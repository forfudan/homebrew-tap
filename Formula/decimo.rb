class Decimo < Formula
  desc "Arbitrary-precision calculator"
  homepage "https://github.com/forfudan/decimo"
  version "0.15.0"
  license "Apache-2.0"

  # The URLs interpolate `version`, so a release bump is the version above
  # and the three checksums below. Each tarball's SHA-256 is published beside
  # it on the release as `<name>.tar.gz.sha256`.
  on_macos do
    on_arm do
      url "https://github.com/forfudan/decimo/releases/download/v#{version}/decimo-#{version}-darwin-arm64.tar.gz"
      sha256 "6b91b1483acc0bb99f718ece7db22332a6a563c9d01486275f5d4f250b3616a1"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/forfudan/decimo/releases/download/v#{version}/decimo-#{version}-linux-x86_64.tar.gz"
      sha256 "8071a12ef43c7dea8aec799b862f1a1da91a2bd7a80c341adbfad53b2bb7364c"
    end
    on_arm do
      url "https://github.com/forfudan/decimo/releases/download/v#{version}/decimo-#{version}-linux-aarch64.tar.gz"
      sha256 "eb935778fdec8e9a8d50805d3e08a408d602a418e62b9e4b87939bd76c1dcd67"
    end
  end

  def install
    # Install the binary and the bundled Mojo runtime libs side by side
    # under the formula's prefix. The binary's rpath is set to
    # @executable_path/../lib (macOS) / $ORIGIN/../lib (Linux), so
    # `bin/decimo` will find the dylibs in `lib/` automatically.
    bin.install "bin/decimo"
    lib.install Dir["lib/*"]
    pkgshare.install "README.md", "LICENSE", "NOTICE"
    # Bundle the third-party license texts so users can inspect them
    # via `brew info decimo` / the cellar.
    pkgshare.install "THIRD_PARTY_LICENSES" if Dir.exist?("THIRD_PARTY_LICENSES")
  end

  test do
    # Smoke test: the version flag should mention "decimo".
    assert_match "decimo", shell_output("#{bin}/decimo --version")
  end
end
