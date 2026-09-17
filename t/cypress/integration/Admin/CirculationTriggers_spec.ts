// Generates a rule set in the format the API actually returns:
// { context: { library_id, patron_category_id, item_type_id }, overdue_N_delay, ... }
const getMockRuleSet = (
    library_id: string = "*",
    patron_category_id: string = "*",
    item_type_id: string = "*",
    triggerNum: number = 1,
    delay: string = "7"
) => {
    return {
        context: { library_id, patron_category_id, item_type_id },
        [`overdue_${triggerNum}_delay`]: delay,
        [`overdue_${triggerNum}_notice`]: null,
        [`overdue_${triggerNum}_restrict`]: null,
        [`overdue_${triggerNum}_mtt`]: null,
    };
};

const getMockLibraries = () => {
    return [
        {
            library_id: "CPL",
            name: "Centerville",
            address1: "123 Main St",
            city: "Centerville",
        },
        {
            library_id: "MPL",
            name: "Midway",
            address1: "456 Broad St",
            city: "Midway",
        },
        {
            library_id: "FPL",
            name: "Fairview",
            address1: "789 Park Ave",
            city: "Fairview",
        },
    ];
};

const getMockPatronCategories = () => {
    return [
        {
            patron_category_id: "PT",
            name: "Patron",
            description: "Regular patron",
        },
        {
            patron_category_id: "ST",
            name: "Student",
            description: "Student patron",
        },
        {
            patron_category_id: "SF",
            name: "Staff",
            description: "Staff member",
        },
    ];
};

const getMockItemTypes = () => {
    return [
        {
            item_type_id: "BK",
            description: "Books",
        },
        {
            item_type_id: "DVD",
            description: "DVDs",
        },
        {
            item_type_id: "MAG",
            description: "Magazines",
        },
    ];
};

const getMockLetters = () => {
    return [
        {
            code: "ODUE1",
            name: "First Overdue Notice",
            branchcode: null,
            module: "circulation",
        },
        {
            code: "ODUE2",
            name: "Second Overdue Notice",
            branchcode: null,
            module: "circulation",
        },
        {
            code: "ODUE3",
            name: "Third Overdue Notice",
            branchcode: null,
            module: "circulation",
        },
        {
            code: "CPL_ODUE",
            name: "Centerville Overdue",
            branchcode: "CPL",
            module: "circulation",
        },
    ];
};

describe("Circulation Triggers - Breadcrumbs", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Should display correct breadcrumbs", () => {
        cy.visit("/cgi-bin/koha/admin/admin-home.pl");
        cy.contains("Circulation triggers").click();
        cy.get("#breadcrumbs").contains("Administration");
        cy.get("#breadcrumbs > ol > li:nth-child(3)").contains(
            "Circulation triggers"
        );
    });

    it("Should have breadcrumb link from add form", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.contains("Add new trigger").click();
        cy.get("#breadcrumbs")
            .contains("Circulation triggers")
            .should("have.attr", "href")
            .and("equal", "/cgi-bin/koha/admin/circulation_triggers");
    });
});

