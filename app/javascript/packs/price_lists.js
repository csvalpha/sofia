import Vue from 'vue/dist/vue.esm'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  var element = document.getElementById('product_categories')
  if (element != null) {
    var users = new Vue({
      el: element,
      data: {
        cats: []
      },
      created() {
        this.cats.push({ name: "Turkish Cat" })
        this.cats.push({ name: "Russian Cat" })
      }
    })
  }
})
