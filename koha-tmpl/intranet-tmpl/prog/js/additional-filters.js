/**
 * Additional filters library for Koha DataTables
 *
 * Provides boolean data attribute-based filter controls that integrate
 * seamlessly with kohaTable's additional_filters parameter.
 *
 * Template Usage:
 * [% INCLUDE 'additional-filters.inc'
 *     filters = [
 *         { id = 'filter-expired', label_show = t('Include expired'), label_hide = t('Exclude expired') },
 *         { id = 'filter-cancelled', label_show = t('Include cancelled'), label_hide = t('Exclude cancelled') },
 *     ]
 *     filter_class = 'bookings'  # Optional, defaults to 'filters'
 * %]
 *
 * JavaScript Usage:
 * @example
 * const additional_filters = AdditionalFilters.init(['filter-expired', 'filter-cancelled'])
 *   .onChange((filters, { anyFiltersApplied }) => {
 *     table.column('status').visible(anyFiltersApplied);
 *   })
 *   .build({
 *     status: ({ filters, isNotApplied }) =>
 *       isNotApplied(filters['filter-expired']) ? { '!=': 'expired' } : undefined
 *   });
 */

window.AdditionalFilters = {
    /**
     * Initialize filter controls and attach event listeners
     * @param {string[]|Object} filterIds - Array of full element IDs or options object
     * @param {Function} [onFilterChange] - Callback when filters change
     * @param {Object} [options] - Configuration options
     * @param {string} [options.event='click'] - Event type to listen for
     * @param {string} [options.attribute='filtered'] - Data attribute name
     * @param {string} [options.closest='a'] - Element selector for event delegation
     * @param {boolean} [options.strict=true] - Log warnings for missing elements
     * @returns {AdditionalFiltersAPI} Chainable API object
     */
    init: function (filterIds, onFilterChange, options = {}) {
        if (typeof filterIds === "object" && !Array.isArray(filterIds)) {
            options = filterIds;
            filterIds = options.filterIds || [];
            onFilterChange = options.onFilterChange || onFilterChange;
        }

        const config = {
            event: options.event || "click",
            attribute: options.attribute || "filtered",
            closest: options.closest || "a",
            ...options,
        };

        const filters = {};

        const isApplied = filter =>
            filter?.hasAttribute(`data-${config.attribute}`);
        const isNotApplied = filter => !isApplied(filter);

        function attachFilter(elementId) {
            const element = document.getElementById(elementId);
            if (element) {
                filters[elementId] = element;
                element.addEventListener(config.event, handleFilter);
            } else if (config.strict !== false) {
                console.debug(
                    `AdditionalFilters: Element not found with ID '${elementId}'`
                );
            }
        }

        function handleFilter(e) {
            const target = e.target;
            const filter = target.closest(config.closest);
            if (!filter) return;

            if (isApplied(filter)) {
                filter.removeAttribute(`data-${config.attribute}`);
            } else {
                filter.setAttribute(`data-${config.attribute}`, "");
            }

            if (changeCallback) {
                changeCallback(filters, {
                    anyFiltersApplied: Object.values(filters).some(isApplied),
                    anyFiltersNotApplied:
                        Object.values(filters).some(isNotApplied),
                    isApplied,
                    isNotApplied,
                });
            }
        }

        filterIds.forEach(attachFilter);

        let filterDefinitions = {};
        let changeCallback = onFilterChange;

        const api = {
            filters: filters,
            isApplied: isApplied,
            isNotApplied: isNotApplied,
            config: config,

            /**
             * Re-scan DOM for missing filter elements
             * @returns {AdditionalFiltersAPI} Chainable API
             */
            refresh: function () {
                filterIds.forEach(filterId => {
                    if (!filters[filterId]) {
                        attachFilter(filterId);
                    }
                });
                return api;
            },

            /**
             * Set or update the filter change callback
             * @param {Function} callback - Called when filters change
             * @param {Object} callback.filters - Filter element map
             * @param {Object} callback.helpers - Helper functions and state
             * @param {boolean} callback.helpers.anyFiltersApplied - True if any filter is applied
             * @param {boolean} callback.helpers.anyFiltersNotApplied - True if any filter is not applied
             * @param {Function} callback.helpers.isApplied - Check if filter is applied
             * @param {Function} callback.helpers.isNotApplied - Check if filter is not applied
             * @returns {AdditionalFiltersAPI} Chainable API
             */
            onChange: function (callback) {
                changeCallback = callback;
                return api;
            },

            /**
             * Clean up event listeners and references
             * @returns {void}
             */
            destroy: function () {
                Object.values(filters).forEach(filter => {
                    if (filter) {
                        filter.removeEventListener(config.event, handleFilter);
                    }
                });
                Object.keys(filters).forEach(key => delete filters[key]);
                changeCallback = null;
            },

            /**
             * Add filter definitions for API parameters
             * @param {Object} definitions - Map of API parameters to generator functions
             * @returns {AdditionalFiltersAPI} Chainable API
             */
            withFilters: function (definitions) {
                filterDefinitions = { ...filterDefinitions, ...definitions };
                return api;
            },

            /**
             * Generate additional_filters object for kohaTable
             * @param {Object} [definitions] - Filter definitions to use
             * @returns {Object} additional_filters object for kohaTable
             */
            getAdditionalFilters: function (definitions) {
                const filtersToUse = definitions || filterDefinitions;
                const additionalFilters = {};

                for (const [apiParam, generator] of Object.entries(
                    filtersToUse
                )) {
                    additionalFilters[apiParam] = () => {
                        return generator({
                            filters,
                            isApplied,
                            isNotApplied,
                        });
                    };
                }

                return additionalFilters;
            },

            /**
             * Set filter definitions and return additional_filters object
             * @param {Object} [definitions] - Filter definitions
             * @returns {Object} additional_filters object for kohaTable
             */
            build: function (definitions) {
                if (definitions) {
                    filterDefinitions = {
                        ...filterDefinitions,
                        ...definitions,
                    };
                }
                return this.getAdditionalFilters();
            },
        };

        return api;
    },

    /**
     * Initialize filters when DOM is ready
     * @param {string[]|Object} filterIds - Array of full element IDs or options object
     * @param {Function} [onFilterChange] - Callback when filters change
     * @param {Object} [options] - Configuration options
     * @param {boolean} [options.allowEmpty] - Resolve even if no elements found
     * @returns {Promise<AdditionalFiltersAPI>} Promise resolving to API object
     */
    ready: function (filterIds, onFilterChange, options = {}) {
        return new Promise(resolve => {
            const tryInit = () => {
                const helper = this.init(filterIds, onFilterChange, options);
                if (
                    Object.keys(helper.filters).length > 0 ||
                    options.allowEmpty
                ) {
                    resolve(helper);
                } else {
                    setTimeout(tryInit, 50);
                }
            };

            if (document.readyState === "loading") {
                document.addEventListener("DOMContentLoaded", tryInit);
            } else {
                tryInit();
            }
        });
    },
};
