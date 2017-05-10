#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(readr)
library(ggthemes)
library(tidyr)


add_colnames_for_enc = function(df){
    #colnames(df) = c("filename","sizeof_pixel","shape","n_elements","time_mus","final_bytes","id","comment")

    df = df %>% separate(comment, into = c("pipeline", "threads","timestamp"), sep = "\\|")
    df$threads = as.integer(gsub("threads","",df$threads))
    df$filename = gsub("\\.tif","",df$filename)

    return(df)
}

add_colnames_for_dec = function(ddf){
    #colnames(ddf) = c("mode","filename","pipeline","realtime_s","user_s","sys_s","exit_code","threads","timestamp")
    return(ddf)
}

add_colnames_for_qual = function(qdf){
    #colnames(qdf) = c("filename","pipeline","timestamp","bits_p_sample","left_drange","mse","nrmse","psnr","right_drange")
    return(qdf)
}


enc_df = read_csv("sqy-corpus-encode.csv"      )
enc_df = add_colnames_for_enc(enc_df)

gr_enc_df = enc <- enc_df %>%
    group_by(filename, sizeof_pixel,n_elements,final_bytes,pipeline,threads) %>%
    summarize( mn_time_mus = mean(time_mus), md_time_mus = median(time_mus), sd_time_mus = sd(time_mus)) %>%
    mutate( size_mb = n_elements*sizeof_pixel/(1024*1024), size_gb = size_mb/(1024),
           md_ingest_bw_mb_per_sec = size_mb*10e6/(md_time_mus),
           mn_ingest_bw_mb_per_sec = size_mb*10e6/(mn_time_mus),
           sd_ingest_bw_mb_per_sec = size_mb*10e6/(sd_time_mus)
           )

dec_df = read_csv("sqy-corpus-decode.csv"      )
dec_df = add_colnames_for_dec(dec_df)


qual_df = read_csv("sqy-corpus-quality.csv"      )
qual_df = add_colnames_for_qual(qual_df)


combined_enc = inner_join(gr_enc_df,qual_df,by = c("filename"="filename",
                                                   "pipeline"="pipeline"))

glimpse(combined_enc)
unique(combined_enc$pipeline)

to_plot = combined_enc %>% filter("quantiser->lz4" %in% pipeline) %>% mutate( obfuscated_filename = paste("corpus-",row_number(),sep=""))

glimpse(to_plot)
paste(unique(to_plot$filename))

xinter=median(to_plot$md_ingest_bw_mb_per_sec)
yinter=median(to_plot$nrmse)

quantizer_plot = ggplot( to_plot ,aes( x=md_ingest_bw_mb_per_sec,y=nrmse)) + theme_bw()
quantizer_plot = quantizer_plot + geom_point(size=4) 
quantizer_plot = quantizer_plot + ggtitle("sqeazy quantiser (8 threads of Intel E5-2680v3 CPU)")
quantizer_plot = quantizer_plot + xlab("ingest bandwidth / MB/s") + ylab(" RMS / (max(original)-min(original)) ")
quantizer_plot = quantizer_plot + geom_vline(xintercept=xinter, color="Red", size=2)
quantizer_plot = quantizer_plot + geom_text(aes(x=xinter, label=sprintf("\nmedian = %.0f",xinter), y=.7*max(nrmse)),
                                            colour="red", angle=90, text=element_text(size=11))

quantizer_plot = quantizer_plot + geom_hline(yintercept=yinter, color="Blue", size=2)
quantizer_plot = quantizer_plot + geom_text(aes(y=yinter, label=sprintf("\nmedian = %.4f",yinter), x=.7*max(md_ingest_bw_mb_per_sec)),
                                            colour="blue", text=element_text(size=11))


ggsave("sqy_quantizer_nrmse.png",quantizer_plot,height=4)
ggsave("sqy_quantizer_nrmse.svg",quantizer_plot,height=4)
ggsave("sqy_quantizer_nrmse.pdf",quantizer_plot,height=4)


xinter=median(to_plot$md_ingest_bw_mb_per_sec)
yinter=median(to_plot$mnmse)

median_based_plot = ggplot( to_plot ,aes( x=md_ingest_bw_mb_per_sec,y=mnmse)) + theme_bw()
median_based_plot = median_based_plot + geom_point(size=4) 
median_based_plot = median_based_plot + ggtitle("sqeazy quantiser (8 threads of Intel E5-2680v3 CPU)")
median_based_plot = median_based_plot + xlab("ingest bandwidth / MB/s") + ylab(" RMS / (mean(original)) ")
median_based_plot = median_based_plot + geom_vline(xintercept=xinter, color="Red", size=2)
median_based_plot = median_based_plot + geom_text(aes(x=xinter, label=sprintf("\nmedian = %.0f",xinter), y=.7*max(mnmse)),
                                            colour="red", angle=90, text=element_text(size=11))

median_based_plot = median_based_plot + geom_hline(yintercept=yinter, color="Blue", size=2)
median_based_plot = median_based_plot + geom_text(aes(y=yinter, label=sprintf("\nmedian = %.4f",yinter), x=.7*max(md_ingest_bw_mb_per_sec)),
                                            colour="blue", text=element_text(size=11))


ggsave("sqy_median_based_mnmse.png",median_based_plot,height=4)
ggsave("sqy_median_based_mnmse.svg",median_based_plot,height=4)
ggsave("sqy_median_based_mnmse.pdf",median_based_plot,height=4)

xinter=median(to_plot$md_ingest_bw_mb_per_sec)
yinter=median(to_plot$rms)

median_based_plot = ggplot( to_plot ,aes( x=md_ingest_bw_mb_per_sec,y=rms)) + theme_bw()
median_based_plot = median_based_plot + geom_point(size=4) 
median_based_plot = median_based_plot + ggtitle("sqeazy quantiser (8 threads of Intel E5-2680v3 CPU)")
median_based_plot = median_based_plot + xlab("ingest bandwidth / MB/s") + ylab(" RMS ")
median_based_plot = median_based_plot + geom_vline(xintercept=xinter, color="Red", size=2)
median_based_plot = median_based_plot + geom_text(aes(x=xinter, label=sprintf("\nmedian = %.0f",xinter), y=.7*max(rms)),
                                            colour="red", angle=90, text=element_text(size=11))

median_based_plot = median_based_plot + geom_hline(yintercept=yinter, color="Blue", size=2)
median_based_plot = median_based_plot + geom_text(aes(y=yinter, label=sprintf("\nmedian = %.4f",yinter), x=.7*max(md_ingest_bw_mb_per_sec)),
                                            colour="blue", text=element_text(size=11))


ggsave("sqy_rms.png",median_based_plot,height=4)
ggsave("sqy_rms.svg",median_based_plot,height=4)
ggsave("sqy_rms.pdf",median_based_plot,height=4)
