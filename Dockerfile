FROM --platform=linux/arm64 node:lts-bullseye-slim as node
WORKDIR /app

RUN apt update -y
RUN apt install curl -y

RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash -

RUN rm -rf /var/lib/apt/lists/*

COPY package.json .
COPY main.js .

RUN yarn install

FROM node:lts-bullseye-slim
WORKDIR /app

ARG USER="viewer"
ARG PASSWORD="default"
ARG HOST="http://localhost"
ARG PLAYLIST_ID="0"
ARG DISPLAY=":0"

ENV USER=${USER}
ENV PASSWORD=${PASSWORD}
ENV HOST=${HOST}
ENV PLAYLIST_ID=${PLAYLIST_ID}
ENV DISPLAY=${DISPLAY}

RUN echo "USER=${USER}"
RUN echo "PASSWORD=${PASSWORD}"
RUN echo "HOST=${HOST}"
RUN echo "PLAYLIST_ID=${PLAYLIST_ID}"
RUN echo "DISPLAY=${DISPLAY}"

ARG UID=1001
ENV UID=$UID
RUN useradd -m --uid $UID -g users -G plugdev,video,audio user

RUN apt update -y
RUN apt install curl procps libglib2.0-dev libnss3-dev libatk1.0-dev libatk-bridge2.0-dev libatk1.0-dev libgtk2.0-dev \
  libdbus-1-dev libx11-dev libx11-xcb-dev  libxcb1-dev libxi-dev \
  libxcursor-dev libxdamage-dev libxrandr-dev libxcomposite-dev libxext-dev \
  libxfixes-dev libxrender-dev libxtst-dev libxss-dev libgconf2-dev \
  libdrm2 libgtk-3-0 libgbm1 libasound2 libxss1 libgl1 -y

RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash -

COPY --chown=user:users --from=node /app .

USER user

CMD npx electron --no-sandbox ./main.js
