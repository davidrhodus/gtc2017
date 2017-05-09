#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(readr)
library(ggthemes)
library(tidyr)


enc_df = read_csv("sqy-corpus-encode.csv") %>% filter(exit==0) %>% select(-flags, -timestamp)

encnv_df = read_csv("sqy-corpus-encode-nvprof.csv") %>% filter(exit==0)  

qual_df = read_csv("sqy-corpus-quality.csv") %>% select(-flags, -timestamp)


combined_enc = inner_join(enc_df,qual_df,by = c("filename"="filename",
                                             "shorthand"="shorthand")) 

combined_enc = combined_enc %>%
    mutate( ingest_bw_mb_per_sec = raw_size_bytes/(1024*1024*realtime_sec),
           encoder = gsub("_ultrafast","",shorthand),
           compression_ratio = raw_size_bytes/encoded_size_bytes)



realtime_plot = ggplot( combined_enc ,aes( x=ingest_bw_mb_per_sec,y=compression_ratio,color=encoder)) + theme_bw()
realtime_plot = realtime_plot + geom_point(size=4) 
realtime_plot = realtime_plot + ggtitle("ffmpeg (8c of Intel Xeon E5-2680v3, 1 GTX1080)")
realtime_plot = realtime_plot + xlab("ingest bandwidth / MB/s") + ylab(" size(raw) / size(encoded) ")


ggsave("ffmpeg_cpugpu_video_codecs_realtime.png",realtime_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_realtime.svg",realtime_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_realtime.pdf",realtime_plot,height=5)


encnv_df = inner_join(encnv_df,qual_df,by = c("filename"="filename",
                                             "shorthand"="shorthand"))  %>%
    mutate( ingest_bw_mb_per_sec = raw_size_bytes/(1024*1024*cuCtxTime_sec),
           encoder = gsub("_ultrafast","",shorthand),
           compression_ratio = raw_size_bytes/encoded_size_bytes)

including_nvprof = combined_enc %>% filter( !(grepl("nvenc",encoder)) ) %>% bind_rows(encnv_df) %>% mutate(encoder = gsub("_nvprof","",encoder)) 

enhanced_plot = ggplot( including_nvprof ,aes( x=ingest_bw_mb_per_sec,y=compression_ratio,color=encoder)) + theme_bw()
enhanced_plot = enhanced_plot + geom_point(size=4) 
enhanced_plot = enhanced_plot + ggtitle("ffmpeg (8c of Intel Xeon E5-2680v3, 1 GTX1080)")
enhanced_plot = enhanced_plot + xlab("ingest bandwidth / MB/s") + ylab(" size(raw) / size(encoded) ")


ggsave("ffmpeg_cpugpu_video_codecs_enhanced.png",enhanced_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_enhanced.svg",enhanced_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_enhanced.pdf",enhanced_plot,height=5)


glimpse(including_nvprof)
