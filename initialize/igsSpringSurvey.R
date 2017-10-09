##########################
# spring survey
##########################

# set up the stations from the spring survey
stations <-
    data.table(subset(translate.stodvar(), sampling.type == 30, ## autumn survey 35
                      select = c(sample.id,year,month,lat,lon,gear.type, depth))) %>%
    left_join(data.table(mapping)) %>%
    filter(lat < 66 & lon < -14.5) %>%
    group_by(sample.id) %>%
    mutate(month = 3,
           areacell = d2sr(lat,lon),
           sampling_type = 'IGFS') %>%
    filter(!is.na(areacell))

## Import length distribution from spring survey
ldist <- translate.all.le() %>%
    filter(sample.id %in% stations$sample.id &
               species.code %in% species.key$species.code) %>%
    group_by(sample.id,species.code) %>%
    left_join(stations) %>%
    left_join(species.key) %>%
    left_join(translate.all.nu()) %>%
    mutate(count=round(count*pmax(number.counted+number.measured,1,na.rm=TRUE)/
                           pmax(1,number.measured,na.rm=TRUE)),
           sex = c('M','F')[pmax(1,sex)],
           age = 0,
           maturity_stage = pmax(1,pmin(maturity,2))) %>%
    ungroup() %>%
    mutate(number.measured = NULL,
           number.counted = NULL,
           catch=NULL,
           station.wt = NULL,
           species.code = NULL,
           gear.type = NULL)           

ldist <- data.table(ldist)

mfdb_import_survey(mdb,
                   data_source = 'iceland-ldist.igfs',
                   ldist)
rm(ldist)

## Import age - length frequencies from the spring survey
aldist <- translate.all.kv() %>%
    filter(sample.id %in% stations$sample.id &
               species.code %in% species.key$species.code) %>%
    group_by(sample.id,species.code) %>%
    left_join(stations) %>%
    left_join(species.key) %>%
    mutate(count=1,
           areacell = d2sr(lat,lon),
           sex = c('M','F')[pmax(1,sex)],
           sampling_type = 'IGFS',
           month = 3,
           maturity_stage = pmax(1,pmin(maturity,2))) %>%
    rename(weight = ungutted.wt,
           gutted = gutted.wt) %>%
    filter(!is.na(areacell)) %>%
    ungroup()

aldist <- data.table(aldist)

mfdb_import_survey(mdb,
                   data_in=aldist,
                   data_source = 'iceland-aldist.igfs')
rm(aldist)

# # import weights and compute length~weight relationship
# biomass.fit.igfs <- 
#     translate.all.kv() %>%
#     filter(sample.id %in% stations$sample.id &
#                species.code %in% species.key$species.code &
#                !is.na(ungutted.wt)) %>%
#     mutate(wt.kilo=ungutted.wt/1e3) %>%
#     nls(wt.kilo ~ a*length^b, ., start=c(a=1e-05, b=3)) %>%
#     coef(nls)
# a <- biomass.fit.igfs[1]
# b <- biomass.fit.igfs[2]
# 
# biomass.igfs <-
#     translate.all.nu() %>%
#     filter(species.code == 19) %>%
#     mutate(total=ifelse(number.counted > 1,
#                         number.counted + number.measured,
#                         ifelse(number.counted == 0,
#                                number.measured, 0))) %>%
#     mutate(p = number.measured / total) %>%
#     filter(sample.id %in% stations$sample.id) %>%
#     left_join(translate.all.le()) %>%
#     group_by(sample.id, length) %>%
#     mutate(biomass = (count*(a*length^b)) / p) %>%
#     mutate(biomass = replace(biomass, is.na(biomass), 0)) %>%
#     ungroup() %>% group_by(sample.id, length) %>%
#     summarize(weight = sum(biomass)) %>%
#     left_join(stations) %>%
#     mutate(areacell = d2sr(lat,lon),
#            sampling_type = 'IGFS',
#            month = 3,
#            species = 'GSS') %>%
#     select(sample.id, species, sampling_type, year, month, areacell, gear, length, weight)
# 
# biomass.igfs <- data.table(biomass.igfs)
# 
# mfdb_import_survey(mdb,
#                    data_in = biomass.igfs,
#                    data_source = 'iceland-biomass.igfs')
# 
# rm(biomass.fit.igfs)
# rm(biomass.igfs)