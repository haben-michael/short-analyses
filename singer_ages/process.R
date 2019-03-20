data <- read.csv('data2.csv',header=FALSE)
colnames(data) <- c('song','year','birth.year','artist')
data <- data[,c(1,4,2,3)]
data$age <- data$year - data$birth.year
plot(age ~ year, data=data)
## png('fig2.png')
plot(aggregate(age ~ year, data=data, mean))
## dev.off()
## plot(aggregate(age ~ year, data=data, max))
png('fig1.png')
## boxplot(age ~ year, data=data)
dev.off()
boxplot(age ~ year, data=data[data$artist!='Elvis Presley',])

plot(aggregate(artist ~ year, data=data, function(x)length(unique(x))))
