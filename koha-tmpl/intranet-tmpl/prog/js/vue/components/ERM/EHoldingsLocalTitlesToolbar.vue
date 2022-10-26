<template>
    <div id="toolbar" class="btn-toolbar">
        <router-link
            to="/cgi-bin/koha/erm/eholdings/local/titles/add"
            class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__("New title") }}</router-link
        >
        &nbsp;
        <router-link
            to="/cgi-bin/koha/erm/eholdings/local/titles/import"
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
