/**
 * Koha Cypress Testing Data Insertion Utilities
 *
 * This module provides functions to create and manage test data for Cypress tests.
 * It handles creating complete bibliographic records, patrons, holds, checkouts,
 * and other Koha objects with proper relationships and dependencies.
 *
 * @module insertData
 */

const { buildSampleObject, buildSampleObjects } = require("./mockData.js");
const { query } = require("./db.js");

const { apiGet, apiPost } = require("./api-client.js");

/**
 * Creates a complete bibliographic record with associated items and libraries.
 *
 * @async
 * @function insertSampleBiblio
 * @param {Object} params - Configuration parameters
 * @param {number} params.item_count - Number of items to create for this biblio
 * @param {Object} [params.options] - Additional options
 * @param {boolean} [params.options.different_libraries] - If true, creates different libraries for each item
 * @param {string} params.baseUrl - Base URL for API calls
 * @param {string} params.authHeader - Authorization header for API calls
 * @returns {Promise<Object>} Created biblio with items, libraries, and item_type
 * @returns {Object} returns.biblio - The created bibliographic record
 * @returns {Array<Object>} returns.items - Array of created item records
 * @returns {Array<Object>} returns.libraries - Array of created library records
 * @returns {Object} returns.item_type - The created item type record
 * @example
 * // Create a biblio with 3 items using the same library
 * const result = await insertSampleBiblio({
 *   item_count: 3,
 *   baseUrl: 'http://localhost:8081',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 *
 * @example
 * // Create a biblio with 2 items using different libraries
 * const result = await insertSampleBiblio({
 *   item_count: 2,
 *   options: { different_libraries: true },
 *   baseUrl: 'http://localhost:8081',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 */
const insertSampleBiblio = async ({
    item_count,
    options,
    baseUrl,
    authHeader,
}) => {
    const generatedItemType = await buildSampleObject({ object: "item_type" });
    const item_type = await insertObject({
        type: "item_type",
        object: generatedItemType,
        baseUrl,
        authHeader,
    });

    let title = "Some boring read";
    let author = "Some boring author";
    let biblio = {
        leader: "     nam a22     7a 4500",
        fields: [
            { "005": "20250120101920.0" },
            {
                245: {
                    ind1: "",
                    ind2: "",
                    subfields: [{ a: title }],
                },
            },
            {
                100: {
                    ind1: "",
                    ind2: "",
                    subfields: [{ c: author }],
                },
            },
            {
                942: {
                    ind1: "",
                    ind2: "",
                    subfields: [{ c: item_type.item_type_id }],
                },
            },
        ],
    };
    let result = await apiPost({
        endpoint: "/api/v1/biblios",
        headers: {
            "Content-Type": "application/marc-in-json",
            "x-confirm-not-duplicate": 1,
        },
        body: biblio,
        baseUrl,
        authHeader,
    });
    const biblio_id = result.id;
    // We do not have a route to get a biblio as it is stored in DB
    // We might need to refine that in the future
    biblio = {
        biblio_id,
        title,
        author,
    };

    let items = buildSampleObjects({
        object: "item",
        count: item_count,
        values: {
            biblio_id,
            lost_status: 0,
            withdrawn: 0,
            damaged_status: 0,
            not_for_loan_status: 0,
            restricted_status: 0,
            new_status: null,
            issues: 0,
            checked_out_date: null,
            item_type_id: item_type.item_type_id,
        },
    });
    items = items.map(
        ({
            item_id,
            checkout,
            transfer,
            lost_date,
            withdrawn_date,
            damaged_date,
            course_item,
            _strings,
            biblio,
            bundle_host,
            item_group_item,
            recall,
            return_claim,
            return_claims,
            serial_item,
            first_hold,
            checkouts_count,
            renewals_count,
            holds_count,
            bundle_items_lost_count,
            analytics_count,
            effective_not_for_loan_status,
            effective_item_type_id,
            home_library,
            holding_library,
            bundle_items_not_lost_count,
            item_type,
            _status,
            effective_bookable,
            in_bundle,
            cover_image_ids,
            localuse,
            ...rest
        }) => rest
    );
    let createdItems = [];
    let libraries = [];
    let commonLibrary;
    if (!options || !options.different_libraries) {
        const generatedLibrary = await buildSampleObject({ object: "library" });
        commonLibrary = await insertObject({
            type: "library",
            object: generatedLibrary,
            baseUrl,
            authHeader,
        });
        libraries.push(commonLibrary);
    }
    for (const item of items) {
        if (options?.different_libraries) {
            const generatedLibrary = await buildSampleObject({
                object: "library",
            });
            const library = await insertObject({
                type: "library",
                object: generatedLibrary,
                baseUrl,
                authHeader,
            });
            libraries.push(library);
            item.home_library_id = library.library_id;
            item.holding_library_id = library.library_id;
        } else {
            item.home_library_id = commonLibrary.library_id;
            item.holding_library_id = commonLibrary.library_id;
        }

        await apiPost({
            endpoint: `/api/v1/biblios/${biblio_id}/items`,
            body: item,
            baseUrl,
            authHeader,
        }).then(i => createdItems.push(i));
    }
    return { biblio, items: createdItems, libraries, item_type };
};

