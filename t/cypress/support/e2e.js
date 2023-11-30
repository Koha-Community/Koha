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
const dayjs = require("dayjs") /* Cannot use our calendar JS code, it's in an include file (!)
                                   Also note that moment.js is deprecated */

const dates = {
    today_iso: dayjs().format("YYYY-MM-DD"),
    today_us: dayjs().format("MM/DD/YYYY"),
    tomorrow_iso: dayjs().add(1, "day").format("YYYY-MM-DD"),
    tomorrow_us: dayjs().add(1, "day").format("MM/DD/YYYY"),
}

cy.get_agreement = () => {
    let licenses = cy.get_licenses_to_relate();
    return {
        agreement_id: 1,
        closure_reason: "",
        description: "my first agreement",
        is_perpetual: false,
        license_info: "",
        name: "agreement 1",
        renewal_priority: "",
        status: "active",
        vendor_id: 1,
        vendor: [cy.get_vendors_to_relate()[0]],
        periods: [
            {
                started_on: dates["today_iso"],
                ended_on: dates["tomorrow_iso"],
                cancellation_deadline: null,
                notes: null,
            },
            {
                started_on: dates["today_iso"],
                ended_on: null,
                cancellation_deadline: dates["tomorrow_iso"],
                notes: "this is a note",
            },
        ],
        user_roles: [],
        agreement_licenses: [
            {
                agreement_id: 1,
                agreement_license_id: 3,
                license: licenses[0],
                license_id: licenses[0].license_id,
                notes: "license notes",
                physical_location: "cupboard",
                status: "controlling",
                uri: "license uri",
            },
            {
                agreement_id: 1,
                agreement_license_id: 4,
                license: licenses[1],
                license_id: licenses[1].license_id,
                notes: "second license notes",
                physical_location: "cupboard",
                status: "future",
                uri: "license uri",
            },
        ],
        agreement_relationships: [
            {
                agreement_id: 1,
                notes: "related agreement notes",
                related_agreement: {
                    agreement_id: 2,
                    description: "agreement description",
                    name: "agreement name",
                },
                related_agreement_id: 2,
                relationship: "supersedes",
            },
        ],
        agreement_packages: [],
        documents: [
            {
                agreement_id: 1,
                file_description: "file description",
                file_name: "file.json",
                notes: "file notes",
                physical_location: "file physical location",
                uri: "file uri",
                uploaded_on: "2022-10-27T11:57:02+00:00",
            },
        ],
    };
}

cy.get_licenses_to_relate = () => {
    return [
        {
            license_id: 1,
            description: "license description",
            license_id: 1,
            name: "first license name",
            status: "expired",
            type: "alliance",
        },
        {
            license_id: 2,
            description: "a second license",
            name: "second license name",
        },
        {
            license_id: 3,
            description: "a third license",
            name: "third license name",
        },
    ];
}

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
        preceding_publication_title_id: "preceeding id",
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

