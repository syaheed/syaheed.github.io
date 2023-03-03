library(shiny)
library("pracma")
library('plotrix')

shifter <- function(y,n = 1) {
  if (n == 0) y else c(tail(y, -n), head(y, n))
}

pol <- function(stim) {
  pol2cart(c(stim*pi/180,1))
}

pol2 <- function(s) {
  sapply(s,pol)
}

makepop <- function(max_fire,tuning,gain, x) {
  y = dnorm(x, mean = 0, sd = tuning, log = FALSE)
  y = max_fire * y/max(y)
  mat = sapply(x,shifter,y=y)
  mat = mat + gain
  mat[mat > max_fire] = max_fire
  mat = t(mat)
  return(mat)
}

popplot <- function(mat,colour = 'black') {
  mat2 = t(mat[c(1,46,91,136,181,226,271,316),])
  x = -179:180
  matplot(x, mat2, type = "l", col=colour, xlab = 'Orientation', ylab = 'Firing Rate (Hz)', main = 'Population Neural Tuning', ylim = c(0,max(mat)))
}

encode <- function(mat, stim, noise, x, max_fire) {
  index = which(x==-stim)
  noise_vect = runif(length(x)) * max_fire * noise
  vect = mat[,index] + noise_vect
  vect[vect > max_fire] = max_fire
  return(vect)
}


vplot <- function(vect, x, colour = 'black') {
  polar.plot(vect,x,start=90,clockwise=TRUE, labels = '', main = 'Example Vector plot', line.col = colour, show.grid = 0)
}


decode <- function(vect, cart, stim) {
  res = c(sum(cart[1,] * vect),sum(cart[2,] * vect))
  est = cart2pol(as.vector(res))[1] * 180/pi 
  angDiff = abs((est - stim + 90) %% 180 - 90)
}


coder <- function(stim, mat, max_fire, x, cart) {
  vect = encode(mat, stim, noise = 0.1, x, max_fire)
  angDiff = decode(vect, cart, stim)
  return(angDiff)
}


tplot <- function(vect,x,decoded_data, string, colour = 'black') {
  par(mfrow=c(1,2)) 
  vplot(vect, x, 'red')
  hist(decoded_data, main = string, xlim = c(0,5), xlab = 'Error', breaks = 50, col = 'black') 
}


max_fire = 12
x = -179:180
cart = pol2(x)

shinyServer(function(input, output) {
  
  observe({
    
    nmat = makepop(max_fire, tuning = input$Tuning, gain = input$Gain, x)
    stim_list = round(runif(input$Trials,min = -179, max = 179))
    decoded_data = sapply(stim_list,coder,mat = nmat, max_fire = max_fire, x=x, cart=cart)
    
    output$population <- renderPlot({  popplot(nmat,'red')})
    
    m_angDiff = mean(decoded_data)
    string = paste0('Error Hist. Mean: ', as.character(round(m_angDiff,4)), ' deg')
    nvect = encode(nmat, input$Stimulus, input$Noise, x, max_fire)
    output$encode <- renderPlot({  tplot(nvect, x, decoded_data, string, 'red') })

    output$owner <- renderText({print('Written by Syaheed Jabar (syaheed.jabar@uwaterloo.ca)')})
    output$space1 <- renderText({print('-------------------------------------------------')})
    })
  
  
})



