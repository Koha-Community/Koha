<template>
    <div id="toolbar" class="btn-toolbar">
        <router-link
            :to="{ name: 'EHoldingsLocalTitlesFormAdd' }"
            class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__("New title") }}</router-link
        >
        &nbsp;
        <router-link
            :to="{ name: 'EHoldingsLocalTitlesFormImport' }"
            class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__("Import from list") }}</router-link
        >
    </div>
</template>

<script>
export default {
    name: "EHoldingsLocalTitleToolbar",
}
</script>
