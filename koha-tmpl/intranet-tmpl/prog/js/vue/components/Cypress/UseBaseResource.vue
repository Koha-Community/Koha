<template></template>

<script>
import { useBaseResource } from "../../composables/base-resource.js";
export default {
    props: {
        resourceConfig: Object,
    },
    setup(props) {
        const result = useBaseResource(props.resourceConfig);
        return {
            result,
        };
    },
    name: "UseBaseResource",
};
</script>

<style></style>
