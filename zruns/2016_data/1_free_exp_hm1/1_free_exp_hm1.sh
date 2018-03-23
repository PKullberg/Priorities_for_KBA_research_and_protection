#!/bin/bash
umask 007
zig4 -r 1_free_exp_hm1.dat ../general_files/threatened_TW_relative_no_marines_DD0.spp 1_free_exp_hm1_out/1_free_exp_hm1.txt 0.0 0 1.0 0 --grid-output-formats compressed-tif

