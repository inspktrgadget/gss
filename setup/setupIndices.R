## IGFS survey indices

igfs.SI1 <- mfdb_sample_count(mdb, c('length'), c(list(
    sampling_type ='IGFS',
    length = mfdb_interval("len", c(18,21,24))),
    defaults))

igfs.SI2 <- mfdb_sample_count(mdb, c('length'), c(list(
    sampling_type ='IGFS',
    length = mfdb_interval("len", c(24,27,30,33))),
    defaults))

igfs.SI3 <- mfdb_sample_count(mdb, c('length'), c(list(
    sampling_type = 'IGFS',
    length = mfdb_interval("len", c(33,36,39), open_ended=T)),
    defaults))


gadget_dir_write(gd, gadget_likelihood_component("surveyindices",
                                                 name = "igfs.si.short",
                                                 weight = 1,
                                                 data = igfs.SI1[[1]],
                                                 fittype = 'fixedslopeloglinearfit',
                                                 slope=1,
                                                 stocknames = stocknames))

gadget_dir_write(gd, gadget_likelihood_component("surveyindices",
                                                 name = "igfs.si.mid",
                                                 weight = 1,
                                                 data = igfs.SI2[[1]],
                                                 fittype = 'fixedslopeloglinearfit',
                                                 slope=1,
                                                 stocknames = stocknames))

gadget_dir_write(gd, gadget_likelihood_component("surveyindices",
                                                 name = "igfs.si.long",
                                                 weight = 1,
                                                 data = igfs.SI3[[1]],
                                                 fittype = 'fixedslopeloglinearfit',
                                                 slope=1,
                                                 stocknames = stocknames))


## AUT survey indices
aut.SI1 <- mfdb_sample_count(mdb, c('length'), c(list(
    sampling_type = 'AUT',
    length = mfdb_interval("len", c(21,24,27,30))),
    defaults))

aut.SI2 <- mfdb_sample_count(mdb, c('length'), c(list(
    sampling_type = 'AUT',
    length = mfdb_interval("len", c(30,33,36,39))),
    defaults))

aut.SI3 <- mfdb_sample_count(mdb, c( 'length'), c(list(
    sampling_type = 'AUT',
    length = mfdb_interval("len", c(39,42,45), open_ended=T)),
    defaults))


gadget_dir_write(gd, gadget_likelihood_component("surveyindices",
                                                 name = "aut.si.short",
                                                 weight = 1,
                                                 data = aut.SI1[[1]],
                                                 fittype = 'fixedslopeloglinearfit',
                                                 slope=1,
                                                 stocknames = stocknames))

gadget_dir_write(gd, gadget_likelihood_component("surveyindices",
                                                 name = "aut.si.mid",
                                                 weight = 1,
                                                 data = aut.SI2[[1]],
                                                 fittype = 'fixedslopeloglinearfit',
                                                 slope=1,
                                                 stocknames = stocknames))

gadget_dir_write(gd, gadget_likelihood_component("surveyindices",
                                                 name = "aut.si.long",
                                                 weight = 1,
                                                 data = aut.SI3[[1]],
                                                 fittype = 'fixedslopeloglinearfit',
                                                 slope=1,
                                                 stocknames = stocknames))
