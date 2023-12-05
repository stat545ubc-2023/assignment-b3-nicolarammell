# Vancouver Street Tree Planting App

**Author**: Nicola Rammell\
**Contact**: rammell@student.ubc.ca

🌲🌳🌲🌳🌲

## ABOUT THE PROJECT

This is a repository that contains all files as required for UBC's STAT 545B Assignment B3 and Assignment B4. This is an individual assignment completed in Fall Term as part of STAT 545B: Exploratory Data Analysis II. In this project, I use the `shiny` R package to build and update a Shiny app!

## REPOSITORY FILE STRUCTURE

This repository includes two folders: `app_v1` and `app_v2`.

The `app_v1` folder contains the R code file used to create my Assignment 3 app. It also contains a subfolder with images used in the app. My Assignment 3 app is hosted on the shinyapps.io server, viewed [here](https://nicolarammell.shinyapps.io/app_v1/).

The `app_v2` folder contains the R code file used to create my Assignment 4 app. It also contains a subfolder with images used in the app. My Assignment 4 app is hosted on the shinyapps.io server, viewed [here](https://nicolarammell.shinyapps.io/app_v2/).

## ASSIGNMENT B3

For **Assignment B3**, I chose **Option B: Create your own Shiny app**. Specifically, I decided to make a **Vancouver Street Tree Planting** app using the `vancouver_trees` dataset from the `datateachr` package. Please note that as a starting point, I still referenced the BC Liquor app as an example. To start, I reviewed the BC Liquor app linked in the STAT545 [slide deck](https://docs.google.com/presentation/d/1dXhqqsD7dPOOdcC5Y7RW--dEU7UfU52qlb0YD3kKeLw/edit#slide=id.p). The BC Liquor app was built by [Dean Attali](https://github.com/daattali) and can be viewed [here](https://daattali.com/shiny/bcl/). Using the BC Liquor app [code](https://github.com/daattali/shiny-server/tree/master/bcl) as a jumping off point, I built my own **Vancouver Street Tree Planting** app with several new and unique features!

### Description of the Vancouver Street Tree Planting app

My **Vancouver Street Tree Planting** app allows users to interactively explore trees planted in the city of Vancouver from 1989 to 2019. Specifically, users can search for any number of tree genera to see how many trees were planted in Vancouver over time. Users can also filter by neighborhood and/or filter by latitude and longitude. I included a number of features in my app to meet the Assignment B3 requirements.

Three of these **unique features** *not* already present in the BC Liquor app example include:

-   **Add an image to the UI**. I added images to the UI as well as links to the photo sources. This is a useful feature because upon opening the app, the user can quickly visualize the kind of street trees this dataset includes! This improves the user experience.

-   **Add a widget to the UI**. I added *two* customized sliders to the UI, so that users can filter by any combination of latitude and longitude! These filters work in tandem with the optional neighborhood filter, so that users can optionally filter by neighbourhood and further refine their search using the sliders. This is a useful feature because it allows a high level of specificity in the user input.

-   **Add a download plot function**. I added the option to download the plot (as a .png file) that is generated based off the user preferences! This is a useful feature because it allows the user to create a custom plot with their data of interest and quickly download it, even without any knowledge of R/RStudio.

Additional features of interest include:

-   **Allow the user to search for multiple entries simultaneously**. In my app, the user can search for any number of tree genera at once. This is useful because it allows for a greater range of search criteria that is highly adaptable to the particular interest of the app user.

-   **Use the `DT package` to turn a static table into an interactive table**. This is useful because the user may wish to visualize a large subset of data in the plot, but filter to a smaller subset of data before downloading the data table. Furthermore, it nullifies the need for a function that shows the number of results found whenever the filters change, because the number of rows is displayed in the interactive table!

-   **Allow the user to download the table as a .csv file**. This is useful because the user may wish to obtain a copy of their table. This feature is especially useful for someone without any knowledge of R/RStudio who would like to obtain a pre-filtered version of the [City of Vancouver Open Data Portal](https://opendata.vancouver.ca/explore/dataset/street-trees/information/?disjunctive.species_name&disjunctive.common_name&disjunctive.on_street&disjunctive.neighbourhood_name) dataset!

## ASSIGNMENT B4

For Assignment B4, I chose **Option C: Update Your Shiny App**. Below is a description of the three features that I updated:

1.  Update

2.  Update

3.  Update

## LINKS TO THE APPS

My [Assignment 3](https://nicolarammell.shinyapps.io/app_v1/) and [Assignment 4](https://nicolarammell.shinyapps.io/app_v2/) Vancouver Street Tree Planing apps are hosted on the shinyapps.io server and can be viewed at the respective links.

🌲🌳🌲🌳🌲
