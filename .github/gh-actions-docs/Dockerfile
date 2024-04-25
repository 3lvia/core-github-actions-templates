FROM haskell:9.4.8-slim

WORKDIR /opt/app

RUN cabal update

COPY gh-actions-docs.cabal ./
RUN cabal build --only-dependencies

COPY app ./app

RUN cabal install --overwrite-policy=always

ENTRYPOINT ["gh-actions-docs"]
