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

wrack_predictors <- left_join(sites, wrack_biomass, by = join_by(site))


###########################################################
# PART 2: Examine Collinearity of Predictors ##############
###########################################################

ggpairs(wrack_predictors[,c(5:20)], #subset predictor columns at data for ggpairs function
        switch="both")+ #labels on left and bottom of plot
  theme_few()+ #theme
  theme(strip.background = element_rect(fill = "white"), #replace background
        strip.placement = "outside") #facet label on outside of tickmarks


#The only predictors with high collinearity (R>.7) are the different measures of donor habitat. 

############################################
# PART 3: Donor Habitat Modelling ##########
############################################

# Model F1: Intertidal Width ####

f1 <- glmmTMB(mean_wrack_biomass~beach_width, 
                     data = wrack_predictors, 
                     family=Gamma(link = "log"))
summary(f1)

# Check assumptions with DHARMa package
f1_res = simulateResiduals(f1)
plot(f1_res, rank = T)
testDispersion(f1_res)


# Model F2: Intertidal Area within 100m buffer ####
f2 <- glmmTMB(mean_wrack_biomass~buffer_100m, 
                       data = wrack_predictors, 
                       family=Gamma(link = "log"))
summary(f2)

# Check assumptions with DHARMa package
f2_res = simulateResiduals(f2)
plot(f2_res, rank = T)
testDispersion(f2_res)


# Model F3: Intertidal Area within 200m buffer ####
f3 <- glmmTMB(mean_wrack_biomass~buffer_200m, 
                       data = wrack_predictors, 
                       family=Gamma(link = "log"))
summary(f3)

# Check assumptions with DHARMa package
f3_res = simulateResiduals(f3)
plot(f3_res, rank = T)
testDispersion(f3_res)

# Model F4: Null Model ####

f4 <- glmmTMB(mean_wrack_biomass~1, 
              data = wrack_predictors, 
              family=Gamma(link = "log"))
summary(f4)



donor_habitat_models <- aictab(cand.set=list(f1, f2, f3, f4),
                               modnames=(c("Intertidal Width",
                                           "Intertidal Area Within 100m Buffer",
                                           "Intertidal Area Within 200m Buffer", 
                                           "null")),
                               second.ord=F) %>% 
  mutate(across(c('AIC', 'Delta_AIC', "ModelLik", "AICWt", "LL", "Cum.Wt"), round, digits = 3))



##############################################
# PART 4: All Predictors Modelling ###########
##############################################

# Model F5: Climatic Variables ####

f5 <- glmmTMB(mean_wrack_biomass~wind_direction+wind_speed+wave_height+wave_period+high_tide, 
               data = wrack_predictors, 
               family=Gamma(link = "log"))
summary(f5)

# Check assumptions with DHARMa package
f5_res = simulateResiduals(f5)
plot(f5_res, rank = T)
testDispersion(f5_res)


# Model F6: Biophysical Site Variables ####

f6 <- glmmTMB(mean_wrack_biomass~aspect+slope_mean+wave_exposure, 
            data = wrack_predictors, 
            family=Gamma(link = "log"))
summary(f6)

# Check assumptions with DHARMa package
f6_res = simulateResiduals(f6)
plot(f6_res, rank = T)
testDispersion(f6_res)

# Model F7: Intertidal Width + Climatic Variables ####

f7 <- glmmTMB(mean_wrack_biomass~wind_direction+wind_speed+wave_height+
                                        wave_period+high_tide +
                                        beach_width, 
                                      data = wrack_predictors, 
                                      family=Gamma(link = "log"))
summary(f7)

# Check assumptions with DHARMa package
f7_res = simulateResiduals(f7)
plot(f7_res, rank = T)
testDispersion(f7_res)

# Model F8: Intertidal Width + Biophysical Site Variables ####

f8 <- glmmTMB(mean_wrack_biomass~aspect+slope_mean+wave_exposure+
                                 beach_width, 
                               data = wrack_predictors, 
                               family=Gamma(link = "log"))
summary(f8)

# Check assumptions with DHARMa package
f8_res = simulateResiduals(f8)
plot(f8_res, rank = T)
testDispersion(f8_res)


# Model F9: Biophysical Site Variables + Climatic Variables ####

f9 <- glmmTMB(mean_wrack_biomass~
                           aspect+slope_mean+wave_exposure+ #Site variables
                           wind_direction+wind_speed+wave_height+ #Climate variables
                           wave_period+high_tide,
                         data = wrack_predictors, 
                         family=Gamma(link = "log"))
summary(f9)

# Check assumptions with DHARMa package
f9_res = simulateResiduals(f9)
plot(f9_res, rank = T)
testDispersion(f9_res)


# Model F10: Intertidal Width + Biophysical Site Variables + Climatic Variables ####

f10 <- glmmTMB(mean_wrack_biomass~ beach_width+ #Intertidal width
             aspect+slope_mean+wave_exposure+ #biophysical site variables
             wind_direction+wind_speed+wave_height+ #Climate variables
             wave_period+high_tide,
             data = wrack_predictors, 
             family=Gamma(link = "log"))
summary(f10)

# Check assumptions with DHARMa package
f10_res = simulateResiduals(f10)
plot(f10_res, rank = T)
testDispersion(f10_res)



# Compare Models ####

all_wrack_models <- aictab(cand.set=list(f1, f2, f3, f4, f5, f6, f7, f8, f9, f10),
                               modnames=(c("Intertidal Width",
                                           "Intertidal Area Within 100m Buffer",
                                           "Intertidal Area Within 200m Buffer",
                                           "Null", 
                                           "Climatic Variables", 
                                           "Biophysical Site Variables",
                                           "Intertidal Width + Climatic Variables", 
                                           "Intertidal Width + Biophysical Site Variables",
                                           "Biophysical Site Variables + Climatic Variables",
                                           "Intertidal Width + Biophysical Site Variables + Climatic Variables"
                                           )),
                               second.ord=F) %>% 
  mutate(across(c('AIC', 'Delta_AIC', "ModelLik", "AICWt", "LL", "Cum.Wt"), round, digits = 3))



#Table S7: Summary Table -------------------------------

wrack_models_gt <- gt(all_wrack_models)

wrack_models_summary <- 
  wrack_models_gt |>
  tab_header(
    title = "Environmental Predictors of Wrack Biomass",
    subtitle = "Generalized Linear Mixed-Effects Models with Gamma Distributions and Log Link Functions"
  ) |>
  cols_label(Modnames = md("**Model terms**"),
             K = md("**K**"),
             AIC = md("**AIC**"),
             Delta_AIC = md("**∆AIC**"),
             ModelLik = md("**Model Likelihood**"),
             AICWt = md("**AIC Weight**"),
             LL = md("**Log Likelihood**"),
             Cum.Wt = md("**Cumulative Weight**"))
wrack_models_summary


#Export high-quality table
gtsave(scav_prob_summary, "output/supp_figures/scavenging_probability_table.pdf")



