FROM node:12-alpine3.12

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ENV GHOST_VERSION 3.40.5
ENV NODE_ENV production
ENV GHOST_HOME /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content

# set system env
RUN echo '' > /etc/apk/repositories && \
    echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.10/main"         >> /etc/apk/repositories && \
    echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.10/community"    >> /etc/apk/repositories && \
    echo "Asia/Shanghai" > /etc/timezone \
    apk update && apk add git && \


# grab su-exec for easy step-down from root
RUN apk add --no-cache 'su-exec>=0.2'

RUN apk add --no-cache \
# add "bash" for "[["
		bash

# set env 
RUN mkdir -p "$GHOST_HOME"; \
        chown node:node "$GHOST_HOME"; \
        npm install -g yarn; \
        apk add --no-cache --virtual .build-deps g++ gcc libc-dev make python3 vips-dev; \
        yarn global add knex-migrator grunt-cli ember-cli; 

WORKDIR $GHOST_HOME

COPY * ./

# build
RUN yarn install && grunt symlink && grunt init; \
        grunt prod;



VOLUME $GHOST_CONTENT

EXPOSE 8866
CMD ["npm","start"]
