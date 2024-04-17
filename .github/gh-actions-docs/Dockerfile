FROM haskell:9.4.8-slim AS build

WORKDIR /opt/app

RUN cabal update

COPY gh-actions-docs.cabal ./
RUN cabal build --only-dependencies

COPY app ./app

RUN cabal install --overwrite-policy=always

ARG USERNAME=gh-actions-docs
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID $USERNAME
RUN chown -R $USERNAME .
USER $USERNAME

ENTRYPOINT ["gh-actions-docs"]
