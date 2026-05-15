FROM debian:bullseye

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    git cmake build-essential libssl-dev libgmp-dev \
    libboost-all-dev libsodium-dev python3 ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --recursive https://github.com/scipr-lab/libiop.git /libiop

WORKDIR /libiop/build

RUN cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DWITH_PROCPS=OFF \
      -DBENCHMARK_ENABLE_TESTING=OFF \
 && make -j2 instrument_ligero_snark test_ligero_snark \
 && echo "=== BUILD OK ==="

COPY scripts/run_bench.sh /run_bench.sh
RUN chmod +x /run_bench.sh

CMD ["/run_bench.sh"]