message('Loading Packages')
library(rvest)
library(tidyverse)
library(mongolite)

message('Scraping Data')
url<-"https://www.iqair.com/indonesia/jakarta"
aqi1 <- read_html(url) %>% html_nodes("table") %>% .[[1]] %>% html_table()
aqi2 <- read_html(url) %>% html_nodes("table") %>% .[[4]] %>% html_table()
aqi1_1 <- t(aqi1[,2])
colnames(aqi1_1)<-as.vector(aqi1[,1])$X1
rownames(aqi1_1)<-NULL
aqi2_2 <- aqi2
data<-data.frame(Waktu=Sys.time(),Kota="Jakarta")
data2<-cbind(data,aqi1_1,aqi2_2)
data2$`Air quality index`<-as.numeric(gsub('[A-Z]',"",data2$`Air quality index`))
data2$Temperature<-as.numeric(gsub('[[:punct:]]+[[:alpha:]]',"",data2$Temperature))
data2$Humidity<-as.numeric(gsub('[[:punct:]]',"",data2$Humidity))
data2$Wind<-as.numeric(gsub('[^0-9.]',"",data2$Wind))
data2$Pressure<-as.numeric(gsub('[a-z]',"",data2$Pressure))
colnames(data2)<-c("time","city","weather","temperature","humidity","wind","pressure","pollution_level","aqi","main_pollutant")

#MONGODB
message('Input Data to MongoDB Atlas')
atlas_conn <- mongo(
  collection = Sys.getenv("ATLAS_COLLECTION"),
  db         = Sys.getenv("ATLAS_DB"),
  url        = Sys.getenv("ATLAS_URL")
)

atlas_conn$insert(data2)
rm(atlas_conn)