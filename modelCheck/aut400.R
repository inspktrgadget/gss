library(ggplot2)
data(gbdypi.400)

## read in data from gssInitdb.R and igsAutumnSurvey.R first filtering 
## stations with and without depth > 400 for deep and all data
aut.all <- 
    ldist %>%
    group_by(lat, lon) %>%
    summarize(total.count = sum(count))

aut.all.plot <-
    ggplot(island, aes(x=lon, y=lat)) + geom_polygon() +
    geom_path(data = gbdypif.400$reg1, aes(x=lon, y=lat)) +
    geom_point(data=aut.all, aes(x=lon, y=lat, size=total.count / 1000))

aut.deep <- 
    ldist %>% 
    group_by(lat, lon) %>% 
    summarize(total.count = sum(count))

aut.deep.plot <- 
    ggplot(island, aes(x=lon, y=lat)) + 
    geom_polygon() + 
    geom_point(data=aut.deep, aes(x=lon, y=lat, size=total.count / 1000)) +
    geom_path(data=gbdypif.400$reg1, aes(x=lon, y=lat)) +
    geom_path(data=gbdypif.400$reg2, aes(x=lon, y=lat))