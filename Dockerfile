FROM collegeimprovements/elixir-docker-base as build


# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile


# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
RUN mix release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/mini_repo ./
RUN chown -R nobody: /app
USER nobody

EXPOSE 4000

ENV HOME=/app
