##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 0X: Wrack Plots #################################################
#-------------------------------------------------------------------------

####################################
# PART 1: Import Data ##############
####################################

#Import cleaned datasets from the "processed" data folder. 
wrack_cover <- read_csv("data/processed/wrack_cover.csv")
wrack_biomass <- read_csv("data/processed/wrack_biomass.csv")
wrack_zonation <- read_csv("data/processed/wrack_zonation.csv")


####################################
# PART 2: XXX ######################
####################################

#Sites ordered from North to South for plots
site_order <- c("Mosquito", "OldSitka", "Shotgun", "Cruise", "Halibut", "Magic", "NetIsland", "Harbor", "Sandy", "Totem", "Indian", "Eagle", "Private", "Ferry", "Jamestown")

#Wrack Species ordered from most to least total biomass
wrack_order <- factor("Fucus dischitus", "Macrocystis pyrifera", "Zostera marina", "Other_Red_Algae", "Other_Brown_Algae", "Green_Algae")

#Lumped macrophyte categories

other_red_algae <- c("Ceramium pacificum","Cladophora sericea", "Halosacccion glandiforme", "Microcladia borealis","Pyropia spp.","Neorhodomela larix","Mastocarpus spp.","Chondracanthus exasperatus","Mazzaella phyllocarpa","Palmaria palmata","Opuntiella californica","Ahnfeltia fastigata","Dumontia alaskana","Endocladia muricata","Gloiopeltis furcata","Neorhodomela oregona","Neorhodomela spp.","Ptilota serrata","Odonthalia floccosa","Osmundea spectabilis","Polysiphonia pacifica","Grateloupia californica")

other_brown_algae <- c("Pylaiella littoralis","Chordaria flagelliformis","Cymathaere triplicata","Saccharina latissima","Desmarestia aculeata","Leathesia marina","Nereocystis luetkeana")

green_algae <- c("Cladophora sericea","Ulva intestinalis","Chaetomorpha sp.","Ulva latuca","Ulva prolifera","Acrosiphonia coalita")

##############################################################
# PART X: Percent Cover vs Biomass Plot ######################
##############################################################

cover_biomass_plot <- left_join(wrack_cover, wrack_biomass, 
                                by = c("site","transect_number","species_id","species")) %>% 
  drop_na(biomass) %>%  #remove wood and fish 
  filter(species_id %in% c("FUDI", "ZOMA")) #filter for species with >5 observations

ggplot(cover_biomass_plot, aes(x=log10(percent_cover), y=log10(biomass), color = species))+
  geom_point()+
  theme_classic()+
  labs(x = "log(Percent Cover)", y = "log(Biomass (g))", color = "Species")


