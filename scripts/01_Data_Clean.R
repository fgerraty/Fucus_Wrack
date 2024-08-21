##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 01: Clean and Summarise Datasets ################################
#-------------------------------------------------------------------------

###################################################
# PART 1: Import and Clean Site and Wrack Data ####
###################################################

# PART 1A: "Sites" Dataset -----------------------------------------------------

#Import and clean "sites" dataset, which includes site/survey metadata as well as environmental variables associated with each survey
sites <- read_csv("data/raw/sites.csv") %>% 
  #Create new values including for the total percent cover of each substrate type across 10 randomly placed quadrats on each beach at the primary wrack line. 
  mutate(percent_boulder = rowSums(pick(boulder_1:boulder_10))/1000,
         percent_cobble = rowSums(pick(cobble_1:cobble_10))/1000,
         percent_pebble = rowSums(pick(pebble_1:pebble_10))/1000,
         percent_granule = rowSums(pick(granule_1:granule_10))/1000,
         percent_sand = rowSums(pick(sand_1:sand_10))/1000) %>% 
  #Keep relevant summarized columns and order variables by type (site/survey metadata, static environmental variables, dynamic environmental variables)
  dplyr::select(site:slope_mean, percent_boulder:percent_sand, wind_direction:high_tide) %>% 
  drop_na(site)


# PART 1B: "Wrack Cover" Dataset -----------------------------------------------

#Import and clean "wrack_cover" dataset, which includes all data from wrack percent cover surveys
wrack_cover <- read_csv("data/raw/Wrack_Percent_Cover_Raw_Data.csv") %>% 
  #Calculate the total distance along each transect covered by each macrophyte species, and then divide by 20 to get the percent cover of each transect. 
  group_by(site, transect_number, species_ID, species) %>% 
  summarise(percent_cover = sum(total_distance)/20, .groups = "drop")


# PART 1C: "Wrack Biomass" Dataset ---------------------------------------------

#Import and clean "wrack_biomass" dataset, which includes all data from wrack biomass surveys
wrack_biomass <- read_csv("data/raw/Wrack_Biomass_Raw_Data.csv") %>% 
  #Calculate the total biomass of wrack of each macrophyte species along each transect.
  group_by(site, transect_number, species_ID, species) %>% 
  summarise(biomass = sum(wrack_mass_per_transect), .groups = "drop")


#Create another wrack biomass dataset that also includes zonation
wrack_zonation <- read_csv("data/raw/Wrack_Biomass_Raw_Data.csv") %>% 
  group_by(site, transect_number, zone_start, zone_end, species_ID, species) %>% 
  summarise(biomass = sum(wrack_mass_per_transect), .groups = "drop")


# PART 1D: "Invertebrate" Dataset Import --------------------------------------

#Import and clean "invertebrate" dataset, which includes all invertebrate data
  
invertebrates <- read_csv("data/raw/Invertebrate_Raw_Data.csv") 


########################################################################
# PART 2: Generate Invertebrate Length-Mass Relationships ##############
########################################################################


#For two main taxonomic groups of invertebrates we sampled, Traskorchestia traskiana (TRTR) amphipods and isopods (ISOPOD), we measured and massed a subset of the individuals to generate length-mass relationships. Using these relationships, we fit a non-linear model to estimate the mass of all of the individuals processed based on the measured lengths. 


# PART 2A: TRTR Amphipod length-mass relationship ------------------------------

#Select all TRTR observations with both length and mass measured
TRTR <- invertebrates %>% 
  filter(species_ID == "TRTR") %>% 
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
    length^3} # multiplied by length cubed

# PART 2B: ISOPOD length-mass relationship -------------------------------------

#Select observations with isopods that were both measured (length) and massed (mass)
ISOPOD <- invertebrates %>% 
  filter(species_ID == "ISOPOD") %>% 
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
                           filter(species_ID == "TRTR") %>% 
                           drop_na(length))$length)

mean_ISOPOD_length = mean((invertebrates %>% 
                             filter(species_ID == "ISOPOD") %>% 
                             drop_na(length))$length)



#Create a dataframe called "invertebrate_summary" that calculates the number of individuals and the estimated biomass of each species along each transect. These values (# individuals, biomass) will be response variables for analyses looking at relationships between macroalgal wrack and invertebrate communities. 

