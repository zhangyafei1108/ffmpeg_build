#!/bin/sh

# directories
FF_VERSION="4.2"
#FF_VERSION="snapshot-git"
if [[ $FFMPEG_VERSION != "" ]]; then
  FF_VERSION=$FFMPEG_VERSION
fi
SOURCE="zyb_ffmpeg-$FF_VERSION"
FAT="ffmpeg-libs/ios"

SCRATCH="scratch"
# must be an absolute path
THIN=`pwd`/"thin"
SCRATCHPATH=`pwd`/"scratch"

FDK_AAC=`pwd`/thirdparty/fdk-aac-ios
#LAME=`pwd`/thirdparty/lame-ios
OPENSSL=`pwd`/thirdparty/openssl
#X264=`pwd`/thirdparty/ios-x264-lib
XMLPATH=`pwd`/xml
export PATH=$PATH:$XMLPATH

 #
CONFIGURE_FLAGS="--enable-cross-compile --disable-debug  --enable-static --enable-dnsplus --disable-shared --disable-programs \
                 --disable-everything --disable-doc --enable-pic --disable-symver --enable-small  --enable-nonfree \
                 --enable-protocol=rtmp \
                 --enable-protocol=http \
                 --enable-protocol=https \
                 --enable-openssl --enable-protocol=crypto --enable-protocol=tls_openssl \
                 --enable-protocol=tcp \
                 --enable-protocol=udp \
                 --enable-protocol=file \
                 --enable-demuxer=flv \
                 --enable-muxer=flv \
		 --enable-muxer=mjpeg \
		 --enable-demuxer=hls \
                 --enable-demuxer=dash \
                 --enable-demuxer=h264 \
                 --enable-demuxer=aac \
                 --enable-demuxer=wav \
                 --enable-demuxer=mpegts \
                 --enable-demuxer=mov \
		 --enable-muxer=mp4 \
                 --enable-muxer=mp3 \
		 --enable-demuxer=mp3 \
		 --enable-avfilter\
                 --enable-decoder=h264 \
                 --enable-decoder=aac \
		 --enable-decoder=mp3 \
		 --enable-encoder=mjpeg \
                 --enable-encoder=libfdk_aac \
				 --enable-encoder=libmp3lame \
                 --enable-decoder=aasc \
                 --enable-decoder=aac_latm \
                 --enable-parser=aac \
                 --enable-gpl \
		 --enable-parser=h264"
#--enable-libx264 --enable-gpl --enable-encoder=libx264 \
# avresample
#CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-avresample"
if [ "$FDK_AAC" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libfdk-aac --enable-nonfree"
fi

if [ "$LAME" ]
then
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libmp3lame"
fi

ARCHS="arm64 armv7 x86_64"

COMPILE="y"
LIPO="y"

DEPLOYMENT_TARGET="8.0"

if [ "$*" ]
then
	if [ "$*" = "lipo" ]
	then
		# skip compile
		COMPILE=
	else
		ARCHS="$*"
		if [ $# -eq 1 ]
		then
			# skip lipo
			LIPO=
		fi
	fi
fi

if [ "$COMPILE" ]
then
	if [ ! `which yasm` ]
	then
		echo 'Yasm not found'
		if [ ! `which brew` ]
		then
			echo 'Homebrew not found. Trying to install...'
                        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
				|| exit 1
		fi
		echo 'Trying to install Yasm...'
		brew install yasm || exit 1
	fi
	if [ ! `which gas-preprocessor.pl` ]
	then
		echo 'gas-preprocessor.pl not found. Trying to install...'
		(curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
			-o /usr/local/bin/gas-preprocessor.pl \
			&& chmod +x /usr/local/bin/gas-preprocessor.pl) \
			|| exit 1
	fi

    CWD=`pwd`
	if [ ! -r $SOURCE ]
	then
		#echo 'FFmpeg source not found. Trying to download...'
		#curl http://www.ffmpeg.org/releases/$SOURCE.tar.bz2 | tar xj \
		#	|| exit 1
        #tar xj $SOURCE.tar.bz2 
        mkdir -p $CWD/$SOURCE
        tar jxf $SOURCE.tar.bz2 "${SOURCE}"
	fi

	for ARCH in $ARCHS
	do
		echo "building $ARCH..."
		mkdir -p "$SCRATCH/$ARCH"
		cd "$SCRATCH/$ARCH"

		CFLAGS="-arch $ARCH"
		if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
		then
		    PLATFORM="iPhoneSimulator"
		    CFLAGS="$CFLAGS -mios-simulator-version-min=$DEPLOYMENT_TARGET"
		else
		    PLATFORM="iPhoneOS"
		    CFLAGS="$CFLAGS -mios-version-min=$DEPLOYMENT_TARGET " #-fembed-bitcode"
		    if [ "$ARCH" = "arm64" ]
		    then
		        EXPORT="GASPP_FIX_XCODE5=1"
		    fi
		fi

		XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
		CC="xcrun -sdk $XCRUN_SDK clang"

		# force "configure" to use "gas-preprocessor.pl" (FFmpeg 3.3)
		if [ "$ARCH" = "arm64" ]
		then
		    AS="gas-preprocessor.pl -arch aarch64 -- $CC"
		else
		    AS="gas-preprocessor.pl -- $CC"
		fi

		CXXFLAGS="$CFLAGS"
		LDFLAGS="$CFLAGS"
		
		
    if [ "$OPENSSL" ]
		then
			CFLAGS="$CFLAGS -I$OPENSSL/include"
			LDFLAGS="$LDFLAGS -L$OPENSSL/lib"
		fi
		
    if [ "$FDK_AAC" ]
		then
			CFLAGS="$CFLAGS -I$FDK_AAC/include"
			LDFLAGS="$LDFLAGS -L$FDK_AAC/lib"
		fi

    if [ "$LAME" ]
		then
			CFLAGS="$CFLAGS -I$LAME/include"
			LDFLAGS="$LDFLAGS -L$LAME/lib"
		fi
    if [ "$X264" ]
                then
                        CFLAGS="$CFLAGS -I$X264/include"
                        LDFLAGS="$LDFLAGS -L$X264/lib"
                fi

    CFLAGS="$CFLAGS -I$XMLPATH"
		TMPDIR=${TMPDIR/%\/} $CWD/$SOURCE/configure \
		    --target-os=darwin \
		    --arch=$ARCH \
		    --cc="$CC" \
		    --as="$AS" \
		    $CONFIGURE_FLAGS \
		    --extra-cflags="$CFLAGS" \
		    --extra-ldflags="$LDFLAGS" \
		    --prefix="$THIN/$ARCH" \
		|| exit 1

		make -j8 install $EXPORT || exit 1
		cd $CWD
	done
fi

if [ "$LIPO" ]
then
	echo "building fat binaries..."
	mkdir -p $FAT/lib
	set - $ARCHS
	CWD=`pwd`
	cd $THIN/$1/lib
	for LIB in *.a
	do
		cd $CWD
		echo lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB 1>&2
		lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB || exit 1
	done

	cd $CWD
	cp -rf $THIN/$1/include $FAT
fi

rm -rf $THIN
rm -rf $SCRATCHPATH
echo Done
