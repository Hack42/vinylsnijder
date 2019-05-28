#!/usr/bin/env python

import io
import sys

if len(sys.argv) != 3:
  print("Usage: ./interleave.py <in1> <in2>\n")
  exit(1)

even = io.open(sys.argv[1], "rb").read()
odd = io.open(sys.argv[2], "rb").read()
interleaved = "".join(i for j in zip(even, odd) for i in j)
sys.stdout.write(interleaved)
