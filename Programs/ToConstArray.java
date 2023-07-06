import java.io.*;

public class ToConstArray {
	public static void main(String[] args) {
		try {
			FileInputStream fis = new FileInputStream(args[0]);
			int len = 0;
			System.out.println("const uint32_t pgm[] = {");
			System.out.print("\t");
			while(fis.available() > 0) {
				len++;
				if(len % 16 == 0) {
					System.out.println();
					System.out.print("\t");
				}
				int val = fis.read();
				System.out.print(String.format("0x%02x,", val));
			}
			System.out.println();
			System.out.println("\t'C','h','i','r','p','!'");
			len += 6;
			System.out.println("};");
			System.out.println("const uint32_t pgm_len = " + len + ";");
			fis.close();
		}catch(Exception e) {
			e.printStackTrace();
		}
	}
}
