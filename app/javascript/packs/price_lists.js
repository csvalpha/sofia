import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  var element = document.getElementById('price_lists_table');
  if (element != null) {

    var priceLists = JSON.parse(element.dataset.priceLists);
    var products = JSON.parse(element.dataset.products);
    var productPrice = JSON.parse(element.dataset.productPrice);

    var users = new Vue({
      el: element,
      data: function() {
        return { priceLists: priceLists, products: products, productPrice: productPrice};
      },
      methods: {
        findPrice: function(product, priceList) {
          var p = productPrice.find(p => (p.product_id === product.id && p.price_list_id === priceList.id))/
          p ? `€${parseFloat(p.price).toFixed(2)}` : '';
        }
      }
    });
  }
});
