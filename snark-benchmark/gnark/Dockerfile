FROM golang:1.22-bookworm

WORKDIR /app

COPY go.mod ./

COPY go.sum ./

RUN go mod tidy

COPY . .

# Cria a pasta de resultados dentro do contentor
RUN mkdir -p results

CMD ["sh", "-c", "go run main.go | tee results/bench_output.txt"]