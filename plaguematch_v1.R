#PLague platform guessing final step, in R script format

#V1 - Aug 4, 2016


#Get command list
args <- commandArgs(trailingOnly = TRUE)
plague_file <- args[1]


 unlist_split <- function(x, ...)
  {
	toret <- unlist(strsplit(x, ...) )
	ncols <- length(toret)
	return(t(toret)[ncols])
  }


#plague_file <- 'pgbd_unfiltered.plague'
dat <- read.table(plague_file,header=F,skip=3, stringsAsFactors=F)

dat$sum <- dat$V8 + dat$V15
dat$platform <- sapply(dat$V3,unlist_split,split="_")
	 
plat <- dat[order(dat$sum,decreasing=TRUE),]$platform[1] #After sorting, the first entry is the platform

write.table(plat, paste(plague_file,'.platform',sep=''),quote=F,row.names=F,col.names=F)

cat(plat)

