# The *Fucus* flow: Wide intertidal zones amplify rockweed wrack subsidies to shoreline invertebrates

F.D. Gerraty (2024). The *Fucus* flow: Wide intertidal zones amplify rockweed wrack subsidies to shoreline invertebrates. *In Review*

I examined the role of rockweed (*Fucus distichus*) as a spatial subsidy to gravel beach food webs in Sitka Sound, Southeast Alaska. Here, I provide an outline of my analyses and provide a description of the scripts and datasets associated with this repository.

------------------------------------------------------------------------

There are six R scripts associated with this repository run all console and data preparation, data cleaning, analysis, and visualization steps:

-   **00_Packages.R** loads every package that is needed in following scripts. After running this script, all following scripts can be run independently.

-   **01_Data_Clean.R** cleans and summarizes raw data files. This script also generates equations for length-mass relationships of the two primary invertebrate groups (amphipods and isopods) and produces the plots that form Figure S2.

-   **02_Environment_Wrack_Analyses.R** conducts all analyses for investigating the best environmental predictors of wrack biomass. This script also generates Figure S2 and Tables S2-S3 in the manuscript.

-   **03_Wrack_Invert_Analyses.R** assesses the relationship between wrack and invertebrate biomass. This script also generates Figure 3 in the manuscript.

-   **04_Map.R** produces the map figure (Figure 1 in the manuscript). Note that this script depends on a shapefile of the Alaska Coastline that is too large to push to GitHub. For details on how to download and organize the shapefile in order to reproduce Figure 1, see the "[Alaska Shapefile](https://github.com/fgerraty/Fucus_Wrack/tree/main/data#alaska-shapefile)" section in the "[data dictionary](https://github.com/fgerraty/Fucus_Wrack/blob/main/data/README.md)".

-   **05_Plots.R** produces Figures 2A-D and Figure S1.

------------------------------------------------------------------------

### Directory Information

#### Folder "[data](https://github.com/fgerraty/Fucus_Wrack/tree/main/data)" houses raw and processed data files associated with this repository.

See "[data dictionary](https://github.com/fgerraty/Fucus_Wrack/blob/main/data/README.md)" for details on data files and associated metadata

#### Folder "[output](https://github.com/fgerraty/Fucus_Wrack/tree/main/output)" houses the following folders and files

-   Folder [**main_figures**](https://github.com/fgerraty/Fucus_Wrack/tree/main/output/main_figures) containing figures in manuscript main text:

    -   Figure_1.png
    -   Figure_2.png
    -   Figure_3.png

-   Folder [**supp_figures**](https://github.com/fgerraty/Fucus_Wrack/tree/main/output/supp_figures) containing figures in manuscript supplemental information:

    -   zonation_plot.png - Figure S1
    -   invert_length_mass.png - Figure S2
    -   beach_width_wrack_glm.png - Figure S3
    -   donor_habitat_models_table.png - Table S2
    -   environmental_predictors_table.png - Table S3

-   Folder [**extra_figures**](https://github.com/fgerraty/Fucus_Wrack/tree/main/output/extra_figures) containing supporting figures not included in manuscript main text or supplemental information

    -   Alaska.pdf, Sitka.pdf, Southeast.pdf - outputs from **04_Map.R** script, combined in Illustrator to make final map (Fig. 1) for publication.
    -   ISOPOD_length_mass.png, TRTR_length_mass.png - outputs from **01_Data_Clean.R** script, combined in Illustrator to make final Figure S2.
    -   wrack_biomass_panel.png, wrack_species_panel.png, invert_biomass_panel.png, invert_species_panel.png - outputs from **05_Plots.R** script, combined in Illustrator to make Figure 2.
    -   wrack_invert_biomass.png - output from **03_Wrack_Invert_Analyses.R** script, tweaked in Illustrator to make Figure 3.

#### Folder "[scripts](https://github.com/fgerraty/Fucus_Wrack/tree/main/scripts)" houses R scripts associated with this repository.

**Fucus_Wrack.Rproj** - R project for running scripts and directory in RStudio.
