<template lang="html">
  <div
    class="grid-tile"
    :class="{
      'grid-tile-product': itemType === 'product',
      'grid-tile-folder': itemType === 'folder',
      'grid-tile-back': itemType === 'back',
      'edit-mode': editMode,
      'draggable': editMode && (itemType === 'product' || itemType === 'folder'),
      'drop-target': draggedItem && draggedItemType === 'product' && (itemType === 'folder' || itemType === 'back'),
      'product-requires-age': itemType === 'product' && selectedUser && selectedUser.minor && item.product.requires_age
    }"
    :style="tileStyle"
    :draggable="editMode && (itemType === 'product' || itemType === 'folder')"
    @click="handleClick"
    @dragover="handleDragOver"
    @drop="handleDrop"
    @dragstart="handleDragStart"
    @dragend="handleDragEnd"
    :data-item-id="itemId"
    :data-item-type="itemType"
  >
    <span v-if="editMode && itemType !== 'back'" class="drag-handle">
      <i class="fas fa-ellipsis-v"></i>
    </span>
    
    <span v-if="editMode && itemType === 'folder'" class="folder-edit-btn" @click.stop="handleEdit">
      <i class="fas fa-pen"></i>
    </span>

    <span v-if="itemType === 'product' && selectedUser && selectedUser.minor && item.product.requires_age" class="product-grid-product-requires-age mb-2 fa-stack">
      <i class="fa fa-circle fa-circle-lighter fa-stack-2x"></i>
      <span class="fa fa-stack-1x fa-inverse fa-plus18"></span>
    </span>

    <span class="grid-tile-name">
      {{ displayName }}
    </span>

    <span v-if="itemType === 'product'" class="grid-tile-price">
      {{ formattedPrice }}
    </span>

    <span v-if="itemType === 'folder' || itemType === 'back'" class="folder-icon">
      <i v-if="itemType === 'folder'" class="fas fa-folder"></i>
      <i v-if="itemType === 'back'" class="fas fa-folder-open"></i>
      <i v-if="itemType === 'back'" class="fas fa-arrow-left folder-back-arrow"></i>
    </span>
  </div>
</template>

<script>
export default {
  props: {
    itemType: {
      type: String,
      required: true,
      validator: value => ['product', 'folder', 'back'].includes(value)
    },
    item: {
      type: Object,
      required: true
    },
    editMode: {
      type: Boolean,
      default: false
    },
    selectedUser: {
      type: Object,
      default: null
    },
    draggedItem: {
      type: Object,
      default: null
    },
    draggedItemType: {
      type: String,
      default: null
    },
    backgroundColor: {
      type: String,
      default: null
    }
  },

  computed: {
    itemId() {
      return this.item.id || 'back';
    },

    displayName() {
      if (this.itemType === 'back') return 'Terug';
      if (this.itemType === 'folder') return this.item.name;
      if (this.itemType === 'product') return this.item.product.name;
      return '';
    },

    formattedPrice() {
      if (this.itemType === 'product') {
        return `€${parseFloat(this.item.price).toFixed(2)}`;
      }
      return '';
    },

    tileStyle() {
      const style = {};
      
      if (this.backgroundColor) {
        style.backgroundColor = this.backgroundColor;
      } else if (this.itemType === 'folder' && this.item.color) {
        style.backgroundColor = this.item.color;
      } else if (this.itemType === 'product' && this.item.product && this.item.product.color) {
        style.backgroundColor = this.item.product.color;
      }
      
      return style;
    }
  },

  methods: {
    handleClick(evt) {
      if (this.editMode) return;
      
      evt.stopPropagation();
      
      this.$emit('click', {
        evt,
        itemType: this.itemType,
        item: this.item
      });
    },

    handleDragOver(evt) {
      if (!this.editMode) return;
      
      evt.preventDefault && evt.preventDefault();
      evt.stopPropagation && evt.stopPropagation();
      
      this.$emit('dragover', {
        evt,
        itemType: this.itemType,
        item: this.item
      });
    },

    handleDrop(evt) {
      if (!this.editMode) return;
      
      evt.preventDefault && evt.preventDefault();
      evt.stopPropagation && evt.stopPropagation();
      
      this.$emit('drop', {
        evt,
        itemType: this.itemType,
        item: this.item
      });
    },

    handleDragStart(evt) {
      if (!this.editMode) return;
      
      evt.dataTransfer.setData('text/plain', this.item.id);
      
      this.$emit('dragstart', {
        evt,
        itemType: this.itemType,
        item: this.item
      });
    },

    handleDragEnd() {
      this.$emit('dragend');
    },

    handleEdit(evt) {
      if (!this.editMode) return;
      
      this.$emit('edit', {
        evt,
        itemType: this.itemType,
        item: this.item
      });
    }
  }
};
</script>