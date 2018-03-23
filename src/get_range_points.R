## KBA priorioty project: function for fetching GBIF observations within spp ranges
## Author: Peter Kullberg, peter.kullberg@helsinki.fi

# There used to be error in the dismo package that this scrip fixes
source("src/dismo_gbif_patch.R")

get_range_points <- function(spp, buffer = 25000, time = "1990,2016", temp_loc = "/media/DATAPART1/temp_peter") {
  
  # This creates own temporary files for each iteration which are then destroyd in the end
  temp_path <- tempfile(tmpdir = temp_loc)
  dir.create(temp_path, recursive = T)
  rasterOptions(tmpdir = temp_path)
  
  name <- sapply(strsplit(spp, split = "/"), function(x) gsub("IUCN_|_r16p.tif", "", x[5]))
  name <- gsub("(.)([[:upper:]])", "\\1 \\2", name)
  name <- unlist(strsplit(name, " "))
  name[2] <- tolower(name[2])
  
  # fetch specie's gbif data, and if there area subs species filter observations
  gbif_data <- gbif2(name[1], name[2], geo = T, args = paste0("year=", time), temp2 = NA) ##  limit years with args = "year=2000,2016"
  if (!is.null(gbif_data)) {
    # removes possible subspecies 
    if (grepl("Subs", spp)) {
      if (length(name) != 4) {warning("subspecies name uncertain")}
      gbif_data <- gbif_data[grep(name[4], unlist(gbif_data["scientificName"])), ]
    }
    # This trims the data, propably not needed anymore after the gbif2 is used
    if (nrow(gbif_data) != 0 & !is.null(gbif_data$lat) & !is.null(gbif_data$lon)) {gbif_data <- gbif_data[!is.na(gbif_data$lat) | !is.na(gbif_data$lon), ]}  # geo = T is corrected now in the gbif2 function, so this could be removed
    if (nrow(gbif_data) != 0 & !is.null(gbif_data$lon) & !is.null(gbif_data$lon)) {
      
      # filter out spp outside species range
      gbif_spatial <- gbif_data
      coordinates(gbif_spatial) <- c("lon", "lat")
      spp_raster <- raster(spp)
      spp_raster_cropped <- crop(spp_raster, extent(gbif_spatial) + c(-1.5, 1.5, -1.5, 1.5))
      try(spp_raster_cropped <- buffer(spp_raster_cropped, width = buffer, doEdge = TRUE))
      range_obs <- raster::extract(spp_raster_cropped, gbif_spatial)
      
      if(all(is.na(range_obs))) {
        gbif_data <- data.frame("scientificName" = NA, "lon" = NA, "lat" = NA)
      } else {
        gbif_data <- gbif_data[!is.na(range_obs), ]
        gbif_data <- gbif_data[c("scientificName", "lon", "lat")]
      }
    }
  } else {
    gbif_data <- data.frame("scientificName" = NA, "lon" = NA, "lat" = NA)
  }
  unlink(temp_path, recursive = TRUE, force = T) # removes temp rasters
  return(gbif_data)
}
