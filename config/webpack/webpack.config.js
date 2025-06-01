const path    = require("path")
const webpack = require("webpack")

module.exports = {
  mode: "production",
  devtool: "source-map",
  entry: {
    application: "./app/javascript/application.js"
  },
  output: {
    filename: "[name].js",
    chunkFilename: "[name]-[contenthash].digested.js",
    sourceMapFilename: "[file]-[fullhash].map",
    path: path.resolve(__dirname, '..', '..', 'app/assets/builds'),
    hashFunction: "sha256",
    hashDigestLength: 64,
  },
  module: {
    rules: [
        {
          test: /\.(js)$/,
          exclude: /node_modules/,
          use: ['babel-loader'],
        },
        {
          test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
          use: 'file-loader',
        },
    ],
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ]
}
