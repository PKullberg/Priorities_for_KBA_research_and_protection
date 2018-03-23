#!/bin/bash
umask 007
zig4 -r 3_new_kba_hm2_noDD.dat ../general_files/threatened_TW_relative_no_marines_DD0.spp 3_new_kba_hm2_noDD_out/3_new_kba_hm2_noDD.txt 0.0 0 1.0 0 --grid-output-formats compressed-tif

