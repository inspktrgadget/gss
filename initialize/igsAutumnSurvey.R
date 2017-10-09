##########################
# autumn survey
##########################

stations <-
    subset(translate.stodvar(), sampling.type == 35, ## spring survey 30
                      select = c(sample.id,year,month,lat,lon,gear.type,depth)) %>%
    left_join(mapping) %>%
    filter(lat < 66 & lon < -14.5) %>%
    group_by(sample.id) %>%
    mutate(month = 10,
           areacell = d2sr(lat,lon),
           sampling_type = 'AUT') %>%
    filter(!is.na(areacell))

# Import length distribution from autumn survey
ldist <- translate.all.le() %>%
    filter(sample.id %in% stations$sample.id &
               species.code %in% species.key$species.code) %>%
    group_by(sample.id,species.code) %>%
    left_join(stations) %>%
    left_join(species.key) %>%
    left_join(translate.all.nu()) %>%
    filter(year >= 2000) %>%
    mutate(count=round(count*pmax(number.counted+number.measured,1,na.rm=TRUE)/
                           pmax(1,number.measured,na.rm=TRUE)),
           sex = c('M','F')[pmax(1,sex)],
           age = 0,
           maturity_stage = pmax(1,pmin(maturity,2))) %>%
    ungroup() %>%
    mutate(number.measured = NULL,
           number.measured = NULL,
           catch=NULL,
           station.wt = NULL,
           species.code = NULL,
           gear.type = NULL)

ldist <- data.table(ldist)

mfdb_import_survey(mdb,
                   data_source = 'iceland-ldist.aut',
                   ldist)
rm(ldist)

# import age-length frequencies from the autumn survey
aldist <- translate.all.kv() %>%
    filter(sample.id %in% stations$sample.id &
               species.code %in% species.key$species.code) %>%
    group_by(sample.id, species.code) %>%
    left_join(stations) %>%
    left_join(species.key) %>%
    filter(year >= 2000) %>%
    mutate(count=1,
           areacell = d2sr(lat,lon),
           sex = c('M','F')[pmax(1,sex)],
           month = 10,
           maturity_stage = pmax(1,pmin(maturity,2))) %>%
    filter(!is.na(areacell)) %>%
    ungroup() %>%
    mutate(maturity=NULL,
           species.code = NULL,
           gear.type = NULL) %>%
    rename(weight = ungutted.wt)

aldist <- data.table(aldist)

mfdb_import_survey(mdb,
                   data_source = 'iceland-aldist.aut',
                   aldist)
rm(aldist)

# # import weights and compute length~weight relationship
# biomass.fit.aut <- 
#     translate.all.kv() %>%
#     filter(sample.id %in% stations$sample.id &
#                species.code %in% species.key$species.code &
#                !is.na(ungutted.wt)) %>%
#     mutate(wt.kilo=ungutted.wt/1e3) %>%
#     nls(wt.kilo ~ a*length^b, ., start=c(a=1e-05, b=3)) %>%
#     coef(nls)
# a <- biomass.fit.aut[1]
# b <- biomass.fit.aut[2]
# 
# biomass.aut <-
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
#            sampling_type = 'AUT',
#            month = 10,
#            species = 'GSS') %>%
#     select(sample.id, species, sampling_type, year, month, areacell, gear, length, weight)
# 
# biomass.aut <- data.table(biomass.aut)
# 
# mfdb_import_survey(mdb,
#                    data_in = biomass.aut,
#                    data_source = 'iceland-biomass.aut')
# 
# rm(biomass.fit.aut)
# rm(biomass.aut)
