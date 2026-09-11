<template>
    <Toolbar>
        <ToolbarButton
            :to="{
                name: 'CirculationTriggersFormConfirmContext',
                query: {
                    library_id: currentLibraryId,
                    patron_category_id: currentPatronCategoryId,
                    item_type_id: currentItemTypeId,
                },
            }"
            icon="plus"
            :title="$__('Add new trigger')"
        />
    </Toolbar>
    <div v-if="filtersInitialized">
        <h1>{{ $__("Circulation triggers") }}</h1>
        <div class="page-section bg-info">
            <p>
                {{
                    $__(
                        "Rules are applied from most specific to less specific, using the first found in this order"
                    )
                }}:
            </p>
            <ul>
                <li>
                    {{
                        $__(
                            "same library, same patron category, same item type"
                        )
                    }}
                </li>
                <li>
                    {{
                        $__(
                            "same library, same patron category, all item types"
                        )
                    }}
                </li>
                <li>
                    {{
                        $__(
                            "same library, all patron categories, same item type"
                        )
                    }}
                </li>
                <li>
                    {{
                        $__(
                            "same library, all patron categories, all item types"
                        )
                    }}
                </li>
                <li>
                    {{
                        $__(
                            "default (all libraries), same patron category, same item type"
                        )
                    }}
                </li>
                <li>
                    {{
                        $__(
                            "default (all libraries), same patron category, all item types"
                        )
                    }}
                </li>
                <li>
                    {{
                        $__(
                            "default (all libraries), all patron categories, same item type"
                        )
                    }}
                </li>
                <li>
                    {{
                        $__(
                            "default (all libraries), all patron categories, all item types"
                        )
                    }}
                </li>
            </ul>
            <p>
                {{
                    $__(
                        "The system is currently set to match based on the %s"
                    ).format(from_branch)
                }}
            </p>
        </div>
        <div
            v-if="
                ruleSetInitialized &&
                currentLibraryId === '*' &&
                triggerCounts['*'] === 0
            "
            class="alert alert-warning"
        >
            <p>
                {{
                    $__(
                        "No default overdue triggers are defined. Default triggers apply to all libraries unless overridden."
                    )
                }}
            </p>
            <template v-if="librariesWithRules.length > 0">
                <p>
                    {{
                        $__(
                            "The following libraries have library-specific triggers defined:"
                        )
                    }}
                </p>
                <ul>
                    <li v-for="lib in librariesWithRules" :key="lib.library_id">
                        <a
                            href="#"
                            @click.prevent="
                                currentLibraryId = lib.library_id;
                                filterRuleSetsbySearchParam();
                            "
                            >{{ lib.name }}</a
                        >
                    </li>
                </ul>
            </template>
            <p v-else>
                {{
                    $__(
                        "No library-specific triggers are defined either. Select add new trigger above to get started."
                    )
                }}
            </p>
        </div>
        <div class="page-section" v-if="filtersInitialized">
            <legend>
                {{ $__("Filter by") }}
                <span style="color: blue; font-weight: bold">{{
                    $__("context")
                }}</span>
            </legend>
            <p v-if="!canManageAnyLibrary" class="alert alert-info">
                {{
                    $__(
                        "You can only manage circulation rules for your own library."
                    )
                }}
            </p>
            <table>
                <thead>
                    <tr>
                        <th>{{ $__("Library") }}</th>
                        <th>{{ $__("Category") }}</th>
                        <th>{{ $__("Item type") }}</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <v-select
                                id="library_select"
                                v-model="currentLibraryId"
                                label="name"
                                :reduce="lib => lib.library_id"
                                :options="
                                    canManageAnyLibrary
                                        ? libraries
                                        : libraries.filter(
                                              lib =>
                                                  lib.library_id ===
                                                  user_library_id
                                          )
                                "
                                @update:modelValue="
                                    filterRuleSetsbySearchParam()
                                "
                                :clearable="false"
                                :disabled="!canManageAnyLibrary"
                                :placeholder="
                                    $__('Default rules for all libraries')
                                "
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="!currentLibraryId"
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
                        </td>
                        <td>
                            <v-select
                                id="patron_category_select"
                                v-model="currentPatronCategoryId"
                                label="name"
                                :reduce="cat => cat.patron_category_id"
                                :options="patronCategories"
                                @update:modelValue="
                                    filterRuleSetsbySearchParam()
                                "
                                :placeholder="$__('any')"
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="!currentPatronCategoryId"
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
                        </td>
                        <td>
                            <v-select
                                id="item_type_select"
                                v-model="currentItemTypeId"
                                label="description"
                                :reduce="itype => itype.item_type_id"
                                :options="itemTypes"
                                @update:modelValue="
                                    filterRuleSetsbySearchParam()
                                "
                                :placeholder="$__('any')"
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="!currentItemTypeId"
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
                        </td>
                    </tr>
                </tbody>
            </table>
            <div class="toggle-view-all-applicable-wrapper">
                <label for="filter-rules">{{ $__("Display ") }}</label>
                <v-select
                    id="filter-rules"
                    v-model="displayAllApplicableRules"
                    :reduce="opt => opt.value"
                    :options="[
                        {
                            value: 0,
                            label: 'explicitly set rules.',
                        },
                        {
                            value: 1,
                            label: 'all applied rules.',
                        },
                    ]"
                    @update:modelValue="filterRuleSetsbySearchParam()"
                >
                </v-select>
            </div>
        </div>
    </div>
    <div
        v-if="filtersInitialized && ruleSetInitialized"
        id="circ-triggers-content"
    >
        <div id="circ-triggers-tabs" class="toptabs numbered">
            <ul class="nav nav-tabs" role="tablist">
                <li
                    v-for="number in triggerCounts[currentLibraryId]"
                    class="nav-item"
                    role="presentation"
                    :key="`noticeTab_${number}`"
                >
                    <a
                        href="#"
                        class="nav-link"
                        role="tab"
                        v-bind:class="
                            tabSelected === `Notice ${number}` ? 'active' : ''
                        "
                        @click="changeTabContent"
                        :data-content="`Notice ${number}`"
                        >{{ $__x("Trigger {number}", { number }) }}
                    </a>
                </li>
            </ul>
        </div>
        <div class="tab-content">
            <template v-for="number in triggerCounts[currentLibraryId]">
                <div
                    class="tab-pane"
                    role="tabpanel"
                    v-bind:class="
                        tabSelected === `Notice ${number}` ? 'show active' : ''
                    "
                    v-if="tabSelected === `Notice ${number}`"
                    :key="`noticeTabContent_${number}`"
                >
                    <div class="page-section">
                        <TriggersTable
                            :modal="false"
                            :displayActions="true"
                            :enableActions="true"
                            :ruleSets="ruleSets"
                            :triggerNumber="number"
                        >
                            <router-link
                                v-if="isLastTrigger(number)"
                                :to="{
                                    name: 'CirculationTriggersFormConfirmTriggerDelete',
                                    query: { triggerNumber: number },
                                }"
                                custom
                                v-slot="{ navigate }"
                            >
                                <span :title="deleteDisabledReason">
                                    <button
                                        :disabled="!!deleteDisabledReason"
                                        @click="navigate"
                                        class="btn btn-primary"
                                    >
                                        <i class="fa-solid fa-xmark"></i>
                                        {{ $__("Delete") }}
                                    </button>
                                </span>
                            </router-link>
                            <div
                                :class="{
                                    'page-section bg-info': true,
                                    'inline-block': isLastTrigger(number),
                                }"
                            >
                                {{
                                    $__(
                                        "Bold italic values denote fallback values where an override has not been set for the context."
                                    )
                                }}
                            </div>
                        </TriggersTable>
                    </div>
                </div>
            </template>
        </div>
    </div>
    <div v-if="showModal" class="modal" role="dialog">
        <div
            class="modal-dialog modal-dialog-centered modal-lg modal-dialog-scrollable"
            role="document"
        >
            <router-view></router-view>
        </div>
    </div>
