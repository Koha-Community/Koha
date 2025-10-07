import { mount } from "@cypress/vue";

function get_account() {
    return {
        ae_field_template: "",
        allow_additional_materials_checkout: false,
        allow_empty_passwords: false,
        allow_fields: null,
        av_field_template: "",
        blocked_item_types: null,
        checked_in_ok: false,
        convert_nonprinting_characters: "",
        cr_item_field: "collection_code",
        ct_always_send: false,
        cv_send_00_on_success: false,
        cv_triggers_alert: false,
        custom_item_fields: [],
        custom_patron_fields: [
            {
                field: "field1",
                sip_account_custom_patron_field_id: 1,
                sip_account_id: 1,
                template: "template1",
            },
        ],
        da_field_template: "",
        delimiter: "",
        disallow_overpayment: false,
        encoding: null,
        error_detect: false,
        format_due_date: false,
        hide_fields: null,
        holds_block_checkin: false,
        holds_get_captured: false,
        item_fields: [],
        inhouse_item_types: null,
        inhouse_patron_categories: null,
        institution: {
            checkin: false,
            checkout: false,
            implementation: "asdasd",
            name: "asdasd",
            offline: false,
            renewal: false,
            retries: 5,
            sip_institution_id: 1,
            status_update: false,
            timeout: 100,
        },
        login_id: "asdas",
        login_password: "dasdasd",
        lost_block_checkout: null,
        lost_block_checkout_value: null,
        lost_status_for_missing: null,
        overdues_block_checkout: false,
        patron_attributes: [
            {
                code: "code2",
                field: "field2",
                sip_account_id: 1,
                sip_account_patron_attribute_id: 1,
            },
        ],
        payment_type_writeoff: "",
        prevcheckout_block_checkout: false,
        register_id: null,
        seen_on_item_information: "",
        send_patron_home_library_in_af: false,
        show_checkin_message: false,
        show_outstanding_amount: false,
        sip_account_id: 1,
        sip_institution_id: 1,
        terminator: null,
    };
}

