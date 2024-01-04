##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 02: Invertebrate Data Manipulation ##############################
#-------------------------------------------------------------------------

#Import data

invertebrates <- read_csv("data/processed/invertebrates.csv")



#Create TRTR Model

TRTR <- invertebrates %>% 
  filter(species_id == "TRTR") %>% 
  drop_na(length, mass)

ggplot(TRTR, aes(x=length, y=mass))+
  geom_point()

ggplot(TRTR, aes(x=log(length), y=log(mass)))+
  geom_point()


#Fit an exponential curve model. 
#Exponential 3P provides best fitting model in JMP
#nlme package? 



#Create ISOPOD Model


ISOPOD <- invertebrates %>% 
  filter(species_id == "ISOPOD") %>% 
  drop_na(length, mass)

ggplot(ISOPOD, aes(x= length, y= mass)) +
  geom_point()

ggplot(ISOPOD, aes(x= log(length), y= log(mass))) +
  geom_point()


#Use projected mass for 
