<template>
    <a
        v-if="toolTip"
        class="tooltip_helper"
        data-bs-toggle="tooltip"
        :title="toolTip"
        ><i class="fa-solid fa-circle-question"></i
    ></a>
</template>

<script>
import Tooltip from "bootstrap/js/dist/tooltip";
import { onMounted } from "vue";

export default {
    props: {
        toolTip: String | null,
    },
    setup() {
        onMounted(() => {
            new Tooltip(document.body, {
                selector: "[data-bs-toggle='tooltip']",
            });
        });
        return {};
    },
    name: "ToolTip",
};
</script>

<style>
.tooltip_helper {
    margin-left: 0.5em;
}
.tooltip_helper:hover {
    cursor: pointer;
}
</style>