cy.get_vendors_to_relate = () => {
    return [
        {
            "id": 1,
            "name": "My Vendor",
            "aliases": [],
        },
        {
            "id": 2,
            "name": "My Vendor 2",
            "aliases": [
                {"alias": "alias", alias_id: 1, vendor_id: 2}
            ],
        }
    ]
}
cy.get_counter_file = () => {
    return {
            "date_uploaded": "2023-06-19T09:13:39+00:00",
            "erm_counter_files_id": 1,
            "file_content": "Report_Name,\"Journal Requests (Excluding OA_Gold)\"\r\nReport_ID,TR_J1\r\nRelease,5\r\nInstitution_Name,\"University Of West London\"\r\nInstitution_ID,\"Proprietary:Wiley:EAL00000122866; ISNI:0000000121857124\"\r\nMetric_Types,\"Total_Item_Requests; Unique_Item_Requests\"\r\nReport_Filters,\"Metric_Type:Total_Item_Requests|Unique_Item_Requests; Access_Type:Controlled; End_Date:2023-06-01; Begin_Date:2022-01-01; Data_Type:Journal; Access_Method:Regular\"\r\nReport_Attributes,\r\nExceptions,\"3031: Usage Not Ready for Requested Dates (Requested data between 2023-06-01 and 2023-06-01. However only data between 2018-11-01 and 2023-05-31 exists.)\"\r\nReporting_Period,\"Begin_Date=2022-01-01; End_Date=2023-06-01\"\r\nCreated,2023-06-19T02:13:31Z\r\nCreated_By,\"Atypon Systems LLC.\"\r\n\r\nTitle,Publisher,Publisher_ID,Platform,DOI,Proprietary_ID,Print_ISSN,Online_ISSN,URI,Metric_Type,Reporting_Period_Total,\"Jan 2022\",\"Feb 2022\",\"Mar 2022\",\"Apr 2022\",\"May 2022\",\"Jun 2022\",\"Jul 2022\",\"Aug 2022\",\"Sep 2022\",\"Oct 2022\",\"Nov 2022\",\"Dez 2022\",\"Jan 2023\",\"Feb 2023\",\"Mar 2023\",\"Apr 2023\",\"May 2023\",\"Jun 2023\"\r\n\"AEM Education and Training\",Wiley,0000000403801313,\"Wiley Online Library\",10.1002/(ISSN)2472-5390,Wiley:AET2,2472-5390,2472-5390,,Total_Item_Requests,16,1,3,0,1,3,1,0,2,1,0,0,1,0,3,0,0,0,0\r\n\"AEM Education and Training\",Wiley,0000000403801313,\"Wiley Online Library\",10.1002/(ISSN)2472-5390,Wiley:AET2,2472-5390,2472-5390,,Unique_Item_Requests,10,1,2,0,1,1,1,0,1,1,0,0,1,0,1,0,0,0,0\r\n\"AIChE Journal\",Wiley,0000000403801313,\"Wiley Online Library\",10.1002/(ISSN)1547-5905,Wiley:AIC,0001-1541,1547-5905,,Total_Item_Requests,4,1,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0\r\n\"AIChE Journal\",Wiley,0000000403801313,\"Wiley Online Library\",10.1002/(ISSN)1547-5905,Wiley:AIC,0001-1541,1547-5905,,Unique_Item_Requests,4,1,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0\r\n\"ANZ Journal of Surgery\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1445-2197,Wiley:ANS,1445-1433,1445-2197,,Total_Item_Requests,103,11,2,20,14,8,2,9,1,0,5,6,0,2,4,6,5,8,0\r\n\"ANZ Journal of Surgery\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1445-2197,Wiley:ANS,1445-1433,1445-2197,,Unique_Item_Requests,77,9,2,16,8,6,1,9,1,0,3,4,0,1,4,4,2,7,0\r\n\"AORN Journal\",Wiley,0000000403801313,\"Wiley Online Library\",10.1002/(ISSN)1878-0369,Wiley:AORN,0001-2092,1878-0369,,Total_Item_Requests,634,71,45,59,20,43,47,45,11,14,15,31,22,29,18,28,39,97,0\r\n\"AORN Journal\",Wiley,0000000403801313,\"Wiley Online Library\",10.1002/(ISSN)1878-0369,Wiley:AORN,0001-2092,1878-0369,,Unique_Item_Requests,436,53,27,27,15,34,30,30,6,11,13,22,17,23,16,26,26,60,0\r\nAPMIS,Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1600-0463,Wiley:APM,0903-4641,1600-0463,,Total_Item_Requests,6,0,0,0,1,0,0,0,2,0,0,0,2,0,1,0,0,0,0\r\nAPMIS,Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1600-0463,Wiley:APM,0903-4641,1600-0463,,Unique_Item_Requests,4,0,0,0,1,0,0,0,1,0,0,0,1,0,1,0,0,0,0\r\n\"AWWA Water Science\",Wiley,0000000403801313,\"Wiley Online Library\",10.1002/(ISSN)2577-8161,Wiley:AWS2,,2577-8161,,Total_Item_Requests,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0\r\n\"AWWA Water Science\",Wiley,0000000403801313,\"Wiley Online Library\",10.1002/(ISSN)2577-8161,Wiley:AWS2,,2577-8161,,Unique_Item_Requests,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0\r\nAbacus,Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1467-6281,Wiley:ABAC,0001-3072,1467-6281,,Total_Item_Requests,51,3,0,7,0,2,0,1,0,0,0,11,6,0,3,17,1,0,0\r\nAbacus,Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1467-6281,Wiley:ABAC,0001-3072,1467-6281,,Unique_Item_Requests,36,2,0,6,0,2,0,1,0,0,0,7,2,0,2,13,1,0,0\r\n\"Academic Emergency Medicine\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1553-2712,Wiley:ACEM,1069-6563,1553-2712,,Total_Item_Requests,213,18,16,11,13,21,20,28,16,6,11,2,4,18,17,1,7,4,0\r\n\"Academic Emergency Medicine\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1553-2712,Wiley:ACEM,1069-6563,1553-2712,,Unique_Item_Requests,159,15,11,10,10,15,13,23,12,6,7,2,2,10,12,1,7,3,0\r\n\"Accounting & Finance\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1467-629X,Wiley:ACFI,0810-5391,1467-629X,,Total_Item_Requests,67,2,4,4,13,8,1,0,2,2,1,9,6,2,0,2,4,7,0\r\n\"Accounting & Finance\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1467-629X,Wiley:ACFI,0810-5391,1467-629X,,Unique_Item_Requests,53,1,4,4,11,7,1,0,2,1,1,7,3,1,0,2,4,4,0\r\n\"Accounting Perspectives\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1911-3838,Wiley:APR,1911-382X,1911-3838,,Total_Item_Requests,19,0,0,2,1,3,0,1,0,0,0,0,0,3,1,0,4,4,0\r\n\"Accounting Perspectives\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1911-3838,Wiley:APR,1911-382X,1911-3838,,Unique_Item_Requests,14,0,0,1,1,1,0,1,0,0,0,0,0,2,1,0,4,3,0\r\n\"Acta Anaesthesiologica Scandinavica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1399-6576,Wiley:AAS,0001-5172,1399-6576,,Total_Item_Requests,181,29,20,19,5,15,4,19,6,5,6,4,0,3,29,1,12,4,0\r\n\"Acta Anaesthesiologica Scandinavica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1399-6576,Wiley:AAS,0001-5172,1399-6576,,Unique_Item_Requests,117,21,12,11,4,10,4,14,3,5,4,4,0,2,14,1,4,4,0\r\n\"Acta Neurologica Scandinavica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1600-0404,Wiley:ANE,0001-6314,1600-0404,,Total_Item_Requests,23,0,0,2,0,5,0,1,1,0,2,2,0,2,1,5,2,0,0\r\n\"Acta Neurologica Scandinavica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1600-0404,Wiley:ANE,0001-6314,1600-0404,,Unique_Item_Requests,21,0,0,2,0,4,0,1,1,0,1,2,0,2,1,5,2,0,0\r\n\"Acta Obstetricia et Gynecologica Scandinavica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1600-0412,Wiley:AOGS,0001-6349,1600-0412,,Total_Item_Requests,22,1,0,0,0,0,0,0,0,0,0,0,0,0,0,15,4,2,0\r\n\"Acta Obstetricia et Gynecologica Scandinavica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1600-0412,Wiley:AOGS,0001-6349,1600-0412,,Unique_Item_Requests,11,1,0,0,0,0,0,0,0,0,0,0,0,0,0,7,2,1,0\r\n\"Acta Ophthalmologica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1755-3768,Wiley:AOS,1755-375X,1755-3768,,Total_Item_Requests,2,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0\r\n\"Acta Ophthalmologica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1755-3768,Wiley:AOS,1755-375X,1755-3768,,Unique_Item_Requests,2,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0\r\n\"Acta Paediatrica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1651-2227,Wiley:APA,0803-5253,1651-2227,,Total_Item_Requests,229,23,26,14,12,8,45,22,6,10,8,3,9,7,8,11,9,8,0\r\n\"Acta Paediatrica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1651-2227,Wiley:APA,0803-5253,1651-2227,,Unique_Item_Requests,165,16,19,8,8,8,37,11,6,7,6,3,8,6,7,7,3,5,0\r\n\"Acta Physiologica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1748-1716,Wiley:APHA,1748-1708,1748-1716,,Total_Item_Requests,13,2,0,0,1,1,8,0,0,0,0,0,0,0,1,0,0,0,0\r\n\"Acta Physiologica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1748-1716,Wiley:APHA,1748-1708,1748-1716,,Unique_Item_Requests,12,2,0,0,1,1,7,0,0,0,0,0,0,0,1,0,0,0,0\r\n\"Acta Psychiatrica Scandinavica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1600-0447,Wiley:ACPS,0001-690X,1600-0447,,Total_Item_Requests,226,5,9,28,28,15,18,4,1,2,4,13,14,24,8,20,21,12,0\r\n\"Acta Psychiatrica Scandinavica\",Wiley,0000000403801313,\"Wiley Online Library\",10.1111/(ISSN)1600-0447,Wiley:ACPS,0001-690X,1600-0447,,Unique_Item_Requests,178,4,5,19,23,10,17,3,1,1,4,13,10,19,6,18,14,11,0\r\n",
            "filename": "PTFS Journals_TR_J1",
            "type": "TR_J1",
            "usage_data_provider_id": 1,
            "counter_logs": [
                {
                    "borrowernumber": null,
                    "counter_files_id": 2,
                    "erm_counter_log_id": 2,
                    "filename": "PTFS Journals_TR_J1",
                    "importdate": "2023-06-19T09:40:46+00:00",
                    "logdetails": null
                }
            ]
        }
      
}

