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
        :href="formattedHref"
        :class="{ disabled: linkData.disabled }"
    >
        <slot />
    </a>
    <slot v-else />
</template>

<script>
import { ref } from "vue";
export default {
    props: {
        linkData: Object,
        resource: Object,
    },
    setup(props) {
        const formattedHref = ref(props.linkData?.href);
        const formattedParams = ref({});

        if (props.linkData && props.linkData.params) {
            Object.keys(props.linkData.params).forEach(key => {
                formattedParams.value[key] =
                    props.resource[props.linkData.params[key]];
            });
        }

        if (props.linkData?.href && props.linkData.params) {
            formattedHref.value += "?";
            Object.keys(props.linkData.params).forEach(key => {
                formattedHref.value += `${key}=${formattedParams.value[key]}&`;
            });
            formattedHref.value = formattedHref.value.slice(0, -1);
        }
        if (props.linkData?.href && props.linkData.slug) {
            formattedHref.value += `/${props.resource[props.linkData.slug]}`;
        }
        return {
            formattedHref,
            formattedParams,
        };
    },
};
</script>

<style></style>