describe("Circulation Triggers - Initial Load", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: getMockLibraries(),
        }).as("get-libraries");

        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: getMockPatronCategories(),
        }).as("get-patron-categories");

        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: getMockItemTypes(),
        }).as("get-item-types");

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [
                getMockRuleSet("*", "*", "*", 1),
                getMockRuleSet("*", "*", "*", 2),
                getMockRuleSet("CPL", "PT", "BK", 1),
            ],
            headers: {
                "X-Base-Total-Count": "3",
                "X-Total-Count": "3",
            },
        }).as("get-rules");
    });

    it("Should successfully load the component and display initial elements", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("h1").should("contain", "Circulation triggers");
        cy.get(".page-section").should(
            "contain",
            "Rules are applied from most specific to less specific"
        );
        cy.get("#library_select").should("exist");
        cy.get("#patron_category_select").should("exist");
        cy.get("#item_type_select").should("exist");
        cy.contains("Add new trigger").should("exist");
    });

    it("Should display trigger tabs when rules exist", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("#circ-triggers-tabs").should("exist");
        cy.get(".nav-link").contains("Trigger 1").should("exist");
        cy.get(".nav-link").contains("Trigger 2").should("exist");
    });

    it("Should handle API errors gracefully", () => {
        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 500,
        }).as("get-rules-error");

        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.wait("@get-rules-error");

        // Component should still render without crashing
        cy.get("h1").should("contain", "Circulation triggers");
    });

    //  regression check (mtt stopped reliably displaying fallback status)
    it("Should render MTT cells with the fallback class when no explicit mtt rule exists", () => {
        // mtt is one DB column shared by email/print/sms, so the three are
        // atomic — you can't set sms while inheriting print/email. When no
        // rule set provides an mtt value, all three cells render .fallback
        // (bold italics) to signal inheritance.
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("#trigger-table-main tbody tr")
            .first()
            .within(() => {
                cy.get("td").eq(5).find("span.fallback").should("exist");
                cy.get("td").eq(6).find("span.fallback").should("exist");
                cy.get("td").eq(7).find("span.fallback").should("exist");
            });
    });
});

describe("Circulation Triggers - No default rules warning", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: getMockLibraries(),
        }).as("get-libraries");

        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: getMockPatronCategories(),
        }).as("get-patron-categories");

        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: getMockItemTypes(),
        }).as("get-item-types");
    });

    it("Should show warning when no default rules exist but library-specific rules do", () => {
        // First intercept: default-library fetch returns empty
        // Second intercept: all-rules fetch (for getLibrariesWithRules) returns CPL rules
        cy.intercept("GET", "/api/v1/circulation_rules*", req => {
            const url = new URL(req.url);
            if (url.searchParams.get("library_id") === "*") {
                req.reply({
                    statusCode: 200,
                    body: [],
                    headers: {
                        "X-Base-Total-Count": "0",
                        "X-Total-Count": "0",
                    },
                });
            } else {
                req.reply({
                    statusCode: 200,
                    body: [getMockRuleSet("CPL", "*", "*", 1)],
                    headers: {
                        "X-Base-Total-Count": "1",
                        "X-Total-Count": "1",
                    },
                });
            }
        }).as("get-rules");

        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".alert-warning").should(
            "contain",
            "No default overdue triggers are defined"
        );
        cy.get(".alert-warning").should(
            "contain",
            "The following libraries have library-specific triggers defined"
        );
        cy.get(".alert-warning").contains("Centerville").should("exist");
    });

    it("Should show get-started message when no rules exist anywhere", () => {
        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [],
            headers: { "X-Base-Total-Count": "0", "X-Total-Count": "0" },
        }).as("get-rules");

        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".alert-warning").should(
            "contain",
            "No default overdue triggers are defined"
        );
        cy.get(".alert-warning").should(
            "contain",
            "Select add new trigger above to get started"
        );
    });

    it("Should not show warning when default rules exist", () => {
        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [getMockRuleSet("*", "*", "*", 1)],
            headers: { "X-Base-Total-Count": "1", "X-Total-Count": "1" },
        }).as("get-rules");

        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.get("#circ-triggers-tabs").should("exist");

        cy.get(".alert-warning").should("not.exist");
    });

    it("Should switch to library view when clicking a library link in the warning", () => {
        cy.intercept("GET", "/api/v1/circulation_rules*", req => {
            const url = new URL(req.url);
            if (url.searchParams.get("library_id") === "*") {
                req.reply({
                    statusCode: 200,
                    body: [],
                    headers: {
                        "X-Base-Total-Count": "0",
                        "X-Total-Count": "0",
                    },
                });
            } else {
                req.reply({
                    statusCode: 200,
                    body: [getMockRuleSet("CPL", "*", "*", 1)],
                    headers: {
                        "X-Base-Total-Count": "1",
                        "X-Total-Count": "1",
                    },
                });
            }
        }).as("get-rules");

        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".alert-warning").contains("Centerville").click();

        // The library filter should now show Centerville and the warning should be gone
        cy.get("#library_select .vs__selected").should(
            "contain",
            "Centerville"
        );
        cy.get(".alert-warning").should("not.exist");
    });
});

