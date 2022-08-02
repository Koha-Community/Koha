<template>
    <router-link to="/cgi-bin/koha/erm/eholdings/local/titles/add" class="btn btn-default"
        ><font-awesome-icon icon="plus" />
        {{ $t("New title") }}</router-link
    >
    &nbsp;
    <router-link to="/cgi-bin/koha/erm/eholdings/local/titles/import" class="btn btn-default"
        ><font-awesome-icon icon="plus" />
        {{ $t("Import from list") }}</router-link
>
</template>

<script>
export default {
    name: "EHoldingsLocalTitleToolbar",
}
</script>
