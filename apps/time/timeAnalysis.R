rm(list = ls())

library(dplyr)
set.seed(123)
seconds_per_day = 60*60*24
seconds_per_week = seconds_per_day*7

# create a dataset  
start = as.numeric(as.POSIXct("2023-07-02 00:00:00"))
finish = as.numeric(as.POSIXct("2023-08-27 00:00:00"))

x = runif(10000, min = start, max = finish)
d = data.frame(timestamp = as.POSIXct(x))
d$weekday = weekdays(d$timestamp)
d$weekday = factor(d$weekday, levels= c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

d$hour = as.numeric(format(d$timestamp, "%H"))
d$month = as.numeric(format(d$timestamp, "%m"))
d$week = NA
d$day = NA

for (i in 1:8){d$week[d$timestamp <= finish-((i-1)*seconds_per_week)] = 9-i}
for (i in 1:56){d$day[d$timestamp <= finish-((i-1)*seconds_per_day)] = 57-i}

# manipulate dataset to make things less uniform (let's assume timestamps are work-related)
x = which(d$weekday == "Sunday")
x = sample(x,round(length(x)*0.6))
d = d[-x,]

x = which(d$weekday == "Saturday")
x = sample(x,round(length(x)*0.8))
d = d[-x,]

x = which(d$hour <= 9)
x = sample(x,round(length(x)*0.6))
d = d[-x,]

x = which(d$hour >= 17)
x = sample(x,round(length(x)*0.6))
d = d[-x,]

x = which(d$week == 1)
x = sample(x,round(length(x)*0.6))
d = d[-x,]

# summarise data
dmat = d %>% count(day) # daily counts
emat = d %>% count(week) # weekly counts

# for weekday/hour plot
lmat = d %>% count(weekday,hour) # 'long' format
wmat = reshape(lmat, idvar = "weekday", timevar = "hour", direction = "wide") # make 'wide'
colnames(wmat)[2:25] = paste0(as.character(0:23),'-',as.character(1:24)) # column labels
wmat[,2:25] = wmat[,2:25]/max(wmat[,2:25]) # normalize to 1 as max

# plotting functions
corMap = function(wmat){
  # plot weekday by hour
  numDays = 7
  numHours = 24
  par(las=2)
  par(mar=c(1,1,1,1)) # adjust as needed
  x = seq(0,1,0.1)
  colfunc = colorRampPalette(c("black","royalblue"))
  colHex = colfunc(length(x)) # make 11 colors / shades of blue
  plot(-100,-100,xlim = c(-1.5,numHours) , ylim = c(-0.5,numDays+0.5), xlab = "", ylab = "", xaxt="n", yaxt="n",bty="n")
  for (i in 1:numHours){
    text(i,-0.1,colnames(wmat)[i+1], cex=1, srt=270, col = "white")
    text(-1,1+7-i,wmat[i,1], cex=1, col = "white")
    for (j in 1:numDays){
      colIdx = (round(wmat[j,i+1],2) * 10) +1
      rect(i-0.5,1+numDays-j-0.5,i+0.5,1+numDays-j+0.5,col = colHex[colIdx])
    }
  }
}

# plot
x11(display = "", 1000,1000); layout(matrix(c(1,2,3,3), nrow = 2, ncol = 2, byrow = TRUE))
par(bg = "black", fg = 'white')

par(mar=c(5,5,5,1)) # adjust as needed
plot(dmat$day,dmat$n,type="l", lwd = 2, cex.lab=1.2, cex.axis=1, ylab = 'Count', xlab = 'Day', col.lab = "white" , col.axis = "white", col = "royalblue")
mtext(expression(bold("Timestamp Analyses")), side = 3, line = -2, outer = TRUE)

par(mar=c(5,5,5,1)) # adjust as needed
barplot(emat$n,names.arg = emat$week, cex.lab=1.2, cex.axis=1, ylab = 'Count', xlab = 'Week', col.lab = "white" , col.axis = "white", col = "royalblue")

corMap(wmat)
savePlot(filename = 'time.jpg', "jpeg", device = dev.cur())
