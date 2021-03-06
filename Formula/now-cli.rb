require "language/node"

class NowCli < Formula
  desc "The command-line interface for Now"
  homepage "https://zeit.co/now"
  url "https://registry.npmjs.org/now/-/now-19.0.1.tgz"
  sha256 "22abf055e1b89f647b8d500d3c6b6a4cbd7a4c69460941a8828b0c40014152f2"

  bottle do
    cellar :any_skip_relocation
    sha256 "e5e73029348742f5e9b75ccf1149ab355ce9f4036bf37bb17825980e267e16bb" => :catalina
    sha256 "1ffb6470c551d85fa32557a0c2fd1ba422098ac6c4da8d846ff217d1018138a6" => :mojave
    sha256 "57697c2a958eb74ebf1603f83d7decec6f1cad70ad0ca9d98cdb18a64c301c82" => :high_sierra
    sha256 "1ea9e57abe617119d4191937ceaf84fa95c75df03f5ec71ecf04331c3300bcab" => :x86_64_linux
  end

  depends_on "node"

  def install
    rm Dir["dist/{*.exe,xsel}"]
    inreplace "dist/index.js", "t.default=getUpdateCommand",
                               "t.default=async()=>'brew upgrade now-cli'"
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/now", "init", "jekyll"
    assert_predicate testpath/"jekyll/_config.yml", :exist?, "_config.yml must exist"
    assert_predicate testpath/"jekyll/README.md", :exist?, "README.md must exist"
  end
end
