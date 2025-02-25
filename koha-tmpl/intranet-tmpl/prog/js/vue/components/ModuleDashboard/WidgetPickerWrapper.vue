<template>
    <div class="widget-details" :id="id">
        <div class="d-flex align-items-center widget-header">
            <h1 class="widget-title me-auto m-0">
                <i v-if="icon" :class="icon"></i> {{ name }}
            </h1>
            <div class="widget-actions">
                <button
                    v-if="!alreadyAdded"
                    class="btn btn-primary me-1 add-widget"
                    @click="addWidget"
                >
                    <font-awesome-icon icon="plus" />
                    {{ $__("Add") }}
                </button>
                <button
                    v-if="alreadyAdded"
                    class="btn btn-default remove-widget"
                    @click="removeWidget"
                >
                    <font-awesome-icon icon="trash" />
                    {{ $__("Remove") }}
                </button>
            </div>
        </div>
        <p class="widget-description">
            {{ description }}
        </p>
    </div>
</template>

<script>
import { toRefs } from "vue";

export default {
    name: "WidgetDetails",
    props: {
        id: {
            type: String,
            required: true,
        },
        name: {
            type: String,
            required: true,
        },
        icon: {
            type: String,
            required: false,
        },
        description: {
            type: String,
            required: true,
        },
        alreadyAdded: {
            type: Boolean,
            default: false,
        },
    },
    emits: ["removed", "added"],
    setup(props, { emit }) {
        const { id, name, icon, description, alreadyAdded } = toRefs(props);

        function removeWidget() {
            emit("removed", props);
        }

        function addWidget() {
            emit("added", props);
        }

        return {
            id,
            name,
            icon,
            description,
            alreadyAdded,
            removeWidget,
            addWidget,
        };
    },
};
</script>

<style scoped>
.widget-description {
    padding: 12px;
}

.widget-header {
    background-color: #f7f7f7;
    border-bottom: 1px solid #ccc;
    border-top-left-radius: 8px;
    border-top-right-radius: 8px;
    padding: 6px 12px;
    margin-bottom: 6px;
}
</style>
