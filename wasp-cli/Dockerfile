ARG GOLANG_IMAGE_TAG=1.18-bullseye

# Build stage
FROM golang:${GOLANG_IMAGE_TAG} AS build
ARG BUILD_TAGS=rocksdb
ARG BUILD_LD_FLAGS=""
ARG BUILD_TARGET="."

LABEL org.label-schema.description="Wasp"
LABEL org.label-schema.name="iotaledger/wasp"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.vcs-url="https://github.com/iotaledger/wasp"

# Ensure ca-certificates are up to date
RUN update-ca-certificates

# Set the current Working Directory inside the container
RUN mkdir /scratch
WORKDIR /scratch

# Prepare the folder where we are putting all the files
RUN mkdir /app
RUN mkdir /app/waspdb

# Make sure that modules only get pulled when the module file has changed
COPY go.mod go.sum ./

# Download go modules
RUN go mod download
RUN go mod verify

# Project build stage
COPY . .

# Build the binary
RUN go build -o /app/wasp -a -tags="$BUILD_TAGS" -ldflags="${BUILD_LD_FLAGS}" ${BUILD_TARGET}
RUN cd tools/wasp-cli && go build -o /app/wasp-cli -tags="${BUILD_TAGS}" -ldflags="${BUILD_LD_FLAGS}" ${BUILD_TARGET}

############################
# Image
############################
# https://console.cloud.google.com/gcr/images/distroless/global/cc-debian11
# using distroless cc "nonroot" image, which includes everything in the base image (glibc, libssl and openssl)
FROM gcr.io/distroless/cc-debian11:nonroot

WORKDIR /app

COPY --chown=nonroot:nonroot --from=build /app/wasp-cli /app

ENTRYPOINT ["/app/wasp-cli"]
