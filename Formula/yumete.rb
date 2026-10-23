class Yumete < Formula
  desc "CJK-aware terminal editor for Chinese prose, with the Yume IME built in"
  homepage "https://github.com/forfudan/yumete"
  version "0.11.0"
  license "Apache-2.0"

  # The URLs interpolate `version`, so a release bump is the version above and
  # the three checksums below. Each tarball's SHA-256 is published beside it on
  # the release as `<name>.tar.gz.sha256` — `scripts/update-yumete.sh` fetches
  # them and rewrites this file.
  on_macos do
    on_arm do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-darwin-arm64.tar.gz"
      sha256 "136d8642c8dda3d1451749114bc2a9a1a223f0d792a322409e6bca53bdcd48e7"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-linux-x86_64.tar.gz"
      sha256 "1852989c69be9e2870a11d63cdcaf6a78eb39dee62aaf3b7a8438f96290747a5"
    end
    on_arm do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-linux-aarch64.tar.gz"
      sha256 "0dbdc8dec1b71237de536995cf3f2c28bcacf13266c9bc8347c6e5223ee440c9"
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
    # **The tarball carries three things** (yumete 0.9.0): the binary, the
    # licence and the manual. The README and the changelog came out of it —
    # they are a click away on the release page — so installing them from
    # here would fail the moment the tarball arrived without them.
    doc.install "LICENSE"
    doc.install "docs/manual.md"
  end

  def caveats
    <<~EOS
      yumete types Chinese characters out of the box: the binary carries
      Lingming essential version, a cut of Lingming covering every character
      in CJK 基本區 and 擴展A.

      For the full experience — words, the language model behind fluency mode,
      and the chaifen annotations — install the data as well:

        brew install forfudan/tap/yume-data

      A machine that already runs the Yume input method needs nothing: yumete
      finds its tables where the app put them.

      The manual is at:
        #{doc}/manual.md
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
