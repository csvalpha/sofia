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
    products.forEach(p => p.editing = false);

    var users = new Vue({
      el: element,
      data: function() {
        return { priceLists: priceLists, products: products };
      },
      methods: {
        findPrice: function(product, priceList) {
          return product.product_prices.find(p => (p.product_id === product.id && p.price_list_id === priceList.id));
        },
        newProduct: function(index) {
          var newProduct = {
            name: '',
            contains_alcohol: true,
            editing: true,
            product_prices: [],
          };
          this.stubProductPrice(newProduct);
          return products.push(newProduct);
        },
        saveProduct: function(product) {
          if (!product.id) {
            this.$http.post('/products.json', { product: product }).then( (response) => {
                var index = this.products.indexOf(product);
                this.products.splice(index, 1);

                var newProduct = response.data;
                newProduct.editing = false;
                this.stubProductPrice(newProduct);
                this.products.push(Object.assign({}, newProduct));
              }, (response) => {
                this.errors = response.data.errors;
              }
            );
          } else {
            console.log(product.product_prices[0].price);
            product.editing = true;
          }
        },
        editProduct: function(product) {
          // TODO: save original state
          product.editing = true;
          return product;
        },
        cancelEditProduct: function(product) {
          if (product.id) { // Product already exists on server
            // TODO: reset object to original state
            product.editing = false;
          } else {
            var index = this.products.indexOf(product);
            this.products.splice(index, 1);
          }
          return products;
        },
        productPriceValue: function(productPrice) {
          return productPrice ? parseFloat(productPrice.price).toFixed(2) : null;
        },
        productPriceToCurrency: function(productPrice) {
          return productPrice ? `€${parseFloat(productPrice.price).toFixed(2)}` : '';
        },
        stubProductPrice: function(product) {
          for (var i = 0, len = this.priceLists.length; i < len; i++) {
            product.product_prices.push({
              price_list_id: priceLists[i].id,
              price: null,
            });
          }
        }
      }
    });
  }
});
