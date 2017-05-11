ENCODE_CSV=$(wildcard [A-Z]*encode.csv)
ENCODENVPROF_CSV=$(wildcard [A-Z]*encode-nvprof.csv)
ENCODESDK_CSV=$(wildcard [A-Z]*encode-sdk.csv)

QUAL_CSV=$(wildcard *quality.csv)

all : sqy-corpus-encode.csv sqy-corpus-encode-nvprof.csv sqy-corpus-quality.csv 

plots : ffmpeg_video_codec_cpuonly.svg ffmpeg_timing_difference.svg ffmpeg_cpugpu_video_codecs_enhanced.svg ffmpeg_cpugpu_video_codecs_realtime.svg

sqy-corpus-encode.csv : $(ENCODE_CSV)
	@echo "alg,filename,shorthand,flags,realtime_sec,cpu_user_sec,cpu_sys_sec,exit,threads,timestamp" > $@
	@cat $^ | sed -e 's/Keller_//' -e 's/Myers_//' -e 's/Svoboda_//' -e 's/Hyman_//' -e 's/Huisken_//' -e 's/Tomancak_//' >> $@

sqy-corpus-encode-nvprof.csv : $(ENCODENVPROF_CSV)
	@echo "alg,filename,shorthand,flags,cuCtxTime_sec,cpu_user_sec,cpu_sys_sec,exit,threads,timestamp" > $@
	@cat $^ | sed -e 's/Keller_//' -e 's/Myers_//' -e 's/Svoboda_//' -e 's/Hyman_//' -e 's/Huisken_//' -e 's/Tomancak_//'  >> $@

sqy-corpus-encode-sdk.csv : $(ENCODESDK_CSV)
	@echo "alg,filename,shorthand,flags,sdk_time_msec,cpu_user_sec,cpu_sys_sec,exit,threads,timestamp" > $@
	@cat $^ | sed -e 's/Keller_//' -e 's/Myers_//' -e 's/Svoboda_//' -e 's/Hyman_//' -e 's/Huisken_//' -e 's/Tomancak_//'  >> $@

sqy-corpus-quality.csv : $(QUAL_CSV)
	@echo "filename,shorthand,flags,timestamp,raw_size_bytes,encoded_size_bytes,bits_p_sample,left_drange,mse,nrmse,psnr,right_drange" > $@
	@cat $^ | sed -e 's/Keller_//' -e 's/Myers_//' -e 's/Svoboda_//' -e 's/Hyman_//' -e 's/Huisken_//' -e 's/Tomancak_//'  >> $@

ffmpeg_video_codec_cpuonly.svg :  sqy-corpus-encode.csv sqy-corpus-quality.csv
	@./cpuonly.R

ffmpeg_timing_difference.svg :  sqy-corpus-encode.csv sqy-corpus-encode-nvprof.csv
	@./timing.R

ffmpeg_cpugpu_video_codecs_enhanced.svg :  sqy-corpus-encode.csv sqy-corpus-encode-nvprof.csv sqy-corpus-quality.csv
	@./gpu.R


clean :
	@rm -fv sqy-corpus-encode.csv sqy-corpus-encode-nvprof.csv sqy-corpus-quality.csv ffmpeg_video_codec_cpuonly.svg
