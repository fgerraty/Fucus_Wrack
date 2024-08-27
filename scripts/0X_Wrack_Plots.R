##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 0X: Plots #######################################################
#-------------------------------------------------------------------------

####################################
# PART 1: Import Data ##############
####################################

#Import cleaned datasets from the "processed" data folder. 
wrack_biomass <- read_csv("data/processed/wrack_biomass.csv")
wrack_zonation <- read_csv("data/processed/wrack_zonation.csv")
invertebrates <- read_csv("data/processed/invertebrates.csv")
invertebrate_summary <- read_csv("data/processed/invertebrate_summary.csv")

######################################################################
# PART 2: Create guides for plotting aesthetics ######################
######################################################################

#Sites ordered from North to South for plots
site_order <- factor(c("Mosquito", "OldSitka", "Shotgun", "Cruise", "Halibut", "Magic", "NetIsland", "Harbor", "Sandy", "Totem", "Indian", "Eagle", "Private", "Ferry", "Jamestown"), ordered = TRUE)

site_labels <- c("Mosquito", "Old Sitka", "Shotgun", "Cruise", "Halibut", "Magic", "Net Island", "Harbor", "Sandy", "Totem", "Indian", "Eagle", "Private", "Ferry", "Jamestown")

#Wrack Species ordered from most to least total biomass
wrack_order <- factor(c("Green Algae", "Other Brown Algae", "Other Red Algae", "Zostera marina", "Macrocystis pyrifera", "Fucus distichus"), ordered = TRUE)

#Lumped macrophyte categories

other_red_algae <- c("Ceramium pacificum","Cladophora sericea", "Halosacccion glandiforme", "Microcladia borealis","Pyropia spp.","Neorhodomela larix","Mastocarpus spp.","Chondracanthus exasperatus","Mazzaella phyllocarpa","Palmaria palmata","Opuntiella californica","Ahnfeltia fastigiata","Dumontia alaskana","Endocladia muricata","Gloiopeltis furcata","Neorhodomela oregona","Neorhodomela spp.","Ptilota serrata","Odonthalia floccosa","Osmundea spectabilis","Polysiphonia pacifica","Grateloupia californica")

other_brown_algae <- c("Pylaiella littoralis","Chordaria flagelliformis","Cymathaere triplicata","Saccharina latissima","Desmarestia aculeata","Leathesia marina","Nereocystis luetkeana")

green_algae <- c("Cladophora sericea","Ulva intestinalis","Chaetomorpha sp.","Ulva latuca","Ulva prolifera","Acrosiphonia coalita")

#Wrack color palette
wrack_colors <- c("Fucus distichus" = "#E69F00", "Macrocystis pyrifera" = "#0072B2", "Green Algae" ="#009E73", "Other Red Algae" = "#D55E00", "Other Brown Algae" = "#56B4E9", "Zostera marina" = "#CC79A7")

#################################################################
# PART 3: Biomass and Species Composition Multi-Panel Plot ######
#################################################################

# Panel A: Wrack Abundance per Site Plot ####

wrack_biomass_summary <- read_csv("data/processed/wrack_biomass.csv") %>% 
  group_by(site, transect_number) %>% 
  summarise(wrack_biomass = sum(biomass)) %>% 
  ungroup(transect_number) %>% 
  summarise(mean_wrack_biomass = mean(wrack_biomass),
            SE = sd(wrack_biomass)/sqrt(3))

ggplot(wrack_biomass_summary, aes(x=factor(site, levels = site_order), 
                                  y=mean_wrack_biomass))+
  geom_bar(stat = "identity", fill = "grey65")+
  geom_errorbar(aes(ymin = mean_wrack_biomass-SE,
                    ymax= mean_wrack_biomass+SE,
                    width = .2))+
  labs(x="", y= "Wrack Biomass (kg per transect)\n(axis ticks on log scale)")+
  #Reorganize Y axis scale to place it on a log scale
  scale_y_log10(breaks = c(100, 1000, 10000, 100000), 
                labels = c(".1", "1", "10", "100"))+
  #Set themes and aesthetics
  theme_few()+
  theme(panel.border = element_rect(colour = "black", 
                                    fill=NA, 
                                    linewidth=1),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())+
  #Cut off lower section of plots to better show differences between sites
  coord_cartesian(ylim = c(30,130000))


ggsave("output/extra_figures/wrack_biomass_panel.png", 
       width = 8.5, height = 3.25, units = "in")


# Panel B: Wrack Proportions per Species Plot ####

wrack_species_breakdown <- wrack_biomass %>% 
  mutate(species_lumped = if_else(species %in% other_red_algae, 
                                  "Other Red Algae",
                          if_else(species %in% other_brown_algae,
                                  "Other Brown Algae",
                          if_else(species %in% green_algae,
                                  "Green Algae",
                                  species)))) %>% 
  group_by(site, species_lumped) %>% 
  summarise(sum_biomass = sum(biomass), .groups = "drop")


