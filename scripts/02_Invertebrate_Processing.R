##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 02: Invertebrate Data Manipulation ##############################
#-------------------------------------------------------------------------

#Import data

invertebrates <- read_csv("data/processed/invertebrates.csv")


#Create TRTR Exponential growth curve model. 

TRTR <- invertebrates %>% 
  filter(species_id == "TRTR") %>% 
  drop_na(length, mass)

TRTR_model <- nls(mass ~ I(a + b * exp(c * length)), 
                  data = TRTR, 
                  start = list(a = 1, b = 1, c = 1), trace = T)

summary(TRTR_model)

#Create function that pulls coefficient estimate values from TRTR_model to predict the mass of TRTR amphipods.   
predict_TRTR_mass <- function(length)
{summary(TRTR_model)$coefficients[1,1] + #"a" estimate from model
    summary(TRTR_model)$coefficients[2,1] * #"b" estimate from model
    exp(summary(TRTR_model)$coefficients[3,1] * length )} #exp(c * length) 




#Select observations with isopods that were both measured (length) and massed (mass)
ISOPOD <- invertebrates %>% 
  filter(species_id == "ISOPOD") %>% 
  drop_na(length, mass)

#Create non-linear model 
ISOPOD_model <- nls(mass ~ I(a + b * exp(c * length)), 
                    data = ISOPOD, 
                    start = list(a = 1, b = 1, c = 1), trace = T)

#Create function that pulls coefficient estimate values from ISOPOD_model to predict the mass of isopods.  
predict_ISOPOD_mass <- function(length)
  {summary(ISOPOD_model)$coefficients[1,1] + #"a" estimate from model
    summary(ISOPOD_model)$coefficients[2,1] * #"b" estimate from model
    exp(summary(ISOPOD_model)$coefficients[3,1] * length )} #exp(c * length) 



invertebrates2 <- invertebrates %>% 
  mutate(project_mass = predict_ISOPOD_mass(length))
