/* eslint-env node */
const path = require("path");
const fs = require("fs");
const webpack = require("webpack");
const { VueLoaderPlugin } = require("vue-loader");
const ESLintPlugin = require('eslint-webpack-plugin');

// Path to your javascript folder
const javascriptsDir = path.resolve(__dirname, "app/javascript");

// Find all .js files in the app/javascript directory
const entries = fs.readdirSync(javascriptsDir)
  .filter(file => file.endsWith(".js"))
  .reduce((acc, file) => {
    const name = file.replace(/\.js$/, "");
    acc[name] = path.join(javascriptsDir, file);
    return acc;
  }, {});

module.exports = {
  mode: process.env.NODE_ENV || "development",
  devtool: process.env.NODE_ENV === "production" ? "hidden-source-map" : "source-map",
  // Use our dynamically generated entries object
  entry: entries,
  output: {
    filename: "[name].js",
    sourceMapFilename: "[name].js.map",
    path: path.resolve(__dirname, "app/assets/builds"),
    // emit original names so Sprockets can add the single fingerprint
    assetModuleFilename: "[name][ext]"
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
    new VueLoaderPlugin(),
    new ESLintPlugin({
      extensions: ['js', 'jsx', 'vue'], // Specify file extensions to check (including .vue for your project)
      exclude: ['node_modules'], // Directories to exclude (defaults to node_modules)
      formatter: 'stylish', // Use the 'stylish' formatter (or any other you prefer)
      emitError: true, // Report ESLint errors as webpack errors
      emitWarning: true, // Report ESLint warnings as webpack warnings
      failOnError: process.env.NODE_ENV === "production", // Make the build fail on ESLint errors
      cache: true, // Enable caching for faster linting
      cacheLocation: path.resolve(__dirname, 'node_modules/.cache/.eslintcache'), // Custom cache location
      fix: false, // Set to true to automatically fix linting issues (use with caution in CI)
      lintDirtyModulesOnly: process.env.NODE_ENV !== "production", // Only lint changed files (set to true for faster incremental builds)
    }),
  ],
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: "vue-loader",
      },
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: ["babel-loader"],
      },
      {
        test: /\.css$/,
        use: ['vue-style-loader', 'css-loader']
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf|svg)$/i,
        type: 'asset/resource',
      }
    ],
  },
  resolve: {
    extensions: [".js", ".vue"],
    alias: {
      vue$: 'vue/dist/vue.esm.js'
    }
  },
};