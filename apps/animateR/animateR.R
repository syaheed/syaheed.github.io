rm(list = ls())
graphics.off()

library("av")

path = 'C:/Users/syahe/OneDrive/Desktop/animateR/'
setwd(path)

x = 1:360

for (phase in x){
    y = sin(pi*(x+phase) / 180)
    tiff(paste0('plot_',sprintf('%05d',phase),'.tiff'), width = 6, height = 4, units = 'in', res = 100)
    plot(x,y, ylim =  c(-1,1), main = sprintf('Phase Shift = %d degree', phase))
    dev.off()
}

images = sprintf("plot_%05d.tiff", x)
av::av_encode_video(images, 'animated.mp4', framerate = 30)
