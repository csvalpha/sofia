<template lang="html">
  <div class="order-history">
    <b-row>
      <b-col>
        <b-table
          striped hover :busy.sync="isLoading" :items="ordersProvider"
          :fields="fields" no-provider-sorting sort-by="created_at" sort-desc />

        <spinner class="pt-2 pb-3" size="large" v-if="isLoading" />
      </b-col>
    </b-row>
  </div>
</template>

<script>
import BootstrapVue from 'bootstrap-vue';
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
        }
      }
    };
  },

  methods: {
    ordersProvider(_ctx) {
      let promise = axios.get(`/activities/${this.activity.id}/orders.json`);

      return promise.then((response) => {
        const orders = response.data;

        return orders;
      }, (error) => {
        console.error(error);
        return [];
      });
    },

    userFormatter(user) {
      return user.name;
    },

    createdAtFormatter(value) {
      return moment(value).format('DD-MM HH:mm:ss');
    },

    doubleToCurrency(price) {
      return `€${parseFloat(price).toFixed(2)}`;
    },
  },

  components: {
    Spinner
  }
}
</script>

<style lang="css">
</style>
