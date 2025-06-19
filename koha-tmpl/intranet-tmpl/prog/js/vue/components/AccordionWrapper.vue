<template>
    <div
        v-for="(group, counter) in accordionList"
        v-bind:key="counter"
        class="accordion"
    >
        <fieldset class="accordion-item">
            <legend
                v-if="group.name"
                type="button"
                data-bs-toggle="collapse"
                :data-bs-target="`#collapse-${counter}`"
                aria-expanded="true"
                :aria-controls="`collapse-${counter}`"
            >
                <i class="fa fa-caret-down" title="Collapse this section"></i>
                {{ group.name }}
            </legend>
            <div
                :id="`collapse-${counter}`"
                class="accordion-collapse collapse show"
                :aria-labelledby="`heading-${counter}`"
                data-bs-parent="#formAccordion"
            >
                <fieldset class="accordion-body rows">
                    <slot name="accordionContent" :accordionGroup="group" />
                </fieldset>
            </div>
        </fieldset>
    </div>
</template>

<script>
export default {
    props: {
        accordionList: {
            type: Array,
            required: true,
        },
    },
};
</script>

<style></style>
