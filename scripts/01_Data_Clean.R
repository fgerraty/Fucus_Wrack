##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 01: Clean and Summarise Datasets ################################
#-------------------------------------------------------------------------

####################################
# PART 1: Import and Clean Data ####
####################################


# PART 1A: "Sites" Dataset -----------------------------------------------------

#Import and clean "sites" dataset, which includes site/survey metadata as well as static and dynamic environmental variables associated with each survey
sites <- read_excel("data/raw/sites.xlsx") %>% 
  clean_names() %>% #rename columns
  #Create new values including for the total percent cover of each substrate type across 10 randomly placed quadrats on each beach at the primary wrack line. 
  mutate(percent_boulder = rowSums(pick(pt1_percent_boulder:pt10_percent_boulder))/1000,
         percent_cobble = rowSums(pick(pt1_percent_cobble:pt10_percent_cobble))/1000,
         percent_pebble = rowSums(pick(pt1_percent_pebble:pt10_percent_pebble))/1000,
         percent_granule = rowSums(pick(pt1_percent_granule:pt10_percent_granule))/1000,
         percent_sand = rowSums(pick(pt1_percent_sand:pt10_percent_sand))/1000) %>% 
  #Keep relevant summarized columns and order variables by type (site/survey metadata, static environmental variables, dynamic environmental variables)
  dplyr::select(site:slope_mean, percent_boulder:percent_sand, wind_direction:high_tide)


# PART 1B: "Wrack Cover" Dataset -----------------------------------------------

#Import and clean "wrack_cover" dataset, which includes all data from wrack percent cover surveys
wrack_cover <- read_excel("data/raw/Wrack_Percent_Cover_Raw_Data.xlsx", 
                          skip = 2) %>% 
  clean_names() %>%   #rename columns
  #Calculate the total distance along each transect covered by each macrophyte species, and then divide by 20 to get the percent cover of each transect. 
  group_by(site, transect_number, species_id, species) %>% 
  summarise(percent_cover = sum(total_distance)/20, .groups = "drop")


# PART 1C: "Wrack Biomass" Dataset ---------------------------------------------

#Import and clean "wrack_biomass" dataset, which includes all data from wrack biomass surveys
wrack_biomass <- read_excel("data/raw/Wrack_Biomass_Raw_Data.xlsx", 
                            skip = 2) %>% 
  clean_names() %>% 
  #Calculate the total biomass of wrack of each macrophyte species along each transect.
  group_by(site, transect_number, species_id, species) %>% 
  summarise(biomass = sum(wrack_mass_per_transect), .groups = "drop")


#Create another wrack biomass dataset that also includes zonation
wrack_zonation <- read_excel("data/raw/Wrack_Biomass_Raw_Data.xlsx", 
                            skip = 2) %>% 
  clean_names() %>% 
  group_by(site, transect_number, zone_start, zone_end, species_id, species) %>% 
  summarise(biomass = sum(wrack_mass_per_transect), .groups = "drop")


# PART 1D: "Invertebrate" Dataset Import --------------------------------------

#Import and clean "invertebrate" dataset, which includes all invertebrate data
  
invertebrates <- read_csv("data/raw/Invertebrate_Raw_Data.csv") %>% 
  clean_names()

####################################
# PART 3: Export Processed Data ####
####################################

write_csv(sites, "data/processed/sites.csv")
write_csv(wrack_cover, "data/processed/wrack_cover.csv")
write_csv(wrack_biomass, "data/processed/wrack_biomass.csv")
write_csv(wrack_zonation, "data/processed/wrack_zonation.csv")
write_csv(invertebrates, "data/processed/invertebrates.csv")
