class Yumete < Formula
  desc "CJK-aware terminal editor for Chinese prose, with the Yume IME built in"
  homepage "https://github.com/forfudan/yumete"
  version "0.22.0"
  license "Apache-2.0"

  # The URLs interpolate `version`, so a release bump is the version above and
  # the three checksums below. Each tarball's SHA-256 is published beside it on
  # the release as `<name>.tar.gz.sha256` — `scripts/update-yumete.sh` fetches
  # them and rewrites this file.
  on_macos do
    on_arm do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-darwin-arm64.tar.gz"
      sha256 "bad18e52b83a1f5c11813f6b7a8d54e5f3be8fa34cebab0d73a225e97c10d8de"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-linux-x86_64.tar.gz"
      sha256 "91af84685185efc1ada73b051395a511d86c9b27ad89c05ef1853470dcf2e51f"
    end
    on_arm do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-linux-aarch64.tar.gz"
      sha256 "b5bbd250e1384ee03133322252eb4806a504d81fbe4dbbe74e9d375222ee9ab0"
    end
  end

  def install
    bin.install "bin/yumete"
    # **Both names, because the README promises both.** 「It installs under both
    # names: `yumete`, and `ye` for the one you actually type」 — and until
    # 2026-09-16 the formula installed one, so everyone who arrived by `brew`
    # found that sentence to be false. A symlink rather than a second copy: it
    # is the same 8 MB binary and it must not be possible for the two to differ.
    bin.install_symlink bin/"yumete" => "ye"
    # ⚠️ **Not `pkgshare`.** `pkgshare` *is* `share/yumete`, and that is the
    # directory yumete scans for 宇浩 IME data (`installed_data_dirs`) — the
    # one a separate `yume-data` formula links its tables into so that the two
    # meet in one prefix. Putting documentation there is how the two formulae
    # would come to fight over the same links.
    # **The tarball carries the binary, the licence and the theme licences**
    # (yumete 0.17.0). The manual moved to https://yumete.shurufa.app/ and
    # left the tarball, so a `doc.install` of it fails the whole install.
    doc.install "LICENSE"
    doc.install "licenses"
  end

  def caveats
    <<~EOS
      yumete types Chinese characters out of the box: the binary carries
      Lingming essential version, a cut of Lingming covering every character
      in CJK 基本區 and 擴展A.

      For the full experience — words, the language model behind fluency mode,
      and the chaifen annotations — install the Yume input method itself, or
      point $YUMETE_DATA_DIR at a data directory. A machine that already runs
      Yume needs nothing: yumete finds its tables where the app put them.

      The manual is at:
        https://yumete.shurufa.app/
    EOS
  end

  test do
    # The version the tarball is named for is the version inside it.
    assert_match "yumete #{version}", shell_output("#{bin}/yumete --version")

    # …and it draws a page. `--shot` runs the whole launch without a terminal,
    # so this catches a binary that starts and then cannot render.
    (testpath/"a.md").write("那年冬天。\n")
    assert_match "那年冬天", shell_output("#{bin}/yumete --shot=40x6 #{testpath}/a.md")
  end
end
