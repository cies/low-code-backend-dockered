elm-hasura-dockered
===================

This repo contains a Elm-Hasura starter kit for rapid+typesafe web application development on open source foundations.

Elm is great!
But what do you run server-side?
Server-side updates may change the API and therefor break your app.
Using [elm-graphql](https://package.elm-lang.org/packages/dillonkearns/elm-graphql/latest)
and [Hasura](https://hasura.io) we can generate an Elm GraphQL client that exactly fits your data model.
After changing the database schema simply regenerate the client code.
Any errors resulting from your change show up as errors in your IDE.

Stop writing/debugging layers of error-prone boilerplate and focus on cranking out features!

Highlights:

* Strong typesafety from database schema, through GraphQL API to frontend (with generated GraphQL client code).
* Define database schema with a UI that creates migrations! (to aid collaboration and deployments)
* Hot code reloading in development mode.
* Optimized (pre-gzipped) production builds, served by Nginx in production mode.
* And everything runs from containers:
  * No need to install any tooling on the local machine except for `docker`, `docker-compose` and `make`.
  * All versions are pinned, so it should work anywhere (if not please raise an issue).
  * Uninstalls cleanly.


## Ingredients

This repo contains the following parts:

* Dockered Postgres database
* Dockered Hasura which provides:
  * a GraphQL frontend to Postgres 
  * an API gateway with (row based) authorization 
  * a UI for schema changes that also manages migrations (see `/hasura/metadata` and `/hasura/migrations`)
  * a basic UI for CRUD operations on data
* Dockered type-safe Elm GraphQL API client generator
* Dockered Webpack based setup providing:
  * hot code reloading in development
  * production builds (with pre-gzipped artifacts)
* Dockered Nginx serving pre-gzipped production builds (to show the setup on full speed)
* Container orchestration with [docker-compose](https://docs.docker.com/compose)
* A minimal demo Elm app that uses the generated GraphQL client (see `/frontend`)
* Some migrations, seed data and basic role definitions (all Hasura managed)
* A self-documenting Makefile for common tasks (run `make help`)
* This README explaining what's inside and how it works


## Get going

Assuming you have `docker`, `docker-compose` and `make` installed, let's go!

Start by running Postres and Hasura with:

    docker-compose up hasura

Once the `hasura` docker service is running, start Hasura's console with:

    make hasura-console 

This console is only for local development use. To use it point your browser to:

    http://localhost:9695

Any changes you make using the console may become migrations (in the `/hasura/migrations` directory)
or may lead to changes to the metadata (in `/hasura/metadata`).
By checking these folders into version control you will always keep the the schema definitions with your code.
Hasura can help you in running/managing migrations.

The `/hasura/migrations` and `/hasura/metadata` directories are not empty.
They contain a simple schema modelling `posts` that have `tags` with a many-to-many relationship over a join table.
The `posts` also have a `status` that is modelled with what Hasura calls an "enum table".

The following command is used to generate the 100% type safe GraphQL client:

    make generate-elm-client 

The code will be put in `/frontend/src/HasuraClient` which is *not* checked into version control,
as it can be re-generated at any time (and needs to be regenerated on schema changes) using the command above.

The following command runs development-mode Webpack in the `/frontend` container:

    docker-compose up hasura 

It proxies request for the `hasura` container (`/v1/graphql`)
and watches filesystem on the host for changes in the `/frontend` directory which will be hot-reloaded to the browser on:

    http://localhost:3000

Production builds are made with:

    make frontend-run-prod

Which compiles/copies/gzips artifacts to `/frontend/dist/`, from there the production setup may pick it up:

    docker-compose up nginx

Point your browser to:

    http://localhost:3030

Now check the response times and rejoice!



## Moving forward

Interesting ways to extend this setup?

 * Add a [hasura-backend-plus](https://nhost.github.io/hasura-backend-plus) service and some basic (or not so basic) authentication/authorization system.
 * Add React Admin with [ra-data-hasura](https://github.com/hasura/ra-data-hasura) as a better place to manage data than through Hasura's console.
 * Add [MeiliSearch](https://www.meilisearch.com) as service that sits behind Hasura's "remote schema".
 * Describe how running Elm tests would work in this setup.
 * Use the `RemoteData` package.
 * Make sure this works on MacOS and Windows.
 * Improve the performance even further
   * Possibly with server-side prerendering, for which we have to pick an approach:
      * https://discourse.elm-lang.org/t/exploration-for-server-side-rendering/4999/23
      * https://github.com/rogeriochaves/spades
      * https://github.com/dawehner/elm-static-html-lib
      * https://elm-pages.com/blog/static-http/
      * http://pietrograndi.com/server-side-rendering-with-elm/

Collaboration is encouraged. Feel free to fork, submit PRs and/or open issues (even if it is to discuss how to improve this setup)!


## Caveats

* Files on the host filesystem are owned by `root` when created from docker containers. Fix it with: `chown $USER:$USER -R .`

* For integration with your IDE you may need to run some local tooling (like `node`, `elm` and `elm-format`).