describe("Circulation Triggers - Filtering", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: getMockLibraries(),
        });

        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: getMockPatronCategories(),
        });

        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: getMockItemTypes(),
        });

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [
                getMockRuleSet("*", "*", "*", 1),
                getMockRuleSet("CPL", "*", "*", 1),
                getMockRuleSet("CPL", "PT", "*", 1),
                getMockRuleSet("CPL", "PT", "BK", 1),
                getMockRuleSet("MPL", "ST", "DVD", 1),
            ],
            headers: {
                "X-Base-Total-Count": "5",
                "X-Total-Count": "5",
            },
        }).as("get-rules");
    });

    it("Should filter by library", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("#library_select .vs__search").type("Centerville{enter}", {
            force: true,
        });
        cy.get("#library_select .vs__selected").should(
            "contain",
            "Centerville"
        );
    });

    it("Should filter by patron category", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("#patron_category_select .vs__search").type("Patron{enter}", {
            force: true,
        });
        cy.get("#patron_category_select .vs__selected").should(
            "contain",
            "Patron"
        );
    });

    it("Should filter by item type", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("#item_type_select .vs__search").type("Books{enter}", {
            force: true,
        });
        cy.get("#item_type_select .vs__selected").should("contain", "Books");
    });

    it("Should toggle between explicit and all applicable rules", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("#filter-rules").should("exist");

        cy.get("#filter-rules .vs__search").click();
        cy.get("#filter-rules .vs__dropdown-menu")
            .contains("explicitly set rules")
            .click({ force: true });
    });
});

describe("Circulation Triggers - Tab Navigation", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: [],
        });

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [
                getMockRuleSet("*", "*", "*", 1),
                getMockRuleSet("*", "*", "*", 2),
                getMockRuleSet("*", "*", "*", 3),
            ],
            headers: {
                "X-Base-Total-Count": "3",
                "X-Total-Count": "3",
            },
        }).as("get-rules");
    });

    it("Should switch between trigger tabs", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".nav-link")
            .contains("Trigger 1")
            .should("have.class", "active");

        cy.get(".nav-link").contains("Trigger 2").click();
        cy.get(".nav-link")
            .contains("Trigger 2")
            .should("have.class", "active");

        cy.get(".tab-pane.active").should("exist");

        cy.get(".nav-link").contains("Trigger 3").click();
        cy.get(".nav-link")
            .contains("Trigger 3")
            .should("have.class", "active");
    });
});