cy.get_usage_data_provider = () => {
    return   {
        "active": 1,
        "aggregator": "test_aggregator",
        "api_key": '12345',
        "begin_date": dates['today_iso'],
        "customer_id": "12345",
        "description": "A data provider for cypress testing",
        "end_date": dates['tomorrow_iso'],
        "erm_usage_data_provider_id": 1,
        "method": "test",
        "name": "Wiley Online Library",
        "report_release": "test_report_release",
        "report_types": "TR_J1;",
        "requestor_email": "test_requestor_email",
        "requestor_id": "12345",
        "requestor_name": "test_requestor_name",
        "service_type": "test_service_type",
        "service_url": "www.url.com",
        "counter_files": [
            {
                "type": "TR_J1",
                "date_uploaded": dates['today_iso']
            },
            {
                "type": "TR_J1",
                "date_uploaded": dates['tomorrow_iso']
            },

        ],
        "earliest_title": "2023-01-01",
        "latest_title": "2023-01-01",
        "earliest_item": "",
        "latest_item": "",
        "earliest_platform": "2023-01-01",
        "latest_platform": "2023-01-01",
        "earliest_database": "",
        "latest_database": "",
        "last_run": "2023-10-01"
    }
}

cy.get_usage_title = () => {
    return [
        {
          "online_issn": "2472-5390",
          "print_issn": "2472-5390",
          "publisher": "Wiley",
          "publisher_id": "0000000403801313",
          "title": "AEM Education and Training",
          "title_doi": "10.1002/(ISSN)2472-5390",
          "title_id": 1338,
          "title_uri": "",
          "usage_data_provider_id": 5
        }
    ]
}

