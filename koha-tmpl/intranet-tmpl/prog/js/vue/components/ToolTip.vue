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

export default {
    props: {
        toolTip: String | null,
    },
    mounted() {
        new Tooltip(document.body, {
            selector: "[data-bs-toggle='tooltip']",
        });
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
