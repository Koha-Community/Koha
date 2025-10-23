<template>
    <div class="row" style="margin-bottom: 0.9em">
        <div
            v-for="pane in panesToDisplay"
            :key="pane.pane"
            :class="columnSizeClass"
        >
            <slot name="splitPane" :paneFieldList="pane.fields"></slot>
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
import { computed } from "vue";
export default {
    props: {
        fieldList: Array,
        splitScreenGroupings: Array,
    },
    setup(props) {
        const getPaneSortOrder = group => {
            return props.splitScreenGroupings.findIndex(
                grp => grp.name === group
            );
        };
        const determineGroupsForPane = pane => {
            const groups = props.fieldList.filter(
                group => group.splitPane == pane
            );
            return groups.sort(
                (a, b) => getPaneSortOrder(a.name) - getPaneSortOrder(b.name)
            );
        };
        const panesToDisplay = computed(() => {
            return props.splitScreenGroupings
                .reduce((acc, group) => {
                    const isPaneAssigned = acc.find(
                        pane => pane.pane == group.pane
                    );
                    if (isPaneAssigned) return acc;
                    acc.push({
                        pane: group.pane,
                        fields: determineGroupsForPane(group.pane),
                    });
                    return acc;
                }, [])
                .sort((a, b) => a.pane - b.pane);
        });
        const numberOfPanes = computed(() => {
            return panesToDisplay.value.length;
        });
        const columnSizeClass = computed(() => {
            return `col-sm-${Math.floor(12 / numberOfPanes.value)}`;
        });
        return {
            determineGroupsForPane,
            panesToDisplay,
            numberOfPanes,
            columnSizeClass,
        };
    },
};
</script>

<style></style>