invertebrate_summary <- invertebrates %>% 
  mutate(
    
#For broken invertebrate individuals, we will use the mean length of each taxonomic group as the length value. We will project mass from that mean length value for biomass calculations. 
    length = 
           #Replace missing TRTR lengths with mean_TRTR_length
           if_else(is.na(length) & species_ID == "TRTR", 
                   mean_TRTR_length, 
           #Replace missing ISOPOD lengths with mean_ISOPOD_length
           if_else(is.na(length) & species_ID == "ISOPOD", 
                   mean_ISOPOD_length, 
           #Keep length values for those that were measured
           length)),
    
#Predict the mass of each individual invertebrate using the functions created above. 
    predicted_mass = 
           #First, predict the mass of TRTR amphipods based on their length. 
           if_else(species_ID == "TRTR", 
                   predict_TRTR_mass(length), 
                   #Second, predict the mass of ISOPODs based on their length
                   if_else(species_ID == "ISOPOD", 
                           predict_ISOPOD_mass(length), 
                           #Keep mass values for those "OTHER" species that were measured
                           mass))) %>% 
  
  #Summarize invertebrate metrics by transect
  drop_na(species_ID) %>% # Removes samples with no invertebrates
  group_by(site_name, transect_number, species_ID, species) %>% 
  summarise(number_invertebrates = n(), #count number of invertebrates in each grouping
            biomass = sum(predicted_mass, na.rm = TRUE), #sum the predicted mass of invertebrates in each grouping
            .groups = "drop") #drop groups

####################################
# PART 4: Export Processed Data ####
####################################

write_csv(sites, "data/processed/sites.csv")
write_csv(wrack_cover, "data/processed/wrack_cover.csv")
write_csv(wrack_biomass, "data/processed/wrack_biomass.csv")
write_csv(wrack_zonation, "data/processed/wrack_zonation.csv")
write_csv(invertebrates, "data/processed/invertebrates.csv")
write_csv(invertebrate_summary, "data/processed/invertebrate_summary.csv")


#######################################################
# PART 5: Plot Length-Mass Relationships ##############
#######################################################


#Generate TRTR length-mass relationship curve 

TRTR_pred <- data.frame(length = seq(1, 20.4, 0.2)) #TRTR_pred = predicted values dataframe
prop <- predictNLS(TRTR_model, newdata = TRTR_pred) #Predict values 

TRTR_pred$mean <- prop$summary[,2] #Pull mean from model predictions
TRTR_pred$lcl <- prop$summary[,5] #Pull lower confidence level from model predictions
TRTR_pred$ucl <- prop$summary[,6] #Pull upper confidence level from model predictions

#Generate TRTR equation label

TRTR_label <- paste0("Mass = 0.0000274 * Length^{3}")



TRTR_plot <- ggplot(TRTR, aes(x=length, y=mass))+
  geom_point(color = "grey70", alpha = .7, shape = 16)+
  geom_line(data = TRTR_pred, aes(x = length, y = mean), color= "black") +
  geom_ribbon(data = TRTR_pred, 
              aes(x = length, y = mean, ymin = lcl, ymax = ucl), 
              fill= "grey10", alpha = .5)+
  theme_classic()+
  labs(x="Length (mm)", y= "Mass (g)")

TRTR_plot


#Generate ISOPOD length-mass relationship curve 

ISOPOD_pred <- data.frame(length = seq(1, 7, 0.1)) #TRTR_pred = predicted values dataframe
prop <- predictNLS(ISOPOD_model, newdata = ISOPOD_pred) #Predict values 

ISOPOD_pred$mean <- prop$summary[,2] #Pull mean from model predictions
ISOPOD_pred$lcl <- prop$summary[,5] #Pull lower confidence level from model predictions
ISOPOD_pred$ucl <- prop$summary[,6] #Pull upper confidence level from model predictions



ISOPOD_plot <- ggplot(ISOPOD, aes(x=length, y=mass))+
  geom_point(color = "grey70", alpha = .7)+
  geom_line(data = ISOPOD_pred, aes(x = length, y = mean), color= "black") +
  geom_ribbon(data = ISOPOD_pred, 
              aes(x = length, y = mean, ymin = lcl, ymax = ucl), 
              fill= "grey10", alpha = .5)+
  theme_classic()+
  labs(x="Length (mm)", y= "Mass (g)")
ISOPOD_plot



# Save plots
ggsave("output/extra_figures/TRTR_length_mass.png", 
       TRTR_plot,
       width = 8, height = 5, units = "in")

ggsave("output/extra_figures/ISOPOD_length_mass.png", 
       ISOPOD_plot,
       width = 8, height = 5, units = "in")

