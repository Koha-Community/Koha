import { mount } from "@cypress/vue";

function get_supplying_request() {
    return {
        iso18626_request_id: 1,
        iso18626_requesting_agency_id: 1,
        status: "RequestReceived",
        service_type: "Loan",
        pending_requesting_agency_action: null,
        created_on: "2024-01-01T00:00:00+00:00",
        updated_on: "2024-01-01T00:00:00+00:00",
        requestingAgencyRequestId: "RA-001",
        biblio_id: null,
        hold_id: null,
        issue_id: null,
        requesting_agency: {
            iso18626_requesting_agency_id: 1,
            name: "Test Agency",
            patron_id: 1,
        },
    };
}

function get_message(id, type, content) {
    return {
        iso18626_message_id: id,
        iso18626_request_id: 1,
        type: type,
        content: JSON.stringify(content),
        timestamp: "2024-01-01T00:00:00+00:00",
    };
}

describe("Supplying ILL Requests operations", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
        cy.set_syspref("ILLModule", 1);
    });

    it("List supplying requests", () => {
        // GET supplying requests returns 500
        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 500,
        });
        cy.visit("/cgi-bin/koha/ill/ill.pl");
        cy.get(".sidebar_menu").contains("Supplying ILLs").click();
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong"
        );

        // GET supplying requests returns empty list
        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", []);
        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.get("#iso18626_requests_list").contains(
            "There are no supplying ILLs defined"
        );

        // GET supplying requests returns populated list
        let request = get_supplying_request();
        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        });
        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.get("#iso18626_requests_list").contains(
            "Showing 1 to 1 of 1 entries"
        );
    });

    it("Show supplying request", () => {
        let request = get_supplying_request();

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            messages: [],
            hold: null,
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");

        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");
        cy.get("#iso18626_requests_show h2").contains(
            "Supplying ILL #" + request.iso18626_request_id
        );
    });

    it("Displays ISO18626 messages", () => {
        let request = get_supplying_request();

        const statusChangeMsg = get_message(1, "statusChange", {
            statusChange: { action: "Loaned" },
        });
        const confirmationMsg = get_message(
            2,
            "requestingAgencyMessageConfirmation",
            { requestingAgencyMessageConfirmation: {} }
        );

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold: null,
            messages: [statusChangeMsg, confirmationMsg],
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");

        // By default, confirmation messages are hidden
        cy.get("#iso18626_messages tbody tr").should("have.length", 1);

        // Information column shows parsed message action
        cy.get("#iso18626_messages tbody tr:first td:nth-child(2)").should(
            "contain",
            "Action: Loaned"
        );

        // View message button exists in each row
        cy.get("#iso18626_messages tbody tr:first").contains("View message");

        // Checking "Show confirmations" reveals the confirmation message
        cy.get("#showConfirmationRows").click();
        cy.get("#iso18626_messages tbody tr").should("have.length", 2);
    });

    it("Shows correct action buttons for Loan service type", () => {
        let request = get_supplying_request(); // service_type: "Loan"

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold: null,
            messages: [],
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");

        // PlaceHold shown for Loan with no linked biblio (search to hold)
        cy.get("#iso18626_requests_show").contains(
            "Expect to supply (Search to hold)"
        );
        // RetryPossible and Unfilled are always shown
        cy.get("#iso18626_requests_show").contains("Ask for retry");
        cy.get("#iso18626_requests_show").contains("Unfilled");

        // ExpectToSupply (copy) and CopyCompleted are hidden for Loan
        cy.get("#iso18626_requests_show").should(
            "not.contain",
            "Expect to supply copy"
        );
        cy.get("#iso18626_requests_show").should(
            "not.contain",
            "Copy completed"
        );

        // Cancel is hidden when there is no pending cancellation action
        cy.get("#iso18626_requests_show").should("not.contain", "Cancel");

        // Complete loan is hidden when there is no active checkout
        cy.get("#iso18626_requests_show").should(
            "not.contain",
            "Complete loan (Check in)"
        );

        // PlaceHold shows "Place hold" label when a biblio is already linked
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            biblio_id: 42,
            hold: null,
            messages: [],
        }).as("getRequestWithBiblio");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequestWithBiblio");

        cy.get("#iso18626_requests_show").contains(
            "Expect to supply (Place hold)"
        );
        cy.get("#iso18626_requests_show").should(
            "not.contain",
            "Expect to supply (Search to hold)"
        );
    });

    it("Shows correct action buttons for Copy service type", () => {
        let request = { ...get_supplying_request(), service_type: "Copy" };

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold: null,
            messages: [],
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");

        // ExpectToSupply (copy) and CopyCompleted are shown for Copy
        cy.get("#iso18626_requests_show").contains("Expect to supply copy");
        cy.get("#iso18626_requests_show").contains("Copy completed");

        // PlaceHold is hidden for Copy service type
        cy.get("#iso18626_requests_show").should(
            "not.contain",
            "Expect to supply (Search to hold)"
        );
        cy.get("#iso18626_requests_show").should(
            "not.contain",
            "Expect to supply (Place hold)"
        );
    });

    it("Shows Cancel button when a cancellation is pending", () => {
        let request = {
            ...get_supplying_request(),
            pending_requesting_agency_action: "Cancel",
        };

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold: null,
            messages: [],
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");

        // Cancel button appears when pending_requesting_agency_action is "Cancel"
        cy.get("#iso18626_requests_show").contains("Cancel");
    });

    it("Displays circulation information", () => {
        let request = get_supplying_request();

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");

        // No active hold or checkout
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold: null,
            messages: [],
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");

        cy.contains("label", "Active hold on biblio")
            .next()
            .should("contain", "No");
        cy.contains("label", "Active hold on item")
            .next()
            .should("contain", "No");
        cy.contains("label", "Active checkout").next().should("contain", "No");

        // Active hold on biblio, hold on item, and active checkout
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold_id: 42,
            hold: { item_id: 10 },
            issue_id: 99,
            messages: [],
        }).as("getRequestWithCirc");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequestWithCirc");

        cy.contains("label", "Active hold on biblio")
            .next()
            .should("contain", "Yes");
        cy.contains("label", "Active hold on item")
            .next()
            .should("contain", "Yes");
        cy.contains("label", "Active checkout").next().should("contain", "Yes");
    });

    it("Shows error banner when progressing status fails", () => {
        let request = get_supplying_request();

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold: null,
            messages: [],
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");

        cy.intercept("PATCH", "/api/v1/ill/iso18626_requests/*", {
            statusCode: 500,
            body: { error: "Request could not be progressed" },
        }).as("patchRequest");

        cy.get("#iso18626_requests_show").contains("Unfilled").click();
        cy.get("#confirmation #reasonUnfilled .vs__search").type(
            "Not held{enter}",
            { force: true }
        );
        cy.get("#accept_modal").click();
        cy.wait("@patchRequest");
        cy.get("main div[class='alert alert-warning']").contains(
            "Something went wrong: Error: Request could not be progressed"
        );
    });

    it("Progresses status via the RetryPossible modal", () => {
        let request = get_supplying_request();

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold: null,
            messages: [],
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");

        // Open the RetryPossible modal
        cy.get("#iso18626_requests_show").contains("Ask for retry").click();
        cy.get("#confirmation").should("exist");
        cy.get("#confirmation h1").contains("RetryPossible");
        cy.get("#confirmation .modal-body").contains(
            "The supplying library cannot fill the request based on information provided"
        );

        // Submitting without the required reason keeps the dialog open
        cy.get("#accept_modal").click();
        cy.get("#confirmation").should("exist");
        cy.get("#confirmation input:invalid").should("exist");

        // Select a reason and confirm
        cy.get("#confirmation #reasonRetry .vs__search").type(
            "At bindery{enter}",
            { force: true }
        );

        cy.intercept("PATCH", "/api/v1/ill/iso18626_requests/*", {
            statusCode: 200,
            body: { ...request, status: "RetryPossible" },
        }).as("patchRequest");

        cy.get("#accept_modal").click();
        cy.wait("@patchRequest");
        cy.get("main div[class='alert alert-info']").contains(
            "ISO18626 request #1 updated"
        );
    });

    it("Disables action buttons while a status change is in flight", () => {
        let request = get_supplying_request();

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold: null,
            messages: [],
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");

        // Intercept PATCH with a delay so we can assert mid-flight UI state
        cy.intercept("PATCH", "/api/v1/ill/iso18626_requests/*", {
            delay: 1500,
            statusCode: 200,
            body: { ...request, status: "Unfilled" },
        }).as("patchRequest");

        // Open the Unfilled modal, select a reason, and confirm
        cy.get("#iso18626_requests_show").contains("Unfilled").click();
        cy.get("#confirmation #reasonUnfilled .vs__search").type(
            "Not held{enter}",
            { force: true }
        );
        cy.get("#accept_modal").click();

        // While the PATCH is in-flight, action buttons should have the disabled class
        cy.get("#iso18626_requests_show")
            .contains("Ask for retry")
            .should("have.class", "disabled");
        cy.get("#iso18626_requests_show")
            .contains("Unfilled")
            .should("have.class", "disabled");

        // After the PATCH resolves, buttons should be enabled again
        cy.wait("@patchRequest");
        cy.get("#iso18626_requests_show")
            .contains("Ask for retry")
            .should("not.have.class", "disabled");
        cy.get("#iso18626_requests_show")
            .contains("Unfilled")
            .should("not.have.class", "disabled");
    });

    it("Progresses status via the Unfilled modal", () => {
        let request = get_supplying_request();

        cy.intercept("GET", "/api/v1/ill/iso18626_requests*", {
            statusCode: 200,
            body: [request],
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        }).as("getRequests");
        cy.intercept("GET", "/api/v1/ill/iso18626_requests/*", {
            ...request,
            hold: null,
            messages: [],
        }).as("getRequest");

        cy.visit("/cgi-bin/koha/ill/iso18626_requests");
        cy.wait("@getRequests");
        cy.get(
            "#iso18626_requests_list table tbody tr:first td:first a"
        ).click();
        cy.wait("@getRequest");

        // Open the Unfilled modal
        cy.get("#iso18626_requests_show").contains("Unfilled").click();
        cy.get("#confirmation").should("exist");
        cy.get("#confirmation h1").contains("Unfilled");

        // Select a reason and confirm
        cy.get("#confirmation #reasonUnfilled .vs__search").type(
            "Not held{enter}",
            { force: true }
        );

        cy.intercept("PATCH", "/api/v1/ill/iso18626_requests/*", {
            statusCode: 200,
            body: { ...request, status: "Unfilled" },
        }).as("patchRequest");

        cy.get("#accept_modal").click();
        cy.wait("@patchRequest");
        cy.get("main div[class='alert alert-info']").contains(
            "ISO18626 request #1 updated"
        );
    });
});
