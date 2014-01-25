# -*- coding:utf-8 -*-
import korean
import json
import sys

input = sys.stdin.read()

input = input.decode('utf-8')

output = []
for ch in input:
	if korean.hangul.is_hangul(ch):
		output.append(korean.hangul.split_char(ch))
	else:
		output.append(ch)

print json.dumps(output)
