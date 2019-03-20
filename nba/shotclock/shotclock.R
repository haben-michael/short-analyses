## Relation between shot success and length of possession at the time of the attempt.

require(ggplot2)
require(stringr)

csv.dir <- 'd:/scrapes/basketball_reference/csv/games/'
filenames <- dir(csv.dir)

data <- lapply(filenames, function(filename) {
    game.data <- read.csv(paste0(csv.dir,filename),header=FALSE,stringsAsFactors=FALSE)
    colnames(game.data) <- c('time','team','qtr','comment')
    game.data$new.possession <- c(TRUE,game.data$team[-1] != game.data$team[-length(game.data$team)])
    ## game.data$time <- as.Date(game.data$time,format='%H:%M.0')
    ## which(diff(game.data$qtr)!=0)
    times <- str_match(game.data$time,'([0-9]+):([0-9]+)')
    game.data$time <- 60*as.numeric(times[,2]) + as.numeric(times[,3])
    origin.times <- game.data$time[game.data$new.possession]
    offsets <- rep(origin.times,rle(game.data$team)$lengths)
    game.data$elapsed <- abs(game.data$time - offsets)
    made.idx <- grep('makes [23]-pt',game.data$comment)
    made.type <- str_match(game.data[made.idx,'comment'], '((2|3))-pt shot')[,2]
    made.elapsed <- diff(game.data$time)[made.idx-1]
    missed.idx <- grep('misses [23]-pt',game.data$comment)
    missed.type <- str_match(game.data[missed.idx,'comment'], '((2|3))-pt shot')[,2]
    missed.elapsed <- diff(game.data$time)[missed.idx-1]
    ## missed.elapsed <- with(game.data, diff(game.data$time)[grep('misses [23]-pt',comment)-1])

    ## hist(made.elapsed)
    ## boxplot(made.elapsed,missed.elapsed)
    ## hist(missed.elapsed)
    team.names <- unique(game.data$team)
    team.names <- paste(substr(gsub(' ','',team.names[team.names!='']), 1, 3),collapse='-')
    date <- as.Date(substr(filename,1,8),format='%Y%m%d')

    df <- data.frame(offset=abs(c(made.elapsed,missed.elapsed)), outcome=rep(c('made','missed'),c(length(made.elapsed),length(missed.elapsed))), type=as.integer(c(made.type,missed.type)), game.id=paste0(team.names,'-',substr(filename,1,9)), date=date)
})


## e.g., in 200311120BOS: clock seems to be reset, removing outliers manually for now
## 9:45.0	 	 	50-46	 	Personal foul by J. Rose
## 8:37.0	 	 	50-46	 	M. James misses 3-pt shot from 22 ft

data <- do.call(rbind, data)

boxplot(offset ~ outcome, data=subset(data,offset<=32))
ggplot(subset(data,offset<=32), aes(x=offset, group=outcome, fill=outcome)) + geom_histogram(position='dodge') + theme_classic() + scale_fill_grey()
ggsave('041618a.png')
## the statisticians seemed to be rounding the time of shot to nice numbers (0, 5, 15)
ggplot(subset(data,offset<=32 & date>as.Date('2002-01-01')), aes(x=offset, group=outcome, fill=outcome)) + geom_histogram(position='dodge') + theme_classic() + scale_fill_grey() + facet_grid( ~ type)
ggsave('041618b.png')
