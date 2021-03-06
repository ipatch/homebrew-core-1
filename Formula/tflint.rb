class Tflint < Formula
  desc "Linter for Terraform files"
  homepage "https://github.com/wata727/tflint"
  url "https://github.com/terraform-linters/tflint/archive/v0.16.1.tar.gz"
  sha256 "0c44c0d1e648da72d840bd58e7e56755f354484be1f7ea8ac715a2ba2e447f50"
  head "https://github.com/wata727/tflint.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "41f2602ab4f066f5ef8cf765483cb2c4ee24c09bc0c85dac11c6f6fb018b1ff0" => :catalina
    sha256 "4f4d5b10ee95b41ea98507e8a2d56c5358b6d8113bfc63e6dfdb9a0105c951eb" => :mojave
    sha256 "be3a8b12746bc7c620845a17b97a64fe3d4c4e8f862da6b0ee8c61dd3f9c1c41" => :high_sierra
    sha256 "bb49798fd26d73e64236a0af67858243a3ac0e7a28ceb30ff9a8d9fd8bf89f47" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags", "-s -w", "-o", bin/"tflint"
  end

  test do
    (testpath/"test.tf").write <<~EOS
      provider "aws" {
        region = var.aws_region
      }
    EOS

    # tflint returns exitstatus: 0 (no issues), 2 (errors occured), 3 (no errors but issues found)
    assert_match "", shell_output("#{bin}/tflint test.tf")
    assert_equal 0, $CHILD_STATUS.exitstatus
    assert_match version.to_s, shell_output("#{bin}/tflint --version")
  end
end