/**
 * Creates a hold request for a bibliographic record or item.
 *
 * @async
 * @function insertSampleHold
 * @param {Object} params - Configuration parameters
 * @param {Object} [params.item] - Item to place hold on (optional if biblio provided)
 * @param {Object} [params.biblio] - Biblio to place hold on (optional if item provided)
 * @param {string} [params.library_id] - Library ID for pickup location (defaults to item's home library)
 * @param {string} params.baseUrl - Base URL for API calls
 * @param {string} params.authHeader - Authorization header for API calls
 * @returns {Promise<Object>} Created hold with associated patron and patron_category
 * @returns {Object} returns.hold - The created hold record
 * @returns {Object} returns.patron - The patron who placed the hold
 * @returns {Object} returns.patron_category - The patron's category
 * @throws {Error} When neither library_id nor item is provided
 * @example
 * // Create a hold on a specific item
 * const holdResult = await insertSampleHold({
 *   item: { item_id: 123, home_library_id: 'CPL' },
 *   baseUrl: 'http://localhost:8081',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 *
 * @example
 * // Create a biblio-level hold
 * const holdResult = await insertSampleHold({
 *   biblio: { biblio_id: 456 },
 *   library_id: 'CPL',
 *   baseUrl: 'http://localhost:8081',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 */
const insertSampleHold = async ({
    item,
    biblio,
    library_id,
    baseUrl,
    authHeader,
}) => {
    library_id ||= item?.home_library_id;

    if (!library_id) {
        throw new Error(
            "Could not generate sample hold without library_id or item"
        );
    }

    const { patron, patron_category } = await insertSamplePatron({
        library: { library_id },
        baseUrl,
        authHeader,
    });

    const generatedHold = buildSampleObject({
        object: "hold",
        values: {
            patron_id: patron.patron_id,
            biblio_id: item?.biblio_id || biblio.biblio_id,
            pickup_library_id: library_id,
            item_id: item?.item_id || null,
        },
    });
    const hold = await insertObject({
        type: "hold",
        object: generatedHold,
        baseUrl,
        authHeader,
    });
    return { hold, patron, patron_category };
};

/**
 * Creates a checkout record with associated biblio, item, and optional patron.
 *
 * @async
 * @function insertSampleCheckout
 * @param {Object} params - Configuration parameters
 * @param {Object} [params.patron] - Existing patron to check out to (creates new if not provided)
 * @param {string} params.baseUrl - Base URL for API calls
 * @param {string} params.authHeader - Authorization header for API calls
 * @returns {Promise<Object>} Created checkout with all associated records
 * @returns {Object} returns.biblio - The bibliographic record
 * @returns {Array<Object>} returns.items - Array of item records
 * @returns {Array<Object>} returns.libraries - Array of library records
 * @returns {Object} returns.item_type - The item type record
 * @returns {Object} returns.checkout - The checkout record
 * @returns {Object} [returns.patron] - The patron record (if generated)
 * @returns {Object} [returns.patron_category] - The patron category (if generated)
 * @example
 * // Create a checkout with a new patron
 * const checkoutResult = await insertSampleCheckout({
 *   baseUrl: 'http://localhost:8081',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 *
 * @example
 * // Create a checkout for an existing patron
 * const checkoutResult = await insertSampleCheckout({
 *   patron: { patron_id: 123 },
 *   baseUrl: 'http://localhost:8081',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 */
