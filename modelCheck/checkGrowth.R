library(plyr)
library(dplyr)
library(ggplot2)
library(mfdb)

# read in necessary objects in order to pull data
mdb <- mfdb('Iceland')
reitmapping <- read.table(
    system.file("demo-data", "reitmapping.tsv", package="mfdb"),
    header=TRUE,
    as.is=TRUE)
subdiv <- c(1011, 1012, 1013, 1014, 1015, 1022, 1023, 1061,
            1071, 1081, 1082, 1091, 1092, 1093, 1094, 1095, 1101, 1132, 1141, 
            1142, 1143, 1144, 1145, 1146, 1151)
st.year <- 1975
end.year <- 2015
defaults <- list(   
    area = mfdb_group("1" = subdiv),
    timestep = mfdb_timestep_quarterly,
    year = st.year:end.year,
    species = 'GSS')

## read in data
mla <- mfdb_sample_meanlength_stddev(mdb, c('age'),
                                     c(list(sampling_type=c("IGFS","AUT"),
                                            age=1:30), # got 30 from ICES 2013. Report on the workshop on age estimation of deep water species
                                       defaults))
temp <- mutate(mla[[1]], se = stddev / sqrt(number), ci = 1.96*se)

# plot growth data
gr.plot <-
    ggplot(temp, aes(age, mean)) + geom_point() + 
    geom_errorbar(aes(ymax=mean+ci, ymin=mean-ci, width = 0)) + 
    facet_wrap(~year) + xlab('Age') + ylab('Length')

## read in model data
library(Rgadget)
setwd('~/gadget/gadget-models/grSilverSmelt/gssModel')
main <- Rgadget:::read.gadget.main('main')
stocks <- Rgadget:::read.gadget.stockfiles(main$stockfiles)
params <- read.gadget.parameters('WGTS/params.final')
stock.growth <- Rgadget:::get.gadget.growth(stocks, params, age.based=T)

## growth plot facetted by years
gr.plot + geom_line(data=stock.growth, aes(x=age, y=length))

## overall growth plot
overall.growth <-
    ggplot(temp, aes(age, mean)) + geom_point() + 
    geom_errorbar(aes(ymax=mean+ci, ymin=mean-ci, width = 0)) +
    geom_line(data=stock.growth, aes(x=age, y=length))