#!/bin/bash
set -e

ARCH="aarch64"
PACKAGE_ID="com.mdkwork.mitools"
TERMUX_REPO="https://github.com/termux/termux-packages.git"
BOOTSTRAP_SCRIPT="scripts/build-bootstrap.sh"

# Clone Termux packages
if [ ! -d termux-packages ]; then
  git clone --depth 1 "$TERMUX_REPO"
fi

cd termux-packages

# Set custom app package name
sed -i "s/^TERMUX_APP_PACKAGE=.*/TERMUX_APP_PACKAGE=\"$PACKAGE_ID\"/" scripts/properties.sh

# Ensure build-bootstrap.sh is executable
chmod +x "$BOOTSTRAP_SCRIPT"

# Install required packages list
PACKAGE_LIST=(
  abseil-cpp apt bash brotli bzip2 ca-certificates clang command-not-found coreutils
  curl dash debianutils dialog diffutils dos2unix dpkg ed findutils gawk gdbm glib gpgv
  grep gzip inetutils less libandroid-glob libandroid-posix-semaphore libandroid-selinux
  libandroid-support libassuan libbz2 libc++ libcap-ng libcompiler-rt libcrypt libcurl
  libevent libexpat libffi libgcrypt libgmp libgnutls libgpg-error libiconv libidn2 libllvm
  liblz4 liblzma libmd libmpfr libnettle libnghttp2 libnghttp3 libnpth libprotobuf-tadb-core
  libsmartcols libsqlite libssh2 libtirpc libunbound libunistring libusb libxml2 lld llvm
  lsof make nano ncurses-ui-libs ncurses ndk-sysroot net-tools openssl patch pcre2
  pkg-config procps psmisc pv python-pip python-pycryptodomex python readline resolv-conf
  sed tar termux-adb termux-am-socket termux-am termux-api termux-core termux-exec
  termux-keyring termux-licenses termux-tools tur-repo unzip util-linux xxhash xz-utils
  zlib zstd
)

# Run in Docker
../scripts/run-docker.sh <<EOF
cd termux-packages
for pkg in "${PACKAGE_LIST[@]}"; do
  ./build-package.sh -a $ARCH \$pkg || true
done
./scripts/build-bootstrap.sh --architectures $ARCH
EOF

echo "Bootstrap build complete: termux-packages/bootstrap-${ARCH}.zip"
