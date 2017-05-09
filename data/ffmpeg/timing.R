#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(readr)
library(ggthemes)
library(tidyr)


enc_df = read_csv("sqy-corpus-encode.csv") %>% filter(exit==0) %>% select(-flags, -timestamp) 

encnv_df = read_csv("sqy-corpus-encode-nvprof.csv") %>% filter(exit==0)  %>% mutate(shorthand = gsub("_nvprof","",shorthand))

glimpse(encnv_df)
glimpse(enc_df)
combined_enc = inner_join(enc_df,encnv_df,by = c("filename"="filename",
                                              "shorthand"="shorthand")) %>% mutate(time_ratio = realtime_sec/cuCtxTime_sec, encoder=gsub("_ultrafast","",shorthand), shortuid = as.integer(row_number())) 

glimpse(combined_enc)

timingplot = ggplot( combined_enc ,aes( x=shortuid, y=time_ratio,color=encoder)) + theme_bw()
timingplot = timingplot + geom_point(size=4) 
timingplot = timingplot + ggtitle("ffmpeg (1 Nvidia GeForce GTX1080 per process)\nflags:  -c:v nvenc_<encoder> -preset llhp -2pass 0")
timingplot = timingplot + xlab("file id") + ylab(" time(/usr/bin/time ffmpeg) / time(nvprof ffmpeg) ")
timingplot = timingplot + coord_flip()


ggsave("ffmpeg_timing_difference.png",timingplot,height=4)
ggsave("ffmpeg_timing_difference.svg",timingplot,height=4)
ggsave("ffmpeg_timing_difference.pdf",timingplot,height=4)
