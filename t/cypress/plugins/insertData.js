const { buildSampleObject, buildSampleObjects } = require("./mockData.js");
const { query } = require("./db.js");

const { apiGet, apiPost } = require("./api-client.js");

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

const insertSamplePatron = async ({
    library,
    patron_category,
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
        ...patron
    } = generatedPatron;
    delete patron.library;

    patron = await apiPost({
        endpoint: `/api/v1/patrons`,
        body: patron,
        baseUrl,
        authHeader,
    });

    return {
        patron,
        ...(generatedLibrary ? { library } : {}),
        ...(generatedCategory ? { patron_category } : {}),
    };
};

const deleteSampleObjects = async allObjects => {
    if (!Array.isArray(allObjects)) {
        allObjects = [allObjects];
    }

    const pluralMap = {
        hold: "holds",
        checkout: "checkouts",
        patron: "patrons",
        item: "items",
        biblio: "biblios",
        library: "libraries",
        item_type: "item_types",
    };
    // Merge by type
    const mergedObjects = {};
    for (const objects of allObjects) {
        for (const [type, value] of Object.entries(objects)) {
            let plural = pluralMap?.[type] || type;
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
        "patrons",
        "items",
        "biblios",
        "libraries",
        "item_types",
    ];

    for (const type of deletionOrder) {
        if (!mergedObjects[type] || mergedObjects[type].length === 0) {
            continue;
        }

        const objects = mergedObjects[type];
        let ids = [];
        switch (type) {
            case "biblios":
                ids = objects.map(i => i.biblio_id);
                await query({
                    sql: `DELETE FROM biblio WHERE biblionumber IN (${ids.map(() => "?").join(",")})`,
                    values: ids,
                });
                break;
            case "items":
                ids = objects.map(i => i.item_id);
                await query({
                    sql: `DELETE FROM items WHERE itemnumber IN (${ids.map(() => "?").join(",")})`,
                    values: ids,
                });
                break;
            case "libraries":
                ids = objects.map(i => i.library_id);
                await query({
                    sql: `DELETE FROM branches WHERE branchcode IN (${ids.map(() => "?").join(",")})`,
                    values: ids,
                });
                break;
            case "holds":
                ids = objects.map(i => i.hold_id);
                await query({
                    sql: `DELETE FROM reserves WHERE reserve_id IN (${ids.map(() => "?").join(",")})`,
                    values: ids,
                });
                break;
            case "checkouts":
                ids = objects.map(i => i.checkout_id);
                await query({
                    sql: `DELETE FROM issues WHERE issue_id IN (${ids.map(() => "?").join(",")})`,
                    values: ids,
                });
                break;
            case "item_types":
                ids = objects.map(i => i.item_type_id);
                await query({
                    sql: `DELETE FROM itemtypes WHERE itemtype IN (${ids.map(() => "?").join(",")})`,
                    values: ids,
                });
                break;
            case "patrons":
                ids = objects.map(i => i.patron_id);
                await query({
                    sql: `DELETE FROM borrowers WHERE borrowernumber IN (${ids.map(() => "?").join(",")})`,
                    values: ids,
                });
                break;
            default:
                throw Error(
                    `Not implemented yet: cannot deleted object '${type}'`
                );
        }
    }
    return true;
};

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
            item_type,
            item_level,
            cancellation_requested,
            biblio,
            deleted_biblio,
            item,
            pickup_library,
            hold_date,
            ...hold
        } = object;

        return apiPost({
            endpoint: `/api/v1/holds`,
            body: hold,
            baseUrl,
            authHeader,
        });
    } else if (type == "checkout") {
        const { issuer, patron, ...checkout } = object;

        return apiPost({
            endpoint: "/api/v1/checkouts",
            body: checkout,
            baseUrl,
            authHeader,
        });
    } else {
        throw Error(`Unsupported object type '${type}' to insert`);
    }

    return true;
};

module.exports = {
    insertSampleBiblio,
    insertSampleHold,
    insertSampleCheckout,
    insertSamplePatron,
    insertObject,
    deleteSampleObjects,
};