cy.get_default_report = () => {
    const params = {
        "url": "/api/v1/erm/usage_titles/monthly_report?q=[{\"erm_usage_muses.year\":2022,\"erm_usage_muses.report_type\":\"TR_J1\",\"erm_usage_muses.month\":[1,2,3,4,5,6,7,8,9,10,11,12],\"erm_usage_muses.metric_type\":[\"Total_Item_Requests\",\"Unique_Item_Requests\"]},{\"erm_usage_muses.year\":2023,\"erm_usage_muses.report_type\":\"TR_J1\",\"erm_usage_muses.month\":[1,2,3,4,5,6,7,8,9,10,11,12],\"erm_usage_muses.metric_type\":[\"Total_Item_Requests\",\"Unique_Item_Requests\"]}]",
        "columns": [1],
        "queryObject": {
            "data_display": "monthly",
            "report_type": "TR_J1",
            "metric_types": [
                "Total_Item_Requests",
                "Unique_Item_Requests"
            ],
            "usage_data_providers": null,
            "titles": null,
            "start_month": null,
            "start_year": "2022",
            "end_month": null,
            "end_year": "2023"
        },
        "yearly_filter": true,
        "type": "monthly",
        "tp_columns": {
            "2022": [
                {
                    "short": "Jan",
                    "description": "January",
                    "value": 1,
                    "active": true
                },
                {
                    "short": "Feb",
                    "description": "February",
                    "value": 2,
                    "active": true
                },
                {
                    "short": "Mar",
                    "description": "March",
                    "value": 3,
                    "active": true
                },
                {
                    "short": "Apr",
                    "description": "April",
                    "value": 4,
                    "active": true
                },
                {
                    "short": "May",
                    "description": "May",
                    "value": 5,
                    "active": true
                },
                {
                    "short": "Jun",
                    "description": "June",
                    "value": 6,
                    "active": true
                },
                {
                    "short": "Jul",
                    "description": "July",
                    "value": 7,
                    "active": true
                },
                {
                    "short": "Aug",
                    "description": "August",
                    "value": 8,
                    "active": true
                },
                {
                    "short": "Sep",
                    "description": "September",
                    "value": 9,
                    "active": true
                },
                {
                    "short": "Oct",
                    "description": "October",
                    "value": 10,
                    "active": true
                },
                {
                    "short": "Nov",
                    "description": "November",
                    "value": 11,
                    "active": true
                },
                {
                    "short": "Dec",
                    "description": "December",
                    "value": 12,
                    "active": true
                }
            ],
            "2023": [
                {
                    "short": "Jan",
                    "description": "January",
                    "value": 1,
                    "active": true
                },
                {
                    "short": "Feb",
                    "description": "February",
                    "value": 2,
                    "active": true
                },
                {
                    "short": "Mar",
                    "description": "March",
                    "value": 3,
                    "active": true
                },
                {
                    "short": "Apr",
                    "description": "April",
                    "value": 4,
                    "active": true
                },
                {
                    "short": "May",
                    "description": "May",
                    "value": 5,
                    "active": true
                },
                {
                    "short": "Jun",
                    "description": "June",
                    "value": 6,
                    "active": true
                },
                {
                    "short": "Jul",
                    "description": "July",
                    "value": 7,
                    "active": true
                },
                {
                    "short": "Aug",
                    "description": "August",
                    "value": 8,
                    "active": true
                },
                {
                    "short": "Sep",
                    "description": "September",
                    "value": 9,
                    "active": true
                },
                {
                    "short": "Oct",
                    "description": "October",
                    "value": 10,
                    "active": true
                },
                {
                    "short": "Nov",
                    "description": "November",
                    "value": 11,
                    "active": true
                },
                {
                    "short": "Dec",
                    "description": "December",
                    "value": 12,
                    "active": true
                }
            ]
        }
    }

    return {
        "erm_default_usage_report_id": 1,
        "report_name": "Cypress report",
        "report_url_params": JSON.stringify(params)
    }
}

