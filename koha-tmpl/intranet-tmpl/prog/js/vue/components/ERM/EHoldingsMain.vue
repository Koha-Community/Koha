<template>
    <ul>
        <li v-for="provider in erm_providers" :key="provider">
            <router-link
                v-if="provider == 'local'"
                :to="`/cgi-bin/koha/erm/eholdings/local`"
            >
                {{ $__("Local") }}</router-link
            >
            <router-link
                v-else-if="provider == 'ebsco'"
                :to="`/cgi-bin/koha/erm/eholdings/ebsco`"
            >
                {{ $__("EBSCO") }}</router-link
            >
            <ul>
                <li>
                    <router-link
                        :to="`/cgi-bin/koha/erm/eholdings/${provider}/packages`"
                    >
                        {{ $__("Packages") }}</router-link
                    >
                </li>
                <li>
                    <router-link
                        :to="`/cgi-bin/koha/erm/eholdings/${provider}/titles`"
                    >
                        {{ $__("Titles") }}</router-link
                    >
                </li>
            </ul>
        </li>
    </ul>
</template>

<script>

export default {
    setup() {
        return { erm_providers, }
    },
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
