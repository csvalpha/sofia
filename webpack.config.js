const path = require("path");
const fs = require("fs");
const webpack = require("webpack");
const { VueLoaderPlugin } = require("vue-loader");

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
    // [name] will be replaced by the key from the entry object (e.g., 'activities', 'price_lists')
    filename: "[name].js",
    sourceMapFilename: "[name].js.map",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
    new VueLoaderPlugin(),
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
        generator: {
          // This will copy the fonts to a 'webfonts' subfolder in app/assets/builds
          filename: 'webfonts/[name][ext]'
        }
      }
    ],
  },
  resolve: {
    extensions: [".js", ".vue"],
    alias: {
      vue$: 'vue/dist/vue.esm.js'
    }
  },
  optimization: {
  },
};