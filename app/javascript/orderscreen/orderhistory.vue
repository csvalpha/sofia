<template lang="html">
  <b-row class="order-history">
    <b-col>
      <b-table small hover :busy.sync="isLoading" :items="ordersProvider" :fields="fields"
        no-provider-sorting sort-by="created_at" sort-desc>
        <template slot="order_total" slot-scope="row">
          <span class="pull-right">
            {{doubleToCurrency(row.item.order_total)}}
            <i @click.stop="row.toggleDetails" :class="['order-history--row-edit', 'fa', 'fa-lg', 'pl-2', row.detailsShowing ? 'fa-chevron-circle-up' : 'fa-chevron-circle-down']"></i>
          </span>
        </template>
        <div slot="row-details" slot-scope="row">
          <b-container>
            <b-row v-for="row in row.item.order_rows">
              <b-col sm="2" class="text-right">-</b-col>
              <b-col sm="4">{{row.product.name}}</b-col>
              <b-col>
                {{row.product_count}}
                {{' x '}}
                {{doubleToCurrency(row.price_per_product)}}
              </b-col>
              <b-col sm="2" class="pr-0">
                <span class="pull-right">
                  {{doubleToCurrency(row.product_count * row.price_per_product)}}
                  <i class="order-history--row-edit fa fa-lg fa-edit pl-1"></i>
                </span>
              </b-col>
            </b-row>
          </b-container>
        </div>
      </b-table>

      <spinner class="pt-2 pb-3 m-auto" size="large" v-if="isLoading" />
    </b-col>
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
          sortable: true,
          thClass: 'text-center',
          tdClass: 'text-center'
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
          thClass: 'text-right pr-4'
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
