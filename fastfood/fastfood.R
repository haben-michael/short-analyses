## 1. bring together scraped data

require(dplyr)

    
sbux <- read.table('scrapes/sbux_fips.txt',colClasses = 'character',col.names=c('ID','block.fips','county.fips','state.fips'))
sbux <- sbux[!duplicated(sbux$ID),]
sbux <- data.frame(restaurant='sbux', ID=sbux[,1], geo.ID=sbux[,2],stringsAsFactors=FALSE)
sbux <- sbux[,c(2,1,3)]

bk.kfc <- read.csv('scrapes/addresses.csv',colClasses='character',header=FALSE)
bk.kfc <- data.frame(ID=0:(nrow(bk.kfc)-1), restaurant=bk.kfc[,1],stringsAsFactors=FALSE)
geocoded <- read.csv('scrapes/geocoded_bk_kfc.csv',colClasses='character',header=FALSE)
colnames(geocoded) <- c('ID','geo.ID')
geocoded$ID <- as.integer(geocoded$ID)
bk.kfc <- left_join(bk.kfc,geocoded)
bk.kfc$ID[bk.kfc$restaurant=='kfc'] <- paste0('kfc-',1:sum(bk.kfc$restaurant=='kfc'))
bk.kfc$ID[bk.kfc$restaurant=='bk'] <- paste0('bk-',1:sum(bk.kfc$restaurant=='bk'))

subway <- read.csv('scrapes/geocoded_subway.csv',colClasses='character',header=FALSE,col.names=c('ID','geo.ID'))
subway$restaurant <- 'subway'

mcdonalds <- read.csv('scrapes/geocoded_mcdonalds.csv',colClasses='character',header=FALSE,col.names=c('ID','geo.ID'))
mcdonalds$restaurant <- 'mcdonalds'

restaurants <- rbind(mcdonalds,subway,sbux,bk.kfc)
restaurants$tract.fips <- substr(restaurants$geo.ID,1,11)

income <- read.csv('nhgis/nhgis0004_ds176_20105_2010_tract.csv',colClasses='character')
## income$block.fips <- with(income,paste0(STATEA,COUNTYA,TRACTA,sprintf('%0.4d',as.integer(BLCK_GRPA))))
income$tract.fips <- with(income,paste0(STATEA,COUNTYA,TRACTA))
income <- subset(income,select=c('tract.fips','JQBM001'))
income <- rename(income,income=JQBM001)

present <- lapply(unique(restaurants$restaurant), function(restaurant)income$tract.fips %in% restaurants$tract.fips[restaurants$restaurant==restaurant])
names(present) <- unique(restaurants$restaurant)
data <- cbind(income,do.call(cbind,present))
data$income <- as.numeric(data$income)

## for (restaurant in unique(restaurants$restaurant)) {
##     assign(restaurant,
##     data <- cbind(data,restaurant=get(restaurant))
## }
## data <- data.frame(store=income$tract.fips %in% stores$tract.fips,income=as.integer(income$JQBM001),tract.fips=income$tract.fips,stringsAsFactors=FALSE)


race <- read.csv('nhgis/nhgis0003_ds176_20105_2010_tract.csv',colClasses='character')
race$tract.fips <- with(race,paste0(STATEA,COUNTYA,TRACTA))
black_pct <- with(race,data.frame(tract.fips=tract.fips,black_pct=as.integer(JMBE003)/as.integer(JMBE001),stringsAsFactors=FALSE))
## data <- merge(data,black_pct,by.x='tract.fips',by.y='tract.fips',all=FALSE)
data <- left_join(data,black_pct)
## save.image('200404.RData')
## save.image('200407.RData')
## save.image('200411.RData')

## 2. analysis
load('200411.RData')

glm0 <- glm(sbux ~ income, data=data, family=binomial)
summary(glm0)

glm1 <- glm(sbux ~ income + black_pct, data=data, family=binomial)
summary(glm1)

glm2 <- glm(kfc ~ income + black_pct, data=data, family=binomial)
summary(glm2)

glm3 <- glm(bk ~ income + black_pct, data=data, family=binomial)
summary(glm3)

glm4 <- glm(subway ~ income + black_pct, data=data, family=binomial)
summary(glm4)

glm5 <- glm(mcdonalds ~ income + black_pct, data=data, family=binomial)
summary(glm5)

restaurants <- colnames(data)[!(colnames(data) %in% c('tract.fips','income','black_pct'))]
coefs <- sapply(restaurants, function(restaurant) {
    glm0 <- glm(as.formula(paste0(restaurant,' ~ income + black_pct')), data=data, family=binomial)
    coef(glm0)
})
png('200411.png')
plot(coefs['income',],coefs['black_pct',],xlab='coefficient on income',ylab='coefficient on black percentage')
text(coefs['income',],coefs['black_pct',]-.05,labels=restaurants)
dev.off()
