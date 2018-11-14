FROM elixir:1.7 AS build

COPY lib lib
COPY rel rel
COPY priv priv
COPY Makefile Makefile
COPY mix.exs mix.exs
COPY mix.lock mix.lock
COPY config config

RUN rm -Rf _build && \
  mix local.hex --force && \
  mix local.rebar --force && \
  make release-docker

RUN mkdir -p /export && cp -r _build/docker/rel/shortler /export/

FROM erlang:21

ENV LANG=C.UTF-8

RUN mkdir -p /opt/app
COPY --from=build /export/ /opt/app

CMD /opt/app/shortler/bin/shortler migrate && /opt/app/shortler/bin/shortler foreground
