<template>
    <div>
        <div id="sub-header">
            <Breadcrumbs></Breadcrumbs>
            <Help />
        </div>
        <div class="main container-fluid">
            <div class="row">
                <div class="col-md-10 col-md-offset-1 col-lg-8 col-lg-offset-2">
                    <main>
                        <Dialog></Dialog>
                        <router-view />
                    </main>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Breadcrumbs from "../../Breadcrumbs.vue";
import Help from "../../Help.vue";
import Dialog from "../../Dialog.vue";

export default {
    components: {
        Breadcrumbs,
        Dialog,
        Help,
    },
};
</script>

<style></style>
