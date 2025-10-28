import Vue from 'vue/dist/vue.esm';

document.addEventListener('turbo:load', () => {
  const element = document.getElementById('payment-add');
  if (element !== null) {
    new Vue({
      el: element,
      data: () => {
        return {
          currentCredit: parseFloat(element.dataset.userCredit),
          paymentAmount: parseFloat(element.dataset.paymentAmount) || 20
        };
      },
      computed: {
        newCredit() {
          return (this.currentCredit + this.paymentAmount).toFixed(2);
        }
      },
      methods: {
        amountValid() {
          return this.paymentAmount >= 20;
        }
      },
    });
  }
});