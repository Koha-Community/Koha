<template>
    <div id="toolbar" class="btn-toolbar">
        <router-link
            to="/cgi-bin/koha/preservation/trains/add"
            class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__("New train") }}</router-link
        >
    </div>
</template>

<script>
export default {
    name: "TrainsToolbar",
}
</script>
