class Mvtools < Formula
  desc "Filters for motion estimation and compensation"
  homepage "https://github.com/dubhater/vapoursynth-mvtools"
  url "https://github.com/dubhater/vapoursynth-mvtools/archive/v23.tar.gz"
  sha256 "3b5fdad2b52a2525764510a04af01eab3bc5e8fe6a02aba44b78955887a47d44"
  license "GPL-2.0-only"
  revision 2
  head "https://github.com/dubhater/vapoursynth-mvtools.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "fftw"
  depends_on "vapoursynth"

  # Fixes build issues on arm
  patch :DATA

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats
    <<~EOS
      MVTools will not be autoloaded in your VapourSynth scripts. To use it
      use the following code in your scripts:

        vs.core.std.LoadPlugin(path="#{HOMEBREW_PREFIX}/lib/#{shared_library("libmvtools")}")
    EOS
  end

  test do
    script = <<~EOS.split("\n").join(";")
      import vapoursynth as vs
      vs.core.std.LoadPlugin(path="#{lib/shared_library("libmvtools")}")
    EOS

    system Formula["python@3.9"].opt_bin/"python3", "-c", script
  end
end

__END__
--- a/configure.ac
+++ b/configure.ac
@@ -54,7 +54,7 @@ AS_CASE(
   [i?86],         [BITS="32" NASMFLAGS="$NASMFLAGS -DARCH_X86_64=0" X86="true"],
   [x86_64|amd64], [BITS="64" NASMFLAGS="$NASMFLAGS -DARCH_X86_64=1 -DPIC" X86="true"],
   [powerpc*],     [PPC="true"],
-  [arm*],         [ARM="true"],
+  [arm*|aarch*],  [ARM="true"],
   [AC_MSG_ERROR([Unknown host CPU: $host_cpu.])]
 )
 
--- a/src/SADFunctions.cpp
+++ b/src/SADFunctions.cpp
@@ -646,7 +646,7 @@ static unsigned int Satd_C(const uint8_t *pSrc, intptr_t nSrcPitch, const uint8_
     }
 }
 
-
+#if defined(MVTOOLS_X86)
 template <unsigned nBlkWidth, unsigned nBlkHeight, InstructionSets opt>
 static unsigned int Satd_SIMD(const uint8_t *pSrc, intptr_t nSrcPitch, const uint8_t *pRef, intptr_t nRefPitch) {
     const unsigned partition_width = 16;
@@ -676,7 +676,7 @@ static unsigned int Satd_SIMD(const uint8_t *pSrc, intptr_t nSrcPitch, const uin
 
     return sum;
 }
-
+#endif
 
 #if defined(MVTOOLS_X86)
 #define SATD_X264_U8_MMX(width, height) \
@@ -753,12 +753,14 @@ static const std::unordered_map<uint32_t, SADFunction> satd_functions = {
     SATD_X264_U8_AVX2(8, 8)
     SATD_X264_U8_AVX2(16, 8)
     SATD_X264_U8_AVX2(16, 16)
+    #if defined(MVTOOLS_X86)
     SATD_U8_SIMD(32, 16)
     SATD_U8_SIMD(32, 32)
     SATD_U8_SIMD(64, 32)
     SATD_U8_SIMD(64, 64)
     SATD_U8_SIMD(128, 64)
     SATD_U8_SIMD(128, 128)
+    #endif
 };
 
 SADFunction selectSATDFunction(unsigned width, unsigned height, unsigned bits, int opt, unsigned cpu) {
