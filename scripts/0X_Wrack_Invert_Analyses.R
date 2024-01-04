##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 0X: Wrack vs. Invertebrate Analyses #############################
#-------------------------------------------------------------------------

wrack_biomass <- read_csv("data/processed/wrack_biomass.csv") %>% 
  group_by(site, transect_number) %>% 
  summarise(wrack_biomass = sum(biomass))
  
invertebrate_summary <- read_csv("data/processed/invertebrate_summary.csv") %>%
  group_by(site_name, transect_number) %>% 
  summarise(invert_biomass = sum(biomass)) %>% 
  rename(site = site_name)

wrack_inverts <- left_join(wrack_biomass, invertebrate_summary, by = c("site", "transect_number")) %>% 
  replace_na(list(invert_biomass = 0.0001)) %>% 
  mutate(log_wrack_biomass = log(wrack_biomass),
         log_invert_biomass = log(invert_biomass))

ggplot(wrack_inverts, aes(x=log(wrack_biomass), y=log(invert_biomass), color = site))+
  geom_point()


#Generate model
mod <- glmer(invert_biomass ~ log_wrack_biomass +
        (1|site),
      data = wrack_inverts,
      family = Gamma(link=log))
#Throwing an errror
relgrad <- with(mod@optinfo$derivs,solve(Hessian,gradient))
max(abs(relgrad))
# 6.503403e-05




mod2 <- glmmTMB(invert_biomass ~ log_wrack_biomass +
  (1|site),
data = wrack_inverts,
family = Gamma(link=log))

summary(mod2)

