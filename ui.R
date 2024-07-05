
library(leaflet)
library(leafpop)

ui = fluidPage(

  # App title
  titlePanel("  "),

  sidebarLayout(

    sidebarPanel(
      p(strong("Parameters", HTML('&nbsp;'),
             style="font-size:17px")),
      # Sidebar panel for inputs
      # First input: RCP
      selectInput(inputId = "periode",
                  label = "Time period",
                  choices = list("Historical 1975-2005"=1, "Projection 2071-2100 (absolute)"=2, "Projection 2071-2100 (relative)"=3)),
      selectInput(inputId = "rcp",
                  label = "Climate scenario",
                  choices = list("RCP2.6"=1, "RCP4.5"=2, "RCP8.5"=3)),
      selectInput(inputId = "elev",
                  label = "Elevation",
                  choices = list("0"= 0,"100"=100, "200"=200, "300"=300,
                                 "400"=400, "500"=500, "600"=600, "700"=700,
                                 "800"=800, "900"=900, "1000"=1000, "1100"=1100,
                                 "1200"=1200, "1300"=1300, "1400"=1400, "1500"=1500,
                                 "1600"=1600, "1700"=1700, "1800"=1800, "1900"=1900,
                                 "2000"=2000, "2100"=2100, "2200"=2200, "2300"=2300,
                                 "2400"=2400, "2500"=2500, "2600"=2600, "2700"=2700,
                                 "2800"=2800, "2900"=2900, "3000"=3000, "3100"=3100,
                                 "3200"=3200, "3300"=3300)),
      width=3),

    mainPanel(
      tags$head(
        tags$style(type='text/css', 
                   ".nav-tabs {font-size: 18px} ", "#rel_map{height:85vh !important;}", 
                   "#abs_map{height:85vh !important;}", "#hist_map{height:85vh !important;}")),  
      tabsetPanel( 
        id="fenetre",
        tabPanel("Map",
                 value="panel1",
                 leafletOutput('rl_map'),
                 downloadButton(label="Download as shapefile", outputId = "savemap_rl"),
                 downloadButton(label="Download as csv", outputId = "savedf_rl")),
        tabPanel(title="Context",
                 value="panel2",
                 p(HTML('&nbsp;')),
                 p(strong("The FPCUP “Snowloads” project"),
                   style="font-size:19px"
                 ),
                 p(
                   "Extreme snow fall and snow loads are challenging natural hazards in mountain areas 
                   and in lowlands. While both winter and summer are projected to become warmer throughout 
                   Europe, extreme precipitation is projected to increase throughout ", 
                   HTML(paste0("Europe",tags$sup("1,2,3,4,5"))),
                   ". However, how the combination of temperature increase and extreme precipitation increase 
                   translates into changes in maximum annual amount of snow on the ground depends on location and 
                   elevation. As part of the “Snowloads” project of Framework Partnership Agreement on Copernicus User 
                   Uptake (FPCUP), this portal provides information about past and future 50-year return level estimations 
                   of maximum annual snow mass, as it is key factor of Eurocodes infrastructure safety standards. The maximum 
                   annual snow mass, also referred to as the maximum annual snow water equivalent (SWE), expressed in kg/m2 
                   (equivalent to mm water equivalent), is directly related to the snow load: the latter is obtained by 
                   multiplying SWE values by the gravity of Earth, typically 9.8 ",
                   HTML(paste0("m/s",tags$sup("2"))), 
                   ".",
                   style="text-align: justify;font-size:18px"
                 ),
                 p(
                   "For more information about FPCUP Snowloads ", 
                   tags$a(href="http://www.copernicus-user-uptake.eu/user-uptake/details/estimation-of-snow-load-data-using-copernicus-and-in-situ-data-531", 
                          "click here"), 
                   ".",
                   style="text-align: justify;font-size:18px"
                  ),
                 p(HTML('&nbsp;')),
                 p(strong("The C3S application"),
                   style="font-size:19px"
                 ),
                 p(
                   "The «Snowloads» application of Copernicus Climate Change Service (C3S) provides direct access to snowload 
                   extreme values under past and future climate in Europe, based on datasets of regional reanalyses and regional 
                   climate projections gathered through Copernicus. It enables users to visualize regional data depending on 
                   elevation and location (",
                   actionLink("inTabset", "see Data & Method"),
                   "). The current portal is for demonstration only, and may later be 
                   implemented directly on a Copernicus-hosted portal.", 
                   style="text-align: justify;font-size:18px"
                 )
        ),
      tabPanel("Data & Method",
                 value="panel3",
                 p(HTML('&nbsp;')),
                 p(strong("Data sets used"),
                   style="font-size:19px"
                 ),
                 p("
                 This portal uses data from the C3S Mountain Tourism Meteorological and Snow",
                 HTML(paste0("Indicators",tags$sup("6"))),", which provides a set of snow related indicators based on the 
                 UERRA reanalysis and EURO-CORDEX projections at NUTS-3 (Nomenclature des Unités Territoriales Statistiques) 
                 level, by steps of 100 m elevation. In mountainous areas, the data is provided for several elevation steps, 
                 while for non-mountainous areas the data is provided at the mean elevation of the NUTS-3. Here we use the 
                 annual SWE maximum (over each hydrological year, from August to July). The ADAMONT ", 
                 HTML(paste0("method",tags$sup("7")))," was used to adjust the EURO-CORDEX GCM/RCM pairs using the 
                 UERRA 5.5 km reanalysis as an observation", 
                 HTML(paste0("reference",tags$sup("8"))),". Altogether, this projection ensemble comprises 20 future 
                 climate change scenarios for the 21st century 
                 (9 GCM/RCM pairs for RCP4.5 and RCP8.5, including 2 for RCP2.6).", style="text-align: justify;font-size:18px"
                   ),
                 p(HTML('&nbsp;')),
                 p(strong("Estimating 50-year return levels"),
                   style="font-size:19px"
                 ),
                 strong(
                 "Absolute values", style="font-size:18px"
                 ),
                 p(
                 "We adjusted Generalized Extreme Value ", HTML(paste0("distribution",tags$sup("9,10"))), 
                 " on SWE maxima of 1975-2005 and 2071-2100 time periods.
                   On each simulation chain (GCM-RCM):",
                 strong("(1)"), "If less than 10 non null SWE maxima existed, we carried out no adjustment (insufficient data)."
                 , strong("(2)"), "If at least one null SWE maximum was recorded, we considered a discrete-continuous mixed 
                 distribution with a probability mass in zero and a continuous distribution (exponential or gamma) 
                 for non-zero values.", strong("(3)"), ("Otherwise, we adjusted using a Gumbel function."
                 ), "If one chain of RCP/NUTS/altitude ensemble had less than 10 non null SWE, we
                   went through step 1-3 with all members of the ensemble. This enables to compute 50-year return level 
                 values for annual SWE maximum. ", style="text-align: justify;font-size:18px"
                 ),
                 strong(
                   "Relative differences", style="font-size:18px"
                 ),
                 p(
                 "Based on the results obtained through the method above, we computed the relative difference in return levels 
                 values between 1975-2005 and 2070-2100.",
                 style="text-align: justify;font-size:18px"
                 )),
        tabPanel("References",
                 value="panel4",
                 p(" "),
                 p(
                   strong("1."),"Filippo Giorgi and Piero Lionello, “Climate change projections for the 
                   Mediterranean region”,", em("Global and Planetary Change"), ", vol. 63, no. 2, pp. 90–104, Sept. 2008."
                 ),
                 p(
                   strong("2."),"Daniela Jacob, Juliane Petersen, Bastian Eggert, Antoinette Alias, 
                   Ole Bøssing Christensen, Laurens M. Bouwer, Alain Braun, Augustin Colette, Michel Deque, Goran Georgievski, 
                   Elena Georgopoulou, Andreas Gobiet, Laurent Menut, Grigory Nikulin, Andreas Haensler, Nils Hempelmann, 
                   Colin Jones, Klaus Keuler, Sari Kovats, Nico Kroner, Sven Kotlarski, Arne Kriegsmann, Eric Martin, 
                   Erik van Meijgaard, Christopher Moseley, Susanne Pfeifer, Swantje Preuschmann, Christine Radermacher, 
                   Kai Radtke, Diana Rechid, Mark Rounsevell, Patrick Samuelsson, Samuel Somot, Jean-Francois Soussana, 
                   Claas Teichmann, Riccardo Valentini, Robert Vautard, Bjorn Weber, and Pascal Yiou, “EURO-CORDEX: new 
                   high-resolution climate change projections for European impact research”, 
                   ", em("Regional Environmental Change"), ", vol. 14, no. 2, pp. 563–578, Apr. 2014."
                 ),
                 p(
                   strong("3."),"Simone Russo, Jana Sillmann, and Erich M. Fischer, “Top ten European heatwaves 
                   since 1950 and their occurrence in the coming decades”,", em("Environmental Research Letters"),", 
                   vol. 10, no. 12, pp. 124003, Nov. 2015, Publisher: IOP Publishing."
                 ),
                 p(
                   strong("4."),"E. Kjellstrom, G. Nikulin, G. Strandberg, O. B. Chri-tensen, D. Jacob,
                   K. Keuler, G. Lenderink, E. van Meijgaard, C. Schar, S. Somot, S. L. Sørland, C. Teichmann 
                   , and R. Vautard, “European climate change at global mean temperature increases of 1.5 and 2 degree Celsius 
                   above pre-industrial conditions as simulated by the EURO-CORDEX regional climate models”, 
                   ", em("Earth System Dynamics"),", vol. 9, no. 2, pp. 459–478, 2018."
                 ),
                 p(
                   strong("5."),"Jens Hesselbjerg Christensen, Morten A. D. Larsen, Ole B. Christensen, 
                   Martin Drews, and Martin Stendel, “Robustness of European climate projections from 
                   dynamical downscaling”, ", em("Climate Dynamics"),", vol. 53, no. 7, pp. 4857–4869, Oct. 2019."
                 ),
                 p(
                   strong("6."),"Samuel Morin, Raphaelle Samacoits, Hugues Francois, Carlo M. Carmagnola, Bruno Abegg, O. Cenk 
                 Demiroglu, Marc Pons, Jean-Michel Soubeyroux, Matthieu Lafaysse, Sam Franklin, Guy Griffiths, Debbie Kite, 
                 Anna Amacher Hoppler, Emmanuelle George, Carlo Buontempo, Samuel Almond, Ghislain Dubois and Adeline Cauchy, 
                 “Pan-european meteorological and snow indicators of climate change impact on ski tourism”,",
                 em("Climate Services"), ", vol. 22, pp.100215, Apr. 2021."
                 ),
                 p(
                   strong("7."),"Deborah Verfaillie, Michel Deque, Samuel Morin, and Matthieu Lafaysse, “The method 
                   ADAMONT v1.0 for statistical adjustment of climate projections applicable to energy balance land 
                   surface models”, ",em("Geoscientific Model Development"), ", vol.10, no.11, pp.4257-4283, Nov. 2017. "
                 ),
                  p(
                    strong("8."),"Cornel Soci, Eric Bazile, Francois Besson, and Tomas Landelius,
                   “High-resolution precipitation reanalysis system for climatological purposes”, ",
                   em("Tellus A: Dynamic Meteorology and Oceanography"),", vol. 68, no. 1, pp.29879, Dec. 2016, Publisher: Taylor & Francis eprint: 
                   https://doi.org/10.3402/tellusa.v68.29879."
                 ),
                 p(
                   strong("9."),"R. A. Fisher and L. H. C. Tippett, “Limiting forms of the frequency distribution of 
                   the largest or smallest member of a sample”, ",em("Mathematical Proceedings of the Cambridge 
                   Philosophical Society"),", vol. 24, no. 2, pp. 180–190, Apr. 1928, Publisher: Cambridge University Press."
                 ),
                  p(
                    strong("10."),"B. Gnedenko, “Sur La Distribution Limite Du Terme Maximum D’Une Serie Aleatoire”, 
                   ",em("The Annals of Mathematics"),", vol. 44, no. 3, pp. 423, July 1943."
                 )
      )
      ),
      width=8)
    
  )
)

