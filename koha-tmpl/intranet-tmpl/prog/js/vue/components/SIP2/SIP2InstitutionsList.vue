<template>
    <div id="sip2_institutions_list">
        <div class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptions"
                @install="doInstall"
            ></KohaTable>
        </div>
    </div>
</template>

<script>
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import KohaTable from "../KohaTable.vue";

export default {
    data: function () {
        return {
            // tableOptions: {
            before_route_entered: false,
            building_table: false,
        };
    },
    methods: {
        table_url: function () {
            // FIXME: This is hardcoded
            return "http://localhost:3000/api/plugins";
        },
    },
    components: { Toolbar, ToolbarButton, KohaTable },
    name: "SIP2InstitutionsList",
};
</script>
