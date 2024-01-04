##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 02: Invertebrate Data Manipulation ##############################
#-------------------------------------------------------------------------

####################################
# PART 1: Import Data ##############
####################################

invertebrates <- read_csv("data/processed/invertebrates.csv")


###########################################################
# PART 2: Generate Length-Mass Relationships ##############
###########################################################

#For two main taxonomic groups, Traskorchestia traskiana (TRTR) amphipods and isopods (ISOPOD), we measured and massed a subset of the individuals to generate length-mass relationships. Using these relationships, we will predict the mass of all of the individuals processed based on the measured lengths. 


# PART 2A: TRTR Amphipod length-mass relationship ------------------------------

#Select all TRTR observations with both length and mass measured
TRTR <- invertebrates %>% 
  filter(species_id == "TRTR") %>% 
  drop_na(length, mass)

#Create non-linear model
TRTR_model <- nls(mass ~ I(b * length^3), 
                  data = TRTR, 
                  start = list(b = 1), trace = T)

#Take a look at the model (great fit)
summary(TRTR_model)

#Create function that pulls coefficient estimate values from TRTR_model to predict the mass of TRTR amphipods based on their length.   
predict_TRTR_mass <- function(length)
{summary(TRTR_model)$coefficients[1,1] * #"b" estimate from model 
    length^3} # multoplied by length cubed

# PART 2B: ISOPOD length-mass relationship -------------------------------------

#Select observations with isopods that were both measured (length) and massed (mass)
ISOPOD <- invertebrates %>% 
  filter(species_id == "ISOPOD") %>% 
  drop_na(length, mass)

#Create non-linear model 
ISOPOD_model <- nls(mass ~ I(b * length^3), 
                    data = ISOPOD, 
                    start = list(b = 1), trace = T)

#Look at the model
summary(ISOPOD_model)

#Create function that pulls coefficient estimate values from ISOPOD_model to predict the mass of isopods.  
predict_ISOPOD_mass <- function(length)
  { summary(ISOPOD_model)$coefficients[1,1] *  #"b" estimate from model
    length^3 } #multiplied by length cubed


###############################################################################
# PART 3: Generate Transect-Level Invertebrate Biomass Estimates ##############
###############################################################################

# Many individual invertebrates were broken (and, consequently, the length could not be measured) due to field and lab collection methods. To include the mass of these broken individuals in our estimates of biomass, we will use the mean length of all measured individuals in that taxonomic group as a fill-in for the length and then use the length-mass relationships developed above to estimate biomass. 

#Calculate mean TRTR and ISOPOD lengths
mean_TRTR_length = mean((invertebrates %>% 
  filter(species_id == "TRTR") %>% 
  drop_na(length))$length)

mean_ISOPOD_length = mean((invertebrates %>% 
  filter(species_id == "ISOPOD") %>% 
  drop_na(length))$length)



#Create a dataframe called "invertebrate_summary" that calculates the number of individuals and the estimated biomass of each species along each transect. These values (# individuals, biomass) will be response variables for analyses looking at relationships between macroalgal wrack and invertebrate communities. 

invertebrate_summary <- invertebrates %>% 
  
# For broken invertebrate individuals, we will use the mean length of each taxonomic group as the length value. We will project mass from that mean length value for biomass calculations. 
  mutate(length = 
  #Replace missing TRTR lengths with mean_TRTR_length
   if_else(is.na(length) & species_id == "TRTR", 
           mean_TRTR_length, 
  #Replace missing ISOPOD lengths with mean_ISOPOD_length
   if_else(is.na(length) & species_id == "ISOPOD", 
           mean_ISOPOD_length, 
  #Keep length values for those that were measured
           length)),
    
#Predict the mass of each individual invertebrate using the functions created above. 
    predicted_mass = 
    #First, predict the mass of TRTR amphipods based on their length. 
    if_else(species_id == "TRTR", 
            predict_TRTR_mass(length), 
    #Second, predict the mass of ISOPODs based on their length
    if_else(species_id == "ISOPOD", 
            predict_ISOPOD_mass(length), 
    #Keep mass values for those "OTHER" species that were measured
            mass))) %>% 
           
# Summarize invertebrate metrics by transect
  drop_na(species_id) %>% # Removes samples with no invertebrates
  group_by(site_name, transect_number, species_id, species) %>% 
  summarise(number_invertebrates = n(), #count number of invertebrates in each grouping
         biomass = sum(predicted_mass, na.rm = TRUE), #sum the predicted mass of invertebrates in each grouping
         .groups = "drop") #drop groups

write_csv(invertebrate_summary, "data/processed/invertebrate_summary.csv")


#######################################################
# PART 3: Plot Length-Mass Relationships ##############
#######################################################


#Generate TRTR length-mass relationship curve 

TRTR_pred <- data.frame(length = seq(1, 20.4, 0.2)) #TRTR_pred = predicted values dataframe
prop <- predictNLS(TRTR_model, newdata = TRTR_pred) #Predict values 

TRTR_pred$mean <- prop$summary[,2] #Pull mean from model predictions
TRTR_pred$lcl <- prop$summary[,5] #Pull lower confidence level from model predictions
TRTR_pred$ucl <- prop$summary[,6] #Pull upper confidence level from model predictions


ggplot(TRTR, aes(x=length, y=mass))+
  geom_point(color = "grey70", alpha = .7, shape = 16)+
  geom_line(data = TRTR_pred, aes(x = length, y = mean), color= "black") +
  geom_ribbon(data = TRTR_pred, 
              aes(x = length, y = mean, ymin = lcl, ymax = ucl), 
              fill= "grey10", alpha = .5)+
  theme_classic()+
  labs(x="Length (mm)", y= "Mass (g)")



#Generate ISOPOD length-mass relationship curve 

ISOPOD_pred <- data.frame(length = seq(1, 7, 0.1)) #TRTR_pred = predicted values dataframe
prop <- predictNLS(ISOPOD_model, newdata = ISOPOD_pred) #Predict values 

ISOPOD_pred$mean <- prop$summary[,2] #Pull mean from model predictions
ISOPOD_pred$lcl <- prop$summary[,5] #Pull lower confidence level from model predictions
ISOPOD_pred$ucl <- prop$summary[,6] #Pull upper confidence level from model predictions



ggplot(ISOPOD, aes(x=length, y=mass))+
  geom_point(color = "grey70", alpha = .7)+
  geom_line(data = ISOPOD_pred, aes(x = length, y = mean), color= "black") +
  geom_ribbon(data = ISOPOD_pred, 
              aes(x = length, y = mean, ymin = lcl, ymax = ucl), 
              fill= "grey10", alpha = .5)+
  theme_classic()+
  labs(x="Length (mm)", y= "Mass (g)")
