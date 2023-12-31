##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 0X: Wrack vs. Invertebrate Analyses #############################
#-------------------------------------------------------------------------

################################################
# PART 1: Import and Combine Data ##############
################################################

sites <- read_csv("data/processed/sites.csv")

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

#Need to check with Pete about this ################
library(ggpubr)
ggdensity(wrack_inverts$log_invert_biomass, 
          main = "Density plot of wrack mass",
          xlab = "Wrack mass")
shapiro.test(wrack_inverts$log_invert_biomass)
#####################################################


f1_plot_df1 <- wrack_inverts %>% 
  group_by(site) %>% 
  mutate(mean_log_wrack = mean(log_wrack_biomass), 
         se_log_wrack = sd(log_wrack_biomass)/sqrt(3),
         mean_log_invert = mean(log_invert_biomass), 
         se_log_invert = sd(log_invert_biomass)/sqrt(3)) %>% 
  left_join(., sites[,c("site", "beach_width")], by = "site")

#Create dataframe for generating a line and error bar representing model f1
f1_plot_df2=data.frame(log_wrack_biomass=seq(0,12,.1), site = "Totem")
#predict probability of scavenging using the model
f1_plot_df2$log_invert_biomass <- predict(f1,
                                          newdata=f1_plot_df2,
                                          type="response", 
                                          re.form=NA) #added extra step for mixed effects models

#Code for generating confidence intervals for lmer model. 

#function for bootstrapping
pf1 = function(fit) {predict(fit, f1_plot_df2)} 
#bootstrap to estimate uncertainty in predictions
bb=bootMer(f1,nsim=1000,FUN=pf1,seed=999) 
#Calculate SEs from bootstrap samples on link scale
f1_plot_df2$SE=apply(bb$t, 2, sd) 
#predicted mean + 1 SE on response scale
f1_plot_df2$pSE=f1_plot_df2$log_invert_biomass+f1_plot_df2$SE
# predicted mean - 1 SE on response scale
f1_plot_df2$mSE=f1_plot_df2$log_invert_biomass-f1_plot_df2$SE



f1_plot <- ggplot(f1_plot_df1, 
                  aes(x=mean_log_wrack, y=mean_log_invert))+
  #Errorbars depicting +/- SE of mass measurements
  geom_errorbar(aes(ymin = mean_log_invert-se_log_invert, 
                    ymax = mean_log_invert+se_log_invert),
                width=0, color = "grey40")+
  geom_errorbar(aes(xmin = mean_log_wrack-se_log_wrack, 
                    xmax = mean_log_wrack+se_log_wrack),
                color = "grey40")+
  #Points of mean values
  geom_point(size = 3, aes(color = beach_width))+
  #Fitted model and SE uncertainty
  geom_line(data = f1_plot_df2, 
            aes(x=log_wrack_biomass, y=log_invert_biomass))+
  geom_ribbon(data = f1_plot_df2, 
              mapping = aes(x=log_wrack_biomass, 
                            y = log_invert_biomass, 
                            ymin = mSE, ymax = pSE),
              alpha=0.3,linetype=0)+
  #Color and theme settings
  scale_color_viridis(trans = "log", 
                      breaks = c(25, 50, 100, 200))+
  scale_y_continuous(
    breaks = c(-6.50229, -4.199705, -1.89712, 0.4054651, 2.70805, 5.010635), 
    labels = c( .0015, .015, .15, 1.5,15,150))+
  scale_x_continuous(
    breaks = c(5.010635, 7.31322, 9.615805, 11.91839), 
    labels = c(.15, 1.5, 15, 150))+
  coord_cartesian(xlim = c(3, 12), ylim = c(-9, 6))+
  theme_classic()+
  labs(y = "Invertebrate Biomass (g)\n ", 
       x = "Wrack Biomass (kg)\n",
       color = "Beach\nWidth (m)\n")+
  theme(axis.title = element_text(size=12, face="bold", colour = "black"),
        legend.position = c(0.88,.29),
        legend.key.size = unit(.8, 'cm'),
        legend.box.background = element_rect(colour = "black", 
                                             linewidth=1))
  
f1_plot

#Save plot
ggsave("output/extra_figures/wrack_invert_biomass.png", 
       f1_plot,
       width = 8, height = 5, units = "in")




