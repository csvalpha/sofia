<template lang="html">
  <div class="users-table">
    <table class="table table-striped" v-if="users.length > 0">
      <thead>
        <tr>
          <th id="id" class="ps-4" aria-colindex="1" @click="sortUsers('id')">
            #
            <span class='pull-right'>
              <i v-if="sortBy === 'id'" :class="['text-muted', 'fa', sortAsc ? 'fa-sort-asc align-bottom' : 'fa-sort-desc align-top']"></i>  
            </span>
          </th>
          <th id="name" aria-colindex="2" @click="sortUsers('name')">
              Naam
              <span class='pull-right'>
                <i v-if="sortBy === 'name'" :class="['text-muted', 'fa', sortAsc ? 'fa-sort-asc align-bottom' : 'fa-sort-desc align-top']"></i> 
              </span>
          </th>
          <th id="credit" aria-colindex="3" @click="sortUsers('credit')">
            Saldo
            <span class='pull-right'>
              <i v-if="sortBy === 'credit'" :class="['text-muted', 'fa', sortAsc ? 'fa-sort-asc align-bottom' : 'fa-sort-desc align-top']"></i> 
            </span>
          </th>
        </tr> 
      </thead>
      <tbody class="table-group-divider">
        <tr v-for="user in sortedUsers" :key="user.id">
          <th class="ps-4" aria-colindex="1">{{ user.id }}</th>
          <td><a :href="`/users/${user.id}`" aria-colindex="2">{{ user.name }}</a></td>
          <td :class="user.credit < 0 ? 'text-danger' : ''" aria-colindex="3">€ {{parseFloat(user.credit).toFixed(2)}}</td>
        </tr>
      </tbody>
      <tfoot class="table-group-divider">
        <tr>
          <th/>
          <th>Totaal</th>
          <th :class="total < 0 ? 'text-danger' : ''">€ {{parseFloat(total).toFixed(2)}}</th>
        </tr>
      </tfoot>
    </table>

    <div v-else class="text-center">
      <div class="">
        <em>Er zijn geen gebruikers om weer te geven</em>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    users: {
      type: Array,
      required: true
    }
  },

  data() {
    return { 
      sortBy: '',
      sortAsc: true
    };
  },

  methods: {
    sortUsers: function(newSortBy) {
      if (newSortBy !== this.sortBy) {
        // different category clicked, so sort ascending
        this.sortAsc = true;
      } else {
        // same category clicked, so reverse sorting order
        this.sortAsc = !this.sortAsc;
      }
      this.sortBy = newSortBy;
    }
  },

  computed: {
    total: function() {
      return this.users.map(user => user.credit)
        .reduce((current, credit) => parseFloat(current) + parseFloat(credit), 0);
    },

    sortedUsers: function() {
      let multiplier = this.sortAsc ? 1 : -1;
      let usersCopy = [...this.users];
      if (this.sortBy === 'name') {
        usersCopy.sort((user1, user2) => (user1.name.toUpperCase() > user2.name.toUpperCase() ? 1 : -1) * multiplier);
      } else {
        usersCopy.sort((user1, user2) => (user1[this.sortBy] - user2[this.sortBy]) * multiplier);
      }
      return usersCopy;
    }
  },

  mounted() {
    this.sortUsers('name');
  }
};
</script>
