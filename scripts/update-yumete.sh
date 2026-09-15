#!/usr/bin/env bash
# update-yumete.sh — point Formula/yumete.rb at a release.
#
#   scripts/update-yumete.sh 0.1.0
#
# A release bump is the version and the three checksums, and typing four things
# by hand is how one of them ends up belonging to the previous release. This
# reads the `.sha256` files the release publishes beside each tarball and
# rewrites the formula, then shows the diff. **It does not commit.**
#
# ⚠️ It refuses to write anything unless all three arrived and all three are
# 64 hex digits — a formula with one stale checksum installs the wrong binary
# on one platform and nowhere else, which is the hardest kind to notice.
set -euo pipefail

cd "$(dirname "$0")/.."
REPO="${YUMETE_REPO:-forfudan/yumete}"
VERSION="${1:-}"
if [[ -z "${VERSION}" ]]; then
  echo "usage: scripts/update-yumete.sh <version>   e.g. 0.1.0" >&2
  exit 2
fi
FORMULA="Formula/yumete.rb"
BASE="https://github.com/${REPO}/releases/download/v${VERSION}"

# ⚠️ The order matters: it is the order the three `sha256` lines appear in the
# formula (macOS arm64, Linux x86_64, Linux aarch64).
TARGETS=(darwin-arm64 linux-x86_64 linux-aarch64)

sums=()
for target in "${TARGETS[@]}"; do
  name="yumete-${VERSION}-${target}.tar.gz"
  echo "==> ${name}.sha256"
  # The file holds `<sha>  <name>`; take the first field.
  line="$(curl -fsSL --retry 3 "${BASE}/${name}.sha256")" || {
    echo "!! could not fetch ${name}.sha256 — is the release published?" >&2
    exit 1
  }
  sum="${line%% *}"
  if [[ ! "${sum}" =~ ^[0-9a-f]{64}$ ]]; then
    echo "!! ${name}.sha256 does not hold a SHA-256: ${line}" >&2
    exit 1
  fi
  sums+=("${sum}")
done

# One pass, three replacements, in file order. `awk` rather than three `sed`s:
# the three lines are identical in shape, so a pattern that matches one matches
# all three.
awk -v v="${VERSION}" -v a="${sums[0]}" -v b="${sums[1]}" -v c="${sums[2]}" '
  /^  version "/ { print "  version \"" v "\""; next }
  /^      sha256 "/ {
    n += 1
    if (n == 1) { print "      sha256 \"" a "\""; next }
    if (n == 2) { print "      sha256 \"" b "\""; next }
    if (n == 3) { print "      sha256 \"" c "\""; next }
  }
  { print }
  END { if (n != 3) { print "!! expected 3 sha256 lines, found " n > "/dev/stderr"; exit 1 } }
' "${FORMULA}" > "${FORMULA}.new"
mv "${FORMULA}.new" "${FORMULA}"

echo
git --no-pager diff -- "${FORMULA}"
echo
echo "==> Formula/yumete.rb now points at v${VERSION}. Check it, then:"
echo "      brew install --build-from-source ./Formula/yumete.rb   # or brew audit"
echo "      git commit -am 'Update yumete to v${VERSION}' && git push"
