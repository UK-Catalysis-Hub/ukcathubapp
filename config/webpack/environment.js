const { environment } = require('@rails/webpacker')


import {ProvidedPlugin} from 'webpack'
environment.plugins.append('Provide',
  new ProvidedPlugin({
      $: 'jquery',
      jQuery: 'jquery',
      Popper: ['popper.js', 'default']
  })
)

module.exports = environment
