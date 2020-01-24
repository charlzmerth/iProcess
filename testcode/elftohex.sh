#!/bin/bash

extract_section() {
    elf=$1
    section=$2
    arm-none-eabi-objdump -s $elf -j $section|grep -v elf32|grep -v "Contents of section" |awk 'NF'|cut -c 2-41
    }

convert_hex32() {
    cut -c 6-41|tr " " "\n" |awk 'NF'
}

swap_bytes32() {
    while read line ; do
        echo ${line:6:1}${line:7:1}${line:4:1}${line:5:1}${line:2:1}${line:3:1}${line:0:1}${line:1:1}
    done
}

filename=$1
extract_section $filename .text | convert_hex32 | swap_bytes32 > code.hex

extract_section $filename .text | convert_hex32 | cut -c 1-2 > code_data0.hex
extract_section $filename .text | convert_hex32 | cut -c 3-4 > code_data1.hex
extract_section $filename .text | convert_hex32 | cut -c 5-6 > code_data2.hex
extract_section $filename .text | convert_hex32 | cut -c 7-8 > code_data3.hex

(extract_section $filename .rodata.str1.4; extract_section $filename .data) | convert_hex32 | cut -c 1-2 > data0.hex
(extract_section $filename .rodata.str1.4; extract_section $filename .data) | convert_hex32 | cut -c 3-4 > data1.hex
(extract_section $filename .rodata.str1.4; extract_section $filename .data) | convert_hex32 | cut -c 5-6 > data2.hex
(extract_section $filename .rodata.str1.4; extract_section $filename .data) | convert_hex32 | cut -c 7-8 > data3.hex


