FROM haskell:9.4.8-slim

WORKDIR /opt/app

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs
RUN npm install -g prettier
RUN export PATH=$PATH:/root/.node/bin

RUN cabal update

COPY gh-actions-docs.cabal ./
RUN cabal build --only-dependencies

COPY app ./app

RUN cabal install --overwrite-policy=always

ENTRYPOINT ["gh-actions-docs"]
