const { environment } = require('@rails/webpacker')
const VueLoaderPlugin = require('vue-loader/lib/plugin')

environment.config.merge({
  module: {
    rules: [
      {
        test: /\.vue$/,
        use: 'vue-loader'
      }, {
        test: /\.scss$/,
        loaders: ['style-loader', 'css-loader', 'sass-loader'],
        exclude: /node_modules/
      }
    ]
  },
  plugins: [
    new VueLoaderPlugin()
  ]
})

module.exports = environment