cy.get_multiple_providers = () => {
    return [
        {
            "active": 1,
            "aggregator": "test_aggregator",
            "api_key": '12345',
            "customer_id": "12345",
            "description": "A data provider for cypress testing",
            "erm_usage_data_provider_id": 1,
            "method": "test",
            "name": "Cypress test provider",
            "report_release": "test_report_release",
            "report_types": "TR_J1;",
            "requestor_email": "test_requestor_email",
            "requestor_id": "12345",
            "requestor_name": "test_requestor_name",
            "service_type": "test_service_type",
            "service_url": "www.url.com",
        },
        {
            "active": 1,
            "aggregator": "test_aggregator",
            "api_key": '12345',
            "begin_date": dates['today_iso'],
            "customer_id": "12345",
            "description": "A second provider for reports testing",
            "end_date": dates['tomorrow_iso'],
            "erm_usage_data_provider_id": 2,
            "method": "test",
            "name": "Second test provider",
            "report_release": "test_report_release",
            "report_types": "TR_J1;TR_J2;TR_J3",
            "requestor_email": "test_requestor_email",
            "requestor_id": "12345",
            "requestor_name": "test_requestor_name",
            "service_type": "test_service_type",
            "service_url": "www.url.com",
        },
    ]
}

cy.getCounterRegistryProvider = () => {
    return [
        {
            "abbrev": "Wiley",
            "address": "John Wiley & Sons, Inc.\t\nCorporate Headquarters\tSuite 300\n111 River Street\t\nHoboken, NJ 07030-5774\nUSA",
            "address_country": {
                "code": "US",
                "name": "United States of America"
            },
            "contact": {
                "email": "eal@wiley.com",
                "form_url": "",
                "person": "",
                "phone": ""
            },
            "content_provider_name": "John Wiley & Sons",
            "host_types": [
                {
                    "name": "Aggregated_Full_Content"
                }
            ],
            "id": "60c7aa79-272d-4610-8ad5-c399bd938c8e",
            "name": "Wiley Online Library",
            "reports": [
                {
                    "counter_release": "5",
                    "report_id": "TR_J4",
                    "report_name": "Title Report - Journal Report 4"
                },
                {
                    "counter_release": "5",
                    "report_id": "DR_D2",
                    "report_name": "Database Report - Report 2"
                },
                {
                    "counter_release": "5",
                    "report_id": "TR_J3",
                    "report_name": "Title Report - Journal Report 3"
                },
                {
                    "counter_release": "5",
                    "report_id": "DR_D1",
                    "report_name": "Database Report - Report 1"
                },
                {
                    "counter_release": "5",
                    "report_id": "TR_J2",
                    "report_name": "Title Report - Journal Report 2"
                },
                {
                    "counter_release": "5",
                    "report_id": "PR",
                    "report_name": "Platform Master Report"
                },
                {
                    "counter_release": "5",
                    "report_id": "TR_B2",
                    "report_name": "Title Report - Book Report 2"
                },
                {
                    "counter_release": "5",
                    "report_id": "TR_B3",
                    "report_name": "Title Report - Book Report 3"
                },
                {
                    "counter_release": "5",
                    "report_id": "TR",
                    "report_name": "Title Master Report"
                },
                {
                    "counter_release": "5",
                    "report_id": "TR_B1",
                    "report_name": "Title Report - Book Report 1"
                },
                {
                    "counter_release": "5",
                    "report_id": "PR_P1",
                    "report_name": "Platform Report - Report 1"
                },
                {
                    "counter_release": "5",
                    "report_id": "TR_J1",
                    "report_name": "Title Report - Journal Report 1"
                },
                {
                    "counter_release": "5",
                    "report_id": "DR",
                    "report_name": "Database Master Report"
                }
            ],
            "sushi_services": [
                {
                    "counter_release": "5",
                    "url": "https:\/\/registry.projectcounter.org\/api\/v1\/sushi-service\/101d3199-5878-4421-b9c2-88826bee3ad6\/"
                }
            ],
            "website": "https:\/\/onlinelibrary.wiley.com\/"
        }
    ]
}

