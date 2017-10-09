library(Rgadget)

# find some decent starting values for recl and stddev
mla <- mfdb_sample_meanlength_stddev(mdb, c('age'),
                                     c(list(sampling_type=c("IGFS","AUT"),
                                            age=1:30), # got 30 from ICES 2013. Report on the workshop on age estimation of deep water species
                                       defaults))
init.sigma <- 
    mla[[1]] %>% 
    na.omit() %>% 
    group_by(age) %>%
    summarize(ml=mean(mean), ms=mean(stddev, na.rm=T))

lw <- mfdb_sample_meanweight(mdb, c('length'),
                            c(list(sampling_type=c('IGFS','AUT'),
                                   species='GSS',
                                   length=mfdb_interval("", seq(0,60, by=1)))))

lw.tmp <-   
    lw[[1]] %>% 
    mutate(length=as.numeric(as.character(length)),
           weight=mean/1e3) %>%
    na.omit() %>%
    filter(!length == 8) %>% # removing oddball outlier
    nls(weight ~ a*length^b,.,start=list(a=1e-5,b=3)) %>%
    coefficients() %>%
    as.numeric()

## populate the model with starting default values
opt <- gadget.options(type='simple1stock')

## adapt opt list to greater silver smelt
weight.alpha <- lw.tmp[1]
weight.beta <- lw.tmp[2]

opt$area$numofareas <- 1
opt$area$areasize <- mfdb_area_size(mdb, defaults)[[1]]$size
opt$area$area.temperature <- 3
opt$time$firstyear <- st.year
opt$time$lastyear <- end.year

## setup M and determine initial abundance
nat.mort <- 0.15
pop <- 1
for (i in 1:29) {
    pop[i+1] <- round(pop[i]*exp(-nat.mort), 3)
}


## set up the one stock stock
opt$stocks$imm <- within(opt$stock$imm, {
    name <- 'gss'
    minage <- 1
    maxage <- 30
    minlength <- 1
    maxlength <- 58
    dl <- 1
    growth <- c(linf='#gss.linf', 
                k='#gss.k',
                beta='(* #gss.beta.mult #gss.bbin)', 
                binn=15, recl='#gss.recl'
    )
    weight <- c(a=weight.alpha, b=weight.beta)
    init.abund <- sprintf('(* %s %s)', pop, c(sprintf('#gss.age%s', 1:30)))
    n <- sprintf('(* 100 #gss.rec%s)', st.year:end.year)
    doesmature <- 0
    sigma <- c(init.sigma$ms[1], init.sigma$ms, 0,0,0,0)
    M <- rep(nat.mort,30)
    doesmove <- 0
    doesmigrate <- 0
    doesrenew <- 1
    renewal <- list(minlength=5, maxlength=20)
})




# ## set up immature stock
# opt$stocks$imm <- within(opt$stock$imm, {
#             name <- 'gssimm'
#             minage <- 1
#             maxage <- 17
#             minlength <- 1
#             maxlength <- 50
#             dl <- 1
#             growth <- c(linf='#gss.linf', 
#                         k='#gss.k',
#                         beta='(* 10 #gss.bbin)', 
#                         binn=15, recl='#gss.recl'
#                         )
#             weight <- c(a=weight.alpha, b=weight.beta)
#             init.abund <- sprintf('(* %s %s)', 
#                                   c(0,0.06,0.07,0.08,0.1,0.1,0.08,0.06,0.045,0.03,0.02,0.01,0,0,0,0,0),
#                                  c(0,sprintf('#gss.age%s',2:10),0,0,0,0,0,0,0))
#             n <- sprintf('(* #gss.rec.mult #gss.rec%s)', st.year:end.year)
#             doesmature <- 1
#             maturityfunction <- 'continuous'
#             maturestocksandratios <- 'gssmat 1'
#             maturity.coefficients <- '( * 0.001 #gss.mat1) #gss.mat2 0 0'
#             sigma <- head(init.sigma$ms, 17)
#             M <- rep(0.22,17)
#             maturitysteps <- '0'
#             doesmove <- 0
#             transitionstep <- 4
#             transitionstockandratios <- 'gssmat 1'
#             doesmigrate <- 0
#             doesrenew <- 1
#             renewal <- list(minlength=5, maxlength=20)
# })
#     
# # for both stocks (imm and mat) I used von Bertalanffy growth curve from Magnusson 1996 
# # to set parameters for minlengths and maxlengths
# # for details see 'functions/vbParams.R'
#     
#     
# ## set up mature stock
# opt$stocks$mat <- within(opt$stock$mat, {
#             name <- 'gssmat'
#             minage <- 4
#             maxage <- 30
#             minlength <- 10
#             maxlength <- 58
#             dl <- 1
#             M <- rep(0.22, 27)
#             growth <- c(linf='#gss.linf', k='#gss.k',
#                         beta='(* 10 #gss.bbin)', ## set up immature stock
#                         binn=15, recl='#gss.recl'
#                         )
#             weight <- c(a=weight.alpha, b=weight.beta)
#             init.abund <- sprintf('(* %s %s)', c(0,0.02,0.04,0.06,0.08,0.10,0.08,0.05,
#                                                  rep(0,19)),
#                                   c(0,sprintf('#gss.age%s',4:10),rep(0,19)))
#             sigma <- c(init.sigma$ms[4:19], rep(init.sigma$ms[19],12))
#             doesmature <- 0
#             doesmigrate <- 0
#         })


