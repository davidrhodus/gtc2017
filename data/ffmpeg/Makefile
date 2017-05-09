ENCODE_CSV=$(wildcard [A-Z]*encode.csv)
ENCODENVPROF_CSV=$(wildcard [A-Z]*encode-nvprof.csv)

QUAL_CSV=$(wildcard *quality.csv)

all : sqy-corpus-encode.csv sqy-corpus-encode-nvprof.csv sqy-corpus-quality.csv

sqy-corpus-encode.csv : $(ENCODE_CSV)
	@echo "alg,filename,shorthand,flags,realtime_sec,cpu_user_sec,cpu_sys_sec,exit,threads,timestamp" > $@
	@cat $^ >> $@

sqy-corpus-encode-nvprof.csv : $(ENCODENVPROF_CSV)
	@echo "alg,filename,shorthand,flags,cuCtxTime_sec,cpu_user_sec,cpu_sys_sec,exit,threads,timestamp" > $@
	@cat $^ >> $@

sqy-corpus-quality.csv : $(QUAL_CSV)
	@echo "filename,shorthand,flags,timestamp,bits_p_sample,left_drange,mse,nrmse,psnr,right_drange" > $@
	@cat $^ >> $@

clean :
	@rm -fv sqy-corpus-encode.csv sqy-corpus-encode-nvprof.csv sqy-corpus-quality.csv
