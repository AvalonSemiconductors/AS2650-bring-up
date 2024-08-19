# Bugs
This README serves as a central point to document all hardware bugs of the AS2650.

## Power-up I/O config
### Description
I/O config is incorrect on power-up, with some pins assigned to the management controller instead of the user design.

Severity: Low
### Workarounds
Management controller can write the correct I/O config.

## Reset pin not separate
### Description
AS2650 does not have a separate reset pin from the whole of the chip, as a result, it shares a reset with the management controller.

This affects the design negatively, as it is impossible to stop the AS2650 from running while the management controller is still applying the correct I/O config, as described in the previous bug. The AS2650 therefor ends up in an unpredictable state by the time the I/O config is applied.

Severity: Low
### Workarounds
The management controller’s gpio pin can be used to generate a reset pulse and allow the management controller to reset both itself and the AS2650 after applying the I/O config.

## Interdigit Carry is never generated correctly
During add and subtract instructions, the IDC is simply set to the 4th bit of the result, which is wrong.

Severity: Low (don’t care about BCD anyways)

## Indirect, relative addressed branch instructions do not work
The condition that causes the control logic to switch a relative branch or relative branch to subroutine instruction to read the branch target from a memory location pointed to by its argument cannot trigger.

Severity: Medium, breaks Signetics 2650 binary-compatibility
### Workarounds
Absolute, indirect branches/calls still work.

## Indexed addressing does not work on arithmetic and logic operations
Indexed addressing only appears to work on load/store instructions. Instructions such as `adda,r0 mem_loc,r3+` will not execute correctly. Indexed addressing cannot be used on instructions not of the load/store type.

Severity: Medium, breaks Signetics 2650 binary-compatibility
### Workarounds
If the argument to an affected instruction must come from an indexed location, it can instead be first loaded into a CPU register and then used.

## Return instruction takes 256 clock cycles to complete
The cycle counter is not reset to 0 after the instruction finished executing, causing the processor to become stuck for 253 additional clock cycles, until the counter rolls over.

Severity: Medium
### Workarounds
Use pop instruction to obtain topmost bytes in call stack, and use a indirect addressed branch to return.

## Push instruction writes to wrong location
Push instruction writes to where the stack pointer is pointing, not the address before.

Severity: Medium

## Indirect indexed store instructions do not work
The address appears to be computed correctly, but no value is ever output on the bus.

Severity: High

## Incorrect carry generation on subtraction of 0 or addition of 255 while carry flag is set
Subtracting 0 from any register, or adding 255 to any register, while the carry flag is set, will cause the carry flag to be cleared, which is incorrect. However, the register will be correctly modified.

Severity: High
### Workarounds
Additional code must be wrapped around affected instructions to specifically check for these cases and correct them manually.

Note: this only affects cases where the carry flag is needed in future operations, i.e. when adding 32-bit integers comprised of multiple words. Word sizes of 8 and, in the case of addition, 16 bits are not affected if the final carry is not needed further.
