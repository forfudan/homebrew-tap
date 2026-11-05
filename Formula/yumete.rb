class Yumete < Formula
  desc "CJK-aware terminal editor for Chinese prose, with the Yume IME built in"
  homepage "https://github.com/forfudan/yumete"
  version "0.19.0"
  license "Apache-2.0"

  # The URLs interpolate `version`, so a release bump is the version above and
  # the three checksums below. Each tarball's SHA-256 is published beside it on
  # the release as `<name>.tar.gz.sha256` — `scripts/update-yumete.sh` fetches
  # them and rewrites this file.
  on_macos do
    on_arm do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-darwin-arm64.tar.gz"
      sha256 "a274dbd79f4a5ac51c1e4934216466ba828be7121669fdafedd0f36131c0d9c9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-linux-x86_64.tar.gz"
      sha256 "937531059f36eae4cec1371b3f36e9141281dc2a13cbfc3e14ba222456796c18"
    end
    on_arm do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-linux-aarch64.tar.gz"
      sha256 "90495057739361b6c04a2d9e530df44f2e90abaa274a0162db5aa7bd096c1fb1"
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
