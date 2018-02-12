import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import VueResource from 'vue-resource';

Vue.use(TurbolinksAdapter);
Vue.use(VueResource);

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

    var orderscreenFlash = {
      template: '#orderscreen-flash',
      props: {
        timeout: {
          type: Number,
          default: 5000
        },
        transition: {
          type: String,
          default: 'slide-fade'
        },
        types: {
          type: Object,
          default: () => ({
            base:    'flash',
            success: 'flash-success',
            error:   'flash-danger',
            warning: 'flash-warning',
            info:    'flash-info'
          })
        },
        icons: {
          type: Object,
          default: () => ({
            base:    'fa fa-lg mr-2',
            error:   'fa-exclamation-circle',
            success: 'fa-check-circle',
            info:    'fa-info-circle',
            warning: 'fa-exclamation-circle',
          })
        },
      },

      data: () => ({
        notificationQue: [],
        activeNotification: null,
        timeoutVar: null
      }),

      created() {
        addEventListener('flash', (flash) => {
          this.flash(flash.detail.message, flash.detail.actionText, flash.detail.type);
        });
      },

      methods: {
        flash(message, actionText, type) {
          const flashData = {
            message: message,
            actionText: actionText,
            type: type,
            typeObject: this.classes(this.types, type),
            iconObject: this.classes(this.icons, type)
          };

          this.notificationQue.push(flashData);
          this.notificationQueChanged();
        },

        classes(propObject, type) {
          let classes = {};
          if(propObject.hasOwnProperty('base')) {
            classes[propObject.base] = true;
          }
          if (propObject.hasOwnProperty(type)) {
            classes[propObject[type]] = true;
          }
          return classes;
        },

        hideCurrentNotification() {
          this.activeNotification = null;
          this.notificationQueChanged();
        },

        notificationQueChanged() {
          if (!this.activeNotification && this.notificationQue.length > 0) {
            const newNotification = this.notificationQue.shift();
            this.activeNotification = null;

            // Small delay for UX purposes
            setTimeout(() => {
              this.activeNotification = newNotification;
            }, 100);
            this.timeoutVar = setTimeout(this.hideCurrentNotification, this.timeout);
          }
        },

        mouseOver() {
          clearTimeout(this.timeoutVar);
        },

        mouseLeave() {
          this.timeoutVar = setTimeout(this.hideCurrentNotification, this.timeout);
        }
      }
    };

    var userSelection = {
      template: '#user-selection',
      props: {
        selectedUser: null,
        payWithCash: false,
        users: {
          type: Array,
          required: true
        }
      },

      data: () => {
        return {
          highlightedUserIndex: -1,
          userQuery: '',
          suggestedUsers: users
        };
      },

      watch: {
        'users': 'queryChange'
      },

      updated: function(){
        const input = this.$refs.userSearchBar;
        if (input) {
          input.focus();
        }
      },

      methods: {
        doubleToCurrency(price) {
          return `€${parseFloat(price).toFixed(2)}`;
        },

        queryChange() {
          this.suggestedUsers = this.searchUsersResult();
          this.resetHighlight();
        },

        searchUsersResult: function() {
          return this.users.filter((user) => {
            return user.name.toLowerCase().indexOf(this.userQuery.toLowerCase()) !== -1;
          });
        },

        resetHighlight() {
          if (this.userQuery.length === 0) {
            this.highlightedUserIndex = -1;
          } else {
            this.highlightedUserIndex = 0;
          }
        },

        increaseHighlightedUserIndex() {
          if ((this.highlightedUserIndex + 1) < this.suggestedUsers.length) {
            this.highlightedUserIndex++;
          }
        },

        decreaseHighlightedUserIndex() {
          if ((this.highlightedUserIndex) > 0) {
            this.highlightedUserIndex--;
          }
        },

        selectUser(user) {
          this.userQuery = '';
          this.queryChange();
          this.$emit('updateuser', user);
        },

        selectHighlightedUser() {
          if (this.searchUsersResult(this.userQuery).length > 0){
            var user = this.searchUsersResult(this.userQuery)[this.highlightedUserIndex];
            this.selectUser(user);
          }
        },

        selectCash() {
          this.userQuery = '';
          this.queryChange();
          this.$emit('selectcash', 'pay_with_cash');
        }
      }
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
            const additionalInfo = `${user ? user.userName : 'Contant'} - ${orderTotal}`;

            if (user) {
              this.$set(this.users, this.users.indexOf(this.selectedUser), response.body.user);
              this.$emit('updateusers');
            }

            this.sendFlash('Bestelling geplaatst.', additionalInfo, 'success');
            this.setUser(null);
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

            this.creditMutationAmount = null;
            this.creditMutationDescription = 'Inleg contant';

            const additionalInfo = `${response.body.user.name} - ${this.doubleToCurrency(response.body.amount)}`;
            this.sendFlash('Inleg opgeslagen.', additionalInfo, 'success');
            this.setUser(null);
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
        'orderscreen-flash': orderscreenFlash,
        'user-selection': userSelection
      }
    });
  }
});
