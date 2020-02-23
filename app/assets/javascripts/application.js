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
//= require bootstrap.bundle.min.js
// bundle.min.js is sentry browser
//= require bundle.min.js
//= require webfontloader.js
//= require turbolinks-animate/src/index.js
//= require_tree .

/* eslint-disable no-undef */
WebFont.load({
  google: {
    families: ['Roboto:300,400,500']
  }
});

document.addEventListener( 'turbolinks:load', function() {
  TurbolinksAnimate.init({
    element: document.querySelector('main'),
    animation: 'fadein',
    duration: '0.15s',
  });
});
/* eslint-enable no-undef */
