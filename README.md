# Shortler

URL Shortner for Elixir/Erlang

## Description

A HTTP/REST API Service for shortening given urls.

### HTTP API

- `POST /` - request body is plain text, which is is the original URL (i.e. `curl -XPOST "http://localhost:8888/" -d 'https://google.com/'` ) - when everything went fine, `HTTP 201` will be returned, having the short url as part of the response body - no json, just plain text.
- `GET /:shorturl-hash` - retrieves the original URL based on the given shorturl hash - if there's no URL stored, or if the URL expired, a `HTTP 404` will be returned; if the URL exists, `HTTP 302` is returned, having the response `location` header pointing to the original URL.

# Installation

## Prerequisites

- [Make](https://www.gnu.org/software/make/) (optional)
- [Docker](https://www.docker.com/products/docker-desktop)
- [Elixir](https://github.com/elixir-lang/elixir) `>= 1.7.2`

## Build

- `make build`

## Build (Docker)

- `make -C docker build`

## Tests

- `make -C docker postgres && make test`

## Release

- `make release` - this will create a `prod` release
- `make release-docker` - this will create a `docker` release, which basically means that is using the `docker.exs` config.

## Run (local)

- `make -C docker postgres && make run`

## Run (within Docker)

- `make -C docker run` - this will start all services necessary to run `shortler`, and then the `shortler`.
- `make -C docker influxdb run` - this will make sure that influxdb is started, and then carry on with the rest of startup.

## Timeseries Data

The timeseries DB, if started, can easily be accessed by any HTTP client, something similar to this:
```
curl "http://localhost:8086/query?pretty=true" --data-urlencode "db=shortler_clicks" --data-urlencode "q=SELECT * FROM \"requests\""
```
and you'd be able to see results similar to this:

```
{
  "results": [
    {
      "statement_id": 0,
      "series": [
        {
          "name": "requests",
          "columns": [
            "time",
            "accept",
            "host",
            "url",
            "user-agent"
          ],
          "values": [
            [
              "2018-10-14T19:23:24.0571226Z",
              "*/*",
              "localhost:8888",
              "http://localhost:8888/ErhTVwSuHUi",
              "curl/7.54.0"
            ],
            [
              "2018-10-14T19:23:32.7438721Z",
              "*/*",
              "localhost:8888",
              "http://localhost:8888/ErhTVwSuHUi",
              "curl/7.54.0"
            ],
...
```

This can be further explored using the InfluxDB capabilities as documented here: (Querying data with the HTTP API)[https://docs.influxdata.com/influxdb/v1.6/guides/querying_data/]
