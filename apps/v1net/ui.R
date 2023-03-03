library(shiny)

# Define UI for application that plots random distributions 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("V1 Generator"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    textOutput("owner"),
    textOutput("space1"), 
    sliderInput("Stimulus", "Orientation of Sample Stimulus:", min = -180,max = 179, value = 23),
    sliderInput("Tuning", "Tuning (sd) of population:", min = 1,max = 100, value = 20),
    sliderInput("Gain", "Gain of population:", min = 0,max = 12, value = 0),
    sliderInput("Noise", "Noise of population:", min = 0,max = 1, value = 0.1),
    sliderInput("Trials", "Number of trials (more trials = slower):", min = 500,max = 5000, value = 1000),
    helpText( a("Click here for more information", href="https://brittlab.uwaterloo.ca/2016/04/23/OnlineV1Model/"), 
              p(''),
              a("Click here for the VSS poster", href="http://syaheed.tech:3838/sj_vss2016_final.pdf") )
  ,width = 3),
  
  
  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("population", width = 600, height=300),
    plotOutput("encode", width=600, height=300)
  , width = 9 )
))
