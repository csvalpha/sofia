<template lang="html">
  <spinner class="pt-2 pb-3 m-auto" size="large" v-if="isLoading"/>

  <div v-else>
    <div v-for="order in orders" :key="order.id">
      <b class="mb-1">{{formatTime(order.created_at)}}</b>
      <ProductTable class="mb-4" :order="order"/>
    </div>
  </div>

</template>

<script>
import Spinner from 'vue-simple-spinner';
import ProductTable from '../ProductTable.vue';
import ActivityOrderHistory from './ActivityOrderHistory.vue';
import axios from 'axios';
import moment from 'moment';

export default {
  props: {
    user: {
      type: Object,
      required: true
    },
    activity: {
      type: Object,
      required: true
    },
  },

  data: function () {
    return {
      isLoading: true,
      orders: []
    };
  },

  created() {
    let params = { user_id: this.user.id, activity_id: this.activity.id };

    let promise = axios.get('/orders', { params });

    promise.then((response) => {
      this.orders = response.data.sort((a, b) => (a.created_at > b.created_at) ? 1 : -1);
      this.isLoading = false;
    }, () => {
      this.isLoading = false;
    });
  },

  methods: {
    formatTime(time) {
      return moment(time).format('HH:mm');
    }
  },

  components: {
    Spinner,
    ProductTable
  }
};
</script>
