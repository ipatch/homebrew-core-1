class Mesa < Formula
  desc "Graphics Library"
  homepage "https://www.mesa3d.org/"
  url "https://mesa.freedesktop.org/archive/mesa-20.1.0.tar.xz"
  mirror "https://www.mesa3d.org/archive/mesa-20.1.0.tar.xz"
  sha256 "2109055d7660514fc4c1bcd861bcba9db00c026119ae222720111732dba27c83"
  revision 1
  head "https://gitlab.freedesktop.org/mesa/mesa.git"

  bottle do
    sha256 "92b7bd991ed224369f30bce554d38c5b3528e5a3f50a1a998f79ead055e685ab" => :catalina
    sha256 "dcdd217b01307e24e1f90dad0de2f2d07bf68d2de25cd23388b2e3a3d9385d8d" => :mojave
    sha256 "e670124c03db8becfe7b8d883c5b6027fb2922f01d52a51a3b2f2958f0f59075" => :high_sierra
    sha256 "07360498e420cf43589a5b4d24c4c2be1d0aeb018ad5cbdd0b447a679d9509b3" => :x86_64_linux
  end

  depends_on "meson-internal" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.8" => :build
  depends_on "freeglut" => :test if OS.mac?
  depends_on "expat"
  depends_on "gettext"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  unless OS.mac?
    depends_on "llvm"
    depends_on "libelf"
    depends_on "linuxbrew/xorg/libdrm"
    depends_on "linuxbrew/xorg/libomxil-bellagio"
    depends_on "linuxbrew/xorg/libva-internal"
    depends_on "linuxbrew/xorg/libvdpau"
    depends_on "linuxbrew/xorg/libx11"
    depends_on "linuxbrew/xorg/libxcb"
    depends_on "linuxbrew/xorg/libxdamage"
    depends_on "linuxbrew/xorg/libxext"
    depends_on "linuxbrew/xorg/libxfixes"
    depends_on "linuxbrew/xorg/libxrandr"
    depends_on "linuxbrew/xorg/libxshmfence"
    depends_on "linuxbrew/xorg/libxv"
    depends_on "linuxbrew/xorg/libxvmc"
    depends_on "linuxbrew/xorg/libxxf86vm"
    depends_on "linuxbrew/xorg/wayland"
    depends_on "linuxbrew/xorg/wayland-protocols"
    depends_on "lm-sensors"
  end

  resource "Mako" do
    url "https://files.pythonhosted.org/packages/72/89/402d2b4589e120ca76a6aed8fee906a0f5ae204b50e455edd36eda6e778d/Mako-1.1.3.tar.gz"
    sha256 "8195c8c1400ceb53496064314c6736719c6f25e7479cd24c77be3d9361cddc27"
  end

  resource "gears.c" do
    url "https://www.opengl.org/archives/resources/code/samples/glut_examples/mesademos/gears.c"
    sha256 "7df9d8cda1af9d0a1f64cc028df7556705d98471fdf3d0830282d4dcfb7a78cc"
  end

  def install
    python3 = Formula["python@3.8"].opt_bin/"python3"
    xy = Language::Python.major_minor_version python3
    ENV.prepend_create_path "PYTHONPATH", buildpath/"vendor/lib/python#{xy}/site-packages"

    resource("Mako").stage do
      system python3, *Language::Python.setup_install_args(buildpath/"vendor")
    end

    resource("gears.c").stage(pkgshare.to_s)

    mkdir "build" do
      args = %w[
        -Dbuildtype=plain
        -Db_ndebug=true
      ]

      if OS.mac?
        args << "-Dplatforms=surfaceless"
        args << "-Dglx=disabled"
      else
        args << "-Dplatforms=x11,wayland,drm,surfaceless"
        args << "-Dglx=auto"
        args << "-Ddri3=true"
        args << "-Ddri-drivers=auto"
        args << "-Dgallium-drivers=auto"
        args << "-Degl=true"
        args << "-Dgbm=true"
        args << "-Dopengl=true"
        args << "-Dgles1=true"
        args << "-Dgles2=true"
        args << "-Dxvmc=true"
        args << "-Dtools=drm-shim,etnaviv,freedreno,glsl,nir,nouveau,xvmc,lima"
      end

      system "meson", *std_meson_args, "..", *args
      system "ninja"
      system "ninja", "install"
    end

    unless OS.mac?
      # Strip executables/libraries/object files to reduce their size
      system("strip", "--strip-unneeded", "--preserve-dates", *(Dir[bin/"**/*", lib/"**/*"]).select do |f|
        f = Pathname.new(f)
        f.file? && (f.elf? || f.extname == ".a")
      end)
    end
  end

  test do
    if OS.mac?
      flags = %W[
        -framework OpenGL
        -I#{Formula["freeglut"].opt_include}
        -L#{Formula["freeglut"].opt_lib}
        -lglut
      ]
      system ENV.cc, "#{pkgshare}/gears.c", "-o", "gears", *flags
    else
      output = shell_output("ldd #{lib}/libGL.so").chomp
      libs = %w[
        libxcb-dri3.so.0
        libxcb-present.so.0
        libxcb-sync.so.1
        libxshmfence.so.1
        libglapi.so.0
        libXext.so.6
        libXdamage.so.1
        libXfixes.so.3
        libX11-xcb.so.1
        libX11.so.6
        libxcb-glx.so.0
        libxcb-dri2.so.0
        libxcb.so.1
        libXxf86vm.so.1
        libdrm.so.2
        libXau.so.6
        libXdmcp.so.6
        libexpat.so.1
      ]

      libs.each do |lib|
        assert_match lib, output
      end
    end
  end
end
