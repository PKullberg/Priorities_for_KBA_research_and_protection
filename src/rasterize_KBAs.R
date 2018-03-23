### KBA priority project: Rasterize KBA layers
### Author: Peter Kullberg, peter@kullberg@helsinki.fi

library(raster)

# template raster for GDAL_rasterize
global_template <- raster("data/masks/CBIG_GlobalCellAreaR_r16c.tif")
global_template[] <- NA
writeRaster(global_template, "temp/KBA_template_new.tif", overwrite = T)

# GDAL from commandline (Takes many hours. Commandline veriosn seemed to do the job, whereas the raster::rasterize failed)
system("gdal_rasterize -at -a SITRECID -l Global_KBA_poly data/KBAsGlobal_2016_4/Global_KBA_poly.shp temp/KBA_template_new.tif")
full_raster <- raster("temp/KBA_template_new.tif")

# load rasters for filtering
mask_raster <- raster("data/masks/land_mask_nofw_TW_data.tif") # terrestrial areas that overlap with threatened species ranges = 1, others = NA. All data in zonation analyses should be filtered with this, otherwise errors will flood the output. The layer is produced using wrrcsr-layer of an initial zonation run 
water_mask <- raster("data/masks/CBIG_LandWater_r16b.tif") # non-terrestrial areas = 1 > filter data for general statistics

# ID layers.
KBA2016_nofw_r16_threatened_included <- mask(full_raster, water_mask, filename = "data/masks/KBA_ID_raster_2016_only_terrestrials.tif", format = "GTiff", silent = F, overwrite = T, options = "COMPRESSION=DEFLATE") # for general stats and plots
KBA2016_nofw_r16 <- mask(full_raster, mask_raster, filename = "data/masks/KBA_ID_raster_2016_nofw.tif", format = "GTiff", silent = F, overwrite = T, options = "COMPRESSION=DEFLATE")  # for z analyses

# binary KBA-mask layer: KBAs = 1, others = NA
full_raster_binary_nofw_threatened_included <- calc(KBA2016_nofw_r16_threatened_included, fun = function(x) {x[!is.na(x)] <- 1; return(x)}, filename = "data/masks/KBA_raster_2016_full_threatened_included.tif", format = "GTiff", silent = F, overwrite = T, options = "COMPRESSION=DEFLATE")
full_raster_binary_nofw <- calc(KBA2016_nofw_r16, fun = function(x) {x[!is.na(x)] <- 1; return(x)}, filename = "data/masks/KBA_raster_2016_full.tif", format = "GTiff", silent = F, overwrite = T, options = "COMPRESSION=DEFLATE")
full_raster_marine_and_terrestrial <- calc(full_raster, fun = function(x) {x[!is.na(x)] <- 1; return(x)}, filename = "data/masks/KBA_raster_2016_marine_and_terr.tif", format = "GTiff", silent = F, overwrite = T, options = "COMPRESSION=DEFLATE")