import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';
import axios from 'axios';

import FlashNotification from '../components/FlashNotification.vue';
import UserSelection from '../components/orderscreen/UserSelection.vue';
import ActivityOrders from '../components/orderscreen/ActivityOrders.vue';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

document.addEventListener('turbolinks:load', () => {
  const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  Vue.http.headers.common['X-CSRF-TOKEN'] = token;
  axios.defaults.headers.common['X-CSRF-Token'] = token;

  var element = document.getElementById('order-screen');
  if (element != null) {
    var users = JSON.parse(element.dataset.users);
    var productPrices = JSON.parse(element.dataset.productPrices);
    var activity = JSON.parse(element.dataset.activity);
    var flashes = JSON.parse(element.dataset.flashes);

    window.flash = function(message, actionText, type) {
      const event = new CustomEvent('flash', { detail: { message: message, actionText: actionText, type: type } } );
      document.body.dispatchEvent(event);
    };

    setTimeout(() => {
      for (let message of flashes) {
        window.flash(message[1], null, message[0]);
      }
    }, 100); // Wait for flash component init

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
          if (this.selectedUser === null || user === null || this.selectedUser.id != user.id) {
            this.orderRows = [];
          }

          if (user !== null) {
            // Reload user to get latest credit balance
            this.$http.get(`/users/${user.id}/json?activity_id=${this.activity.id}`).then((response) => {
              const user = response.body;
              this.$set(this.users, this.users.indexOf(user), user);

              // Selected user might have changed in the meantime
              if (this.selectedUser && this.selectedUser.id == user.id) {
                this.selectedUser = user;
              }
            }, (response) => {
              this.handleXHRError(response);
            });
          }

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

        decreaseRowAmount(orderRow) {
          if (orderRow.amount > 0) {
            orderRow.amount--;
          }
        },

        increaseRowAmount(orderRow) {
          orderRow.amount++;
        },

        maybeConfirmOrder() {
          if (!this.selectedUser || this.selectedUser.can_order) {
            this.confirmOrder();
          } else {
            /* eslint-disable no-undef */
            bootstrap.Modal.getOrCreateInstance('#cannot-order-modal').show();
          }
        },

        confirmOrder(openWithSumup = false) {
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
            let additionalInfo;
            if (response.body.paid_with_pin) {
              additionalInfo = `Pin - ${orderTotal}`;
            } else if (response.body.paid_with_cash) {
              additionalInfo = `Contant - ${orderTotal}`;
            } else {
              additionalInfo = `${user.name} - ${orderTotal}`;
            }

            if (user) {
              this.$set(this.users, this.users.indexOf(this.selectedUser), response.body.user);
            }

            this.sendFlash('Bestelling geplaatst.', additionalInfo, 'success');
            if(!this.keepUserSelected){
              this.setUser(null);
            } else {
              // re-set user to update credit
              this.setUser(response.body.user);
              this.orderRows = [];
            }

            this.isSubmitting = false;

            if (openWithSumup) {
              this.startSumupPayment(response.body.id, response.body.order_total);
            }
          }, (response) => {
            this.handleXHRError(response);

            this.isSubmitting = false;
          });
        },

        handleXHRError(error) {
          if (error.status == 500) {
            this.sendFlash('Server error!', 'Herlaad de pagina', 'error');

            try {
              throw new Error(error.body.text);
            } catch(e) {
              /* eslint-disable no-undef */
              Sentry.captureException(e);
              /* eslint-enable no-undef */
            }
          } else if (error.status == 422) {
            this.sendFlash('Error bij het opslaan!', 'Probeer het opnieuw', 'warning');
          } else {
            this.sendFlash(`Error ${error.status}?!🤔`, 'Herlaad de pagina', 'info');
          }
        },

        escapeKeyListener(evt) {
          if (evt.keyCode === 27 && app.selectedUser) {
            app.setUser(null);
          }
        },

        startSumupPayment(orderId, orderTotal) {
          let affilateKey = element.dataset.sumupKey;
          let callback = element.dataset.sumupCallback;
          
          let sumupUrl = `sumupmerchant://pay/1.0?affiliate-key=${affilateKey}&currency=EUR&title=Bestelling ${element.dataset.siteName}&skip-screen-success=true&foreign-tx-id=${orderId}`;
          if (this.isIos) {
            sumupUrl += `&amount=${orderTotal}&callbacksuccess=${callback}&callbackfail=${callback}`;
          } else {
            sumupUrl += `&total=${orderTotal}&callback=${callback}`;
          }

          window.location = sumupUrl;
        },

        deleteOrder(orderId) {
          /* eslint-disable no-undef */
          bootstrap.Modal.getOrCreateInstance('#sumup-error-order-modal').hide();

          this.$http.delete(`/orders/${orderId}`).then(() => {
            this.sendFlash('Pin bestelling verwijderd.', '', 'success');
            this.$refs.activityOrders.refresh();
          }, (response) => {
            this.handleXHRError(response);
          });
        },
      },

      computed: {
        orderTotal() {
          return this.orderRows.map(function(row) {
            return row.productPrice.price * row.amount;
          }).reduce((total, amount) => total + amount, 0);
        },

        orderRequiresAge() {
          return this.orderRows.filter((row) => {
            return row.productPrice.product.requires_age;
          }).length > 0;
        },

        orderConfirmButtonDisabled() {
          return !(this.selectedUser || this.payWithCash || this.payWithPin) || this.totalProductCount == 0 || this.isSubmitting;
        },

        showOrderWarning() {
          return this.showCannotOrderWarning || this.showInsufficientCreditWarning || this.showAgeWarning;
        },

        showCannotOrderWarning() {
          return this.selectedUser && !this.selectedUser.can_order;
        },

        showInsufficientCreditWarning() {
          return this.selectedUser && this.selectedUser.insufficient_credit;
        },

        showAgeWarning() {
          return this.selectedUser && this.selectedUser.minor && this.orderRequiresAge;
        },

        totalProductCount() {
          return this.orderRows.map(function(row) {
            return row.amount;
          }).reduce((total, amount) => total + amount, 0);
        },

        isIos() {
          return /iPhone|iPad|iPod/i.test(navigator.userAgent) || // iOS
            (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1); // iPadOS
        },

        isMobile() {
          return this.isIos || /Android|webOS|Opera Mini/i.test(navigator.userAgent);
        }
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
        FlashNotification,
        UserSelection,
        ActivityOrders
      },
    });

    new Vue({
      el: document.getElementById('credit-mutation-modal'),
      data: () => {
        return {
          activityTitle: activity.title,
          creditMutationAmount: null,
          creditMutationDescription: 'Inleg contant',
          creditMutationFormInvalid: false,
          isSubmitting: false
        };
      },
      methods: {
        saveCreditMutation() {
          this.isSubmitting = true;

          this.creditMutationFormInvalid = (!document.getElementById('credit-mutation-modal-form').checkValidity() 
            || !app.selectedUser || !this.creditMutationAmount || !this.creditMutationDescription);

          if (this.creditMutationFormInvalid) {
            this.isSubmitting = false;
            return;
          }

          app.$http.post('/credit_mutations', {
            credit_mutation: {
              user_id: app.selectedUser.id,
              activity_id: app.activity.id,
              description: this.creditMutationDescription,
              amount: this.creditMutationAmount
            }
          }).then((response) => {
            app.$set(app.users, app.users.indexOf(app.selectedUser), response.body.user);

            if(!app.keepUserSelected && app.orderRows.length === 0){
              app.setUser(null);
            } else {
              // re-set user to update credit
              app.setUser(response.body.user);
            }

            /* eslint-disable no-undef */
            bootstrap.Modal.getOrCreateInstance('#credit-mutation-modal').hide();

            this.creditMutationAmount = null;
            this.creditMutationDescription = 'Inleg contant';

            const additionalInfo = `${response.body.user.name} - ${app.doubleToCurrency(response.body.amount)}`;
            app.sendFlash('Inleg opgeslagen.', additionalInfo, 'success');
            this.isSubmitting = false;

          }, (response) => {
            app.handleXHRError(response);
            this.isSubmitting = false;
          });
        },
      }
    });

    new Vue({
      el: document.getElementById('cannot-order-modal'),
      methods: {
        doubleToCurrency(price) {
          return app.doubleToCurrency(price);
        },
      },
      computed: {
        selectedUser() {
          return app.selectedUser;
        }
      }
    });

    new Vue({
      el: document.getElementById('sumup-error-order-modal'),
      methods: {
        deleteOrder(orderId) {
          /* eslint-disable no-undef */
          bootstrap.Modal.getOrCreateInstance('#sumup-error-order-modal').hide();

          app.deleteOrder(orderId);
        },

        startSumupPayment(orderId, orderTotal) {
          /* eslint-disable no-undef */
          bootstrap.Modal.getOrCreateInstance('#sumup-error-order-modal').hide();

          app.startSumupPayment(orderId, orderTotal);
        },
      },
      mounted() {
        if (document.getElementById('sumup-error-order-modal')) {
          /* eslint-disable no-undef */
          bootstrap.Modal.getOrCreateInstance('#sumup-error-order-modal').show();
        }
      },
      computed: {
        isSubmitting() {
          return app.isSubmitting;
        }
      }
    });
  }
});
