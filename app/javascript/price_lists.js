import Vue from 'vue/dist/vue.esm';
import api from './api/axiosInstance';

document.addEventListener('turbo:load', () => {
  const element = document.getElementById('pricelists-container');
  if (element != null) {
    const priceLists = JSON.parse(element.dataset.priceLists);
    const products = JSON.parse(element.dataset.products);

    products.forEach(p => p.editing = false);

    new Vue({
      el: element,
      data: () => {
        return { priceLists: priceLists, products: products, showArchived: false, errors: [] };
      },
      computed: {
        filteredPriceLists: function() {
          if (this.showArchived) {
            return this.priceLists;
          } else {
            return this.priceLists.filter(priceList => !priceList.archived_at);
          }
        }
      },
      methods: {
        findPrice: function(product, priceList) {
          if (!product || !product.product_prices) {
            return { price: null };
          }
          const price = product.product_prices.find(p => (p.product_id === product.id && p.price_list_id === priceList.id));

          if (price) {
            return price;
          }
          const newPrice = {
            product_id: product.id,
            price_list_id: priceList.id,
            price: null
          };
          product.product_prices.push(newPrice);
          return newPrice;
        },

        newProduct () {
          const newProduct = {
            name: '',
            category: 0,
            color: '#f8f9fa',
            editing: true,
            product_prices: [],
          };
          this.products.push(newProduct);
          return newProduct;
        },

        saveProduct: function(product) {
          const colorError = this.getColorError(product.color);
          if (colorError) {
            this.errors = [colorError];
            return;
          }

          if (product.id && product._beforeEditingCache.name !== product.name) {
            if (!confirm('Weet je zeker dat je de productnaam wilt wijzigen? Pas hier mee op want dit kan problemen geven in bestaande orders. Als je twijfelt, maak dan een nieuw product aan in plaats van het bestaande te hernoemen.')) {
              return;
            }
          }
          const sanitizedProduct = this.sanitizeProductInput(product);
          if (sanitizedProduct.id) {
            api.put(`/products/${sanitizedProduct.id}.json`, { product: sanitizedProduct }).then((response) => {
              const newProduct = response.data;
              newProduct.editing = false;

              this.$set(this.products, this.products.indexOf(product), newProduct);
            }).catch((error) => {
              this.errors = error.response?.data?.errors || ['An error occurred'];
            });
          } else {
            api.post('/products.json', { product: sanitizedProduct }).then( (response) => {
              const index = this.products.indexOf(product);
              this.products.splice(index, 1);

              const newProduct = response.data;
              newProduct.editing = false;

              this.products.push(newProduct);
            }).catch((error) => {
              this.errors = error.response?.data?.errors || ['An error occurred'];
            });
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
            const index = this.products.indexOf(product);
            this.products.splice(index, 1);
          }
        },

        archivePriceList: function(priceList) {
          api.post(`/price_lists/${priceList.id}/archive`, {}).then((response) => {
            priceList.archived_at = response.data;
          }).catch((error) => {
            this.errors = error.response?.data?.errors || ['An error occurred'];
          });
        },

        unarchivePriceList: function(priceList) {
          api.post(`/price_lists/${priceList.id}/unarchive`, {}).then((response) => {
            priceList.archived_at = response.data;
          }).catch((error) => {
            this.errors = error.response?.data?.errors || ['An error occurred'];
          });
        },

        productPriceToCurrency: function(productPrice) {
          return (productPrice && productPrice.price) ? `€ ${parseFloat(productPrice.price).toFixed(2)}` : '';
        },

        isValidHexColor: function(color) {
          return /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.test(color);
        },

        getColorError: function(color) {
          if (!color) {
            return 'Kleur is verplicht';
          }
          if (!this.isValidHexColor(color)) {
            return 'Ongeldige kleur. Gebruik het formaat #RRGGBB of #RGB (bijv. #FF5733 of #F57)';
          }
          return null;
        },
      }
    });
  }
});