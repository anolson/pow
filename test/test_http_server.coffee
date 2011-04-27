http            = require "http"
{HttpServer}    = require ".."
async           = require "async"
{testCase}      = require "nodeunit"

{prepareFixtures, fixturePath, createConfiguration, swap, serve} = require "./lib/test_helper"

serveRoot = (root, options, callback) ->
  unless callback
    callback = options
    options  = {}
  configuration = createConfiguration
    hostRoot: fixturePath(root),
    dstPort:  options.dstPort ? 80
  serve new HttpServer(configuration), callback

module.exports = testCase
  setUp: (proceed) ->
    prepareFixtures proceed

  "serves requests from multiple apps": (test) ->
    test.expect 4
    serveRoot "apps", (request, done) ->
      async.parallel [
        (proceed) ->
          request "GET", "/", host: "hello.dev", (body) ->
            test.same "Hello", body
            proceed()
        (proceed) ->
          request "GET", "/", host: "www.hello.dev", (body) ->
            test.same "Hello", body
            proceed()
        (proceed) ->
          request "GET", "/", host: "env.dev", (body) ->
            test.same "Hello Pow", JSON.parse(body).POW_TEST
            proceed()
        (proceed) ->
          request "GET", "/", host: "pid.dev", (body) ->
            test.ok body.match /^\d+$/
            proceed()
      ], ->
        done -> test.done()

  "responds with an info page for requests to show.pow.*": (test) ->
    test.expect 2
    serveRoot "apps", (request, done) ->
      request "GET", "/", host: "show.pow.dev", (body, response) ->
        test.same 200, response.statusCode
        test.same "pow_info", response.headers["x-pow-template"]
        done -> test.done()

  "responds with a custom 503 when a domain isn't configured": (test) ->
    test.expect 2
    serveRoot "apps", (request, done) ->
      request "GET", "/redirect", host: "nonexistent.dev", (body, response) ->
        test.same 503, response.statusCode
        test.same "nonexistent_domain", response.headers["x-pow-template"]
        done -> test.done()

  "responds with a custom 500 when an app can't boot": (test) ->
    test.expect 2
    serveRoot "apps", (request, done) ->
      request "GET", "/", host: "error.dev", (body, response) ->
        test.same 500, response.statusCode
        test.same "application_exception", response.headers["x-pow-template"]
        done -> test.done()

  "recovering from a boot error": (test) ->
    test.expect 3
    config = fixturePath "apps/error/config.ru"
    ok = fixturePath "apps/error/ok.ru"
    serveRoot "apps", (request, done) ->
      request "GET", "/", host: "error.dev", (body, response) ->
        test.same 500, response.statusCode
        swap config, ok, (err, unswap) ->
          request "GET", "/", host: "error.dev", (body, response) ->
            test.same 200, response.statusCode
            test.same "OK", body
            done -> unswap -> test.done()

  "respects public-facing port in redirects": (test) ->
    test.expect 2
    async.series [
      (proceed) ->
        serveRoot "apps", dstPort: 80, (request, done) ->
          request "GET", "/redirect", host: "hello.dev", (body, response) ->
            test.same "http://hello.dev/", response.headers.location
            done proceed
      (proceed) ->
        serveRoot "apps", dstPort: 81, (request, done) ->
          request "GET", "/redirect", host: "hello.dev", (body, response) ->
            test.same "http://hello.dev:81/", response.headers.location
            done proceed
    ], test.done

  "serves static assets in public/": (test) ->
    test.expect 2
    serveRoot "apps", (request, done) ->
      request "GET", "/robots.txt", host: "hello.dev", (body, response) ->
        test.same 200, response.statusCode
        test.same "User-Agent: *\nDisallow: /\n", body
        done -> test.done()

  "serves static assets from non-Rack applications": (test) ->
    test.expect 3
    async.series [
      (proceed) ->
        serveRoot "apps", (request, done) ->
          request "GET", "/", host: "static.dev", (body, response) ->
            test.same 200, response.statusCode
            test.same "<!doctype html>\nhello world!\n", body
            done proceed
      (proceed) ->
        serveRoot "apps", (request, done) ->
          request "GET", "/nonexistent", host: "static.dev", (body, response) ->
            test.same 404, response.statusCode
            done proceed
    ], test.done

  "post request": (test) ->
    test.expect 2
    serveRoot "apps", (request, done) ->
      request "POST", "/post", host: "hello.dev", data: "foo=bar", (body, response) ->
        test.same 200, response.statusCode
        test.same "foo=bar", body
        done -> test.done()

  "hostnames are case-insensitive": (test) ->
    test.expect 3
    async.series [
      (proceed) ->
        serveRoot "apps", (request, done) ->
          request "GET", "/", host: "Capital.dev", (body, response) ->
            test.same 200, response.statusCode
            done proceed
      (proceed) ->
        serveRoot "apps", (request, done) ->
          request "GET", "/", host: "capital.dev", (body, response) ->
            test.same 200, response.statusCode
            done proceed
      (proceed) ->
        serveRoot "apps", (request, done) ->
          request "GET", "/", host: "CAPITAL.DEV", (body, response) ->
            test.same 200, response.statusCode
            done proceed
    ], test.done
