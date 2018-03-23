### KBA priority project: Fetch GBIF observations
### Author: Peter Kullberg, peter@kullberg@helsinki.fi
library(doParallel)
library(foreach)
library(sp)
library(geosphere)
library(raster)

## Fetch the point occurences, to speed up the proces this was run on Arnold ####
# function for getting GBIF observations
source("src/get_range_points.R")

# This is a list of spp with less than 5% within WDPA and KBAs.
# The list is based on outputs of previous zonation runs, but could also be get by intersecting species rasters with WDPA and PA rasters 
load("temp/less_than_5pr.Rda")

registerDoParallel(31)
less_than_5pr_ocs <- foreach(species = less_than_5pr_arnold, .combine = "rbind", .errorhandling = "stop") %dopar% {
  get_range_points(species, buffer = NA)
}

save(less_than_5pr_ocs, file = "temp/less_than_5pr_ocs_dec_new.Rda")

# filter those without observation and make spatial
less_than_5pr_ocs <- less_than_5pr_ocs[!is.na(less_than_5pr_ocs$scientificName), ]
coordinates(less_than_5pr_ocs) <- ~lon+lat
projection(less_than_5pr_ocs) <- CRS("+proj=longlat +ellps=WGS84")

## Add path name, IUCN status and marine status
less_than_5pr_ocs$simpName <- sapply(strsplit(less_than_5pr_ocs$scientificName, " "), function(x) paste(x[c(1,2)], collapse = ""))

# Function for making buffers using geographic coorinate system (thanks to: https://gis.stackexchange.com/questions/250389/euclidean-and-geodesic-buffering-in-r)
make_GeodesicBuffer <- function(pts, width) {
  ### A) Construct buffers as points at given distance and bearing
  # a vector of bearings (fallows a circle)
  dg <- seq(from = 0, to = 360, by = 5)
  
  # Construct equidistant points defining circle shapes (the "buffer points")
  buff.XY <- geosphere::destPoint(p = pts, 
                                  b = rep(dg, each = length(pts)), 
                                  d = width)
  
  ### B) Make SpatialPolygons
  # group (split) "buffer points" by id
  buff.XY <- as.data.frame(buff.XY)
  id  <- rep(1:length(pts), times = length(dg))
  lst <- split(buff.XY, id)
  
  # Make SpatialPolygons out of the list of coordinates
  poly   <- lapply(lst, sp::Polygon, hole = FALSE)
  polys  <- lapply(list(poly), sp::Polygons, ID = NA)
  spolys <- sp::SpatialPolygons(Srl = polys, 
                                proj4string = CRS(as.character("+proj=longlat +ellps=WGS84 +datum=WGS84")))
}

# Loop trough all observations and make single raster layer  per species
foreach(foc_names = less_than_5pr_ocs$simpName) %dopar% {
  species_gbif <- less_than_5pr_ocs[less_than_5pr_ocs$simpName %in% foc_names, ]

  species_buffer <- make_GeodesicBuffer(species_gbif, 25000)
  species_buffer <- gUnaryUnion(species_buffer)
  species_raster <- rasterize(species_buffer, land_mask, filename = paste0("data/gbif_spp_temp/" , gsub(" ", "", foc_names), "_GBIF_range_obs_temp"), format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T)
  mask(species_raster, land_mask, filename = paste0("data/gbif_spp/" ,gsub(" ", "", foc_names),  "_GBIF_range_obs"), format = "GTiff", options = "COMPRESS=DEFLATE", overwrite = T)
}
