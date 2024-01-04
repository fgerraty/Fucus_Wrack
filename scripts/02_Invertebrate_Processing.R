##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 02: Invertebrate Data Manipulation ##############################
#-------------------------------------------------------------------------

#Import data

invertebrates <- read_csv("data/processed/invertebrates.csv")


#Create model and function to predict the mass of TRTR amphipods based on their length ####

#Select all TRTR observations with both length and mass measured
TRTR <- invertebrates %>% 
  filter(species_id == "TRTR") %>% 
  drop_na(length, mass)

#Create non-linear model
TRTR_model <- nls(mass ~ I(a + b * exp(c * length)), 
                  data = TRTR, 
                  start = list(a = 1, b = 1, c = 1), trace = T)

#Take a look at the model (great fit)
summary(TRTR_model)

#Create function that pulls coefficient estimate values from TRTR_model to predict the mass of TRTR amphipods.   
predict_TRTR_mass <- function(length)
{summary(TRTR_model)$coefficients[1,1] + #"a" estimate from model
    summary(TRTR_model)$coefficients[2,1] * #"b" estimate from model
    exp(summary(TRTR_model)$coefficients[3,1] * length )} #exp(c * length) 

#Create model to predict the mass of ISOPODs based on their length ####

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


#Generate estimates of individual and transect-level invertebrate biomass using length-weight relationships #####

#Calculate mean TRTR and ISOPOD lengths for broken ones
mean_TRTR_length = mean((invertebrates %>% 
  filter(species_id == "TRTR") %>% 
  drop_na(length))$length)

mean_ISOPOD_length = mean((invertebrates %>% 
  filter(species_id == "ISOPOD") %>% 
  drop_na(length))$length)


invertebrates_predicted <- invertebrates %>% 
  
#For broken invertebrate individuals, we will take the mean length of each species and use that mean as the length value. We will project mass from that mean length for biomass calculations
  mutate(length = 
  #Replace missing TRTR lengths with mean_TRTR_length
   if_else(is.na(length) & species_id == "TRTR", 
           mean_TRTR_length, 
  #Replace missing ISOPOD lengths with mean_ISOPOD_length
   if_else(is.na(length) & species_id == "ISOPOD", 
           mean_ISOPOD_length, 
  #Keep length values for those that were measured
           length)),
    

#Predict the mass using the functions created above. 
    predicted_mass = 
    #First, predict the mass of TRTR amphipods based on their length. 
    if_else(species_id == "TRTR", 
            predict_TRTR_mass(length), 
    #Second, predict the mass of ISOPODs based on their length
    if_else(species_id == "ISOPOD", 
            predict_ISOPOD_mass(length), 
    #Keep mass values for those "OTHER" species that were measured
            mass)))
           
           
# Site-Level Invertebrate Summary
invertebrate_summary <- invertebrates_predicted %>% 
  drop_na(species_id) %>% 
  group_by(site_name, transect_number, species_id, species) %>% 
  summarise(number_invertebrates = n(),
         biomass = sum(predicted_mass, na.rm = TRUE),
         .groups = "drop")

write_csv(invertebrate_summary, "data/processed/invertebrate_summary.csv")
