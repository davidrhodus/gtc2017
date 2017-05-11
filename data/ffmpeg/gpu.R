#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(readr)
library(scales)
library(ggthemes)
library(tidyr)


enc_df = read_csv("sqy-corpus-encode.csv") %>% filter(exit==0) %>% select(-flags, -timestamp)

enc_nvprof_df = read_csv("sqy-corpus-encode-nvprof.csv") %>% filter(exit==0)
enc_sdk_df = read_csv("sqy-corpus-encode-sdk.csv") %>% filter(exit==0)  

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
realtime_plot = realtime_plot + scale_y_continuous(trans=log2_trans(), breaks = trans_breaks("log2", function(x) 2^x),  labels = trans_format("log2", math_format(2^.y)))

ggsave("ffmpeg_cpugpu_video_codecs_realtime.png",realtime_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_realtime.svg",realtime_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_realtime.pdf",realtime_plot,height=5)


##### using the cuCtxCreate/Destroy timings

enc_nvprof_df = inner_join(enc_nvprof_df,qual_df,by = c("filename"="filename",
                                              "shorthand"="shorthand"))

enc_nvprof_df = enc_nvprof_df %>% mutate( parent_filename = gsub("(_unweighted|weighted_power_3_1)","",filename))
enc_nvprof_df = inner_join(enc_nvprof_df,info_df,by = "parent_filename")

enc_nvprof_df = enc_nvprof_df %>%
    mutate( ingest_bw_mb_per_sec = yuv420_size_bytes/(1024*1024*cuCtxTime_sec),
           encoder = gsub("_ultrafast","",shorthand),
           compression_ratio = raw_size_bytes/encoded_size_bytes)

including_nvprof = combined_enc %>% filter( !(grepl("nvenc",encoder)) ) %>% bind_rows(enc_nvprof_df) %>% mutate(encoder = gsub("_nvprof","",encoder)) 



libx264_md = median((including_nvprof %>% filter(encoder == "libx264"))$ingest_bw_mb_per_sec)
nvenc_h264_md = median((including_nvprof %>% filter(encoder == "nvenc_h264"))$ingest_bw_mb_per_sec)

cat(sprintf("libx264 median bandwidth   = %f\n",libx264_md))
cat(sprintf("nvenc_h264 median bandwidth= %f\n",nvenc_h264_md))


enhanced_plot = ggplot( including_nvprof ,aes( x=ingest_bw_mb_per_sec,y=compression_ratio,color=encoder)) + theme_bw()
enhanced_plot = enhanced_plot + geom_point(size=4) 
enhanced_plot = enhanced_plot + ggtitle("ffmpeg (8c of Intel Xeon E5-2680v3, 1 GTX1080)")
enhanced_plot = enhanced_plot + xlab("ingest bandwidth / MB/s") + ylab(" size(raw) / size(encoded) ")
enhanced_plot = enhanced_plot + ylim(.1,1.1*max(including_nvprof$compression_ratio))

## enhanced_plot = enhanced_plot + geom_vline(xintercept=libx264_md, color="gray", size=1.25)
## enhanced_plot = enhanced_plot + geom_text(aes(x=libx264_md, label=sprintf("\nmedian libx264 = %.0f",libx264_md), y=.7*max(compression_ratio)),
##                                           angle=90, color="black", text=element_text(size=11))

## enhanced_plot = enhanced_plot + geom_vline(xintercept=nvenc_h264_md, color="gray",  size=1.25)
## enhanced_plot = enhanced_plot + geom_text(aes(x=nvenc_h264_md, label=sprintf("\nmedian nvenc_h264 = %.0f",nvenc_h264_md), y=.7*max(compression_ratio)),
##                                           angle=90, color="black", text=element_text(size=11))
enhanced_plot = enhanced_plot + scale_y_continuous(trans=log2_trans() , breaks = trans_breaks("log2", function(y) 2^y))#,  labels = trans_format("log2", math_format(2^.x)))


ggsave("ffmpeg_cpugpu_video_codecs_enhanced.png",enhanced_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_enhanced.svg",enhanced_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_enhanced.pdf",enhanced_plot,height=5)


##### using the SDK timings

enc_sdk_df = inner_join(enc_sdk_df,qual_df,by = c("filename"="filename",
                                              "shorthand"="shorthand"))

enc_sdk_df = enc_sdk_df %>% mutate( parent_filename = gsub("(_unweighted|weighted_power_3_1)","",filename))
enc_sdk_df = inner_join(enc_sdk_df,info_df,by = "parent_filename")

enc_sdk_df = enc_sdk_df %>%
    mutate( ingest_bw_mb_per_sec = yuv420_size_bytes/(1024*1024*sdk_time_msec/1000.),
           encoder = gsub("_ultrafast","",shorthand),
           compression_ratio = raw_size_bytes/encoded_size_bytes)

including_sdk = combined_enc %>% filter( !(grepl("nvenc",encoder)) ) %>% bind_rows(enc_sdk_df) %>% mutate(encoder = gsub("_sdk","",encoder)) 



libx264_md = median((including_sdk %>% filter(encoder == "libx264"))$ingest_bw_mb_per_sec)
nvenc_h264_md = median((including_sdk %>% filter(encoder == "nvenc_h264"))$ingest_bw_mb_per_sec)

cat(sprintf("libx264 median bandwidth   = %f\n",libx264_md))
cat(sprintf("nvenc_h264 median bandwidth= %f\n",nvenc_h264_md))


sdk_plot = ggplot( including_sdk ,aes( x=ingest_bw_mb_per_sec,y=compression_ratio,color=encoder)) + theme_bw()
sdk_plot = sdk_plot + geom_point(size=4) 
sdk_plot = sdk_plot + ggtitle("ffmpeg (8c of Intel Xeon E5-2680v3, 1 GTX1080)")
sdk_plot = sdk_plot + xlab("ingest bandwidth / MB/s") + ylab(" size(raw) / size(encoded) ")
sdk_plot = sdk_plot + ylim(.1,1.1*max(including_sdk$compression_ratio))

## sdk_plot = sdk_plot + geom_vline(xintercept=libx264_md, color="gray", size=1.25)
## sdk_plot = sdk_plot + geom_text(aes(x=libx264_md, label=sprintf("\nmedian libx264 = %.0f",libx264_md), y=.7*max(compression_ratio)),
##                                           angle=90, color="black", text=element_text(size=11))

## sdk_plot = sdk_plot + geom_vline(xintercept=nvenc_h264_md, color="gray",  size=1.25)
## sdk_plot = sdk_plot + geom_text(aes(x=nvenc_h264_md, label=sprintf("\nmedian nvenc_h264 = %.0f",nvenc_h264_md), y=.7*max(compression_ratio)),
##                                           angle=90, color="black", text=element_text(size=11))
sdk_plot = sdk_plot + scale_y_continuous(trans=log2_trans() , breaks = trans_breaks("log2", function(y) 2^y))#,  labels = trans_format("log2", math_format(2^.x)))


ggsave("ffmpeg_cpugpu_video_codecs_sdk.png",sdk_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_sdk.svg",sdk_plot,height=5)
ggsave("ffmpeg_cpugpu_video_codecs_sdk.pdf",sdk_plot,height=5)



glimpse(including_nvprof)
