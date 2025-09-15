<template>
    <div class="row">
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
