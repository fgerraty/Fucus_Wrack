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
  summarise(wrack_biomass = sum(biomass))

wrack_predictors_unscaled <- left_join(sites, wrack_biomass, by = join_by(site)) 

wrack_predictors <- wrack_predictors_unscaled %>% 
  dplyr::select(-percent_boulder, -percent_cobble, -percent_pebble, 
                -percent_granule, -percent_sand) %>% 
  relocate(wave_exposure, .after = last_col()) %>% 
  mutate(across(
    .cols = 5:14,          
    .fns  = ~ if(is.numeric(.x)) as.numeric(scale(.x)) else .x)) %>% 
  mutate(wave_exposure = factor(wave_exposure))


###########################################################
# PART 2: Examine Collinearity of Predictors ##############
###########################################################

ggpairs(wrack_predictors[,c(5:14)], #subset predictor columns at data for ggpairs function
        switch="both")+ #labels on left and bottom of plot
  theme_few()+ #theme
  theme(strip.background = element_rect(fill = "white"), #replace background
        strip.placement = "outside") #facet label on outside of tickmarks


#The only predictors with high collinearity (R>.7) are the different measures of donor habitat. 

######################################################
# PART 3: Fit All Non-collinear Models  ##############
######################################################

#Extract predictor names
predictors <- names(wrack_predictors)[c(5:14,17)]
predictors


#Generate all possible combinations of predictor variables
all_models <- map(1:length(predictors), 
                  ~ combn(predictors, ., simplify = FALSE)) %>% 
  unlist(recursive = FALSE)


#Create function to check collinearity among numeric predictors
is_collinear <- function(vars, df, threshold = 0.7) {
  
  numeric_vars <- vars[sapply(df[, vars, drop = FALSE], is.numeric)]
  
  if (length(numeric_vars) < 2) return(FALSE)
  
  cor_mat <- cor(df[, numeric_vars, drop = FALSE], use = "pairwise.complete.obs")
  any(abs(cor_mat[upper.tri(cor_mat)]) > threshold)
}

#Filter out models with collinear predictors
non_collinear_sets <- keep(all_models, ~ !is_collinear(.x, wrack_predictors))

# Define a model fitting function
fit_model <- function(vars) {
  # formula: additive predictors + random effect of site
  fmla <- as.formula(
    paste("wrack_biomass ~", paste(vars, collapse = " + "), "+ (1|site)")
  )
  # Gamma glm (log link) with glmmTMB
  possibly(glmmTMB, otherwise = NULL)(fmla, data = wrack_predictors, family = Gamma(link = "log"))
}

# Fit all non-collinear models
fitted_models <- map(non_collinear_sets, fit_model)

#Model selection using AICc
all_models_selection <- tibble(model.sel(fitted_models))

top_models <- all_models_selection %>% 
  filter(delta < 2)

#####################################################
# PART 4: Fitting and Assessing Top Models ##########
#####################################################

# Model F1: Intertidal Width ####

f1 <- glmmTMB(wrack_biomass~beach_width + (1|site), 
              data = wrack_predictors, 
              family=Gamma(link = "log"))
summary(f1)

# Check assumptions with DHARMa package
f1_res = simulateResiduals(f1)
plot(f1_res, rank = T)
testDispersion(f1_res)

performance::r2(f1) #R squared values


# Model F2: Intertidal Width + Wave Period ####

f2 <- glmmTMB(wrack_biomass~beach_width + wave_period + (1|site), 
              data = wrack_predictors, 
              family=Gamma(link = "log"))
summary(f2)

# Check assumptions with DHARMa package
f2_res = simulateResiduals(f2)
plot(f2_res, rank = T)
testDispersion(f2_res)

check_collinearity(f2)

# Model F3: Intertidal Width + Slope ####

f3 <- glmmTMB(wrack_biomass~beach_width + slope_mean + (1|site), 
              data = wrack_predictors, 
              family=Gamma(link = "log"))
