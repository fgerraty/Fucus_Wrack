# Data Dictionary

Gerraty, F.D. (2024) The *Fucus* flow: Broad beaches are hotspots of rockweed wrack subsidies to shoreline invertebrates. *In Review*

------------------------------------------------------------------------

## Sites Dataset

The "sites" dataset ([***data/processed/sites.csv***](https://github.com/fgerraty/Fucus_Wrack/blob/main/data/processed/sites.csv)) contains site metadata and site-level environmental and biophysical predictors of wrack biomass.

**Site and Survey Metadata** *(column name - description)*

-   **site -** unique site name

-   **latitude -** decimal degrees

-   **longitude -** decimal degrees

-   **sampling_date -** date of wrack and biomass survey

**Environmental Data**

In addition to site/survey metadata, I quantified 16 static and dynamic environmental variables for each of 15 study sites (Table 1) that were combined into candidate models for predicting wrack biomass at the site level.

| Parameter                        | Variable                               | Column Name     | Categories                | Source                    | Description                                                                                                                                                                        |
|------------|------------|------------|------------|------------|------------|
| Donor Habitat                    | Beach Width                            | beach_width     | NA                        | Planet Satellite Imagery  | Intertidal width (i.e. distance from high tide to low tide at approximately-.31m MLLW tide height) measured using Planet Imagery and QGIS (m)                                      |
| Donor Habitat                    | Intertidal Extent (100m radius buffer) | x100m_buffer    | NA                        | Planet Satellite Imagery  | Intertidal extent (i.e. cover of intertidal zone within a 100m radius buffer of survey site at approximately-.31m MLLW tide height) measured using Planet Imagery and QGIS (m\^2)  |
| Donor Habitat                    | Intertidal Extent (200m radius buffer) | x200m_buffer    | NA                        | Planet Satellite Imagery  | Intertidal extent (i.e. cover of intertidal zone within a 200m radius buffer of survey site at approximately -.31m MLLW tide height) measured using Planet Imagery and QGIS (m\^2) |
| Biophysical Site Characteristics | Wave Exposure                          | wave_exposure   | Protected, Semi-protected | Alaska Shorezone          | "Biological wave exposure" for alaska shorezone unit associated with survey site                                                                                                   |
| Biophysical Site Characteristics | Aspect                                 | aspect          | NA                        | Planet Satellite Imagery  | Beach aspect measured using Planet Imagery and QGIS (º)                                                                                                                            |
| Biophysical Site Characteristics | Slope                                  | slope_mean      | NA                        | Compass Commander         | Beach slope at 10 randomly placed points along the predominate wrack line measured using CommanderCompass IOS Application (º)                                                      |
| Biophysical Site Characteristics | Boulder Percent Cover                  | percent_boulder | NA                        | Field Survey              | Percent cover of "boulder" substrate (i.e., grain size \> 256 mm) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                            |
| Biophysical Site Characteristics | Cobble Percent Cover                   | percent_cobble  | NA                        | Field Survey              | Percent cover of "cobble" substrate (i.e., grain size 64-256 mm) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                             |
| Biophysical Site Characteristics | Pebble Percent Cover                   | percent_pebble  | NA                        | Field Survey              | Percent cover of "pebble" substrate (i.e., grain size 4 - 64 mm) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                             |
| Biophysical Site Characteristics | Granule Percent Cover                  | percent_granule | NA                        | Field Survey              | Percent cover of "granule" substrate (i.e., grain size 2 - 4 mm) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                             |
| Biophysical Site Characteristics | Sand Percent Cover                     | percent_sand    | NA                        | Field Survey              | Percent cover of "sand" substrate (i.e., grain size 0.625 - 2 mm) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                            |
| Climate                          | Wind Direction                         | wind_direction  | NA                        | NOAA                      | Direction from which the wind is blowing at Edgecumb Buoy (ºTrue)                                                                                                                  |
| Climate                          | Wind Speed                             | wind_speed      | NA                        | NOAA                      | Wind speed at Edgecumb Buoy (m/sec)                                                                                                                                                |
| Climate                          | Wave Height                            | wave_height     | NA                        | NOAA                      | Wave height at Edgecumb Buoy (m)                                                                                                                                                   |
| Climate                          | Wave Period                            | wave_period     | NA                        | NOAA                      | Wave period at Edgecumb Buoy (sec)                                                                                                                                                 |
| Climate                          | High Tide                              | high_tide       | NA                        | NOAA                      | Height of the most recent high tide prior to survey (m) at Sitka Harbor Tide Station                                                                                               |

Table 1. Environmental variables used to predict macrophyte wrack biomass.

## Wrack Biomass Dataset

The "wrack biomass" dataset ([***data/processed/wrack_biomass.csv***](https://github.com/fgerraty/Fucus_Wrack/blob/main/data/processed/wrack_biomass.csv)) contains wrack biomass data summarised by transect. We randomly placed three 20m transects extending from above the high tide line (the base of terrestrial vegetation or 1m above the highest wrack line, whichever was higher) toward the ocean at each site. Along each of these three transects, a 1m x 20m swath of macrophyte wrack was sorted to species and weighed using a spring scale.

The wrack biomass dataset contains the following columns

-   **site -** unique site name

-   **transect_number -** transect ID at site

-   **species_id -** 4-letter ID code for wrack species/type.

-   **species -** wrack species/genus/type.

-   **biomass -** biomass of wrack species along 20m transect (in grams).

## Wrack Zonation Dataset

The "wrack zonation" dataset ([***data/processed/wrack_zonation.csv***](https://github.com/fgerraty/Fucus_Wrack/blob/main/data/processed/wrack_zonation.csv)) contains wrack biomass data summarised by transect and "zone" of each transect. We split each biomasss survey into four zones along the 20m transect (0-5m, 5-10m, 10-15m, 15-20m) to quantify the distribution of wrack biomass across the intertidal at each site.

*Data Note: At two sites, "Sandy" and "Magic" we only split the biomass into two zones (0-10m, 10-20m) because we had not refined our methods. These inconsistencies are described in the manuscript and the two inconsistent sites are excluded from zonation analyses.*

The wrack zonation dataset contains the following columns:

-   **site -** unique site name

-   **transect_number -** transect ID at site

-   **zone_start -** start of zone (i.e. 0, 5, 10, or 15 meter mark)

-   **zone_end -** end of zone (i.e. 5, 10, 15, or 20 meter mark)

-   **species_id -** 4-letter ID code for wrack species/type.

-   **species -** wrack species/genus/type.

-   **biomass -** biomass of wrack species in transect zone (in grams).

## Invertebrates Dataset

The "invertebrates" dataset ([***data/processed/invertebrates.csv***](https://github.com/fgerraty/Fucus_Wrack/blob/main/data/processed/invertebrates.csv)) contains data for all invertebrates sampled in the study. The dataset contains the following columns:

-   **site -** unique site name

-   **site_number -** unique site number

-   **sampling_date -** date of field sampling

-   **transect_number -** transect ID at site

-   **distance_from_upper_transect -** distance (m) that sediment core was collected at from the upper transect (1-5)

-   **number_of_individuals_in_sample -** number of invertebrates collected within the same sediment core. Note that there are several rows with a value of 0, indicating that a core was collected but that no invertebrates were present.

-   **species_ID -** unique ID for each invertebrate species/order group. Values are either "TRTR" for *Traskorchestia traskiana*, "ISOPOD" for isopods, "OTHER" for other invertebrates not identified to species, and "NA" for cores in which no invertebrates were collected.

-   **species -** latin name for invertebrates identified to species (i.e. just *Traskorchestia traskiana)*

-   **length -** invertebrate length (mm)

-   **mass -** invertebrate mass (grams)

-   **notes -** miscellaneous notes about invertebrates and/or sediment cores.

## Invertebrate Summary Dataset

The "invertebrate summary" dataset ([***data/processed/invertebrate_summary.csv***](https://github.com/fgerraty/Fucus_Wrack/blob/main/data/processed/invertebrate_summary.csv)) contains transect-level summaries of invertebrates collected in the study. The dataset contains the following columns:

-   **site -** unique site name

-   **transect_number -** transect ID at site

-   **species_ID -** unique ID for each invertebrate species/order group. Values are either "TRTR" for *Traskorchestia traskiana*, "ISOPOD" for isopods, "OTHER" for other invertebrates not identified to species.

-   **species -** latin name for invertebrates identified to species (i.e. just *Traskorchestia traskiana)*

-   **number_invertebrates -** count of total number of invertebrates (grouped by site, transect, and species_ID)

-   **biomass -** measured and/or estimated biomass (see manuscript for details on biomass estimation) of invertebrates (grouped by site, transect, and species_ID).

------------------------------------------------------------------------

This repository also contains raw data files within the folder [***data/raw/***](https://github.com/fgerraty/Fucus_Wrack/tree/main/data/raw). The raw data files include some additional columns relevant to data collection and organization that are not relevant to downstream data processing and results. Please let me know if you are interested in using any of these data and I would be happy to work with you to make that happen!
