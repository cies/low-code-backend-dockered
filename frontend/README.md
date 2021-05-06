# Usage

These should be run with node/npm and the elm tool chain installed.

Or from within the docker container (see `../Makefile`).

## Install

```sh
npm install
```

## Develop

Start with Elm debug tool with either

```sh
npm start
```

or

```sh
npm start --nodebug
```

the `--nodebug` removes the Elm debug tool (useful when the model becomes too big).

## Production builds

Build production assets (HTML, JS and CSS together) with:

```sh
npm run prod
```

## Static assets

Just add to `src/assets/` and the production build copies them to `/dist`


## Testing

Requires you have [installed elm-test globally](https://github.com/elm-community/elm-test#running-tests-locally).

When you install your dependencies `elm-test init` is run. After that all you need to do to run the tests is:

```sh
npm test
```

Take a look at the examples in `tests/`

If you add dependencies to your main app, then run `elm-test --add-dependencies`


## Elm-analyse

Elm-analyse is a "tool that allows you to analyse your Elm code, identify deficiencies and apply best practices."
Its built into this starter, just run the following to see how your code is getting on:

```sh
npm run analyse
```

## ES6

This starter includes [Babel](https://babeljs.io/) so you can directly use ES6 code.


## How it works

`npm run dev` maps to `webpack-dev-server --hot --colors --port 3000` where

  - `--hot` Enable webpack's Hot Module Replacement feature
  - `--port 3000` - use port 3000 instead of default 8000
  - inline (default) a script will be inserted in your bundle to take care of reloading, and build messages will appear in the browser console.
  - `--colors` should show the colours created in the original Elm errors, but does not (To Fix)
  
One alternative is to run `npx webpack-dev-server --hot --colors --host=0.0.0.0 --port 3000` which will enable your dev server to be reached from other computers on your local network

