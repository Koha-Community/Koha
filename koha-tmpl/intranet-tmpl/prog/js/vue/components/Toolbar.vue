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
    methods: {
        stickyToolbar([e]) {
            e.target.classList.toggle("floating", e.intersectionRatio < 1);
        },
    },
    mounted() {
        if (this.sticky) {
            this.observer = new IntersectionObserver(this.stickyToolbar, {
                threshold: [1],
            });
            this.observer.observe(this.$refs.toolbar);
        }
    },
};
</script>
