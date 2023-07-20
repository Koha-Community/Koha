// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })

function get_fallback_login_value(param) {

    var env_var = param == 'username' ? 'KOHA_USER' : 'KOHA_PASS';

    return typeof Cypress.env(env_var) === 'undefined' ? 'koha' : Cypress.env(env_var);
}

Cypress.Commands.add('login', (username, password) => {
    var user = typeof username === 'undefined' ? get_fallback_login_value('username') : username;
    var pass = typeof password === 'undefined' ? get_fallback_login_value('password') : password;
    cy.visit('/cgi-bin/koha/mainpage.pl?logout.x=1')
    cy.get("#userid").type(user)
    cy.get("#password").type(pass)
    cy.get("#submit-button").click()
})

Cypress.Commands.add('left_menu_active_item_is', (label) => {
    cy.get("#navmenulist a.current:not(.disabled)").should('have.length',1).contains(label);
})

cy.get_title = () => {
    return {
        access_type: "access type",
        biblio_id: null,
        coverage_depth: "coverage depth",
        date_first_issue_online: "date first",
        date_last_issue_online: "date last",
        date_monograph_published_online: "date mono online",
        date_monograph_published_print: "date mono print",
        embargo_info: "embargo info",
        external_id: "",
        first_author: "first author",
        first_editor: "first editor",
        monograph_edition: "monograph edition",
        monograph_volume: "monograph volume",
        notes: "notes",
        num_first_issue_online: "num first issue",
        num_first_vol_online: "num first vol",
        num_last_issue_online: "num last issue",
        num_last_vol_online: "num last vol",
        online_identifier: "online identifier",
        parent_publication_title_id: "parent id",
        preceeding_publication_title_id: "preceeding id",
        print_identifier: "print identifier",
        publication_title: "publication title",
        publication_type: "journal",
        publisher_name: "publication name",
        resources: [
            {
                ended_on: null,
                package: {
                    content_type: "",
                    package_id: 1,
                    name: "first package name"
                },
                package_id: 1,
                resource_id: 2,
                title: {
                    biblio_id: 439,
                    title_id: 1,
                },
                title_id: 1
            }
        ],
        title_id: 1,
        title_url: "title url"
      };
}

cy.get_agreements_to_relate = () => {
    return [
        {
            agreement_id: 2,
            description: "a second agreement",
            name: "second agreement name"
        },
        {
            agreement_id: 3,
            description: "a third agreement",
            name: "third agreement name"
        },
        {
            agreement_id: 4,
            description: "a fourth agreement",
            name: "fourth agreement name"
        },
    ]
}
