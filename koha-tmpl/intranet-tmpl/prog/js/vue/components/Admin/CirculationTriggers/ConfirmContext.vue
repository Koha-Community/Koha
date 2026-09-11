<template>
    <div v-if="!contextInitialized">
        <p>{{ $__("Loading context...") }}</p>
    </div>
    <fieldset v-else class="rows">
        <legend>
            {{
                isConfirming
                    ? $__("Confirm trigger context")
                    : $__("Selected trigger context")
            }}
        </legend>
        <div class="page-section">
            <ol id="confirm-context-list">
                <li>
                    <label for="library_id" :class="{ required: isConfirming }"
                        >{{ $__("Library") }}:</label
                    >
                    <v-select
                        id="library_id"
                        v-model="context.library_id"
                        label="name"
                        :reduce="lib => lib.library_id"
                        :options="
                            canManageAnyLibrary
                                ? libraries
                                : libraries.filter(
                                      lib => lib.library_id === user_library_id
                                  )
                        "
                        :disabled="!isConfirming || !canManageAnyLibrary"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="isConfirming && !context.library_id"
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span v-if="isConfirming" class="required">{{
                        $__("Required")
                    }}</span>
                </li>
                <li>
                    <label
                        for="patron_category_id"
                        :class="{ required: isConfirming }"
                        >{{ $__("Patron category") }}:</label
                    >
                    <v-select
                        id="patron_category_id"
                        v-model="context.patron_category_id"
                        label="name"
                        :reduce="cat => cat.patron_category_id"
                        :options="patronCategories"
                        :disabled="!isConfirming"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="
                                    isConfirming && !context.patron_category_id
                                "
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span v-if="isConfirming" class="required">{{
                        $__("Required")
                    }}</span>
                </li>
                <li>
                    <label
                        for="item_type_id"
                        :class="{ required: isConfirming }"
                        >{{ $__("Item type") }}:</label
                    >
                    <v-select
                        id="item_type_id"
                        v-model="context.item_type_id"
                        label="description"
                        :reduce="type => type.item_type_id"
                        :options="itemTypes"
                        :disabled="!isConfirming"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="
                                    isConfirming && !context.item_type_id
                                "
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span v-if="isConfirming" class="required">{{
                        $__("Required")
                    }}</span>
                </li>
            </ol>
        </div>
        <div v-if="isConfirming">
            <router-link
                :to="{
                    name: 'CirculationTriggersSelectOrAdd',
                    query: context,
                }"
                class="btn btn-default btn-xs float-end"
                ><i class="fa-solid fa-pencil"></i>
                {{ $__("Confirm context") }}</router-link
            >
        </div>
    </fieldset>
</template>

<script>
export default {
    props: {
        context: { type: Object, required: true },
        contextInitialized: { type: Boolean, required: true },
        editMode: { type: [String, Boolean], required: true },
        canManageAnyLibrary: { type: Boolean, required: true },
        libraries: { type: Array, required: true },
        user_library_id: { type: [String, null], default: null },
        patronCategories: { type: Array, required: true },
        itemTypes: { type: Array, required: true },
    },
    computed: {
        isConfirming() {
            return this.editMode === "confirmContext";
        },
    },
};
</script>

<style scoped>
#confirm-context-list {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    height: fit-content;
}

#confirm-context-list li {
    display: flex;
    flex-direction: column;
    width: 320px;
}

#confirm-context-list .v-select {
    width: 100%;
}

#confirm-context-list label {
    width: 100%;
    text-align: left;
    padding: 0 0 4px 10px;
}

#confirm-context-list span {
    width: 100%;
    align-content: right;
    padding-top: 4px;
}

#confirm-context-list :deep(.v-select ul) {
    max-height: 120px;
}
</style>
