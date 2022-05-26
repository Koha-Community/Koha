<template>
    <ul>
        <li>
            <router-link to="/cgi-bin/koha/erm/eholdings/packages">
                <i class="fa fa-file-text-o"></i>
                {{ $t("Packages") }}</router-link
            >
        </li>
        <li>
            <router-link to="/cgi-bin/koha/erm/eholdings/titles">
                <i class="fa fa-file-text-o"></i>
                {{ $t("Titles") }}</router-link
            >
        </li>
    </ul>
</template>

<script>

export default {
    data() {
        return {
        }
    },
    methods: {
    },
    components: {
    },
};
</script>
