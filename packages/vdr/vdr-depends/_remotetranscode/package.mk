# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="_remotetranscode"
PKG_VERSION="ddc43d621d30c9bdf0698deb9541ddbee12ff70b"
PKG_SHA256="13021b3145fc252994d8c21686b0636f17e837965df2c8a9d3d8892f97c28153"
PKG_LICENSE="unknown"
PKG_SITE="https://github.com/Zabrimus/remotetranscode"
PKG_URL="https://github.com/Zabrimus/remotetranscode/archive/${PKG_VERSION}.zip"
PKG_SOURCE_DIR="remotetranscode-${PKG_VERSION}"
PKG_DEPENDS_TARGET="toolchain ffmpeg _thrift"
PKG_LONGDESC="remotetranscode"
PKG_TOOLCHAIN="meson"
PKG_BUILD_FLAGS="+speed"

if [ "${OS_MAJOR}" = "20" ]; then
	PKG_DEPENDS_TARGET+=" _inputstream.adaptive"
fi

RT_PREFIX="/usr/local"

PKG_MESON_OPTS_TARGET="--prefix=${RT_PREFIX} \
                       --bindir=${RT_PREFIX}/bin \
                       --libdir=${RT_PREFIX}/lib \
                       --libexecdir=${RT_PREFIX}/lib \
                       --sbindir=${RT_PREFIX}/bin"

pre_configure_target() {
   export SSL_CERT_FILE=$(get_install_dir openssl)/etc/ssl/cacert.pem.system
}

pre_make_target() {
  export PKG_CONFIG_DISABLE_SYSROOT_PREPEND="yes"
  export LDFLAGS="$(echo ${LDFLAGS} | sed -e "s|-Wl,--as-needed||") -L${SYSROOT_PREFIX}/usr/local/lib"
}

post_makeinstall_target() {
  # prepare sample archive
  # mkdir -p ${INSTALL}/storage/remotetranscode-sample
  # mv ${INSTALL}/usr/local/movie ${INSTALL}/storage/remotetranscode-sample
  mkdir -p ${INSTALL}/storage/.config/vdropt-sample
  cp -r ${PKG_BUILD}/config/* ${INSTALL}/storage/.config/vdropt-sample

  # copy systemd services
  mkdir -p ${INSTALL}/usr/local/system.d

  if [ "${OS_MAJOR}" = "20" ]; then
  	cp ${PKG_DIR}/_system.d/remotetranscode.service.CE20 ${INSTALL}/usr/local/system.d/remotetranscode.service
  else
  	cp ${PKG_DIR}/_system.d/remotetranscode.service ${INSTALL}/usr/local/system.d/remotetranscode.service
  fi

  # zip everything
  mkdir -p ${INSTALL}/usr/local/config
  cd ${INSTALL}
  # zip -qrum9 ${INSTALL}/usr/local/config/web-remotetranscode-sample.zip storage/remotetranscode-sample
  zip -qrum9 ${INSTALL}/usr/local/config/remotetranscode-sample-config.zip storage/.config
}
