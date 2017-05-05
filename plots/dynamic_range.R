#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(readr)
library(ggthemes)

corpus_df= read_csv("corpus_info.csv") %>% filter ("flybrain.tif" != filename)
head(corpus_df)


drangeplot = ggplot( corpus_df ,aes(filename , drange)) + theme_bw()
drangeplot = drangeplot + geom_point(size=2) 
#drangeplot = drangeplot + ggtitle("GPU-Stream Add : AMD R9 Fiji Nano (rocm 1.4)")
drangeplot = drangeplot + xlab("corpus file name") + ylab(" dynamic range / number of bits ")
drangeplot = drangeplot + coord_flip()
drangeplot = drangeplot + ylim(0,16)

cat(paste("mean dynamic range: ",mean(corpus_df$drange),"median dynamic range: ",median(corpus_df$drange),"\n"))
cat(paste("std dynamic range: ",sd(corpus_df$drange),"\n"))

ggsave("corpus_drange.png",drangeplot,height=4,width=10)
ggsave("corpus_drange.svg",drangeplot,height=4,width=10)
