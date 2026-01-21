import Vue from 'vue/dist/vue.esm';
import api from './api/axiosInstance';
import * as bootstrap from 'bootstrap';
import Sortable from 'sortablejs';

import FlashNotification from './components/FlashNotification.vue';
import UserSelection from './components/orderscreen/UserSelection.vue';
import ActivityOrders from './components/orderscreen/ActivityOrders.vue';

document.addEventListener('turbo:load', () => {
  const element = document.getElementById('order-screen');
  if (element != null) {
    const users = JSON.parse(element.dataset.users);
    const productPrices = JSON.parse(element.dataset.productPrices);
    const folders = JSON.parse(element.dataset.folders || '[]');
    const activity = JSON.parse(element.dataset.activity);
    const flashes = JSON.parse(element.dataset.flashes);
    const depositButtonEnabled = element.dataset.depositButtonEnabled === 'true';
    const isTreasurer = element.dataset.isTreasurer === 'true';
    const priceListId = element.dataset.priceListId;

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
          folders: folders,
          activity: activity,
          selectedUser: null,
          payWithCash: false,
          payWithPin: false,
          keepUserSelected: false,
          depositButtonEnabled: depositButtonEnabled,
          orderRows: [],
          isSubmitting: false,
          // Folder navigation
          currentFolder: null,
          // Edit mode (treasurer only)
          editMode: false,
          isTreasurer: isTreasurer,
          priceListId: priceListId,
          // Folder modal
          showFolderModal: false,
          editingFolder: null,
          folderForm: { name: '', color: '#6c757d' },
          // Drag state
          draggedItem: null,
          sortableInstance: null,
          folderSortableInstance: null
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
            api.get(`/users/${user.id}/json?activity_id=${this.activity.id}`).then((response) => {
              const refreshedUser = response.data;
              const index = this.users.findIndex((candidate) => candidate.id === refreshedUser.id);
              if (index !== -1) {
                this.$set(this.users, index, refreshedUser);
              } else {
                this.users.push(refreshedUser);
              }

              if (this.selectedUser && this.selectedUser.id == refreshedUser.id) {
                this.selectedUser = refreshedUser;
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

          api.post('/orders', {
            order: order
          }).then((response) => {
            const user = response.data.user;
            const orderTotal = this.doubleToCurrency(response.data.order_total);
            let additionalInfo;
            if (response.data.paid_with_pin) {
              additionalInfo = `Pin - ${orderTotal}`;
            } else if (response.data.paid_with_cash) {
              additionalInfo = `Contant - ${orderTotal}`;
            } else {
              additionalInfo = `${user.name} - ${orderTotal}`;
            }

            if (user) {
              const index = this.users.findIndex((candidate) => candidate.id === user.id);
              if (index !== -1) {
                this.$set(this.users, index, response.data.user);
              } else {
                this.users.push(response.data.user);
              }
            }

            this.sendFlash('Bestelling geplaatst.', additionalInfo, 'success');
            if(!this.keepUserSelected){
              this.setUser(null);
            } else {
              // re-set user to update credit
              this.setUser(response.data.user);
              this.orderRows = [];
            }

            this.isSubmitting = false;

            if (openWithSumup) {
              this.startSumupPayment(response.data.id, response.data.order_total);
            }
          }, (response) => {
            this.handleXHRError(response);

            this.isSubmitting = false;
          });
        },

        handleXHRError(error) {
          if (error.status === 500) {
            this.sendFlash('Server error!', 'Herlaad de pagina', 'error');

            try {
              throw new Error(JSON.stringify(error.response.data));
            } catch(e) {
              /* eslint-disable no-undef */
              Sentry.captureException(e);
              /* eslint-enable no-undef */
            }
          } else if (error.status === 422) {
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
          const affiliateKey = element.dataset.sumupKey;
          const callback = element.dataset.sumupCallback;
          
          let sumupUrl = `sumupmerchant://pay/1.0?affiliate-key=${affiliateKey}&currency=EUR&title=Bestelling ${element.dataset.siteName}&skip-screen-success=true&foreign-tx-id=${orderId}`;
          if (this.isIos) {
            sumupUrl += `&amount=${orderTotal}&callbacksuccess=${callback}&callbackfail=${callback}`;
          } else {
            sumupUrl += `&total=${orderTotal}&callback=${callback}`;
          }

          window.location = sumupUrl;
        },

        deleteOrder(orderId) {
          bootstrap.Modal.getOrCreateInstance('#sumup-error-order-modal').hide();

          api.delete(`/orders/${orderId}`).then(() => {
            this.sendFlash('Pin bestelling verwijderd.', '', 'success');
            this.$refs.activityOrders.refresh();
          }, (response) => {
            this.handleXHRError(response);
          });
        },

        // Folder navigation methods
        enterFolder(folder) {
          if (!this.editMode) {
            this.currentFolder = folder;
          }
        },

        exitFolder() {
          this.currentFolder = null;
        },

        // Edit mode methods
        toggleEditMode() {
          this.editMode = !this.editMode;
          if (this.editMode) {
            this.$nextTick(() => {
              this.initSortable();
            });
          } else {
            this.destroySortable();
          }
        },

        initSortable() {
          const productGrid = this.$el.querySelector('.product-grid');
          if (productGrid && !this.sortableInstance) {
            this.sortableInstance = Sortable.create(productGrid, {
              animation: 150,
              ghostClass: 'sortable-ghost',
              chosenClass: 'sortable-chosen',
              dragClass: 'sortable-drag',
              filter: '.folder-tile, .back-button-tile, .add-folder-tile',
              onEnd: this.onProductDragEnd.bind(this)
            });
          }

          const folderContainer = this.$el.querySelector('.folder-container');
          if (folderContainer && !this.folderSortableInstance) {
            this.folderSortableInstance = Sortable.create(folderContainer, {
              animation: 150,
              ghostClass: 'sortable-ghost',
              filter: '.add-folder-tile',
              onEnd: this.onFolderDragEnd.bind(this)
            });
          }
        },

        destroySortable() {
          if (this.sortableInstance) {
            this.sortableInstance.destroy();
            this.sortableInstance = null;
          }
          if (this.folderSortableInstance) {
            this.folderSortableInstance.destroy();
            this.folderSortableInstance = null;
          }
        },

        onProductDragEnd(evt) {
          const productPriceId = evt.item.dataset.productPriceId;
          const targetFolderId = evt.to.dataset.folderId || null;
          
          // Update position via API
          const productPrice = this.productPrices.find(p => p.id == productPriceId);
          if (productPrice) {
            this.assignProductToFolder(productPrice, targetFolderId, evt.newIndex);
          }
        },

        onFolderDragEnd(evt) {
          // Update folder positions
          const folderPositions = [];
          const folderElements = evt.to.querySelectorAll('.folder-tile');
          folderElements.forEach((el, index) => {
            const folderId = el.dataset.folderId;
            if (folderId) {
              folderPositions.push({ id: parseInt(folderId), position: index });
              const folder = this.folders.find(f => f.id == folderId);
              if (folder) folder.position = index;
            }
          });

          if (folderPositions.length > 0) {
            api.patch(`/price_lists/${this.priceListId}/product_price_folders/reorder`, {
              folder_positions: folderPositions
            }).catch((response) => {
              this.handleXHRError(response);
            });
          }
        },

        assignProductToFolder(productPrice, folderId, newPosition = 0) {
          api.patch(`/product_prices/${productPrice.id}/assign_folder`, {
            folder_id: folderId
          }).then(() => {
            productPrice.product_price_folder_id = folderId ? parseInt(folderId) : null;
            productPrice.position = newPosition;
          }).catch((response) => {
            this.handleXHRError(response);
          });
        },

        // Drop product on folder
        onDropOnFolder(evt, folder) {
          evt.preventDefault();
          const productPriceId = evt.dataTransfer.getData('productPriceId');
          const productPrice = this.productPrices.find(p => p.id == productPriceId);
          if (productPrice) {
            this.assignProductToFolder(productPrice, folder ? folder.id : null);
          }
        },

        onDragStartProduct(evt, productPrice) {
          evt.dataTransfer.setData('productPriceId', productPrice.id);
          this.draggedItem = productPrice;
        },

        onDragEnd() {
          this.draggedItem = null;
        },

        // Folder CRUD methods
        openFolderModal(folder = null) {
          this.editingFolder = folder;
          if (folder) {
            this.folderForm = { name: folder.name, color: folder.color };
          } else {
            this.folderForm = { name: '', color: '#6c757d' };
          }
          this.showFolderModal = true;
        },

        closeFolderModal() {
          this.showFolderModal = false;
          this.editingFolder = null;
          this.folderForm = { name: '', color: '#6c757d' };
        },

        saveFolder() {
          if (!this.folderForm.name.trim()) {
            this.sendFlash('Voer een mapnaam in', '', 'warning');
            return;
          }

          if (this.editingFolder) {
            // Update existing folder
            api.patch(`/product_price_folders/${this.editingFolder.id}`, {
              product_price_folder: this.folderForm
            }).then((response) => {
              const index = this.folders.findIndex(f => f.id === this.editingFolder.id);
              if (index !== -1) {
                this.$set(this.folders, index, response.data);
              }
              this.sendFlash('Map bijgewerkt', '', 'success');
              this.closeFolderModal();
            }).catch((response) => {
              this.handleXHRError(response);
            });
          } else {
            // Create new folder
            api.post(`/price_lists/${this.priceListId}/product_price_folders`, {
              product_price_folder: this.folderForm
            }).then((response) => {
              this.folders.push(response.data);
              this.sendFlash('Map aangemaakt', '', 'success');
              this.closeFolderModal();
            }).catch((response) => {
              this.handleXHRError(response);
            });
          }
        },

        deleteFolder(folder) {
          if (!confirm(`Map "${folder.name}" verwijderen? Producten worden terug naar het hoofdscherm verplaatst.`)) {
            return;
          }

          api.delete(`/product_price_folders/${folder.id}`).then(() => {
            // Move products back to home
            this.productPrices.forEach(pp => {
              if (pp.product_price_folder_id === folder.id) {
                pp.product_price_folder_id = null;
              }
            });
            // Remove folder from list
            const index = this.folders.findIndex(f => f.id === folder.id);
            if (index !== -1) {
              this.folders.splice(index, 1);
            }
            this.sendFlash('Map verwijderd', '', 'success');
            this.closeFolderModal();
          }).catch((response) => {
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
        },

        // Folder computed properties
        sortedFolders() {
          return [...this.folders].sort((a, b) => a.position - b.position);
        },

        productsWithoutFolder() {
          return this.productPrices
            .filter(pp => !pp.product_price_folder_id)
            .sort((a, b) => a.position - b.position);
        },

        productsInCurrentFolder() {
          if (!this.currentFolder) return [];
          return this.productPrices
            .filter(pp => pp.product_price_folder_id === this.currentFolder.id)
            .sort((a, b) => a.position - b.position);
        },

        visibleProducts() {
          if (this.currentFolder) {
            return this.productsInCurrentFolder;
          }
          return this.productsWithoutFolder;
        },

        isInFolder() {
          return this.currentFolder !== null;
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

          api.post('/credit_mutations', {
            credit_mutation: {
              user_id: app.selectedUser.id,
              activity_id: app.activity.id,
              description: this.creditMutationDescription,
              amount: this.creditMutationAmount
            }
          }).then((response) => {
            const index = app.users.findIndex((candidate) => candidate.id === response.data.user.id);
            if (index !== -1) {
              app.$set(app.users, index, response.data.user);
            } else {
              app.users.push(response.data.user);
            }
            if(!app.keepUserSelected && app.orderRows.length === 0){
              app.setUser(null);
            } else {
              // re-set user to update credit
              app.setUser(response.data.user);
            }

            bootstrap.Modal.getOrCreateInstance('#credit-mutation-modal').hide();


            this.creditMutationAmount = null;
            this.creditMutationDescription = 'Inleg contant';

            const additionalInfo = `${response.data.user.name} - ${app.doubleToCurrency(response.data.amount)}`;
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
          bootstrap.Modal.getOrCreateInstance('#sumup-error-order-modal').hide();

          app.deleteOrder(orderId);
        },

        startSumupPayment(orderId, orderTotal) {
          bootstrap.Modal.getOrCreateInstance('#sumup-error-order-modal').hide();

          app.startSumupPayment(orderId, orderTotal);
        },
      },
      mounted() {
        if (document.getElementById('sumup-error-order-modal')) {
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