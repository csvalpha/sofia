<template lang="html">
  <div class="product-totals">
    <user-input class="mb-3" v-model="user" :include-pin="true" :include-cash="true"></user-input>

    <div class="pb-3" v-if="isLoading">
      <div class="spinner-border text-primary d-block m-auto" style="width: 2.5rem; height: 2.5rem;" role="status">
        <span class="visually-hidden">Laden...</span>
      </div>
    </div>

    <div class="table-responsive" v-else>
      <table class="table table-sm" v-if="orderTotals.length > 0">
        <thead>
          <tr>
            <th scope="col">Product</th>
            <th scope="col">Aantal keer besteld</th>
            <th class="text-end" scope="col">Totaalbedrag</th>
          </tr>
        </thead>
        <tbody class="table-group-divider">
          <tr v-for="orderTotal in orderTotals" :key="orderTotal.name">
            <td>{{orderTotal.name}}</td>
            <td>{{orderTotal.amount}} x</td>
            <td class="text-end">{{doubleToCurrency(orderTotal.price)}}</td>
          </tr>
          <tr>
            <th scope="col">Totaal</th>
            <td></td>
            <td class="text-end">
              <strong>{{doubleToCurrency(totalAmount)}}</strong>
            </td>
          </tr>
        </tbody>
      </table>
      <table v-else class="table table-striped">
        <tbody>
          <tr>
            <td class="text-center" colspan="4">
              <p class="my-1">
                <em>
                  Er zijn nog geen producten verkocht
                </em>
              </p>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import UserInput from '../UserInput.vue';
import axios from 'axios';

export default {
  props: {
    activity: {
      required: true,
    }
  },

  data() {
    return {
      user: {},
      orderTotals: [],
      totalAmount: 0.0,
      isLoading: true
    };
  },

  created() {
    this.loadProductTotals();
  },

  methods: {
    loadProductTotals() {
      this.isLoading = true;

      let params = {user: this.user.id, paid_with_cash: this.user.paid_with_cash, paid_with_pin: this.user.paid_with_pin};
      axios.get(`/activities/${this.activity}/product_totals`, { params }).then((response) => {
        this.orderTotals = response.data;
        this.totalAmount = this.orderTotals.reduce((a, b) => a + parseFloat(b.price), 0.0);
        this.isLoading = false;
      }).catch((error) => {
        this.isLoading = false;
        console.error(error);
      });
    },
    doubleToCurrency(price) {
      return `€ ${parseFloat(price).toFixed(2)}`;
    },
  },

  watch: {
    user() {
      this.loadProductTotals();
    }
  },

  components: {
    UserInput
  }
};
</script>