const insertSampleCheckout = async ({ patron, baseUrl, authHeader }) => {
    const { biblio, items, libraries, item_type } = await insertSampleBiblio({
        item_count: 1,
        baseUrl,
        authHeader,
    });

    let generatedPatron;
    let patronCategory;
    if (!patron) {
        generatedPatron = true;
        const patron_objects = await insertSamplePatron({
            library: { library_id: libraries[0].library_id },
            baseUrl,
            authHeader,
        });
        generatedCategory = patron_objects.category;
        patron = patron_objects.patron;
    }

    const generatedCheckout = buildSampleObject({
        object: "checkout",
        values: {
            patron_id: patron.patron_id,
            item_id: items[0].item_id,
        },
    });
    delete generatedCheckout.external_id;
    const checkout = await insertObject({
        type: "checkout",
        object: generatedCheckout,
        baseUrl,
        authHeader,
    });
    return {
        biblio,
        items,
        libraries,
        item_type,
        checkout,
        ...(generatedPatron
            ? {
                  patron,
                  patron_category: generatedCategory,
              }
            : {}),
    };
};

/**
 * Creates a patron record with associated library and category.
 *
 * @async
 * @function insertSamplePatron
 * @param {Object} params - Configuration parameters
 * @param {Object} [params.library] - Library to assign patron to (creates new if not provided)
 * @param {Object} [params.patron_category] - Patron category to assign (creates new if not provided)
 * @param {string} params.baseUrl - Base URL for API calls
 * @param {string} params.authHeader - Authorization header for API calls
 * @returns {Promise<Object>} Created patron with associated records
 * @returns {Object} returns.patron - The created patron record
 * @returns {Object} [returns.library] - The library record (if generated)
 * @returns {Object} [returns.patron_category] - The patron category record (if generated)
 * @example
 * // Create a patron with new library and category
 * const patronResult = await insertSamplePatron({
 *   baseUrl: 'http://localhost:8081',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 *
 * @example
 * // Create a patron for an existing library
 * const patronResult = await insertSamplePatron({
 *   library: { library_id: 'CPL' },
 *   baseUrl: 'http://localhost:8081',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 */
const insertSamplePatron = async ({
    library,
    patron_category,
    patronValues = {},
    baseUrl,
    authHeader,
}) => {
    let generatedLibrary;
    let generatedCategory;
    if (!library) {
        generatedLibrary = await buildSampleObject({ object: "library" });
        library = await insertLibrary({
            library: generatedLibrary,
            baseUrl,
            authHeader,
        });
    }
    if (!patron_category) {
        generatedCategory = await buildSampleObject({
            object: "patron_category",
        });
        query({
            sql: "INSERT INTO categories(categorycode, description) VALUES (?, ?)",
            values: [
                generatedCategory.patron_category_id,
                `description for ${generatedCategory.patron_category_id}`,
            ],
        });
        // FIXME We need /patron_categories/:patron_category_id
        await apiGet({
            endpoint: `/api/v1/patron_categories?q={"me.patron_category_id":"${generatedCategory.patron_category_id}"}`,
            baseUrl,
            authHeader,
        }).then(categories => (patron_category = categories[0]));
    }

    let generatedPatron = await buildSampleObject({
        object: "patron",
        values: {
            library_id: library.library_id,
            category_id: patron_category.patron_category_id,
            incorrect_address: null,
            patron_card_lost: null,
            ...patronValues,
        },
    });

    let {
        patron_id,
        _strings,
        anonymized,
        restricted,
        expired,
        extended_attributes,
        checkouts_count,
        overdues_count,
        account_balance,
        lang,
        login_attempts,
        sms_provider_id,
        self_renewal_available,
        ...patron
    } = generatedPatron;
    delete patron.library;

    patron = await apiPost({
        endpoint: `/api/v1/patrons`,
        body: patron,
        baseUrl,
        authHeader,
    });

    if (patronValues.hasOwnProperty("password")) {
        const password = patronValues.password;
        await apiPost({
            endpoint: `/api/v1/patrons/${patron.patron_id}/password`,
            body: { password, password_2: password },
            baseUrl,
            authHeader,
        });
    }

    return {
        patron,
        ...(generatedLibrary ? { library } : {}),
        ...(generatedCategory ? { patron_category } : {}),
    };
};

