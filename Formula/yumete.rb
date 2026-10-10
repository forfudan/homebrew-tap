class Yumete < Formula
  desc "CJK-aware terminal editor for Chinese prose, with the Yume IME built in"
  homepage "https://github.com/forfudan/yumete"
  version "0.6.0"
  license "Apache-2.0"

  # The URLs interpolate `version`, so a release bump is the version above and
  # the three checksums below. Each tarball's SHA-256 is published beside it on
  # the release as `<name>.tar.gz.sha256` — `scripts/update-yumete.sh` fetches
  # them and rewrites this file.
  on_macos do
    on_arm do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-darwin-arm64.tar.gz"
      sha256 "8f85ee9ecb1cd700963deba03fdb751facffeb78874d967fb18d774ffdcfe40e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-linux-x86_64.tar.gz"
      sha256 "95ec2b69a156ca7aa83bf56f38289f3576952d5d00ed923ce1a47848ad431cec"
    end
    on_arm do
      url "https://github.com/forfudan/yumete/releases/download/v#{version}/yumete-#{version}-linux-aarch64.tar.gz"
      sha256 "2ebc1359279d4d497d5d1cf5ae37f4cde57fcccc3d538bd5a349513f3d37a834"
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
    doc.install "README.md", "LICENSE", "CHANGELOG.md"
    doc.install "docs/manual.md"
  end

  def caveats
    <<~EOS
      yumete types 漢字 out of the box: the binary carries 靈明精華版, a cut of
      宇浩's 碼表 covering every character in CJK 基本區 and 擴展A.

      For the full experience — 詞組, the language model behind 整句 input, and
      the 拆分 annotations — install the data as well:

        brew install forfudan/tap/yume-data

      A machine that already runs the 宇浩 input method needs nothing: yumete
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
