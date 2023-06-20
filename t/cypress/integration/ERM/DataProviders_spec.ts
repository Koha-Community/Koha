import { mount } from "@cypress/vue"
import { data } from "cypress/types/jquery"

const dayjs = require("dayjs") 

const dates = {
    today_iso: dayjs().format("YYYY-MM-DD"),
    today_us: dayjs().format("MM/DD/YYYY"),
    tomorrow_iso: dayjs().add(1, "day").format("YYYY-MM-DD"),
    tomorrow_us: dayjs().add(1, "day").format("MM/DD/YYYY"),
}

describe("Data provider CRUD operations", () => {
    beforeEach(() => {
        cy.login()
        cy.title().should("eq", "Koha staff interface")
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMModule",
            '{"value":"1"}'
        )
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMProviders",
            '{"value":"local"}'
        )
    })

    it("Should list providers", () => {
        // GET usage_data_providers returns 500
        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 500,
            error: "Something went wrong",
        })
        cy.visit("/cgi-bin/koha/erm/erm.pl")
        cy.get("#navmenulist").contains("Data providers").click()
        cy.get("main div[class='dialog alert']").contains(
            /Something went wrong/
        )

        // GET usage_data_providers returns empty list
        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", [])
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")
        cy.get("#usage_data_providers_list").contains("There are no usage data providers defined")

        const dataProvider = cy.get_usage_data_provider()
        const dataProviders = [dataProvider]

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.intercept("GET", "/api/v1/erm/usage_data_providers/*", dataProvider)
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")
        cy.get("#usage_data_providers_list").contains("Showing 1 to 1 of 1 entries")
    })

    it("Should add provider", () => {
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")
        cy.contains("New data provider").click()
        cy.get("#data_providers_add h2").contains("New usage data provider")

        const dataProvider = cy.get_usage_data_provider()

        cy.get("#data_providers_add").contains("Submit").click()
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            6
        )
        
        // Fill in text inputs
        cy.get("#usage_data_provider_name").type(dataProvider.name)
        cy.get("#usage_data_provider_description").type(dataProvider.description)
        cy.get("#usage_data_provider_service_type").type(dataProvider.service_type)
        cy.get("#usage_data_provider_service_url").type(dataProvider.service_url)
        cy.get("#usage_data_provider_report_release").type(dataProvider.report_release)
        cy.get("#usage_data_provider_customer_id").type(dataProvider.customer_id)
        cy.get("#usage_data_provider_requestor_id").type(dataProvider.requestor_id)
        cy.get("#usage_data_provider_api_key").type(dataProvider.api_key)
        cy.get("#usage_data_provider_requestor_name").type(dataProvider.requestor_name)
        cy.get("#usage_data_provider_requestor_email").type(dataProvider.requestor_email)

        cy.get("#data_providers_add").contains("Submit").click()
        cy.get("input:invalid,textarea:invalid,select:invalid").should(
            "have.length",
            1
        )

        // Fill in status and report types
        cy.get("#harvester_status .vs__search").type(
            dataProvider.active + "{enter}",
            { force: true }
        )
        cy.get("#report_type .vs__search").type(
            dataProvider.report_types.slice(0, -1) + "{enter}",
            { force: true }
        )

        // Fill in start and end dates
        cy.get("#usage_data_provider_begin_date+input").click()
        cy.get(".flatpickr-calendar")
            .eq(1)
            .find("span.today")
            .click({ force: true })
        cy.get("#usage_data_provider_end_date+input").click()
        cy.get(".flatpickr-calendar")
            .eq(1)
            .find("span.today")
            .next("span")
            .click({ force: true })

        // Submit the form, get 500
        cy.intercept("POST", "/api/v1/erm/usage_data_providers", {
            statusCode: 500,
            error: "Something went wrong",
        })
        cy.get("#data_providers_add").contains("Submit").click()
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Error: Internal Server Error"
        )

        // Submit the form, success!
        cy.intercept("POST", "/api/v1/erm/usage_data_providers", {
            statusCode: 201,
            body: dataProvider,
        })
        cy.get("#data_providers_add").contains("Submit").click()
        cy.get("main div[class='dialog message']").contains(
            "Data provider created"
        )

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: [dataProvider],
        })
    })

    it("Should edit provider", () => {
        const dataProvider = cy.get_usage_data_provider()
        const dataProviders = [dataProvider]

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.intercept("GET", "/api/v1/erm/usage_data_providers/*", dataProvider).as(
            "get-data-provider"
        )
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")
        cy.get("#usage_data_providers_list table tbody tr:first").contains("Edit").click()
        cy.wait("@get-data-provider")
        cy.wait(500) // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#data_providers_add h2").contains("Edit usage data provider")

        // Form has been correctly filled in
        cy.get("#usage_data_provider_name").should("have.value", dataProvider.name)
        cy.get("#usage_data_provider_description").should("have.value", dataProvider.description)
        cy.get("#usage_data_provider_service_type").should("have.value", dataProvider.service_type)
        cy.get("#usage_data_provider_service_url").should("have.value", dataProvider.service_url)
        cy.get("#usage_data_provider_report_release").should("have.value", dataProvider.report_release)
        cy.get("#usage_data_provider_customer_id").should("have.value", dataProvider.customer_id)
        cy.get("#usage_data_provider_requestor_id").should("have.value", dataProvider.requestor_id)
        cy.get("#usage_data_provider_api_key").should("have.value", dataProvider.api_key)
        cy.get("#usage_data_provider_requestor_name").should("have.value", dataProvider.requestor_name)
        cy.get("#usage_data_provider_requestor_email").should("have.value", dataProvider.requestor_email)

        cy.get("#harvester_status .vs__selected").contains("Active")
        cy.get("#report_type .vs__selected").contains("TR_J1")
        cy.get("#usage_data_provider_begin_date").invoke("val").should("eq", dates["today_iso"])
        cy.get("#usage_data_provider_end_date").invoke("val").should("eq", dates["tomorrow_iso"])

        // Submit the form, get 500
        cy.intercept("PUT", "/api/v1/erm/usage_data_providers/*", {
            statusCode: 500,
            error: "Something went wrong",
        })
        cy.get("#data_providers_add").contains("Submit").click()
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Error: Internal Server Error"
        )
        // Submit the form, success!
        cy.intercept("PUT", "/api/v1/erm/usage_data_providers/*", {
            statusCode: 200,
            body: dataProvider,
        })
        cy.get("#data_providers_add").contains("Submit").click()
        cy.get("main div[class='dialog message']").contains("Data provider updated")
    })

    it("Should show provider", () => {
        const dataProvider = cy.get_usage_data_provider()
        const dataProviders = [dataProvider]

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.intercept("GET", "/api/v1/erm/usage_data_providers/*", dataProvider).as(
            "get-data-provider"
        )
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")
        let name_link = cy.get(
            "#usage_data_providers_list table tbody tr:first td:first a"
        )
        name_link.should(
            "have.text",
            dataProvider.name + " (#" + dataProvider.erm_usage_data_provider_id + ")"
        )
        name_link.click()
        cy.wait("@get-data-provider")
        cy.wait(500) // Cypress is too fast! Vue hasn't populated the form yet!
        cy.get("#usage_data_providers_show h2").contains("Data provider #" + dataProvider.erm_usage_data_provider_id)
    })

    it("Should delete provider", () => {
        const dataProvider = cy.get_usage_data_provider()
        const dataProviders = [dataProvider]
        
        // Click the 'Delete' button from the list
        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.intercept("GET", "/api/v1/erm/usage_data_providers/*", dataProvider).as(
            "get-data-provider"
        )
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")
    
        cy.get("#usage_data_providers_list table tbody tr:first").contains("Delete").click()
        cy.get(".dialog.alert.confirmation h1").contains("remove this data provider")
        cy.contains(dataProvider.name)
    
        // Accept the confirmation dialog, get 500
        cy.intercept("DELETE", "/api/v1/erm/usage_data_providers/*", {
            statusCode: 500,
            error: "Something went wrong",
        })
        cy.contains("Yes, delete").click()
        cy.get("main div[class='dialog alert']").contains(
            "Something went wrong: Error: Internal Server Error"
        )
    
        // Accept the confirmation dialog, success!
        cy.intercept("DELETE", "/api/v1/erm/usage_data_providers/*", {
            statusCode: 204,
            body: null,
        })
        cy.get("#usage_data_providers_list table tbody tr:first")
            .contains("Delete")
            .click()
        cy.get(".dialog.alert.confirmation h1").contains("remove this data provider")
        cy.contains("Yes, delete").click()
        cy.get("main div[class='dialog message']")
            .contains("Data provider")
            .contains("deleted")
    
        // Delete from show
        // Click the "name" link from the list
        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.intercept("GET", "/api/v1/erm/usage_data_providers/*", dataProvider).as(
            "get-data-provider"
        )
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")
        let name_link = cy.get(
            "#usage_data_providers_list table tbody tr:first td:first a"
        )
        name_link.should(
            "have.text",
            dataProvider.name + " (#" + dataProvider.erm_usage_data_provider_id + ")"
        )
        name_link.click()
        cy.wait("@get-data-provider")
        cy.wait(500)
        cy.get("#usage_data_providers_show h2").contains("Data provider #" + dataProvider.erm_usage_data_provider_id)
    
        cy.get("#usage_data_providers_show .action_links .fa-trash").click()
        cy.get(".dialog.alert.confirmation h1").contains("remove this data provider")
        cy.contains("Yes, delete").click()
    
        //Make sure we return to list after deleting from show
        cy.get("#usage_data_providers_list table tbody tr:first")
    })
})

