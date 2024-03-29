<template lang="html">
  <div class="row order-history g-0">
    <div class="col">
      <table class="table">
        <thead>
          <tr>
            <th id="start_time" class="ps-4">Datum</th>
            <th id="title">Titel</th>
            <th id="order_total" class="text-end pe-4">Totaal</th>
          </tr> 
        </thead>
        <tbody class="table-group-divider">
          <template v-for="activity in activities">
            <tr :key="activity.id">
              <td class="ps-4">{{ formatDate(activity.start_time) }}</td>
              <td>{{ activity.title }}</td>
              <td class="text-end">
                <span>
                  {{ doubleToCurrency(activity.order_total) }}
                  <i @click.stop="activity.toggleDetails()" :class="['order-history-details-expand', 'fa', 'fa-lg', 'ps-2', 'pe-1', activity.detailsShowing ? 'fa-chevron-circle-up' : 'fa-chevron-circle-down']"></i>
                </span>
              </td>
            </tr>
            <tr v-if="activity.detailsShowing" :key="activity.id + '-details'">
              <td colspan="4" role="cell">
                <ActivityOrderHistory :activity="activity" :user="user" />
              </td>
            </tr>
          </template>
        </tbody>
      </table>

      <div v-if="activities.length === 0" class="text-center">
        <div class="">
          <em>Er zijn geen bestellingen om weer te geven</em>
        </div>
      </div>

      <div class="pb-3 pt-2" v-if="isLoading">
        <div class="spinner-border text-primary d-block m-auto" style="width: 2.5rem; height: 2.5rem;" role="status">
          <span class="visually-hidden">Laden...</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ActivityOrderHistory from './ActivityOrderHistory.vue';
import axios from 'axios';
import moment from 'moment';

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
      activities: []
    };
  },

  methods: {
    activityProvider() {
      let promise = axios.get('/users/'+this.user.id+'/activities');

      promise.then((response) => {
        let activities = response.data;
        activities.forEach(activity => {
          activity.detailsShowing = false;
          activity.toggleDetails = (() => activity.detailsShowing = !activity.detailsShowing);
        });
        this.activities = activities;
      }, () => {
        this.activities = [];
      });
    },

    doubleToCurrency(price) {
      return `€ ${parseFloat(price).toFixed(2)}`;
    },

    formatDate(time) {
      return moment(time).format('DD-MM-YY HH:mm');
    }
  },

  mounted() {
    this.activityProvider();
  },

  components: {
    ActivityOrderHistory
  }
};
</script>
