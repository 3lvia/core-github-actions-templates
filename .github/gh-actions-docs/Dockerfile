FROM haskell:9.4.8-slim

WORKDIR /opt/app

RUN apt-get update && \
    apt-get install -y --no-install-recommends npm
RUN npm install -g prettier@2.8.8
RUN export PATH=$PATH:/root/.node/bin

RUN cabal update

COPY gh-actions-docs.cabal ./
RUN cabal build --only-dependencies

COPY app ./app

RUN cabal install --overwrite-policy=always

ENTRYPOINT ["gh-actions-docs"]
