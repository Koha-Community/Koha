const RESTdefaultPageSize = "20"; // FIXME Mock this
const baseTotalCount = "42";

describe("catalogue/detail/holdings_table with items", () => {
    const table_id = "holdings_table";
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.window().then(win => {
            win.localStorage.clear();
        });

        // FIXME All the following code should not be reused as it
        // It must be moved to a Cypress command or task "buildSampleBiblio" or even "insertSampleBiblio"
        let generated_objects = {};
        const objects = [{ object: "library" }, { object: "item_type" }];
        cy.wrap(Promise.resolve())
            .then(() => {
                return objects.reduce((chain, { object }) => {
                    return chain.then(() => {
                        return cy
                            .task("buildSampleObject", { object })
                            .then(attributes => {
                                generated_objects[object] = attributes;
                            });
                    });
                }, Promise.resolve());
            })
            .then(() => {
                const library = generated_objects["library"];
                const item_type = generated_objects["item_type"];
                const queries = [
                    {
                        query: "INSERT INTO branches(branchcode, branchname) VALUES (?, ?)",
                        values: [library.library_id, library.name],
                    },
                    {
                        query: "INSERT INTO itemtypes(itemtype, description) VALUES (?, ?)",
                        values: [item_type.item_type_id, item_type.description],
                    },
                ];
                cy.wrap(Promise.resolve())
                    .then(() => {
                        return queries.reduce((chain, { query, values }) => {
                            return chain.then(() =>
                                cy.task("query", { sql: query, values })
                            );
                        }, Promise.resolve());
                    })
                    .then(() => {
                        let biblio = {
                            leader: "     nam a22     7a 4500",
                            fields: [
                                { "005": "20250120101920.0" },
                                {
                                    "245": {
                                        ind1: "",
                                        ind2: "",
                                        subfields: [{ a: "Some boring read" }],
                                    },
                                },
                                {
                                    "100": {
                                        ind1: "",
                                        ind2: "",
                                        subfields: [
                                            { c: "Some boring author" },
                                        ],
                                    },
                                },
                                {
                                    "942": {
                                        ind1: "",
                                        ind2: "",
                                        subfields: [
                                            { c: item_type.item_type_id },
                                        ],
                                    },
                                },
                            ],
                        };
                        cy.request({
                            method: "POST",
                            url: "/api/v1/biblios",
                            headers: {
                                "Content-Type": "application/marc-in-json",
                                "x-confirm-not-duplicate": 1,
                            },
                            body: biblio,
                        }).then(response => {
                            const biblio_id = response.body.id;
                            cy.wrap(biblio_id).as("biblio_id");
                            cy.request({
                                method: "POST",
                                url: `/api/v1/biblios/${biblio_id}/items`,
                                headers: {
                                    "Content-Type": "application/json",
                                },
                                body: {
                                    home_library_id: library.library_id,
                                    holding_library_id: library.library_id,
                                },
                            });
                        });
                    });
            });
        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='AlwaysShowHoldingsTableFilters'",
        }).then(value => {
            cy.wrap(value).as("syspref_AlwaysShowHoldingsTableFilters");
        });
    });

    afterEach(function () {
        cy.set_syspref(
            "AlwaysShowHoldingsTableFilters",
            this.syspref_AlwaysShowHoldingsTableFilters
        );
    });

    it("Correctly init the table", function () {
        // Do not use `() => {` or this.biblio_id won't be retrieved
        const biblio_id = this.biblio_id;
        cy.task("buildSampleObjects", {
            object: "item",
            count: RESTdefaultPageSize,
            values: {
                biblio_id,
                checkout: null,
                transfer: null,
                lost_status: 0,
                withdrawn: 0,
                damaged_status: 0,
                not_for_loan_status: 0,
                course_item: null,
                cover_image_ids: [],
                _status: ["available"],
            },
        }).then(items => {
            cy.intercept("get", `/api/v1/biblios/${biblio_id}/items*`, {
                statuscode: 200,
                body: items,
                headers: {
                    "X-Base-Total-Count": baseTotalCount,
                    "X-Total-Count": baseTotalCount,
                },
            });

            cy.visit(
                "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" + biblio_id
            );

            cy.get(`#${table_id}_wrapper tbody tr`).should(
                "have.length",
                RESTdefaultPageSize
            );

            cy.get(`#${table_id}_wrapper .dt-info`).contains(
                `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
            );
        });
    });

    it("Show filters", function () {
        // Do not use `() => {` or this.biblio_id won't be retrieved
        const biblio_id = this.biblio_id;
        cy.task("buildSampleObjects", {
            object: "item",
            count: RESTdefaultPageSize,
            values: {
                biblio_id,
                checkout: null,
                transfer: null,
                lost_status: 0,
                withdrawn: 0,
                damaged_status: 0,
                not_for_loan_status: 0,
                course_item: null,
                cover_image_ids: [],
                _status: ["available"],
            },
        }).then(items => {
            cy.intercept("get", `/api/v1/biblios/${biblio_id}/items*`, {
                statuscode: 200,
                body: items,
                headers: {
                    "X-Base-Total-Count": baseTotalCount,
                    "X-Total-Count": baseTotalCount,
                },
            });

            cy.set_syspref("AlwaysShowHoldingsTableFilters", 0).then(() => {
                cy.visit(
                    "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" +
                        biblio_id
                );

                // Hide the 'URL' column
                cy.mock_table_settings(
                    {
                        columns: { uri: { is_hidden: 1 } },
                    },
                    "items_table_settings.holdings"
                );

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id}_wrapper tbody tr`).should(
                        "have.length",
                        RESTdefaultPageSize
                    );

                    // Filters are not displayed
                    cy.get(`#${table_id} thead tr`).should("have.length", 1);

                    cy.get(`#${table_id} th`).contains("Status");
                    cy.get(`#${table_id} th`)
                        .contains("URL")
                        .should("not.exist");
                    cy.get(`#${table_id} th`)
                        .contains("Course reserves")
                        .should("not.exist");

                    cy.get(`.${table_id}_table_controls .show_filters`).click();
                    cy.get(`#${table_id}_wrapper .dt-info`).contains(
                        `Showing 1 to ${RESTdefaultPageSize} of ${baseTotalCount} entries`
                    );
                    // Filters are displayed
                    cy.get(`#${table_id} thead tr`).should("have.length", 2);

                    cy.get(`#${table_id} th`).contains("Status");
                    cy.get(`#${table_id} th`)
                        .contains("URL")
                        .should("not.exist");
                    cy.get(`#${table_id} th`)
                        .contains("Course reserves")
                        .should("not.exist");
                });
            });

            cy.set_syspref("AlwaysShowHoldingsTableFilters", 1).then(() => {
                cy.visit(
                    "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" +
                        biblio_id
                );

                // Hide the 'URL' column
                cy.mock_table_settings(
                    {
                        columns: { uri: { is_hidden: 1 } },
                    },
                    "items_table_settings.holdings"
                );

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id}_wrapper tbody tr`).should(
                        "have.length",
                        RESTdefaultPageSize
                    );

                    // Filters are displayed
                    cy.get(`#${table_id} thead tr`).should("have.length", 2);

                    cy.get(`.${table_id}_table_controls .hide_filters`).click();

                    // Filters are not displayed
                    cy.get(`#${table_id} thead tr`).should("have.length", 1);
                });
            });
        });
    });

    it("Filters by code and description", function () {
        // Do not use `() => {` or this.biblio_id won't be retrieved
        const biblio_id = this.biblio_id;
        cy.task("buildSampleObjects", {
            object: "item",
            count: RESTdefaultPageSize,
            values: {
                biblio_id,
                checkout: null,
                transfer: null,
                lost_status: 0,
                withdrawn: 0,
                damaged_status: 0,
                not_for_loan_status: 0,
                course_item: null,
                cover_image_ids: [],
                _status: ["available"],
            },
        }).then(items => {
            cy.intercept("get", `/api/v1/biblios/${biblio_id}/items*`, {
                statuscode: 200,
                body: items,
                headers: {
                    "X-Base-Total-Count": baseTotalCount,
                    "X-Total-Count": baseTotalCount,
                },
            }).as("searchItems");

            cy.visit(
                "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" + biblio_id
            );

            cy.window().then(win => {
                win.coded_values.library = new Map(
                    items.map(i => [
                        i.home_library.name,
                        i.home_library.library_id,
                    ])
                );
                win.coded_values.item_type = new Map(
                    items.map(i => [
                        i.item_type.description,
                        i.item_type.item_type_id,
                    ])
                );
            });
            cy.wait("@searchItems");

            let library_id = items[0].home_library.library_id;
            let library_name = items[0].home_library.name;
            cy.get(`#${table_id}_wrapper input.dt-input`).type(library_id);

            cy.wait("@searchItems").then(interception => {
                const q = interception.request.query.q;
                expect(q).to.match(
                    new RegExp(
                        `"me.home_library_id":{"like":"%${library_id}%"}`
                    )
                );
            });

            cy.get(`#${table_id}_wrapper input.dt-input`).clear();
            cy.wait("@searchItems");
            cy.get(`#${table_id}_wrapper input.dt-input`).type(library_name);

            cy.wait("@searchItems").then(interception => {
                const q = interception.request.query.q;
                expect(q).to.match(
                    new RegExp(`"me.home_library_id":\\["${library_id}"\\]`)
                );
            });

            let item_type_id = items[0].item_type.item_type_id;
            let item_type_description = items[0].item_type.description;
            cy.get(`#${table_id}_wrapper input.dt-input`).clear();
            cy.wait("@searchItems");
            cy.get(`#${table_id}_wrapper input.dt-input`).type(item_type_id);

            cy.wait("@searchItems").then(interception => {
                const q = interception.request.query.q;
                expect(q).to.match(
                    new RegExp(`"me.item_type_id":{"like":"%${item_type_id}%"}`)
                );
            });

            cy.get(`#${table_id}_wrapper input.dt-input`).clear();
            cy.wait("@searchItems");
            cy.get(`#${table_id}_wrapper input.dt-input`).type(
                item_type_description
            );

            cy.wait("@searchItems").then(interception => {
                const q = interception.request.query.q;
                expect(q).to.match(
                    new RegExp(`"me.item_type_id":\\["${item_type_id}"\\]`)
                );
            });

            cy.viewport(2999, 2999);
            cy.get(`#${table_id}_wrapper input.dt-input`).clear();
            cy.wait("@searchItems");
            // Show filters if not there already
            cy.get(`.${table_id}_table_controls .show_filters`)
                .then(link => {
                    if (link.is(":visible")) {
                        cy.wrap(link).click();
                        cy.wait("@searchItems");
                    }
                })
                .then(() => {
                    // Select first (non-empty) option
                    cy.get(
                        `#${table_id}_wrapper th#holdings_itype select`
                    ).then(select => {
                        const raw_value = select.find("option").eq(1).val();
                        expect(raw_value).to.match(/^\^/);
                        expect(raw_value).to.match(/\$$/);
                        item_type_id = raw_value.replace(/^\^|\$$/g, ""); // Remove ^ and $
                    });
                    cy.get(
                        `#${table_id}_wrapper th#holdings_itype select option`
                    )
                        .eq(1)
                        .then(o => {
                            cy.get(
                                `#${table_id}_wrapper th#holdings_itype select`
                            ).select(o.val(), { force: true });
                        });
                    cy.wait("@searchItems").then(interception => {
                        const q = interception.request.query.q;
                        expect(q).to.match(
                            new RegExp(`{"me.item_type_id":"${item_type_id}"}`)
                        );
                    });
                });
        });
    });
});

