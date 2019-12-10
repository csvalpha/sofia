<template lang="html">
  <div class="product-totals">
    <user-input class="mb-3" v-model="user" :include-pin="true" :include-cash="true"></user-input>

    <spinner class="pb-3 m-auto" size="large" v-if="isLoading" />
    <div class="table-responsive" v-else>
      <table class="table table-sm" v-if="orderTotals.length > 0">
        <thead>
          <tr>
            <th scope="col">Product</th>
            <th scope="col">Aantal keer besteld</th>
            <th class="text-right" scope="col">Totaalbedrag</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in orderTotals">
            <td>{{row.name}}</td>
            <td>{{row.amount}} x</td>
            <td class="text-right">{{doubleToCurrency(row.price)}}</td>
          </tr>
        </tbody>
      </table>
      <div v-else>
        Er zijn geen producten verkocht
      </div>
    </div>
  </div>
</template>

<script>
  import UserInput from '../userinput.vue';
  import Spinner from 'vue-simple-spinner';

  export default {
    props: {
      activity: {
        required: true,
      }
    },

    data() {
      return {
        user: {
          id: 0
        },
        orderTotals: [],
        isLoading: true
      }
    },

    created() {
      this.loadProductTotals();
    },

    methods: {
      loadProductTotals() {
        this.isLoading = true;

        let params = {};
        if (this.user.id > 0) {
          params.user = this.user.id;
        }
        if (this.user.paid_with_cash) {
          params.paid_with_cash = true;
        }
        if (this.user.paid_with_pin) {
          params.paid_with_pin = true;
        }
        this.$http.get('/activities/'+this.activity+'/product_totals', { params }).then((response) => {
          this.orderTotals = response.body;
          this.isLoading = false;
        })
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
      Spinner,
      UserInput
    }
  }
</script>
