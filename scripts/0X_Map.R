##########################################################################
# Sitka Sound Wrack Project ##############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 0X: Map for Rockweed Wrack Publication ##########################
#-------------------------------------------------------------------------

####################################
# PART 1: Import Data ##############
####################################

#Import cleaned datasets from the "processed" data folder. 
sites <- read_csv("data/processed/sites.csv")
wrack_biomass <- read_csv("data/processed/wrack_biomass.csv")

site_biomass <- wrack_biomass %>% 
  group_by(site, transect_number) %>% 
  summarise(mass_per_transect = sum(biomass), .groups = "drop_last") %>% 
  summarise(mean_biomass = mean(mass_per_transect), .groups = "drop") %>% 
  left_join(., sites[1:3], by = "site")
  

#Load high resolution shapefile of Alaska coastline 
# Shapefile is available online for download at the following link: 
# https://gis.data.alaska.gov/maps/24bb1a5332894893bf9a305d9f6c6696
alaska_coastline <- st_read("data/raw/alaska_shapefile/Alaska_Coastline.shp")

###############################################################
# PART 2: Make Locator Map using "rnaturalearth" ##############
###############################################################

#Subset USA and Canada shapes from rnaturalearth dataset
world <- ne_countries(scale='medium',returnclass = 'sf') #extract all countries
usa <- subset(world, admin == "United States of America") #subset USA
canada <- subset(world, admin == "Canada") #subset Canada

#Generate plot of locator map
alaska <- ggplot() +
  geom_sf(data = usa, fill = "grey85") + #plot USA
  geom_sf(data = canada, fill = "grey70")+ #plot Canada
  #inner bounding box: creates rectangular bounding box using a different projection from map projection
  geom_spatial_rect(    
    aes(xmin = -137.2, 
        xmax = -133.7, 
        ymin = 55.8,
        ymax = 58.5),
    crs = st_crs(4326), 
    fill = "blue", 
    alpha = .4,
    colour = "blue",
    linewidth = 1)+   
  #plot outer bounding box / plot border
  geom_rect(aes(  
    xmin = -1000000, 
    xmax = 1600000, 
    ymin = 200000,
    ymax = 2560000 ),
    fill = NA,
    color = "black",
    linewidth = 1.75) +
  #Add annotations for country labels 
  annotate(geom = "text", x = 100000, y = 1700000, label = "Alaska", 
           fontface = "italic", color = "black", size = 2.5)+
  annotate(geom = "text", x = 1100000, y = 1700000, label = "Canada", 
           fontface = "italic", color = "black", size = 2.5)+
  #Set coordinate reference system for plot
  coord_sf(crs = st_crs(3467), 
           xlim = c(-1000000, 1600000), 
           ylim = c(200000, 2560000), 
           expand = FALSE) +  
  theme_void()+
  theme(panel.background = element_rect(fill = "#BDE8FE")) #add blue color background


#############################################################################
# PART 3: Make second map level (Fig X, Panel B) of SE Alaska  ##############
#############################################################################

#Create southeast plot
southeast <- ggplot() +
  #Add southeast alaska shapefile
  geom_sf(data = alaska_coastline, fill = "antiquewhite", linewidth = .1) +
  #internal bounding box (i.e. sitka region)
  geom_rect(aes(      
    xmin = -135.42,
    xmax = -135.27,
    ymin = 57.03,
    ymax = 57.15),
    fill = "red",
    alpha = .4,
    colour = "red", 
    linewidth = 1) +
  #outer bounding box / plot border
  geom_rect(aes(  
    xmin = -137.2, 
    xmax = -133.7, 
    ymin = 55.8,
    ymax = 58.5),
    fill = NA, 
    colour = "blue",
    linewidth = 1.75)+   
  #set coordinate reference system of plot
  coord_sf(crs = st_crs(4326), 
           xlim = c(-137.2, -133.7), 
           ylim = c(55.8, 58.5),
           expand = FALSE
           ,label_axes = "-NE-" #sets which axes are labeled, top(blank), right, bottom, left (blank)
  ) +
  #Label countries - REMOVE ?????????
  annotate(geom = "text", x = -132.9, y = 58.6, label = "Canada", 
           fontface = "italic", color = "black", size = 3.5)+
  annotate(geom = "text", x = -134.3, y = 58.6, label = "Alaska", 
           fontface = "italic", color = "black", size = 3.5)+
  scale_y_continuous(position = "right", breaks = c(55,56,57,58,59)) + #sets y labels
  scale_x_continuous(breaks=c(-133, -134, -135, -136, -137))+ #sets x labels 
  #Add scale and north arrow
  annotation_scale (location = "tr", width_hint = 0.1)+
  annotation_north_arrow(
    location = "tr", which_north = "true",
    height = unit(1, "cm"), width = unit(1, "cm"),
    pad_y = unit(.75, "cm"),
    style = north_arrow_fancy_orienteering())+
  theme_bw()+
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.background = element_rect(fill = "#BDE8FE"))


#############################################################################
# PART 4: Make third map level (Fig X, Panel A) of Survey Sites  ############
#############################################################################

sitka <- ggplot(data=alaska_coastline)+
  geom_sf(fill = "antiquewhite") +
  geom_point(data = site_biomass, #places study sites on the map, colored by value "wrack_biomass"
             mapping = aes(longitude, latitude, 
                           fill = log(mean_biomass)), 
             size = 3,
             color= "black",
             pch=21)+
  scale_fill_viridis()+ 
  geom_rect(aes(  # outer bounding box / border
    xmin = -135.42, 
    xmax = -135.27, 
    ymin = 57.03,
    ymax = 57.15),
    fill = NA, 
    colour = "red",
    linewidth = 1.75)+   
  #set coordinate reference system of plot
  coord_sf(crs = st_crs(4326),
           xlim = c(-135.42, -135.27), 
           ylim = c(57.03, 57.15), 
           expand = FALSE)+
  scale_x_continuous(breaks=c(-135.3, -135.35, -135.4))+ # Sets the x (longitude) labels 
  theme_bw()+
  labs(fill= "Wrack\nBiomass\n ") +
  theme(legend.position = c(.95, .97),
        legend.justification = c("right", "top"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.background = element_rect(fill = "#BDE8FE"), ) +
  annotate(geom = "text", x = -135.335, y = 57.057, label = "Sitka", 
           fontface = "italic", color = "black", size = 3.5) +
  annotation_scale (location = "bl", width_hint = 0.3)+
  annotation_north_arrow(
    location = "bl", which_north = "true",
    height = unit(1, "cm"), width = unit(1, "cm"),
    pad_y = unit(.75, "cm"),
    style = north_arrow_fancy_orienteering())



#############################################################################
# PART 5: Export maps to be compiled in illustrator  ########################
#############################################################################

#Export maps to "output/extra_figures" to be compiled in illustrator

#Export alaska locator map as high-quality PDF
pdf("~/Desktop/Alaska.pdf", 
    width = 2, height = 2)
plot(alaska)
dev.off()

#Export Southeast Map 
pdf("~/Desktop/Southeast.pdf", 
    width = 4, height = 5)
plot(southeast)
dev.off()

#Export sitka map as high-quality PDF
pdf("~/Desktop/Sitka.pdf", 
    width = 4, height = 5)
plot(sitka)
dev.off()
