FROM haskell:8

# get ContainerPilot release
ARG CONTAINERPILOT_VERSION=3.8.0
RUN export CP_SHA1=84642c13683ddae6ccb63386e6160e8cb2439c26 \
    && apt-get update && apt-get install -y wget \
    && wget --quiet -O /tmp/containerpilot.tar.gz \
    "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
    && echo "${CP_SHA1}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /bin \
    && rm /tmp/containerpilot.tar.gz

# setup duckling
RUN git clone https://github.com/tagshelfsrl/duckling.git

WORKDIR /duckling

# NOTE:`stack build` will use as many cores as are available to build
# in parallel. However, this can cause OOM issues as the linking step
# in GHC can be expensive. If the build fails, try specifying the
# '-j1' flag to force the build to run sequentially.
ARG J_FLAG=""
RUN stack setup && stack build ${J_FLAG}

# add ContainerPilot configuration and env
ENV APP_NAME=duckling \
    PUB_ADDR=0.0.0.0 \
    PUB_PORT=8000 \
    CONSUL_ADDR=localhost \
    CONSUL_PORT=8500 \
    SCHEME=http \
    CONSUL_TOKEN=WoWmuchSecure! \
    TLS_VERIFY=true \
    AGENT_BIND= \
    CONTAINERPILOT=/etc/containerpilot.json5
COPY containerpilot.json5 /etc/containerpilot.json5

CMD ["/bin/containerpilot", "stack", "exec", "duckling-example-exe"]