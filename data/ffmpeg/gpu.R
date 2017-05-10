#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(readr)
library(ggthemes)
library(tidyr)


enc_df = read_csv("sqy-corpus-encode.csv") %>% filter(exit==0) %>% select(-flags, -timestamp)

encnv_df = read_csv("sqy-corpus-encode-nvprof.csv") %>% filter(exit==0)  

qual_df = read_csv("sqy-corpus-quality.csv") %>% select(-flags, -timestamp)

info_df = read_csv("sqy-corpus-info.csv") %>% mutate(filename = gsub(".tif","",filename))
info_df = info_df %>%
    mutate(parent_filename = filename, bytesof_pixel = bits_per_pixel/8) %>%
    separate(shape, into = c("zshape", "yshape","xshape"), sep = "x", convert = T, remove = F) %>%
    mutate(n_elems = zshape*yshape*xshape,
           size_bytes = n_elems*bytesof_pixel ,
           yuv420_size_bytes = n_elems*6/4.)


combined_enc = inner_join(enc_df,qual_df,by = c("filename"="filename",
                                             "shorthand"="shorthand")) 

combined_enc = combined_enc %>% mutate( parent_filename = gsub("(_unweighted|weighted_power_3_1)","",filename))
combined_enc = inner_join(combined_enc,info_df,by = "parent_filename")

combined_enc = combined_enc %>%
    mutate( ingest_bw_mb_per_sec = yuv420_size_bytes/(1024*1024*realtime_sec),
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
                                              "shorthand"="shorthand"))

encnv_df = encnv_df %>% mutate( parent_filename = gsub("(_unweighted|weighted_power_3_1)","",filename))
encnv_df = inner_join(encnv_df,info_df,by = "parent_filename")

encnv_df = encnv_df %>%
    mutate( ingest_bw_mb_per_sec = yuv420_size_bytes/(1024*1024*cuCtxTime_sec),
           encoder = gsub("_ultrafast","",shorthand),
           compression_ratio = raw_size_bytes/encoded_size_bytes)

including_nvprof = combined_enc %>% filter( !(grepl("nvenc",encoder)) ) %>% bind_rows(encnv_df) %>% mutate(encoder = gsub("_nvprof","",encoder)) 



libx264_md = median((including_nvprof %>% filter(encoder == "libx264"))$ingest_bw_mb_per_sec)
nvenc_h264_md = median((including_nvprof %>% filter(encoder == "nvenc_h264"))$ingest_bw_mb_per_sec)

cat(sprintf("libx264 median bandwidth   = %f\n",libx264_md))
cat(sprintf("nvenc_h264 median bandwidth= %f\n",nvenc_h264_md))


enhanced_plot = ggplot( including_nvprof ,aes( x=ingest_bw_mb_per_sec,y=compression_ratio,color=encoder)) + theme_bw()
enhanced_plot = enhanced_plot + geom_point(size=4) 
enhanced_plot = enhanced_plot + ggtitle("ffmpeg (8c of Intel Xeon E5-2680v3, 1 GTX1080)")
enhanced_plot = enhanced_plot + xlab("ingest bandwidth / MB/s") + ylab(" size(raw) / size(encoded) ")

enhanced_plot = enhanced_plot + geom_vline(xintercept=libx264_md, color="gray", size=1.25)
enhanced_plot = enhanced_plot + geom_text(aes(x=libx264_md, label=sprintf("\nmedian libx264 = %.0f",libx264_md), y=.7*max(compression_ratio)),
                                          angle=90, color="black", text=element_text(size=11))

enhanced_plot = enhanced_plot + geom_vline(xintercept=nvenc_h264_md, color="gray",  size=1.25)
enhanced_plot = enhanced_plot + geom_text(aes(x=nvenc_h264_md, label=sprintf("\nmedian nvenc_h264 = %.0f",nvenc_h264_md), y=.7*max(compression_ratio)),
                                          angle=90, color="black", text=element_text(size=11))


ggsave("ffmpeg_cpugpu_video_codecs_enhanced.png",enhanced_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_enhanced.svg",enhanced_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_enhanced.pdf",enhanced_plot,height=5)


glimpse(including_nvprof)
