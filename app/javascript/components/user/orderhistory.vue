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
          <template v-for="activity in activities" class="row table-details-item px-2">
            <tr :key="activity.start_time">
              <td class="ps-4">{{ formatDate(activity.start_time) }}</td>
              <td>{{ activity.title }}</td>
              <td class="text-end">
                <span>
                  {{ doubleToCurrency(activity.order_total) }}
                  <i @click.stop="activity.toggleDetails()" :class="['order-history-details-expand', 'fa', 'fa-lg', 'ps-2', 'pe-1', activity.detailsShowing ? 'fa-chevron-circle-up' : 'fa-chevron-circle-down']"></i>
                </span>
              </td>
            </tr>
            <tr v-if="activity.detailsShowing">
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
  import ActivityOrderHistory from './activityorderhistory.vue';
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
          const activities = response.data;
          activities.sort((activity1, activity2) => activity2.start_time - activity1.start_time);
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
