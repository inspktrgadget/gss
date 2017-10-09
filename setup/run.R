library(Rgadget)
setwd('~/gadget/gadget-models/grSilverSmelt/gssModel')
tmp <- gadget.iterative(rew.sI=TRUE,
                        main='main',
                        grouping=list(short=c('igfs.si.short', 'aut.si.short'),
                                      mid=c('igfs.si.mid', 'aut.si.mid'),
                                      long=c('igfs.si.long', 'aut.si.long')),
                        wgts='WGTS')


# survey=c('ldist.igfs', 'ldist.aut',
#          'aldist.igfs', 'aldist.aut'),
# comm=c('ldist.bmt', 'aldist.bmt')