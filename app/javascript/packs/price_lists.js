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

    // Make sure property exists before Vue sees the data
    products.forEach(p => p.editing = false);

    var vuePriceLists = new Vue({
      el: element,
      data: () => {
        return { priceLists: priceLists, products: products };
      },
      methods: {
        findPrice: function(product, priceList) {
          if (!product || !product.product_prices) {
            return { price: null };
          }
          var price = product.product_prices.find(p => (p.product_id === product.id && p.price_list_id === priceList.id));
          return price || product.product_prices.push({
            product_id: product.id,
            price_list_id: priceList.id,
            price: null
          });
        },

        newProduct: function(index) {
          var newProduct = {
            name: '',
            contains_alcohol: false,
            editing: true,
            product_prices: [],
          };
          return products.push(newProduct);
        },

        saveProduct: function(product) {
          if (!product.id) { // New product
            this.sanitizeProductInput(product);

            this.$http.post('/products.json', { product: product }).then( (response) => {
                var index = this.products.indexOf(product);
                this.products.splice(index, 1);

                var newProduct = response.data;
                newProduct.editing = false;

                this.products.push(newProduct);
              }, (response) => {
                this.errors = response.data.errors;
              }
            );
          } else { // Update existing product
            product.editing = true;
          }
        },

        sanitizeProductInput: function (product) {
          this.$set(product, 'product_prices_attributes', {});

          product.product_prices.forEach((price, index) => {
            if (price && price.price && price.price > 0) {
              this.$set(product.product_prices_attributes, index, price);
            }
          });

          this.$delete(product, 'product_prices');
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

        productPriceToCurrency: function(productPrice) {
          return (productPrice && productPrice.price) ? `€${parseFloat(productPrice.price).toFixed(2)}` : '';
        },
      }
    });
  }
});
