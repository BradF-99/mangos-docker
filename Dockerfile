# Stage 1: Build CMangos
FROM debian:stable AS build

# Install our build dependencies
RUN apt update
RUN apt install grep build-essential gcc g++ automake git-core autoconf make patch cmake libmariadb-dev libmariadb-dev-compat mariadb-server libtool libssl-dev binutils libz-dev libc6 libbz2-dev subversion libboost-all-dev p7zip-full tmux net-tools curl -y

WORKDIR /mangos

COPY ./mangos-classic/ /mangos/
COPY ./modules/ /mangos/src/modules/

WORKDIR /mangos/build

RUN cmake ../ -DCMAKE_INSTALL_PREFIX=/mangos/run -DPCH=1 -DDEBUG=0 -DBUILD_PLAYERBOTS=ON -DBUILD_AHBOT=ON -DBUILD_MODULES=ON -DBUILD_MODULE_IMMERSIVE=ON -DBUILD_MODULE_ACHIEVEMENTS=ON -DBUILD_MODULE_TRANSMOG=ON -DBUILD_MODULE_HARDCORE=ON -DBUILD_MODULE_DUALSPEC=ON -DBUILD_MODULE_TRAININGDUMMIES=ON -DBUILD_MODULE_BALANCING=ON -DBUILD_MODULE_PALADINPOWER=ON -DBUILD_MODULE_BARBER=ON -DBUILD_MODULE_CLASSLESS=ON -DBUILD_MODULE_VOICEOVER=ON -DBUILD_METRICS=ON -Wno-dev
RUN make -j $(nproc)
RUN make install

# Stage 2: Build runtime image
FROM debian:stable AS final

WORKDIR /mangos

# We use a script to make the final image a bit smaller
COPY ./docker/ ./docker
RUN ./docker/final-install-packages.sh

COPY --from=build /mangos/run .

WORKDIR /mangos/bin

ENTRYPOINT ["./mangosd"]
