all: ag50-75-v1.8a.dump

.PHONY: clean

clean:
	rm *.dump *.bin

%.bin: %.hex
	/usr/share/python3-intelhex/hex2bin.py $< $@

ag50-75-v1.8a.bin: ag50-75-v1.8a-l-part1.bin ag50-75-v1.8a-h-part1.bin ag50-75-v1.8a-l-part2.bin ag50-75-v1.8a-h-part2.bin
	./interleave.py ag50-75-v1.8a-h-part1.bin ag50-75-v1.8a-l-part1.bin > $@
	./interleave.py ag50-75-v1.8a-h-part2.bin ag50-75-v1.8a-l-part2.bin >> $@

%.dump: %.bin
	/usr/m68k-linux-gnu/bin/objdump -d $< > $@

