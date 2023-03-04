rm(list = ls())
graphics.off()

# Data from https://www.kaggle.com/datasets/shrutimehta/zomato-restaurants-data?resource=download

# Boilerplate stuff
rm(list = ls()) ; graphics.off()
library(rworldmap); library(priceR); library("stringdist")
path = 'C:/Users/syahe/OneDrive/Desktop/zomatoData/' ; setwd(path)

# load data
data = read.csv('zomato.csv')
country = read.csv('Country-Code.csv')$Country

# currency conversion to USD
currency = currencies()

# cases fail fuzzy matching
data$Currency[data$Currency == 'Dollar($)'] = 'United States Dollar'
data$Currency[data$Currency == 'Pounds(\x8c\xa3)'] = 'British Pound Sterling'
data$Currency[data$Currency == 'Emirati Diram(AED)'] = 'United Arab Emirates Dirham'
data$Currency[data$Currency == 'Rand(R)'] = 'South African Rand'
data$Currency = currency$description[amatch(data$Currency, currency$description,maxDist = 10)] #fuzzy matching

currency2code = function(x){return(currency$code[currency$description == data$Currency[x]])}
data$CurrencyCode = sapply(1:length(data$Currency),currency2code)
data$USD = round(convert_currencies(data$Average.Cost.for.two,data$CurrencyCode,"USD")/2,2)

#aggregate ratings by country
meanRating = sapply(split(data$Aggregate.rating, data$Country.Code), mean)
meanUSD = sapply(split(data$USD, data$Country.Code), mean)
meanRatingbyPrice = round(meanRating/meanUSD,2)

# clean up mistakes in country names
country[country == 'UAE'] = 'United Arab Emirates' 
country[country == 'Phillipines'] = 'Philippines'

# join summary data with map data
summaryData = data.frame(country,meanRating,meanUSD,meanRatingbyPrice)
n = joinCountryData2Map(summaryData, joinCode="NAME", nameJoinColumn="country")

# plot the maps
dev.new()
par(mar=c(0, 0, 0, 0)) ; par(mfrow=c(1,3))
mapCountryData(n, nameColumnToPlot="meanRating", mapTitle="Ratings", oceanCol="lightblue", missingCountryCol="white", addLegend='FALSE')
mapCountryData(n, nameColumnToPlot="meanUSD", mapTitle="Price", oceanCol="lightblue", missingCountryCol="white", addLegend='FALSE')
mapCountryData(n, nameColumnToPlot="meanRatingbyPrice", mapTitle="Ratings_by_price", oceanCol="lightblue", missingCountryCol="white", addLegend='FALSE')
