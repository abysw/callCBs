#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# Author: Yuan-SW-F, yuanswf@163.com
# Created Time: 2020-12-04 20:26:14
# Version : Ypip2.0, Python3
# github: https://github.com/Yuan-SW-F/callCBs
# Example call_CBs.py file.maf
# Filter out sequences with nt < 5bp and query_len/reference_len < 0.5, Filter out blocks with fewer than 1 rows.
import sys, os, re

fo_file = sys.argv[1]
fo = open(fo_file)

len_r = 0
check = 0
for line in fo:
        line = line.strip()
        re_head = re.match(r'(\S)', line)
        if re_head:
                head = re_head.group()
        if head == '#':
                print (line)
        elif not re_head:
                if len(seq_id) >= 5 and check > 0:
                        print (block)
                len_r = 0
        else:
                list = line.split( )
                if head == 'a':
                        block = line + "\n"
                        seq_r = ''
                        seq_id = []
                elif head == 's':
                        if len_r == 0:
                                len_r = int(list[3])
                                seq_r = list[6]
                                for i in range(0,len(seq_r)):
                                        re_i = re.match(r'[ATCGatcg]', seq_r[i])
                                        if re_i:
                                                seq_id.append(i) 
                                block += line + "\n"
                                if not 'Medicago_truncatula' in line:
                                        seq_id = []
                                check = 0
                        else:
                                seq_q = list[6]
                                count = 0
                                if 'null' in seq_q:
                                         continue
                                for i in seq_id:
                                         re_i = re.match(r'[ATCGatcg]', seq_q[i])
                                         if re_i:
                                                 count += 1
                                if count >= 5 and count/len(seq_id) >= 0.5:
                                        block += line + "\n"
                                        check += 1
print ("##eof maf")

