##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 03: Wrack vs. Invertebrate Analyses #############################
#-------------------------------------------------------------------------

################################################
# PART 1: Import and Combine Data ##############
################################################

sites <- read_csv("data/processed/sites.csv")

wrack_biomass <- read_csv("data/processed/wrack_biomass.csv") %>% 
  group_by(site, transect_number) %>% 
  summarise(
    wrack_biomass = sum(biomass, na.rm = TRUE),
    macrocystis_biomass = sum(biomass[species == "Macrocystis pyrifera"], na.rm = TRUE),
    zostera_biomass     = sum(biomass[species == "Zostera marina"], na.rm = TRUE),
    prop_macrocystis = macrocystis_biomass / wrack_biomass,
    prop_zostera = zostera_biomass / wrack_biomass,
    .groups = "drop") 
  
invertebrate_summary <- read_csv("data/processed/invertebrate_summary.csv") %>%
  rename(site = site_name) %>% 
  group_by(site, transect_number) %>% 
  summarise(invert_biomass = sum(biomass),
            invert_count = sum(number_invertebrates),
            TRTR_biomass = sum(if_else(species_ID == "TRTR", biomass, 0)),
            TRTR_count = sum(if_else(species_ID == "TRTR", number_invertebrates, 0)),
            ISOPOD_biomass = sum(if_else(species_ID == "ISOPOD", biomass, 0)),
            ISOPOD_count = sum(if_else(species_ID == "ISOPOD", number_invertebrates, 0)))


wrack_inverts <- left_join(wrack_biomass, invertebrate_summary, by = c("site", "transect_number")) %>%
  replace_na(list(invert_biomass = 0.0001)) %>% 
  mutate(log_wrack_biomass = log(wrack_biomass),
         log_invert_biomass = log(invert_biomass))
        


##############################################################################
# PART 2: Analyze Relationship Between Wrack and Invert Biomass ##############
##############################################################################

# PART 2A: Wrack Biomass (log) vs Invert Biomass (log) ------------------------

h1 <- lmer(log_invert_biomass ~ log_wrack_biomass +  (1|site),
            data = wrack_inverts)

#Take a look at the model
summary(h1)
#Calculate R2 values
MuMIn::r.squaredGLMM(h1)

# Check h1 assumptions with DHARMa package
h1_res = simulateResiduals(h1)
plot(h1_res, rank = T)
testDispersion(h1_res)
plotResiduals(h1_res, factor(wrack_inverts$site), xlab = "Site", main=NULL)


# PART 2B: Wrack Biomass (log) vs Invert Biomass (log) + Prop Macrocystis + Prop Zostera  -----

h2 <- lmer(log_invert_biomass ~ log_wrack_biomass + prop_macrocystis + prop_zostera + (1|site),
           data = wrack_inverts)

#Take a look at the model
summary(h2)
#Calculate R2 values
MuMIn::r.squaredGLMM(h2)

# Check h2 assumptions with DHARMa package
h2_res = simulateResiduals(h2)
plot(h2_res, rank = T)
testDispersion(h2_res)
plotResiduals(h2_res, factor(wrack_inverts$site), xlab = "Site", main=NULL)

#Check collinearity with performance package (calculate VIF)
check_collinearity(h2)


#Compare AIC values of h1 and h2 
AICc(h2)-AICc(h1)

aictab(c(h1, h2))
##############################################################################
# PLOT ##############
##############################################################################

h1_plot_df1 <- wrack_inverts %>% 
  group_by(site) %>% 
  mutate(mean_log_wrack = mean(log_wrack_biomass), 
         se_log_wrack = sd(log_wrack_biomass)/sqrt(3),
         mean_log_invert = mean(log_invert_biomass), 
         se_log_invert = sd(log_invert_biomass)/sqrt(3)) %>% 
  left_join(., sites[,c("site", "beach_width")], by = "site")

#Create dataframe for generating a line and error bar representing model h1
h1_plot_df2=data.frame(log_wrack_biomass=seq(0,12,.1), site = "Totem")
#predict probability of scavenging using the model
h1_plot_df2$log_invert_biomass <- predict(h1,
                                          newdata=h1_plot_df2,
                                          type="response", 
                                          re.form=NA) #added extra step for mixed effects models

#Code for generating confidence intervals for lmer model. 

#function for bootstrapping
ph1 = function(fit) {predict(fit, h1_plot_df2)} 
#bootstrap to estimate uncertainty in predictions
bb=bootMer(h1,nsim=1000,FUN=ph1,seed=999) 
#Calculate SEs from bootstrap samples on link scale
h1_plot_df2$SE=apply(bb$t, 2, sd) 
#predicted mean + 1 SE on response scale
h1_plot_df2$pSE=h1_plot_df2$log_invert_biomass+h1_plot_df2$SE
# predicted mean - 1 SE on response scale
h1_plot_df2$mSE=h1_plot_df2$log_invert_biomass-h1_plot_df2$SE



h1_plot <- ggplot(h1_plot_df1, 
                  aes(x=mean_log_wrack, y=mean_log_invert))+
  #Errorbars depicting +/- SE of mass measurements
  geom_errorbar(aes(ymin = mean_log_invert-se_log_invert, 
                    ymax = mean_log_invert+se_log_invert),
                width=0, color = "grey40")+
  geom_errorbar(aes(xmin = mean_log_wrack-se_log_wrack, 
                    xmax = mean_log_wrack+se_log_wrack),
                color = "grey40")+
  #Fitted model and SE uncertainty
  geom_line(data = h1_plot_df2, 
            aes(x=log_wrack_biomass, y=log_invert_biomass))+
  geom_ribbon(data = h1_plot_df2, 
              mapping = aes(x=log_wrack_biomass, 
                            y = log_invert_biomass, 
                            ymin = mSE, ymax = pSE),
              alpha=0.3,linetype=0)+
  #Points of mean values
  geom_point(size = 3, aes(color = beach_width))+
  #Color and theme settings
  scale_color_viridis(option = "C", trans = "log", 
                      breaks = c(25, 50, 100, 200))+
  scale_y_continuous(
    breaks = c(-6.50229, -4.199705, -1.89712, 0.4054651, 2.70805, 5.010635), 
    labels = c( .0015, .015, .15, 1.5,15,150))+
  scale_x_continuous(
    breaks = c(5.010635, 7.31322, 9.615805, 11.91839), 
    labels = c(.15, 1.5, 15, 150))+
  coord_cartesian(xlim = c(3, 12), ylim = c(-9, 6))+
  theme_classic()+
  labs(y = "Invertebrate Biomass (g / transect)\n ", 
       x = "Wrack Biomass (kg / transect)\n",
       color = "Intertidal\nWidth (m)\n")+
  theme(axis.title = element_text(size=12, face="bold", colour = "black"),
        legend.position = c(0.88,.29),
        legend.key.size = unit(.8, 'cm'),
        legend.box.background = element_rect(colour = "black", 
                                             linewidth=1))
  
h1_plot

#Save plot
ggsave("output/extra_figures/wrack_invert_biomass.png", 
       h1_plot,
       width = 8, height = 5, units = "in")




