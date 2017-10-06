ready = ->
  ### Activating Best In Place ###
  jQuery('.best_in_place').best_in_place()

$('.best_in_place').bind 'ajax:success', ->
  debugger
  alert 'Name updated for ' + $(this).data('priceList') + 'in' + $(this).data('userName')

$(document).ready(ready)
$(document).on('turbolinks:load', ready)
