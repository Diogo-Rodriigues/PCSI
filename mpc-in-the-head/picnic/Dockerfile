FROM debian:bullseye

# 1. Dependências do sistema
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --no-install-recommends \
    git cmake build-essential libssl-dev ca-certificates python3

# 2. Clonar e compilar a implementação de referência Picnic (NIST Round 3)
RUN git clone --depth 1 https://github.com/IAIK/Picnic.git /picnic && \
    cd /picnic && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make -j$(nproc)

WORKDIR /picnic

# 3. Copiar o script de benchmark
COPY scripts/run_bench.sh /run_bench.sh
RUN chmod +x /run_bench.sh

CMD ["/run_bench.sh"]