describe("Circulation Triggers - Add New Trigger", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: getMockLibraries(),
        });

        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: getMockPatronCategories(),
        });

        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: getMockItemTypes(),
        });

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [getMockRuleSet("*", "*", "*", 1, "7")],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-rules");
    });

    it("Should open add trigger modal", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.get(".modal-dialog").should("not.exist");
        cy.contains("Add new trigger").click();

        cy.get(".modal-dialog").should("be.visible");
        cy.get(".modal-title").should(
            "contain",
            "Circulation Trigger Configuration"
        );
    });

    it("Should require context selection fields", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.contains("Add new trigger").click();

        cy.get("#library_id").should("exist");
        cy.get("#patron_category_id").should("exist");
        cy.get("#item_type_id").should("exist");
    });

    it("Should show trigger number 1 when adding first trigger for a library with no existing rules", () => {
        // Regression test for bug where triggerNumber was NaN when no rules
        // existed for a library (triggerCounts[library_id] was undefined).
        // The default beforeEach intercept returns only a */*/* rule, so CPL
        // has no library-specific rules — exact regression case.
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.contains("Add new trigger").click();

        cy.get("#library_id .vs__search").type("Centerville{enter}", {
            force: true,
        });
        cy.get("#patron_category_id .vs__search").type("Patron{enter}", {
            force: true,
        });
        cy.get("#item_type_id .vs__search").type("Books{enter}", {
            force: true,
        });
        cy.contains("Confirm context").click();

        cy.get("#trigger-table-form td.actions button").contains("Add").click();

        // trigger number should be 1, not NaN
        cy.get("legend").should("contain", "Add new trigger 1");
        cy.get("#overdue_delay").should("exist");
        cy.get("#overdue_delay").should("not.have.attr", "name", /NaN/);
    });

    it("Should show enabled row actions in the trigger table at the selectOrAdd step", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.contains("Add new trigger").click();

        cy.get("#library_id .vs__search").type("Centerville{enter}", {
            force: true,
        });
        cy.get("#patron_category_id .vs__search").type("Patron{enter}", {
            force: true,
        });
        cy.get("#item_type_id .vs__search").type("Books{enter}", {
            force: true,
        });
        cy.contains("Confirm context").click();

        cy.get("#trigger-table-form td.actions").should("exist");
        cy.get("#trigger-table-form td.actions button").should("exist");
        cy.get("#trigger-table-form td.actions button[disabled]").should(
            "not.exist"
        );
    });

    it("Should disable row actions once add mode is entered from the trigger table", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.contains("Add new trigger").click();

        cy.get("#library_id .vs__search").type("Centerville{enter}", {
            force: true,
        });
        cy.get("#patron_category_id .vs__search").type("Patron{enter}", {
            force: true,
        });
        cy.get("#item_type_id .vs__search").type("Books{enter}", {
            force: true,
        });
        cy.contains("Confirm context").click();

        cy.get("#trigger-table-form td.actions button").contains("Add").click();

        cy.get("#trigger-table-form td.actions button[disabled]").should(
            "exist"
        );
        cy.get("#trigger-table-form td.actions button:not([disabled])").should(
            "not.exist"
        );
    });

    it("Should mark non-active steps with bg-success-subtle in the add flow", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.contains("Add new trigger").click();

        cy.get("#library_id .vs__search").type("Centerville{enter}", {
            force: true,
        });
        cy.get("#patron_category_id .vs__search").type("Patron{enter}", {
            force: true,
        });
        cy.get("#item_type_id .vs__search").type("Books{enter}", {
            force: true,
        });
        cy.contains("Confirm context").click();

        // At selectOrAdd: the prior ConfirmContext step is highlighted,
        // but the active TriggersTable section is not.
        cy.contains("legend", "Selected trigger context")
            .parents(".page-section")
            .first()
            .should("have.class", "bg-success-subtle");
        cy.get("#trigger-table-form")
            .parents(".page-section")
            .first()
            .should("not.have.class", "bg-success-subtle");

        // Enter add mode: now both prior steps should be highlighted.
        cy.get("#trigger-table-form td.actions button").contains("Add").click();
        cy.get("#trigger-table-form")
            .parents(".page-section")
            .first()
            .should("have.class", "bg-success-subtle");
    });

    it("Should show row actions in the trigger table on the main list", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("#trigger-table-main td.actions").should("exist");
    });

    it("Should allow cancelling add operation", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.contains("Add new trigger").click();

        cy.get(".modal-dialog").should("be.visible");

        cy.contains("Cancel").click();

        cy.get(".modal-dialog").should("not.exist");
        cy.get("h1").should("contain", "Circulation triggers");
    });
});

describe("Circulation Triggers - Delete Trigger", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: [],
        });

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [
                getMockRuleSet("*", "*", "*", 1),
                getMockRuleSet("*", "*", "*", 2),
                getMockRuleSet("*", "*", "*", 3),
            ],
            headers: {
                "X-Base-Total-Count": "3",
                "X-Total-Count": "3",
            },
        }).as("get-rules");
    });

    it("Should only show delete button for last trigger tab", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".nav-link").contains("Trigger 3").click();
        cy.contains("Delete").should("exist");

        cy.get(".nav-link").contains("Trigger 1").click();
        cy.contains("Delete").should("not.exist");
    });

    it("Should show confirmation dialog for delete", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".nav-link").contains("Trigger 3").click();
        cy.contains("Delete").click();

        cy.get(".modal-dialog").should("be.visible");
        cy.get(".modal-title").should(
            "contain",
            "Confirm deletion of trigger 3"
        );
        cy.get(".modal-body").should("contain", "Rule sets to be deleted");
    });

    it("Should allow canceling delete operation", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".nav-link").contains("Trigger 3").click();
        cy.contains("Delete").click();

        cy.get(".modal-dialog").should("be.visible");

        cy.contains("Cancel").click();

        cy.get(".modal-dialog").should("not.exist");
        cy.get(".nav-link")
            .contains("Trigger 3")
            .should("have.class", "active");
    });
});

