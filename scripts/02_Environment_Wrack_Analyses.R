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

f1 <- glm(mean_wrack_biomass~beach_width, 
                     data = wrack_predictors, 
                     family=Gamma(link = "log"))
summary(f1)

# Check assumptions with DHARMa package
f1_res = simulateResiduals(f1)
plot(f1_res, rank = T)
testDispersion(f1_res)


# Model F2: Intertidal Area within 100m buffer ####
f2 <- glm(mean_wrack_biomass~buffer_100m, 
                       data = wrack_predictors, 
                       family=Gamma(link = "log"))
summary(f2)

# Check assumptions with DHARMa package
f2_res = simulateResiduals(f2)
plot(f2_res, rank = T)
testDispersion(f2_res)


# Model F3: Intertidal Area within 200m buffer ####
f3 <- glm(mean_wrack_biomass~buffer_200m, 
                       data = wrack_predictors, 
                       family=Gamma(link = "log"))
summary(f3)

# Check assumptions with DHARMa package
f3_res = simulateResiduals(f3)
plot(f3_res, rank = T)
testDispersion(f3_res)

# Model F4: Null Model ####

f4 <- glm(mean_wrack_biomass~1, 
              data = wrack_predictors, 
              family=Gamma(link = "log"))
summary(f4)



donor_habitat_models <- aictab(cand.set=list(f1, f2, f3, f4),
                               modnames=(c("Intertidal Width***",
                                           "Intertidal Area Within 100m Buffer*",
                                           "Intertidal Area Within 200m Buffer***", 
                                           "null")),
                               second.ord=F) %>% 
  mutate(across(c('AIC', 'Delta_AIC', "ModelLik", "AICWt", "LL", "Cum.Wt"), 
                \(x) round(x, digits = 3)))


donor_habitat_models

#Summary Table

donor_models_gt <- gt(donor_habitat_models)

donor_models_summary <- 
  donor_models_gt |>
  tab_header(
    title = "Donor Habitat Predictors of Wrack Biomass",
    subtitle = "Generalized Linear Models with Gamma Distributions and Log Link Functions (***p<.005, *p<.05)"
  ) |>
  cols_label(Modnames = md("**Model Name**"),
             K = md("**K**"),
             AIC = md("**AIC**"),
             Delta_AIC = md("**∆AIC**"),
             ModelLik = md("**Model Likelihood**"),
             AICWt = md("**AIC Weight**"),
             LL = md("**Log Likelihood**"),
             Cum.Wt = md("**Cumulative Weight**")) 
donor_models_summary


#Export high-quality table
gtsave(donor_models_summary, "output/supp_figures/donor_habitat_models_table.pdf")


##############################################
# PART 4: All Predictors Modelling ###########
##############################################


# Model G1: Intertidal Width ####

g1 <- glm(mean_wrack_biomass~beach_width, 
              data = wrack_predictors, 
              family=Gamma(link = "log"))
summary(g1)

# Check assumptions with DHARMa package
g1_res = simulateResiduals(g1)
plot(g1_res, rank = T)
testDispersion(g1_res)



# Model G2: Climatic Variables ####

g2 <- glm(mean_wrack_biomass~wind_direction+wind_speed+wave_height+wave_period+high_tide, 
               data = wrack_predictors, 
               family=Gamma(link = "log"))
summary(g2)

# Check assumptions with DHARMa package
g2_res = simulateResiduals(g2)
plot(g2_res, rank = T)
testDispersion(g2_res)


# Model G3: Biophysical Site Variables ####

g3 <- glm(mean_wrack_biomass~aspect+slope_mean+wave_exposure, 
            data = wrack_predictors, 
            family=Gamma(link = "log"))
summary(g3)

# Check assumptions with DHARMa package
g3_res = simulateResiduals(g3)
plot(g3_res, rank = T)
testDispersion(g3_res)

# Model G4: Intertidal Width + Climatic Variables ####

g4 <- glm(mean_wrack_biomass~wind_direction+wind_speed+wave_height+
                                        wave_period+high_tide +
                                        beach_width, 
                                      data = wrack_predictors, 
                                      family=Gamma(link = "log"))
summary(g4)

# Check assumptions with DHARMa package
g4_res = simulateResiduals(g4)
plot(g4_res, rank = T)
testDispersion(g4_res)

# Model G5: Intertidal Width + Biophysical Site Variables ####

g5 <- glm(mean_wrack_biomass~aspect+slope_mean+wave_exposure+
                                 beach_width, 
                               data = wrack_predictors, 
                               family=Gamma(link = "log"))
summary(g5)

# Check assumptions with DHARMa package
g5_res = simulateResiduals(g5)
plot(g5_res, rank = T)
testDispersion(g5_res)


# Model G6: Biophysical Site Variables + Climatic Variables ####

