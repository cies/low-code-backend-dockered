const path = require("path");
const glob = require("glob");
const {merge} = require('webpack-merge');
const {CleanWebpackPlugin} = require("clean-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const HTMLWebpackPlugin = require("html-webpack-plugin");

// Production JS optimization
const ClosurePlugin = require("closure-webpack-plugin");

// Production CSS assets - separate, minimised
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");

// Production optimized images
const ImageMinPlugin = require('imagemin-webpack-plugin').default;

// Production pre-compressed assets
const CompressionWebpackPlugin = require("compression-webpack-plugin");

module.exports = () => ({});

var MODE = process.env.npm_lifecycle_event === "prod" ? "production" : "development";
var withDebug = !process.env["npm_config_nodebug"] && MODE === "development";
// this may help for Yarn users
// var withDebug = !npmParams.includes("--nodebug");
console.log(
    "\x1b[36m%s\x1b[0m",
    `** elm-webpack-starter: mode "${MODE}", withDebug: ${withDebug}\n`
);

var common = {
    mode: MODE,
    entry: "./src/index.js",
    output: {
        path: path.join(__dirname, "dist"),
        publicPath: "/",
        // FIXME webpack -p automatically adds hash when building for production
        filename: MODE === "production" ? "[name]-[hash].js" : "index.js"
    },
    plugins: [
        new HTMLWebpackPlugin({
            // Use this template to get basic responsive meta tags
            template: "src/index.html",
            favicon: "src/assets/images/favicon.ico",
            // inject details of output file at end of body
            inject: "body"
        })
    ],
    resolve: {
        modules: [path.join(__dirname, "src"), "node_modules"],
        extensions: [".js", ".elm", ".scss", ".png"]
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: { loader: "babel-loader" }
            },
            {
                test: /\.(sa|sc|c)ss$/,
                exclude: [/elm-stuff/, /node_modules/],
                // see https://github.com/webpack-contrib/css-loader#url
                use: ["style-loader", "css-loader?url=false", "sass-loader"]
            },
            {
                test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: "url-loader",
                    options: {
                        limit: 10000,
                        mimetype: "application/font-woff"
                    }
                }
            },
            {
                test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader: "file-loader"
            },
            {
                test: /\.(jpe?g|png|gif|svg)$/i,
                exclude: [/elm-stuff/, /node_modules/],
                loader: "file-loader"
            }
        ]
    }
};

if (MODE === "development") {
    module.exports = merge(common, {
        optimization: {
            // Prevents compilation errors causing the hot loader to lose state
            noEmitOnErrors: true
        },
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [
                        { loader: "elm-hot-webpack-loader" },
                        {
                            loader: "elm-webpack-loader",
                            options: {
                                // add Elm's debug overlay to output
                                debug: withDebug
                            }
                        }
                    ]
                }
            ]
        },
        devServer: {
            inline: true,
            stats: "errors-only",
            contentBase: path.join(__dirname, "src/assets"),
            historyApiFallback: true,
            // feel free to delete this section if you don't need anything like this
            before(app) {
                // on port 3000
                app.get("/test", function (req, res) {
                    res.json({result: "OK"});
                });
            },
            // proxy requests to meilisearch, so it all runs from the same domain
            proxy: {
                "/v1/graphql": {
                  target: "http://hasura:8080"
                }
            }
        }
    });
}



if (MODE === "production") {
    module.exports = merge(common, {
        optimization: {
            splitChunks: {
                cacheGroups: {
                    styles: {
                        name: 'styles',
                        test: /\.css$/,
                        chunks: 'all',
                        enforce: true
                    }
                }
            },
            minimizer: [
                new ClosurePlugin(
                    { mode: "STANDARD" },
                    {
                        // compiler flags here
                        //
                        // for debugging help, try these:
                        //
                        // formatting: 'PRETTY_PRINT',
                        // debug: true
                        // renaming: false
                    }
                ),
                new OptimizeCSSAssetsPlugin({})
            ]
        },
        plugins: [
            // Delete everything from output-path (/dist) and report to user
            new CleanWebpackPlugin({
                root: __dirname,
                exclude: [],
                verbose: true,
                dry: false
            }),

            // Copy static assets
            new CopyWebpackPlugin({
                patterns: [
                    { from: "src/assets" }
                ]
            }),

            new MiniCssExtractPlugin({
                // Options similar to the same options in webpackOptions.output
                // both options are optional
                filename: "[name]-[hash].css"
            }),

            new ImageMinPlugin({
              test: /\.(jpe?g|png|gif|svg)$/i,
              cache: true,
            }),

            new OptimizeCSSAssetsPlugin(),

            new CompressionWebpackPlugin()
        ],
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: {
                        loader: "elm-webpack-loader",
                        options: { optimize: true }
                    }
                },
                {
                    test: /\.(sa|sc|c)ss$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [
                        MiniCssExtractPlugin.loader,
                        "css-loader?url=false",
                        "sass-loader"
                    ]
                }
            ]
        }
    });
}
