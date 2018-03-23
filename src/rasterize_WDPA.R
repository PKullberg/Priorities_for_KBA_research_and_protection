### KBA priority project: Rasterize WDPA layers
### Author: Peter Kullberg, peter@kullberg@helsinki.fi

library(raster)

# template raster for GDAL_rasterize
global_template <- raster("data/masks/CBIG_GlobalCellAreaR_r16c.tif") # this file contains size of 1 arc minute grid cells in geographic coordinate system (in km2). Here the rasters is used simply as a template.
global_template[] <- NA
writeRaster(global_template, "temp/WDPA_template_new.tif", overwrite = T)

# GDAL from commandline (Takes many hours. Commandline veriosn seemed to do the job, whereas the raster::rasterize failed)
# Rasterizes polygon data set of protected areas of the world, which can be downloaded from www.protectedplanet.net (IUCN, & UNEP-WCMC; 2016). Retrieved in December 2016.  
system(gdal_rasterize -at -burn 1 -sql "SELECT * FROM  WDPA_Dec2016_shapefile_polygons WHERE marine <> '2' AND status = 'Designated'" data/WDPA2016dec/WDPA_Dec2016_shapefile_polygons.shp temp/WDPA_template_new.tif)
full_raster <- raster("temp/WDPA_template_new.tif")

# load rasters for filtering
mask_raster <- raster("data/masks/land_mask_nofw_TW_data.tif") # terrestrial areas that overlap with threatened species ranges = 1, others = NA. All data in zonation analyses should be filtered with this, otherwise errors will flood the output. The layer is produced using wrrcsr-layer of an initial zonation run 
water_mask <- raster("data/masks/CBIG_LandWater_r16b.tif") # non-terrestrial areas = 1 > filter data for general statistics

WDPA2016_nofw_r16 <- mask(full_raster, mask_raster, filename = "data/masks/WDPA_raster_2016_nofw.tif", format = "GTiff", silent = F, overwrite = T, options = "COMPRESSION=DEFLATE")
WDPA2016_nofw_r16_all_included <- mask(full_raster, water_mask, filename = "data/masks/WDPA_raster_2016_nofw_all_included.tif", format = "GTiff", silent = F, overwrite = T, options = "COMPRESSION=DEFLATE")