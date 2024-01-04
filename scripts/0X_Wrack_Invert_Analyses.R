##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 0X: Wrack vs. Invertebrate Analyses #############################
#-------------------------------------------------------------------------

################################################
# PART 1: Import and Combine Data ##############
################################################

wrack_biomass <- read_csv("data/processed/wrack_biomass.csv") %>% 
  group_by(site, transect_number) %>% 
  summarise(wrack_biomass = sum(biomass))
  
invertebrate_summary <- read_csv("data/processed/invertebrate_summary.csv") %>%
  rename(site = site_name) %>% 
  group_by(site, transect_number) %>% 
  summarise(invert_biomass = sum(biomass),
            invert_count = sum(number_invertebrates),
            TRTR_biomass = sum(if_else(species_id == "TRTR", biomass, 0)),
            TRTR_count = sum(if_else(species_id == "TRTR", number_invertebrates, 0)),
            ISOPOD_biomass = sum(if_else(species_id == "ISOPOD", biomass, 0)),
            ISOPOD_count = sum(if_else(species_id == "ISOPOD", number_invertebrates, 0)))


wrack_inverts <- left_join(wrack_biomass, invertebrate_summary, by = c("site", "transect_number")) %>% 
  replace_na(list(invert_biomass = 0.0001)) %>% 
  mutate(log_wrack_biomass = log(wrack_biomass),
         log_invert_biomass = log(invert_biomass))


##############################################################################
# PART 2: Analyze Relationship Between Wrack and Invert Biomass ##############
##############################################################################

# PART 2A: Wrack Biomass (log) vs Invert Biomass (log) ------------------------

f1 <- lmer(log_invert_biomass ~ log_wrack_biomass +  (1|site),
            data = wrack_inverts)

#Take a look at the model
summary(f1)

#Check assumptions
plot(f1)
qqnorm(resid(f1))











fun <- function(x) -11.4441 + 1.2403 * x 





wrack_inverts_plot <- wrack_inverts %>% 
  group_by(site) %>% 
  mutate(mean_log_wrack = mean(log_wrack_biomass), 
         se_log_wrack = sd(log_wrack_biomass)/sqrt(3),
         mean_log_invert = mean(log_invert_biomass), 
         se_log_invert = sd(log_invert_biomass)/sqrt(3))




ggplot(wrack_inverts_summary, aes(x=mean_log_wrack, y=mean_log_invert))+
  geom_point()+
  geom_function(fun = fun)+
  geom_errorbar(aes(ymin = mean_log_invert-se_log_invert, ymax = mean_log_invert+se_log_invert))+
  geom_errorbar(aes(xmin = mean_log_wrack-se_log_wrack, xmax = mean_log_wrack+se_log_wrack))+
  lims(x = c(0,13))
  
  