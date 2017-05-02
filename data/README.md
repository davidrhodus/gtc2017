# benchmarks

## building the software stack

### x264

- commit `90a61ec76424778c050524f682a33f115024be96` from [here](http://www.videolan.org/developers/x264.html) compiled with [gcc/6.2.0](ftp://ftp.gwdg.de/pub/misc/gcc/releases/gcc-6.2.0/) from the official mirror sites

### x265

- version 2.4 from [here](https://bitbucket.org/multicoreware/x265/downloads/) compiled with [gcc/6.2.0](ftp://ftp.gwdg.de/pub/misc/gcc/releases/gcc-6.2.0/) from the official mirror sites

### CUDA

- version 8.0.61 from [developer.nvidia.com/cuda-downloads](https://developer.nvidia.com/cuda-downloads) with [gcc/5.4.0](ftp://ftp.gwdg.de/pub/misc/gcc/releases/gcc-5.4.0/) from the official mirror sites

### nvenc

- used from nvidia's video codec SDK `v7.1` from [here](https://developer.nvidia.com/nvidia-video-codec-sdk#NVENCFeatures)

### ffmpeg

- version 3.0.7 from [here]() compiled with [gcc/5.4.0](ftp://ftp.gwdg.de/pub/misc/gcc/releases/gcc-5.4.0/) from the official mirror sites

```
./configure --prefix=${HOME}/software/ffmpeg/3.0.7-x264-hevc-nvenc --enable-shared --enable-static --enable-libx264 --enable-libx265 --enable-gpl --extra-ldflags="${HOME}/software/x264/master/lib/libx264.so ${HOME}/software/x265/2.4/lib/libx265.so" --disable-sdl --disable-libxcb --disable-zlib --disable-bzlib --disable-xlib --disable-lzma --disable-indevs --disable-outdevs --disable-filters  --enable-nvenc --enable-nonfree  --extra-cflags=-I${HOME}/software/nvidia_video_codec_sdk/Video_Codec_SDK_7.1.9/Samples/common/inc
```
