const RESTdefaultPageSize = "20"; // FIXME Mock this
const baseTotalCount = "42";

describe("catalogue/detail/holdings_table", () => {
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
                            return chain.then(() => cy.query(query, values));
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
        cy.query(
            "SELECT value FROM systempreferences WHERE variable='AlwaysShowHoldingsTableFilters'"
        ).then(value => {
            cy.wrap(value).as("syspref_AlwaysShowHoldingsTableFilters");
        });
    });

    afterEach(
        () =>
            function () {
                cleanup();
                cy.set_syspref(
                    "AlwaysShowHoldingsTableFilters",
                    this.syspref_AlwaysShowHoldingsTableFilters
                );
            }
    );

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

            cy.window().then(win => {
                win.libraries_map = items.reduce((map, i) => {
                    map[i.library_id] = i.library_id;
                    return map;
                }, {});
            });

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

                cy.window().then(win => {
                    win.libraries_map = items.reduce((map, i) => {
                        map[i.library_id] = i.library_id;
                        return map;
                    }, {});
                });

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

                    cy.get(".show_filters").click();
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

                cy.window().then(win => {
                    win.libraries_map = items.reduce((map, i) => {
                        map[i.library_id] = i.library_id;
                        return map;
                    }, {});
                });

                cy.get("@columns").then(columns => {
                    cy.get(`#${table_id}_wrapper tbody tr`).should(
                        "have.length",
                        RESTdefaultPageSize
                    );

                    // Filters are displayed
                    cy.get(`#${table_id} thead tr`).should("have.length", 2);

                    cy.get(".hide_filters").click();

                    // Filters are not displayed
                    cy.get(`#${table_id} thead tr`).should("have.length", 1);
                });
            });
        });
    });
});
