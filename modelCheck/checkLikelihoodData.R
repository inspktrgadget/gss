## code to check how many samples are in each aldist and ldist
setwd('~/gadget/gadget-models/grSilverSmelt/gssModel')

main <- read.gadget.main()
likelihood <- read.gadget.likelihood(main$likelihood)
dat <- read.gadget.data(likelihood)

al.aut <- dat$dat$catchdistribution$aldist.aut
al.bmt <- dat$dat$catchdistribution$aldist.bmt
al.igfs <- dat$dat$catchdistribution$aldist.igfs
ld.aut <- dat$dat$catchdistribution$ldist.aut
ld.bmt <- dat$dat$catchdistribution$ldist.bmt
ld.igfs <- dat$dat$catchdistribution$ldist.igfs

## check autumn age-length
al.aut %>% group_by(year) %>% summarize(n = sum(number)) %>% as.data.frame()

## check bottom trawl age-length
al.bmt %>% group_by(year) %>% summarize(n = sum(number)) %>% as.data.frame()

## check spring age-length
al.igfs %>% group_by(year) %>% summarize(n = sum(number)) %>% as.data.frame()

## check autumn length distribution
ld.aut %>% group_by(year) %>% summarize(n = sum(number)) %>% as.data.frame()

## check bottom trawl length distribution
ld.bmt %>% group_by(year) %>% summarize(n = sum(number)) %>% as.data.frame()

## check spring length distribution
ld.igfs %>% group_by(year) %>% summarize(n = sum(number)) %>% as.data.frame()