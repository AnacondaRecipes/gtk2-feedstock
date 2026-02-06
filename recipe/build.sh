#!/usr/bin/env bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-}:${PREFIX}/lib/pkgconfig:$BUILD_PREFIX/$BUILD/sysroot/usr/lib64/pkgconfig:$BUILD_PREFIX/$BUILD/sysroot/usr/share/pkgconfig

GDKTARGET=""
if [[ "${target_platform}" == osx-* ]]; then
    export GDKTARGET="quartz"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -framework Carbon"
elif [[ "${target_platform}" == linux-* ]]; then
    export GDKTARGET="x11"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath=${PREFIX}/lib"
fi

./configure \
  --prefix="${PREFIX}" \
  --disable-dependency-tracking \
  --disable-silent-rules \
  --disable-glibtest \
  --enable-introspection=yes \
  --with-gdktarget="${GDKTARGET}" \
  --disable-visibility \
  --disable-gtk-doc \
  --with-html-dir="${SRC_DIR}/html"

make V=0 -j$CPU_COUNT
# make check -j$CPU_COUNT
make install -j$CPU_COUNT
