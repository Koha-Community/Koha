<template>
    <ul>
        <li v-for="provider in erm_providers" :key="provider">
            <router-link
                v-if="provider == 'local'"
                :to="`/cgi-bin/koha/erm/eholdings/local`"
            >
                <i class="fa fa-file-text-o"></i>
                {{ $t("Local") }}</router-link
            >
            <router-link
                v-else-if="provider == 'ebsco'"
                :to="`/cgi-bin/koha/erm/eholdings/ebsco`"
            >
                <i class="fa fa-file-text-o"></i>
                {{ $t("EBSCO") }}</router-link
            >
            <ul>
                <li>
                    <router-link
                        :to="`/cgi-bin/koha/erm/eholdings/${provider}/packages`"
                    >
                        <i class="fa fa-file-text-o"></i>
                        {{ $t("Packages") }}</router-link
                    >
                </li>
                <li>
                    <router-link
                        :to="`/cgi-bin/koha/erm/eholdings/${provider}/titles`"
                    >
                        <i class="fa fa-file-text-o"></i>
                        {{ $t("Titles") }}</router-link
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
