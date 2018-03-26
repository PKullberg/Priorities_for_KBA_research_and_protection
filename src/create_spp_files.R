### KBA priority project: create spp-files for zonation.
### Author: Peter Kullberg, peter@kullberg@helsinki.fi

library(zonator)
library(raster)
library(tidyverse)

# Create spp files using folders that contain rasterized versions of species in the IUCN redlist of threatened species.
# (The rasterized species distribution files that are used here, are produced within a different project, and the descrption of rasterization scripts is not aivailable within this document). 
create_spp(filename = "zruns/production/general_files/new_amphibians.spp", weight = 1, alpha = 1, bqp = 1,
           bqp_p = 1, cellrem = 0.25, "data/New_global_species/IUCN_AmphibiansCBIGClassification_r16p/",
           spp_file_pattern = "\\.tif$", override_path = NULL)

create_spp(filename = "zruns/production/general_files/new_birds.spp", weight = 1, alpha = 1, bqp = 1,
           bqp_p = 1, cellrem = 0.25, "data/New_global_species/IUCN_BirdsCBIGClassification_r16p/",
           spp_file_pattern = "\\.tif$", override_path = NULL)

create_spp(filename = "zruns/production/general_files/new_mammals.spp", weight = 1, alpha = 1, bqp = 1,
           bqp_p = 1, cellrem = 0.25, "data/New_global_species/IUCN_MammalsCBIGClassification_r16p/",
           spp_file_pattern = "\\.tif$", override_path = NULL)

# load spp-files and combine to one
amphibians <- read.table("zruns/2016_data/general_files/new_amphibians.spp")
birds <- read.table("zruns/2016_data/general_files/new_birds.spp")
mammals <- read.table("zruns/2016_data/general_files/new_mammals.spp")

all_spp <- rbind(amphibians, birds, mammals)
# all_spp <- read.table("zruns/2016_data/general_files/all_vertebrate.spp")

# make paths spp files relative to the project folder 
terrestrial_threatened_spp <- all_spp %>% mutate(V6 = gsub("/wrk/pkullber/zonation_runs/KBA_priority/" ,"../../../" ,V6))

# Filter out purely marine spp
## this is a bit tricky way to do this but IUCN RLI portal does not allow "select not ..." operations, or provide info on the system in the data table.
### terrestrial tetrapods from IUCN RL, downloaded 12 / 2016, search by system: marine, include sub species
marines <- read.csv("data/spp_info/marin_IUCN_search_2016.csv")
### terrestrial tetrapods from IUCN RL, downloaded 12 / 2016, search by system: marine + terrestrial, include sub species
terrestrials <- read.csv("data/spp_info/terrestrial_IUCN_search_2016.csv")  

marine_spp <- dplyr::anti_join(x = marines, y = terrestrials, by = c("Genus", "Species")) %>%
  mutate(Species = sub("(.)", "\\U\\1", Species, perl = TRUE)) %>% 
  unite(Name, Genus, Species, sep = "") %>% 
  select(Name)

terrestrial_spp <- all_spp %>% mutate(key = str_split(V6, "_", simplify = T)[ ,8]) %>%
  anti_join(marine_spp, by = c("key" = "Name"))


# Filter non-threatened and DD species form the spp file
## this data is downloaded form the IUCN redlist website and edited to contain only species name and threat status
spp_info <- read.csv2("data/New_global_species/species_RLI_class.csv")

## add gbif spp
GBIF_files <- list.files("data/gbif_spp", full.names = T) %>% str_c("../../../", .)
GBIF_spp <- data.frame(V1 = 1, V2 = 1, V3 = 1, V4 = 1, V5 = 0.25, V6 = GBIF_files, key = NA, Status = "GBIF")

terrestrial_threatened_and_dd_spp <- terrestrial_spp %>% left_join(spp_info, by = c("key" = "Name")) %>%
  filter(!Status %in% c("LC", "NT"))

terrestrial_DD0_spp <- terrestrial_threatened_and_dd_spp %>%
  mutate(V1 = if_else(Status == "DD", 0, 1)) %>%
  select(-Status, -key)


# make spp fille with all data
terrestrial_threatened_dd_and_gbif_spp_status <- bind_rows(terrestrial_threatened_and_dd_spp, GBIF_spp) # leave status for later use
terrestrial_threatened_dd_and_gbif_spp <- select(terrestrial_threatened_dd_and_gbif_spp_status, -Status, -key)

# make spp fille where gbif and DD species have 0 weight (They don't not affect the prioritization, but their status can be followed)
GBIF_spp <- data.frame(V1 = 0, V2 = 1, V3 = 1, V4 = 1, V5 = 0.25, V6 = GBIF_files)
terrestrial_threatened_dd_and_gbif0_spp <- bind_rows(terrestrial_threatened_and_dd_spp, GBIF_spp)
terrestrial_threatened_dd0_and_gbif0_spp <- bind_rows(terrestrial_DD0_spp, GBIF_spp)

write.table(terrestrial_threatened_dd_and_gbif_spp, "zruns/2016_data/general_files/threatened_only_TW_relative_no_marines.spp", row.names = F, col.names = F)
write.table(terrestrial_threatened_dd_and_gbif0_spp, "zruns/2016_data/general_files/threatened_and_GBIF05_TW_relative_no_marines.spp", row.names = F, col.names = F)
write.table(terrestrial_threatened_dd0_and_gbif0_spp, "zruns/2016_data/general_files/threatened_TW_relative_no_marines_DD0.spp", row.names = F, col.names = F)
