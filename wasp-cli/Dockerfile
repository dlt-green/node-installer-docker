ARG GOLANG_IMAGE_TAG=1.18-bullseye

# Build stage
FROM golang:${GOLANG_IMAGE_TAG} AS build
ARG BUILD_TAGS="rocksdb,builtin_static"
ARG BUILD_LD_FLAGS=""
ARG BUILD_TARGET="./..."

WORKDIR /wasp

# Make sure that modules only get pulled when the module file has changed
COPY go.mod go.sum ./
RUN go mod download
RUN go mod verify

# Project build stage
COPY . .

RUN go build -o . -tags=${BUILD_TAGS} -ldflags="${BUILD_LD_FLAGS}" ${BUILD_TARGET}
RUN cd tools/wasp-cli && go build -o . -tags=${BUILD_TAGS} -ldflags="${BUILD_LD_FLAGS}" ${BUILD_TARGET}

# Wasp build
FROM gcr.io/distroless/cc

ARG FINAL_BINARY="wasp-cli"

WORKDIR /wasp-cli

COPY --from=build /wasp/${FINAL_BINARY} /usr/bin/

CMD ["wasp-cli", "-c", "/wasp-cli/wasp-cli.json"]
