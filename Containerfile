FROM docker.io/library/fedora:latest AS builder
ENV CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
RUN <<EORUN
    set -eu
    dnf -y install boost-devel cmake gcc-c++ git libevdev-devel systemd-devel yaml-cpp-devel
    # Build interception-tools
    git clone --depth 1 https://gitlab.com/interception/linux/tools.git interception-tools
    cd interception-tools
    cmake -B build $CMAKE_FLAGS
    cmake --build build
    mkdir /out
    mv build/{intercept,mux,udevmon,uinput} /out
    # Build caps2esc plugin
    git clone --depth 1 https://gitlab.com/interception/linux/plugins/caps2esc.git
    cd caps2esc
    cmake -B build $CMAKE_FLAGS
    cmake --build build
    mv build/caps2esc /out
EORUN

FROM scratch AS caps2esc
COPY --from=builder /out .
