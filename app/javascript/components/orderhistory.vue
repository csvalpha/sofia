<template lang="html">
  <b-row class="order-history no-gutters">
    <b-col>
      <b-table show-empty :busy.sync="isLoading" :items="activityProvider" :fields="fields"
               no-provider-sorting sort-by="start_time" sort-desc>
        <template slot="start_time" slot-scope="row">
          {{formatDate(row.item.start_time)}}
        </template>

        <template slot="activity_total" slot-scope="row">
          <span class="pull-right">
            {{doubleToCurrency(row.item.activity_total)}}
            <i @click.stop="row.toggleDetails" :class="['order-history--details-expand', 'fa', 'fa-lg', 'pl-2', row.detailsShowing ? 'fa-chevron-circle-up' : 'fa-chevron-circle-down']"></i>
          </span>
        </template>

        <template slot="empty">
          <p class="my-1 text-center">
            <em>Er zijn geen bestellingen om weer te geven</em>
          </p>
        </template>

        <template slot="row-details" slot-scope="row">
          <div v-for="order in row.item.orders">
            <b class="mb-1">{{formatTime(order.created_at)}}</b>
            <ProductTable class="mb-4" :order="order" />
          </div>
        </template>
      </b-table>

      <spinner class="pt-2 pb-3 m-auto" size="large" v-if="isLoading" />
    </b-col>
  </b-row>
</template>

<script>
  import Spinner from 'vue-simple-spinner';
  import ProductTable from './producttable.vue';
  import axios from 'axios';
  import moment from 'moment';
  import _ from 'lodash';

  export default {
    props: {
      user: {
        type: Object,
        required: true
      },
    },

    data: function () {
      return {
        isLoading: false,
        fields: {
          start_time: {
            label: 'Datum',
            sortable: true
          },
          title: {
            label: 'Titel',
            sortable: false
          },
          activity_total: {
            label: 'Bedrag',
            sortable: false,
            thClass: 'text-right pr-4'
          }
        },
      };
    },

    methods: {
      activityProvider() {
        let params;
        if (this.activity) {
          params = { activity_id: this.activity.id }
        } else if (this.user) {
          params = { user_id: this.user.id }
        }

        let promise = axios.get('/orders', { params });

        return promise.then((response) => {
          const orders = response.data;
          orders.map(order => {
            order.order_rows.map(row => { row.editing = false });
          });

          let activities = _.groupBy(orders, order => order.activity.id);
          activities = _.map(activities, orders => {
            let activity = orders[0].activity;
            let ordersTotal = orders.reduce((accumulator, order) => accumulator + parseFloat(order.order_total), 0);
            return {
              ...activity,
              orders: orders,
              activity_total: ordersTotal
            };
          });
          console.log(activities);
          return activities;
        }, () => {
          return [];
        });
      },

      doubleToCurrency(price) {
        return `€ ${parseFloat(price).toFixed(2)}`;
      },

      formatTime(time) {
        return moment(time).format('HH:mm');
      },

      formatDate(time) {
        return moment(time).format('DD-MM-YY HH:mm');
      }
    },

    components: {
      Spinner,
      ProductTable
    }
  };
</script>

<style lang="css">
</style>
