FROM haskell:9.4.8-slim AS build

WORKDIR /opt

RUN cabal update

COPY gh-actions-docs.cabal /opt/
RUN cabal build --only-dependencies -j4

COPY app /opt/app
RUN cabal install

ENTRYPOINT ["gh-actions-docs"]
