## KBA priorioty: Prepare zonation raster files
## Author: Peter Kullberg, peter.kullberg@helsinki.fi
library(raster)

# these scripts creates rasters from WDPA and KBA polygons. The run takes many hours and requires substantial amount of memory
source("src/rasterize_WDPA.R")
wdpa_mask <- raster("data/masks/WDPA_raster_2016_nofw.tif")
wdpa_mask_all <- raster("data/masks/WDPA_raster_2016_nofw_all_included.tif")

source("src/rasterize_KBAs.R")
KBA_value_raster <- raster("data/masks/KBA_ID_raster_2016_nofw.tif")
kba_mask <- raster("data/masks/KBA_raster_2016_full.tif")
kba_mask_all <- raster("data/masks/KBA_raster_2016_full_threatened_included.tif")

land_mask_z <- raster("data/masks/land_mask_nofw_TW_data.tif") # created with initial zonation run. Contains terestrial areas that overlap with threatened spp ranges.
land_mask_fw <- raster("data/masks/CBIG_LandWater_r16b.tif") # Freswater data from CBIG-database

## Hierarchical masks: These masks force removal hierarchy into zonation analyses. If hierarchical mask is used, cells with low value area removed first.
hm1_2016 <- mask(land_mask_z, wdpa_mask, maskvalue = 1, updatevalue = 2, filename = "data/masks/hm1_2016.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT2S")
hm2_temp <- mask(land_mask_z, kba_mask, maskvalue = 1, updatevalue = 2, filename = "temp/temp_hm2.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT2S") # just a helpper file.
hm2_2016 <- mask(hm2_temp, wdpa_mask, maskvalue = 1, updatevalue = 3, filename = "data/masks/hm2_2016.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT2S")

## int this case KBA value raster can be used directly as the IDs are so small.
sort(unique(KBA_value_raster)) # There is no KBA with ID 1 or 2 so it is safe to use lasndmask = 1 and WDPA = 2 directly in the PLU raster
KBA_plula <- merge(KBA_value_raster, land_mask, filename = "temp/kba_plula_2016_storage.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT4U")
KBA_plula <- mask(KBA_plula, wdpa_mask, maskvalue = 1, updatevalue = 2, filename = "data/masks/kba_plula_2016.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT4U")
KBA_plula <- mask(KBA_plula, land_mask, filename = "data/masks/kba_plula_2016_nofw.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT4U")
KBA_plula_filt <- mask(KBA_plula, not_protected_or_kba_z_filt, maskvalue = 1, updatevalue = 1, filename = "temp/kba_plula_2016_filt.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT4U")


# Some derived datasets are needed to process the results 
## Check which data needs to be leoaded from zonation_raster
unprotected_KBA_z <- raster("../data/masks/non_protected_KBAs_2016_threatened_included.tif")
# combined KBAs and WDPAs mask
wdpa_and_kba_mask_all <- merge(wdpa_mask_all, kba_mask_all, filename = "data/masks/wdpa_and_kba_mask_all.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT2S")

# Make not protected mask
not_protected <- reclassify(wdpa_mask_all, matrix(c(NA, 1, 1, NA), 2, 2, byrow = T ), filename = "temp/not_protected.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T)
not_protected <- mask(not_protected, land_mask_fw, filename = "data/masks/not_protected.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T)
not_protected_z <- mask(not_protected, land_mask_z, filename = "data/masks/not_protected_z.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T)

# make mask files of areas with no KBAs or PAs
not_protected_or_kba_z <- mask(not_protected_z, unprotected_KBAs_2016, maskvalue = 1, filename = "data/masks/not_protected_or_kba_z.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T)
not_protected_or_kba <- mask(not_protected, unprotected_KBAs_2016_all, maskvalue = 1, filename = "data/masks/not_protected_or_kba.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T)

# Unprotected areas
unprotected_KBAs_2016 <- mask(kba_mask, wdpa_mask, maskvalue = 1, updatevalue = NA, filename = "data/masks/non_protected_KBAs_2016.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT2S")
unprotected_KBAs_2016_all <- mask(kba_mask_all, wdpa_mask_all, maskvalue = 1, updatevalue = NA, filename = "data/masks/non_protected_KBAs_2016_threatened_included.tif", format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T, datatype = "INT2S")