describe("Circulation Triggers - Delete Trigger Disabled States", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: getMockLibraries(),
        });
        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: getMockPatronCategories(),
        });
        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: getMockItemTypes(),
        });
    });

    // this is because we always delete a trigger for a library
    // where a trigger is all the rulesets for the triggerNumber for the library
    // this mirrors the create trigger pattern, which is also per library per triggerNumber
    it("Should disable Delete with tooltip when a patron category filter is set", () => {
        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [
                getMockRuleSet("*", "*", "*", 1),
                getMockRuleSet("*", "*", "*", 2),
            ],
            headers: {
                "X-Base-Total-Count": "2",
                "X-Total-Count": "2",
            },
        }).as("get-rules");

        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".nav-link").contains("Trigger 2").click();
        cy.contains("Delete").should("not.have.attr", "disabled");

        cy.get("#patron_category_select .vs__search").type("Patron{enter}", {
            force: true,
        });

        cy.contains("Delete").should("have.attr", "disabled");
        cy.contains("Delete")
            .parent("span")
            .should(
                "have.attr",
                "title",
                "Delete is only available when no patron category or item type filter is set, as it removes all explicit rules for this trigger across the selected library."
            );
    });

    it("Should disable Delete with tooltip when an item type filter is set", () => {
        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [
                getMockRuleSet("*", "*", "*", 1),
                getMockRuleSet("*", "*", "*", 2),
            ],
            headers: {
                "X-Base-Total-Count": "2",
                "X-Total-Count": "2",
            },
        }).as("get-rules");

        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".nav-link").contains("Trigger 2").click();
        cy.contains("Delete").should("not.have.attr", "disabled");

        cy.get("#item_type_select .vs__search").type("Books{enter}", {
            force: true,
        });

        cy.contains("Delete").should("have.attr", "disabled");
        cy.contains("Delete")
            .parent("span")
            .should(
                "have.attr",
                "title",
                "Delete is only available when no patron category or item type filter is set, as it removes all explicit rules for this trigger across the selected library."
            );
    });

    it("Should disable Delete on default library when another library has higher triggers", () => {
        // Default library has triggers 1 and 2; CPL has triggers up to 3.
        // Deleting trigger 2 on the default library would orphan CPL trigger 3.
        // Since we do not allow breaks in trigger sequentiality, this should result in the button being disabled
        cy.intercept("GET", "/api/v1/circulation_rules*", req => {
            const url = new URL(req.url);
            if (url.searchParams.get("library_id") === "*") {
                req.reply({
                    statusCode: 200,
                    body: [
                        getMockRuleSet("*", "*", "*", 1),
                        getMockRuleSet("*", "*", "*", 2),
                    ],
                    headers: {
                        "X-Base-Total-Count": "2",
                        "X-Total-Count": "2",
                    },
                });
            } else {
                req.reply({
                    statusCode: 200,
                    body: [
                        getMockRuleSet("*", "*", "*", 1),
                        getMockRuleSet("*", "*", "*", 2),
                        getMockRuleSet("CPL", "*", "*", 1),
                        getMockRuleSet("CPL", "*", "*", 2),
                        getMockRuleSet("CPL", "*", "*", 3),
                    ],
                    headers: {
                        "X-Base-Total-Count": "5",
                        "X-Total-Count": "5",
                    },
                });
            }
        }).as("get-rules");

        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".nav-link").contains("Trigger 2").click();

        cy.contains("Delete").should("have.attr", "disabled");
        cy.contains("Delete")
            .parent("span")
            .should("have.attr", "title")
            .and("contain", "Centerville")
            .and("contain", "would be orphaned");
    });
});

