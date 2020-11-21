## chrome

html <- scan('http://www.oldversion.com/windows/google-chrome/',what='',sep='\n')

main <- html[which.max(sapply(html,nchar))]
main <- strsplit(main,'</tr>')[[1]]
sizes <- unlist(lapply(main[-1],function(row)strsplit(row,'</td>')[[1]][3]))
dates <- lapply(main[-1],function(row)strsplit(row,'</td>')[[1]][2])
idx <- (1:length(dates))[regexpr('Add info',dates)==-1]
sizes <- sizes[idx]; dates <- dates[idx]
sizes <- as.numeric(gsub('[^0-9\\.]','',sizes))
dates <- sub('<.+>','',dates)
dates <- as.Date(dates,format='%b %d, %Y')
bad.idx <- which(sizes>100)
sizes <- sizes[-bad.idx]; dates <- dates[-bad.idx]


html2 <- scan('https://www.slimjet.com/chrome/google-chrome-old-version.php',what='',sep='')

main <- paste(html2,collapse='')
start <- regexpr('<tbody>',main)
end <- regexpr('</tbody>',main)
table <- substr(main,start,end)
rows <- strsplit(table,'<tr>')[[1]]
sizes2 <- unlist(lapply(rows[-1],function(row)strsplit(row,'</td>')[[1]][2]))
sizes2 <- as.numeric(gsub('[^0-9\\.]','',sizes2))
dates2 <- unlist(lapply(rows[-1],function(row)strsplit(row,'</td>')[[1]][3]))
dates2 <- gsub('[^0-9-]','',dates2)
dates2 <- as.Date(dates2,format='%Y-%m-%d')
bad.idx <- which(sizes2<2)
sizes2 <- sizes2[-bad.idx]; dates2 <- dates2[-bad.idx]

data <- data.frame(date=c(dates,dates2),size=c(sizes,sizes2))
## png('200313.png')
plot(size ~ date, data=data,xlab='release date',ylab='chrome file size')
abline(lm(size ~ date, data=data))
## dev.off()
## save.image('200313.RData')


## firefox

html3 <- paste(scan('https://en.wikipedia.org/wiki/Firefox_early_version_history',what='',sep=''),collapse=' ')
tables <- strsplit(html3,'<table class=\"wikitable mw-collapsible mw-collapsed\"')[[1]]
starts <- regexpr('<tbody>',tables)
ends <- regexpr('</tbody>',tables)
tables <- substr(tables,starts,ends)
## table <- tables[2]
version.date <- lapply(tables,function(table) {
    tr.starts <- gregexpr('<tr>',table)[[1]]
    tr.ends <- gregexpr('</tr>',table)[[1]]
    rows <- substr(rep(table,length(tr.starts)),tr.starts,tr.ends)
    ## row <- rows[3]
    unname(lapply(rows,function(row) strsplit(row,'<td>')[[1]][c(2,4)]))
})
version.date <- do.call(rbind,(lapply(version.date,function(table)do.call(rbind,table))))
version.date <- na.omit(version.date)
version.date[,1] <- gsub('[^0-9\\.]','',version.date[,1])
version.date[,2] <- gsub(' </td> $','',version.date[,2])



html4 <- paste(scan('https://en.wikipedia.org/wiki/Firefox_version_history',what='',sep=''),collapse=' ')
tables <- strsplit(html4,'<table class=\"wikitable mw-collapsible mw-collapsed\"')[[1]]
starts <- regexpr('<tbody>',tables)
ends <- regexpr('</tbody>',tables)
tables <- substr(tables,starts,ends)
table <- tables[2]
version.date2 <- lapply(tables[-1],function(table) {
    tr.starts <- gregexpr('<tr>',table)[[1]]
    tr.ends <- gregexpr('</tr>',table)[[1]]
    rows <- substr(rep(table,length(tr.starts)),tr.starts,tr.ends)
    row <- rows[3]
    unname(lapply(rows,function(row) strsplit(row,'<td>')[[1]][c(2,3)]))
})
version.date2 <- do.call(rbind,(lapply(version.date2,function(table)do.call(rbind,table))))
version.date2 <- na.omit(version.date2)
version.date2[,1] <- gsub('[^0-9\\.]','',version.date2[,1])
version.date2[,2] <- gsub(' </td> $','',version.date2[,2])

versions <- c(version.date[,1],version.date2[,1])
dates <- as.Date(c(version.date[,2],version.date2[,2]),format='%B %d, %Y')
dates <- data.frame(version=versions,date=dates,stringsAsFactors=FALSE)

dirlist <- scan('https://ftp.mozilla.org/pub/firefox/releases/',what='',sep='\n')
dirlist <- dirlist[grep('/pub/firefox/releases',dirlist)][-(1:2)]
starts <- regexpr('href=\"',dirlist)
stops <- regexpr('\">',dirlist)
dirs <- substr(rep(dirlist,length(starts)),starts+nchar('href=\"'),stops-1)
dir <- dirs[10]
dirs <- unique(dirs)
dirs <- dirs[-(1:9)]
sizes <- lapply(dirs,function(dir) {
    print(dir)
    Sys.sleep(.2)
    tryCatch({
        filelist <- paste(scan(paste0('https://ftp.mozilla.org/',dir,'win32/en-US/'),what='',sep='\n'),collapse='')
        filelist <- strsplit(filelist,'<tr>')[[1]]
        filelist <- filelist[grep('.zip|.exe',filelist)]
        unname(sapply(filelist,function(file)strsplit(file,'<td>')[[1]][4]))},error=function(e)NA,warning=function(w)NA)
})
size <- sizes[[1]]

sizes <- sapply(sizes,function(size){
    size <- unname(sapply(size,function(str)gsub('[^0-9M]','',str)))
    size <- unname(sapply(size,function(str)gsub('M','000000',str)))
    size <- as.numeric(size)
})
sizes <- sapply(sizes,function(vv)max(vv))

versions <- gsub('/pub/firefox/releases/','',dirs)
versions <- gsub('/','',versions)
sizes <- data.frame(version=versions,size=sizes,stringsAsFactors=FALSE)

require(dplyr)
firefox <- left_join(dates,sizes,by='version')
firefox <- na.omit(firefox)
firefox <- subset(firefox,subset=size<7e7)
firefox$size <-firefox$size/1e6
plot(size ~ date,data=firefox)

load('200313.RData')
chrome <- data
## png('200315.png')
plot(size ~ date, data=chrome,xlab='release date',ylab='file size (MB)')
abline(lm(size ~ date, data=chrome))
points(size ~ date,data=firefox,col=2)
legend('topleft',legend=c('chrome','firefox'),pch=1,col=1:2)
## dev.off()