# create gadget skeleton
gm <- gadget.skeleton(time=opt$time, area=opt$area,
                      stocks=opt$stocks, fleets=opt$fleets)

gm@stocks$imm@renewal.data$stddev <- '#gss.rec.sd'

gm@stocks$imm@initialdata$area.factor <- '( * #gss.mult #gss.init.abund)'
#gm@stocks$mat@initialdata$area.factor <- '( * #gss.mult #gss.init.abund)'

gm@fleets <- list(bmt.fleet, igfs.fleet, aut.fleet)
gm@fleets[[2]]@suitability$params <- c("#igfs.p1 #igfs.p2 (- 1 #igfs.p1) #igfs.p4 #igfs.p5 100")
gm@fleets[[3]]@suitability$params <- c("(* #aut.alpha (* -1 #aut.beta)) #aut.beta 0 1")

gd.list <- list(dir=gd$dir)
Rgadget:::gadget_dir_write(gd.list, gm)

# fleet.file <- file(sprintf('%s/Modelfiles/fleets', gd$dir))
# fleet.lines <- readLines(fleet.file)
# fleet.lines <- gsub('#igfs.p ', '#igfs.p', fleet.lines)
# #fleet.lines <- gsub('#aut.p ',  '#aut.p', fleet.lines)
# writeLines(fleet.lines, con=fleet.file)
# close(fleet.file)
# rm(fleet.file)

curr.dir <- getwd()
setwd(gd$dir)
callGadget(s=1, log='logfile.txt', ignore.stderr=FALSE)

init.params <- read.gadget.parameters('params.out')

init.params[c('gss.linf', 'gss.k', 'gss.bbin', 'gss.beta.mult',
              'gss.mult', 'gss.init.abund', 'gss.rec.sd'), ] <-
read.table(text='switch	 value  lower 	upper 	optimise
gss.linf	         50	   40       70         1
gss.k	             0.2   0.06     0.30       1
gss.bbin	         6	   1e-08    300        1
gss.beta.mult        1000  1e-08    1e06       1
gss.mult	         100   1e-05    1e+05      1
gss.init.abund       100   0.1      100        1
gss.rec.sd           2     0.1      5          1', 
header=TRUE) 


## calculate initial values
init.val <- 100
init.upper <- 200
for (i in 1:29) {
    init.val[i+1] <- init.val[i]*exp(-nat.mort);
    init.upper[i+1] <- ceiling(init.upper[i]*exp(-nat.mort+0.1))
}

initial.abundance <- data.frame(switch = sprintf('#gss.age%s', 1:30),
                                value = init.val,
                                lower = 1,
                                upper = init.upper,
                                optimise = 1)

init.params[grep('age', rownames(init.params), value=T),] <- initial.abundance

init.params$switch <- rownames(init.params)

init.params[grepl('rec[0-9]',init.params$switch),'value'] <- 1
init.params[grepl('rec[0-9]',init.params$switch),'upper'] <- 500
init.params[grepl('rec[0-9]',init.params$switch),'lower'] <- 0.001
init.params[grepl('rec[0-9]',init.params$switch),'optimise'] <- 1

init.params['gss.recl',-1] <- c(15, 5, 20,1)

init.params[grepl('alpha',init.params$switch),'value'] <- 0.5
init.params[grepl('alpha',init.params$switch),'upper'] <- 3
init.params[grepl('alpha',init.params$switch),'lower'] <- 0.01
init.params[grepl('alpha',init.params$switch),'optimise'] <- 1

init.params[grepl('l50',init.params$switch),'value'] <- 30
init.params[grepl('l50',init.params$switch),'upper'] <- 60
init.params[grepl('l50',init.params$switch),'lower'] <- 10
init.params[grepl('l50',init.params$switch),'optimise'] <- 1

init.params[init.params$switch=='igfs.p1',] <- c('igfs.p1', 0.5, 0.01, 1, 1)
init.params[init.params$switch=='igfs.p2',] <- c('igfs.p2', 0.5, 0.01, 1, 1)
#init.params[init.params$switch=='igfs.p3',] <- c('igfs.p3', 0.5, 0.01, 1, 1)
init.params[init.params$switch=='igfs.p4',] <- c('igfs.p4', 5, 0.1, 100, 1)
init.params[init.params$switch=='igfs.p5',] <- c('igfs.p5', 5, 0.1, 100, 1)

init.params[init.params$switch=='aut.alpha',] <- c('aut.alpha', 20, 5, 60, 1)
init.params[init.params$switch=='aut.beta',] <- c('aut.beta', 0.9, 0.06, 2, 1)
# #init.params[init.params$switch=='aut.gamma',] <- c('aut.gamma', 0.5, 0, 1, 1)
# #init.params[init.params$switch=='aut.delta',] <- c('aut.delta', 0.5, 0, 1, 1)

#init.params[init.params$switch=='aut.p1',] <- c('aut.p1', 0.5, 0.01, 1, 1)
#init.params[init.params$switch=='aut.p2',] <- c('aut.p2', 0.5, 0.01, 1, 1)
#init.params[init.params$switch=='aut.p3',] <- c('aut.p3', 0.5, 0.01, 1, 1)
#init.params[init.params$switch=='aut.p4',] <- c('aut.p4', 5, 0.1, 100, 1)
#init.params[init.params$switch=='aut.p5',] <- c('aut.p5', 5, 0.1, 100, 1)


write.gadget.parameters(init.params,file='params.in')
setwd(curr.dir)
