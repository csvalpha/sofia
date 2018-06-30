// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery3
//= require popper
//= require bootstrap
//= require raven-js/dist/raven.min.js
//= require webfontloader/webfontloader
//= require turbolinks-animate/src/turbolinks-animate
//= require_tree .

/* eslint-disable no-undef */
WebFont.load({
  google: {
    families: ['Roboto:300,400']
  }
});

Raven.config('https://329a65545f5a4cbbb27a1c9d5433113b@sentry.io/228968').install();

document.addEventListener( 'turbolinks:load', function() {
  TurbolinksAnimate.init({
    element: document.querySelector('main'),
    animation: 'fadein',
    duration: '0.15s',
  });
});
/* eslint-enable no-undef */
