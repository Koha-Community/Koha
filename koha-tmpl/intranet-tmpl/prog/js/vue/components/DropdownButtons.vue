<template>
    <div class="btn-group">
        <a
            class="btn btn-default dropdown-toggle"
            data-bs-toggle="dropdown"
            href="#"
            ><i class="fa fa-plus"></i> {{ title }}</a
        >
        <ul class="dropdown-menu">
            <li v-for="(item, index) in items" :key="index">
                <ToolbarButton
                    :to="item.to"
                    :title="$__(item.title)"
                    :callback="item.callback"
                    :cssClass="'dropdown-item'"
                />
            </li>
        </ul>
    </div>
</template>

<script>
import ToolbarButton from "./ToolbarButton.vue";

export default {
    components: { ToolbarButton },
    props: ["items", "title"],
};
</script>

<style></style>
