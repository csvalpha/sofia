<template lang="html">
  <b-row class="order-history">
    <b-table small hover :busy.sync="isLoading" :items="ordersProvider" :fields="fields"
      no-provider-sorting sort-by="created_at" sort-desc>
      <template slot="show_details" slot-scope="row">
       <i @click.stop="row.toggleDetails" :class="['fa', 'fa-lg', row.detailsShowing ? 'fa-chevron-circle-up' : 'fa-chevron-circle-down']"></i>
      </template>
      <div slot="row-details" slot-scope="row">
        <b-row v-for="row in row.item.order_rows">
          <b-col></b-col>
          <b-col>{{row.product.name}}</b-col>
          <b-col>
            {{row.product_count}}
            {{' x '}}
            {{doubleToCurrency(row.price_per_product)}}
          </b-col>
          <b-col>
            {{doubleToCurrency(row.product_count * row.price_per_product)}}
          </b-col>
        </b-row>
      </div>
    </b-table>

    <spinner class="pt-2 pb-3 m-auto" size="large" v-if="isLoading" />
  </b-row>
</template>

<script>
import Spinner from 'vue-simple-spinner';
import axios from 'axios';
import moment from 'moment';

export default {
  props: {
    activity: {
      type: Object,
      required: true
    }
  },

  data: function () {
    return {
      isLoading: false,
      fields: {
        id: {
          label: '#',
          sortable: true
        },
        created_at: {
          label: 'Tijdstip',
          sortable: true,
          formatter: 'createdAtFormatter'
        },
        user: {
          label: 'Gebruiker',
          sortable: true,
          formatter: 'userFormatter',
        },
        order_total: {
          label: 'Bedrag',
          sortable: false,
          formatter: 'doubleToCurrency'
        },
        show_details: {
          label: ' ',
          sortable: false
        }
      },
    };
  },

  methods: {
    ordersProvider() {
      let promise = axios.get(`/activities/${this.activity.id}/orders.json`);

      return promise.then((response) => {
        const orders = response.data;

        return orders;
      }, () => {
        return [];
      });
    },

    userFormatter(user) {
      return user ? user.name : '<i>Contant betaald</i>';
    },

    createdAtFormatter(value) {
      return moment(value).format('DD-MM HH:mm:ss');
    },

    doubleToCurrency(price) {
      return `€${parseFloat(price).toFixed(2)}`;
    },
  },

  components: {
    Spinner,
  }
};
</script>

<style lang="css">
</style>
