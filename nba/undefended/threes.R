require(ggplot2)
setwd('/gdrive/scripts/threes')

## 1. did players improve shooting undefended threes?

files <- dir('data/')
csvs <- files[grep('[0-9]{4}.csv$',files)]
csvs <- paste0('data/',csvs)

percents <- lapply(csvs,function(csv) {
    ## print(year)
    df <- read.csv(csv)
    made <- df$X.36
    made <- made[grep('^[0-9]+$',made)]
    attempted <- df$X.37
    attempted <- attempted[grep('^[0-9]+$',attempted)]
    made <- as.numeric(as.character(made)); attempted <- as.numeric(as.character(attempted))
    no.attempts <- which(attempted==0)
    made[-no.attempts]/attempted[-no.attempts]
})

years <- substr(csvs,76,79)
names(percents) <- years
percents <- percents[years>1997]
annual.means <- sapply(percents,mean)
png('062217a.png')
plot(names(annual.means),annual.means,xlab='year',ylab='three point percentage',main='Shooting percentages at all-star game 3-point shooting contest')
dev.off()
## clear trend


## 2. did free throw shooting improve?
csv.dir <- 'd:/scrapes/basketball_reference/csv/'
files <- dir(csv.dir)
files <- files[grep('NBA_[0-9]{4}_totals',files)]
files <- paste0(csv.dir,files)

FTP <- sapply(files,function(file) {
    print(file)
    data <- read.csv(file,stringsAsFactors=F)

    data <- data[data$Player!='Player',]
    with(data, sum(as.numeric(FT))/sum(as.numeric(FTA)))
})
names(FTP) <- substr(names(FTP),nchar(csv.dir)+5,nchar(csv.dir)+8)
png('062217b.png')
plot(names(FTP),FTP,xlab='year',ylab='free throw percentage',main='Leaguewide free-throw percentages')
dev.off()
## also a clear trend from the mid 90s. what is the cause of the dip in early 90s? did something happen also with 3pt, except no data on that.

## 3. look at histograms of ft%
csv.dir <- 'd:/scrapes/basketball_reference/csv/'
files <- dir(csv.dir)
files <- files[grep('NBA_[0-9]{4}_totals',files)]
files <- paste0(csv.dir,files)

FTP <- lapply(files,function(file) {
    data <- read.csv(file,stringsAsFactors=F)
    data <- data[data$Player!='Player',]
    as.numeric(data$FT.)
})
names(FTP) <- substr(files,nchar(csv.dir)+5,nchar(csv.dir)+8)

years <- c(2000,2004,2008,2012)
years <- 1990:1995
gg.df <- FTP[as.character(years)]
gg.df <- lapply(1:length(gg.df),function(i)data.frame(FTP=gg.df[[i]],year=names(gg.df)[i]))
gg.df <- do.call(rbind,gg.df)
ggplot(gg.df,aes(x=FTP))+geom_histogram()+facet_grid(year ~ .)

## 4. quantiles of ft%
csv.dir <- 'd:/scrapes/basketball_reference/csv/'
files <- dir(csv.dir)
files <- files[grep('NBA_[0-9]{4}_totals',files)]
files <- paste0(csv.dir,files)

FTP <- sapply(files,function(file) {
    data <- read.csv(file,stringsAsFactors=F)
    data <- data[data$Player!='Player',]
    quantile(as.numeric(data$FT.),na.rm=T,probs=c(.1,.25,.5,.75,.9,.95))
})
colnames(FTP) <- substr(files,nchar(csv.dir)+5,nchar(csv.dir)+8)

FTP <- t(FTP)
gg.df <- data.frame(FTP=as.numeric(FTP),year=rownames(FTP),quantile=gl(ncol(FTP),nrow(FTP),labels=colnames(FTP)))
ggplot(gg.df,aes(x=year,y=FTP,group=quantile,color=quantile))+geom_line()+geom_point()+theme(axis.text.x = element_text(angle = 90, hjust = 1))

## 5. variance of ft%
csv.dir <- 'd:/scrapes/basketball_reference/csv/'
files <- dir(csv.dir)
files <- files[grep('NBA_[0-9]{4}_totals',files)]
files <- paste0(csv.dir,files)

FTP <- sapply(files,function(file) {
    data <- read.csv(file,stringsAsFactors=F)
    data <- data[data$Player!='Player',]
    var(as.numeric(data$FT.),na.rm=T)
})
names(FTP) <- substr(files,nchar(csv.dir)+5,nchar(csv.dir)+8)
png('062217c.png')
plot(names(FTP),FTP,xlab='year',ylab='free throw percentage',main="variance of players' FT%")
dev.off()

## weighted by FTA
files <- files[(length(files)-30):length(files)]
FTP <- sapply(files,function(file) {
    data <- read.csv(file,stringsAsFactors=F)
    data <- data[data$Player!='Player',]
    w <- as.numeric(data$FTA)
    w <- w/sum(w)
    ftp <- as.numeric(data$FT.)
    mean.ftp <- mean(ftp,na.rm=T)
    mean(w*(ftp-mean.ftp)^2,na.rm=T)
})
names(FTP) <- substr(files,nchar(csv.dir)+5,nchar(csv.dir)+8)
png('062217d.png')
plot(names(FTP),FTP,xlab='year',ylab='free throw percentage',main="variance of players' FT% weighted by FTA")
dev.off()
## strong trend in unweighted case
