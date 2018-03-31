const { environment } = require('@rails/webpacker')

environment.config.merge({
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader'
      }
    ]
  }
})

module.exports = environment
