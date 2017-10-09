library(tidyr)
library(dplyr)
library(fjolst)
library(fjolstTranslate)

setwd('~/gadget/gadget-models/grSilverSmelt')

## spring surveys - using these initially because good age data does not exist
## for catches until fishery is well establisheds
spr.stations <-
    translate.stodvar() %>%
    filter(sampling.type %in% c(30))

# read in age data
c.age.spr <- 
    translate.all.kv() %>%
    filter(species.code == 19, sample.id %in% spr.stations$sample.id) %>%
    left_join(spr.stations)

c.early <- 
    filter(c.age.spr, year %in% 1985:1989) %>% 
    group_by(year, age) %>%
    summarize(catch = sum(number, na.rm=T))

# plot catch at age
catch.plot <-
    ggplot(data=c.early, aes(x=age, y=catch, color=factor(year))) + 
    geom_line()

# plot log catch at log age
log.catch.plot <-
    ggplot(data=c.early, aes(x=log(age), y=log(catch), color=factor(year))) + 
    geom_line()


# take the catches difference betweened age
f.age <- 1:21
l.age <- 2:22
c.tab <- 
    c.early %>%
    spread(age, catch)
c.tab <- as.matrix(c.tab)
c.tab <- c.tab[,2:23]
c.diff <- log(c.tab[ ,f.age]) - log(c.tab[ ,l.age])
c.diff <- as.data.frame(c.diff)
c.diff$year <- 1985:1989
c.diff.long <- melt(c.diff, id='year')
c.diff.long$age <- as.numeric(as.character(c.diff.long$variable))

# plot log annual differences in catch at age
# things are all over the map - indicates to me that mortality is probably 
# very low, which makes sense as this is a long-lived fish
log.diff.plot <-
    ggplot(data=c.diff.long, aes(x=age, y=value, color=factor(year))) +
    geom_line() + facet_wrap(~year)


#################################################
## now trying this out with some actual catches
#################################################
# use only commercial catch samples
sea.stations <- 
    translate.stodvar() %>% filter(sampling.type %in% c(1,8))

# get age data from commercial catch samples and calculate age proportion
c.age.sea <-
    translate.all.kv() %>%
    filter(species.code == 19, sample.id %in% sea.stations$sample.id) %>%
    left_join(sea.stations) %>%
    group_by(year, age) %>%
    summarize(total = sum(number, na.rm=T)) %>%
    mutate(age.prop = total / sum(total))

# read in annual landings data
gss.landings <- 
    read.csv('data/gss_landings.csv', header=T) %>%
    rename(year = ar) %>%
    group_by(year) %>%
    summarize(ann.catch = sum(catch))

# calculate catch by age and year
catch.ay <- 
    left_join(c.age.sea, gss.landings) %>%
    mutate(catch.age = ann.catch*age.prop) %>%
    select(year, age, catch.age)


# subset desired years
cay.mid <- filter(catch.ay, year %in% 2006:2010)

ggplot(cay.mid, aes(x=age, y=log(catch.age))) + 
    geom_line() + facet_wrap(~year) + xlim(c(0,30))

z.mid <- spread(cay.mid, age, catch.age)
z.mid <- as.matrix(z.mid[,4:15])
z.diff <- log(z.mid[,1:(ncol(z.mid)-1)]) - log(z.mid[,2:ncol(z.mid)])
z.df <- data.frame(z.diff)
colnames(z.df) <- as.character(5:15)
z.df$year <- 2006:2010
z.df.long <- melt(z.df, id='year')
z.df.long$age <- as.numeric(as.character(z.df.long$variable))
z.plot <- 
    ggplot(z.df.long, aes(x=age, y=value, color=factor(year))) + geom_line()

mn.z <- apply(z.diff, 2, mean)
ages <- 5:15

# plotting regression of ln(Cay) against age for 9-15 year olds
cay.old <- filter(cay.mid, age > 8, age < 16)

cay.old.plot <-
    ggplot(cay.old, aes(x=age, y=log(catch.age))) + geom_point() + facet_wrap(~year)
    
ann.z <- NULL
for (i in unique(cay.old$year)) {
    z <- coef(lm(log(catch.age) ~ age, filter(cay.old, year == i)))[2]
    names(z) <- i
    ann.z <- c(ann.z, z)
}
ann.z.df <- data.frame(year = as.integer(as.character(attr(ann.z, 'names'))), 
                       z = abs(ann.z))
mn.z <- mean(ann.z)

## attempting to plot Z against effort to obtain an estimate of M
# there is a negative pattern here!!
effort <- 
    translate.all.kv() %>%
    filter(species.code == 19, sample.id %in% sea.stations$sample.id) %>%
    left_join(sea.stations) %>%
    filter(year %in% 2006:2010) %>%
    group_by(year, sample.id) %>%
    summarize(n = n()) %>%
    group_by(year) %>%
    summarize(n = n())
    
effort <- 
    translate.botnv() %>%
    select(year, fishing.month, fishing.day, trawl.time,
           gr.silver.smelt) %>%
    filter(year %in% 2006:2010, gr.silver.smelt > 0) %>%
    group_by(year) %>%
    summarize(effort = sum(trawl.time, na.rm=T)) %>%
    left_join(ann.z.df)
    
    
    
    
    
    
    
