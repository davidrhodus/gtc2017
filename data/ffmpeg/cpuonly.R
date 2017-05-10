#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(readr)
library(ggthemes)
library(tidyr)



enc_df = read_csv("sqy-corpus-encode.csv") %>% filter(exit==0) %>% select(-flags, -timestamp)

info_df = read_csv("sqy-corpus-info.csv") %>% mutate(filename = gsub(".tif","",filename))
info_df = info_df %>%
    mutate(parent_filename = filename, bytesof_pixel = bits_per_pixel/8) %>%
    separate(shape, into = c("zshape", "yshape","xshape"), sep = "x", convert = T, remove = F) %>%
    mutate(n_elems = zshape*yshape*xshape,
           size_bytes = n_elems*bytesof_pixel ,
           yuv420_size_bytes = n_elems*6/4.)


#encnv_df = read_csv("sqy-corpus-encode-nvprof.csv") %>% filter(exit==0)
qual_df = read_csv("sqy-corpus-quality.csv") %>% select(-flags, -timestamp)


combined_enc = inner_join(enc_df,qual_df,by = c("filename"="filename",
                                             "shorthand"="shorthand")) 

glimpse(combined_enc)
combined_enc = combined_enc %>% mutate( parent_filename = gsub("(_unweighted|weighted_power_3_1)","",filename))
combined_enc = inner_join(combined_enc,info_df,by = "parent_filename")


combined_enc = combined_enc %>%
    mutate( ingest_bw_mb_per_sec = yuv420_size_bytes/(1024*1024*realtime_sec),
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
