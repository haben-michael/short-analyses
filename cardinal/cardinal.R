require(ggplot2)
require(dlyr)

bb <- read.csv('cardinalbb.csv')
fb <- read.csv('cardinalfb.csv')
bb$season <- substr(as.character(bb$Season),1,4)
gg.df <- rbind(select(bb,season,pct=W.L.), select(fb,season=Year,pct=Pct))
gg.df$season <- as.numeric(gg.df$season)
gg.df$sport <- rep(c('bb','fb'),c(nrow(bb),nrow(fb)))
ggplot(subset(gg.df, season>=1960), aes(x=season,y=pct,color=sport)) + geom_point() + geom_smooth()
ggsave('112917.png')
