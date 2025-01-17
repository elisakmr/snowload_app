
### Server on degree ###

#======================================

library(shiny)
library(tidyverse)
library(sf)
library(leaflet)
library(ggplot2)
library(ggpubr)
library(ggiraph)
library(leaflet)
library(RColorBrewer)
library(shinydashboard)
library("rnaturalearth")
library("rnaturalearthdata")
library(gtools)

load("RLSWE_17.09_rcp85.RData")
load("INC_17.09_rcp85.RData")

#----------------------------------------------------------------------------
# function enabling download user guide button to be outside parameter panel
sidebarPanel2 <- function (..., out = NULL, width = 3)
{
  div(class = paste0("col-sm-", width),
      tags$form(class = "well", ...),
      out
  )
}
#----------------------------------------------------------------------------

rl_list=list()
rl_list[[1]] <- RL1.1517
rl_list[[2]] <- RL1.6584
rl_list[[3]] <- RL3vs1.1517*100
rl_list[[4]] <- RL3vs1.6584*100

inc_list=list()
inc_list[[1]] <- INC1.1517
inc_list[[2]] <- INC1.6584
inc_list[[3]] <- INC3vs1.1517
inc_list[[4]] <- INC3vs1.6584

indic <- "max-sd-NS-year"
shp_1517 <- st_read("shp_altMean4326.shp") # shapefile of ajusted elevation per nuts
shp_6584 <- st_read("max-sd-NS-year_sf_nut.shp") # shapefile of ajusted elevation per nuts

# #############
# shp_1517 <- st_transform(shp_1517, CRS("+init=epsg:3857"))
# shp_6584 <- st_transform(shp_6584, CRS("+init=epsg:3857"))
# ##############

shp_list=list()
shp_list[[1]] <- shp_1517 %>% mutate(alt='mean')
shp_list[[2]] <- shp_6584

world <- ne_countries(scale = "medium", returnclass = "sf")
vecDegre = c("RL1degre","RL3vs1degre","RL3vs1degre")
rl_chgcol <- c('Value (mm)' = "rl", 'Value (mm)' = "rl", 'Value (%)' = "rl")
rl_col <- c('Value (mm)', 'Value (mm)' , 'Value (%)')
inc_chgcol <- c('Confidence interval (mm)' = "inc", 'Confidence interval (mm)' = "inc", 'Confidence interval (%)' = "inc")
inc_col <- c('Confidence interval (mm)', 'Confidence interval (mm)', 'Confidence interval (%)')

unite_nom <- c('Value (mm)','Value (mm)','Value (%)')
altitudes <- list("mean",list("0"= 0,"100"=100, "200"=200, "300"=300,
                  "400"=400, "500"=500, "600"=600, "700"=700,
                  "800"=800, "900"=900, "1000"=1000, "1100"=1100,
                  "1200"=1200, "1300"=1300, "1400"=1400, "1500"=1500,
                  "1600"=1600, "1700"=1700, "1800"=1800, "1900"=1900,
                  "2000"=2000, "2100"=2100, "2200"=2200, "2300"=2300,
                  "2400"=2400, "2500"=2500, "2600"=2600, "2700"=2700,
                  "2800"=2800, "2900"=2900, "3000"=3000, "3100"=3100,
                  "3200"=3200, "3300"=3300))

palette_bordure=colorNumeric(palette="black", domain =c(-10000:10000) ,na.color = NA)

#================================================

