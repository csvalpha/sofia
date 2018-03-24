import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';
import BootstrapVue from 'bootstrap-vue';

import Flash from '../flash.vue';
import UserSelection from '../orderscreen/userselection.vue';
import OrderHistory from '../orderscreen/orderhistory.vue';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);
Vue.use(BootstrapVue);

document.addEventListener('turbolinks:load', () => {
  Vue.http.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('order-screen');
  if (element != null) {
    var users = JSON.parse(element.dataset.users);
    var productPrices = JSON.parse(element.dataset.productPrices);
    var activity = JSON.parse(element.dataset.activity);

    window.flash = function(message, actionText, type) {
      const event = new CustomEvent('flash', { detail: { message: message, actionText: actionText, type: type } } );
      dispatchEvent(event);
    };

    new Vue({
      el: element,
      data: () => {
        return {
          users: users,
          productPrices: productPrices,
          activity: activity,
          selectedUser: null,
          payWithCash: false,
          keepUserSelected: false,
          orderRows: [],
          creditMutationAmount: null,
          creditMutationDescription: 'Inleg contant',
          creditMutationFormInvalid: false
        };
      },
      methods: {
        sendFlash: function(message, actionText, type) {
          window.flash(message, actionText, type);
        },

        doubleToCurrency(price) {
          return `€${parseFloat(price).toFixed(2)}`;
        },

        setUser(user) {
          if (!user) {
            this.orderRows = [];
          }

          this.payWithCash = false;
          this.selectedUser = user;
        },

        selectCash() {
          this.payWithCash = true;
        },

        selectProduct(productPrice) {
          if (this.selectedUser || this.payWithCash) {
            const orderRow = this.orderRows.filter((row) => { return row.productPrice === productPrice; })[0];

            if (orderRow) {
              orderRow.amount++;
            } else {
              this.orderRows.push({productPrice: productPrice, amount: 1});
            }
          }
        },

        dropOrderRow(index) {
          this.$delete(this.orderRows, index);
        },

        orderTotal() {
          return this.orderRows.map(function(row) {
            return row.productPrice.price * row.amount;
          }).reduce((total, amount) => total + amount, 0);
        },

        decreaseRowAmount(orderRow) {
          if (orderRow.amount > 0) {
            orderRow.amount--;
          }
        },

        increaseRowAmount(orderRow) {
          orderRow.amount++;
        },

        confirmOrder() {
          let order = {};
          const order_rows_attributes = this.orderRows.map((row) => {
            if (row.amount) {
              return {
                product_id: row.productPrice.product.id,
                product_count: row.amount
              };
            }
          });

          if (this.payWithCash) {
            order = {
              paid_with_cash: true,
              activity_id: this.activity.id,
              order_rows_attributes
            };
          } else {
            order = {
              user_id: this.selectedUser.id,
              activity_id: this.activity.id,
              order_rows_attributes
            };
          }

          this.$http.post(`/activities/${this.activity.id}/orders.json`, {
            order: order
          }).then((response) => {
            const user = response.body.user;
            const orderTotal = this.doubleToCurrency(response.body.order_total);
            const additionalInfo = `${user ? user.name : 'Contant'} - ${orderTotal}`;

            if (user) {
              this.$set(this.users, this.users.indexOf(this.selectedUser), response.body.user);
              this.$emit('updateusers');
            }

            this.sendFlash('Bestelling geplaatst.', additionalInfo, 'success');
            this.orderRows = [];
            if(!this.keepUserSelected){
              this.setUser(null);
            }
          }, this.handleXHRError );
        },

        orderConfirmButtonDisabled() {
          return !(this.selectedUser || this.payWithCash) || this.totalProductCount() == 0;
        },

        totalProductCount() {
          return this.orderRows.map(function(row) {
            return row.amount;
          }).reduce((total, amount) => total + amount, 0);
        },

        saveCreditMutation(event) {
          this.creditMutationFormInvalid = (!this.selectedUser
            || !this.creditMutationAmount || !this.creditMutationDescription);

          if (this.creditMutationFormInvalid) {
            // Prevent event propagation so modal stays visible
            return event.stopPropagation();
          }

          this.$http.post('/credit_mutations.json', {
            credit_mutation: {
              user_id: this.selectedUser.id,
              activity_id: this.activity.id,
              description: this.creditMutationDescription,
              amount: this.creditMutationAmount
            }
          }).then((response) => {
            this.$set(this.users, this.users.indexOf(this.selectedUser), response.body.user);
            this.$emit('updateusers');

            if(!this.keepUserSelected) {
              this.setUser(null);
            }
            this.$refs.creditMutationModal.hide();

            this.creditMutationAmount = null;
            this.creditMutationDescription = 'Inleg contant';
            const additionalInfo = `${response.body.user.name} - ${this.doubleToCurrency(response.body.amount)}`;
            this.sendFlash('Inleg opgeslagen.', additionalInfo, 'success');
          }, this.handleXHRError);
        },

        handleXHRError(error) {
          if (error.status == 500) {
            this.sendFlash('Server error!', 'Herlaadt de pagina', 'error');

            try {
              throw new Error(error.body.text);
            } catch(e) {
              /* eslint-disable no-undef */
              Raven.captureException(e);
              /* eslint-enable */
            }
          } else if (error.status == 422) {
            this.sendFlash('Error bij het opslaan!', 'Probeer het opnieuw', 'warning');
          } else {
            this.sendFlash(`Error ${error.status}?!🤔`, 'Herlaadt de pagina', 'info');
          }
        }
      },

      components: {
        Flash,
        UserSelection,
        OrderHistory
      }
    });
  }
});
