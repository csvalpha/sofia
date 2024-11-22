process.env.NODE_ENV = process.env.NODE_ENV || 'luxproduction'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
