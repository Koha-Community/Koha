const RESTdefaultPageSize = "20"; // FIXME Mock this
const baseTotalCount = "21";

describe("catalogue/detail/holdings_table with items", () => {
    const table_id = "holdings_table";
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.window().then(win => {
            win.localStorage.clear();
        });

        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='AlwaysShowHoldingsTableFilters'",
        }).then(value => {
            cy.wrap(value).as("syspref_AlwaysShowHoldingsTableFilters");
        });

        cy.task("insertSampleBiblio", { item_count: baseTotalCount }).then(
            objects => {
                cy.wrap(objects).as("objects");
            }
        );
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", [this.objects]);
        cy.set_syspref(
            "AlwaysShowHoldingsTableFilters",
            this.syspref_AlwaysShowHoldingsTableFilters
        );
    });

    it("Correctly init the table", function () {
        // Do not use `() => {` or this.objects won't be retrieved
        const biblio_id = this.objects.biblio.biblio_id;
        cy.set_syspref("AlwaysShowHoldingsTableFilters", 1).then(() => {
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
        // Do not use `() => {` or this.objects won't be retrieved
        const biblio_id = this.objects.biblio.biblio_id;

        cy.set_syspref("AlwaysShowHoldingsTableFilters", 0).then(() => {
            cy.visit(
                "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" + biblio_id
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
                cy.get(`#${table_id} th`).contains("URL").should("not.exist");
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
                cy.get(`#${table_id} th`).contains("URL").should("not.exist");
                cy.get(`#${table_id} th`)
                    .contains("Course reserves")
                    .should("not.exist");
            });
        });

        cy.set_syspref("AlwaysShowHoldingsTableFilters", 1).then(() => {
            cy.visit(
                "/cgi-bin/koha/catalogue/detail.pl?biblionumber=" + biblio_id
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

    it("Filters by code and description", function () {
        // Do not use `() => {` or this.objects won't be retrieved
        const biblio_id = this.objects.biblio.biblio_id;

        cy.intercept("get", `/api/v1/biblios/${biblio_id}/items*`).as(
            "searchItems"
        );

        cy.visit("/cgi-bin/koha/catalogue/detail.pl?biblionumber=" + biblio_id);

        cy.wait("@searchItems");

        cy.task("query", {
            sql: "SELECT homebranch FROM items WHERE biblionumber=? LIMIT 1",
            values: [biblio_id],
        }).then(result => {
            let library_id = result[0].homebranch;
            cy.task("query", {
                sql: "SELECT branchname FROM branches WHERE branchcode=?",
                values: [library_id],
            }).then(result => {
                let library_name = result[0].branchname;
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
                cy.get(`#${table_id}_wrapper input.dt-input`).type(
                    library_name
                );

                cy.wait("@searchItems").then(interception => {
                    const q = interception.request.query.q;
                    expect(q).to.match(
                        new RegExp(`"me.home_library_id":\\["${library_id}"\\]`)
                    );
                });
            });
        });

        cy.task("query", {
            sql: "SELECT itype FROM items WHERE biblionumber=? LIMIT 1",
            values: [biblio_id],
        }).then(result => {
            let item_type_id = result[0].itype;
            cy.task("query", {
                sql: "SELECT description FROM itemtypes WHERE itemtype=?",
                values: [item_type_id],
            }).then(result => {
                let item_type_description = result[0].description;

                cy.get(`#${table_id}_wrapper input.dt-input`).clear();
                cy.wait("@searchItems");
                cy.get(`#${table_id}_wrapper input.dt-input`).type(
                    item_type_id
                );

                cy.wait("@searchItems").then(interception => {
                    const q = interception.request.query.q;
                    expect(q).to.match(
                        new RegExp(
                            `"me.item_type_id":{"like":"%${item_type_id}%"}`
                        )
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
                                new RegExp(
                                    `{"me.item_type_id":"${item_type_id}"}`
                                )
                            );
                        });
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

        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='AlwaysShowHoldingsTableFilters'",
        }).then(value => {
            cy.wrap(value).as("syspref_AlwaysShowHoldingsTableFilters");
        });

        cy.task("insertSampleBiblio", { item_count: 0 }).then(objects => {
            cy.wrap(objects).as("objects");
        });
    });

    afterEach(function () {
        cy.task("deleteSampleObjects", [this.objects]);
        cy.set_syspref(
            "AlwaysShowHoldingsTableFilters",
            this.syspref_AlwaysShowHoldingsTableFilters
        );
    });

    it("Do not display the table", function () {
        // Do not use `() => {` or this.objects won't be retrieved
        const biblio_id = this.objects.biblio.biblio_id;

        cy.visit("/cgi-bin/koha/catalogue/detail.pl?biblionumber=" + biblio_id);

        cy.get(`#${table_id}_wrapper`).should("not.exist");
    });
});
