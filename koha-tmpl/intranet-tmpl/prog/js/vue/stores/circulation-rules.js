import { defineStore } from "pinia";
import { $__ } from "../i18n";
import { APIClient } from "../fetch/api-client.js";
import { isEqual } from "lodash";
import { permissionsActions } from "../composables/permissions";
import { reactive, toRefs, computed } from "vue";
import { cloneDeep } from "lodash";

// NOTES ON RULE SETS TYPES
// exhaustive:  includes 'pure fallback' rules sets for contexts that no rules match.
//              Format: [{overdue_X_<rule_name>: {value: mixed: isFallback: bool}}]
// effective:   includes sets only for contexts for which one or more rule exists in the db. These sets will include fallbacks.
//              Format: [{overdue_X_<rule_name>: <value>}}
// raw:         includes only the exact sets as they are found in the db
//              Format: [{overdue_X_<rule_name>: <value>}}]

export const useCircRulesStore = defineStore("circRules", () => {
    const store = reactive({
        // context
        currentLibraryId: "*",
        currentPatronCategoryId: null,
        currentItemTypeId: null,
        triggerCounts: { "*": 0 },
        lastEditedTriggerNumber: null,
        metaInitialized: false,
        // references
        itemTypes: [],
        libraries: [],
        patronCategories: [],
        userPermissions: null,
        user_library_id: null,
        letters: [],
        ruleSuffixes: ["delay", "notice", "mtt", "restrict"],
        transportTypes: [
            { code: "email", name: $__("Email") },
            { code: "sms", name: $__("SMS") },
            { code: "print", name: $__("Print") },
        ],
        // rule sets
        allDefaultLibraryRawRuleSets: [], // source of truth for default library
        allCurrentLibraryRawRuleSets: [], // source of truth for current library
        allLibrariesRawRuleSets: [], // all rule sets across all libraries; loaded lazily on confirm screens for library=* rule sets. Only loaded if necessary (eg. 'Delete' modal access on default library triggers).
        allEffectiveRuleSets: [], // main data set for display explicitly set rules for current library
        allExhaustiveEffectiveRuleSets: [], // main data set for display all applied rules for current library
        currentAndDefaultRawRuleSets: [], // data set to identify effective rules from (combines allDefaultLibraryRawRuleSets and allCurrentLibraryRawRuleSets)
        librariesWithRules: [],
        storeInitialized: false,
    });

    const canManageAnyLibrary = computed(
        () =>
            !store.userPermissions ||
            !!store.userPermissions
                .CAN_user_parameters_manage_circ_rules_from_any_libraries
    );

    // Exposed as a computed rather than an action to prevent `$id` warnings
    // when called from a Vue component during render.
    const getLibrariesBlockingTriggerDeletion = computed(
        () => triggerNumber => {
            const hasRuleAboveCurrentTriggerNumber = ruleSet => {
                return Object.keys(ruleSet).some(ruleName => {
                    const match = ruleName.match(/^overdue_(\d+)_/);
                    if (!match) {
                        return false;
                    }
                    return (
                        ruleSet[ruleName] != null &&
                        parseInt(match[1]) > triggerNumber
                    );
                });
            };

            const blocking = new Set();
            for (const ruleSet of store.allLibrariesRawRuleSets) {
                const library_id = ruleSet.context?.library_id;
                if (!library_id || library_id === "*") {
                    continue;
                }
                if (blocking.has(library_id)) {
                    continue;
                }
                if (hasRuleAboveCurrentTriggerNumber(ruleSet)) {
                    blocking.add(library_id);
                }
            }
            return [...blocking];
        }
    );

    const actions = {
        // controllers
        async init(defaultLibraryId = "*", userLibraryId = null) {
            store.user_library_id = userLibraryId;
            await this.loadUserPermissions();
            await this.getItemTypes();
            await this.getLibraries();
            await this.getPatronCategories();
            // If user can only manage their own library, override the default view
            if (!canManageAnyLibrary.value && store.user_library_id) {
                this.currentLibraryId = store.user_library_id;
            } else {
                this.currentLibraryId = defaultLibraryId;
            }
            this.metaInitialized = true;
        },
        async loadUserPermissions() {
            if (this.userPermissions !== null) {
                return;
            }
            await this.getConfigurationOptions();
        },
        // utilities
        compareByProperty(property) {
            return (a, b) => a[property].localeCompare(b[property]);
        },
        formatTriggerSpecificRuleSetForDisplay(
            context,
            triggerNumber,
            includeFallbacks = true
        ) {
            const triggerSpecificRuleSet = {
                context,
            };
            this.ruleSuffixes.forEach(ruleSuffix => {
                triggerSpecificRuleSet[
                    `overdue_${triggerNumber}_${ruleSuffix}`
                ] = this.findEffectiveRule(
                    context,
                    ruleSuffix,
                    triggerNumber,
                    includeFallbacks
                );
            });
            triggerSpecificRuleSet[`overdue_${triggerNumber}_has_rules`] =
                this.findEffectiveRule(
                    context,
                    "has_rules",
                    triggerNumber,
                    includeFallbacks
                );
            return triggerSpecificRuleSet;
        },
        handleContext(value, data, type, displayProperty = "name") {
            const item = data.find(item => item[type] === value);
            return item[displayProperty];
        },
        handleNotice(notice) {
            const letter = this.letters.find(letter => letter.code === notice);
            return letter ? letter.name : notice;
        },
        handleRestrictions(value) {
            if (!value) {
                return;
            }
            return value === "1" ? $__("Yes") : $__("No");
        },
        handleTransport(value, type) {
            if (!value) {
                return "";
            }
            return value.includes(type) ? $__("Yes") : $__("No");
        },
        hasExplicitRulesForTrigger(ruleSet, triggerNumber) {
            return this.ruleSuffixes.some(
                suffix => ruleSet[`overdue_${triggerNumber}_${suffix}`] != null
            );
        },
        maxExplicitTriggerNumber(ruleSet) {
            const regex = new RegExp(
                `^overdue_(\\d+)_(${this.ruleSuffixes.join("|")})$`
            );
            let max = 0;
            Object.keys(ruleSet).forEach(key => {
                const match = key.match(regex);
                if (match && ruleSet[key] !== null) {
                    max = Math.max(max, parseInt(match[1]));
                }
            });
            return max;
        },
        hasConflict(oldRuleSet, newRuleSet, triggerNumber) {
            if (
                !oldRuleSet ||
                !this.hasExplicitRulesForTrigger(oldRuleSet, triggerNumber)
            ) {
                return false;
            }

            if (!this.isSameContext(oldRuleSet.context, newRuleSet.context)) {
                return false;
            }

            return this.ruleSuffixes.some(
                suffix =>
                    !isEqual(
                        oldRuleSet[`overdue_${triggerNumber}_${suffix}`] ??
                            null,
                        newRuleSet[`overdue_${triggerNumber}_${suffix}`] ?? null
                    )
            );
        },
        isOnlyRuleSetForTrigger(triggerNumber) {
            return (
                this.allCurrentLibraryRawRuleSets.filter(ruleSet =>
                    this.hasExplicitRulesForTrigger(ruleSet, triggerNumber)
                ).length === 1
            );
        },
        isLastTrigger(triggerNumber) {
            return (
                parseInt(triggerNumber) ===
                this.triggerCounts[this.currentLibraryId]
            );
        },
        async scrollToElementById(id) {
            let count = 0;
            // ensures that the relevant section is loaded before we attempt to scroll it into view
            while (!document.getElementById(id) && count < 8) {
                await new Promise(resolve => setTimeout(resolve, 250));
                count++;
            }
            const element = document.getElementById(id);
            if (!element) {
                // handle loading the page if the element is not at all present
                return;
            }
            element.scrollIntoView({ behavior: "smooth" });
        },
        isSameContext(a, b) {
            return (
                a.library_id === b.library_id &&
                a.patron_category_id === b.patron_category_id &&
                a.item_type_id === b.item_type_id
            );
        },
        containsMatchingContext(contextList, context) {
            return contextList.some(candidate =>
                this.isSameContext(candidate, context)
            );
        },
        // services
        formatMttForDisplay(rawMtt) {
            return rawMtt?.split(",");
        },
        formatRuleSetMttFields(ruleSets) {
            let triggerNumber = 1;
            for (const ruleSet of ruleSets) {
                while (ruleSet[`overdue_${triggerNumber}_mtt`] !== undefined) {
                    if (
                        typeof ruleSet[`overdue_${triggerNumber}_mtt`] ===
                        "string"
                    ) {
                        ruleSet[`overdue_${triggerNumber}_mtt`] =
                            this.formatMttForDisplay(
                                ruleSet[`overdue_${triggerNumber}_mtt`]
                            );
                    }
                    triggerNumber++;
                }
                triggerNumber = 1;
            }
        },
        getSpecificityScore(ruleSetContext, referenceContext) {
            let score = 0;
            if (
                ruleSetContext.library_id !== "*" &&
                ruleSetContext.library_id === referenceContext.library_id
            )
                score += 4;
            if (
                ruleSetContext.patron_category_id !== "*" &&
                ruleSetContext.patron_category_id ===
                    referenceContext.patron_category_id
            )
                score += 2;
            if (
                ruleSetContext.item_type_id !== "*" &&
                ruleSetContext.item_type_id === referenceContext.item_type_id
            )
                score += 1;
            return score;
        },
        findFallbackRuleSetForField(context, triggerNumber, suffix, ruleSets) {
            const candidates = ruleSets.filter(
                ruleSet =>
                    ruleSet[`overdue_${triggerNumber}_${suffix}`] != null &&
                    (ruleSet.context.library_id === context.library_id ||
                        ruleSet.context.library_id === "*") &&
                    (ruleSet.context.patron_category_id ===
                        context.patron_category_id ||
                        ruleSet.context.patron_category_id === "*") &&
                    (ruleSet.context.item_type_id === context.item_type_id ||
                        ruleSet.context.item_type_id === "*")
            );
            if (candidates.length === 0) return null;
            return candidates.reduce((best, current) =>
                this.getSpecificityScore(current.context, context) >
                this.getSpecificityScore(best.context, context)
                    ? current
                    : best
            );
        },
        buildProjectedRuleSet(
            dependentRuleSet,
            triggerNumber,
            contextRuleSets
        ) {
            const projectedRuleSet = {
                context: dependentRuleSet.context,
                [`overdue_${triggerNumber}_has_rules`]: {
                    value: true,
                    isFallback: false,
                },
            };

            this.ruleSuffixes.forEach(suffix => {
                const field = `overdue_${triggerNumber}_${suffix}`;
                if (dependentRuleSet[field] != null) {
                    projectedRuleSet[field] = {
                        value: dependentRuleSet[field],
                        isFallback: false,
                    };
                    return;
                }
                const fallback = this.findFallbackRuleSetForField(
                    dependentRuleSet.context,
                    triggerNumber,
                    suffix,
                    contextRuleSets
                );
                projectedRuleSet[field] = {
                    value: fallback?.[field] ?? null,
                    isFallback: true,
                };
            });

            return projectedRuleSet;
        },
        findEffectiveRule(
            context,
            ruleSuffix,
            triggerNumber,
            includeFallbacks = true
        ) {
            if (
                !this.currentAndDefaultRawRuleSets ||
                !Array.isArray(this.currentAndDefaultRawRuleSets) ||
                this.currentAndDefaultRawRuleSets.length === 0
            ) {
                return { value: null, isFallback: true };
            }
            // Check if the current ruleSet's value for the ruleSuffix is undefined
            const existingRule = this.currentAndDefaultRawRuleSets.find(
                ruleSet =>
                    ruleSet[`overdue_${triggerNumber}_${ruleSuffix}`] !==
                        undefined &&
                    ruleSet[`overdue_${triggerNumber}_${ruleSuffix}`] !==
                        null &&
                    ruleSet?.context.library_id === context.library_id &&
                    ruleSet?.context.patron_category_id ===
                        context.patron_category_id &&
                    ruleSet?.context.item_type_id === context.item_type_id
            );

            // if handling 'has_rules', derive from actual rules rather than DB
            if (ruleSuffix === "has_rules") {
                const hasExplicit = this.currentAndDefaultRawRuleSets.some(
                    ruleSet =>
                        ruleSet?.context.library_id === context.library_id &&
                        ruleSet?.context.patron_category_id ===
                            context.patron_category_id &&
                        ruleSet?.context.item_type_id ===
                            context.item_type_id &&
                        this.hasExplicitRulesForTrigger(ruleSet, triggerNumber)
                );
                return {
                    value: hasExplicit ? true : null,
                    isFallback: !hasExplicit,
                };
            }

            // If the current ruleSet's value is not null, use it directly
            if (existingRule !== undefined) {
                return {
                    value: existingRule[
                        `overdue_${triggerNumber}_${ruleSuffix}`
                    ],
                    isFallback: !this.hasExplicitRulesForTrigger(
                        existingRule,
                        triggerNumber
                    ),
                };
            }

            // If set to return a raw set, return
            if (!includeFallbacks) {
                return;
            }

            // Filter ruleSets to only those with non-null values for the specified ruleSuffix
            // and that are no excluded from the selected context
            const relevantRules = this.currentAndDefaultRawRuleSets.filter(
                ruleSet =>
                    ruleSet[`overdue_${triggerNumber}_${ruleSuffix}`] !==
                        undefined &&
                    ruleSet[`overdue_${triggerNumber}_${ruleSuffix}`] !==
                        null &&
                    (ruleSet.context.library_id === context.library_id ||
                        ruleSet.context.library_id === "*") &&
                    (ruleSet.context.patron_category_id ===
                        context.patron_category_id ||
                        ruleSet.context.patron_category_id === "*") &&
                    (ruleSet.context.item_type_id === context.item_type_id ||
                        ruleSet.context.item_type_id === "*")
            );

            // Sort the ruleSets based on specificity score, descending
            const sortedRules = relevantRules.sort(
                (a, b) =>
                    this.getSpecificityScore(b.context, context) -
                    this.getSpecificityScore(a.context, context)
            );
            // If no ruleSet found, return null
            if (sortedRules.length === 0) {
                return { value: null, isFallback: true };
            }
            // Get the value from the most specific ruleSet
            const bestRule = sortedRules[0];
            return {
                value: bestRule[`overdue_${triggerNumber}_${ruleSuffix}`],
                isFallback: true,
            };
        },
        setAllExhaustiveEffectiveRuleSets() {
            // clear array
            this.allExhaustiveEffectiveRuleSets = [];
            // generate complete rule set list
            this.patronCategories.forEach(category => {
                this.itemTypes.forEach(itemType => {
                    const effectiveRuleSet = {
                        context: {
                            library_id: this.currentLibraryId,
                            patron_category_id: category.patron_category_id,
                            item_type_id: itemType.item_type_id,
                        },
                    };
                    for (
                        let i = 1;
                        i <= this.triggerCounts[this.currentLibraryId];
                        i++
                    ) {
                        this.ruleSuffixes.forEach(ruleSuffix => {
                            effectiveRuleSet[`overdue_${i}_${ruleSuffix}`] =
                                this.findEffectiveRule(
                                    effectiveRuleSet.context,
                                    ruleSuffix,
                                    i
                                );
                        });
                        effectiveRuleSet[`overdue_${i}_has_rules`] =
                            this.findEffectiveRule(
                                effectiveRuleSet.context,
                                "has_rules",
                                i
                            );
                    }
                    this.allExhaustiveEffectiveRuleSets.push(effectiveRuleSet);
                });
            });
        },
        setAllEffectiveRuleSets() {
            // clear array
            this.allEffectiveRuleSets = [];
            // generate complete rule set list
            this.allCurrentLibraryRawRuleSets.forEach(ruleSet => {
                const effectiveRuleSet = {
                    context: { ...ruleSet.context },
                };
                for (
                    let i = 1;
                    i <= this.triggerCounts[this.currentLibraryId];
                    i++
                ) {
                    if (!this.hasExplicitRulesForTrigger(ruleSet, i)) {
                        continue;
                    }
                    this.ruleSuffixes.forEach(ruleSuffix => {
                        effectiveRuleSet[`overdue_${i}_${ruleSuffix}`] =
                            this.findEffectiveRule(
                                ruleSet.context,
                                ruleSuffix,
                                i
                            );
                    });
                    effectiveRuleSet[`overdue_${i}_has_rules`] =
                        this.findEffectiveRule(ruleSet.context, "has_rules", i);
                }
                this.allEffectiveRuleSets.push(effectiveRuleSet);
            });
        },
        setEffectiveTriggerFilteredRuleSet(context) {
            const effectiveTriggerFilteredRuleSets = [];
            for (
                let i = 1;
                i <= this.triggerCounts[this.currentLibraryId];
                i++
            ) {
                const triggerSpecificRuleSet =
                    this.formatTriggerSpecificRuleSetForDisplay(context, i);
                if (!triggerSpecificRuleSet) {
                    continue;
                }
                effectiveTriggerFilteredRuleSets.push(triggerSpecificRuleSet);
            }
            return effectiveTriggerFilteredRuleSets;
        },
        updateTriggerCount() {
            // Library-specific triggerCounts can fall into the following use cases:
            // - No rule sets specific to them exist. Therefore, their triggerCount is the same as default's.
            // - Rule sets exists that override default triggers. Therefore, their triggerCount is the same as default's.
            // - Rule sets exists for triggers for which there is no default.
            //     => such triggers are follow up addition to the existing default sequence.
            //     => the triggerCount for this library will be higher than default's, and equal to the highest trigger number for this library that has any explicit rules.

            // Set the triggerCount for the default library rule set
            if (this.currentLibraryId === "*") {
                this.triggerCounts["*"] =
                    this.allDefaultLibraryRawRuleSets.reduce(
                        (max, ruleSet) =>
                            Math.max(
                                max,
                                this.maxExplicitTriggerNumber(ruleSet)
                            ),
                        0
                    );
                return;
            }

            // Set a library-specific trigger count: no rule set exists -> simply use the default trigger count
            if (this.allCurrentLibraryRawRuleSets.length === 0) {
                this.triggerCounts[this.currentLibraryId] =
                    this.triggerCounts["*"];
                return;
            }

            // Set a library-specific trigger count: at least one rule set exists -> start from the first trigger for which there is no default rule set
            let i = this.triggerCounts["*"] + 1;
            while (
                this.allCurrentLibraryRawRuleSets.some(ruleSet =>
                    this.hasExplicitRulesForTrigger(ruleSet, i)
                )
            ) {
                i++;
            }
            this.triggerCounts[this.currentLibraryId] = i - 1;
        },
        async setAllRawRuleSets() {
            await this.getCurrentAndDefaultRawRuleSets();

            this.currentAndDefaultRawRuleSets = [
                ...this.allCurrentLibraryRawRuleSets,
                ...this.allDefaultLibraryRawRuleSets,
            ];
        },
        async setAllFormattedRuleSets() {
            await this.setAllRawRuleSets();
            this.formatRuleSetMttFields(this.allDefaultLibraryRawRuleSets);
            if (this.currentLibraryId !== "*") {
                this.formatRuleSetMttFields(this.allCurrentLibraryRawRuleSets);
            }
        },
        async getSelectedRuleSet(context, effective = true) {
            const rawSelectedRuleSet = await this.getRawSelectedRuleSet(
                context,
                effective
            );
            if (!rawSelectedRuleSet) {
                return;
            }

            let formattedSelectedRuleSet = cloneDeep(rawSelectedRuleSet);
            let i = 1;
            while (i <= this.triggerCounts[this.currentLibraryId]) {
                if (rawSelectedRuleSet[`overdue_${i}_mtt`]) {
                    formattedSelectedRuleSet[`overdue_${i}_mtt`] =
                        this.formatMttForDisplay(
                            rawSelectedRuleSet[`overdue_${i}_mtt`]
                        );
                }
                i++;
            }
            return formattedSelectedRuleSet;
        },
        isImpactedByDeletion(
            candidate,
            triggerNumber,
            deletedContexts,
            contextRuleSets
        ) {
            if (
                this.containsMatchingContext(deletedContexts, candidate.context)
            ) {
                return false;
            }
            if (!this.hasExplicitRulesForTrigger(candidate, triggerNumber)) {
                return false;
            }
            return this.ruleSuffixes.some(suffix => {
                if (candidate[`overdue_${triggerNumber}_${suffix}`] != null) {
                    return false;
                }
                const fallback = this.findFallbackRuleSetForField(
                    candidate.context,
                    triggerNumber,
                    suffix,
                    contextRuleSets
                );
                return (
                    fallback &&
                    this.containsMatchingContext(
                        deletedContexts,
                        fallback.context
                    )
                );
            });
        },
        // For a set of rule sets being deleted for a given trigger, return the
        // rule sets that depend on any of them (deduplicated, excluding the
        // ones being deleted themselves) and a projection of their state after
        // the deletion has happened. Reset and bulk-delete modals both consume
        // this — reset passes [currentRuleSet], delete passes the full set.
        async computeDeletionImpact(deletedRuleSets, triggerNumber) {
            let searchRuleSets, contextRuleSets;
            if (this.currentLibraryId === "*") {
                await this.loadAllLibrariesRuleSets();
                searchRuleSets = this.allLibrariesRawRuleSets;
                contextRuleSets = this.allLibrariesRawRuleSets;
            } else {
                searchRuleSets = this.allCurrentLibraryRawRuleSets;
                contextRuleSets = this.currentAndDefaultRawRuleSets;
            }

            const deletedContexts = deletedRuleSets.map(
                ruleSet => ruleSet.context
            );

            const projectedRemainingRawRuleSets = contextRuleSets.filter(
                ruleSet =>
                    !this.containsMatchingContext(
                        deletedContexts,
                        ruleSet.context
                    )
            );

            const dependentRuleSets = searchRuleSets.filter(candidate =>
                this.isImpactedByDeletion(
                    candidate,
                    triggerNumber,
                    deletedContexts,
                    contextRuleSets
                )
            );

            const projectedDependentEffectiveRuleSets = dependentRuleSets.map(
                dependentRuleSet =>
                    this.buildProjectedRuleSet(
                        dependentRuleSet,
                        triggerNumber,
                        projectedRemainingRawRuleSets
                    )
            );

            return {
                dependentRuleSets,
                projectedDependentEffectiveRuleSets,
            };
        },
        // repositories
        async deleteRuleSet(ruleSet, triggerNumber) {
            if (!this.hasExplicitRulesForTrigger(ruleSet, triggerNumber)) {
                return;
            }

            const ruleSetInDb = await this.getSelectedRuleSet(
                ruleSet.context,
                false
            );

            if (this.hasConflict(ruleSet, ruleSetInDb, triggerNumber)) {
                throw "The rule set for the selected trigger context could not be reset as it was updated elsewhere. Please see the updated trigger above.";
            }

            const rulesForDeletion = { context: ruleSet.context };
            this.ruleSuffixes.forEach(suffix => {
                rulesForDeletion[`overdue_${triggerNumber}_${suffix}`] = null;
            });
            await this.updateCircRuleSets(rulesForDeletion, triggerNumber);
        },
        async getLibrariesWithRules() {
            const allRules = await this.fetchRawRuleSets();
            const libraryIds = new Set(
                allRules
                    .map(r => r.context?.library_id)
                    .filter(id => id && id !== "*")
            );
            this.librariesWithRules = this.libraries.filter(
                lib => lib.library_id !== "*" && libraryIds.has(lib.library_id)
            );
        },
        async loadAllLibrariesRuleSets() {
            this.allLibrariesRawRuleSets = await this.fetchRawRuleSets();
            this.formatRuleSetMttFields(this.allLibrariesRawRuleSets);
        },
        async getCurrentAndDefaultRawRuleSets() {
            this.allDefaultLibraryRawRuleSets = await this.fetchRawRuleSets({
                library_id: "*",
            });
            if (this.currentLibraryId === "*") {
                this.allCurrentLibraryRawRuleSets =
                    this.allDefaultLibraryRawRuleSets;
                return;
            }
            this.allCurrentLibraryRawRuleSets = await this.fetchRawRuleSets({
                library_id: this.currentLibraryId,
            });
        },
        async fetchRawRuleSets(params = {}) {
            return APIClient.circRule.circ_rules.getAll(
                {},
                { effective: false, ...params }
            );
        },
        async getConfigurationOptions() {
            const client = APIClient.circRule;
            const { permissions } = await client.config.getAll();
            this.userPermissions = permissions;
        },
        async getItemTypes() {
            const client = APIClient.item;
            let itemTypes = await client.item_types.getAll();
            itemTypes.sort(this.compareByProperty("description"));
            itemTypes.unshift({
                item_type_id: "*",
                description: $__("Default rule for all item types"),
            });
            this.itemTypes = itemTypes;
        },
        async getLibraries() {
            const client = APIClient.library;
            let libraries = [];
            libraries = await client.libraries.getAll();
            libraries.sort(this.compareByProperty("name"));
            libraries.unshift({
                library_id: "*",
                name: $__("Default rule for all libraries"),
            });
            this.libraries = libraries;
        },
        async getPatronCategories() {
            const client = APIClient.patron;
            let patronCategories = await client.categories.getAll();
            patronCategories.sort(this.compareByProperty("name"));
            patronCategories.unshift({
                patron_category_id: "*",
                name: $__("Default rule for all categories"),
            });
            this.patronCategories = patronCategories;
        },
        async getRawSelectedRuleSet(context, effective = false) {
            if (context.library_id === null) {
                context.library_id = "*";
            }
            const result = await this.fetchRawRuleSets({
                library_id: context.library_id,
                patron_category_id: context.patron_category_id,
                item_type_id: context.item_type_id,
                effective,
            });
            return result[0] ?? null;
        },
        async updateCircRuleSets(existingRuleSet, triggerNumber) {
            const circRuleSet = { context: existingRuleSet.context };
            circRuleSet[`overdue_${triggerNumber}_delay`] =
                existingRuleSet[`overdue_${triggerNumber}_delay`];
            circRuleSet[`overdue_${triggerNumber}_notice`] =
                existingRuleSet[`overdue_${triggerNumber}_notice`];
            circRuleSet[`overdue_${triggerNumber}_restrict`] =
                existingRuleSet[`overdue_${triggerNumber}_restrict`];
            circRuleSet[`overdue_${triggerNumber}_mtt`] =
                existingRuleSet[`overdue_${triggerNumber}_mtt`];
            const client = APIClient.circRule;
            await client.circ_rules.update(circRuleSet);
        },
        ...permissionsActions(store),
    };

    return {
        ...toRefs(store),
        ...actions,
        canManageAnyLibrary,
        getLibrariesBlockingTriggerDeletion,
    };
});
