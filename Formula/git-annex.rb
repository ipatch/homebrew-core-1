require "language/haskell"

class GitAnnex < Formula
  include Language::Haskell::Cabal

  desc "Manage files with git without checking in file contents"
  homepage "https://git-annex.branchable.com/"
  url "https://hackage.haskell.org/package/git-annex-8.20200522/git-annex-8.20200522.tar.gz"
  sha256 "a81fd3c09126b740e586507b9327ab59f09753ea57a17509b641b29a6699e1ec"
  head "git://git-annex.branchable.com/"

  bottle do
    cellar :any
    sha256 "1a455e13615f747859e1b8ad02cd345e2ef6fbe16f3b7bdaa8af89aa940316fe" => :catalina
    sha256 "481114ac0d3952086c91c9cb3fdfbeb7d7d52415450310731d211a408d3a9818" => :mojave
    sha256 "5e392129bfa3ee1484653c431d269d525d8c657019a3029feea877dc77a0a755" => :high_sierra
    sha256 "3709fd2412280c5b7017271f6e90db104d680920cb75a413473ca4440a0fa398" => :x86_64_linux
  end

  depends_on "cabal-install" => :build
  depends_on "ghc@8.6" => :build
  depends_on "pkg-config" => :build
  depends_on "gsasl"
  depends_on "libmagic"
  depends_on "quvi"

  def install
    install_cabal_package "--constraint", "http-conduit>=2.3",
                          "--constraint", "network>=2.6.3.0",
                          :using => ["alex", "happy", "c2hs"],
                          :flags => ["s3", "webapp"]
    bin.install_symlink "git-annex" => "git-annex-shell"
  end

  plist_options :manual => "git annex assistant --autostart"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <false/>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/git-annex</string>
            <string>assistant</string>
            <string>--autostart</string>
          </array>
        </dict>
      </plist>
    EOS
  end

  test do
    # make sure git can find git-annex
    ENV.prepend_path "PATH", bin
    # We don't want this here or it gets "caught" by git-annex.
    rm_r "Library/Python/2.7/lib/python/site-packages/homebrew.pth"

    system "git", "init"
    system "git", "annex", "init"
    (testpath/"Hello.txt").write "Hello!"
    assert !File.symlink?("Hello.txt")
    assert_match /^add Hello.txt.*ok.*\(recording state in git\.\.\.\)/m, shell_output("git annex add .")
    system "git", "commit", "-a", "-m", "Initial Commit"
    assert File.symlink?("Hello.txt")

    # The steps below are necessary to ensure the directory cleanly deletes.
    # git-annex guards files in a way that isn't entirely friendly of automatically
    # wiping temporary directories in the way `brew test` does at end of execution.
    system "git", "rm", "Hello.txt", "-f"
    system "git", "commit", "-a", "-m", "Farewell!"
    system "git", "annex", "unused"
    assert_match "dropunused 1 ok", shell_output("git annex dropunused 1 --force")
    system "git", "annex", "uninit"
  end
end