summary(f3)

# Check assumptions with DHARMa package
f3_res = simulateResiduals(f3)
plot(f3_res, rank = T)
testDispersion(f3_res)

check_collinearity(f3)

# Model F4: Intertidal Width + Wave Exposure ####

f4 <- glmmTMB(wrack_biomass~beach_width + wave_exposure + (1|site), 
              data = wrack_predictors, 
              family=Gamma(link = "log"))
summary(f4)

# Check assumptions with DHARMa package
f4_res = simulateResiduals(f4)
plot(f4_res, rank = T)
testDispersion(f4_res)

check_collinearity(f4)

# Model F5: Intertidal Width + Wind Direction ####

f5 <- glmmTMB(wrack_biomass~beach_width + wind_direction + (1|site), 
              data = wrack_predictors, 
              family=Gamma(link = "log"))
summary(f5)

# Check assumptions with DHARMa package
f5_res = simulateResiduals(f5)
plot(f5_res, rank = T)
testDispersion(f5_res)

check_collinearity(f5)



#######################################################
# PART 5: Beach Width vs Wrack Biomass Plot ###########
#######################################################

# Model F1: Intertidal Width ####

f1 <- glmmTMB(wrack_biomass~beach_width + (1|site), 
              data = wrack_predictors_unscaled, 
              family=Gamma(link = "log"))

#Assess fit of best fitting model: f1
summary(f1)
performance::r2(f1)

# Create a new dataframe for predictions
fitted_glmm <- data.frame(beach_width = seq(0, 300, 1),
                          site = "Totem")

# Predict fitted values for glmm
fitted_glmm$wrack_biomass <- predict(f1, 
                                     newdata = fitted_glmm, 
                                     type = "response", 
                                     re.form=NA)

#Code for generating confidence intervals for glmmTMB model with a log link. 

#predict mean values on link/log scale
fitted_glmm$pred_wrack_biomass_link=predict(f1,newdata=fitted_glmm,re.form=NA,type="link")
#function for bootstrapping
pf1 = function(fit) {   predict(fit, fitted_glmm) } 
#bootstrap to estimate uncertainty in predictions
bb=bootMer(f1,nsim=1000,FUN=pf1,seed=999) 
#Calculate SEs from bootstrap samples on link scale
fitted_glmm$SE=apply(bb$t, 2, sd) 
#predicted mean + 1 SE on response scale
fitted_glmm$pSE=exp(fitted_glmm$pred_wrack_biomass_link+fitted_glmm$SE) 
# predicted mean - 1 SE on response scale
fitted_glmm$mSE=exp(fitted_glmm$pred_wrack_biomass_link-fitted_glmm$SE) 



f1_df <- wrack_predictors_unscaled %>% 
  group_by(site, beach_width) %>% 
  summarise(mean_wrack_biomass = mean(wrack_biomass), 
            se_wrack_biomass = sd(wrack_biomass)/sqrt(length(wrack_biomass)))



f1_glmm_plot <- ggplot(data = f1_df, aes(x=beach_width))+
  geom_errorbar(aes(ymin = mean_wrack_biomass-se_wrack_biomass, 
                    ymax = mean_wrack_biomass+se_wrack_biomass),
                width=0, color = "grey40")+
  geom_point(data = f1_df, aes(x=beach_width, y=mean_wrack_biomass))+
  geom_line(data = fitted_glmm, aes(x=beach_width, y=wrack_biomass))+
  geom_ribbon(data = fitted_glmm, aes(ymin = mSE, ymax = pSE),
              alpha=0.3,linetype=0)+
  theme_classic()+
  scale_y_continuous(labels = function(x) x / 1000) +
  labs(x = "Intertidal Width (m)", y="Wrack Biomass (kg / transect)")
f1_glmm_plot

#Save plot
ggsave("output/extra_figures/beach_width_wrack_glmm.png", 
       f1_glmm_plot,
       width = 8, height = 5, units = "in")
