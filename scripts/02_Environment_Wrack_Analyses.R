##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 02: Environmental Features vs. Wrack Analyses ###################
#-------------------------------------------------------------------------

################################################
# PART 1: Import and Combine Data ##############
################################################

sites <- read_csv("data/processed/sites.csv")

wrack_biomass <- read_csv("data/processed/wrack_biomass.csv") %>% 
  group_by(site, transect_number) %>% 
  summarise(wrack_biomass = sum(biomass)) %>% 
  ungroup(transect_number) %>% 
  summarise(mean_wrack_biomass = mean(wrack_biomass))

wrack_predictors <- left_join(sites, wrack_biomass)


###########################################################
# PART 2: Examine Collinearity of Predictors ##############
###########################################################

ggpairs(wrack_predictors[,c(5:20)], #subset predictor columns at data for ggpairs function
        switch="both")+ #labels on left and bottom of plot
  theme_few()+ #theme
  theme(strip.background = element_rect(fill = "white"), #replace background
        strip.placement = "outside") #facet label on outside of tickmarks


#The only predictors with high collinearity (R>.7) are the different measures of donor habitat. 

########################################
# PART 3: Fit Model Suite ##############
########################################

#Intertidal width
donor_habitat_1 <- glm(mean_wrack_biomass~beach_width, 
                     data = wrack_predictors, 
                     family=Gamma(link = "log"))
summary(donor_habitat_1)

#100m buffer
donor_habitat_2 <- glm(mean_wrack_biomass~x100m_buffer, 
                       data = wrack_predictors, 
                       family=Gamma(link = "log"))
summary(donor_habitat_2)

#200m buffer
donor_habitat_3 <- glm(mean_wrack_biomass~x200m_buffer, 
                       data = wrack_predictors, 
                       family=Gamma(link = "log"))
summary(donor_habitat_3)




#Fit other models

climate <- glm(mean_wrack_biomass~wind_direction+wind_speed+wave_height+wave_period+high_tide, 
               data = wrack_predictors, 
               family=Gamma(link = "log"))
summary(climate)

site <- glm(mean_wrack_biomass~Aspect+Slope+Wave_Exposure, 
            data = site_details, 
            family=Gamma(link = "log"))
summary(site)

site_plus_donor_habitat <- glm(mean_wrack_biomass~Aspect+Slope+Wave_Exposure+
                                 Intertidal_Width, 
                               data = site_details, 
                               family=Gamma(link = "log")); 
summary(site_plus_donor_habitat)

climate_plus_donor_habitat <- glm(mean_wrack_biomass~Wind_Direction+Wind_Speed+Wave_Height+Wave_Period+High_Tide+
                                  Intertidal_Width, 
                                  data = site_details, 
                                  family=Gamma(link = "log"))
summary(climate_plus_donor_habitat)

site_plus_climate <- glm(mean_wrack_biomass~Aspect+Slope+Wave_Exposure+
                         Wind_Direction+Wind_Speed+Wave_Height+Wave_Period+High_Tide,
                         data = site_details, 
                         family=Gamma(link = "log"))
summary(site_plus_climate)

site_plus_climate_plus_donor_habitat <- glm(mean_wrack_biomass~Aspect+Slope+Wave_Exposure+
                                            Wind_Direction+Wind_Speed+Wave_Height+
                                            Wave_Period+High_Tide+Intertidal_Width, 
                                            data = site_details, 
                                            family=Gamma(link = "log"))
summary(site_plus_climate_plus_donor_habitat)

null <- glm(mean_wrack_biomass~1, 
            data = site_details, 
            family=Gamma(link = "log"))
summary(null) 


#Plot Models ########

#Intertidal width
donor_habitat_1 <- glm(mean_wrack_biomass~beach_width, 
                       data = wrack_predictors, 
                       family=Gamma(link = "log"))
summary(donor_habitat_1)


#Check assumptions
plot(donor_habitat_1)


ggplot(wrack_predictors, aes(x=beach_width, y=log(mean_wrack_biomass)))+
  geom_point()


