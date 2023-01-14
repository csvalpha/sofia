<template lang="html">
  <div class="user-input position-relative">
    <input type="text" class="d-none" :name="name" :value="selectedSuggestion.id">
    <input type="text" class="form-control bg-white" v-model="query" placeholder="Begin met typen..."
           @input="updateValue"
           @keydown.enter="selectFirstSuggestion"
           aria-haspopup="true" v-bind:aria-expanded="dropdownOpened"
           required="true" autocomplete="off">

    <div class="row g-0">
      <ul class="dropdown-menu" v-bind:class="{'show':dropdownOpened}">
        <li class="dropdown-item" v-for="(suggestion, index) in suggestions"
            v-on:click.prevent="suggestionClicked(index)">
          <a href="#">{{ suggestion.name }}</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
  export default {
    props: {
      name: {
        type: String
      },
      value: {
        type: Object,
        default: () => ({})
      },
      includePin: {
        type: Boolean,
        default: false
      },
      includeCash: {
        type: Boolean,
        default: false
      }
    },
    data: function() {
      return {
        query: '',
        selectedSuggestion: this.value,
        open: true,
        suggestions: [],
        suggestionsUpdatedAt: null
      }
    },
    computed: {
      dropdownOpened() {
        return this.query !== '' &&
          this.suggestions.length !== 0 &&
          this.open === true;
      }
    },
    methods: {
      updateValue() {
        if (this.query === '') {
          // Clear user
          this.selectedSuggestion = {};
          this.$emit('input', this.selectedSuggestion);
        }

        if ((new Date() - this.suggestionsUpdatedAt) > 150) {
          this.updateSuggestions();
        } else if (this.open === false) {
          this.open = true;
        }
      },

      // When one of the suggestion is clicked
      suggestionClicked(index) {
        this.selectedSuggestion = this.suggestions[index];
        this.query = this.selectedSuggestion.name;
        this.open = false;
        this.$emit('input', this.selectedSuggestion);
      },

      updateSuggestions() {
        this.suggestions = [];
        if (this.query.length < 2) {
          return;
        }
        this.$http.post('/users/search.json', { query: this.query }).then( (response) => {
          response.data.forEach((a) => {
            this.suggestions.push(a);
          });
          if (this.includePin) {
            if ("gepind".indexOf(this.query.toLowerCase()) >= 0) {
              this.suggestions.push({
                name: "Gepind",
                paid_with_pin: true
              })
            }
          }
          if (this.includeCash) {
            if ("contant betaald".indexOf(this.query.toLowerCase()) >= 0) {
              this.suggestions.push({
                name: "Contant betaald",
                paid_with_cash: true
              })
            }
          }
          this.updateValue();
        });
        this.suggestionsUpdatedAt = new Date();
      },

      selectFirstSuggestion(e) {
        if (this.open) {
          e.preventDefault();
        }
        if (this.suggestions.length > 0) {
          this.suggestionClicked(0);
        }
      }
    }
  };
</script>
