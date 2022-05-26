<template>
    <router-link to="/cgi-bin/koha/erm/eholdings/titles/add" class="btn btn-default"
        ><font-awesome-icon icon="plus" />
        {{ $t("New title") }}</router-link
    >
</template>

<script>
export default {
    name: "EHoldingsTitleToolbar",
}
</script>
