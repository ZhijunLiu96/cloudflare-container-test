# Cloudflare Containers 友好镜像
# 默认端口 8080，对应 Worker 里 MyContainer.defaultPort
# 构建：docker build -t my-container:dev .
# 本地验：docker run --rm -p 8080:8080 -e MESSAGE=hello my-container:dev

# ---- build ----
FROM golang:1.23-bookworm AS build
WORKDIR /src

# 只拷依赖清单，吃满层缓存（和训练机 cache mount 同一思路）
COPY go.mod go.sum* ./
RUN go mod download || true

COPY . .
# 静态链接，最终镜像不带 libc 动态依赖，启动更稳、层更小
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/server ./cmd/server

# ---- runtime ----
FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app

COPY --from=build /out/server /app/server

ENV PORT=8080
ENV MESSAGE="cloudflare-container"

EXPOSE 8080
USER nonroot:nonroot

ENTRYPOINT ["/app/server"]
