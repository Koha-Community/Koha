const { buildSampleObject, buildSampleObjects } = require("./mockData.js");
const { query } = require("./db.js");

const { APIClient } = require("./dist/api-client.cjs.js");

const insertSampleBiblio = async (item_count, baseUrl, authHeader) => {
    let client = APIClient.default;
    let generated_objects = {};
    const objects = [{ object: "library" }, { object: "item_type" }];
    for (const { object } of objects) {
        const attributes = await buildSampleObject({ object });
        generated_objects[object] = attributes;
    }

    const library = await insertObject(
        "library",
        generated_objects["library"],
        baseUrl,
        authHeader
    );
    const item_type = await insertObject(
        "item_type",
        generated_objects["item_type"],
        baseUrl,
        authHeader
    );

    let biblio = {
        leader: "     nam a22     7a 4500",
        fields: [
            { "005": "20250120101920.0" },
            {
                245: {
                    ind1: "",
                    ind2: "",
                    subfields: [{ a: "Some boring read" }],
                },
            },
            {
                100: {
                    ind1: "",
                    ind2: "",
                    subfields: [{ c: "Some boring author" }],
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
    let result = await client.koha.post({
        endpoint: `${baseUrl}/api/v1/biblios`,
        headers: {
            "Content-Type": "application/marc-in-json",
            "x-confirm-not-duplicate": 1,
            Authorization: authHeader,
        },
        body: biblio,
    });
    const biblio_id = result.id;
    // We do not have a route to get a biblio as it is stored in DB
    // We might need to refine that in the future
    biblio = {
        biblio_id,
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
            item_type_id: item_type.item_type_id,
            home_library_id: library.library_id,
            holding_library_id: library.library_id,
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
    for (const item of items) {
        await client.koha
            .post({
                endpoint: `${baseUrl}/api/v1/biblios/${biblio_id}/items`,
                body: item,
                headers: {
                    "Content-Type": "application/json",
                    Authorization: authHeader,
                },
            })
            .then(i => createdItems.push(i));
    }
    return { biblio, items: createdItems, library, item_type };
};

const deleteSampleObjects = async objects => {
    const deletionOrder = ["items", "biblio", "library", "item_type"];
    for (const type of deletionOrder) {
        if (!objects.hasOwnProperty(type)) {
            continue;
        }
        if (Array.isArray(objects[type]) && objects[type].length == 0) {
            // Empty array
            continue;
        }
        switch (type) {
            case "biblio":
                await query({
                    sql: "DELETE FROM biblio WHERE biblionumber=?",
                    values: [objects[type].biblio_id],
                });
                break;
            case "items":
                let item_ids = objects[type].map(i => i.item_id);
                await query({
                    sql: `DELETE FROM items WHERE itemnumber IN (${item_ids.map(() => "?").join(",")})`,
                    values: item_ids,
                });
                break;
            case "item":
                await query({
                    sql: "DELETE FROM items WHERE itemnumber = ?",
                    values: [objects[type].item_id],
                });
                break;
            case "library":
                await query({
                    sql: "DELETE FROM branches WHERE branchcode = ?",
                    values: [objects[type].library_id],
                });
                break;
            case "item_type":
                await query({
                    sql: "DELETE FROM itemtypes WHERE itemtype = ?",
                    values: [objects[type].item_type_id],
                });
                break;
        }
    }
    return true;
};

const insertLibrary = async (library, baseUrl, authHeader) => {
    const {
        pickup_items,
        smtp_server,
        cash_registers,
        desks,
        library_hours,
        needs_override,
        ...new_library
    } = library;
    let client = APIClient.default;
    return client.koha.post({
        endpoint: `${baseUrl}/api/v1/libraries`,
        body: new_library,
        headers: {
            "Content-Type": "application/json",
            Authorization: authHeader,
        },
    });
};

const insertObject = async (type, object, baseUrl, authHeader) => {
    let client = APIClient.default;
    if (type == "patron") {
        await query({
            sql: "SELECT COUNT(*) AS count FROM branches WHERE branchcode = ?",
            values: [object.library_id],
        }).then(result => {
            if (!result[0].count) {
                insertLibrary(object.library, baseUrl, authHeader);
            }
        });
        await query({
            sql: "SELECT COUNT(*) AS count FROM categories WHERE categorycode= ?",
            values: [object.category_id],
        }).then(result => {
            if (!result[0].count) {
                query({
                    sql: "INSERT INTO categories(categorycode, description) VALUES (?, ?)",
                    values: [
                        object.category_id,
                        `description for ${object.category_id}`,
                    ],
                });
            }
        });
        const {
            _strings,
            anonymized,
            restricted,
            expired,
            extended_attributes,
            library,
            checkouts_count,
            overdues_count,
            account_balance,
            lang,
            login_attempts,
            sms_provider_id,
            ...patron
        } = object;

        return client.koha.post({
            endpoint: `${baseUrl}/api/v1/patrons`,
            body: patron,
            headers: {
                "Content-Type": "application/json",
                Authorization: authHeader,
            },
        });
    } else if (type == "library") {
        const keysToKeep = ["library_id", "name"];
        const library = Object.fromEntries(
            Object.entries(object).filter(([key]) => keysToKeep.includes(key))
        );
        return client.koha.post({
            endpoint: `${baseUrl}/api/v1/libraries`,
            headers: {
                "Content-Type": "application/json",
                Authorization: authHeader,
            },
            body: library,
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
                return client.koha.get({
                    endpoint: `${baseUrl}/api/v1/item_types?q={"item_type_id":"${item_type.item_type_id}"}`,
                    headers: {
                        "Content-Type": "application/json",
                        Authorization: authHeader,
                    },
                });
            })
            .then(item_types => item_types[0]);
    } else {
        return false;
    }

    return true;
};

module.exports = {
    insertSampleBiblio,
    insertObject,
    deleteSampleObjects,
};