/**
 * Deletes test objects from the database in the correct order to respect foreign key constraints.
 *
 * @async
 * @function deleteSampleObjects
 * @param {Object|Array<Object>} allObjects - Object(s) to delete, can be single object or array
 * @returns {Promise<boolean>} True if deletion was successful
 * @description This function handles cleanup of test data by:
 * - Accepting single objects or arrays of objects
 * - Grouping objects by type (holds, checkouts, patrons, items, etc.)
 * - Deleting in dependency order to avoid foreign key violations
 * - Supporting all major Koha object types
 * @example
 * // Delete a single test result
 * await deleteSampleObjects(checkoutResult);
 *
 * @example
 * // Delete multiple test results
 * await deleteSampleObjects([biblioResult, holdResult, checkoutResult]);
 *
 * @example
 * // Delete after creating test data
 * const biblio = await insertSampleBiblio({ item_count: 2, baseUrl, authHeader });
 * const hold = await insertSampleHold({ item: biblio.items[0], baseUrl, authHeader });
 * // ... run tests ...
 * await deleteSampleObjects([biblio, hold]);
 */
const deleteSampleObjects = async allObjects => {
    if (!Array.isArray(allObjects)) {
        allObjects = [allObjects];
    }

    const objectsMap = {
        hold: {
            plural: "holds",
            table: "reserves",
            whereColumn: "reserve_id",
            idField: "hold_id",
        },
        checkout: {
            plural: "checkouts",
            table: "issues",
            whereColumn: "issue_id",
            idField: "checkout_id",
        },
        old_checkout: {
            plural: "old_checkouts",
            table: "old_issues",
            whereColumn: "issue_id",
            idField: "checkout_id",
        },
        basket: {
            plural: "baskets",
            table: "aqbasket",
            whereColumn: "basketno",
            idField: "basket_id",
        },
        vendor: {
            plural: "vendors",
            table: "aqbooksellers",
            whereColumn: "id",
        },
        patron: {
            plural: "patrons",
            table: "borrowers",
            whereColumn: "borrowernumber",
            idField: "patron_id",
        },
        item: {
            plural: "items",
            table: "items",
            whereColumn: "itemnumber",
            idField: "item_id",
        },
        biblio: {
            plural: "biblios",
            table: "biblio",
            whereColumn: "biblionumber",
            idField: "biblio_id",
        },
        library: {
            plural: "libraries",
            table: "branches",
            whereColumn: "branchcode",
            idField: "library_id",
        },
        item_type: {
            plural: "item_types",
            table: "itemtypes",
            whereColumn: "itemtype",
            idField: "item_type_id",
        },
        erm_agreement: {
            plural: "erm_agreements",
            table: "erm_agreements",
            whereColumn: "agreement_id",
        },
        erm_eholdings_title: {
            plural: "erm_eholdings_titles",
            table: "erm_eholdings_titles",
            whereColumn: "title_id",
        },
        category: {
            plural: "categories",
            table: "categories",
            whereColumn: "categorycode",
            idField: "patron_category_id",
        },
    };
    // Merge by type
    const mergedObjects = {};
    for (const objects of allObjects) {
        for (const [type, value] of Object.entries(objects)) {
            let plural = objectsMap[type]?.plural || type;
            if (!mergedObjects[plural]) {
                mergedObjects[plural] = [];
            }

            if (Array.isArray(value)) {
                mergedObjects[plural].push(...value);
            } else {
                mergedObjects[plural].push(value);
            }
        }
    }

    const deletionOrder = [
        "holds",
        "checkouts",
        "old_checkouts",
        "baskets",
        "vendors",
        "patrons",
        "items",
        "biblios",
        "libraries",
        "item_types",
        "erm_agreements",
        "erm_eholdings_titles",
        "categories",
    ];
    const matchTypeToObjectMap = type => {
        const matchingKey = Object.keys(objectsMap).find(
            key => objectsMap[key].plural === type
        );
        return objectsMap[matchingKey];
    };

    for (const type of deletionOrder) {
        if (!mergedObjects[type] || mergedObjects[type].length === 0) {
            continue;
        }

        const objectMap = matchTypeToObjectMap(type);
        if (!objectMap) {
            throw Error(`Not implemented yet: cannot delete object '${type}'`);
        }
        const objects = mergedObjects[type];
        let ids = objects.map(
            i =>
                i[
                    objectMap.hasOwnProperty("idField")
                        ? objectMap.idField
                        : objectMap.whereColumn
                ]
        );
        await query({
            sql: `DELETE FROM ${objectMap.table} WHERE ${objectMap.whereColumn} IN (${ids.map(() => "?").join(",")})`,
            values: ids,
        });
    }
    return true;
};

