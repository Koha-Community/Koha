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
                formattedParams[key] = this.resource[this.linkData.params[key]];
            });
        }

        if (this.linkData?.href && this.linkData.params) {
            this.linkData.href += "?";
            Object.keys(this.linkData.params).forEach(key => {
                this.linkData.href += `${key}=${formattedParams[key]}&`;
            });
            this.linkData.href = this.linkData.href.slice(0, -1);
        }
        return {
            formattedParams,
        };
    },
};
</script>

<style></style>
