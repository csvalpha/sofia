import { Turbo } from '@hotwired/turbo-rails';
Turbo.start();

import 'jquery';
import 'bootstrap';

import WebFont from 'webfontloader';

WebFont.load({
  google: {
    families: ['Roboto:300,400,500']
  }
});

document.addEventListener('turbo:load', () => {});
