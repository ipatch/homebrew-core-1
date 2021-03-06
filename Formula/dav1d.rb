class Dav1d < Formula
  desc "AV1 decoder targeted to be small and fast"
  homepage "https://code.videolan.org/videolan/dav1d"
  url "https://code.videolan.org/videolan/dav1d/-/archive/0.7.0/dav1d-0.7.0.tar.bz2"
  sha256 "8057149f5f08c5ca47e1344fba9046ff84ac85ca409d7adbec8268c707ec5c19"

  bottle do
    cellar :any
    sha256 "8379e085d9affd2875a551e49c4c7caaf1d447f8364b6c7844f73171d9cfbd9b" => :catalina
    sha256 "55b1064d9dc5ea0fc6b226aa07d7b8f64c2a47d8fe3928b6b4a3ac06c7e7d846" => :mojave
    sha256 "672248c6e4bb67b74cb6d367e0bd75e93e70cba1445783c6c8bfde511252f23f" => :high_sierra
    sha256 "a7654eb38652b941257d6e9620dcc5a2c7277eb9f78270e160564ebe46e852c7" => :x86_64_linux
  end

  depends_on "meson" => :build
  depends_on "nasm" => :build
  depends_on "ninja" => :build

  resource "00000000.ivf" do
    url "https://code.videolan.org/videolan/dav1d-test-data/raw/master/8-bit/data/00000000.ivf"
    sha256 "52b4351f9bc8a876c8f3c9afc403d9e90f319c1882bfe44667d41c8c6f5486f3"
  end

  def install
    system "meson", *std_meson_args, "build", "--buildtype", "release"
    system "ninja", "install", "-C", "build"
  end

  test do
    testpath.install resource("00000000.ivf")
    system bin/"dav1d", "-i", testpath/"00000000.ivf", "-o", testpath/"00000000.md5"

    assert_predicate (testpath/"00000000.md5"), :exist?
    assert_match "0b31f7ae90dfa22cefe0f2a1ad97c620", (testpath/"00000000.md5").read
  end
end
