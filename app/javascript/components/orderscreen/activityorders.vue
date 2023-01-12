<template lang="html">
  <div class="row order-history g-0">
    <div class="col">
      <table class="table">
        <thead>
          <tr>
            <th id="id" class="ps-4">#</th>
            <th id="created_at">Tijdstip</th>
            <th id="user">Gebruiker</th>
            <th id="order_total" class="text-end pe-4">Bedrag</th>
          </tr> 
        </thead>
        <tbody>
          <template v-for="order in orders" class="row table-details-item px-2">
            <tr :key="order.id">
              <th class="ps-4">{{ order.id }}</th>
              <td>{{ formatDate(order.created_at) }}</td>
              <td :class="order.user ? '' : 'fst-italic'">
                <span v-if="order.user">{{order.user.name}}</span>
                <span v-else-if="order.paid_with_pin">Gepind</span>
                <span v-else-if="order.paid_with_cash">Contant betaald</span>
              </td>
              <td class="text-end">
                <span>
                  {{ doubleToCurrency(order.order_total) }}
                  <i @click.stop="order.toggleDetails()" :class="['order-history-details-expand', 'fa', 'fa-lg', 'ps-2', 'pe-1', order.detailsShowing ? 'fa-chevron-circle-up' : 'fa-chevron-circle-down']"></i>
                </span>
              </td>
            </tr>
            <tr v-if="order.detailsShowing">
              <td colspan="4" role="cell">
                <product-table @updateordertotal="updateOrderTotal" editable :order="order" :activity="activity" />
              </td>
            </tr>
          </template>
        </tbody>
      </table>

      <div v-if="orders.length === 0" class="text-center">
        <div class="">
          <em>Er zijn geen bestellingen om weer te geven</em>
        </div>
      </div>

      <div class="pb-3 pt-2" v-if="isLoading">
        <div class="spinner-border text-primary d-block m-auto" style="width: 2.5rem; height: 2.5rem;" role="status">
          <span class="visually-hidden">Laden...</span>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
import axios from 'axios';
import moment from 'moment';
import ProductTable from '../producttable.vue';

export default {
  props: {
    activity: {
      type: Object,
      required: true
    },
    editable: {
      type: Boolean,
      default: false
    },
    expand_first: {
      type: Boolean,
      default: false
    }
  },

  data: function () {
    return {
      isLoading: false,
      orders: []
    };
  },

  methods: {
    ordersProvider() {
      let params;
      if (this.activity) {
        params = { activity_id: this.activity.id }
      } else if (this.user) {
        params = { user_id: this.user.id }
      }

      let promise = axios.get('/orders', { params });

      return promise.then((response) => {
        const orders = response.data;
        orders.sort((order1, order2) => order2.id - order1.id);
        orders.map((order, index) => {
          order.order_rows.map(row => { row.editing = false });
          order.detailsShowing = (this.expand_first && index === 0);
          order.toggleDetails = (() => order.detailsShowing = !order.detailsShowing);
        });
        this.orders = orders;
      }, () => {
        this.orders = [];
      });
    },

    updateOrderTotal(order, total) {
      order.order_total = total;
    },

    doubleToCurrency(price) {
      return `€ ${parseFloat(price).toFixed(2)}`;
    },

    formatDate(time) {
      return moment(time).format('DD-MM HH:mm:ss');
    }
  },

  mounted() {
    this.ordersProvider();
  },

  components: {
    ProductTable
  }
};
</script>