/**
 * Creates a library record via API, filtering out unsupported fields.
 *
 * @async
 * @function insertLibrary
 * @param {Object} params - Configuration parameters
 * @param {Object} params.library - Library object to insert
 * @param {string} params.baseUrl - Base URL for API calls
 * @param {string} params.authHeader - Authorization header for API calls
 * @returns {Promise<Object>} Created library record
 * @private
 * @description This is a helper function that removes fields not supported by the API
 * before creating the library record.
 */
const insertLibrary = async ({ library, baseUrl, authHeader }) => {
    const {
        pickup_items,
        smtp_server,
        cash_registers,
        desks,
        library_hours,
        needs_override,
        ...new_library
    } = library;
    return apiPost({
        endpoint: "/api/v1/libraries",
        body: new_library,
        baseUrl,
        authHeader,
    });
};

/**
 * Generic function to insert various types of Koha objects.
 *
 * @async
 * @function insertObject
 * @param {Object} params - Configuration parameters
 * @param {string} params.type - Type of object to insert ('library', 'item_type', 'hold', 'checkout', 'vendor', 'basket')
 * @param {Object} params.object - Object data to insert
 * @param {string} params.baseUrl - Base URL for API calls
 * @param {string} params.authHeader - Authorization header for API calls
 * @returns {Promise<Object|boolean>} Created object or true if successful
 * @throws {Error} When object type is not supported
 * @private
 * @description This is a generic helper function that handles the specifics of creating
 * different types of Koha objects. Each object type may require different field filtering,
 * API endpoints, or database operations.
 *
 * Supported object types:
 * - library: Creates library via API
 * - item_type: Creates item type via database query
 * - hold: Creates hold via API
 * - checkout: Creates checkout via API with confirmation token support
 * - vendor: Creates vendor via API
 * - basket: Creates basket via database query
 */
