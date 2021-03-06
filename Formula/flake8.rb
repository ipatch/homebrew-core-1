class Flake8 < Formula
  include Language::Python::Virtualenv

  desc "Lint your Python code for style and logical errors"
  homepage "https://flake8.pycqa.org/"
  url "https://gitlab.com/pycqa/flake8/-/archive/3.8.2/flake8-3.8.2.tar.bz2"
  sha256 "6185d7b5754dc3672f0ca5b380c5654b7511d4a6ae1439525608e0c3b2321d24"
  head "https://gitlab.com/PyCQA/flake8.git", :shallow => false

  bottle do
    cellar :any_skip_relocation
    sha256 "38a01e872bef609a26d213c04e17175b9538ca51fb88b80e53f99ed900cf24dd" => :catalina
    sha256 "5960ac5f10ae4d51310b4c6b4596872e7ba9ed921507988602439c1fa710325b" => :mojave
    sha256 "59b2d53c686beac8c075e467a92a2245956939767f47b17edca81a5d5ae13c3b" => :high_sierra
    sha256 "0d3993520e43f197c3146b0b5146c10a99faaaafd777913251cc49a4a9136fc3" => :x86_64_linux
  end

  depends_on "python@3.8"

  resource "mccabe" do
    url "https://files.pythonhosted.org/packages/06/18/fa675aa501e11d6d6ca0ae73a101b2f3571a565e0f7d38e062eec18a91ee/mccabe-0.6.1.tar.gz"
    sha256 "dd8d182285a0fe56bace7f45b5e7d1a6ebcbf524e8f3bd87eb0f125271b8831f"
  end

  resource "pycodestyle" do
    url "https://files.pythonhosted.org/packages/bb/82/0df047a5347d607be504ad5faa255caa7919562962b934f9372b157e8a70/pycodestyle-2.6.0.tar.gz"
    sha256 "c58a7d2815e0e8d7972bf1803331fb0152f867bd89adf8a01dfd55085434192e"
  end

  resource "pyflakes" do
    url "https://files.pythonhosted.org/packages/f1/e2/e02fc89959619590eec0c35f366902535ade2728479fc3082c8af8840013/pyflakes-2.2.0.tar.gz"
    sha256 "35b2d75ee967ea93b55750aa9edbbf72813e06a66ba54438df2cfac9e3c27fc8"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"test.py").write <<~EOS
      print("Hello World!")
    EOS

    system "#{bin}/flake8", "test.py"
  end
end
