require(dplyr)
require(tidyr)
require(ggplot2)
require(ggrepel)
data <- read.csv('Most_Popular_Baby_Names_by_Sex_and_Mother_s_Ethnic_Group__New_York_City.csv')
data$Ethnicity[data$Ethnicity=='ASIAN AND PACI'] = 'ASIAN AND PACIFIC ISLANDER'
data$Ethnicity <- plyr::revalue(data$Ethnicity, c('ASIAN AND PACI'='ASIAN AND PACIFIC ISLANDER','BLACK NON HISP'='BLACK NON HISPANIC','WHITE NON HISP'='WHITE NON HISPANIC'))
data$Ethnicity <- droplevels(data$Ethnicity)
data$Ethnicity <- plyr::revalue(data$Ethnicity, c('ASIAN AND PACIFIC ISLANDER' = 'A','BLACK NON HISPANIC'='B','WHITE NON HISPANIC'='W','HISPANIC'='H'))
data$Gender <- plyr::revalue(data$Gender, c('MALE'='M','FEMALE'='F'))
data <- plyr::rename(data,c('Year.of.Birth'='year','Gender'='sex','Ethnicity'='race','Child.s.First.Name'='name','Rank'='rank','Count'='count'))
xtabs( ~ year + race, data=data)
nrow(data)
data$name <- tolower(data$name)
data <- unique(data)
data <- arrange(data,race,year,rank)
## data <- split(data,data$Ethnicity)
head(subset(data,year==2014 & race=='W' & sex=='M'),60)

df1 <- subset(data,year==2014 & race=='W' & sex=='M')
df2 <- subset(data,year==2011 & race=='W' & sex=='M')
cor.names <- function(df1,df2) {
    df <- inner_join(df1,df2,by=c('name'='name'))
    cor(df$rank.x,df$rank.y)
}

cor.names(subset(data,year==2011 & race=='W' & sex=='M'),
          subset(data,year==2011 & race=='B' & sex=='M'))


## data <- subset(data,rank<=30)
## very different plots with different rank limits

races <- unique(data$race)
race.pairs <- t(apply(combn(4,2),2,function(r)races[r]))
cors.by.race <- lapply(c('M','F'), function(s) {
    cors <- matrix(nrow=nrow(race.pairs),ncol=4)
    colnames(cors) <- unique(data$year)
    for(i in 1:nrow(cors))
        for(y in unique(data$year))
            cors[i,as.character(y)] <- cor.names(subset(data,year==y & race==race.pairs[i,1] & sex==s),
                                                 subset(data,year==y & race==race.pairs[i,2] & sex==s))
    data.frame(races=apply(race.pairs,1,paste,collapse='-'),year=cors) %>% gather(key=year,value=correlation,-races)
})

gg.df <- rbind(data.frame(cors.by.race[[1]],sex='boys'),data.frame(cors.by.race[[2]],sex='girls'))
gg.df$year <- as.numeric(gsub('year.','',gg.df$year))
png('171018.png')
ggplot(gg.df,aes(x=year,y=correlation,group=races)) + geom_point() + geom_line() + theme_classic() + geom_text_repel(data=subset(gg.df,year==2012),aes(year,correlation,label=races)) + facet_wrap( ~ sex)
dev.off()
## for male, correlations in two groups, and hispanics correlate with others; things more mixed for females
