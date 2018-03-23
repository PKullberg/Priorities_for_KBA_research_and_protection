#!/bin/bash
umask 007
zig4 -r 3_new_kba_hm2.dat ../general_files/threatened_only_TW_relative_no_marines.spp 3_new_kba_hm2_out/3_new_kba_hm2.txt 0.0 0 1.0 0 --grid-output-formats compressed-tif

