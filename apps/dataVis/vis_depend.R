# Clear all variables
rm(list = ls())

# Load necessary packages
library('ggplot2')
library('dplyr')
library('ggpubr')

# Load the iris dataset
d = iris
d$Species = as.factor(d$Species )

#Calculate mean and standard error for each species
summary_data = d %>% group_by(Species) %>%
 summarise(mean_slength = mean(Sepal.Length),
           se_slength = sd(Sepal.Length) / sqrt(n()),
           mean_swidth = mean(Sepal.Width),
           se_swidth = sd(Sepal.Width) / sqrt(n())
 )

# Plot
p1 = ggplot() + 
  geom_violin(data = d, aes(x = Species, y = Sepal.Length, fill = Species), alpha = 0.1) + 
  geom_jitter(data = d, aes(x = Species, y = Sepal.Length, color = Species)) +
  geom_boxplot(data = d, aes(x = Species, y = Sepal.Length),width=0.1) +
  labs(title = "Sepal Length by Species", x = "Species", y = "Sepal Length") +
  theme_minimal() + theme(legend.position = "none") 

p2 = ggplot() + 
  geom_violin(data = d, aes(x = Species, y = Sepal.Width, fill = Species), alpha = 0.1, color = "grey") + 
  geom_jitter(data = d, aes(x = Species, y = Sepal.Width, color = Species)) +
  geom_boxplot(data = d, aes(x = Species, y = Sepal.Width),width=0.1, color = "grey") +
  labs(title = "Sepal Width by Species", x = "Species", y = "Sepal Width") +
  theme_minimal() + theme(legend.position = "none") 

p3 = ggplot() + 
  geom_jitter(data = d, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  labs(title = "Sepal Length and Width by Species", x = "Sepal Length", y = "Sepal Width") +
  theme_minimal() + theme(legend.position = "none")   

p4 = ggplot() + 
  geom_line(data = summary_data, aes(x = Species, y = mean_slength), group = 1, color = "black", linewidth = 1, linetype = "solid") + 
  geom_point(data = summary_data, aes(x = Species, y = mean_slength),shape = 18, size = 3, color = "black") + 
  geom_errorbar(data = summary_data, aes(x = Species, ymin = mean_slength - se_slength, ymax = mean_slength + se_slength),width = 0.2)+
  geom_line(data = summary_data, aes(x = Species, y = mean_swidth), group = 1, color = "grey", linewidth = 0.5, linetype = "dashed") + 
  geom_point(data = summary_data, aes(x = Species, y = mean_swidth),shape = 18, size = 3, color = "grey") + 
  geom_errorbar(data = summary_data, aes(x = Species, ymin = mean_swidth - se_swidth, ymax = mean_swidth + se_swidth),color = "grey" ,width = 0.2)+
  labs(title = "Sepal Length and Width by Species", x = "Species", y = "Length/Width") +
  theme_minimal() + theme(legend.position = "none") 

x11()
ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2)
ggsave(filename = "vis_depend.jpg",width = 20, height = 20, units = 'cm', dpi = 300)
