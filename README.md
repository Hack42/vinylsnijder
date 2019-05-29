# AG50/AG75 Signline

We are [restoring](https://hack42.nl/wiki/AristoVinylsnijder) an AG50 Signline
vinyl cutter. The firmware supports both the AG50 and the wider AG75.
Unfortunately the model detection appears to be broken, causing the plotter to
report duty as an AG75 and bumping the head against the sides of the machine
during SELF TEST.

To analyze this problem we dumped the memory of the device, which appears
m86k-based.

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

Next step is to find a way to disassemble
