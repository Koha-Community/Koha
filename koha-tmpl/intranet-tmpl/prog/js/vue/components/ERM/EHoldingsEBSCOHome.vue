<template>
    <ul>
        <li>
            <router-link :to="`/cgi-bin/koha/erm/eholdings/ebsco/packages`">
                {{ $__("Packages") }}</router-link
            >
        </li>
        <li>
            <router-link :to="`/cgi-bin/koha/erm/eholdings/ebsco/titles`">
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
