#!/bin/bash -l
#SBATCH -J 2_kba
#SBATCH -o o_2_kba.txt
#SBATCH -e e_2_kba.txt
#SBATCH -n 1
#SBATCH -t 10-00:00:00
#SBATCH -p longrun
#SBATCH --mem-per-cpu=60GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=peter.kullberg@helsinki.fi

umask 007
zig4 -r 2_kba_priority_hm2_plu.dat ../general_files/threatened_TW_relative_no_marines_DD0.spp 2_kba_priority_hm2_plu_out/2_kba_priority_hm2_plu.txt 0.0 0 1.0 0 --grid-output-formats compressed-tif

