<template>
    <ul>
        <li>
            <router-link :to="`/cgi-bin/koha/erm/eholdings/local/packages`">
                {{ $__("Packages") }}</router-link
            >
        </li>
        <li>
            <router-link :to="`/cgi-bin/koha/erm/eholdings/local/titles`">
                {{ $__("Titles") }}</router-link
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
