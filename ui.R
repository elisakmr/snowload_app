
library(leaflet)
library(leafpop)

ui = fluidPage(

  # App title
  titlePanel("  "),

  sidebarLayout(

    sidebarPanel2(
      img(src='fpcup.png', height="100%", width="100%"),
      p(HTML('&nbsp;')),
      p(HTML('&nbsp;')),
      p(strong("Parameters", HTML('&nbsp;'),
               style="font-size:17px")),
      # Sidebar panel for inputs
      # First input: RCP
      selectInput(inputId = "indic",
                  label = "Variable",
                  choices = list("SWE"=1)),
      selectInput(inputId = "stat",
                  label = "Statistic",
                  choices = list("50-year Return Level"=1)),
      selectInput(inputId = "periode",
                  label = "Global warming",
                  choices = list("1°C above preindustrial"=1, "3°C vs 1°C above preindustrial"= 3)),
      selectInput(inputId = "filtre_alt",
                  label = "Elevation coverage",
                  choices = list("NUTS mean"=1, "Specific layer"= 2)),
      uiOutput('menu'),
      out = downloadButton(label="Download user guide", outputId = "userguide"),
      width=3
    ),

    mainPanel(
      tags$head(
        tags$style(type='text/css',
                   ".nav-tabs {font-size: 18px} ", "#rl_map{height: calc(100vh - 105px) !important;}")), #80
      tabsetPanel(
        id="fenetre",
        tabPanel("Map",
                 value="panel1",
                 leafletOutput('rl_map', height=),
                 downloadButton(label="Download as shapefile", outputId = "savemap_rl"),
                 downloadButton(label="Download as csv", outputId = "savedf_rl")),
        tabPanel("Data & Method",
                 value="panel2",
                 p(HTML('&nbsp;')),
                 p(strong("Data sets used"),
                   style="font-size:19px"
                 ),
                 p("
                 This portal uses data from the ",
                   tags$a(href="https://cds.climate.copernicus.eu/datasets/sis-tourism-snow-indicators?tab=overview",
                          "C3S Mountain Tourism Meteorological and Snow",
                          HTML(paste0("Indicators",tags$sup("1")))),
                ", which provides a set of snow related indicators based on the
                 UERRA reanalysis and EURO-CORDEX projections at NUTS-3 (Nomenclature des Unités Territoriales Statistiques",
                HTML(paste0("Indicators",tags$sup("2"))),", 2013 and 2016 mixed version)
                 level, by steps of 100 m elevation. In mountainous areas, the data is provided for several elevation steps,
                 while for non-mountainous areas the data is provided at the mean elevation of the NUTS-3
                 (see Figure 1 and Figure 2). Here we use the
                 annual SWE maximum (over each hydrological year, from August to July). The ADAMONT ",
                   HTML(paste0("method",tags$sup("3")))," was used to adjust the EURO-CORDEX GCM/RCM pairs using the
                 UERRA 5.5 km reanalysis as an observation",
                   HTML(paste0("reference",tags$sup("4"))),". Altogether, this projection ensemble comprises 20 future
                 climate change scenarios for the 21st century
                 (9 GCM/RCM pairs for RCP4.5 and RCP8.5, including 2 for RCP2.6).", style="text-align: justify;font-size:18px"
                 ),
                 p(HTML('&nbsp;')),
                 img(src='NUTelevation_app.png', height="100%", width="100%", align="center"),
                 p(HTML('&nbsp;')),
                 p(strong("Estimating 50-year return levels"),
                   style="font-size:19px"
                 ),
                 strong(
                   "Absolute values", style="font-size:18px"
                 ),
                 p(
                   " We adjust different non-stationary models on SWE maxima. For each projection obtained with the
                   emission scenario RCP8.5, the parameters of the different candidate distributions are dependent
                   of the warming level of the GCM of the corresponding projection. For each GCM, the warming level is
                   the anomaly of the global mean temperature with respect the preindustrial period 1860-1900, which
                   has been smoothed using a cubic spline (see Figure 3). For each simulation chain (RCP8.5/GCM/RCM): ",
                   strong("(1)"), "If there are less than 10% of non-zero SWE maxima, we no dot try to fit a distribution
                   (insufficient data). "
                   , strong("(2)"), "If there is at least one zero SWE maxima, we consider a discrete-continuous mixed
                   distribution with a probability mass in zero and a continuous distribution (Exponential, Gamma, or Inverse-Gamma)
                   for non-zero values. All parameters are considered to evolve linearly with the warming level
                   (a logit transformation is applied to the parameter corresponding to the
                   probability of having a zero values - the scale parameter σ and location parameter µ
                   may also follow a transformation depending on the distribution).",
                   strong("(3)"), "Otherwise, if there is no zero SWE maxima, different continuous distributions are considered:
                                   Gamma, Generalized Gamma, Gumbel or GEV", HTML(paste0("distribution",tags$sup("5,6"))),"
                                   (generalized extreme value). The shape parameter ξ is considered constant, the scale parameter σ and location
                                   parameter µ are considered to evolve linearly with the warming
                   level (after potential transformation, regarding the distribution).
                   For cases",strong("(2)"),"and",strong("(3)")," we then select the best non-stationary model according to the
                   AIC criteria. The 50-year return level estimation for each NUTS/altitude couple is taken as the mean
                   over the 9 return levels obtained with the different simulation chains -
                  distribution parameters being set to the desired warming level.",
                   style="text-align: justify;font-size:18px"
                 ),
                 img(src='GCM_temp2.png', height="100%", width="100%", align="center"),
                 strong(
                   "Relative differences", style="font-size:18px"
                 ),
                 p(
                   "Based on the results obtained through the method above, we computed the relative difference in return levels
                 values between 1 degree and 3 degrees of global warming. ",
                   style="text-align: justify;font-size:18px"
                 ),
                strong(
                  "Uncertainties", style="font-size:18px"
                ),
                p(
                  "We assess two types of uncertainty. The first source of uncertainty corresponds to the sampling uncertainty.
                  Indeed, the parameters of the different models are estimated using a limited amount of data, and this uncertainty
                  is quantified using a non-parametric bootstrap ",
                  HTML(paste0("method",tags$sup("7"))),
                  ". 100 bootstrap estimates of 50-year return levels are provided for each simulation chain.
                  The second type of uncertainty corresponds to the model uncertainty, i.e. the fact that
                  different climate models lead to different future climate conditions. This second type of uncertainty is
                  assessed using different simulating chains. An overall estimate of these two uncertainties is provided by
                  the quantiles 0.05 and 0.95 of the 100 × 9 estimates. The difference between these two quantiles
                  summarizes the magnitude of the uncertainties.",
                  style="text-align: justify;font-size:18px"
                )

                 ),
        tabPanel(title="Context",
                 value="panel3",
                 p(HTML('&nbsp;')),
                 p(strong("The FPCUP “Snowloads” project"),
                   style="font-size:19px"
                 ),
                 p(
                   "Extreme snow fall and snow loads are challenging natural hazards in mountain areas
                   and in lowlands. While both winter and summer are projected to become warmer throughout
                   Europe, extreme precipitation is projected to increase throughout ",
                   HTML(paste0("Europe",tags$sup("8,9,10,11,12"))),
                   ". However, how the combination of temperature increase and extreme precipitation increase
                   translates into changes in maximum annual amount of snow on the ground depends on location and
                   elevation. As part of the “SNOWLOADS” project of Framework Partnership Agreement on Copernicus User
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
                   "The FPCUP SNOWLOADS application of Copernicus Climate Change Service (C3S) provides direct access to snowload
                   extreme values under past and future climate in Europe, based on datasets of regional reanalyses and regional
                   climate projections gathered through Copernicus. It enables users to visualize regional data depending on
                   elevation and location (",
                   actionLink("inTabset", "see Data & Method"),
                   "). The current portal is for demonstration only, and may later be
                   implemented directly on a Copernicus-hosted portal.",
                   style="text-align: justify;font-size:18px"
                 )
        ),
        tabPanel("References",
                 value="panel4",
                 p(" "),
                 p(
                   strong("1."),"Samuel Morin, Raphaelle Samacoits, Hugues Francois, Carlo M. Carmagnola, Bruno Abegg, O. Cenk
                 Demiroglu, Marc Pons, Jean-Michel Soubeyroux, Matthieu Lafaysse, Sam Franklin, Guy Griffiths, Debbie Kite,
                 Anna Amacher Hoppler, Emmanuelle George, Carlo Buontempo, Samuel Almond, Ghislain Dubois and Adeline Cauchy,
                 “Pan-european meteorological and snow indicators of climate change impact on ski tourism”,",
                   em("Climate Services"), ", vol. 22, pp.100215, Apr. 2021."
                 ),
                 p(
                   strong("2."),"Eurostat NUTS,", em("https://ec.europa.eu/eurostat/fr/web/nuts/publications")
                 ),
                 p(
                   strong("3."),"Deborah Verfaillie, Michel Deque, Samuel Morin, and Matthieu Lafaysse, “The method
                   ADAMONT v1.0 for statistical adjustment of climate projections applicable to energy balance land
                   surface models”, ",em("Geoscientific Model Development"), ", vol.10, no.11, pp.4257-4283, Nov. 2017. "
                 ),
                 p(
                   strong("4."),"Cornel Soci, Eric Bazile, Francois Besson, and Tomas Landelius,
                   “High-resolution precipitation reanalysis system for climatological purposes”, ",
                   em("Tellus A: Dynamic Meteorology and Oceanography"),", vol. 68, no. 1, pp.29879, Dec. 2016, Publisher: Taylor & Francis eprint:
                   https://doi.org/10.3402/tellusa.v68.29879."
                 ),
                 p(
                   strong("5."),"R. A. Fisher and L. H. C. Tippett, “Limiting forms of the frequency distribution of
                   the largest or smallest member of a sample”, ",em("Mathematical Proceedings of the Cambridge
                   Philosophical Society"),", vol. 24, no. 2, pp. 180–190, Apr. 1928, Publisher: Cambridge University Press."
                 ),
                 p(
                   strong("6."),"B. Gnedenko, “Sur La Distribution Limite Du Terme Maximum D’Une Serie Aleatoire”,
                   ",em("The Annals of Mathematics"),", vol. 44, no. 3, pp. 423, July 1943."
                 ),
                 p(
                   strong("7."),"Bradley Efron and Robert Tibshirani, “An Introduction to the Bootstrap (1st ed.)”,
                   ", em("Chapman and Hall/CRC."), ", 1994"
                 ),
                 p(
                   strong("8."),"Filippo Giorgi and Piero Lionello, “Climate change projections for the
                   Mediterranean region”,", em("Global and Planetary Change"), ", vol. 63, no. 2, pp. 90–104, Sept. 2008."
                 ),
                 p(
                   strong("9."),"Daniela Jacob, Juliane Petersen, Bastian Eggert, Antoinette Alias,
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
                   strong("10."),"Simone Russo, Jana Sillmann, and Erich M. Fischer, “Top ten European heatwaves
                   since 1950 and their occurrence in the coming decades”,", em("Environmental Research Letters"),",
                   vol. 10, no. 12, pp. 124003, Nov. 2015, Publisher: IOP Publishing."
                 ),
                 p(
                   strong("11."),"E. Kjellstrom, G. Nikulin, G. Strandberg, O. B. Chri-tensen, D. Jacob,
                   K. Keuler, G. Lenderink, E. van Meijgaard, C. Schar, S. Somot, S. L. Sørland, C. Teichmann
                   , and R. Vautard, “European climate change at global mean temperature increases of 1.5 and 2 degree Celsius
                   above pre-industrial conditions as simulated by the EURO-CORDEX regional climate models”,
                   ", em("Earth System Dynamics"),", vol. 9, no. 2, pp. 459–478, 2018."
                 ),
                 p(
                   strong("12."),"Jens Hesselbjerg Christensen, Morten A. D. Larsen, Ole B. Christensen,
                   Martin Drews, and Martin Stendel, “Robustness of European climate projections from
                   dynamical downscaling”, ", em("Climate Dynamics"),", vol. 53, no. 7, pp. 4857–4869, Oct. 2019."
                 )
        )
      ),
      width=8)

  )
)

