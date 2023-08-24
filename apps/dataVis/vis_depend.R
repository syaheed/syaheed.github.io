rm(list = ls())
#setwd("I:/My Drive/codingPrac/R/")

# Load necessary packages
library('ggplot2')
library('dplyr')
library('ggpubr')

# Load the iris dataset
d = iris
d$Species = as.factor(d$Species)

# Let's assume that sepal length is measured again after time t+1 and t+2.
# Lets also assume an average growth rate of 10%, 20% and 30% for the different species
d$Sepal.Length2 = NA
d$Sepal.Length3 = NA
d$Sepal.Length2[d$Species == 'setosa'] = d$Sepal.Length[d$Species == 'setosa'] * rnorm(length(d$Sepal.Length[d$Species == 'setosa']), mean = 1.1, sd = 0.1)
d$Sepal.Length3[d$Species == 'setosa'] = d$Sepal.Length2[d$Species == 'setosa'] * rnorm(length(d$Sepal.Length[d$Species == 'setosa']), mean = 1.1, sd = 0.1)
d$Sepal.Length2[d$Species == 'versicolor'] = d$Sepal.Length[d$Species == 'versicolor'] * rnorm(length(d$Sepal.Length[d$Species == 'versicolor']), mean = 1.2, sd = 0.2)
d$Sepal.Length3[d$Species == 'versicolor'] = d$Sepal.Length2[d$Species == 'versicolor'] * rnorm(length(d$Sepal.Length[d$Species == 'versicolor']), mean = 1.2, sd = 0.2)
d$Sepal.Length2[d$Species == 'virginica'] = d$Sepal.Length[d$Species == 'virginica'] * rnorm(length(d$Sepal.Length[d$Species == 'virginica']), mean = 1.3, sd = 0.3)
d$Sepal.Length3[d$Species == 'virginica'] = d$Sepal.Length2[d$Species == 'virginica'] * rnorm(length(d$Sepal.Length[d$Species == 'virginica']), mean = 1.3, sd = 0.3)

# Let's make the relevant data into a 'long' format
dT1 = data.frame(ID = as.factor(1:length(d$Species)), Species = d$Species, Sepal.Length = d$Sepal.Length)
dT2 = data.frame(ID = as.factor(1:length(d$Species)), Species = d$Species, Sepal.Length = d$Sepal.Length2)
dT3 = data.frame(ID = as.factor(1:length(d$Species)), Species = d$Species, Sepal.Length = d$Sepal.Length3)
d = rbind(dT1,dT2,dT3)
d$Time = as.factor(c(rep(1,length(dT1$Species)), rep(2,length(dT2$Species)), rep(3,length(dT3$Species)) ))
rm(list = c('dT1','dT2','dT3'))

# Within-Subj error bars
within_summary = function(species){
  # Cousineau, Denis, and Fearghal O’Brien. "Error bars in within-subject designs: a comment on Baguley (2012)." Behavior Research Methods 46 (2014): 1149-1151.
  # https://doi.org/10.3758/s13428-013-0441-z 
  X1 = d$Sepal.Length[d$Species == species & d$Time == 1]
  X2 = d$Sepal.Length[d$Species == species & d$Time == 2]
  X3 = d$Sepal.Length[d$Species == species & d$Time == 3]
  XM = (X1+X2+X3)/3
  XGrand = mean(XM)
  
  Y1 = X1 - XM + XGrand 
  Y2 = X2 - XM + XGrand 
  Y3 = X3 - XM + XGrand 
  
  M_X1 = mean(X1)
  M_X2 = mean(X2)
  M_X3 = mean(X3)
  SE_X1 = sd(Y1)/sqrt(length(Y1)) * sqrt(3/2)
  SE_X2 = sd(Y2)/sqrt(length(Y2)) * sqrt(3/2)
  SE_X3 = sd(Y3)/sqrt(length(Y3)) * sqrt(3/2)
  
  temp = data.frame(Species = rep(species,3), M = c(M_X1,M_X2,M_X3), SE = c(SE_X1,SE_X2,SE_X3), Time = c(1,2,3) )
  temp$Species = as.factor(temp$Species)
  temp$Time = as.factor(temp$Time)
  return(temp)
}
summary_data = rbind(within_summary(unique(d$Species)[1]),within_summary(unique(d$Species)[2]),within_summary(unique(d$Species)[3]))

p1a = ggplot() + 
  geom_violin(data = d, aes(x = Species, y = Sepal.Length, fill = Species), alpha = 0.1) + 
  geom_jitter(data = d, aes(x = Species, y = Sepal.Length, color = Species)) +
  geom_boxplot(data = d, aes(x = Species, y = Sepal.Length),width=0.1) +
  labs(title = "Sepal Length split by Time", x = "Species", y = "Sepal Length") +
  theme_minimal() + theme(legend.position = "none") +
  facet_grid(. ~ Time)

p1b = ggplot() + 
  geom_violin(data = d, aes(x = Time, y = Sepal.Length, fill = Species), alpha = 0.1) + 
  geom_jitter(data = d, aes(x = Time, y = Sepal.Length, color = Species)) +
  geom_boxplot(data = d, aes(x = Time, y = Sepal.Length),width=0.1) +
  labs(title = "Sepal Length split by Species", x = "Time", y = "Sepal Length") +
  theme_minimal() + theme(legend.position = "none") +
  facet_grid(. ~ Species)

p2 = ggplot() + 
  geom_line(data = d, aes(x = Time, y = Sepal.Length, group = ID, color = Species), linewidth = 0.3, linetype = "solid", alpha = 0.1) + 
  geom_point(data = d, aes(x = Time, y = Sepal.Length, color = Species)) + 
  geom_line(data = summary_data, aes(x = Time, y = M), group = 1, linewidth = 0.1, linetype = "solid", color = 'black') + 
  geom_point(data = summary_data, aes(x = Time, y = M, color = Species),shape = 16, size = 0.5, color = 'black') + 
  geom_errorbar(data = summary_data, aes(x = Time, ymin = M - SE, ymax = M + SE),width = 0.2, color = 'black')+
  labs(title = "Sepal Length by Time", x = "Time", y = "Sepal Length") +
  theme_minimal() + theme(legend.position = "none") + 
  facet_grid(. ~ Species)

p3 = ggplot() + 
  geom_line(data = summary_data, aes(x = Time, y = M, group = Species, color = Species), linewidth = 0.3, linetype = "solid") + 
  geom_point(data = summary_data, aes(x = Time, y = M, color = Species),shape = 16, size = 3) + 
  geom_errorbar(data = summary_data, aes(x = Time, ymin = M - SE, ymax = M + SE, color = Species),width = 0.2)+
  labs(title = "Sepal Length by Species/Time", x = "Time", y = "Sepal Length") +
  theme_minimal() #+ theme(legend.position = "none") 


x11()
ggarrange(p1a, p2, p3, ncol = 1, nrow = 3)
ggsave(filename = "vis_depend.jpg",width = 20, height = 30, units = 'cm', dpi = 300)