describe("Data providers summary", () => {
    beforeEach(() => {
        cy.login()
        cy.title().should("eq", "Koha staff interface")
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMModule",
            '{"value":"1"}'
        )
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMProviders",
            '{"value":"local"}'
        )
    })

    it("Should navigate to the summary page and back to providers list", () => {
        const dataProvider = cy.get_usage_data_provider()
        const dataProviders = [dataProvider]

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")

        cy.contains("Data providers summary").click()
        cy.get("#usage_data_providers_summary").contains("Showing 1 to 1 of 1 entries")

        cy.contains("Data providers list").click()
        cy.get("#usage_data_providers_list").contains("Showing 1 to 1 of 1 entries")

    })

    it("Should correctly display dates", () => {
        const dataProvider = cy.get_usage_data_provider()
        const dataProviders = [dataProvider]

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")

        cy.contains("Data providers summary").click()

        // Check provider name
        cy.get("#usage_data_providers_summary table tbody tr:first td:first").should(
            "have.text",
            dataProvider.name
        )

        // Check start and end dates
        const startDate = dataProvider.counter_files[0].date_uploaded.substr(0,10)
        const endDate = dataProvider.counter_files[1].date_uploaded.substr(0,10)

        cy.get("#usage_data_providers_summary table tbody tr:first td:nth-child(2)").should(
            "have.text",
            startDate
        )
        cy.get("#usage_data_providers_summary table tbody tr:first td:nth-child(3)").should(
            "have.text",
            endDate
        )
        // Check "Not run" harvests
        cy.get("#usage_data_providers_summary table tbody tr:first td:nth-child(4)").should(
            "have.text",
            "Not run"
        )
    })
})

