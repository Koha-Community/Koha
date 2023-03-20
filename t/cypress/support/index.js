// ***********************************************************
// This example support/index.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
import './commands';

// Alternatively you can use CommonJS syntax:
// require('./commands')

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