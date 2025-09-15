<template>
    <div class="row" style="margin-bottom: 0.9em">
        <div class="col-sm-6">
            <slot
                name="splitPane"
                :paneFieldList="determineGroupsForPane('left')"
            ></slot>
        </div>
        <div class="col-sm-6">
            <slot
                name="splitPane"
                :paneFieldList="determineGroupsForPane('right')"
            ></slot>
        </div>
    </div>
    <template v-if="determineGroupsForPane(null).length > 0">
        <slot
            name="splitPane"
            :paneFieldList="determineGroupsForPane(null)"
        ></slot>
    </template>
</template>

<script>
export default {
    props: {
        fieldList: Array,
    },
    setup(props) {
        const determineGroupsForPane = pane => {
            return props.fieldList.filter(group => group.splitPane == pane);
        };
        return {
            determineGroupsForPane,
        };
    },
};
</script>

<style></style>
