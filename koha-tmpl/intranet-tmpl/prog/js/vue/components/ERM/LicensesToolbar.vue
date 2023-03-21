<template>
    <div id="toolbar" class="btn-toolbar">
        <router-link :to="{ name: 'LicensesFormAdd' }" class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__("New license") }}</router-link
        >
    </div>
</template>

<script>
export default {
    name: "LicensesToolbar",
}
</script>
