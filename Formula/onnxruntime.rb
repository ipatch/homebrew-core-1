class Onnxruntime < Formula
  desc "Cross-platform, high performance scoring engine for ML models"
  homepage "https://github.com/microsoft/onnxruntime"
  url "https://github.com/microsoft/onnxruntime.git",
    :tag      => "v1.3.0",
    :revision => "eb5da13bb5744c92583e03f8c7a7ddd8198e6771"

  bottle do
    cellar :any
    sha256 "07fa4a98ecb70a70dc1d325401c859e534957307c5d6de419326bc5360b03e2e" => :catalina
    sha256 "90d5fa38c83f552f2b7150af0bd64fa827cb8d1379309b479085ec7a9f215e6e" => :mojave
    sha256 "64a845ee9d26c3e4a443654677efad48985464a3e081f9ce1054d5fee1f45224" => :high_sierra
    sha256 "c0d1073d9114241f715948164f60c754d61fc1fe65d1b5ca03dbd9bee86c7034" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "python@3.8" => :build

  def install
    cmake_args = %W[
      -Donnxruntime_RUN_ONNX_TESTS=OFF
      -Donnxruntime_GENERATE_TEST_REPORTS=OFF
      -DPYTHON_EXECUTABLE=#{Formula["python@3.8"].opt_bin}/python3
      -Donnxruntime_BUILD_SHARED_LIB=ON
      -Donnxruntime_BUILD_UNIT_TESTS=OFF
      -DCMAKE_BUILD_TYPE=Release
    ]

    mkdir "build" do
      system "cmake", "../cmake", *std_cmake_args, *cmake_args
      system "make", "install"
    end
  end

  test do
    if OS.mac?
      (testpath/"test.c").write <<~EOS
        #include <onnxruntime/core/session/onnxruntime_c_api.h>
        #include <stdio.h>
        int main()
        {
          printf("%s\\n", OrtGetApiBase()->GetVersionString());
          return 0;
        }
      EOS
      system ENV.cc, "-I#{include}", "-L#{lib}", "-lonnxruntime",
             testpath/"test.c", "-o", testpath/"test"
      assert_equal version, shell_output("./test").strip
    else
      (testpath/"test.c").write <<~EOS
        #include <onnxruntime/core/session/onnxruntime_c_api.h>
        #include <stdio.h>
        int main()
        {
          if(ORT_API_VERSION)
            printf("ok");
        }
      EOS
      system ENV.cc, "-I#{include}", "-L#{lib}", "-lonnxruntime",
             testpath/"test.c", "-o", testpath/"test"
      assert_equal "ok", shell_output("./test").strip
    end
  end
end
