const pubmedid_metadata_response = {
    errors: [],
    results: {
        result: {
            header: {
                type: "esummary",
                version: "0.3",
            },
            result: {
                "123": {
                    articleids: [
                        {
                            idtype: "pubmed",
                            idtypen: 1,
                            value: "123",
                        },
                        {
                            idtype: "doi",
                            idtypen: 3,
                            value: "10.1002\/bjs.1800621024",
                        },
                    ],
                    attributes: ["Has Abstract"],
                    authors: [
                        {
                            authtype: "Author",
                            clusterid: "",
                            name: "Keighley MR",
                        },
                        {
                            authtype: "Author",
                            clusterid: "",
                            name: "Asquith P",
                        },
                        {
                            authtype: "Author",
                            clusterid: "",
                            name: "Edwards JA",
                        },
                        {
                            authtype: "Author",
                            clusterid: "",
                            name: "Alexander-Williams J",
                        },
                    ],
                    availablefromurl: "",
                    bookname: "",
                    booktitle: "",
                    chapter: "",
                    doccontriblist: [],
                    docdate: "",
                    doctype: "citation",
                    edition: "",
                    elocationid: "",
                    epubdate: "",
                    essn: "",
                    fulljournalname: "The British journal of surgery",
                    history: [
                        {
                            date: "1975\/10\/01 00:00",
                            pubstatus: "pubmed",
                        },
                        {
                            date: "1975\/10\/01 00:01",
                            pubstatus: "medline",
                        },
                        {
                            date: "1975\/10\/01 00:00",
                            pubstatus: "entrez",
                        },
                    ],
                    issn: "0007-1323",
                    issue: "10",
                    lang: ["eng"],
                    lastauthor: "Alexander-Williams J",
                    locationlabel: "",
                    medium: "",
                    nlmuniqueid: "0372553",
                    pages: "845-9",
                    pmcrefcount: "",
                    pubdate: "1975 Oct",
                    publisherlocation: "",
                    publishername: "",
                    pubstatus: "4",
                    pubtype: ["Journal Article"],
                    recordstatus: "PubMed - indexed for MEDLINE",
                    references: [],
                    reportnumber: "",
                    sortfirstauthor: "Keighley MR",
                    sortpubdate: "1975\/10\/01 00:00",
                    sorttitle:
                        "importance of an innervated and intact antrum and pylorus in preventing postoperative duodenogastric reflux and gastritis",
                    source: "Br J Surg",
                    srccontriblist: [],
                    srcdate: "",
                    title: "The importance of an innervated and intact antrum and pylorus in preventing postoperative duodenogastric reflux and gastritis.",
                    uid: "123",
                    vernaculartitle: "",
                    volume: "62",
                },
                uids: ["123"],
            },
        },
    },
};

const parse_to_ill_response = {
    errors: [],
    results: {
        result: {
            article_title:
                "The importance of an innervated and intact antrum and pylorus in preventing postoperative duodenogastric reflux and gastritis.",
            associated_id: "123",
            author: "Keighley MR; Asquith P; Edwards JA; Alexander-Williams J",
            issn: "0007-1323",
            issue: "10",
            pages: "845-9",
            publisher: "",
            pubmedid: "123",
            title: "The British journal of surgery",
            volume: "62",
            year: "1975",
        },
    },
};

const batchstatuses = [
    {
        code: "NEW",
        id: 1,
        is_system: true,
        name: "New",
    },
    {
        code: "IN_PROGRESS",
        id: 2,
        is_system: true,
        name: "In progress",
    },
    {
        code: "COMPLETED",
        id: 3,
        is_system: true,
        name: "Completed",
    },
    {
        code: "UNKNOWN",
        id: 4,
        is_system: true,
        name: "Unknown",
    },
];

