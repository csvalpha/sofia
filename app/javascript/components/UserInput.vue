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
        <li class="dropdown-item" v-for="(suggestion, index) in suggestions" :key="suggestion.id"
            v-on:click.prevent="suggestionClicked(index)">
          <a href="#">{{ suggestion.name }}</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import api from '../api/axiosInstance';

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
      // This will hold the timer ID for our custom debounce function
      debounceTimer: null,
    };
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
      clearTimeout(this.debounceTimer);

      if (this.query === '') {
        this.selectedSuggestion = {};
        this.$emit('input', this.selectedSuggestion);
        this.suggestions = [];
        return;
      }

      this.debounceTimer = setTimeout(() => {
        this.updateSuggestions();
      }, 400);
    },

    updateSuggestions() {
      if (this.query.length < 2) {
        this.suggestions = [];
        return;
      }

      api.post('/users/search.json', { query: this.query }).then( (response) => {
        let results = response.data || [];

        if (this.includePin && 'gepind'.indexOf(this.query.toLowerCase()) >= 0) {
          results.push({ name: 'Gepind', paid_with_pin: true });
        }
        if (this.includeCash && 'contant betaald'.indexOf(this.query.toLowerCase()) >= 0) {
          results.push({ name: 'Contant betaald', paid_with_cash: true });
        }

        this.suggestions = results;
        this.open = true;
      });
    },

    // When a suggestion is clicked, this logic is still correct
    suggestionClicked(index) {
      this.selectedSuggestion = this.suggestions[index];
      this.query = this.selectedSuggestion.name;
      this.open = false;
      this.$emit('input', this.selectedSuggestion);
    },

    // The enter key logic is still correct
    selectFirstSuggestion(e) {
      if (this.open) {
        e.preventDefault();
      }
      if (this.suggestions.length > 0) {
        this.suggestionClicked(0);
      }
    }
  },
  beforeDestroy() {
    clearTimeout(this.debounceTimer);
  }
};
</script>