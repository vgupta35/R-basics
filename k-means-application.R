install.packages("ggplot2")
install.packages("tidyr")

library(readxl)
library(tidyr)
library(ggplot2)

path <- ("C:\\Users\\vgupta\\OneDrive - Navigant Consulting Inc\\Documents\\Scotia\\Peer Group\\export_CA02_JUNE2018.xlsx")

RawData <- read_excel(path, sheet = 1)

summary(RawData)

vector <- c(1:100)

kmeans_output <- do.call("rbind", lapply(vector, FUN = function(k){ 
  df = RawData[,2:3]
  cluster <- kmeans(df, centers = k)
  as.data.frame(matrix(c(k,cluster$tot.withinss,cluster$betweenss), 
      nrow = 1, dimnames = list(NULL, c("k","withinss","betweenss"))))
  }))

# Plot single Variable
ggplot(kmeans_output, aes(x=k, y=log(withinss))) + geom_point() + xlab('k') #+ geom_smooth(se = FALSE)
ggplot(kmeans_output, aes(x=k, y=log(betweenss))) + geom_point() + xlab('k')

# Plot multiple variables via tranpose
kmeans_tranpose <- gather(kmeans_output, measure, value, c(withinss,betweenss))

ggplot(kmeans_tranpose, aes(x = k, y = log(value), colour = measure)) + 
  geom_point() + xlab('k')

?mgcv::gam
