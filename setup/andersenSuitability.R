## testing the andersen suitabilty function to understand parameters
## using greater silver smelt as the example
library(mfdb)
library(dplyr)
library(ggplot2)

# open connection to mareframe database
mdb <- mfdb('Iceland')

# define the andersen suitability function
asf <- function(p0,p1,p2,p3,p4,L,l) {
    if (log(L/l) <= p1) {
        s <- p0 + (p2*exp(-((log(L/l)-p1)^2)/p4));
    }
    else {s <- p0 + (p2*exp(-((log(L/l)-p1)^2)/p3))}
    return(s)
}

# set up and plot curves to explore function paramters 
ijksuits <- data.frame(NULL);
for (i in 1:10) {
    jksuits <- data.frame(NULL);
    for (j in 10:15) {
        ksuits <- NULL;
        for (k in 10:15) {
            suit <- asf(0,i,1,j,k,100,1:100);
            suits <- data.frame(suitability=suit, p1=i, p3=j, p4=k,L=100, l=1:100)
            ksuits <- rbind(ksuits, suits);
        }
        jksuits <- rbind(ksuits, jksuits);
    }
    ijksuits <- rbind(ijksuits, jksuits);
}

ggplot(ijksuits, aes(x=l, y=suitability, color=p1)) + 
    geom_point() +
    facet_wrap(~p3 + p4)
    

# fetch gss data and fit the function to the data
## Query length data to create survey catchdistribution components
minlength <- 1
maxlength <- 58
reitmapping <- read.table(
    system.file("demo-data", "reitmapping.tsv", package="mfdb"),
    header=TRUE,
    as.is=TRUE)

defaults <- list(   
    area = mfdb_group("1" = unique(reitmapping$DIVISION)),
    timestep = mfdb_timestep_yearly,
    year = 1982:2015,
    species = 'GSS')

spr.data <- mfdb_sample_count(mdb, c('age', 'length'), c(list(
    sampling_type = 'IGFS',
    species = defaults$species,
    length = mfdb_interval("len", seq(0, maxlength, by = 1))),
    defaults))

spr.data <- mutate(spr.data[[1]], length=substr(length,4,5))
spr.data <- mutate(spr.data, length=as.numeric(length))
sdat.lng <- 
spr.ldist <- spr.data %>% group_by(length) %>% summarize(n=n()) %>% mutate(prop=n / sum(n))






