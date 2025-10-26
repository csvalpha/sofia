import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

document.addEventListener('turbolinks:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('pricelists-container');
  if (element != null) {
    var priceLists = JSON.parse(element.dataset.priceLists);
    var products = JSON.parse(element.dataset.products);

    // Make sure property exists before Vue sees the data
    products.forEach(p => p.editing = false);

    new Vue({
      el: element,
      data: () => {
        return { priceLists: priceLists, products: products, showArchived: false };
      },
      computed: {
        filteredPriceLists: function() {
          if (this.showArchived) {
            return priceLists;
          } else {
            return priceLists.filter(priceList => !priceList.archived_at);
          }
        }
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

        newProduct () {
          var newProduct = {
            name: '',
            category: 0,
            editing: true,
            product_prices: [],
          };
          return products.push(newProduct);
        },

        saveProduct: function(product) {
          if (product.id && product._beforeEditingCache.name !== product.name) {
            if (!confirm("Weet je zeker dat je de productnaam wilt wijzigen? Pas hier mee op want dit kan problemen geven in bestaande orders. Als je twijfelt, maak dan een nieuw product aan in plaats van het bestaande te hernoemen.")) {
              return;
            }
          }
          const sanitizedProduct = this.sanitizeProductInput(product);
          if (sanitizedProduct.id) { // Existing product
            this.$http.put(`/products/${sanitizedProduct.id}.json`, { product: sanitizedProduct }).then( (response) => {
              var newProduct = response.data;
              newProduct.editing = false;

              this.$set(this.products, this.products.indexOf(product), newProduct);
            }, (response) => {
              this.errors = response.data.errors;
            });
          } else {
            this.$http.post('/products.json', { product: sanitizedProduct }).then( (response) => {
              var index = this.products.indexOf(product);
              this.products.splice(index, 1);

              var newProduct = response.data;
              newProduct.editing = false;

              this.products.push(newProduct);
            }, (response) => {
              this.errors = response.data.errors;
            }
            );
          }
        },

        sanitizeProductInput: function (product) {
          const sanitizedProduct = product;
          this.$delete(sanitizedProduct, 'editing');
          this.$delete(sanitizedProduct, '_beforeEditingCache');
          this.$delete(sanitizedProduct, 't_category');

          if (sanitizedProduct.id) {
            this.$delete(sanitizedProduct.product_prices, 'product_id');
            this.$delete(sanitizedProduct.product_prices, 'price_list_id');
          } else {
            this.$delete(sanitizedProduct, 'id');
          }

          this.$set(sanitizedProduct, 'product_prices_attributes', {});

          sanitizedProduct.product_prices.forEach((price, index) => {
            if (price && price.price && price.price > 0) {
              this.$set(sanitizedProduct.product_prices_attributes, index, price);
            } else if(price.id) {
              price.price = 0;
              price._destroy = true;
              this.$set(sanitizedProduct.product_prices_attributes, index, price);
            }
          });

          this.$delete(sanitizedProduct, 'product_prices');
          return sanitizedProduct;
        },

        editProduct: function(product) {
          // Save original state
          product._beforeEditingCache = Vue.util.extend({}, product);
          product.product_prices.forEach((pp, i) => {
            product._beforeEditingCache.product_prices[i] = Vue.util.extend({}, pp);
          });

          product.editing = true;
          return product;
        },

        cancelEditProduct: function(product) {
          if (product.id) {
            this.$set(this.products, this.products.indexOf(product), product._beforeEditingCache);

            product.editing = false;
          } else {
            var index = this.products.indexOf(product);
            this.products.splice(index, 1);
          }
          return products;
        },

        archivePriceList: function(priceList) {
          this.$http.post(`/price_lists/${priceList.id}/archive`, {}).then((response) => {
            priceList.archived_at = response.data;
          }, (response) => {
            this.errors = response.data.errors;
          });
        },

        unarchivePriceList: function(priceList) {
          this.$http.post(`/price_lists/${priceList.id}/unarchive`, {}).then((response) => {
            priceList.archived_at = response.data;
          }, (response) => {
            this.errors = response.data.errors;
          });
        },

        productPriceToCurrency: function(productPrice) {
          return (productPrice && productPrice.price) ? `€ ${parseFloat(productPrice.price).toFixed(2)}` : '';
        },
      }
    });
  }
});
