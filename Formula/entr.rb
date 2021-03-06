class Entr < Formula
  desc "Run arbitrary commands when files change"
  homepage "http://entrproject.org/"
  url "http://entrproject.org/code/entr-4.5.tar.gz"
  sha256 "d6cbb3109d50d0d8e28fccd9843c522f896f00d4bfde7b1588cd01c1536afa21"
  head "https://github.com/eradman/entr.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "2b4d9fac8d479903227ae181d1d1d7e403d7a6ebef7848be4365ad80e8e7e380" => :catalina
    sha256 "b83f3bd4f30ebcd65d22516f04ad7aec3260c75151488cc6b3ae15829872d3ec" => :mojave
    sha256 "a08481646a0439de7643b26c41d100adc099ba573aabb8ca45723ce9fbfa97e2" => :high_sierra
    sha256 "8b29a8205ae06ff6b3e4cd262347c9c089f684b68e360c3743119813b9f8aad7" => :x86_64_linux
  end

  def install
    ENV["PREFIX"] = prefix
    ENV["MANPREFIX"] = man
    system "./configure"
    system "make"
    system "make", "install"
  end

  test do
    touch testpath/"test.1"
    fork do
      sleep 0.5
      touch testpath/"test.2"
    end
    assert_equal "New File", pipe_output("#{bin}/entr -p -d echo 'New File'", testpath).strip
  end
end
