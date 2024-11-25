<template>
    <router-link
        v-if="linkData && linkData.name"
        :to="{
            name: linkData.name,
            params: formattedParams,
        }"
    >
        <slot />
    </router-link>
    <a
        v-else-if="linkData && linkData.href"
        :href="linkData.href"
        :class="{ disabled: linkData.disabled }"
    >
        <slot />
    </a>
    <slot v-else />
</template>

<script>
export default {
    props: {
        linkData: Object,
        resource: Object,
    },
    data() {
        const formattedParams = {};

        if (this.linkData && this.linkData.params) {
            Object.keys(this.linkData.params).forEach(key => {
                formattedParams[key] = this.resource[key];
            });
        }
        return {
            formattedParams,
        };
    },
};
</script>

<style></style>
