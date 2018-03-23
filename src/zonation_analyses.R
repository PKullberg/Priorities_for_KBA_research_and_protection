## KBA priorioty: Prepare zonation raster files
## Author: Peter Kullberg, peter.kullberg@helsinki.fi

# Runs zonatio conservation prioritization analyses.
# WARNING: runnig these analyses will take > 10 days even with moderately fast computer.
# Sourcing this assumes: 
# - Linux sysstem with at ~30 GB ram and > 10 GB free discspace
# - zonation 4 installed and available system wide (https://github.com/cbig/zonation-core)
# - All files under the zruns folder set as shown in the github release xxx

old_wd <- getwd()
setwd(paste0(old_wd, "/zruns/2016_data/1_free_exp_hm1"))
system("./1_free_exp_hm1.sh", ignore.stdout = T, ignore.stderr = T)

setwd(paste0(old_wd, "/zruns/2016_data/2_kba_priority_hm2_plu/"))
system("./2_kba_priority_hm2_plu.sh", ignore.stdout = T, ignore.stderr = T)

setwd(paste0(old_wd, "/zruns/2016_data/3_new_kba_hm2/"))
system("./3_new_kba_hm2.sh", ignore.stdout = T, ignore.stderr = T)

setwd(paste0(old_wd, "/zruns/2016_data/3_new_kba_hm2_GBIF/"))
system("./3_new_kba_hm2_GBIF.sh", ignore.stdout = T, ignore.stderr = T)

setwd(paste0(old_wd, "/zruns/2016_data/3_new_kba_hm2_noDD/"))
system("./3_new_kba_hm2_noDD.sh", ignore.stdout = T, ignore.stderr = T)
setwd(old_wd)

