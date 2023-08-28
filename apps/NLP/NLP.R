rm(list = ls())

#import libraries
library("stopwords")
library("dplyr")

#import data
data = readLines("nytimes_news_articles.txt") # text repo
sw = gsub("'","",stopwords("en", source = "snowball")) # stopwords
prevData = read.csv("13428_2018_1077_MOESM2_ESM.csv") # database for prevalence

# some initial data-mining based on where the "URL" line is.
idxURL = grep("URL: http:", data)
idxStart = idxURL +2
numArticles = length(idxStart)
idxFinish = c(idxStart[2:numArticles] - 4, length(data))

# function to extract text per article and get features of interest
extractData = function(articleno){
  temp = unlist(strsplit(data[idxURL][articleno],'/'))
  source = temp[3]
  year = temp[4]
  month = temp[5]
  day = temp[6]
  topic = temp[7]
  subtopic = temp[8]
  artHead = gsub('.html','',gsub('-',' ',temp[9]))
  
  text = tolower(paste(data[idxStart[articleno]:idxFinish[articleno]],collapse = " "))
  text = gsub('-',' ',text); text=gsub("[()]", "", text); text = gsub("’","",text); text = gsub('\\.','',text); text = gsub(',','',text); text = gsub('”','',text); text = gsub('“','',text); text = gsub(':','',text)
  text = gsub("[[:digit:]]", "", text)
  text = gsub(".*— ","",text)
  text = gsub("  ", " ", text, perl = TRUE)
  text = gsub("  ", " ", text, perl = TRUE)
  
  tokens = unlist(strsplit(text,' '))
  wordlength = length(tokens)
  tokens = sort(unique(tokens))
  tokens = setdiff(tokens, sw)
  tokens = tokens[tokens %in% prevData$Word]
  uTokens = length(tokens)
  
  uDens = uTokens/wordlength
  
  prevTokens = prevData$Prevalence[match(tokens,prevData$Word)]
  prevMin = min(prevTokens)
  prevMean = mean(prevTokens)
  prevMedian = median(prevTokens)
  
  d = data.frame(source,year,month,day,topic,subtopic,artHead,wordlength,uTokens,uDens,prevMin,prevMean,prevMedian)
  return(d)
}


d = extractData(1)
for (i in 2:numArticles){
  print(i)
  d = rbind(d,extractData(i))
}


#clean-up
x = is.na(d$artHead)
d$artHead[x] = d$subtopic[x] # alignment issues for articles with no subtopics
d$subtopic[x] = NA
d$artHead[x] = gsub('.html','',gsub('-',' ',d$artHead[x]))
d = d[d$uDens >= 0.1, ] # probably errors if its too low (check outliers with hist(d$uDens))
d = d[d$wordlength >= 100, ] # probably errors if its too low, cap word min to 100

#summary per group
agg_tbl = d %>% group_by(topic) %>% 
  summarise(ncount=n(),
            m_wordlength=mean(wordlength),
            m_uTokens=mean(uTokens),
            m_uDens=mean(uDens),
            m_prevMin=mean(prevMin),
            m_prevMean=mean(prevMean),
            m_prevMedian=mean(prevMedian),
            .groups = 'drop')

# plots
x11(display = "", width = 12, height = 12); par(mfrow = c(3, 2))
par(mar = c(7, 5, 5, 5)); barplot(agg_tbl$ncount, main = "Article Count", xlab = "", ylab = "Count", names.arg = agg_tbl$topic,las=2)
par(mar = c(7, 5, 5, 5)); barplot(agg_tbl$m_wordlength, main = "Avg Wordlength", xlab = "", ylab = "Words", names.arg = agg_tbl$topic,las=2, ylim=c(200,650),xpd=FALSE)
par(mar = c(7, 5, 5, 5)); barplot(agg_tbl$m_uTokens, main = "Avg Unique Words", xlab = "", ylab = "Words", names.arg = agg_tbl$topic,las=2, ylim=c(60,170),xpd=FALSE)
par(mar = c(7, 5, 5, 5)); barplot(agg_tbl$m_uDens, main = "Proportion Unique Words", xlab = "", ylab = "Proportion", names.arg = agg_tbl$topic,las=2, ylim=c(0.28,0.38),xpd=FALSE)
par(mar = c(7, 5, 5, 5)); barplot(agg_tbl$m_prevMedian, main = "Median Word Prevalence", xlab = "", ylab = "Prevalence", names.arg = agg_tbl$topic,las=2, ylim=c(2.34,2.38),xpd=FALSE)
par(mar = c(7, 5, 5, 5)); barplot(agg_tbl$m_prevMin, main = "Min Word Prevalence", xlab = "", ylab = "Prevalence", names.arg = agg_tbl$topic,las=2, ylim=c(-0.7,0.7),xpd=FALSE)
savePlot(filename = 'NLP.jpg', "jpeg", device = dev.cur())