server = function(input, output, session) {

  ######### SWITCHING TAB when click on "Method" ##########

  observeEvent(input$inTabset, {
    updateTabsetPanel(session, inputId = "fenetre", selected="panel2")
  })

  ######### REACTIVE elevation menu ##########

  outVar=reactive({
    outVar=altitudes[[as.numeric(input$filtre_alt)]]
    return(outVar)
  })

  output$menu <- renderUI({
    selectInput(inputId = "elev",
                label = "Pick elevation",
                choices = outVar())
  })

  ######## Reactive SHAPEFILES ###########

  shp_rl <- reactive({
    altitude_type=as.numeric(input$filtre_alt)
    shp_filt <- shp_list[[altitude_type]]
    index.alt <- which(shp_filt$alt==input$elev)
    nuts_filt <- shp_filt$nuts_id[index.alt]
    index.nuts <- match(nuts_filt,shp_1517$nuts_id)

    shp_rl <- shp_1517
    n.nuts <- length(shp_rl$nuts_id)
    shp_rl$rl <- rep(NA,n.nuts)
    shp_rl$rl[index.nuts] <- as.numeric(round(rl_list[[altitude_type+as.numeric(input$periode)-1]][index.alt],2))
    shp_rl$inc <- rep(NA,n.nuts)
    shp_rl$inc[index.nuts] <- inc_list[[altitude_type+as.numeric(input$periode)-1]][index.alt]

    if(dim(shp_filt)[1]==6584){
      shp_rl$alt_mtmsi[index.nuts] <- input$elev
    }

    return(shp_rl)

  })

  ############## Reactive DOWNLOADS of csv ###############

  output$savedf_rl <- downloadHandler(
    filename = function(){
      indexi = as.numeric(input$periode)
      paste0(vecDegre[indexi], "_", input$elev,".csv") #
    },
    content = function(file){
      indexi = as.numeric(input$periode)
      data=shp_rl() %>% select(nuts_id,nuts_name,rl) %>% na.omit() %>%
        dplyr::rename(all_of(c("Region"="nuts_name",rl_chgcol[indexi])))
      st_write(data,file)
    }
  )

  ############# Reactive DOWNLOADS of shp as ZIP file ############

  layer_name=c("RL_1d","RL_3vs1","RL_3vs1")

  output$userguide <- downloadHandler(
    filename="snowload_user_guide.pdf",
    content=function(file){
      file.copy(file.path(getwd(),'www','snowload_user_guide.pdf'), file,overwrite = TRUE)
    }
  )

  output$savemap_rl <- downloadHandler(
    filename = function(){
      indexi = as.numeric(input$periode)
      paste0(vecDegre[indexi], "_", input$elev, ".zip") #
    },
    content = function(file) {
      indexi = as.numeric(input$periode)
      # create a temp folder for shp files
      data=shp_rl() %>% select(nuts_id,nuts_name,rl) %>% na.omit() %>%
        dplyr::rename(all_of(c("Region"="nuts_name", rl_chgcol[indexi])))
      temp_shp <- tempdir()
      # write shp files
      st_write(data, dsn=temp_shp, layer=layer_name[indexi], driver="ESRI Shapefile", append=FALSE)
      # zip all the shp files
      zip_file <- file.path(temp_shp, paste0(layer_name[indexi],"_shp.zip"))
      shp_files <- list.files(temp_shp,
                              layer_name[indexi],
                              full.names = TRUE)
      zip_command <- paste("zip -j",
                           zip_file,
                           paste(shp_files, collapse = " "))
      system(zip_command)
      # copy the zip file to the file argument
      file.copy(zip_file, file)
      # remove all the files created
      file.remove(zip_file, shp_files)

    })

  ############## Reactive COLOR PALETTE ###############

  palette_couleur <- reactive({
    couleur_carte <- list()
    absrl_max=max(shp_rl()$rl, na.rm=TRUE)
    absrl_min=min(shp_rl()$rl, na.rm=TRUE)
    color_heat=rev(brewer.pal(n = 4, name = "YlOrRd"))
    color_cold=brewer.pal(n = 5, name = "Blues")
    couleur_carte[[1]] <- colorBin(color_cold, domain = c(absrl_min,absrl_max), bins=10, na.color = "#FF000000")
    couleur_carte[[2]] = couleur_carte[[1]]

    couleur_carte[[3]] <- colorBin(c(color_heat,color_cold,"darkblue"),
                                   domain = seq(-100,160,20), bins=11, na.color = "#FF000000")

    palette_couleur=couleur_carte[[as.numeric(input$periode)]]

    return(palette_couleur)
  })

  ############## Reactive MAPPING ###############

  output$rl_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lat = 56.5, lng = 23, zoom = 3)
  })

  observe({
    leafletProxy("rl_map", data = shp_rl() ) %>%
      clearControls() %>%
      addLegend(pal = palette_couleur(), values = ~rl, opacity=1, title=unite_nom[as.numeric(input$periode)]) %>%
      clearShapes() %>%
      addPolygons(fillColor = ~palette_couleur()(rl), stroke = TRUE,
                  weight=1, color=~palette_bordure(rl),fillOpacity=1, #"black"
                  popup = popupTable(shp_rl() %>%
                                       dplyr::rename(all_of(c("Region"="nuts_name", "Altitude (m)"="alt_mtmsi",
                                                              rl_chgcol[as.numeric(input$periode)],
                                                              inc_chgcol[as.numeric(input$periode)]))),
                                     row.numbers = FALSE, feature.id = FALSE,
                                     zcol=c("Region",
                                            "Altitude (m)",
                                            rl_col[as.numeric(input$periode)],
                                            inc_col[as.numeric(input$periode)])))
  })

}