const insertObject = async ({ type, object, baseUrl, authHeader }) => {
    if (type == "library") {
        const keysToKeep = ["library_id", "name"];
        const library = Object.fromEntries(
            Object.entries(object).filter(([key]) => keysToKeep.includes(key))
        );
        return apiPost({
            endpoint: "/api/v1/libraries",
            body: library,
            baseUrl,
            authHeader,
        });
    } else if (type == "item_type") {
        const keysToKeep = ["item_type_id", "description"];
        const item_type = Object.fromEntries(
            Object.entries(object).filter(([key]) => keysToKeep.includes(key))
        );
        return query({
            sql: "INSERT INTO itemtypes(itemtype, description) VALUES (?, ?)",
            values: [item_type.item_type_id, item_type.description],
        })
            .then(result => {
                // FIXME We need /item_types/:item_type_id
                return apiGet({
                    endpoint: `/api/v1/item_types?q={"item_type_id":"${item_type.item_type_id}"}`,
                    baseUrl,
                    authHeader,
                });
            })
            .then(item_types => item_types[0]);
    } else if (type == "hold") {
        const {
            hold_id,
            deleted_biblio_id,
            item_group_id,
            desk_id,
            cancellation_date,
            cancellation_reason,
            notes,
            priority,
            status,
            timestamp,
            waiting_date,
            expiration_date,
            lowest_priority,
            suspended,
            suspended_until,
            non_priority,
            item_type_id,
            _strings,
            hold_group_id,
            item_level,
            item_level_holds_count,
            item_group,
            cancellation_requested,
            biblio,
            deleted_biblio,
            item,
            pickup_library,
            hold_date,
            patron,
            iso18626_request,
            ...hold
        } = object;

        return apiPost({
            endpoint: `/api/v1/holds`,
            body: hold,
            baseUrl,
            authHeader,
        });
    } else if (type == "checkout") {
        const { issuer, patron, booking, ...checkout } = object;

        let endpoint = "/api/v1/checkouts";
        // Force the checkout - we might need a parameter to control this behaviour later
        await apiGet({
            endpoint: `/api/v1/checkouts/availability?item_id=${object.item_id}&patron_id=${object.patron_id}`,
            baseUrl,
            authHeader,
        }).then(result => {
            if (result.confirmation_token) {
                endpoint += `?confirmation=${result.confirmation_token}`;
            }
        });

        return apiPost({
            endpoint,
            body: checkout,
            baseUrl,
            authHeader,
        });
    } else if (type == "vendor") {
        const {
            id,
            baskets_count,
            invoices_count,
            subscriptions_count,
            external_id,
            aliases,
            baskets,
            contacts,
            contracts,
            interfaces,
            invoices,
            list_currency,
            invoice_currency,
            extended_attributes,
            _strings,
            ...vendor
        } = object;

        let endpoint = "/api/v1/acquisitions/vendors";

        return apiPost({
            endpoint,
            body: vendor,
            baseUrl,
            authHeader,
        });
    } else if (type == "basket") {
        const keysToKeep = ["name", "vendor_id", "close_date"];
        const basket = Object.fromEntries(
            Object.entries(object).filter(([key]) => keysToKeep.includes(key))
        );
        return query({
            sql: "INSERT INTO aqbasket(basketname, booksellerid, closedate) VALUES (?, ?, ?)",
            values: [basket.name, basket.vendor_id, basket.close_date],
        })
            .then(result => {
                const basket_id = result.insertId;
                // FIXME We need /acquisitions/baskets/:basket_id
                return apiGet({
                    endpoint: `/api/v1/acquisitions/baskets?q={"basket_id":"${basket_id}"}`,
                    baseUrl,
                    authHeader,
                });
            })
            .then(baskets => baskets[0]);
    } else if (type == "invoice") {
        const keysToKeep = [
            "invoice_number",
            "vendor_id",
            "shipping_date",
            "invoice_date",
        ];
        const invoice = Object.fromEntries(
            Object.entries(object).filter(([key]) => keysToKeep.includes(key))
        );
        return query({
            sql: "INSERT INTO aqinvoices(invoicenumber, booksellerid, shipmentdate, billingdate) VALUES (?, ?, ?, ?)",
            values: [
                invoice.invoice_number,
                invoice.vendor_id,
                invoice.shipping_date,
                invoice.invoice_date,
            ],
        })
            .then(result => {
                const invoice_id = result.insertId;
                // FIXME We need /acquisitions/invoices/:invoice_id
                return apiGet({
                    endpoint: `/api/v1/acquisitions/vendors/${invoice.vendor_id}`,
                    headers: { "x-koha-embed": "invoices" },
                    baseUrl,
                    authHeader,
                });
            })
            .then(vendor =>
                vendor.invoices.find(
                    i => i.invoice_number == invoice.invoice_number
                )
            );
    } else if (type === "erm_agreement") {
        const {
            agreement_id,
            _strings,
            periods,
            user_roles,
            agreement_relationships,
            agreement_licenses,
            documents,
            extended_attributes,
            vendor,
            ...erm_agreement
        } = object;
        if (typeof periods[0] !== "string") {
            erm_agreement.periods = periods;
        }
        return apiPost({
            endpoint: "/api/v1/erm/agreements",
            body: erm_agreement,
            baseUrl,
            authHeader,
        });
    } else if (type === "erm_eholdings_title") {
        const {
            title_id,
            biblio_id,
            create_linked_biblio,
            is_selected,
            resources,
            ...erm_eholdings_title
        } = object;
        return apiPost({
            endpoint: "/api/v1/erm/eholdings/local/titles",
            body: erm_eholdings_title,
            baseUrl,
            authHeader,
        });
    } else if (type === "category") {
        return apiPost({
            endpoint: "/api/v1/patron_categories",
            body: object,
            baseUrl,
            authHeader,
        });
    } else {
        throw Error(`Unsupported object type '${type}' to insert`);
    }

    return true;
};

