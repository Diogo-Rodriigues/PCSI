cmake_minimum_required(VERSION 3.10)

# Dá um nome profissional ao teu projeto
project(ZKP_VOLE_Benchmarks VERSION 1.0)

# O emp-zk requer C++ moderno (C++20 é o ideal para as versões mais recentes)
set(CMAKE_CXX_STANDARD 20)

# Aponta para onde o Docker instalou o emp-toolkit
include_directories(/usr/local/include/emp-ot/)
include_directories(/usr/local/include/emp-tool/)
include_directories(/usr/local/include/emp-zk/)

# Flags de otimização de performance (Crucial para testes de velocidade reais!)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native -O2")

# Diz ao CMake para atirar os executáveis prontos para a pasta "bin"
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)

# Procurar os pacotes do EMP instalados
FIND_PACKAGE(EMP-TOOL REQUIRED)
FIND_PACKAGE(EMP-OT REQUIRED)
FIND_PACKAGE(EMP-ZK REQUIRED)
FIND_PACKAGE(Threads REQUIRED)

# Agrupar as bibliotecas do EMP e do sistema (criptografia e threads)
set(ZK_LIBRARIES "/usr/local/lib/libemp-tool.so"
                 "/usr/local/lib/libemp-zk.so"
                 "-lpthread"
                 "-lssl"
                 "-lcrypto")

# 1. Teste Boolean-Heavy: Função de Hash SHA-256
add_executable(bench_sha256 src/sha256.cpp)
target_link_libraries(bench_sha256 ${ZK_LIBRARIES})

# 2. Teste Arithmetic-Heavy: Multiplicação de Matrizes
add_executable(bench_matrix src/matrix.cpp)
target_link_libraries(bench_matrix ${ZK_LIBRARIES})