import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';
import axios from 'axios';
import BootstrapVue from 'bootstrap-vue';

import Flash from '../components/flash.vue';
import UserSelection from '../components/orderscreen/userselection.vue';
import ActivityOrders from '../components/orderscreen/activityorders.vue';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);
Vue.use(BootstrapVue);

document.addEventListener('turbolinks:load', () => {
  const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  Vue.http.headers.common['X-CSRF-TOKEN'] = token;
  axios.defaults.headers.common['X-CSRF-Token'] = token;

  var element = document.getElementById('order-screen');
  if (element != null) {
    var users = JSON.parse(element.dataset.users);
    var productPrices = JSON.parse(element.dataset.productPrices);
    var activity = JSON.parse(element.dataset.activity);

    window.flash = function(message, actionText, type) {
      const event = new CustomEvent('flash', { detail: { message: message, actionText: actionText, type: type } } );
      dispatchEvent(event);
    };

    const app = new Vue({
      el: element,
      data: () => {
        return {
          users: users,
          productPrices: productPrices,
          activity: activity,
          selectedUser: null,
          payWithCash: false,
          payWithPin: false,
          keepUserSelected: false,
          orderRows: [],
          creditMutationAmount: null,
          creditMutationDescription: 'Inleg contant',
          creditMutationFormInvalid: false,
          isSubmitting: false
        };
      },
      methods: {
        sendFlash: function(message, actionText, type) {
          window.flash(message, actionText, type);
        },

        doubleToCurrency(price) {
          return `€${parseFloat(price).toFixed(2)}`;
        },

        setUser(user = null) {
          this.orderRows = [];
          this.payWithCash = false;
          this.payWithPin = false;
          this.selectedUser = user;
        },

        selectCash() {
          this.payWithCash = true;
        },

        selectPin() {
          this.payWithPin = true;
        },

        selectProduct(productPrice) {
          if (this.selectedUser || this.payWithCash || this.payWithPin) {
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

        orderRequiresAge() {
          return this.orderRows.filter((row) => {
            return row.productPrice.product.requires_age;
          }).length > 0;
        },

        maybeConfirmOrder(e) {
          if (this.selectedUser && this.selectedUser.insufficient_credit) {
            this.$root.$emit('bv::show::modal', 'insufficient-credit-modal', e.target)
          } else {
            this.confirmOrder();
          }
        },

        confirmOrder() {
          this.isSubmitting = true;

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
          } else if (this.payWithPin) {
            order = {
              paid_with_pin: true,
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

          this.$http.post('/orders', {
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
            if(!this.keepUserSelected){
              this.setUser(null);
            } else {
              // re-set user to update credit
              this.setUser(response.body.user);
            }

            this.isSubmitting = false;
          }, (response) => {
            this.handleXHRError(response);

            this.isSubmitting = false;
          });
        },

        orderConfirmButtonDisabled() {
          return !(this.selectedUser || this.payWithCash || this.payWithPin) || this.totalProductCount() == 0 || this.isSubmitting;
        },

        totalProductCount() {
          return this.orderRows.map(function(row) {
            return row.amount;
          }).reduce((total, amount) => total + amount, 0);
        },

        saveCreditMutation(event) {
          this.isSubmitting = true;

          this.creditMutationFormInvalid = (!this.selectedUser
            || !this.creditMutationAmount || !this.creditMutationDescription);

          if (this.creditMutationFormInvalid) {
            // Prevent event propagation so modal stays visible
            this.isSubmitting = false;
            return event.stopPropagation();
          }

          this.$http.post('/credit_mutations', {
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
            } else {
              // re-set user to update credit
              this.setUser(response.body.user);
            }
            this.$refs.creditMutationModal.hide();

            this.creditMutationAmount = null;
            this.creditMutationDescription = 'Inleg contant';
            const additionalInfo = `${response.body.user.name} - ${this.doubleToCurrency(response.body.amount)}`;
            this.sendFlash('Inleg opgeslagen.', additionalInfo, 'success');

            this.isSubmitting = false;
          }, (response) => {
            this.handleXHRError(response);

            this.isSubmitting = false;
          });
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
        },

        escapeKeyListener: function(evt) {
          if (evt.keyCode === 27 && app.selectedUser) {
            app.setUser(null);
          }
        }
      },

      computed: {
        sumupUrl: function() {
          let affilateKey = element.dataset.sumupKey;
          let callback = element.dataset.sumupCallback;
          return `sumupmerchant://pay/1.0?affiliate-key=${affilateKey}&total=${this.orderTotal()}&currency=EUR&title=Bestelling SOFIA&callback=${callback}`;
        },
      },

      // Listen to escape button which are dispatched on the body content_tag
      // https://vuejsdevelopers.com/2017/05/01/vue-js-cant-help-head-body/
      created: function() {
        document.addEventListener('keyup', this.escapeKeyListener);
      },
      destroyed: function() {
        document.removeEventListener('keyup', this.escapeKeyListener);
      },

      components: {
        Flash,
        UserSelection,
        ActivityOrders
      },
    });
  }
});
