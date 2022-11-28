<template lang="html">
  <b-table class="users-table" :fields="fields" :items="users" responsive="" show-empty="" sort-by="name" striped="">
    <template #cell(name)="data">
      <a :href="`/users/${data.item.id}`">
        {{data.value}}
      </a></template>
    <template #empty>
      <p class="my-1 text-center">
        <em>Er zijn geen gebruikers om weer te geven
        </em>
      </p>
    </template>
    <template #custom-foot>
      <b-tr>
        <b-th></b-th>
        <b-th>Totaal</b-th>
        <b-th :class="total < 0 ? 'text-danger' : ''">€ {{parseFloat(total).toFixed(2)}}</b-th>
      </b-tr>
    </template>
  </b-table>
</template>

<script>
export default {
  props: {
    users: {
      type: Array,
      required: true
    }
  },

  data: function () {
    return {
      fields: [
        {
          key: 'id',
          label: '#',
          sortable: true,
          isRowHeader: true
        },
        {
          key: 'name',
          label: 'Naam',
          sortable: true
        },
        {
          key: 'credit',
          label: 'Saldo',
          sortable: true,
          tdClass: (value) => {
            return value < 0 ? 'text-danger' : '';
          },
          formatter: (value) => `€ ${parseFloat(value).toFixed(2)}`,
        }
      ]
    };
  },
  computed: {
    total: function() {
      return this.users.map(user => user.credit)
        .reduce((current, credit) => parseFloat(current) + parseFloat(credit));
    }
  }
};
</script>
