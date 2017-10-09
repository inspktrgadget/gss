library(ggplot2)


## read in data from gssInitdb.R and igsSpringSurvey.R first
igfs.all <- 
    ldist %>%
    group_by(lat, lon) %>%
    summarize(total.count = sum(count))

igfs.all.plot <-
    ggplot(island, aes(x=lon, y=lat)) + geom_polygon() +
    geom_path(data = gbdypif.400$reg1, aes(x=lon, y=lat)) +
    geom_point(data=igfs.all, aes(x=lon, y=lat, size=total.count / 1000))

igfs.deep <- 
    ldist %>% 
    group_by(lat, lon) %>% 
    summarize(total.count = sum(count))

igfs.deep.plot <- 
    ggplot(island, aes(x=lon, y=lat)) + 
    geom_polygon() + 
    geom_point(data=igfs.deep, aes(x=lon, y=lat, size=total.count / 1000)) +
    geom_path(data=gbdypif.400$reg1, aes(x=lon, y=lat)) +
    geom_path(data=gbdypif.400$reg2, aes(x=lon, y=lat))