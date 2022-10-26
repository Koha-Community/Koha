<template>
    <ul>
        <li>
            <router-link :to="`/cgi-bin/koha/erm/eholdings/ebsco/packages`">
                <i class="fa fa-file-text-o"></i>
                {{ $__("Packages") }}</router-link
            >
        </li>
        <li>
            <router-link :to="`/cgi-bin/koha/erm/eholdings/ebsco/titles`">
                <i class="fa fa-file-text-o"></i>
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
