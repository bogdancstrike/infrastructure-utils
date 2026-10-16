# The community project no longer publishes the old container images.
# Build the last source release explicitly; prefer ../seaweedfs for new setups.
FROM golang:1.27.2-alpine AS builder
ARG MINIO_VERSION=RELEASE.2025-10-15T17-29-55Z
RUN apk add --no-cache git
RUN git clone --depth 1 --branch "${MINIO_VERSION}" https://github.com/minio/minio.git /src
WORKDIR /src
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/minio .

FROM alpine:3.24.2
RUN apk add --no-cache ca-certificates && mkdir /data && chown 1000:1000 /data
COPY --from=builder /out/minio /usr/local/bin/minio
USER 1000:1000
EXPOSE 9000 9001
ENTRYPOINT ["minio"]
