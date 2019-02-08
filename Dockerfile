# When pulling from the private repo the FQDN must be specified
# exmple: FROM docker.tagshelf.io/tagshelfsrl/haskell-service
# by passing --build-arg FQDN=docker.tagshelf.io/
ARG FQDN=docker.tagshelf.io/
FROM ${FQDN}tagshelfsrl/haskell-service

RUN git clone https://github.com/tagshelfsrl/duckling.git

WORKDIR /duckling

# NOTE:`stack build` will use as many cores as are available to build
# in parallel. However, this can cause OOM issues as the linking step
# in GHC can be expensive. If the build fails, try specifying the
# '-j1' flag to force the build to run sequentially.
ARG J_FLAG="-j1"
RUN stack setup && stack build ${J_FLAG}

# add ContainerPilot configuration and env
ENV APP_NAME=default-name
ENV PUB_ADDR=0.0.0.0
ENV PUB_PORT=8000
ENV CONSUL_ADDR=localhost:8500
ENV CONSUL_PORT=8500
ENV SCHEME=http
ENV CONSUL_TOKEN=WoWmuchSecure!
ENV TLS_VERIFY=true
ENV AGENT_BIND=
ENV CONTAINERPILOT=/etc/containerpilot.json5

COPY containerpilot.json5 /etc/containerpilot.json5

CMD ["stack", "exec", "duckling-example-exe"]