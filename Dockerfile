# To build and test, use e.g.:
# - docker build -t keystone-learning --progress plain .
# - docker run -p 8080:8080 --env-file .env.docker keystone-learning
# where .env.docker has, e.g.:
# SESSION_SECRET="t0p-s3cr3t"

# base node image
FROM node:18-bullseye-slim as base

# Install openssl for Prisma
RUN apt-get update && apt-get install -y openssl sqlite3 unzip

# Install all node_modules, including dev dependencies
FROM base as deps
WORKDIR /myapp

ENV NODE_ENV=production

COPY package.json yarn.lock ./
RUN yarn install --include=dev

# Show disk usage
RUN du -m -d 4 . | sort -nr | head -n 25

# Build the app
FROM deps as build
WORKDIR /myapp

ENV DATABASE_URL=file:/keystone.db
ENV NEXT_TELEMETRY_DISABLED=1

# Show all env vars prior to build. DEBUG ONLY -- remove for production.
RUN env | sort

COPY . .
RUN yarn build

# Apply the DB migrations.
RUN yarn keystone prisma migrate deploy

# Finally, set up the runtime.
FROM build
WORKDIR /myapp

ENV PORT=8080

# add shortcut for connecting to database CLI
RUN echo "#!/bin/sh\nset -x\nsqlite3 \$DATABASE_URL" > /usr/local/bin/database-cli && chmod +x /usr/local/bin/database-cli

ENTRYPOINT [ "yarn", "keystone", "start" ]
