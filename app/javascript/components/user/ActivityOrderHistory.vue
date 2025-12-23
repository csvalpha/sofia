<template lang="html">
  <div class="pb-3 pt-2" v-if="isLoading">
    <div class="spinner-border text-primary d-block m-auto" style="width: 2.5rem; height: 2.5rem;" role="status">
      <span class="visually-hidden">Laden...</span>
    </div>
  </div>
  

  <div v-else>
    <div v-for="order in orders" :key="order.id">
      <b class="mb-1">{{formatTime(order.created_at)}}</b>
      <product-table class="mb-4" :order="order"/>
    </div>
  </div>

</template>

<script>
import ProductTable from '../ProductTable.vue';
import api from '../../api/axiosInstance';
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

    let promise = api.get('/orders', { params });

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
    ProductTable
  }
};
</script>
