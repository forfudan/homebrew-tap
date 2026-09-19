# homebrew-tap

Homebrew tap for [forfudan](https://github.com/forfudan) CLI tools.

Currently published:

- [`decimo`](https://github.com/forfudan/decimo) — arbitrary-precision calculator built with Mojo
- [`yumete`](https://github.com/forfudan/yumete) — CJK-aware terminal editor for Chinese prose, with the Yume IME built in

## Install

```bash
brew install forfudan/tap/decimo
brew install forfudan/tap/yumete
```

Or, if you prefer to tap once and then use the bare formula name:

```bash
brew tap forfudan/tap
brew install decimo
```

## Verify

```bash
decimo --version
```

## Upgrade

```bash
brew update
brew upgrade decimo
```

## Uninstall

```bash
brew uninstall decimo
brew untap forfudan/tap
```

## Supported platforms

- macOS arm64 (Apple Silicon)
- Linux x86_64
- Linux arm64 (aarch64)

Each formula installs a self-contained binary plus the bundled Mojo
runtime libraries; no Mojo or Pixi installation is required on the
user's machine.

## Maintaining

Updating a formula for a new release.

The release has to carry its tarballs first. `decimo` attaches them by itself
when a release is published, so check that they are there rather than assuming
it. Then read the checksums from the `.sha256` files published beside them:

```bash
V=0.15.0
for t in darwin-arm64 linux-x86_64 linux-aarch64; do
  printf "%-14s " "$t"
  gh release download "v$V" --repo forfudan/decimo \
    -p "decimo-$V-$t.tar.gz.sha256" -O - | awk '{print $1}'
done
```

In `Formula/decimo.rb`, change the `version` line and the three `sha256`
lines. The URLs interpolate `version`, so they need no edit.

Check that each URL really downloads and really hashes to what the formula
now claims. This is where a bad release goes wrong, and the error a user gets
is unhelpful:

```bash
for t in darwin-arm64 linux-x86_64 linux-aarch64; do
  printf "%-14s " "$t"
  curl -sL "https://github.com/forfudan/decimo/releases/download/v$V/decimo-$V-$t.tar.gz" \
    | shasum -a 256 | awk '{print $1}'
done
```

Then commit, push, and install it for real: `brew update && brew upgrade
decimo`, and run the binary.

### Never rewrite a pushed commit here

No `--amend` after pushing, no force-push, no rebase of `main`.

Homebrew keeps its own clone of this tap, separate from any working copy you
have, under `$(brew --repository)/Library/Taps/forfudan/homebrew-tap`, and
merges into it on `brew update`. A clone that fetched a commit before it was
rewritten is asked to merge two histories that no longer share a tip, which
leaves conflict markers sitting unresolved in the formula.

That happened here in April 2026 and was not noticed until September, because
nothing surfaces it. The clone is not somewhere anyone runs `git status`; the
failure appears as a Ruby syntax error in the formula (`unexpected '>'`,
`unexpected float`) that reads like a broken formula rather than a broken
checkout; and it only fires when someone has a reason to upgrade, which for
four months nobody did.

To repair such a clone -- it is a mirror, so nothing is lost:

```bash
git -C "$(brew --repository)/Library/Taps/forfudan/homebrew-tap" \
  reset --hard origin/main
```

## License

Apache-2.0 (matches the upstream tools).

## Releasing a new `yumete`

The formula pins a version and three checksums. Both come from the release:

```bash
scripts/update-yumete.sh 0.1.0     # rewrites Formula/yumete.rb, shows the diff
git commit -am 'Update yumete to v0.1.0' && git push
```

It refuses to write unless all three `.sha256` files arrived and all three are
64 hex digits — one stale checksum installs the wrong binary on one platform
and nowhere else, which is the hardest kind to notice.
