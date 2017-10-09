##########################
# landings data
##########################

mfdb_import_cs_taxonomy(mdb,'index_type',data.frame(name='Landings'))

# read in data for gss landed catch
landedcatch <- read.csv('data/gss_landings.csv', header=T)
landedcatch <- rename(landedcatch,
                      year = ar,
                      month = man,
                      gear.type = veidarf)
landedcatch$gear.type <- 6 # treat all landings as bottom.trawl

source('initialize/gssLandedCatchLogbooks.R')
# source('initialize/gssLandedCatchSeaSamplingProps.R') #treating all landings as 
                                                        #bottom trawls, so not needed

landings <- 
    bmt.landings %>% 
    filter(areacell != -1818 & areacell != -1316) %>%
    arrange(year, month, areacell) %>%
    rename(weight = catch)

# for a more detailed analysis of landedcatch by areas, see
# ~/gadget/gadget-models/grSilverSmelt/initialize/gssCatchByArea.R

landings <- data.table(landings)


# import landings data into mfdb
mfdb_import_survey(mdb,
                   data_source = 'commercial.landings',
                   landings)

