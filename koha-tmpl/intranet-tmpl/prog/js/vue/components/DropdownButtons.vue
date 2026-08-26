<template>
    <div class="btn-group">
        <slot />
        <template v-if="dropdownButtons.length">
            <a
                :class="`btn ${cssClass} dropdown-toggle`"
                data-bs-toggle="dropdown"
                href="#"
                ><i v-if="title" class="fa fa-plus"></i> {{ title }}</a
            >
            <ul class="dropdown-menu">
                <li v-for="(button, index) in dropdownButtons" :key="index">
                    <ToolbarButton
                        :to="button.to"
                        :title="$__(button.title)"
                        :callback="button.callback"
                        :cssClass="'dropdown-item'"
                        :action="button.action"
                    />
                </li>
            </ul>
        </template>
    </div>
</template>

<script>
import ToolbarButton from "./ToolbarButton.vue";

export default {
    components: { ToolbarButton },
    props: {
        dropdownButtons: Array,
        title: String,
        cssClass: {
            type: String,
            default: "btn-default",
        },
    },
};
</script>

<style></style>
