#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(readr)
library(ggthemes)
library(tidyr)


## add_colnames_for_enc = function(df){
##     colnames(df) = c("filename","sizeof_pixel","shape","n_elements","time_mus","final_bytes","id","comment")

##     df = df %>% separate(comment, into = c("pipeline", "threads","timestamp"), sep = "\\|")
##     df$threads = as.integer(gsub("threads","",df$threads))
##     df$filename = gsub("\\.tif","",df$filename)
##     return(df)
## }

## add_colnames_for_dec = function(ddf){
##     colnames(ddf) = c("mode","filename","pipeline","realtime_s","user_s","sys_s","exit_code","threads","timestamp")
##     return(ddf)
## }

## add_colnames_for_qual = function(qdf){
##     colnames(qdf) = c("filename","pipeline","timestamp","bits_p_sample","left_drange","mse","nrmse","psnr","right_drange")
##     return(qdf)
## }


enc_df = read_csv("sqy-corpus-encode.csv") %>% filter(exit==0) %>% select(-flags, -timestamp) 

## gr_enc_df = enc <- enc_df %>%
##     group_by(filename, sizeof_pixel,n_elements,final_bytes,pipeline,threads) %>%
##     summarize( mn_time_mus = mean(time_mus), md_time_mus = median(time_mus), sd_time_mus = sd(time_mus)) %>%
##     mutate( size_mb = n_elements*sizeof_pixel/(1024*1024), size_gb = size_mb/(1024),
##            md_ingest_bw_mb_per_sec = size_mb*10e6/(md_time_mus),
##            mn_ingest_bw_mb_per_sec = size_mb*10e6/(mn_time_mus),
##            sd_ingest_bw_mb_per_sec = size_mb*10e6/(sd_time_mus)
##            )

encnv_df = read_csv("sqy-corpus-encode-nvprof.csv") %>% filter(exit==0)  %>% mutate(shorthand = gsub("_nvprof","",shorthand))

glimpse(encnv_df)
glimpse(enc_df)
combined_enc = inner_join(enc_df,encnv_df,by = c("filename"="filename",
                                              "shorthand"="shorthand")) %>% mutate(time_ratio = realtime_sec/cuCtxTime_sec, encoder=gsub("_ultrafast","",shorthand), shortuid = as.integer(row_number())) 

glimpse(combined_enc)

timingplot = ggplot( combined_enc ,aes( x=shortuid, y=time_ratio,color=encoder)) + theme_bw()
timingplot = timingplot + geom_point(size=4) 
timingplot = timingplot + ggtitle("ffmpeg (1 Nvidia GeForce GTX1080 per process)\nflags:  -c:v nvenc_<encoder> -preset llhp -2pass 0")
timingplot = timingplot + xlab("file name") + ylab(" time(/usr/bin/time) / time(nvprof) ")
timingplot = timingplot + coord_flip()


ggsave("ffmpeg_timing_difference.png",timingplot,height=4)
ggsave("ffmpeg_timing_difference.svg",timingplot,height=4)
ggsave("ffmpeg_timing_difference.pdf",timingplot,height=4)
