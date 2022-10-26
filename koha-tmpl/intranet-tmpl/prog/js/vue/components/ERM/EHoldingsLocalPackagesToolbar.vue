<template>
    <div id="toolbar" class="btn-toolbar">
        <router-link
            to="/cgi-bin/koha/erm/eholdings/local/packages/add"
            class="btn btn-default"
            ><font-awesome-icon icon="plus" />
            {{ $__("New package") }}</router-link
        >
    </div>
</template>

<script>
export default {
    name: "EHoldingsLocalPackagesToolbar",
}
</script>
