class Xgboost < Formula
  desc "Scalable, Portable and Distributed Gradient Boosting Library"
  homepage "https://xgboost.ai/"
  url "https://github.com/dmlc/xgboost.git",
      :tag      => "v1.1.0",
      :revision => "f5d4fddafec7ff0e908b776e0cebf554df6b89d0"

  bottle do
    cellar :any
    sha256 "7641d5ec78f41c5970703a62d6a06cf75ca8859b98e0d6820119672c4b985942" => :catalina
    sha256 "50e6661f93dc3d8c87801b61e22f1de87fed8e50c92fc724c920035d7bd6724e" => :mojave
    sha256 "fe443009e2572f31ab0d5f0e7138d3f62fbf24f148e12cc7558ae012cf72a242" => :high_sierra
    sha256 "f9842ddcf7a717939f9e3a4e86e2061fba1fe81931252805d8518788e34f4740" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "libomp"

  def install
    mkdir "build" do
      system "cmake", *std_cmake_args, ".."
      system "make"
      system "make", "install"
    end
    pkgshare.install "demo"
  end

  test do
    cp_r (pkgshare/"demo"), testpath
    cd "demo/data" do
      cp "../binary_classification/mushroom.conf", "."
      system "#{bin}/xgboost", "mushroom.conf"
    end
  end
end
