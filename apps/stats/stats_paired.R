rm(list = ls())
#setwd("I:/My Drive/codingPrac/R/")

pairedTest = function(x1,x2, name = "Condition"){
  require("BayesFactor"); require("effsize"); require("pwr")
  cc = complete.cases(x1,x2)
  x1 = x1[cc] ; x2 = x2[cc]
  n = length(x1)
  n_increase = sum(x2 > x1) ; n_decrease = sum(x2 < x1)
  m1 = mean(x1) ; m2 = mean(x2)
  sd1 = sd(x1) ; sd2 = sd(x2)
  se1 = sd1/sqrt(n) ; se2 = se1/sqrt(n)
  wil = wilcox.test(x2, x1, paired = TRUE, exact=FALSE)
  wv = wil$statistic  
  wpval = wil$p.value  
  t = t.test(x2,x1, paired = TRUE, alternative = "two.sided")
  tstat = as.numeric(t$statistic)
  tpval = as.numeric(t$p.value)
  cohenD = cohen.d(x2,x1, paired=TRUE, hedges.correction=FALSE)$estimate
  hedgeG = cohen.d(x2,x1, paired=TRUE, hedges.correction=TRUE)$estimate  
  BF = ttestBF(x2,x1,paired = TRUE) ; BF = as.vector(BF)[[1]]
  reqSample = pwr.t.test(n = NULL, d = cohenD, sig.level = 0.05, power = 0.8, type = "paired", alternative = "two.sided")$n
  power = pwr.t.test(n = length(x1), d = cohenD, sig.level = 0.05, power = NULL, type = "paired", alternative = "two.sided")$power
  d = data.frame(name,n,n_increase,n_decrease,m1,m2,sd1,sd2,se1,se2,tstat,tpval,wv,wpval,cohenD,hedgeG,power,reqSample,BF)
  rownames(d) = NULL
  return(d)
}

d1 = pairedTest(rnorm(30,0,1),rnorm(30,0,1),"case1")
d2 = pairedTest(rnorm(30,0,1),rnorm(30,2,1),"case2")
d = rbind(d1,d2)



