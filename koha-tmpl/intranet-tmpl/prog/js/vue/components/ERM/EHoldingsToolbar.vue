<template>
    <router-link to="/cgi-bin/koha/erm/eholdings/add" class="btn btn-default"
        ><font-awesome-icon icon="plus" />
        {{ $t("New eHolding") }}</router-link
    >
</template>

<script>
export default {
    name: "EHoldingsToolbar",
}
</script>