ggplot(wrack_species_breakdown, aes(x=factor(site, levels = site_order), 
                                    y=sum_biomass, 
                                    fill = factor(species_lumped, 
                                                  levels = wrack_order)))+
  geom_col(position = "fill")+
  scale_fill_manual(values = wrack_colors)+
  labs(x = "", y = "Proportion of wrack biomass", fill = "Species")+
  theme_few()+
  theme(panel.border = element_rect(colour = "black", 
                                    fill=NA, 
                                    linewidth=1),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())


ggsave("output/extra_figures/wrack_species_panel.png", 
       width = 9.5, height = 2.9, units = "in")


# Panel C: Invert Abundance per Site Plot #### 

invert_biomass_summary <- invertebrate_summary %>% 
  group_by(site_name, transect_number) %>% 
  summarise(invert_biomass = sum(biomass)*1000, .groups = "drop") %>% 
  add_row(site_name = "Sandy", transect_number = 2:3, invert_biomass = 0) %>% 
  add_row(site_name = "OldSitka", transect_number = 1:3, invert_biomass = 0) %>% 
  group_by(site_name) %>% 
  summarise(mean_invert_biomass = mean(invert_biomass),
            SE = sd(invert_biomass)/sqrt(3), .groups = "drop")


ggplot(invert_biomass_summary, aes(x=factor(site_name, levels = site_order), 
                                  y=mean_invert_biomass))+
  geom_bar(stat = "identity", fill = "grey65")+
  geom_errorbar(aes(ymin = if_else(site_name == "Sandy", mean_invert_biomass-SE+1,
  mean_invert_biomass-SE),
                    ymax= mean_invert_biomass+SE,
                    width = .2))+
  labs(x="", y= "Invertebrate Biomass (g per transect)\n(axis ticks on log scale)")+
  #Reorganize Y axis scale to place it on a log scale
  scale_y_continuous(transform = "log10", 
                     breaks = c(1,10,100,1000,10000), 
                     labels = c(".0001", ".001", ".01", "1", "10"))+
  #Set themes and aesthetics
  theme_few()+
  theme(panel.border = element_rect(colour = "black", 
                                    fill=NA, 
                                    linewidth=1),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

ggsave("output/extra_figures/invert_biomass_panel.png", 
       width = 8.9, height = 3.25, units = "in")

# Panel D: Invertebrate Biomass Species Proportions ####

invert_species_breakdown <- invertebrate_summary %>% 
  group_by(site_name, species_ID) %>% 
  summarise(sum_biomass = sum(biomass), .groups = "drop") %>% 
  add_row(site_name = "OldSitka", species_ID = "TRTR", sum_biomass = 0)


ggplot(invert_species_breakdown, aes(x=factor(site_name, levels = site_order), 
                                    y=sum_biomass, 
                                    fill = factor(species_ID, 
                                                  levels = c("OTHER", "ISOPOD", "TRTR"))))+
  geom_col(position = "fill")+
  scale_fill_manual(values = c("#9a031e",  "#e36414", "#0f4c5c"), labels = c("Other\nInvertebrates", "Isopods", "Traskorchestia\ntraskiana"))+
  labs(x = "Site", y = "Proportion of invertebrate biomass", fill = "Species")+
  scale_x_discrete(labels = site_labels)+
  theme_few()+
  theme(panel.border = element_rect(colour = "black", 
                                    fill=NA, 
                                    linewidth=1),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.key.size = unit(.75, "cm"))

ggsave("output/extra_figures/invert_species_panel.png", 
       width = 10.2, height = 3.85, units = "in")


####################################
# PART 4: Wrack Zonation Plot ######
####################################

zonation_plot_df <- wrack_zonation %>% 
  filter(!site %in% c("Sandy", "Magic")) %>% 
  mutate(species_lumped = case_when(species %in% other_red_algae   ~ "Other Red Algae",
                                    species %in% other_brown_algae ~ "Other Brown Algae",
                                    species %in% green_algae       ~ "Green Algae",
                                    TRUE                           ~ species),
         zone = case_when(zone_start == 0  ~ "0-5",
                          zone_start == 5  ~ "5-10",
                          zone_start == 10 ~ "10-15",
                          zone_start == 15 ~ "15-20",
                          TRUE ~ NA_character_)) %>% 
  group_by(zone, species_lumped) %>% 
  summarise(biomass = sum(biomass), .groups = "drop")

zonation_plot <- ggplot(zonation_plot_df, aes(x=zone, y=biomass, fill=factor(species_lumped, 
                                                             levels = wrack_order)))+
  geom_col()+
  scale_fill_manual(values = wrack_colors)+
  scale_y_continuous(labels = function(x) x / 1000) +
  labs(x = "Transect Zone (m)", y = "Wrack biomass (kg)", fill = "Species")+
  theme_few()+
  theme(panel.border = element_rect(colour = "black", 
                                    fill=NA, 
                                    linewidth=1))

#Save plot
ggsave("output/supp_figures/zonation_plot.png", 
       zonation_plot,
       width = 8, height = 5, units = "in")

  