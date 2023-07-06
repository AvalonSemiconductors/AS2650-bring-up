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

## Indirect addressed branch instructions do not work
The condition that causes the control logic to switch a branch or branch to subroutine instruction to read the branch target from a memory location pointed to by its argument cannot trigger.
Opcodes for indirect addressed branches will instead incorrectly execute as regular absolute branches.

Severity: Medium, breaks Signetics 2650 binary-compatibility
### Workarounds
A whole absolute branch instruction can be written out into RAM instead, and be branched to, to cause a indirect branch.

## Indexed addressing does not work on arithmetic and logic operations
Indexed addressing only appears to work on load/store instructions. Instructions such as `adda,r0 mem_loc,r3+` will not execute correctly. Indexed addressing cannot be used on instructions not of the load/store type.

Severity: Medium, breaks Signetics 2650 binary-compatibility
### Workarounds
If the argument to an affected instruction must come from an indexed location, it can instead be first loaded into a CPU register and then used.

## Incorrect carry generation on subtraction of 0 or addition of 255 while carry flag is set
Subtracting 0 from any register, or adding 255 to any register, while the carry flag is set, will cause the carry flag to be cleared, which is incorrect. However, the register will be correctly modified.

Severity: High
### Workarounds
Additional code must be wrapped around affected instructions to specifically check for these cases and correct them manually.

Note: this only affects cases where the carry flag is needed in future operations, i.e. when adding 32-bit integers comprised of multiple words. Word sizes of 8 and, in the case of addition, 16 bits are not affected if the carry is not needed.
