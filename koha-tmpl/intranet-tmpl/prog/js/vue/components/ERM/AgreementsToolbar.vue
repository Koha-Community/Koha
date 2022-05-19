<template>
    <router-link to="/cgi-bin/koha/erm/agreements/add" class="btn btn-default"
        ><font-awesome-icon icon="plus" />
        {{ $t("New agreement") }}</router-link
    >
</template>

<script>
export default {
    name: "AgreementsToolbar",
}
</script>
