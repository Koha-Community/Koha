import { mount } from "@cypress/vue";

function get_server_params() {
    return [
        {
            key: "min_servers",
            sip_server_param_id: 1,
            value: "1",
        },
        {
            key: "min_spare_servers",
            sip_server_param_id: 2,
            value: "0",
        },
        {
            key: "max_servers",
            sip_server_param_id: 3,
            value: "1",
        },
        {
            key: "setsid",
            sip_server_param_id: 4,
            value: "1",
        },
        {
            key: "user",
            sip_server_param_id: 5,
            value: "koha",
        },
        {
            key: "group",
            sip_server_param_id: 6,
            value: "koha",
        },
        {
            key: "pid_file",
            sip_server_param_id: 7,
            value: "/var/run/sipserver.pid",
        },
        {
            key: "custom_tcp_keepalive",
            sip_server_param_id: 8,
            value: "0",
        },
        {
            key: "custom_tcp_keepalive_time",
            sip_server_param_id: 9,
            value: "7200",
        },
        {
            key: "custom_tcp_keepalive_intvl",
            sip_server_param_id: 10,
            value: "75",
        },
    ];
}

describe("ServerParams", () => {
    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");
    });

    it("Edit server params", () => {
        let server_params = get_server_params();

        // Intercept follow-up 'search' request after entering /system_preference_overrides
        cy.intercept("GET", "/api/v1/sip2/serverparams**", {
            statusCode: 200,
            body: server_params,
        }).as("get-server_params");
        cy.visit("/cgi-bin/koha/sip2/serverparams");
        cy.wait("@get-server_params");

        cy.left_menu_active_item_is("Server params");

        // Form has been correctly filled in
        cy.get("#min_servers").should(
            "have.value",
            server_params.find(p => p.key === "min_servers").value
        );
        cy.get("#min_spare_servers").should(
            "have.value",
            server_params.find(p => p.key === "min_spare_servers").value
        );
        cy.get("#max_servers").should(
            "have.value",
            server_params.find(p => p.key === "max_servers").value
        );
        cy.get("#setsid").should(
            "have.value",
            server_params.find(p => p.key === "setsid").value
        );
        cy.get("#user").should(
            "have.value",
            server_params.find(p => p.key === "user").value
        );
        cy.get("#group").should(
            "have.value",
            server_params.find(p => p.key === "group").value
        );
        cy.get("#pid_file").should(
            "have.value",
            server_params.find(p => p.key === "pid_file").value
        );
        cy.get("#custom_tcp_keepalive").should(
            "have.value",
            server_params.find(p => p.key === "custom_tcp_keepalive").value
        );
        cy.get("#custom_tcp_keepalive_time").should(
            "have.value",
            server_params.find(p => p.key === "custom_tcp_keepalive_time").value
        );
        cy.get("#custom_tcp_keepalive_intvl").should(
            "have.value",
            server_params.find(p => p.key === "custom_tcp_keepalive_intvl")
                .value
        );

        cy.intercept("PATCH", "/api/v1/sip2/serverparams", req => {
            req.reply({
                message: "Server params updated successfully",
            });
        });
        cy.get("#serverparams").contains("Submit").click();

        cy.get("main div[class='alert alert-info']").contains(
            "Server parameters updated"
        );
    });
});