cy.getSushiService = () => {
    return {
        "api_key_info": "",
        "api_key_required": false,
        "contact": {
            "email": "eal@wiley.com",
            "form_url": "",
            "person": "",
            "phone": ""
        },
        "counter_release": "5",
        "credentials_auto_expire": false,
        "credentials_auto_expire_info": "",
        "customer_id_info": "EAL0000123 (EAL followed by 7 to 11 digits)",
        "customizations_in_place": true,
        "customizations_info": "Consortia reporting extension",
        "data_host": "https:\/\/registry.projectcounter.org\/api\/v1\/usage-data-host\/761269a2-27ed-44ce-8a8f-cca4f198c23f\/",
        "id": "101d3199-5878-4421-b9c2-88826bee3ad6",
        "ip_address_authorization": false,
        "ip_address_authorization_info": "",
        "notification_count": 0,
        "notifications_url": "https:\/\/registry.projectcounter.org\/api\/v1\/sushi-service\/101d3199-5878-4421-b9c2-88826bee3ad6\/notification\/",
        "platform_attr_required": false,
        "platform_specific_info": "",
        "request_volume_limits_applied": false,
        "request_volume_limits_info": "",
        "requestor_id_info": "EAL0000123 (EAL followed by 7 to 11 digits)*\r\n(Only required for those operating outside of their approved institutional IP range).",
        "requestor_id_required": true,
        "url": "https:\/\/onlinelibrary.wiley.com\/reports\/"
    }
}