</template>

<script>
import Toolbar from "../../Toolbar.vue";
import ToolbarButton from "../../ToolbarButton.vue";
import TriggersTable from "./TriggersTable.vue";
import { inject } from "vue";
import { storeToRefs } from "pinia";

export default {
    setup() {
        const circRulesStore = inject("circRulesStore");
        const {
            updateTriggerCount,
            setAllFormattedRuleSets,
            setAllEffectiveRuleSets,
            setAllExhaustiveEffectiveRuleSets,
            isLastTrigger,
            getLibrariesWithRules,
            getLibrariesBlockingTriggerDeletion,
            loadAllLibrariesRuleSets,
            scrollToElementById,
        } = circRulesStore;
        const {
            currentLibraryId,
            currentPatronCategoryId,
            currentItemTypeId,
            itemTypes,
            libraries,
            patronCategories,
            triggerCounts,
            allExhaustiveEffectiveRuleSets,
            allEffectiveRuleSets,
            librariesWithRules,
            lastEditedTriggerNumber,
            storeInitialized,
            metaInitialized,
            canManageAnyLibrary,
            user_library_id,
        } = storeToRefs(circRulesStore);

        return {
            currentLibraryId,
            currentPatronCategoryId,
            currentItemTypeId,
            itemTypes,
            libraries,
            triggerCounts,
            patronCategories,
            updateTriggerCount,
            allExhaustiveEffectiveRuleSets,
            setAllFormattedRuleSets,
            setAllEffectiveRuleSets,
            setAllExhaustiveEffectiveRuleSets,
            allEffectiveRuleSets,
            librariesWithRules,
            isLastTrigger,
            getLibrariesWithRules,
            getLibrariesBlockingTriggerDeletion,
            loadAllLibrariesRuleSets,
            lastEditedTriggerNumber,
            storeInitialized,
            metaInitialized,
            from_branch,
            canManageAnyLibrary,
            user_library_id,
            scrollToElementById,
        };
    },
    data() {
        return {
            filtersInitialized: false,
            ruleSetInitialized: false,
            tabSelected: "Notice 1",
            showModal: false,
            displayAllApplicableRules: 1,
        };
    },
    computed: {
        deleteDisabledReason() {
            const lastTrigger = this.triggerCounts[this.currentLibraryId] || 0;
            return lastTrigger
                ? this.computeDeleteDisabledReason(lastTrigger)
                : "";
        },
    },
    methods: {
        computeDeleteDisabledReason(triggerNumber) {
            if (this.currentPatronCategoryId || this.currentItemTypeId) {
                return this.$__(
                    "Delete is only available when no patron category or item type filter is set, as it removes all explicit rules for this trigger across the selected library."
                );
            }
            if (this.currentLibraryId !== "*") {
                return "";
            }
            const blockingIds =
                this.getLibrariesBlockingTriggerDeletion(triggerNumber);
            if (blockingIds.length === 0) {
                return "";
            }
            const blockingNames = this.libraries
                .filter(lib => blockingIds.includes(lib.library_id))
                .map(lib => lib.name)
                .join(", ");
            return this.$__(
                "Cannot delete: the following libraries have triggers higher than %s, which would be orphaned: %s"
            ).format(triggerNumber, blockingNames);
        },
        async loadRuleSets() {
            this.ruleSetInitialized = false;
            try {
                await this.setAllFormattedRuleSets();
            } catch (e) {
                this.ruleSetInitialized = true;
                return;
            }
            this.updateTriggerCount();
            this.setAllEffectiveRuleSets();
            this.setAllExhaustiveEffectiveRuleSets();
            if (this.currentLibraryId === "*") {
                await this.loadAllLibrariesRuleSets();
                if (this.triggerCounts["*"] === 0) {
                    await this.getLibrariesWithRules();
                }
            }
            this.storeInitialized = true;
        },
        formatSelectedParams() {
            const selectedParams = {};
            selectedParams.effective = true;
            selectedParams.library_id = this.currentLibraryId ?? "*";
            if (this.currentPatronCategoryId) {
                selectedParams.patron_category_id =
                    this.currentPatronCategoryId;
            }
            if (this.currentItemTypeId) {
                selectedParams.item_type_id = this.currentItemTypeId;
            }
            return selectedParams;
        },
        async filterRuleSetsbySearchParam() {
            await this.loadRuleSets();

            const selectedParams = this.formatSelectedParams();
            const data = this.displayAllApplicableRules
                ? this.allExhaustiveEffectiveRuleSets
                : this.allEffectiveRuleSets;

            // handle searches for any patron category and item type combinations
            if (
                !selectedParams.patron_category_id &&
                !selectedParams.item_type_id
            ) {
                this.ruleSets = data;
                this.ruleSetInitialized = true;
                return;
            }

            // handle searches where only the item type is specified
            if (!selectedParams.patron_category_id) {
                this.ruleSets = data.filter(
                    ruleSet =>
                        ruleSet.context.item_type_id ===
                            selectedParams.item_type_id &&
                        ruleSet.context.library_id === selectedParams.library_id
                );
                this.ruleSetInitialized = true;
                return;
            }

            // handle searches where only the patron category is specified
            if (!selectedParams.item_type_id) {
                this.ruleSets = data.filter(
                    ruleSet =>
                        ruleSet.context.patron_category_id ===
                            selectedParams.patron_category_id &&
                        ruleSet.context.library_id === selectedParams.library_id
                );
                this.ruleSetInitialized = true;
                return;
            }

            // handle searches where both patron category and item type are specified and one specific rule is retrieved
            this.ruleSets = data.filter(
                ruleSet =>
                    ruleSet.context.item_type_id ===
                        selectedParams.item_type_id &&
                    ruleSet.context.patron_category_id ===
                        selectedParams.patron_category_id &&
                    ruleSet.context.library_id === selectedParams.library_id
            );
            this.ruleSetInitialized = true;
            return;
        },
        changeTabContent(e) {
            this.tabSelected = e.target.getAttribute("data-content");
        },
    },
    watch: {
        $route: {
            immediate: true,
            async handler(newVal, oldVal) {
                const fromModal = oldVal?.meta?.showModal;
                this.showModal = newVal.meta && newVal.meta.showModal;

                // Handle toggling page scroll as modal accessed / exited
                const overflow = this.showModal ? "hidden" : "";
                document.querySelector("body").style.overflow = overflow;

                // Handle user exiting the modal - do not reload data.
                if (
                    fromModal &&
                    !this.showModal &&
                    !newVal.fullPath.includes("refresh")
                ) {
                    this.filtersInitialized = true;
                    return;
                }

                // Handle initial page loads, and successful save / edit / reset actions - reload data
                if (
                    newVal.fullPath.includes("refresh") ||
                    newVal.path.endsWith("circulation_triggers")
                ) {
                    if (!this.metaInitialized) {
                        await new Promise(resolve => {
                            const stop = this.$watch("metaInitialized", val => {
                                if (val) {
                                    stop();
                                    resolve();
                                }
                            });
                        });
                    }
                    await this.$nextTick();
                    await this.filterRuleSetsbySearchParam();
                    if (this.lastEditedTriggerNumber) {
                        this.tabSelected = `Notice ${this.lastEditedTriggerNumber}`;
                        this.lastEditedTriggerNumber = null;
                    }
                    await this.scrollToElementById("circ-triggers-content");
                }
                this.filtersInitialized = true;
            },
        },
    },
    components: { TriggersTable, Toolbar, ToolbarButton },
};
</script>

<style scoped>
.inline-block {
    display: inline-block;
    width: calc(100% - 90.25px);
    margin: 0 0 0 13px;
}
.page-section table {
    width: 100%;
    table-layout: fixed;
}
.page-section th,
.page-section td {
    width: 33%;
}
.page-section td {
    padding: 0.5em;
    vertical-align: top;
}
.v-select {
    display: block;
    background-color: white;
    margin: 10px;
    height: auto;
}
.vs__search,
.v__selected {
    display: inline-block;
    vertical-align: middle;
}
.active {
    cursor: pointer;
}
.toptabs {
    margin-bottom: 0;
}
.toggle-view-all-applicable-wrapper {
    margin: 10px;
}

.modal {
    position: fixed;
    z-index: 9998;
    display: table;
    transition: opacity 0.3s ease;
    left: 0px;
    top: 0px;
    width: 100%;
    height: 100%;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
    background-color: rgba(0, 0, 0, 0.33);
}
.modal-dialog,
.modal-dialog-centered,
.modal-lg {
    max-width: 90%;
    width: fit-content;
}
</style>
