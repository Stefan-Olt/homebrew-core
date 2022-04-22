class Mvtools < Formula
  desc "Filters for motion estimation and compensation"
  homepage "https://github.com/Stefan-Olt/vapoursynth-mvtools"
  url "https://github.com/Stefan-Olt/vapoursynth-mvtools/archive/refs/tags/v23.2.tar.gz"
  sha256 "f1b31c7e04b9676bf9a6634131c9e518a959d2e9a12da8e5b0ac921f6bdbcdbb"
  license "GPL-2.0-only"
  revision 1
  head "https://github.com/Stefan-Olt/vapoursynth-mvtools.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "fftw"
  depends_on "vapoursynth"

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
