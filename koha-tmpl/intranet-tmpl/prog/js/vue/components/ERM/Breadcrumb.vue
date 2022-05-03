<template>
    <nav id="breadcrumbs" aria-label="Breadcrumb" class="breadcrumb">
        <ol>
            <li>
                <a href="/cgi-bin/koha/mainpage.pl">Home</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/erm/erm.pl"
                    >Electronic resources management</a
                >
            </li>

            <li>
                <router-link to="/cgi-bin/koha/erm/agreements">
                    Agreements</router-link
                >
            </li>
        </ol>
    </nav>
</template>


<script>
export default {
    methods: {
        switchComponent(component) {
            this.component = component
        },
    },
    components: {
    },
};
</script>