g6 <- glm(mean_wrack_biomass~
                           aspect+slope_mean+wave_exposure+ #Site variables
                           wind_direction+wind_speed+wave_height+ #Climate variables
                           wave_period+high_tide,
                         data = wrack_predictors, 
                         family=Gamma(link = "log"))
summary(g6)

# Check assumptions with DHARMa package
g6_res = simulateResiduals(g6)
plot(g6_res, rank = T)
testDispersion(g6_res)


# Model G7: Intertidal Width + Biophysical Site Variables + Climatic Variables ####

g7 <- glm(mean_wrack_biomass~ beach_width+ #Intertidal width
             aspect+slope_mean+wave_exposure+ #biophysical site variables
             wind_direction+wind_speed+wave_height+ #Climate variables
             wave_period+high_tide,
             data = wrack_predictors, 
             family=Gamma(link = "log"))
summary(g7)

# Check assumptions with DHARMa package
g7_res = simulateResiduals(g7)
plot(g7_res, rank = T)
testDispersion(g7_res)




# Compare Models ####

all_wrack_models <- aictab(cand.set=list(g1, g2, g3, g4, g5, g6, g7, f4),
                               modnames=(c("Intertidal Width",
                                           "Climatic Variables", 
                                           "Biophysical Site Variables",
                                           "Intertidal Width + Climatic Variables", 
                                           "Intertidal Width + Biophysical Site Variables",
                                           "Biophysical Site Variables + Climatic Variables",
                                           "Intertidal Width + Biophysical Site Variables + Climatic Variables",
                                           "Null" 
                                           )),
                               second.ord=F) %>% 
  mutate(across(c('AIC', 'Delta_AIC', "ModelLik", "AICWt", "LL", "Cum.Wt"), round, digits = 3),
         model_terms = c("Intertidal Width***",
                         "Intertidal Width*** + Aspect + Slope + Wave Exposure",
                         "Intertidal Width* + Wind Direction + Wind Speed + Wave Height + Wave Period + High Tide", 
                         "Wind Direction + Wind Speed + Wave Height + Wave Period + High Tide*", 
                         "Intertidal Width + Aspect + Slope + Wave Exposure + Wind Direction + Wind Speed + Wave Height + Wave Period + High Tide",
                         "Aspect* + Slope* + Wave Exposure*",
                         "Null",
                        
                         "Aspect + Slope + Wave Exposure + Wind Direction + Wind Speed + Wave Height + Wave Period + High Tide*")) %>% 
  relocate(model_terms, .after=Modnames)



#Table S7: Summary Table -------------------------------

wrack_models_gt <- gt(all_wrack_models)

wrack_models_summary <- 
  wrack_models_gt |>
  tab_header(
    title = "Environmental Predictors of Wrack Biomass",
    subtitle = "Generalized Linear Models with Gamma Distributions and Log Link Functions (***p<.005, *p<.05)"
  ) |>
  cols_label(Modnames = md("**Model Name**"),
             model_terms = md("**Model Terms**"),
             K = md("**K**"),
             AIC = md("**AIC**"),
             Delta_AIC = md("**∆AIC**"),
             ModelLik = md("**Model Likelihood**"),
             AICWt = md("**AIC Weight**"),
             LL = md("**Log Likelihood**"),
             Cum.Wt = md("**Cumulative Weight**"))
wrack_models_summary


#Export high-quality table
gtsave(wrack_models_summary, "output/supp_figures/environmental_predictors_table.pdf")





#######################################################
# PART 5: Beach Width vs Wrack Biomass Plot ###########
#######################################################

# Create a new dataframe for predictions
fitted_glm <- data.frame(beach_width = seq(0, 300, 1))

# Predict fitted values and standard errors
predictions <- predict(f1, 
                       newdata = fitted_glm, 
                       type = "response", 
                       se.fit = TRUE)

# Add fitted values and confidence intervals to the dataframe
fitted_glm$mean_wrack_biomass <- predictions$fit
fitted_glm$lower_se <- predictions$fit - predictions$se.fit
fitted_glm$upper_se <- predictions$fit + predictions$se.fit



f1_glm_plot <- ggplot(data = wrack_predictors, aes(x=beach_width, y=mean_wrack_biomass))+
  geom_point()+
  geom_line(data = fitted_glm)+
  geom_ribbon(data = fitted_glm, aes(ymin = lower_se, ymax = upper_se),
              alpha=0.3,linetype=0)+
  theme_classic()+
  scale_y_continuous(labels = function(x) x / 1000) +
  labs(x = "Intertidal Width (m)", y="Mean Wrack Biomass (kg / transect)")

#Save plot
ggsave("output/extra_figures/beach_width_wrack_glm.png", 
       f1_glm_plot,
       width = 8, height = 5, units = "in")
