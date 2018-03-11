####################
# All Computations
####################


# Change to project directory
df <- read.csv("/Users/Gaurab Bose/Desktop/Desktop/R Codes/InvestAI/data/ETFdb.csv", header=TRUE)

library(wskm)
library(cluster)
library(dummies)
library(MASS)     # base R
library(XML)
library(xml2)
library(rvest)
library(purrr)
library(dplyr)
library(tm)
library(parallel)

library(SnowballC)
  #relevant vars
vars <- df[,c(1,3,6,14,15,16,21,22,23)]


var.no <- 7
total.vars <- 80
  
#cleaning - deal with % and make all numeric
vars$YTD<-as.numeric(sub("%","",vars$YTD))
vars<-vars[,-1]
vars$ER <-as.numeric(sub("%","",vars$ER))
vars[,6]<-as.numeric(sub("%","",vars[,6]))
vars[vars$P.E.Ratio=="n/a",7]=NA
vars[,7]=as.numeric(vars[,7])
vars <- vars[,-3]
vars[vars$Age == "-",3] <- NA
vars[vars$Beta == "n/a",7] <- NA


as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}
vars$Beta <- as.numeric.factor(vars$Beta)
as.numeric(levels(vars)[vars])

#when changing code for data. Change 1) 1200, number of vars here, 
#scale and standadize

#calc means of vars
means=c()
for(i in 1:var.no)
  vars[1:2000, i]=as.numeric(vars[1:2000,i])

for(i in 1:var.no)
  means[i]=mean(vars[1:2000,i], na.rm=TRUE)

sds=c()
for(i in 1:var.no)
  sds[i]=sd(vars[1:2000,i], na.rm=TRUE)

scaled.vars <- data.frame(scale(vars[,1:var.no]))

#need to add weights here

calc <- function(inputs, w, personal){
  weighted.scaled.vars <- data.frame(1:2000)
  scaled.vars.new <- data.frame(1:2000)
  
  for(i in 1:var.no){
    if(w[i]!=0){
      weighted.scaled.vars<-cbind(weighted.scaled.vars, scaled.vars[1:2000,i]*(w[i]*w[i]))
      scaled.vars.new<-cbind(scaled.vars.new, scaled.vars[1:2000,i])
    }
  }
  weighted.scaled.vars = weighted.scaled.vars[,-1]
  scaled.vars.new = scaled.vars.new[,-1]
  

  set.seed(10)

  weighted.scaled.vars[is.na(weighted.scaled.vars)] <- 0
  scaled.vars.new[is.na(scaled.vars.new)] <- 0
  k = (90*(sum(w)))  #need to improve cluster form
  model.kmeans <- kmeans(weighted.scaled.vars, k) 
  
  final.trained <- data.frame(model.kmeans$cluster, df[1:2000,]) #can change no of clusters

  #INPUTS
  #===============
  input.vals <- as.numeric(inputs)
  print(input.vals)
  input.weighted.scaled.new=c()
  input.weighted.scaled = (input.vals[1:var.no]-means[1:var.no])/sds[1:var.no]
  
  for(i in 1:var.no){
    if(w[i]!=0)
      input.weighted.scaled.new=c(input.weighted.scaled.new, input.weighted.scaled[i])
  }

  
  input.frame <- t(data.frame(input.weighted.scaled.new))

  #predict bucket
  knn.predict.input <- knn(scaled.vars.new, input.frame, model.kmeans$cluster, k=30)
  
  result <- final.trained[final.trained[,1]==knn.predict.input,]
  result <- result[,-c(1,8,18,19,20,24:41)]
  return(result)
}


optimizeResults <- function(results, personal) {
  maindb <- read.csv("/Users/Gaurab Bose/Desktop/InvestAI/data/maindb.csv", header=TRUE)
  
  rows <- nrow(results)
  yourage <- rep(personal[1], rows)
  yourincome <- rep(personal[2], rows)
  invgoals <- rep(personal[3], rows)
  new.rows <- data.frame(cbind(results, yourage, yourincome, invgoals))
  print(dim(new.rows))
  print(length(yourage))
  maindb2 <- rbind(maindb[,2:23], new.rows)
  
  print(dim(maindb2))
  print("hello")
  #remember to add new data back to csv file
  # UNHASH IT BACK!
  #write.csv(maindb2, file = "/Users/Gaurab Bose/Desktop/InvestAI/data/maindb.csv")
  #what to return back to button click
  
  
  subset.db <- maindb2[is.element(maindb2$Symbol, results$Symbol),]

  for(i in 1:nrow(subset.db)){
    if(identical(toString(subset.db$invgoals[i]), "Retirement Planning")){
      subset.db$RetirementPlanning[i] = 1
    }
    else{
      subset.db$RetirementPlanning[i] = 0
    }
    if(identical(toString(subset.db$invgoals[i]), "Life Events (i.e. College)")){
      subset.db$LifeEvents[i] = 1
    }
    else{
      subset.db$LifeEvents[i] = 0
    }
    if(identical(toString(subset.db$invgoals[i]), "Rainy Day Funds")){
      subset.db$RainyDay[i] = 1
    }
    else{
      subset.db$RainyDay[i] = 0
    }
  }
  
  k2 = 0.1 #no. in each cluster
  total.unique <- length(unique(subset.db$Symbol))
  print(dim(subset.db))
  scaled <- data.frame(scale(as.numeric(subset.db[,20])), scale(as.numeric(subset.db[,21])), as.numeric(subset.db[,23]), as.numeric(subset.db[,24]),as.numeric(subset.db[,24]))
  scaled[is.na(scaled)] <- 0
  model.kmeans2 <- kmeans(scaled, total.unique/k2) #change no of clusters
  final.trained2 <- data.frame(model.kmeans2$cluster, subset.db[,c(20,21,22)])
  print("kmeans done")
  if(identical(toString(personal[3]), "Retirement Planning")){
    personal[4] = 1
  } else {
    personal[4] = 0
  }
  if(identical(toString(personal[3]), "Life Events (i.e. College)")){
    personal[5] = 1
  } else {
    personal[5] = 0
   }
  
  if(identical(toString(personal[3]), "Rainy Day Funds")){
    personal[6] = 1
  } else {
    personal[6]=0
  }
  
  personal = personal[-3]
  print(personal)
  
  knn.predict.input <- knn(scaled, personal, model.kmeans2$cluster, k=30)
  print(knn.predict.input)
  combined <-data.frame(subset.db[,c(1,20,21,22)],model.kmeans2$cluster)
  result2 <- combined[combined$model.kmeans2.cluster==knn.predict.input,]
  result2.unique <- unique(result2$Symbol)
  return(result2.unique)
}

str <- "high yield"
str <- Corpus(DataframeSource(data.frame(str)))
str2 <- "highest yield"
str3 <- "high-yield"


stem_text<- function(text, language = "english", mc.cores = 1) {
  # stem each word in a block of text
  stem_string <- function(str, language) {
    str <- toString(tolower(str))
    str <- strsplit(x = str, split = c(" ", "-"))
    str <- wordStem(unlist(str), language = language)
    str <- paste(str, collapse = " ")
    return(str)
  }
  
  # stem each text block in turn
  x <- mclapply(X = text, FUN = stem_string, language, mc.cores = mc.cores)
  
  # return stemed text blocks
  return(unlist(x))
}
