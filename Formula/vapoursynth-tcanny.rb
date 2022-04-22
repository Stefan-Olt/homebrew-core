class VapoursynthTcanny < Formula
  desc "Builds an edge map using canny edge detection"
  homepage "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TCanny"
  url "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TCanny/archive/db4e50bd6237d2d3c7f900b089a6f48e4d5327ae.tar.gz"
  version "db4e50b"
  sha256 "c90f8640aba3b241bd556f96fb026551b98200b5877827019902920aa2b61c4c"
  license "GPL-3.0-or-later"
  revision 1
  head "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TCanny.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "vapoursynth"

  # Fixes memory alignment problem at runtime on aarch64
  patch :DATA

  def install
    system "meson", "--prefix=#{prefix}", "build"
    system "ninja", "-C", "build"
    Dir.mkdir(lib.to_s()) unless File.exist?(lib.to_s())
    cp(["./build/#{shared_library("libtcanny")}"], lib.to_s())
  end

  def caveats
    <<~EOS
      tcanny will not be autoloaded in your VapourSynth scripts. To use it
      use the following code in your scripts:

        vs.core.std.LoadPlugin(path="#{HOMEBREW_PREFIX}/lib/#{shared_library("libtcanny")}")
    EOS
  end

  test do
    script = <<~EOS.split("\n").join(";")
      import vapoursynth as vs
      vs.core.std.LoadPlugin(path="#{lib/shared_library("libtcanny")}")
    EOS

    system Formula["python@3.9"].opt_bin/"python3", "-c", script
  end
end

__END__
--- a/TCanny/TCanny.cpp
+++ b/TCanny/TCanny.cpp
@@ -578,7 +578,7 @@ static void VS_CC tcannyCreate(const VSMap* in, VSMap* out, [[maybe_unused]] voi
 
         auto vectorSize{ 1 };
         {
-            d->alignment = 4;
+            d->alignment = 8;
 
 #ifdef TCANNY_X86
             const auto iset{ instrset_detect() };