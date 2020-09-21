#!/bin/bash
export NDK_HOME=/Users/zhangyf/Library/Android/sdk/ndk/android-ndk-r14b
#export NDK_HOME=/Users/zhangyf/Library/Android/sdk/ndk/20.1.5948944

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
	--enable-encoder=mjpeg \
	--disable-bsfs \
	--enable-nonfree \
	--disable-filters \
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

#arm
CURRENT=$PWD
PLATFORM_VERSION=android-21
ARCH=arm
CPU=armeabi
PREFIX=$(pwd)/android/$CPU
TOOLCHAIN=$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64
CROSS_COMPILE=$TOOLCHAIN/bin/arm-linux-androideabi-
ADDI_CFLAGS="-marm -mthumb"
ADDI_LDFLAGS=""
#ADDI_CFLAGS_OPENSSL="-I/Users/zhangyf/work/mac_ffmpeg_compile/opensslbuild/openssl-1.1.1g/output-armeabi/include"
ADDI_CFLAGS_OPENSSL="-I/Users/zhangyf/work/libcurl-android/jni/build/openssl/armeabi-v7a/include"
#ADDI_LDFLAGS_OPENSSL="-L/Users/zhangyf/work/mac_ffmpeg_compile/opensslbuild/openssl-1.1.1g/output-armeabi/lib"
ADDI_LDFLAGS_OPENSSL="-L/Users/zhangyf/work/libcurl-android/jni/build/openssl/armeabi-v7a/lib"

#FDK_INCLUDE=$CURRENT/../thirdparty/arm/fdk/include/
#FDK_LIB=$CURRENT/../thirdparty/arm/fdk/lib/
LAME_INCLUDE="-I$CURRENT/../thirdparty/lame/armeabi-v7a/include/"
LAME_LIB="-L$CURRENT/../thirdparty/lame/armeabi-v7a/lib/"
AAC_INCLUDE="-I$CURRENT/../thirdparty/fdk/armeabi-v7a/include/"
AAC_LIB="-L$CURRENT/../thirdparty/fdk/armeabi-v7a/lib/"
X264_INCLUDE="-I$CURRENT/../thirdparty/x264/armeabi-v7a/include/"
X264_LIB="-L$CURRENT/../thirdparty/x264/armeabi-v7a/lib/"
#ADDI_CFLAGS="-I${SSL_INCLUDE} -I${FDK_INCLUDE} -I${LAME_INCLUDE}"
#ADDI_LDFLAGS="-L${SSL_LIB} -L${FDK_LIB} -L${LAME_LIB}"

# 绝对路径，相对路径编译不过，不要openssl就打开以下两行
# ADDI_CFLAGS_OPENSSL=""
# ADDI_LDFLAGS_OPENSSL=""
SYSROOT=$NDK_HOME/platforms/$PLATFORM_VERSION/arch-$ARCH/
build

#arm-v7a
PLATFORM_VERSION=android-21
ARCH=arm
CPU=armeabi-v7a
PREFIX=$(pwd)/android/$CPU
TOOLCHAIN=$NDK_HOME/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64
CROSS_COMPILE=$TOOLCHAIN/bin/arm-linux-androideabi-
ADDI_CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -mfpu=neon"
ADDI_LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8 "
#ADDI_CFLAGS_OPENSSL="-I/Users/zhangyf/work/mac_ffmpeg_compile/opensslbuild/openssl-1.1.1g/output-armeabi/include"
ADDI_CFLAGS_OPENSSL="-I/Users/zhangyf/work/libcurl-android/jni/build/openssl/armeabi-v7a/include"
#ADDI_LDFLAGS_OPENSSL="-L/Users/zhangyf/work/mac_ffmpeg_compile/opensslbuild/openssl-1.1.1g/output-armeabi/lib"
ADDI_LDFLAGS_OPENSSL="-L/Users/zhangyf/work/libcurl-android/jni/build/openssl/armeabi-v7a/lib"
LAME_INCLUDE="-I$CURRENT/../thirdparty/lame/armeabi-v7a/include/"
LAME_LIB="-L$CURRENT/../thirdparty/lame/armeabi-v7a/lib/"
AAC_INCLUDE="-I$CURRENT/../thirdparty/fdk/armeabi-v7a/include/"
AAC_LIB="-L$CURRENT/../thirdparty/fdk/armeabi-v7a/lib/"
X264_INCLUDE="-I$CURRENT/../thirdparty/x264/armeabi-v7a/include/"
X264_LIB="-L$CURRENT/../thirdparty/x264/armeabi-v7a/lib/"
#绝对路径，相对路径编译不过，不要openssl就打开以下两行
SYSROOT=$NDK_HOME/platforms/$PLATFORM_VERSION/arch-$ARCH/
build

