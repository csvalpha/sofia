<template>
  <transition name="slide-fade">
    <div
      v-if="activeNotification"
      :class="activeNotification.typeObject"
      :mouseover="mouseOver"
      :mouseleave="mouseLeave" >

      <div class="flash-text">
        <i :class="activeNotification.iconObject"/>

        <span class="font-weight-light" :class="{'mr-4': activeNotification.actionText}">
          {{activeNotification.message}}
        </span>

        <div class="flash-undo">
          <em>{{activeNotification.actionText}}</em>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  props: {
    timeout: {
      type: Number,
      default: 5000
    },
    transition: {
      type: String,
      default: 'slide-fade'
    },
    types: {
      type: Object,
      default: () => ({
        base:    'flash',
        success: 'flash-success',
        error:   'flash-danger',
        warning: 'flash-warning',
        info:    'flash-info'
      })
    },
    icons: {
      type: Object,
      default: () => ({
        base:    'fa fa-lg mr-2',
        error:   'fa-exclamation-circle',
        success: 'fa-check-circle',
        info:    'fa-info-circle',
        warning: 'fa-exclamation-circle',
      })
    },
  },

  data: () => ({
    notificationQueue: [],
    activeNotification: null,
    timeoutVar: null
  }),

  created() {
    document.body.addEventListener('flash', (flash) => {
      this.flash(flash.detail.message, flash.detail.actionText, flash.detail.type);
    });
  },

  methods: {
    flash(message, actionText, type) {
      const flashData = {
        message: message,
        actionText: actionText,
        type: type,
        typeObject: this.classes(this.types, type),
        iconObject: this.classes(this.icons, type)
      };

      this.notificationQueue.push(flashData);
      this.notificationQueueChanged();
    },

    classes(propObject, type) {
      let classes = {};
      if(Object.prototype.hasOwnProperty.call(propObject, 'base')) {
        classes[propObject.base] = true;
      }
      if (Object.prototype.hasOwnProperty.call(propObject, type)) {
        classes[propObject[type]] = true;
      }
      return classes;
    },

    hideCurrentNotification() {
      this.activeNotification = null;
      this.notificationQueueChanged();
    },

    notificationQueueChanged() {
      if (!this.activeNotification && this.notificationQueue.length > 0) {
        const newNotification = this.notificationQueue.shift();
        this.activeNotification = null;

        // Small delay for UX purposes
        setTimeout(() => {
          this.activeNotification = newNotification;
        }, 100);
        this.timeoutVar = setTimeout(this.hideCurrentNotification, this.timeout);
      }
    },

    mouseOver() {
      clearTimeout(this.timeoutVar);
    },

    mouseLeave() {
      this.timeoutVar = setTimeout(this.hideCurrentNotification, this.timeout);
    }
  }
};
</script>
