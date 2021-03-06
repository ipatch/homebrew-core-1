require "language/haskell"

class Taskell < Formula
  include Language::Haskell::Cabal

  desc "Command-line Kanban board/task manager with support for Trello"
  homepage "https://taskell.app"
  url "https://github.com/smallhadroncollider/taskell/archive/1.9.3.tar.gz"
  sha256 "bbe81d4a8f04ca6bde0ef6c18b5cc29730e876ea40b0c21a8dfe9c538aa39235"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "2f049bf834c2ab324f6413c8ab99e10fb4c83fd2aa26ef22ace2014e40c653b9" => :catalina
    sha256 "68b52580165c2f43647a7208b9c1c005ad1c349d6de8c7d2f81f8aee3ec5244f" => :mojave
    sha256 "cd5af708aa5738e8e7fe85250f3490a8f8f552d9a385c30b885d6e77795b3cc1" => :high_sierra
    sha256 "6c2734a0d98761259a41e99482c987ed71d482d737e964f5e7661905d2d9f8a3" => :x86_64_linux
  end

  depends_on "cabal-install" => :build
  depends_on "ghc@8.8" => :build
  depends_on "hpack" => :build

  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  def install
    system "hpack"
    install_cabal_package
  end

  test do
    (testpath/"test.md").write <<~EOS
      ## To Do

      - A thing
      - Another thing
    EOS

    expected = <<~EOS
      test.md
      Lists: 1
      Tasks: 2
    EOS

    assert_match expected, shell_output("#{bin}/taskell -i test.md")
  end
end
