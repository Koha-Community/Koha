<template>
    <div
        id="toolbar"
        :class="sticky ? 'btn-toolbar sticky' : 'btn-toolbar'"
        ref="toolbar"
    >
        <slot />
    </div>
</template>

<script>
export default {
    name: "Toolbar",
    props: {
        sticky: {
            type: Boolean,
            default: false,
        },
    },
    data() {
        return {
            observer: null,
        };
    },
    methods: {},
    mounted() {
        if (this.sticky) {
            apply_sticky(this.$refs.toolbar);
        }
    },
};
</script>
