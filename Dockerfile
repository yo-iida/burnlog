FROM ruby:2.6.6

RUN apt-get update && \
    apt-get install -y build-essential libpq-dev postgresql-client nodejs && \
    gem install rails rake && \
    bundle config git.allow_insecure true

WORKDIR /app

EXPOSE 3000