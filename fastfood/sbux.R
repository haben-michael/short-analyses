## locations <- read.csv('directory.csv',stringsAsFactors=FALSE)
## locations <- subset(locations,Country=='US',select=c('Store.Number','Street.Address','City','State.Province','Longitude','Latitude'))

## downloaded <- read.table('fips.txt',stringsAsFactors=FALSE)[,1]

## for(j in 1:nrow(locations)) {
##     latitude <- locations$Latitude[j]; longitude <- locations$Longitude[j]; Store.Number <- locations$Store.Number[j]
##     ## print(Store.Number)
##     if (Store.Number %in% downloaded) next
##     query <- sprintf('https://geo.fcc.gov/api/census/area?lat=%.3f&lon=%.3f&format=xml',latitude,longitude)
##     response <- scan(query,what='',sep='\t',quiet=TRUE)
##     block.fips <- response[grep('block_fips',response)]
##     county.fips <- response[grep('county_fips',response)]
##     state.fips <- response[grep('state_fips',response)]
##     block.fips <- gsub('<[^>]+>','',block.fips)
##     county.fips <- gsub('<[^>]+>','',county.fips)
##     state.fips <- gsub('<[^>]+>','',state.fips)
##     write(paste(Store.Number,block.fips,county.fips,state.fips),'fips.txt',append=TRUE)
##     Sys.sleep(.1)
##     if(j%%100==0) print(j)
## }

## zips <- scan('US.txt',sep='\n',what='')
## zips <- unname(sapply(zips,function(line)strsplit(line,'\t')[[1]][[2]]))
## write(zips,'US_zips.txt',sep='\n')



## #--------------------
## stores <- read.table('fips.txt',stringsAsFactors=FALSE,colClasses='character',col.names=c('ID','block.fips','county.fips','state.fips'))
## stores <- stores[!duplicated(stores$ID),]
## stores$block.fips <- substr(stores$block.fips,1,12)
    
## income <- read.csv('nhgis0001_csv/nhgis0001_ds152_2000_blck_grp.csv',colClasses='character')
## ## income$block.fips <- with(income,paste0(STATEA,COUNTYA,TRACTA,sprintf('%0.4d',as.integer(BLCK_GRPA))))
## income$block.fips <- with(income,paste0(STATEA,COUNTYA,TRACTA,BLCK_GRPA))
## income <- subset(income,select=c('block.fips','HG4001'))

## data <- income
## data$store <- data$block.fips %in% stores$block.fips # not all store block fips among income block fips

## blocks <- merge(blocks,income,by.x='BKGPIDFP00',by.y='block.fips',all.x=FALSE,all.y=FALSE)

## require(maptools)

## blocks <- readShapeSpatial('tl_2010_06_bg00')
## ## plot(blocks[blocks$COUNTYFP00=='075',])
## blocks <- blocks[blocks$COUNTYFP00=='075',]
## blocks@data$BKGPIDFP00 <- as.character(blocks@data$BKGPIDFP00)

## slotNames(blocks)
## str(blocks@data)
## head(blocks@data)

## income <- read.csv('nhgis0001_csv/nhgis0001_ds152_2000_blck_grp.csv',colClasses='character')
## income <- subset(income, STATEA=='06' & COUNTYA=='075')
## income$block.fips <- with(income,paste0(STATEA,COUNTYA,TRACTA,BLCK_GRPA))

## blocks <- merge(blocks,income,by.x='BKGPIDFP00',by.y='block.fips',all.x=FALSE,all.y=FALSE)


## ## Next we clean up our joined data and process for plotting. This
## ## mainly uses things we've seen before, but note also "cut" and the
## ## color palettes.
## blocks@data <- subset(blocks@data,select=c('FIPS','name','unempl'))
## ## colnames(blocks@data) <- c('fips','name','unempl')
## blocks$unempl <- as.numeric(blocks$unempl)

## bins <- 10
## blocks$unempl.fac <- cut(blocks$unempl,bins)
## colors <- terrain.colors(bins)
## plot(blocks,col=colors[as.integer(blocks$unempl.fac)])
## title('US unemployment rate by county, 20??')
## legend('bottomright',col=colors,pch=16,legend=levels(blocks$unempl.fac))


## sbux

stores <- read.table('fips.txt',stringsAsFactors=FALSE,colClasses='character',col.names=c('ID','block.fips','county.fips','state.fips'))
stores <- stores[!duplicated(stores$ID),]
stores$tract.fips <- substr(stores$block.fips,1,11)
    
income <- read.csv('nhgis0004_csv/nhgis0004_ds176_20105_2010_tract.csv',colClasses='character')
## income$block.fips <- with(income,paste0(STATEA,COUNTYA,TRACTA,sprintf('%0.4d',as.integer(BLCK_GRPA))))
income$tract.fips <- with(income,paste0(STATEA,COUNTYA,TRACTA))
income <- subset(income,select=c('tract.fips','JQBM001'))

data <- data.frame(store=income$tract.fips %in% stores$tract.fips,income=as.integer(income$JQBM001),tract.fips=income$tract.fips)

glm0 <- glm(store ~ income, data=data, family=binomial)

race <- read.csv('nhgis0003_csv/nhgis0003_ds176_20105_2010_tract.csv',colClasses='character')
race$tract.fips <- with(race,paste0(STATEA,COUNTYA,TRACTA))
black_pct <- with(race,data.frame(tract.fips=tract.fips,black_pct=as.integer(JMBE003)/as.integer(JMBE001)))

data <- merge(data,black_pct,by.x='tract.fips',by.y='tract.fips',all=FALSE)
glm1 <- glm(store ~ income + black_pct, data=data, family=binomial)
summary(glm1)



## locations <- read.csv('sbux.csv',stringsAsFactors=FALSE)
## locations <- subset(locations,Country=='US',select=c('Store.Number','Street.Address','City','State.Province','Longitude','Latitude'))

## downloaded <- read.table('fips.txt',stringsAsFactors=FALSE)[,1]

## for(j in 1:nrow(locations)) {
##     latitude <- locations$Latitude[j]; longitude <- locations$Longitude[j]; Store.Number <- locations$Store.Number[j]
##     ## print(Store.Number)
##     if (Store.Number %in% downloaded) next
##     query <- sprintf('https://geo.fcc.gov/api/census/area?lat=%.3f&lon=%.3f&format=xml',latitude,longitude)
##     response <- scan(query,what='',sep='\t',quiet=TRUE)
##     block.fips <- response[grep('block_fips',response)]
##     county.fips <- response[grep('county_fips',response)]
##     state.fips <- response[grep('state_fips',response)]
##     block.fips <- gsub('<[^>]+>','',block.fips)
##     county.fips <- gsub('<[^>]+>','',county.fips)
##     state.fips <- gsub('<[^>]+>','',state.fips)
##     write(paste(Store.Number,block.fips,county.fips,state.fips),'fips.txt',append=TRUE)
##     Sys.sleep(.1)
##     if(j%%100==0) print(j)
## }