describe("Data provider tab options", () => {
    beforeEach(() => {
        cy.login()
        cy.title().should("eq", "Koha staff interface")
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMModule",
            '{"value":"1"}'
        )
        cy.intercept(
            "GET",
            "/cgi-bin/koha/svc/config/systempreferences/?pref=ERMProviders",
            '{"value":"local"}'
        )

        const dataProvider = cy.get_usage_data_provider()
        const dataProviders = [dataProvider]

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.intercept("GET", "/api/v1/erm/usage_data_providers/*", dataProvider).as(
            "get-data-provider"
        )
        cy.visit("/cgi-bin/koha/erm/eusage/usage_data_providers")
        let name_link = cy.get(
            "#usage_data_providers_list table tbody tr:first td:first a"
        )
        name_link.should(
            "have.text",
            dataProvider.name + " (#" + dataProvider.erm_usage_data_provider_id + ")"
        )
        name_link.click()
        cy.wait("@get-data-provider")
        cy.wait(500)
    })

    it("Should display provider details", () => {
        const dataProvider = cy.get_usage_data_provider()
        const dataProviders = [dataProvider]

        cy.get("#usage_data_providers_show > div.tab-content > div > legend:nth-child(1)").should(
            "have.text",
            "Data provider"
        )

        //Page should be populated correctly
        cy.get("#usage_data_provider_name").should("have.text", dataProvider.name)
        cy.get("#usage_data_provider_description").should("have.text", dataProvider.description)
        cy.get("#usage_data_provider_service_type").should("have.text", dataProvider.service_type)
        cy.get("#usage_data_provider_service_url").should("have.text", dataProvider.service_url)
        cy.get("#usage_data_provider_report_release").should("have.text", dataProvider.report_release)
        cy.get("#usage_data_provider_customer_id").should("have.text", dataProvider.customer_id)
        cy.get("#usage_data_provider_requestor_id").should("have.text", dataProvider.requestor_id)
        cy.get("#usage_data_provider_api_key").should("have.text", dataProvider.api_key)
        cy.get("#usage_data_provider_requestor_name").should("have.text", dataProvider.requestor_name)
        cy.get("#usage_data_provider_requestor_email").should("have.text", dataProvider.requestor_email)
        cy.get("#harvester_status").should("have.text", dataProvider.active ? "Active" : "Inactive")
        cy.get("#report_type").should("have.text", dataProvider.report_types)
        cy.get("#usage_data_provider_begin_date").should("have.text", dataProvider.begin_date)
        cy.get("#usage_data_provider_end_date").should("have.text", dataProvider.end_date)
    })

    it("Should display titles", () => {
        cy.intercept("GET", "/api/v1/erm/usage_titles*", {
            statusCode: 200,
            body: [],
            headers: {
                "X-Base-Total-Count": "0",
                "X-Total-Count": "0",
            },
        })

        cy.get("#usage_data_providerstabs").contains("Titles").click()
        cy.get("main div[class='dialog message']").should(
            "have.text", "No title data has been harvested for this provider"
        )

        cy.get("#usage_data_providerstabs").contains("Detail").click()
        
        const title = cy.get_usage_title()
        const titles = [title]
        cy.intercept("GET", "/api/v1/erm/usage_titles*", {
            statusCode: 200,
            body: titles,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        
        cy.get("#usage_data_providerstabs").contains("Titles").click()
        cy.get("#titles_list").contains("Showing 1 to 1 of 1 entries")
    })

    it("Should allow manual file upload", () => {
        cy.get("#usage_data_providerstabs").contains("Manual upload").click()
        cy.get("#files h2").should("have.text", "Manual upload:")

        cy.get("#import_file").click()
        cy.get("#import_file").selectFile(
            "t/cypress/fixtures/file.json"
        )
        cy.get("#files .file_information span").contains("file.json")
    })

    it("Should display import logs", () => {
        cy.intercept("GET", "/api/v1/erm/counter_files*", {
            statusCode: 200,
            body: [],
            headers: {
                "X-Base-Total-Count": "0",
                "X-Total-Count": "0",
            },
        })
        cy.get("#usage_data_providerstabs").contains("Import logs").click()
        cy.get("main div[class='dialog message']").should(
            "have.text", "There are no import logs defined"
        )

        cy.get("#usage_data_providerstabs").contains("Detail").click()
        
        const counter_file = cy.get_counter_file()
        const counter_files = [counter_file]
        cy.intercept("GET", "/api/v1/erm/counter_files*", {
            statusCode: 200,
            body: counter_files,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        
        cy.get("#usage_data_providerstabs").contains("Import logs").click()
        cy.get("#counter_logs_list").contains("Showing 1 to 1 of 1 entries")
    })
})