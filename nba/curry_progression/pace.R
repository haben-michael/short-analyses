require(ggplot2)
require(gridExtra)
require(dplyr)

## 1. pace of scoring
csv.dir = 'd:/scrapes/basketball_reference/csv/'
csv.files <- dir(csv.dir)
csv.file <- csv.files[1]

scores <- read.csv(paste0(csv.dir,csv.file),header=F,stringsAsFactors=F)
colnames(scores) <- c('time','team','qtr','incr')
time <- strsplit(scores$time,':')
time <- sapply(time,function(t)60*as.numeric(t[[1]])+as.numeric(t[[2]]))
scores$time <- 12*60 - time
scores$time <- scores$time + (scores$qtr-1)*12*60
teams <- sort(unique(scores$team))
plot(cumsum(incr) ~ time, data=scores,type='o',ylab='cumulative combined score')

scores$cumscore.1 <- cumsum(scores$incr*(scores$team==teams[1]))
scores$cumscore.2 <- cumsum(scores$incr*(scores$team==teams[2]))

cumscores <- subset(scores,team==teams[1],select=c('time','incr','team'))
cumscores <- rbind(cumscores,subset(scores,team==teams[2],select=c('time','incr','team')))
cumscores <- arrange(cumscores,team,time)
cumscores.1 <- cumsum(cumscores$incr[cumscores$team==teams[1]])
cumscores.2 <- cumsum(cumscores$incr[cumscores$team==teams[2]])
cumscores$cumscore <- c(cumscores.1,cumscores.2)

ggplot(cumscores,aes(y=cumscore,x=time,color=team))+geom_line()

loess0 <- loess(cumscore ~ time, degree=1, data=subset(cumscores,team==teams[1]))
slopes <- with(subset(cumscores,team==teams[2]),
     diff(cumscore)/diff(time)
     )
slopes <- with(subset(cumscores,team==teams[1]),
     diff(loess0$fitted)/diff(time)
     )
plot(slopes,type='o')



## process csvs and plot
csv.dir = 'd:/scrapes/basketball_reference/csv/'
csv.files <- dir(csv.dir)

data <- lapply(1:length(csv.files), function(i) {
    csv.file <- csv.files[i]
    scores <- read.csv(paste0(csv.dir,csv.file),header=F,stringsAsFactors=F)
    colnames(scores) <- c('time','team','qtr','incr')
    time <- strsplit(scores$time,':')
    time <- sapply(time,function(t)60*as.numeric(t[[1]])+as.numeric(t[[2]]))
    scores$time <- 12*60 - time
    scores$time <- scores$time + (scores$qtr-1)*12*60
    teams <- sort(unique(scores$team))

    scores$cumscore.1 <- cumsum(scores$incr*(scores$team==teams[1]))
    scores$cumscore.2 <- cumsum(scores$incr*(scores$team==teams[2]))
    structure(scores,class=c('GameData','data.frame'),date=substr(csv.file,1,8))
})
save(data,file='data.RData')

plot.GameData <- function(scores) {
    teams <- sort(unique(scores$team))
    cumscores <- subset(scores,team==teams[1],select=c('time','incr','team'))
    cumscores <- rbind(cumscores,subset(scores,team==teams[2],select=c('time','incr','team')))
    cumscores <- arrange(cumscores,team,time)
    cumscores.1 <- cumsum(cumscores$incr[cumscores$team==teams[1]])
    cumscores.2 <- cumsum(cumscores$incr[cumscores$team==teams[2]])
    cumscores$cumscore <- c(cumscores.1,cumscores.2)

    ggplot(cumscores,aes(y=cumscore,x=time,color=team))+geom_line()+labs(title=attr(scores,'date'))

}
plts <- lapply(data[1:5],plot)
do.call(grid.arrange,plts)

## 2. streak length vs time of gam
csv.dir = 'd:/scrapes/basketball_reference/csv/'
data = load('data.RData')

data <- lapply(data,function(game.data) {
    game.data$streak.len = unlist(lapply(rle(game.data$team)$lengths, seq_len))
    game.data}
    )
plot(data[[1]]$streak.len,col=data[[1]]$team)

data.streak <- lapply(data,function(game.data)subset(game.data,select=c('time','streak.len')))
data.streak <- do.call(rbind,data.streak)
lm(streak.len ~ time, data=data.streak) %>% summary



## 3. Curry progression
require(gridExtra)
require(stringr)
require(ggplot2)
csv.dir = 'd:/scrapes/basketball_reference/csv/'
files <- dir(csv.dir)
files <- files[grep('curryst01',files)]

file <- files[1]
curry.data <- lapply(files, function(file) {
    year <- str_match(file,'([0-9]{4}).csv')[,2]
    year <- as.numeric(year)
    data <- read.csv(paste0(csv.dir,file),stringsAsFactors=F)
    header.idx <- which(data$G=='G')
    data <- data[-header.idx,]
    data <- data.frame(date=as.Date(data$Date),FGP=as.numeric(data$FG.),FGA=as.numeric(data$FGA),PTS=as.numeric(data$PTS))
    data
})
curry.data <- data.frame(do.call(rbind,curry.data))
## curry.data <- curry.data[order(curry.data$year,curry.data$G),]
curry.data <- na.omit(curry.data)
hiring.date <- as.Date('2011-06-06')
firing.date <- as.Date('2014-05-06')

plt1 <- ggplot(curry.data, aes(x=date, y=FGP)) + geom_point() + geom_smooth(method='loess') + geom_vline(xintercept=as.numeric(c(hiring.date,firing.date)),linetype=2) + annotate(geom='text',x=c(hiring.date+40,firing.date+40),y=.25,label=c('MJax hiring','MJax firing'),angle=90) + labs(title='S. Curry FG% versus game')
ggsave('062217a.png',plt1)

plt2 <- ggplot(curry.data, aes(x=date, y=FGA)) + geom_point() + geom_smooth(method='loess') + geom_vline(xintercept=as.numeric(c(hiring.date,firing.date)),linetype=2) + annotate(geom='text',x=c(hiring.date+40,firing.date+40),y=5,label=c('MJax hiring','MJax firing'),angle=90) + labs(title='S. Curry FGA versus game')
ggsave('062217b.png',plt2)

plt3 <- ggplot(curry.data, aes(x=date, y=PTS)) + geom_point() + geom_smooth(method='loess') + geom_vline(xintercept=as.numeric(c(hiring.date,firing.date)),linetype=2) + annotate(geom='text',x=c(hiring.date+40,firing.date+40),y=5,label=c('MJax hiring','MJax firing'),angle=90) + labs(title='S. Curry points versus game')
ggsave('062217c.png',plt3)


grid.arrange(plt2,plt2,plt3)
