# To build and test, use e.g.:
# - docker build -t keystone-learning --progress plain .
# - docker run -p 8080:8080 --env-file .env.docker keystone-learning
# where .env.docker has (without quotes):
# SESSION_SECRET=t0p-s3cr3t

# base node image
FROM node:18-bullseye-slim as base

# set for base and all layers that inherit from it
ENV NODE_ENV production

# Install openssl for Prisma
RUN apt-get update && apt-get install -y openssl sqlite3 unzip

# Install all node_modules, including dev dependencies
FROM base as deps

WORKDIR /myapp

COPY package.json yarn.lock ./
RUN yarn install --include=dev
RUN du -md 4 . | sort -nr | head -n 25

# Build the app
FROM deps as build

WORKDIR /myapp

COPY . .
ENV DATABASE_URL=file:/keystone.db
RUN yarn keystone telemetry disable
RUN yarn build
RUN yarn keystone prisma migrate dev -n init

# Finally, build the production image with minimal footprint
FROM build

WORKDIR /myapp

ENV DATABASE_URL=file:/keystone.db
ENV PORT="8080"

# add shortcut for connecting to database CLI
RUN echo "#!/bin/sh\nset -x\nsqlite3 \$DATABASE_URL" > /usr/local/bin/database-cli && chmod +x /usr/local/bin/database-cli

RUN echo "env:" && env

ENTRYPOINT [ "yarn", "keystone", "start", "--with-migrations" ]