describe("catalogue/detail/holdings_table without items", () => {
    const table_id = "holdings_table";
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.window().then(win => {
            win.localStorage.clear();
        });

        // FIXME All the following code should not be reused as it
        // It must be moved to a Cypress command or task "buildSampleBiblio" or even "insertSampleBiblio"
        let generated_objects = {};
        const objects = [{ object: "library" }, { object: "item_type" }];
        cy.wrap(Promise.resolve())
            .then(() => {
                return objects.reduce((chain, { object }) => {
                    return chain.then(() => {
                        return cy
                            .task("buildSampleObject", { object })
                            .then(attributes => {
                                generated_objects[object] = attributes;
                            });
                    });
                }, Promise.resolve());
            })
            .then(() => {
                const item_type = generated_objects["item_type"];
                const queries = [
                    {
                        sql: "INSERT INTO itemtypes(itemtype, description) VALUES (?, ?)",
                        values: [item_type.item_type_id, item_type.description],
                    },
                ];
                cy.wrap(Promise.resolve())
                    .then(() => {
                        return queries.reduce((chain, { sql, values }) => {
                            return chain.then(() =>
                                cy.task("query", { sql, values })
                            );
                        }, Promise.resolve());
                    })
                    .then(() => {
                        let biblio = {
                            leader: "     nam a22     7a 4500",
                            fields: [
                                { "005": "20250120101920.0" },
                                {
                                    "245": {
                                        ind1: "",
                                        ind2: "",
                                        subfields: [{ a: "Some boring read" }],
                                    },
                                },
                                {
                                    "100": {
                                        ind1: "",
                                        ind2: "",
                                        subfields: [
                                            { c: "Some boring author" },
                                        ],
                                    },
                                },
                                {
                                    "942": {
                                        ind1: "",
                                        ind2: "",
                                        subfields: [
                                            { c: item_type.item_type_id },
                                        ],
                                    },
                                },
                            ],
                        };
                        cy.request({
                            method: "POST",
                            url: "/api/v1/biblios",
                            headers: {
                                "Content-Type": "application/marc-in-json",
                                "x-confirm-not-duplicate": 1,
                            },
                            body: biblio,
                        }).then(response => {
                            const biblio_id = response.body.id;
                            cy.wrap(biblio_id).as("biblio_id");
                        });
                    });
            });
        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='AlwaysShowHoldingsTableFilters'",
        }).then(value => {
            cy.wrap(value).as("syspref_AlwaysShowHoldingsTableFilters");
        });
    });

    afterEach(function () {
        cy.set_syspref(
            "AlwaysShowHoldingsTableFilters",
            this.syspref_AlwaysShowHoldingsTableFilters
        );
    });

    it("Do not display the table", function () {
        // Do not use `() => {` or this.biblio_id won't be retrieved
        const biblio_id = this.biblio_id;

        cy.visit("/cgi-bin/koha/catalogue/detail.pl?biblionumber=" + biblio_id);

        cy.get(`#${table_id}_wrapper`).should("not.exist");
    });
});
