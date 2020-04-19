<template lang="html">
  <div class="col-sm-12">
    <h3>{{this.title}}</h3>
    <b-table :fields="fields" :items="users" responsive="" show-empty="" sort-by="name" striped="">
      <template v-slot:cell(name)="data">
        <a :href="`/users/${data.item.id}`">
          {{data.value}}
        </a></template>
      <template v-slot:empty>
        <p class="my-1 text-center">
          <em>Er zijn geen gebruikers om weer te geven
          </em>
        </p>
      </template>
      <template v-slot:custom-foot>
        <b-tr>
          <b-th></b-th>
          <b-th>Totaal</b-th>
          <b-th>€ {{parseFloat(total).toFixed(2)}}</b-th>
        </b-tr>
      </template>
    </b-table>
  </div>
</template>

<script>
  export default {
    props: {
      users: {
        type: Array,
        required: true
      },
      title: {
        type: String,
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
              return value <= 0 ? 'text-danger' : '';
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
