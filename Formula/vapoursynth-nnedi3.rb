class VapoursynthNnedi3 < Formula
  desc "Neural-network intra-field deinterlacer / upscaler"
  homepage "https://github.com/Stefan-Olt/vapoursynth-nnedi3"
  url "https://github.com/Stefan-Olt/vapoursynth-nnedi3/archive/refs/tags/v12.1.tar.gz"
  sha256 "08174a2f57fa16d3baa825583285236ee2d586d9080e79699721cefaeb6f9805"
  license "GPL-2.0-or-later"
  revision 1
  head "https://github.com/Stefan-Olt/vapoursynth-nnedi3.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "yasm" => :build
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

        vs.core.std.LoadPlugin(path="#{HOMEBREW_PREFIX}/lib/#{shared_library("libnnedi3")}")
    EOS
  end

  test do
    script = <<~EOS.split("\n").join(";")
      import vapoursynth as vs
      vs.core.std.LoadPlugin(path="#{lib/shared_library("libnnedi3")}")
    EOS

    system Formula["python@3.9"].opt_bin/"python3", "-c", script
  end
end
