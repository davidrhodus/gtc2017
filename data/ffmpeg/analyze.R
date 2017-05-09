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

#encnv_df = read_csv("sqy-corpus-encode-nvprof.csv") %>% filter(exit==0)
qual_df = read_csv("sqy-corpus-quality.csv") %>% select(-flags, -timestamp)


combined_enc = inner_join(enc_df,qual_df,by = c("filename"="filename",
                                             "shorthand"="shorthand")) 

combined_enc = combined_enc %>%
    mutate( ingest_bw_mb_per_sec = raw_size_bytes/(1024*1024*realtime_sec),
           encoder = gsub("_ultrafast","",shorthand),
           compression_ratio = raw_size_bytes/encoded_size_bytes)

cpuonly = combined_enc %>% filter(threads > 1)
glimpse(combined_enc)
glimpse(cpuonly)

quantizer_plot = ggplot( cpuonly ,aes( x=ingest_bw_mb_per_sec,y=compression_ratio,color=encoder)) + theme_bw()
quantizer_plot = quantizer_plot + geom_point(size=4) 
quantizer_plot = quantizer_plot + ggtitle("ffmpeg (8 threads of Intel Xeon E5-2680v3)\nflags: -preset ultrafast")
quantizer_plot = quantizer_plot + xlab("ingest bandwidth / MB/s") + ylab(" size(raw) / size(encoded) ")
## quantizer_plot = quantizer_plot + geom_vline(xintercept=xinter, color="Red", size=2)
## quantizer_plot = quantizer_plot + geom_text(aes(x=xinter, label=sprintf("\nmedian = %.0f",xinter), y=1.4e-3),
##                                             colour="red", angle=90, text=element_text(size=11))

## quantizer_plot = quantizer_plot + geom_hline(yintercept=yinter, color="Blue", size=2)
## quantizer_plot = quantizer_plot + geom_text(aes(y=yinter, label=sprintf("\nmedian = %.4f",yinter), x=7.5e3),
##                                             colour="blue", text=element_text(size=11))


ggsave("ffmpeg_video_codec_cpuonly.png",quantizer_plot,height=5)
ggsave("ffmpeg_video_codec_cpuonly.svg",quantizer_plot,height=5)
ggsave("ffmpeg_video_codec_cpuonly.pdf",quantizer_plot,height=5)
