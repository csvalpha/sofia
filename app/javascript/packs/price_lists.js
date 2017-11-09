import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

document.addEventListener('turbolinks:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('price_lists_table');
  if (element != null) {

    var priceLists = JSON.parse(element.dataset.priceLists);
    var products = JSON.parse(element.dataset.products);

    var users = new Vue({
      el: element,
      data: function() {
        return { priceLists: priceLists, products: products};
      },
      methods: {
        findPrice: function(product, priceList) {
          return product.product_prices.find(p => (p.product_id === product.id && p.price_list_id === priceList.id));
        },
        newProduct: function(index) {
          var newProduct = {
            id: products.length,
            name: '',
            contains_alcohol: true,
            editing: true,
            product_prices: [],
          };
          for (var i = 0, len = priceLists.length; i < len; i++) {
            newProduct.product_prices.push({
              product_id: products.length,
              price_list_id: priceLists[i].id,
              price: null,
            });
          }

          return products.push(newProduct);
        },
        removeProduct: function(product) {
          var index = this.products.indexOf(product);
          this.products.splice(index, 1);
          return products;
        },
        saveProduct: function(product) {
          product.editing = false;
          return product;
        },
        editProduct: function(product) {
          product.editing = true;
          return product;
        },
        productPriceToCurrency: function(productPrice) {
          return productPrice ? `€${parseFloat(productPrice.price).toFixed(2)}` : '';
        }
      }
    });
  }
});
