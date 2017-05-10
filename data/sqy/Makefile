ENCODE_CSV=$(wildcard [A-Z]*encode.csv)
DECODE_CSV=$(wildcard [A-Z]*decode.csv)

QUAL_CSV=$(wildcard *quality.csv)

all : sqy-corpus-encode.csv sqy-corpus-decode.csv sqy-corpus-quality.csv

sqy-corpus-encode.csv : $(ENCODE_CSV)
	@echo "filename,sizeof_pixel,shape,n_elements,time_mus,final_bytes,id,comment" > $@
	@cat $^ >> $@

sqy-corpus-decode.csv : $(DECODE_CSV)
	@echo "mode,filename,pipeline,realtime_s,user_s,sys_s,exit_code,threads,timestamp" > $@
	@cat $^ >> $@

sqy-corpus-quality.csv : $(QUAL_CSV)
	@echo "filename,pipeline,timestamp,bits_p_sample,l1norm,l2norm,left_drange,mnmse,mse,nrmse,psnr,right_drange,rms" > $@
	@cat $^ >> $@

.PHONY: plots clean
plots : sqy_quantizer.svg

sqy_quantizer.svg : #sqy-corpus-encode.csv sqy-corpus-decode.csv sqy-corpus-quality.csv
	@./analyze.R

clean :
	@rm -vf *svg *png *pdf sqy-corpus-encode.csv sqy-corpus-decode.csv sqy-corpus-quality.csv
