#!/bin/bash
export NDK_HOME=/Users/zhangyf/Library/Android/sdk/ndk/android-ndk-r14b
function build
{
	echo "start build ffmpeg for $CPU"
	./configure --target-os=android\
	--prefix=$PREFIX --arch=$ARCH \
	--disable-debug \
	--disable-doc \
	--disable-x86asm \
	--disable-asm \
	--disable-symver \
	--disable-programs \
	--disable-htmlpages \
	--disable-manpages \
	--disable-podpages \
	--disable-txtpages \
	--disable-ffmpeg \
	--disable-ffplay \
	--disable-ffprobe \
	--disable-everything \
	--enable-runtime-cpudetect \
	--enable-hardcoded-tables \
	--enable-jni \
	--enable-mediacodec \
	--enable-avcodec \
	--enable-avformat \
	--enable-swresample \
	--enable-swscale \
	--enable-network \
	--disable-protocols \
	--enable-protocol=file \
	--enable-protocol=rtmp \
	--enable-protocol=http \
	--enable-protocol=https \
	--enable-protocol=tcp \
	--enable-protocol=udp \
	--disable-parsers \
	--enable-parser=aac \
	--enable-parser=h264 \
	--disable-demuxers \
	--enable-demuxer=flv \
	--enable-demuxer=hls \
	--enable-demuxer=mpegts \
	--enable-demuxer=mov \
	--disable-muxers \
	--enable-muxer=mp4 \
	--enable-muxer=mjpeg \
	--disable-decoders \
	--enable-decoder=h264 \
	--enable-decoder=h264_mediacodec \
	--enable-decoder=aac \
        --enable-decoder=aasc \
        --enable-decoder=h264 \
        --enable-decoder=mp3 \
        --enable-decoder=aac_latm \
        --disable-encoders \
        --enable-libfdk_aac \
        --enable-encoder=libfdk_aac \
        --enable-libmp3lame \
        --enable-encoder=libmp3lame \
        --enable-gpl \
        --enable-encoder=aac \
	--enable-decoder=mjpeg \
	--disable-bsfs \
	--enable-nonfree \
	--disable-filters \
	--disable-shared \
	--cross-prefix=$CROSS_COMPILE \
	--enable-cross-compile \
	--sysroot=$SYSROOT \
	--enable-openssl \
	--enable-small \
        --extra-cflags="-Os -fpic $ADDI_CFLAGS $ADDI_CFLAGS_OPENSSL $LAME_INCLUDE $AAC_INCLUDE $X264_INCLUDE" \
        --extra-ldflags="-lz -lc -lm -ldl -llog $ADDI_LDFLAGS $ADDI_LDFLAGS_OPENSSL $LAME_LIB $X264_LIB $AAC_LIB" \
	$ADDITIONAL_CONFIGURE_FLAG
	make clean
	make -j8
	make install
	echo "build ffmpeg for $CPU finished"
}

#--enable-libx264 \
#--enable-encoder=libx264 \
#arm64
CURRENT=$PWD
PLATFORM_VERSION=android-21
ARCH=arm64
CPU=arm64
PREFIX=$(pwd)/android/$CPU
TOOLCHAIN=$NDK_HOME/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64
CROSS_COMPILE=$TOOLCHAIN/bin/aarch64-linux-android-
ADDI_CFLAGS=""
ADDI_LDFLAGS=""
#ADDI_CFLAGS_OPENSSL="-I/Users/zhangyf/work/mac_ffmpeg_compile/opensslbuild/openssl-1.1.1g/output-arm64-v8a/include"
ADDI_CFLAGS_OPENSSL="-I/Users/zhangyf/work/libcurl-android/jni/build/openssl/arm64-v8a/include"
#ADDI_CFLAGS_OPENSSL="-I/Users/zhangyf/work/libcurl-android/jni/build/openssl/arm64-v8a/include"
#ADDI_LDFLAGS_OPENSSL="-L/Users/zhangyf/work/mac_ffmpeg_compile/opensslbuild/openssl-1.1.1g/output-arm64-v8a/lib"
ADDI_LDFLAGS_OPENSSL="-L/Users/zhangyf/work/libcurl-android/jni/build/openssl/arm64-v8a/lib"
#ADDI_LDFLAGS_OPENSSL="_L/Users/zhangyf/work/libcurl-android/jni/build/openssl/arm64-v8a/lib"
LAME_INCLUDE="-I$CURRENT/../thirdparty/lame/arm64-v8a/include/"
LAME_LIB="-L$CURRENT/../thirdparty/lame/arm64-v8a/lib/"

AAC_INCLUDE="-I$CURRENT/../thirdparty/fdk/arm64-v8a/include/"
AAC_LIB="-L$CURRENT/../thirdparty/fdk/arm64-v8a/lib/"
X264_INCLUDE="-I$CURRENT/../thirdparty/x264/arm64-v8a/include/"
X264_LIB="-L$CURRENT/../thirdparty/x264/arm64-v8a/lib/"

#不要openssl打开以下两行
# ADDI_CFLAGS_OPENSSL=""
# ADDI_LDFLAGS_OPENSSL=""
SYSROOT=$NDK_HOME/platforms/$PLATFORM_VERSION/arch-$ARCH/
build

