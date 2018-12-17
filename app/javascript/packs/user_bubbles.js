import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';

import Bubbles from '../bubbles.vue';

Vue.use(TurbolinksAdapter);

document.addEventListener('turbolinks:load', () => {
  var element = document.getElementById('user-bubbles');
  if (element !== null) {
    var userName = element.dataset.username;
    new Vue({
      el: element,
      data: () => ({
        userName,
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
        Bubbles
      }
    });
  }
});
