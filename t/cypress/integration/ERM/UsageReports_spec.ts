import { mount } from "@cypress/vue"

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

        const dataProviders = cy.get_multiple_providers()
        const defaultReport = cy.get_default_report()
        const defaultReports = [defaultReport]

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
            body: defaultReports,
            headers: {
                "X-Base-Total-Count": "1",
                "X-Total-Count": "1",
            },
        })

        cy.visit("/cgi-bin/koha/erm/eusage/reports")
        cy.get("#usage_data_providerstabs").contains("Create report").click()
    })

    it("Should limit report types based on the provider(s) selected", () => {
        const dataProviders = cy.get_multiple_providers()
        cy.get('#report_type').find('.vs__actions').click()
        cy.get('#report_type').find('li').as('options')
        cy.get('@options').should('have.length', 16)

        cy.get("#usage_data_provider .vs__search").type(
            dataProviders[0].name + "{enter}",
            { force: true }
        )
        cy.get('#report_type').find('.vs__actions').click()
        cy.get('#report_type').find('li').as('options')
        cy.get('@options').should('have.length', 1)
        
        cy.get("#usage_data_provider .vs__search").type(
            dataProviders[1].name + "{enter}",
            { force: true }
        )
        cy.get('#report_type').find('.vs__actions').click()
        cy.get('#report_type').find('li').as('options')
        cy.get('@options').should('have.length', 3)
    })

    it("Should limit data providers based on the report type(s) selected", () => {
        cy.get('#usage_data_provider').find('.vs__actions').click()
        cy.get('#usage_data_provider').find('li').as('options')
        cy.get('@options').should('have.length', 2)

        cy.get("#report_type .vs__search").type(
            "TR_J2" + "{enter}",
            { force: true }
        )
        cy.get('#usage_data_provider').find('.vs__actions').click()
        cy.get('#usage_data_provider').find('li').as('options')
        cy.get('@options').should('have.length', 1)
        
        cy.get("#report_type .vs__search").type(
            "TR_J1" + "{enter}",
            { force: true }
        )
        cy.get('#usage_data_provider').find('.vs__actions').click()
        cy.get('#usage_data_provider').find('li').as('options')
        cy.get('@options').should('have.length', 2)
    })

    it("Should limit metric types based on the report type(s) selected", () => {
        cy.get("#metric_type .vs__search").should('be.disabled')

        cy.get("#report_type .vs__search").type(
            "TR_J1" + "{enter}",
            { force: true }
        )
        cy.get('#metric_type').find('.vs__actions').click()
        cy.get('#metric_type').find('li').as('options')
        cy.get('@options').should('have.length', 2)
        
        cy.get("#report_type .vs__search").type(
            "PR" + "{enter}",
            { force: true }
        )
        cy.get('#metric_type').find('.vs__actions').click()
        cy.get('#metric_type').find('li').as('options')
        cy.get('@options').should('have.length', 7)
    })

    it("Should disable the month selectors when a yearly report is selected", () => {
        cy.get("#interval .vs__search").type(
            "By year" + "{enter}",
            { force: true }
        )

        cy.get("#start-month .vs__search").should('be.disabled')
        cy.get("#end_month .vs__search").should('be.disabled')
    })
})