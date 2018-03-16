<template lang="html">
  <spinner size="medium" v-if="isLoading"/>
  <div class="order-history" v-else>
    <p>Bestelgeschiedenis!</p>
  </div>
</template>

<script>
import VueResource from 'vue-resource';
import BootstrapVue from 'bootstrap-vue';
import Spinner from 'vue-simple-spinner';

export default {
  props: {
    activity: {
      type: Object,
      required: true
    }
  },

  data: function () {
    return {
      isLoading: true,
      orders: []
    };
  },

  ready: function(){
    this.loadOrders();
  },

  methods: {
    loadOrders() {
      this.isLoading = true;

      this.$http.get(`/activities/${this.activity.id}/orders.json`).then((response) => {
        console.log(response);
      }, (error) => {
        console.log(error);
      });
    }
  },

  components: {
    Spinner
  }
}
</script>

<style lang="css">
</style>
