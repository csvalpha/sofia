const { environment } = require('@rails/webpacker')
const VueLoaderPlugin = require('vue-loader/lib/plugin')

environment.config.merge({
  module: {
    rules: [
      {
        test: /\.vue$/,
        use: 'vue-loader'
      }
    ]
  },
  plugins: [
    new VueLoaderPlugin()
  ]
})

module.exports = environment
