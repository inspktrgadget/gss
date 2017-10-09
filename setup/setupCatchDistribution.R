minage <- Rgadget:::getMinage(gm)
maxage <- Rgadget:::getMaxage(gm)
maxlength <- 58 #max(Rgadget:::getLengthgroups(gm))

## Query length data to create survey catchdistribution components
aggdata <- mfdb_sample_count(mdb, c('age', 'length'), c(list(
    sampling_type = 'IGFS',
    species = defaults$species,
    length = mfdb_interval("len", seq(0, maxlength, by = 1))),
    defaults))

attributes(aggdata[['0.0.0.0.0']])$age$all <- minage:maxage


gadget_dir_write(gd,
                 gadget_likelihood_component("catchdistribution",
                                             name = "ldist.igfs",
                                             weight = 1,
                                             data = aggdata[[1]],
                                             fleetnames = c("igfs"),
                                             stocknames = stocknames))

rm(aggdata)

# Age surveys
aggdata <-
    mfdb_sample_count(mdb, c('age', 'length'),
                      c(list(sampling_type = 'IGFS',
                             age = mfdb_step_interval('age',by=1,from=1,to=30),
                             species=defaults$species,
                             length = mfdb_interval("len", seq(0, maxlength, by = 1))),
                        defaults))

#attributes(aggdata[[1]])$age <-
#    llply(attributes(aggdata[[1]])$age,function(x) x[1])

gadget_dir_write(gd,
                 gadget_likelihood_component("catchdistribution",
                                             name = "aldist.igfs",
                                             weight = 1,
                                             data = aggdata[[1]],
                                             fleetnames = c("igfs"),
                                             stocknames = stocknames))
rm(aggdata)


# ## Maturity @3 from IGFS
# aggdata <- mfdb_sample_count(mdb, c('maturity_stage','age','length'),
#                     append(defaults,
#                         list(sampling_type='IGFS',
#                                 age=mfdb_group(imm=1:6, mat=7:30),
#                                 length = mfdb_step_interval('len', by=1, from=0, to=maxlength),              
#                                 maturity_stage = mfdb_group(gssimm = 1, gssmat = 2:5))))
# 
# gadget_dir_write(gd,
#                  gadget_likelihood_component("stockdistribution",
#                                              name = "matp.igfs",
#                                              weight = 1,
#                                              data = aggdata[[1]],
#                                              fleetnames = c("igfs"),
#                                              stocknames = stocknames))
# rm(aggdata)

# Query length data to create autumn survey catchdistribution components
aggdata <- mfdb_sample_count(mdb, c('age', 'length'), c(list(
    sampling_type = 'AUT',
    species = defaults$species,
    length = mfdb_interval("len", seq(0, maxlength, by = 1))),
    defaults))

attributes(aggdata[['0.0.0.0.0']])$age$all <- minage:maxage

gadget_dir_write(gd,
                 gadget_likelihood_component("catchdistribution",
                                             name = "ldist.aut",
                                             weight = 1,
                                             data = aggdata[[1]],
                                             fleetnames = c("aut"),
                                             stocknames = stocknames))
rm(aggdata)

## Age autumn survey
aggdata <-
    mfdb_sample_count(mdb, c('age', 'length'),
                      c(list(sampling_type = 'AUT',
                             age = mfdb_step_interval('age',by=1,from=1,to=30),
                             species=defaults$species,
                             length = mfdb_interval("len", seq(0, maxlength, by = 1))),
                        defaults))

#attributes(aggdata[[1]])$age <-
#    llply(attributes(aggdata[[1]])$age,function(x) x[1])

gadget_dir_write(gd,
                 gadget_likelihood_component("catchdistribution",
                                             name = "aldist.aut",
                                             weight = 1,
                                             data = aggdata[[1]],
                                             fleetnames = c("aut"),
                                             stocknames = stocknames))
rm(aggdata)


# ## Maturity @3 from autumn survey
# aggdata <- mfdb_sample_count(mdb, c('maturity_stage','age','length'),
#                              append(defaults,
#                                     list(sampling_type='AUT',
#                                          age=mfdb_group(imm=1:6, mat=7:20),
#                                          length = mfdb_step_interval('len', by=1, from=0, to=maxlength),
#                                          maturity_stage = mfdb_group(gssimm = 1, gssmat = 2:5))))
# 
# gadget_dir_write(gd,
#                  gadget_likelihood_component("stockdistribution",
#                                              name = "matp.aut",
#                                              weight = 1,
#                                              data = aggdata[[1]],
#                                              fleetnames = c("aut"),
#                                              stocknames = stocknames))
# rm(aggdata)



# Query length data to create bmt catchdistribution components
aggdata <- mfdb_sample_count(mdb, c('age', 'length'), c(list(
    sampling_type = 'SEA',
    species = defaults$species,
    gear = c('BMT'),
    length = mfdb_interval("len", seq(0, maxlength, by = 1))),
    defaults))
attributes(aggdata[['0.0.0.0.0']])$age$all <- minage:maxage

gadget_dir_write(gd, gadget_likelihood_component("catchdistribution",
                                                 name = "ldist.bmt",
                                                 weight = 1,
                                                 data = aggdata[[1]],
                                                 fleetnames = c("bmt.comm"),
                                                 stocknames = stocknames))
rm(aggdata)


## Age bottom.trawl fleet
aggdata <-
    mfdb_sample_count(mdb, c('age', 'length'),
                      c(list(sampling_type = 'SEA',
                             gear = 'BMT',
                             age = mfdb_step_interval('age',by=1,from=1,to=30),
                             length = mfdb_interval("len", seq(0, maxlength, by = 1))),
                        defaults))
#attributes(aggdata[[1]])$age <-
#    llply(attributes(aggdata[[1]])$age,function(x) x[1])

gadget_dir_write(gd,
                 gadget_likelihood_component("catchdistribution",
                                             name = "aldist.bmt",
                                             weight = 1,
                                             data = aggdata[[1]],
                                             fleetnames = c("bmt.comm"),
                                             stocknames = stocknames))
rm(aggdata)
