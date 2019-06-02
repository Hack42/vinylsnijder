# AG50/AG75 Signline

We are [restoring](https://hack42.nl/wiki/AristoVinylsnijder) an AG50 Signline
vinyl cutter. The firmware supports both the AG50 and the wider AG75.
Unfortunately the model detection appears to be broken, causing the plotter to
report duty as an AG75 and bumping the head against the sides of the machine
during SELF TEST.

To analyze this problem we dumped the memory of the device, which has a
MC68HC000FN16 processor. This repo contains the dumps and a Makefile to
stitch them together and create a raw disassembly - though rather than
analyzing by hand it is much easier to use a tool like
[Ghidra](https://ghidra-sre.org).

On machine startup it shows `AG75 SIGNLINE` on the display, where we would
expect `AG50 SIGNLINE` (or perhaps `AG50/75 SIGNLINE`). Indeed we find this
string in the dumped firmware:

```
00007d70  56 45 20 31 31 32 20 20  20 20 00 00 20 20 20 20  |VE 112    ..    |
00007d80  45 52 52 4f 52 20 46 41  54 41 4c 20 31 31 32 20  |ERROR FATAL 112 |
00007d90  20 20 20 20 00 00 20 20  20 20 46 41 54 41 4c 45  |    ..    FATALE|
00007da0  20 45 52 52 45 55 52 20  31 31 32 20 20 20 00 00  | ERREUR 112   ..|
00007db0  20 56 20 31 2e 38 41 20  20 00 00 00 41 47 35 30  | V 1.8A  ...AG50|
00007dc0  2f 37 35 20 53 49 47 4e  4c 49 4e 45 20 00 00 00  |/75 SIGNLINE ...|
00007dd0  00 00 00 00 00 00 20 41  47 35 30 20 53 49 47 4e  |...... AG50 SIGN|
00007de0  4c 49 4e 45 20 00 00 00  00 00 00 00 00 00 00 00  |LINE ...........|
00007df0  20 41 47 37 35 20 53 49  47 4e 4c 49 4e 45 20 00  | AG75 SIGNLINE .|
00007e00  00 00 00 00 00 00 00 00  00 00 20 20 20 20 20 20  |..........      |
00007e10  20 53 45 4c 46 20 54 45  53 54 20 20 20 20 20 20  | SELF TEST      |
00007e20  20 20 00 00 20 20 20 20  20 20 20 53 45 4c 42 53  |  ..       SELBS|
00007e30  54 54 45 53 54 20 20 20  20 20 20 20 00 00 20 20  |TTEST       ..  |
00007e40  20 20 20 20 20 41 55 54  4f 20 54 45 53 54 20 20  |     AUTO TEST  |
```

## Memory layout

| Item   | From          | To            | Notes
| ------ | ------------- | ------------- | ---------
| ROM    | `0x0000.0000` | `0x0002.ffff` | Gesplitst in Low en High byte EPROMS
| CMFP   | `0x0020.0000` | `0x0020.002f` | CMOS Multi-Function Peripheral ([Datasheet](docs/ts68hc901.pdf))
| RAM    | `0x0030.0000` | `0x0030.7fff` | Volgens de memory test
| EEPROM | ?             | ?+4k          | CMOS EEPROM ([Datasheet](docs/28c04a.pdf))

Notable addresses:

0x280001 I/O?
0x303ffe initial stack pointer
0x30d914 memcheck result
0x30d9d6 language ('0'=english, '1'=german, '2'=spanish?, '3'=french)
0x30d982 model indicator ('5'=AG50, '7'=AG75, '\0'=AG50/75)
0x30e5ac selftest result
0x30e6e4 initialized with blob of length ? from 0x50a
0x30e898 initialized with blob of length ? from 0x6c7

We suspect some user settings, such as the language and model to show during
boot are stored in the 28c04a. Can it be that that is memory-mapped around
0x30d900?

The language is read at 0x18008 and also found at 0xc910. It looks like area
around 0xc910 is some kind of data structure describing the menu's, as it contains
many pointers into 0x300000 and to settings strings.

The model indicator at 0x30d982 is used to determine what model to show during
boot, but AFAICS it is not used to determine how far to move the carriage
during the self-test.

Unlike the language, the model indicator does not appear anywhere around 0xc910
(which makes sense since it doesn't seem to be in the menu's).
It is read at 0x18020, and also appears at 0x89b. Not sure yet how to interpret
that.

Main questions:
* how is the model indicator written?
* if not the model indicator, what determines how far the carriage is to move
  during initialization.
