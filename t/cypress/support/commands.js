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

Cypress.Commands.add('set_ERM_sys_pref_value', (enable) => {
    cy.visit('/cgi-bin/koha/admin/admin-home.pl')
    cy.get("h4").contains("Global system preferences").click();
    cy.get("a[title^=E-resource]").contains("E-resource management").click();
    cy.get('#pref_ERMModule').then(($select) => {
        // Only enable if currently disabled, or only disable if currently enabled
        let sys_pref_value = $select.find(":selected").text().trim();
        if (enable && sys_pref_value == 'Disable' || !enable && sys_pref_value == 'Enable') {
            cy.get("#pref_ERMModule").select(enable ? 'Enable' : 'Disable');
            cy.get(".save-all").first().click();
            Cypress.env("current_ERM_Module_sys_pref_value", enable);
            cy.wait(500); // Cypress is too fast!
        }
    })
})

Cypress.Commands.add('fetch_initial_ERM_sys_pref_value', () => {
    cy.login();
    cy.visit('/cgi-bin/koha/admin/admin-home.pl')
    cy.get("h4").contains("Global system preferences").click();
    cy.get("a[title^=E-resource]").contains("E-resource management").click();
    cy.get('#pref_ERMModule').then(($select) => {
        Cypress.env('initial_ERM_Module_sys_pref_value', $select.find(":selected").text().trim() == 'Enable');
    })
})

Cypress.Commands.add('reset_initial_ERM_sys_pref_value', () => {
    cy.login();
    cy.set_ERM_sys_pref_value(Cypress.env("initial_ERM_Module_sys_pref_value"));
})