const insertSampleEdifactMessages = async () => {
    // First, create a test vendor
    const vendorResult = await query({
        sql: `INSERT INTO aqbooksellers (name, address1, address2, address3, phone, fax, url, active, listprice, invoiceprice, gstreg, listincgst, invoiceincgst, tax_rate, discount, notes)
              VALUES ('Test EDI Vendor', '123 Test Street', 'Test City', 'Test Country', '555-1234', '555-5678', 'http://testvendor.com', 1, 'USD', 'USD', 0, 1, 1, 0.10, 0.05, 'Test vendor for EDIFACT testing')`,
        values: [],
    });
    const vendor_id = vendorResult.insertId;

    // Create a file transport for the EDI account
    const fileTransportResult = await query({
        sql: `INSERT INTO file_transports (name, host, port, transport, passive, user_name, password, auth_mode, download_directory, upload_directory)
              VALUES ('Test EDI Transport', 'test.edi.host', 22, 'sftp', 1, 'testuser', 'testpass', 'password', '/download', '/upload')`,
        values: [],
    });
    const file_transport_id = fileTransportResult.insertId;

    // Create a test EDI account for the vendor
    const ediAccountResult = await query({
        sql: `INSERT INTO vendor_edi_accounts (description, vendor_id, san, standard, quotes_enabled, invoices_enabled, orders_enabled, responses_enabled, auto_orders, plugin, file_transport_id)
              VALUES ('Test EDI Account', ?, 'TEST123', 'EUR', 1, 1, 1, 1, 0, '', ?)`,
        values: [vendor_id, file_transport_id],
    });
    const edi_acct = ediAccountResult.insertId;

    // Insert sample EDIFACT messages for testing
    const messages = [
        {
            message_type: "ORDERS",
            transfer_date: "2025-01-20",
            vendor_id: vendor_id,
            edi_acct: edi_acct,
            status: "new",
            basketno: null,
            filename: "test_order_001.edi",
            raw_msg: `UNA:+.? 'UNB+UNOC:3+TEST_SUPPLIER:14+TEST_LIBRARY:14+20250121:1234+1++1++1'UNH+1+ORDERS:D:96A:UN:EAN008'BGM+220+BASKET001+9'DTM+137:20250721:102'RFF+ON:LibraryBasket001'NAD+BY+1234567890123::91++Test Library System+123 Library Street+Booktown+12345+US'LIN+1++9781234567890:IB'PIA+5+BOOK001:SA'IMD+L+009+:::Test Author'IMD+L+050+:::Introduction to Library Science'QTY+21:3'PRI+AAE:29.95:CA'RFF+LI:ORDER001'UNT+12+1'UNZ+1+1'`,
        },
        {
            message_type: "INVOIC",
            transfer_date: "2025-01-19",
            vendor_id: vendor_id,
            edi_acct: edi_acct,
            status: "new",
            basketno: null,
            filename: "test_invoice_001.edi",
            raw_msg: `UNA:+.? 'UNB+UNOC:3+FOCUS_SUPPLIER:14+FOCUS_LIBRARY:14+20250721:1600+3++1++1'UNH+2+INVOIC:D:96A:UN:EAN008'BGM+380+67890+9'DTM+137:20250720:102'RFF+IV:TEST_INVOICE_001'RFF+ON:FocusBasket002'NAD+SU+9876543210987::91++Test Book Supplier+456 Publisher Ave+Bookville+54321+US'LIN+1++9789876543210:IB'IMD+L+009+:::Sample Author'IMD+L+050+:::Advanced Library Management'QTY+47:2'PRI+AAA:45.00:CA'MOA+203:90.00:USD'UNT+13+2'UNZ+1+3'`,
        },
        {
            message_type: "ORDERS",
            transfer_date: "2025-01-18",
            vendor_id: vendor_id,
            edi_acct: edi_acct,
            status: "new",
            basketno: null,
            filename: "test_search_content.edi",
            raw_msg: `UNA:+.? 'UNB+UNOC:3+SEARCH_SUPPLIER:14+SEARCH_LIBRARY:14+20250721:1500+2++1++1'UNH+1+ORDERS:D:96A:UN:EAN008'BGM+220+SEARCH_BASKET+9'IMD+L+009+:::JavaScript Programming Guide'IMD+L+050+:::Learn modern JavaScript programming techniques'PIA+5+JS001:SA+9781234567890:IB'FTX+LIN+++Essential reading for web developers learning JavaScript'UNT+6+1'UNZ+1+2'`,
        },
    ];

    const inserted_ids = [];
    for (const message of messages) {
        const result = await query({
            sql: `INSERT INTO edifact_messages (message_type, transfer_date, vendor_id, edi_acct, status, basketno, filename, raw_msg) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            values: [
                message.message_type,
                message.transfer_date,
                message.vendor_id,
                message.edi_acct,
                message.status,
                message.basketno,
                message.filename,
                message.raw_msg,
            ],
        });
        inserted_ids.push(result.insertId);
    }

    return {
        message_ids: inserted_ids,
        vendor_id: vendor_id,
        edi_acct: edi_acct,
        file_transport_id: file_transport_id,
    };
};

const deleteSampleEdifactMessages = async test_data => {
    if (!test_data) {
        // Clean up all test messages and related data
        await query({
            sql: "DELETE FROM edifact_messages WHERE filename LIKE 'test_%'",
        });
        await query({
            sql: "DELETE FROM vendor_edi_accounts WHERE description = 'Test EDI Account'",
        });
        await query({
            sql: "DELETE FROM file_transports WHERE name = 'Test EDI Transport'",
        });
        await query({
            sql: "DELETE FROM aqbooksellers WHERE name = 'Test EDI Vendor'",
        });
        return { success: true };
    }

    if (test_data.message_ids) {
        // Delete specific messages
        await query({
            sql: `DELETE FROM edifact_messages WHERE id IN (${test_data.message_ids.map(() => "?").join(",")})`,
            values: test_data.message_ids,
        });
    }

    if (test_data.edi_acct) {
        // Delete the test EDI account
        await query({
            sql: "DELETE FROM vendor_edi_accounts WHERE id = ?",
            values: [test_data.edi_acct],
        });
    }

    if (test_data.file_transport_id) {
        // Delete the test file transport
        await query({
            sql: "DELETE FROM file_transports WHERE file_transport_id = ?",
            values: [test_data.file_transport_id],
        });
    }

    if (test_data.vendor_id) {
        // Delete the test vendor
        await query({
            sql: "DELETE FROM aqbooksellers WHERE id = ?",
            values: [test_data.vendor_id],
        });
    }

    return { success: true };
};

module.exports = {
    insertSampleBiblio,
    insertSampleHold,
    insertSampleCheckout,
    insertSamplePatron,
    insertObject,
    deleteSampleObjects,
    insertSampleEdifactMessages,
    deleteSampleEdifactMessages,
};