describe("Accounts", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("List accounts", () => {
        // GET accounts returns 500
        cy.intercept("GET", "/api/v1/sip2/accounts*", {
            statusCode: 500,
            error: "Something went wrong",
        });
        cy.visit("/cgi-bin/koha/sip2/sip2.pl");
        cy.get(".sidebar_menu").contains("Accounts").click();
        cy.get("main div[class='alert alert-warning']").contains(
            /Something went wrong/
        );

        // GET accounts returns empty list
        cy.intercept("GET", "/api/v1/sip2/accounts*", []);
        cy.visit("/cgi-bin/koha/sip2/accounts");
        cy.get("#accounts_list").contains("There are no accounts defined");

        // GET accounts returns something
        let account = get_account();
        let accounts = [account];

        cy.intercept("GET", "/api/v1/sip2/accounts*", {
            statusCode: 200,
            body: accounts,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.intercept("GET", "/api/v1/sip2/accounts/*", account);
        cy.visit("/cgi-bin/koha/sip2/accounts/");
        cy.get("#accounts_list").contains("Showing 1 to 1 of 1 entries");
    });

    it("Add account", () => {
        let account = get_account();
        let institution = cy.getSIP2Institution();
        let institutions = [institution];

        // No account
        cy.intercept("GET", "/api/v1/sip2/accounts**", {
            statusCode: 200,
            body: [],
        });

        cy.intercept("GET", "/api/v1/sip2/institutions*", institutions).as(
            "getSIP2Institutions"
        );

        // Click the button in the toolbar
        cy.visit("/cgi-bin/koha/sip2/accounts");
        cy.contains("New account").click();
        cy.get("#accounts_add h2").contains("New account");
        cy.left_menu_active_item_is("Accounts");

        // Fill in the form for normal attributes
        cy.get("#accounts_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            3
        );
        cy.get("#login_id").type(account.login_id);
        cy.get("#login_password").type(account.login_password);

        cy.wait("@getSIP2Institutions");
        cy.get("#sip_institution_id .vs__search").type(
            institutions[0].name + "{enter}",
            {
                force: true,
            }
        );

        cy.get("#allow_fields .vs__search").click();
        cy.get("#allow_fields [id*=__option-0]").contains("AA");
        cy.get("#allow_fields [id*=__option-1]").contains("AB");
        cy.get("#allow_fields .vs__search").type("CG" + "{enter}", {
            force: true,
        });
        cy.get("#allow_fields .vs__search").type("CE" + "{enter}", {
            force: true,
        });
        cy.get("#allow_fields .vs__selected-options").contains("CG");
        cy.get("#allow_fields .vs__selected-options").contains("CE");

        cy.get("#allow_fields .vs__selected-options .vs__selected")
            .contains("CG")
            .find(".vs__deselect")
            .click();
        cy.get("#allow_fields .vs__selected-options").should(
            "not.contain",
            "CG"
        );

        //TODO: intercept http://localhost:8081/api/v1/item_types?_per_page=-1
        cy.intercept("GET", "/api/v1/item_types*", {
            statusCode: 200,
            body: cy.getItemTypes(),
        });
        // blocked_item_types
        cy.get("#blocked_item_types .vs__search").click();
        cy.get("#blocked_item_types [id*=__option-0]").contains("Books");
        cy.get("#blocked_item_types [id*=__option-1]").contains(
            "Computer Files"
        );
        cy.get("#blocked_item_types .vs__search").type("Books" + "{enter}", {
            force: true,
        });
        cy.get("#blocked_item_types .vs__selected-options").contains("Books");

        //CR item field
        cy.get("#cr_item_field .vs__selected-options").contains(
            "Collection code"
        );

        // relationshipWidgets
        cy.contains("Add new custom patron field").click();
        cy.get("#accounts_add").contains("Submit").click();
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            2
        );

        // Add new custom patron fields
        cy.contains("Add new custom patron field").click();
        cy.get("#custom_patron_fields_relationship > fieldset").should(
            "have.length",
            2
        );

        cy.contains("a", "Remove this custom patron field").click();

        cy.get("#custom_patron_fields_0 #custom_patron_fields_field_0").type(
            "test"
        );
        cy.get("#custom_patron_fields_0 #custom_patron_fields_template_0").type(
            "test"
        );

        cy.get(".accordion-item").each($el => {
            cy.wrap($el).children(".collapse").should("have.class", "show");
        });

        cy.get(".accordion-item legend[data-bs-toggle='collapse']").each(
            $el => {
                cy.wrap($el).click({ force: true });
            }
        );

        cy.get(".accordion-item").each($el => {
            cy.wrap($el).children(".collapse").should("not.have.class", "show");
        });

        cy.get("#login_id").should("not.be.visible");

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/sip2/accounts", {
            statusCode: 500,
        });
        cy.get("#accounts_add").contains("Submit").click();

        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/sip2/accounts", {
            statusCode: 201,
            body: account,
        });
        cy.get("#accounts_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Account created"
        );
    });

    it("Edit account", () => {
        let account = get_account();
        let accounts = [account];

        // Intercept follow-up 'search' request after entering /accounts
        cy.intercept("GET", "/api/v1/sip2/accounts?_page*", {
            statusCode: 200,
            body: accounts,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-single-account-search-result");
        cy.visit("/cgi-bin/koha/sip2/accounts");
        cy.wait("@get-single-account-search-result");

        // Intercept request after edit click
        cy.intercept("GET", "/api/v1/sip2/accounts/*", account).as(
            "get-account"
        );

        // Click the 'Edit' button from the list
        cy.get("#accounts_list table tbody tr:first").contains("Edit").click();
        cy.wait("@get-account");
        cy.get("#accounts_add h2").contains("Edit account");
        cy.left_menu_active_item_is("Accounts");

        // Form has been correctly filled in
        cy.get("#login_id").should("have.value", accounts[0].login_id);
        cy.get("#login_password").should(
            "have.value",
            accounts[0].login_password
        );

        // cy.get("#checkin_yes").should("be.checked");
        // cy.get("#checkout_yes").should("be.checked");
        // cy.get("#offline_no").should("be.checked");
        // cy.get("#renewal_no").should("be.checked");

        // cy.get("#retries").should("have.value", accounts[0].retries);
        // cy.get("#status_update_no").should("be.checked");
        // cy.get("#timeout").should("have.value", accounts[0].timeout);

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/sip2/accounts/*", req => {
            req.reply({
                statusCode: 500,
                delay: 1000,
            });
        }).as("edit-account");
        cy.get("#accounts_add").contains("Submit").click();
        cy.get("main div[class='modal_centered']").contains("Submitting...");
        cy.wait("@edit-account");
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/sip2/accounts/*", {
            statusCode: 200,
            body: account,
        });
        cy.get("#accounts_add").contains("Submit").click();
        cy.get("main div[class='alert alert-info']").contains(
            "Account updated"
        );
    });

    it("Show account", () => {
        let account = get_account();
        let accounts = [account];
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/sip2/accounts*", {
            statusCode: 200,
            body: accounts,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-accounts");
        cy.intercept("GET", "/api/v1/sip2/accounts/*", account).as(
            "get-account"
        );
        cy.visit("/cgi-bin/koha/sip2/accounts");
        cy.wait("@get-accounts");
        let name_link = cy.get(
            "#accounts_list table tbody tr:first td:first a"
        );
        name_link.should("have.text", account.login_id);
        name_link.click();
        cy.wait("@get-account");
        cy.get("#accounts_show h2").contains(
            "Account #" + account.sip_account_id
        );
        cy.left_menu_active_item_is("Accounts");
    });

    it("Delete account", () => {
        let account = get_account();
        let accounts = [account];

        // Delete from list
        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/sip2/accounts*", {
            statusCode: 200,
            body: accounts,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("get-accounts");
        cy.intercept("GET", "/api/v1/sip2/accounts/*", account);
        cy.visit("/cgi-bin/koha/sip2/accounts");

        cy.get("#accounts_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this account"
        );
        cy.contains(account.login_id);

        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/sip2/accounts/*", {
            statusCode: 500,
        });
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Internal Server Error"
        );

        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/sip2/accounts/*", {
            statusCode: 204,
            body: null,
        });
        cy.get("#accounts_list table tbody tr:first")
            .contains("Delete")
            .click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this account"
        );
        cy.contains("Yes, delete").click();
        cy.get("main div[class='alert alert-info']")
            .contains("Account")
            .contains("deleted");

        // Delete from show
        // Click the "name" link from the list
        cy.visit("/cgi-bin/koha/sip2/accounts");
        cy.wait("@get-accounts");
        cy.intercept("GET", "/api/v1/sip2/accounts/*", account).as(
            "get-account"
        );
        let name_link = cy.get(
            "#accounts_list table tbody tr:first td:first a"
        );
        name_link.should("have.text", account.login_id);
        name_link.click();
        cy.wait("@get-account");
        cy.get("#accounts_show h2").contains(
            "Account #" + account.sip_account_id
        );

        cy.get("#accounts_show #toolbar").contains("Delete").click();
        cy.get(".alert-warning.confirmation h1").contains(
            "remove this account"
        );
        cy.contains("Yes, delete").click();

        //Make sure we return to list after deleting from show
        cy.get("#accounts_list table tbody tr:first");
    });
});
