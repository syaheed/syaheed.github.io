rm(list = ls())

## Based on data from https://goldberg.berkeley.edu/jester-data/ (just the first set)
d = read.csv('jester-data-1.csv', header = FALSE) # converted to csv for easier use
d = d[,2:101] # remove column 1, now we are only left with 1 column per option (column 1 was number of ratings given)
d[d == 99] = NA # specify NAs
numOpts = length(d)

#calculate dissimilarity matrix (based in linear distance)
disMat = matrix(NA,nrow = numOpts, ncol = numOpts)
for (i in 1:numOpts){
  print(i)
  for (j in 1:numOpts){
    a = cbind(d[i],d[j]); a = a[complete.cases(a),]
    disMat[i,j] = mean(abs(a[,1] - a[,2]))
  }
}
disMat = disMat/ max(disMat)

# Correlation Map
corMap = function(disMat){
  numFeatures = length(disMat[1,])
  par(las=2)
  par(mar=c(1,1,1,1)) # adjust as needed
  x = seq(0,1,0.1) 
  colfunc = colorRampPalette(c("royalblue","white"))
  colHex = colfunc(length(x)) # make 11 colors / shades of blue
  plot(-100,-100,xlim = c(-2,numFeatures) , ylim = c(-2,numFeatures), xlab = "", ylab = "", xaxt="n", yaxt="n")
  for (i in 1:numFeatures){
    text(i,-1,as.character(i), cex=0.7, srt=270)
    text(-1,i,as.character(i), cex=0.7)
    for (j in 1:numFeatures){
      colIdx = (round(disMat[i,j],2) * 10) +1
      rect(i-0.5,j-0.5,i+0.5,j+0.5,col = colHex[colIdx])
    }
 }
}
x11(display = "", 1000,1000); corMap(disMat)
savePlot(filename = 'recommender.jpg', "jpeg", device = dev.cur())

# Make recommendations
recJokes = function(opt, n=1, mat=disMat){
  return(order(mat[opt,])[2:(1+n)])
}
recJokes(14,5) # suggest 5 best jokes based on liking joke#14



