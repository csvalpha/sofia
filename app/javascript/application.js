import { Turbo } from '@hotwired/turbo-rails';
Turbo.start();

import Vue from 'vue/dist/vue.esm';
import VueResource from 'vue-resource';
import axios from 'axios';

import 'jquery';
import 'bootstrap';

import WebFont from 'webfontloader';
import '@fortawesome/fontawesome-free/css/all.css';

Vue.use(VueResource);

WebFont.load({
  google: {
    families: ['Roboto:300,400,500']
  }
});

document.addEventListener('turbo:load', () => {});
