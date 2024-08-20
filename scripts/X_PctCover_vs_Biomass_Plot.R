#Percent Cover vs Biomass

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