describe("ILL Batches", () => {
    beforeEach(() => {
        cy.login();
        cy.task("query", {
            sql: "SELECT value FROM systempreferences WHERE variable='ILLModule'",
        }).then(rows => {
            cy.wrap(rows[0].value).as("syspref_ILLModule");
        });
        cy.set_syspref("ILLModule", 1);
        cy.title().should("eq", "Koha staff interface");
        cy.get("a.icon_administration").contains("Administration").click();
        cy.get("a").contains("Manage plugins").click();
        cy.get("a#upload_plugin").contains("Upload plugin").click();

        cy.get("#uploadfile").click();
        cy.get("#uploadfile").selectFile(
            "t/cypress/fixtures/koha-plugin-ill-metadata-enrichment.kpz"
        );
        cy.get("input").contains("Upload").click();

        cy.intercept("GET", "/api/v1/ill/batchstatuses", {
            statusCode: 200,
            body: batchstatuses,
        }).as("get-batchstatuses");
    });
    afterEach(function () {
        //Restore ILLModule sys pref original value
        cy.set_syspref("ILLModule", this.syspref_ILLModule);
        //Clean-up created test batches
        cy.task("query", {
            sql: "DELETE from illbatches where name IN ('test batch', 'second test batch')",
        });
        //Uninstall plugin
        cy.visit("/cgi-bin/koha/plugins/plugins-home.pl");
        cy.get('.actions .btn-group.dropup a[id*="Pubmed"]')
            .contains("Actions")
            .click();
        cy.get(".dropdown-item.uninstall_plugin").click();
    });
    it("ILL requests batch modal", function () {
        cy.visit("/cgi-bin/koha/mainpage.pl");
        cy.get("a.icon_ill").contains("ILL requests");
        cy.get("a.icon_ill").click();

        // Open batch modal
        cy.get("#ill-batch-backend-dropdown")
            .contains("New ILL requests batch")
            .click();
        cy.get(".dropdown-menu.show a").contains("Standard").click();
        cy.wait("@get-batchstatuses");
        cy.get("#ill-batch-modal").should("be.visible");
        cy.get("#ill-batch-modal #button_create_batch")
            .should("exist")
            .and("be.disabled");

        // Create batch
        cy.get("#ill-batch-modal #name").type("test batch");
        cy.get("#ill-batch-modal #batchcardnumber").type("42");
        cy.get("#ill-batch-modal #branchcode").select("Centerville");
        cy.get("#ill-batch-modal #button_create_batch")
            .should("exist")
            .and("not.be.disabled");
        cy.get("#ill-batch-modal #button_create_batch").click();
        cy.get("#ill-batch-modal #add_batch_items").should("be.visible");

        // Close modal
        cy.get("#ill-batch-modal #button_cancel_batch").click();
        cy.get("#ill-batch-modal").should("not.be.visible");

        // Reopen modal, button_create_batch must exist and be disabled
        cy.get("#ill-batch-backend-dropdown")
            .contains("New ILL requests batch")
            .click();
        cy.get(".dropdown-menu.show a").contains("Standard").click();
        cy.get("#ill-batch-modal #button_create_batch")
            .should("exist")
            .and("be.disabled");

        // Create a new batch
        cy.get("#ill-batch-modal #name").type("second test batch");
        cy.get("#ill-batch-modal #batchcardnumber").type("42");
        cy.get("#ill-batch-modal #branchcode").select("Centerville");
        cy.get("#ill-batch-modal #button_create_batch")
            .should("exist")
            .and("not.be.disabled");
        cy.get("#ill-batch-modal #button_create_batch").click();
        cy.get("#ill-batch-modal #add_batch_items").should("be.visible");

        // Add identifiers + Mock plugin (pubmedid) API responses
        let pubmedid = "123";
        cy.intercept(
            "GET",
            "/api/v1/contrib/pubmed/esummary?pmid=" + pubmedid,
            {
                statusCode: 200,
                body: pubmedid_metadata_response,
            }
        ).as("get-pubmedid-metadata");
        cy.intercept("POST", "/api/v1/contrib/pubmed/parse_to_ill", {
            statusCode: 200,
            body: parse_to_ill_response,
        }).as("get-parse_to_ill");
        cy.get("#ill-batch-modal #identifiers_input").type(pubmedid);
        cy.get("#ill-batch-modal #process-button")
            .contains("Process identifiers")
            .click();
        cy.wait("@get-pubmedid-metadata");
        cy.wait("@get-parse_to_ill");
        cy.get("#ill-batch-modal #create-requests-button").should("exist");

        // Close modal
        cy.get("#ill-batch-modal #button_cancel_batch").click();
        cy.get("#ill-batch-modal").should("not.be.visible");

        // Reopen modal, #identifier-table_wrapper must not be visible
        cy.get("#ill-batch-backend-dropdown")
            .contains("New ILL requests batch")
            .click();
        cy.get(".dropdown-menu.show a").contains("Standard").click();
        cy.get("#identifier-table_wrapper").should("not.be.visible");
    });
});
