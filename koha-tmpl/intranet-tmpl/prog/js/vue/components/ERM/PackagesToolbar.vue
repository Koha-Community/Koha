<template>
    <router-link to="/cgi-bin/koha/erm/packages/add" class="btn btn-default"
        ><font-awesome-icon icon="plus" />
        {{ $t("New package") }}</router-link
    >
</template>

<script>
export default {
    name: "PackagesToolbar",
}
</script>
