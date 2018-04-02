<template lang="html">
  <b-row class="order-history">
    <b-col>
      <b-table :busy.sync="isLoading" :items="ordersProvider" :fields="fields"
        no-provider-sorting sort-by="created_at" sort-desc>
        <template slot="order_total" slot-scope="row">
          <span class="pull-right">
            {{doubleToCurrency(row.item.order_total)}}
            <i @click.stop="row.toggleDetails" :class="['order-history--details-expand', 'fa', 'fa-lg', 'pl-2', row.detailsShowing ? 'fa-chevron-circle-up' : 'fa-chevron-circle-down']"></i>
          </span>
        </template>

        <b-container slot="row-details" slot-scope="row">
          <b-row class="b-table-details--header px-2 py-1 mb-2">
            <b-col sm="5">product</b-col>
            <b-col sm="2" class="text-right">aantal</b-col>
            <b-col sm="3" class="text-right">prijs per stuk</b-col>
            <b-col sm="2" class="text-right pr-3">
              <span class="pr-3">totaal</span>
            </b-col>
          </b-row>
          <b-row v-for="orderRow in row.item.order_rows" class="b-table-details--item px-2">
            <b-col sm="5" >
              {{orderRow.product.name}}
              <div>
                <small class="text-danger"><em>{{orderRowErrors[orderRow.id]}}</em></small>
              </div>
            </b-col>
            <b-col sm="2" class="text-right">
              <template v-if="orderRow.editing">
                <i @click="increaseProductCount(orderRow)"
                   class="fa fa-plus-square-o order-history--item-count"></i>
                <span class="px-2">{{orderRow.product_count}}</span>
                <i @click="decreaseProductCount(orderRow)"
                   class="fa fa-minus-square-o order-history--item-count"></i>
              </template>
              <template v-else>
                {{orderRow.product_count}}
              </template>
            </b-col>
            <b-col sm="3" class="text-right">
              {{doubleToCurrency(orderRow.price_per_product)}}
            </b-col>
            <b-col sm="2" class="text-right pr-1">
              {{doubleToCurrency(orderRow.product_count * orderRow.price_per_product)}}
              <i v-if="orderRow.editing" @click="saveOrderRow(row.item, orderRow)" class="order-history--item-save fa fa-save pl-3"></i>
              <i v-else @click="editOrderRow(orderRow)" class="order-history--item-edit fa fa-pencil pl-3"></i>
            </b-col>
          </b-row>
        </b-container>
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
      orderRowErrors: {},
    };
  },

  methods: {
    ordersProvider() {
      let promise = axios.get(`/activities/${this.activity.id}/orders.json`);

      return promise.then((response) => {
        const orders = response.data;
        orders.map(order => {
          order.order_rows.map(row => { row.editing = false })
        })

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

    editOrderRow(orderRow) {
      orderRow.editing = true;
    },

    saveOrderRow(order, orderRow) {
      const newOrder = {
        order_rows_attributes: [ {
            id: orderRow.id,
            product_count: orderRow.product_count,
        } ]
      }

      axios.patch(`/activities/${this.activity.id}/orders/${order.id}`, newOrder).then((response) => {
        const updatedOrder = response.data;
        const updatedOrderRow = updatedOrder.order_rows.find(r => r.id == orderRow.id);
        let orderRowToUpdate = order.order_rows.find(r => r.id == orderRow.id);

        order.order_total = updatedOrder.order_total;
        orderRowToUpdate = {
          ...updatedOrderRow,
          editing: false
        }

        orderRow.editing = false;
      }, (error) => {
        let errorMessage = 'Something went wrong saving this order row';
        if (error.response.data['order_rows.product_count']) {
          errorMessage = `Aantal ${error.response.data['order_rows.product_count']}`
        }

        this.$set(this.orderRowErrors, orderRow.id, errorMessage);
      })
    },

    increaseProductCount(orderRow) {
      orderRow.product_count += 1;
    },

    decreaseProductCount(orderRow) {
      if (orderRow.product_count > 0) {
        orderRow.product_count -= 1;
      }
    },
  },

  components: {
    Spinner,
  }
};
</script>

<style lang="css">
</style>
