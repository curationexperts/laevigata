const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
const vue = require('./loaders/vue')
environment.loaders.prepend('vue', vue)
module.exports = environment
