##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 00: Load packages ###############################################
#-------------------------------------------------------------------------

# Part 1: Load Packages --------------------------------------------------

# Load packages
packages <- c("tidyverse", "lme4", "propagate","viridis", "sf", "rnaturalearth", "rnaturalearthdata", "ggspatial", "GGally", "ggthemes", "glmmTMB", "DHARMa", "gt", "AICcmodavg", "lmerTest")

pacman::p_load(packages, character.only = TRUE); rm(packages)