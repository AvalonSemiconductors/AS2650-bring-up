using System;
using System.IO;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace Signetics2650 {
    enum AddressingModes {
        Implicit,
        Zero,
        Immediate,
        Relative,
        Absolute
    }
    struct Instruction {
            public Instruction(uint op, bool br, bool reg, AddressingModes addr) {
                opcode = op;
                isBranch = br;
                needsRegister = reg;
                addrMode = addr;
            }
            public uint opcode { get; }
            public bool isBranch { get; }
            public bool needsRegister { get; }
            public AddressingModes addrMode { get; }
    }
    class Asm2650 {
        private static Dictionary<string, Instruction> cpuInstrs = null;
        private static List<string> unusableOpcodes;
        private static string[] invalidLabelStarts = {"0","1","2","3","4","5","6","7","8","9"};
        private static char[] invalidLabelSymbols = {'-', '+', '*', '/', '>', '<', ',', '\\', '\'', '%'};
        static void FillInstructionTable() {
            cpuInstrs = new Dictionary<string, Instruction>();
            unusableOpcodes = new List<string>();
            cpuInstrs.Add("lodz", new Instruction(0x00, false, true, AddressingModes.Zero));
            cpuInstrs.Add("lodi", new Instruction(0x04, false, true, AddressingModes.Immediate));
            cpuInstrs.Add("lodr", new Instruction(0x08, false, true, AddressingModes.Relative));
            cpuInstrs.Add("loda", new Instruction(0x0C, false, true, AddressingModes.Absolute));
            cpuInstrs.Add("spsu", new Instruction(0x12, false, false, AddressingModes.Implicit));
            cpuInstrs.Add("spsl", new Instruction(0x13, false, false, AddressingModes.Implicit));
            cpuInstrs.Add("retc", new Instruction(0x14, true, false, AddressingModes.Implicit));
            cpuInstrs.Add("bctr", new Instruction(0x18, true, false, AddressingModes.Relative));
            cpuInstrs.Add("bcta", new Instruction(0x1C, true, false, AddressingModes.Absolute));
            cpuInstrs.Add("eorz", new Instruction(0x20, false, true, AddressingModes.Zero));
            cpuInstrs.Add("eori", new Instruction(0x24, false, true, AddressingModes.Immediate));
            cpuInstrs.Add("eorr", new Instruction(0x28, false, true, AddressingModes.Relative));
            cpuInstrs.Add("eora", new Instruction(0x2C, false, true, AddressingModes.Absolute));
            cpuInstrs.Add("redc", new Instruction(0x30, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("rete", new Instruction(0x34, true, false, AddressingModes.Implicit));
            cpuInstrs.Add("bstr", new Instruction(0x38, true, false, AddressingModes.Relative));
            cpuInstrs.Add("bsta", new Instruction(0x3C, true, false, AddressingModes.Absolute));
            cpuInstrs.Add("halt", new Instruction(0x40, false, false, AddressingModes.Implicit));
            cpuInstrs.Add("andz", new Instruction(0x40, false, true, AddressingModes.Zero));
            unusableOpcodes.Add("andz,r0");
            cpuInstrs.Add("andi", new Instruction(0x44, false, true, AddressingModes.Immediate));
            cpuInstrs.Add("andr", new Instruction(0x48, false, true, AddressingModes.Relative));
            cpuInstrs.Add("anda", new Instruction(0x4C, false, true, AddressingModes.Absolute));
            cpuInstrs.Add("rrr",  new Instruction(0x50, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("rede", new Instruction(0x54, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("brnr", new Instruction(0x58, true, true, AddressingModes.Relative));
            cpuInstrs.Add("brna", new Instruction(0x5C, true, true, AddressingModes.Absolute));
            cpuInstrs.Add("iorz", new Instruction(0x60, false, true, AddressingModes.Zero));
            cpuInstrs.Add("iori", new Instruction(0x64, false, true, AddressingModes.Immediate));
            cpuInstrs.Add("iorr", new Instruction(0x68, false, true, AddressingModes.Relative));
            cpuInstrs.Add("iora", new Instruction(0x6C, false, true, AddressingModes.Absolute));
            cpuInstrs.Add("redd", new Instruction(0x70, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("cpsu", new Instruction(0x74, false, false, AddressingModes.Immediate));
            cpuInstrs.Add("cpsl", new Instruction(0x75, false, false, AddressingModes.Immediate));
            cpuInstrs.Add("ppsu", new Instruction(0x76, false, false, AddressingModes.Immediate));
            cpuInstrs.Add("ppsl", new Instruction(0x77, false, false, AddressingModes.Immediate));
            cpuInstrs.Add("bsnr", new Instruction(0x78, true, true, AddressingModes.Relative));
            cpuInstrs.Add("bsna", new Instruction(0x7C, true, true, AddressingModes.Absolute));
            cpuInstrs.Add("addz", new Instruction(0x80, false, true, AddressingModes.Zero));
            cpuInstrs.Add("addi", new Instruction(0x84, false, true, AddressingModes.Immediate));
            cpuInstrs.Add("addr", new Instruction(0x88, false, true, AddressingModes.Relative));
            cpuInstrs.Add("adda", new Instruction(0x8C, false, true, AddressingModes.Absolute));
            cpuInstrs.Add("lpsu", new Instruction(0x92, false, false, AddressingModes.Implicit));
            cpuInstrs.Add("lpsl", new Instruction(0x93, false, false, AddressingModes.Implicit));
            cpuInstrs.Add("dar",  new Instruction(0x94, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("bcfr", new Instruction(0x98, true, false, AddressingModes.Relative));
            cpuInstrs.Add("zbrr", new Instruction(0x9B, true, false, AddressingModes.Relative));
            unusableOpcodes.Add("bcfr,un");
            unusableOpcodes.Add("bcfr,3");
            cpuInstrs.Add("bcfa", new Instruction(0x9C, true, false, AddressingModes.Absolute));
            cpuInstrs.Add("bxa",  new Instruction(0x9F, true, false, AddressingModes.Absolute));
            unusableOpcodes.Add("bcfa,un");
            unusableOpcodes.Add("bcfa,3");
            cpuInstrs.Add("subz", new Instruction(0xA0, false, true, AddressingModes.Zero));
            cpuInstrs.Add("subi", new Instruction(0xA4, false, true, AddressingModes.Immediate));
            cpuInstrs.Add("subr", new Instruction(0xA8, false, true, AddressingModes.Relative));
            cpuInstrs.Add("suba", new Instruction(0xAC, false, true, AddressingModes.Absolute));
            cpuInstrs.Add("wrtc", new Instruction(0xB0, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("tpsu", new Instruction(0xB4, false, false, AddressingModes.Immediate));
            cpuInstrs.Add("tpsl", new Instruction(0xB5, false, false, AddressingModes.Immediate));
            cpuInstrs.Add("bsfr", new Instruction(0xB8, true, false, AddressingModes.Relative));
            unusableOpcodes.Add("bsfr,un");
            unusableOpcodes.Add("bsfr,3");
            cpuInstrs.Add("zsbr", new Instruction(0xBB, true, false, AddressingModes.Relative));
            cpuInstrs.Add("bsfa", new Instruction(0xBC, true, false, AddressingModes.Absolute));
            cpuInstrs.Add("bsxa", new Instruction(0xBF, true, false, AddressingModes.Absolute));
            unusableOpcodes.Add("bsfa,un");
            unusableOpcodes.Add("bsfa,3");
            cpuInstrs.Add("nop",  new Instruction(0xC0, false, false, AddressingModes.Implicit));
            cpuInstrs.Add("strz", new Instruction(0xC0, false, true, AddressingModes.Zero));
            unusableOpcodes.Add("strz,r0");
            cpuInstrs.Add("strr", new Instruction(0xC8, false, true, AddressingModes.Relative));
            cpuInstrs.Add("stra", new Instruction(0xCC, false, true, AddressingModes.Absolute));
            cpuInstrs.Add("rrl",  new Instruction(0xD0, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("wrte", new Instruction(0xD4, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("birr", new Instruction(0xD8, true, true, AddressingModes.Relative));
            cpuInstrs.Add("bira", new Instruction(0xDC, true, true, AddressingModes.Absolute));
            cpuInstrs.Add("comz", new Instruction(0xE0, false, true, AddressingModes.Zero));
            cpuInstrs.Add("comi", new Instruction(0xE4, false, true, AddressingModes.Immediate));
            cpuInstrs.Add("comr", new Instruction(0xE8, false, true, AddressingModes.Relative));
            cpuInstrs.Add("coma", new Instruction(0xEC, false, true, AddressingModes.Absolute));
            cpuInstrs.Add("wrtd", new Instruction(0xF0, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("tmi",  new Instruction(0xF4, false, true, AddressingModes.Implicit));
            cpuInstrs.Add("bdrr", new Instruction(0xF8, true, true, AddressingModes.Relative));
            cpuInstrs.Add("bdra", new Instruction(0xFC, true, true, AddressingModes.Absolute));
            
            //AS2650 only!
            cpuInstrs.Add("mul", new Instruction(0x90, false, false, AddressingModes.Implicit));
            cpuInstrs.Add("xchg", new Instruction(0x91, false, false, AddressingModes.Implicit));
            cpuInstrs.Add("push", new Instruction(0x10, false, false, AddressingModes.Implicit));
            cpuInstrs.Add("pop", new Instruction(0x11, false, false, AddressingModes.Implicit));
        }

        private static bool ParseNum(string s, out uint res) {
            uint temp;
            if(s.StartsWith("0b")) {
                s = s.Substring(2);
                temp = 0;
                for(int i = 0; i < s.Length; i++) {
                    temp <<= 1;
                    char c = s[i];
                    if(c == '1') temp += 1;
                    else if(c != '0') {
                        res = 0;
                        return false;
                    }
                }
                res = temp;
                return true;
            }else if(s.StartsWith("0x")) {
                s = s.Substring(2);
                bool a = uint.TryParse(s, System.Globalization.NumberStyles.HexNumber, null, out temp);
                if(!a) res = 0;
                else res = temp;
                return a;
            }else if(s.StartsWith('\'')) {
                if(s.Length != 3 || s[2] != '\'') {
                    res = 0;
                    return false;
                }
                res = s[1];
                return true;
            }else {
                bool a = uint.TryParse(s, System.Globalization.NumberStyles.None, null, out temp);
                if(!a) res = 0;
                else res = temp;
                return a;
            }
        }

        private static bool ParseInstrArg(string s, Dictionary<string, uint> symbolTable, out uint res) {
            uint temp;
            Regex regex = new Regex(@"[+\-*/%]|>>|<<");
            Match m = regex.Match(s);
            if(!m.Success || s.StartsWith('\'')) {
                if(ParseNum(s, out temp)) {
                    res = temp;
                    return true;
                }
                if(symbolTable.ContainsKey(s)) {
                    res = symbolTable[s];
                    return true;
                }
                res = 0;
                return false;
            }
            MatchCollection ms = regex.Matches(s);
            m = ms[ms.Count - 1];
            string p1 = s.Substring(0, m.Index);
            string p2 = s.Substring(m.Index + m.Length);
            uint val1,val2;
            if(!ParseInstrArg(p1, symbolTable, out val1) || !ParseInstrArg(p2, symbolTable, out val2)) {
                res = 0;
                return false;
            }
            char c = s[m.Index];
            if(c == '+') res = val1 + val2;
            else if(c == '-') {
                if(val2 > val1) {
                    Console.WriteLine("Value underflow");
                    res = 0;
                    return false;
                }
                res = val1 - val2;
            }else if(c == '*') res = val1 * val2;
            else if(c == '/') res = val1 * val2;
            else if(c == '%') res = val1 % val2;
            else if(c == '>') res = val1 >> (int)val2;
            else if(c == '<') res = val1 << (int)val2;
            else {
                res = 0;
                return false;
            }
            return true;
        }

        private static bool ParseInstr(string s, out string enc, out string arg1, out string arg2, out string arg3) {
            int i;
            for(i = 0; i < s.Length; i++) {
                char c = s[i];
                if(c == ',' || c == ' ' || c == '\t') break;
            }
            if(i == s.Length) {
                enc = s;
                arg1 = arg2 = arg3 = null;
                return true;
            }
            enc = s.Substring(0, i);
            if(s[i] == ' ' || s[i] == '\t') {
                arg1 = s.Substring(i + 1);
                arg2 = arg3 = null;
                return !(arg1.Contains(' ') || arg1.Contains('\t') || arg1.Contains(','));
            }
            s = s.Substring(i + 1);
            i = 0;
            for(i = 0; i < s.Length; i++) {
                char c = s[i];
                if(c == ' ' |