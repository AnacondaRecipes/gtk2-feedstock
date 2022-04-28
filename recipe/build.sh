#!/usr/bin/env bash
set -e
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

export XDG_DATA_DIRS=${XDG_DATA_DIRS}:$PREFIX/share
find .. -name '*.la' -exec rm -f {} \;

configure_args=(
    --disable-dependency-tracking
    --disable-silent-rules
    --disable-glibtest
    --enable-introspection=yes
    --disable-visibility
    --with-html-dir="${SRC_DIR}/html"
    --includedir=${PREFIX}/include
    --libdir=${PREFIX}/lib
)

GDKTARGET=""
if [[ "${target_platform}" == osx-* ]]; then
    export GDKTARGET="quartz"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -framework Carbon"
    configure_ars+=(
        --with-gdktarget="${GDKTARGET}"
    )
elif [[ "${target_platform}" == linux-* ]]; then
    export GDKTARGET="x11"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath=${PREFIX}/lib"
    configure_args+=(
        --x-includes="${CONDA_BUILD_SYSROOT}/usr/include"
        --x-libraries="$(find ${CONDA_BUILD_SYSROOT} -name libX11.so -exec dirname {} \;)"
        --with-gdktarget="${GDKTARGET}"
    )
fi



#export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config
export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig"
#export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${CONDA_BUILD_SYSROOT}/usr/lib/pkgconfig:${CONDA_BUILD_SYSROOT}/usr/lib64/pkgconfig:${CONDA_BUILD_SYSROOT}/usr/share/pkgconfig:${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/lib64/pkgconfig:${PKG_CONFIG_PATH}"
./configure \
    --prefix="${PREFIX}" \
    "${configure_args[@]}"

make V=0 -j$CPU_COUNT
# make check -j$CPU_COUNT
make install -j$CPU_COUNT
