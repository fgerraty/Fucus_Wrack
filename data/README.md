# Data Dictionary

*Rockweed Wrack Subsidies to Upper Intertidal Food Webs. FD Gerraty.*

------------------------------------------------------------------------

## Site Data

The "sites" dataset (***data/processed/sites.csv***) contains site metadata and site-level environmental and biophysical predictors of wrack biomass.

**Site and Survey Metadata** *(column name --- description)*

-   **site ---** unique site name

-   **latitude ---** decimal degrees

-   **longitude ---** decimal degrees

-   **sampling_date ---** date of wrack and biomass survey

**Environmental Data**

In addition to site/survey metadata, I quantified 16 static and dynamic environmental variables for each of 15 study sites (Table 1) that were combined into candidate models for predicting wrack biomass at the site level.

| Parameter                        | Variable                               | Column Name     | Categories                | Source                   | Description                                                                                                                                                                        |
|------------|------------|------------|------------|------------|------------|
| Donor Habitat                    | Beach Width                            | beach_width     | NA                        | Planet Satellite Imagery | Intertidal width (i.e. distance from high tide to low tide at approximately-.31m MLLW tide height) measured using Planet Imagery and QGIS (m)                                      |
| Donor Habitat                    | Intertidal Extent (100m radius buffer) | x100m_buffer    | NA                        | Planet Satellite Imagery | Intertidal extent (i.e. cover of intertidal zone within a 100m radius buffer of survey site at approximately-.31m MLLW tide height) measured using Planet Imagery and QGIS (m\^2)  |
| Donor Habitat                    | Intertidal Extent (200m radius buffer) | x200m_buffer    | NA                        | Planet Satellite Imagery | Intertidal extent (i.e. cover of intertidal zone within a 200m radius buffer of survey site at approximately -.31m MLLW tide height) measured using Planet Imagery and QGIS (m\^2) |
| Biophysical Site Characteristics | Wave Exposure                          | wave_exposure   | Protected, Semi-protected | Alaska Shorezone         | "Biological wave exposure" for alaska shorezone unit associated with survey site                                                                                                   |
| Biophysical Site Characteristics | Aspect                                 | aspect          | NA                        | Planet Satellite Imagery | Beach aspect measured using Planet Imagery and QGIS (º)                                                                                                                            |
| Biophysical Site Characteristics | Slope                                  | slope_mean      | NA                        | Compass Commander        | Beach slope at 10 randomly placed points along the predominate wrack line measured using Compass Commander Go! IOS Application (º)                                                 |
| Biophysical Site Characteristics | Boulder Percent Cover                  | percent_boulder | NA                        | Field Survey             | Percent cover of "boulder" substrate (i.e., grain size XX) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                                   |
| Biophysical Site Characteristics | Cobble Percent Cover                   | percent_cobble  | NA                        | Field Survey             | Percent cover of "cobble" substrate (i.e., grain size XX) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                                    |
| Biophysical Site Characteristics | Pebble Percent Cover                   | percent_pebble  | NA                        | Field Survey             | Percent cover of "pebble" substrate (i.e., grain size XX) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                                    |
| Biophysical Site Characteristics | Granule Percent Cover                  | percent_granule | NA                        | Field Survey             | Percent cover of "granule" substrate (i.e., grain size XX) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                                   |
| Biophysical Site Characteristics | Sand Percent Cover                     | percent_sand    | NA                        | Field Survey             | Percent cover of "sand" substrate (i.e., grain size XX) at 10 randomly placed 1m\^2 quadrats along the predominate wrack line                                                      |
| Climate                          | Wind Direction                         | wind_direction  | NA                        | NOAA                     | Direction from which the wind is blowing at Edgecumb Buoy (ºTrue)                                                                                                                  |
| Climate                          | Wind Speed                             | wind_speed      | NA                        | NOAA                     | Wind speed at Edgecumb Buoy (m/sec)                                                                                                                                                |
| Climate                          | Wave Height                            | wave_height     | NA                        | NOAA                     | Wave height at Edgecumb Buoy (m)                                                                                                                                                   |
| Climate                          | Wave Period                            | wave_period     | NA                        | NOAA                     | Wave period at Edgecumb Buoy (sec)                                                                                                                                                 |
| Climate                          | High Tide                              | high_tide       | NA                        | NOAA                     | Height of the most recent high tide prior to survey (m)                                                                                                                            |

Table 1. Biophysical and environmental predictors used in candidate models.

## Wrack Percent Cover Data

The "wrack cover" dataset (***data/processed/wrack_cover.csv***) contains wrack percent cover data. We randomly placed three 20m transects extending from above the high tide line (the base of terrestrial vegetation or 1m above the highest wrack line, whichever was higher) toward the ocean at each site. Along each of these three transects, the cover of wrack (macrophytes, carrion, driftwood, and debris) was quantified using a line intercept method.

The ***data/processed/wrack_cover.csv*** file contains the following columns

-   **site** --- unique site name

-   **transect_number** --- transect at site

-   **species_id** --- 4-letter ID code for wrack species/type.

-   **species ---** wrack species/genus/type.

-   **percent_cover ---** percent of 20m transect intercepting the wrack species.

## Wrack Biomass Dataset

The "wrack biomass" dataset (***data/processed/wrack_biomass.csv***) contains wrack biomass data summarised by transect. We randomly placed three 20m transects extending from above the high tide line (the base of terrestrial vegetation or 1m above the highest wrack line, whichever was higher) toward the ocean at each site. Along each of these three transects, a 1m x 20m swath of macrophyte wrack was sorted to species and weighed using a spring scale.

The ***data/processed/wrack_biomass.csv*** file contains the following columns

-   **site** --- unique site name

-   **transect_number** --- transect at site

-   **species_id** --- 4-letter ID code for wrack species/type.

-   **species ---** wrack species/genus/type.

-   biomass --- biomass of wrack species along 20m transect (in grams).

## Wrack Zonation Dataset

The "wrack zonation" dataset (***data/processed/wrack_zonation.csv***) contains wrack biomass data summarised by transect and "zone" of each transect. We split each biomasss survey into four zones along the 20m transect (0-5m, 5-10m, 10-15m, 15-20m) to quantify the distribution of wrack biomass across the intertidal at each site.

*Data Note: At two sites, "Sandy" and "Magic" we only split the biomass into two zones (0-10m, 10-20m) because we had not refined our methods. These inconsistencies are described in the manuscript and the two inconsistent sites are excluded from zonation analyses.*

The ***data/processed/wrack_zonation.csv*** file contains the following columns

-   **site** --- unique site name

-   **transect_number** --- transect at site

-   **zone_start** --- start of zone (i.e. 0, 5, 10, or 15 meter mark)

-   **zone_end** --- end of zone (i.e. 5, 10, 15, or 20 meter mark)

-   **species_id** --- 4-letter ID code for wrack species/type.

-   **species ---** wrack species/genus/type.

-   biomass --- biomass of wrack species in transect zone (in grams).
