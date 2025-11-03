<template lang="html">
  <div class="container">
    <div class="row table-details-header text-uppercase px-2 py-1 mb-2">
      <div class="col-sm-5 fw-normal">product</div>
      <div class="col-sm-2 fw-normal text-end">aantal</div>
      <div class="col-sm-3 fw-normal text-end">prijs per stuk</div>
      <div class="col-sm-2 fw-normal text-end">
        <span :class="editable ? 'pe-3' : ''">totaal</span>
      </div>
    </div>
    <div v-for="orderRow in order.order_rows" class="row table-details-item px-2" :key="orderRow.id">
      <div class="col-sm-5 ps-3" >
        {{orderRow.product.name}}
        <div v-if="orderRowErrors[orderRow.id]">
          <small class="text-danger"><em>{{orderRowErrors[orderRow.id]}}</em></small>
        </div>
      </div>
      <div class="col-sm-2 text-end">
        <template v-if="editable && orderRow.editing">
          <i @click="increaseProductCount(orderRow)"
            class="far fa-square-plus order-history-item-count"></i>
          <span class="px-2">{{orderRow.product_count}}</span>
          <i @click="decreaseProductCount(orderRow)"
            class="far fa-square-minus order-history-item-count"></i>
        </template>
        <template v-else>
          {{orderRow.product_count}}
        </template>
      </div>
      <div class="col-sm-3 text-end">
        {{doubleToCurrency(orderRow.price_per_product)}}
      </div>
      <div :class="['col-sm-2 text-end', editable ? 'pe-1' : 'pe-3']">
        {{doubleToCurrency(orderRow.product_count * orderRow.price_per_product)}}
        <template v-if="editable">
          <i v-if="orderRow.editing" @click="saveOrderRow(orderRow)" class="fas fa-floppy-disk ps-3"></i>
          <i v-else @click="editOrderRow(orderRow)" class="order-history-item-edit fas fa-pencil ps-3"></i>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  props: {
    activity: {
      type: Object
    },
    order: {
      type: Object,
      required: true
    },
    editable: {
      type: Boolean,
      default: false
    }
  },
  data: function () {
    return {
      orderRowErrors: {}
    };
  },
  methods: {
    doubleToCurrency(price) {
      return `€ ${parseFloat(price).toFixed(2)}`;
    },

    editOrderRow(orderRow) {
      orderRow.editing = true;
    },

    saveOrderRow(orderRow) {
      const newOrder = {
        order_rows_attributes: [ {
          id: orderRow.id,
          product_count: orderRow.product_count,
        } ]
      };

      if (this.activity.id) newOrder.activity_id = this.activity.id;

      axios.patch(`/orders/${this.order.id}`, newOrder).then((response) => {
        const updatedOrder = response.data;

        this.$emit('updateordertotal', this.order, updatedOrder.order_total);

        orderRow.editing = false;
      }, (error) => {
        let errorMessage = 'Er is iets misgegaan bij het opslaan van deze rij';
        if (error.response && error.response.data['order_rows.product_count']) {
          errorMessage = `Aantal ${error.response.data['order_rows.product_count']}`;
        }

        this.$set(this.orderRowErrors, orderRow.id, errorMessage);
      });
    },

    increaseProductCount(orderRow) {
      orderRow.product_count += 1;
    },

    decreaseProductCount(orderRow) {
      if (orderRow.product_count > 0) {
        orderRow.product_count -= 1;
      }
    }
  }
};
</script>
