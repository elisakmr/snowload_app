
#---------------------------------------

library(shiny)
library(tidyverse)
library(sf)
library(leaflet)
library("rnaturalearth")
library("rnaturalearthdata")
library(ggplot2)
library(ggpubr)
library(ggiraph)
library(leaflet)
library(RColorBrewer)
library(shinydashboard)

load("RLSWEdiff_benchmark.RData")
load("RLSWE_benchmark.RData")

rl_list=list()
rl_list[[1]]<-RLhist.rcp
rl_list[[2]]<-RL.nuts
rl_list[[3]]<-RelDiff.RL *100

indic <- "max-sd-NS-year"
shp_6584nuts <- st_read(paste0(indic,"_sf_nut.shp"))
shp_nuts_raw <- st_read("NUTS3.shp")
shp_nuts = shp_nuts_raw[shp_nuts_raw$nuts_id%in%shp_6584nuts$nuts_id,] # 1517 NUTS
n.nuts = nrow(shp_nuts)

world <- ne_countries(scale = "medium", returnclass = "sf")
vecRCP = c("RCP2.6","RCP4.5","RCP8.5")
colonne_nom <- c('Value (mm)' = "rl", 'Value (mm)' = "rl", 'Value (%)' = "rl")
unite_nom <- c('Value (mm)','Value (mm)','Value (%)')
fichier_nom=c("50yRL_hist_","50yRL_abs_","50yRL_rel_")

#---------------------------------------

server = function(input, output, session) {
  
                                ######### SWITCHING TAB when click on "Method" ##########
  
  observeEvent(input$inTabset, {
    updateTabsetPanel(session, inputId = "fenetre", selected="panel4")
  })
  
                                      ######## Reactive SHAPEFILES ###########
  shp_rl <- reactive({
    shp_rl <- shp_nuts
    index6584 <- which(shp_6584nuts$alt==input$elev)
    idi <- shp_6584nuts$nuts_id[index6584]
    index1515 <- match(idi,shp_nuts$nuts_id)
    n.nuts.alt <- length(index6584)
    shp_rl$rl <- rep(NA,n.nuts)
    shp_rl$rl[index1515] <- round(rl_list[[as.numeric(input$periode)]][index6584,as.numeric(input$rcp)],2)
    return(shp_rl)
  })
  
                              ############## Reactive DOWNLOADS of csv ###############
  
  output$savedf_rl <- downloadHandler(
    filename = function(){
      indic=as.numeric(input$periode)
      paste0(fichier_nom[indic], input$elev, "m_", vecRCP[indic],".csv") #
    },
    content = function(file){
      indic=as.numeric(input$periode)
      data=shp_rl() %>% select(nuts_id,nuts_name,rl) %>% na.omit() %>% 
        dplyr::rename(all_of(c("Region"="nuts_name",colonne_nom[indic])))
      st_write(data,file)
    }
  )
                                  ## Reactive DOWNLOADS of shp as ZIP file ##
  
  layer_name=c("RL_hist","RL_abs","RL_rel")
  output$savemap_rl <- downloadHandler(
    filename = function(){
      indic=as.numeric(input$periode)
      paste0(fichier_nom[indic], input$elev, "m_", vecRCP[indic],".zip") #
    },
    content = function(file) {
      indic=as.numeric(input$periode)
      # create a temp folder for shp files
      data=shp_rl() %>% select(nuts_id,nuts_name,rl) %>% na.omit() %>% 
        dplyr::rename(all_of(c("Region"="nuts_name",colonne_nom[indic])))
      temp_shp <- tempdir()
      # write shp files
      st_write(data, dsn=temp_shp, layer=layer_name[indic], driver="ESRI Shapefile", append=FALSE)
      # zip all the shp files
      zip_file <- file.path(temp_shp, paste0(layer_name[indic],"_shp.zip"))
      shp_files <- list.files(temp_shp,
                              layer_name[indic],
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
                                    ############### REACTIVE MAPS ###################
  
  # color palette
  
  palette_couleur <- reactive({
    couleur_carte <- list()
    absrl_max=max(shp_rl()$rl, na.rm=TRUE)
    absrl_min=min(shp_rl()$rl, na.rm=TRUE)
    color_heat=rev(brewer.pal(n = 5, name = "YlOrRd"))
    color_cold=brewer.pal(n = 5, name = "Blues")
    couleur_carte[[1]] <- colorBin(color_cold, domain = c(absrl_min,absrl_max), bins=10)
    couleur_carte[[2]]=couleur_carte[[1]]
    
    couleur_carte[[3]] <- colorBin(c("darkred",color_heat,color_cold,"darkblue"),
                                   domain = seq(-150,150,20), bins=13)
    
    palette_couleur=couleur_carte[[as.numeric(input$periode)]]
    return(palette_couleur)
  })
  
  # mapping
  
  output$rl_map <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>%
      setView(lat = 56.5, lng = 23, zoom = 3) 
  })

  observe({
    
    leafletProxy("rl_map", data = shp_rl() %>% na.omit()) %>%
      clearControls() %>%
      addLegend(pal = palette_couleur(), values = ~rl, opacity=1, title=unite_nom[as.numeric(input$periode)]) %>%
      clearShapes() %>%
      addPolygons(fillColor = ~palette_couleur()(rl),
                  stroke = TRUE, color="black", weight=1, fillOpacity=1,
                  popup = popupTable(shp_rl() %>% na.omit() %>% dplyr::rename(all_of(c("Region"="nuts_name",
                                                                                       colonne_nom[as.numeric(input$periode)]))),
                                     row.numbers = FALSE, feature.id = FALSE, zcol=c(6,8)))

  })
  
  
}


