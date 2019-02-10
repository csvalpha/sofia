import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import axios from 'axios';
import BootstrapVue from 'bootstrap-vue';

import Bubbles from '../bubbles.vue';
import OrderHistory from '../orderscreen/orderhistory.vue';

Vue.use(TurbolinksAdapter);
Vue.use(BootstrapVue);

document.addEventListener('turbolinks:load', () => {
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  var element = document.getElementById('user-container');
  if (element !== null) {
    var user = JSON.parse(element.dataset.user);
    new Vue({
      el: element,
      data: () => ({
        user,
        bubblesActivated: false,
        soundActivated: true,
      }),
      created() {
        // Eight seconds seems to be the sweet spot. Also: wait a while
        // because chrome prevents auto play without interaction
        setTimeout(this.activateSound, 8000);
      },
      methods: {
        toggleBubbles() {
          if (this.bubblesActivated) {
            this.bubblesActivated = false;
            this.soundActivated = false;
          } else {
            this.bubblesActivated = true;

            const sound = document.getElementById('bubblesound');
            sound.pause();
          }
        },
        activateSound() {
          const sound = document.getElementById('bubblesound');
          sound.volume = 0.06;
          sound.play();
        }
      },
      components: {
        Bubbles,
        OrderHistory
      }
    });
  }
});
