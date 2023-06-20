import { mount } from "@cypress/vue"

const dayjs = require("dayjs")

const dates = {
    today_iso: dayjs().format("YYYY-MM-DD"),
    today_us: dayjs().format("MM/DD/YYYY"),
    tomorrow_iso: dayjs().add(1, "day").format("YYYY-MM-DD"),
    tomorrow_us: dayjs().add(1, "day").format("MM/DD/YYYY"),
}

describe("Reports home tabs", () => {
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
        const defaultReport = cy.get_default_report()
        const defaulReports = [defaultReport]

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.intercept("GET", "/api/v1/erm/default_usage_reports*", {
            statusCode: 200,
            body: defaulReports,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })

        cy.visit("/cgi-bin/koha/erm/eusage/reports")
    })

    it("Should display the saved reports page", () => {
        cy.get("#report_builder .default-report h2")
        .should('have.text', "Select saved report")
    })

    it("Should display the custom report builder", () => {
        cy.get("#usage_data_providerstabs").contains("Create report").click()

        cy.get("#report-builder h2")
        .should('have.text', "Build a custom report")
    })
})

describe("Saved reports", () => {
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
        const defaultReport = cy.get_default_report()
        const defaulReports = [defaultReport]

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.intercept("GET", "/api/v1/erm/default_usage_reports*", {
            statusCode: 200,
            body: defaulReports,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })

        cy.visit("/cgi-bin/koha/erm/eusage/reports")
    })

    it("Should correctly populate the dropdown menu", () => {
        const defaultReport = cy.get_default_report()

        cy.get("#default_usage_reports .vs__open-indicator").click()
        cy.get("#default_usage_reports .vs__dropdown-menu li:first").should(
            "have.text", defaultReport.report_name
        )
    })

    it("Should redirect to the reports viewer with the correct url params", () => {
        const defaultReport = cy.get_default_report()

        cy.get("#default_usage_reports .vs__search").type(
            defaultReport.report_name + "{enter}", 
            { force: true }
        )
        
        cy.get("#report_builder .default-report .action input").click()

        cy.url({ decode: true }).then(url => {
            const urlParams = url.split('viewer?')[1].split('data=')[1]
            const reportParams = defaultReport.report_url_params

            expect(urlParams).to.eq(reportParams)
        })
    })
})

describe("Custom reports", () => {
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
        const defaultReport = cy.get_default_report()
        const defaulReports = [defaultReport]

        cy.intercept("GET", "/api/v1/erm/usage_data_providers*", {
            statusCode: 200,
            body: dataProviders,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })
        cy.intercept("GET", "/api/v1/erm/default_usage_reports*", {
            statusCode: 200,
            body: defaulReports,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })

        cy.visit("/cgi-bin/koha/erm/eusage/reports")
    })

    it("Should offer options to create and display custom reports", () => {
        // ToDo
    })
})