# ffmpeg_build
基于mac环境编译ffmpeg4.2.0
支持移动端环境：android ios的环境。
android脚本
ios的脚本

一、遇到两个问题：
1、 configure 文件 clang修改
    把 默认的 clang 修改为 gcc
    if test "$target_os" = android; then
       # cc_default="clang"
         cc_default="gcc"
   fi
   
   
2、上面演示的build_android.sh 脚本中使用的ndk版本是r14,那在FFmpeg 4.2版本中,你应该会遇到这个error:

  libavformat/udp.c: In function 'udp_set_multicast_sources':
  libavformat/udp.c:290:28: error: request for member 's_addr' in something not a structure or union

  网上很少关于这个错误的描述,官方的回复也没看出来啥子有用的价值.
  https://trac.ffmpeg.org/ticket/7741
  解决方法:
  有两种解决方案
    （1）.ndk版本升到r17c
    （2）.如果不想升ndk版本的,那就修改libavformat/udp.c 文件,把报错的相关代码注释掉就好.前提是你的项目中用不到这块功能.


第三方库编译：参考这里给出编译好的静态库，


https://juejin.im/post/6844904048303276045#heading-9  

https://www.jianshu.com/p/f52c19b3175b



libcur 编译
