##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 00: Load packages ###############################################
#-------------------------------------------------------------------------

# Part 1: Load Packages --------------------------------------------------

# Load packages
packages<- c("tidyverse", "janitor", "readxl", "sf", "rnaturalearth", "rnaturalearthdata", "ggspatial", "viridis", "glmmTMB")

pacman::p_load(packages, character.only = TRUE)

rm(packages)