describe("Circulation Triggers - Reset Rule Set", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: [],
        });

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [
                getMockRuleSet("*", "*", "*", 1),
                getMockRuleSet("CPL", "PT", "BK", 1),
                getMockRuleSet("MPL", "PT", "BK", 1),
            ],
            headers: {
                "X-Base-Total-Count": "3",
                "X-Total-Count": "3",
            },
        }).as("get-rules");
    });

    it("Should show Reset button for explicit rule sets in the table", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("table").contains("Reset").should("exist");
    });

    it("Should show confirmation dialog for reset", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("table").contains("Reset").click();

        cy.get(".modal-dialog").should("be.visible");
        cy.get(".modal-title").should(
            "contain",
            "Confirm circulation rule set reset"
        );
        cy.get(".modal-body").should("contain", "Rule set selected for reset");
    });

    it("Should allow canceling reset operation", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("table").contains("Reset").click();
        cy.get(".modal-dialog").should("be.visible");

        cy.contains("Cancel").click();
        cy.get(".modal-dialog").should("not.exist");
    });
});

describe("Circulation Triggers - Empty States", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: [],
        });

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [],
            headers: {
                "X-Base-Total-Count": "0",
                "X-Total-Count": "0",
            },
        }).as("get-rules");
    });

    it("Should render without crashing when no rules exist", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get("h1").should("contain", "Circulation triggers");
        cy.get(".alert-warning").should(
            "contain",
            "No default overdue triggers"
        );
    });
});

describe("Circulation Triggers - Complex Scenarios", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: getMockLibraries(),
        });

        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: getMockPatronCategories(),
        });

        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: getMockItemTypes(),
        });

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [
                getMockRuleSet("*", "*", "*", 1),
                getMockRuleSet("*", "*", "*", 2),
                getMockRuleSet("*", "*", "*", 3),
                getMockRuleSet("CPL", "*", "*", 1),
                getMockRuleSet("CPL", "PT", "*", 1),
                getMockRuleSet("CPL", "PT", "BK", 1),
            ],
            headers: {
                "X-Base-Total-Count": "6",
                "X-Total-Count": "6",
            },
        }).as("get-rules");
    });

    it("Should show all three trigger tabs for default library", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".nav-link").contains("Trigger 1").should("exist");
        cy.get(".nav-link").contains("Trigger 2").should("exist");
        cy.get(".nav-link").contains("Trigger 3").should("exist");
    });

    it("Should handle rapid tab switching without errors", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");

        cy.get(".nav-link").contains("Trigger 2").click();
        cy.get(".nav-link").contains("Trigger 1").click();
        cy.get(".nav-link").contains("Trigger 3").click();

        cy.get(".tab-pane.active").should("exist");
        cy.get("body").should("exist");
    });
});

describe("Circulation Triggers - Browser Navigation", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        cy.intercept("GET", "/api/v1/libraries*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/patron_categories*", {
            statusCode: 200,
            body: [],
        });
        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: [],
        });

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            statusCode: 200,
            body: [getMockRuleSet("*", "*", "*", 1)],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-rules");
    });

    it("Should close modal on browser back button", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.contains("Add new trigger").click();

        cy.get(".modal-dialog").should("be.visible");

        cy.go("back");

        cy.get(".modal-dialog").should("not.exist");
    });

    it("Should reopen modal on browser forward button", () => {
        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.contains("Add new trigger").click();
        cy.go("back");
        cy.go("forward");

        cy.get(".modal-dialog").should("be.visible");
    });
});

describe("Circulation Triggers - Permissions", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Should redirect to admin home when config returns no valid permissions", () => {
        cy.intercept("GET", "/api/v1/circulation_rules/config*", {
            statusCode: 403,
        }).as("get-config");

        cy.visit("/cgi-bin/koha/admin/circulation_triggers");
        cy.wait("@get-config");

        cy.url().should("include", "admin-home");
    });
});
