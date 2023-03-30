# RELEASE NOTES FOR KOHA 22.11.04
30 Mar 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.04 is a bugfix/maintenance release.

It includes 27 enhancements, 137 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## Enhancements

### Architecture, internals, and plumbing

- [[32609]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32609) Remove compiled files from src

  >This important architectural change removes the built css and javascript files from source control and introduces a build process and trigger into our packaging routines.
  >
  >This will both save space in the repository and lead to less mistakes from developers by dropping the need to build, add and commit these files at release time.
- [[32806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32806) Some Vue files need to be moved for better reusability

  >This is an important architectural improvement to aid in future maintenance and expansion of the Vue based modules (erm) not available in Koha.
- [[32939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32939) Have generic fetch functions in vue modules
- [[32991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32991) Improve our Dialog component and remove routes for deletion
- [[33031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33031) Update OPAC lists page to use Bootstrap markup for tabs
- [[33080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33080) Add helpers that return result_set for further processing
- [[33083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33083) Handle generic collection of records methods

### ERM

- [[32925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32925) Display loading info when a form is submitted

  >This gives the end user more visual feedback when a form is submitted in eRM.

### Hold requests

- [[32421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32421) Add collection ( ccode ) column to holds to pull

  >This enhancement removes an inconsistency in the holds to pull display by adding collection code to the displayed columns.

### Notices

- [[31858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31858) TT syntax for ACQORDER notices

### REST API

- [[31800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31800) REST API: POST endpoint for Biblios
- [[31801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31801) REST API: PUT endpoint for Biblios
- [[32734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32734) REST API: Add a list endpoint for Biblios
- [[32981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32981) Add REST API endpoint to list authorised values for a given category
- [[32997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32997) Add REST API endpoint to list authorised values for multiple given categories
- [[33161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33161) Implement +strings for GET /items and /items/:item_id

  **Sponsored by** *Virginia Polytechnic Institute and State University*

  >Exposes the `+strings` option on the `/items` endpoints.
  >
  >The allows api consumers to request that string expansions of various coded values from these endpoints are embedded into the response.

### SIP2

- [[32684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32684) Implement SIP patron status field "too many items lost"

### Staff interface

- [[32886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32886) Set focus for cursor to Code when adding a new restriction
- [[33090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33090) page-sections are missing in the account line details page

### Templates

- [[32507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32507) Use template wrapper to build breadcrumb navigation

  >Architectural enhancement in preparation for bootstrap 5 upgrade.  This patch adds the foundations for abstracting the breadcrumb component of the staff client.
- [[32658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32658) Use template wrapper in order from staged file template
- [[32683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32683) Convert header search tabs to Bootstrap
- [[32746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32746) Standardize structure around action fieldsets in acquisitions
- [[32952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32952) Standardize action fieldsets in authorities, cataloging, and circulation
- [[33000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33000) Use template wrapper for breadcrumbs: Acquisitions part 1
- [[33068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33068) Use template wrapper for breadcrumbs: Administration part 3

### Test Suite

- [[33282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33282) Cypress tests are failing


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[32472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32472) [21.11 CRASH] The method Koha::Item->count is not covered by tests
- [[32558]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32558) Allow background_jobs_worker.pl to process multiple jobs simultaneously up to a limit
- [[33044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33044) BackgroundJob enqueue does not return the job id if rabbit is unreachable
- [[33183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33183) Error inserting matchpoint_components when creating record matching rules with MariaDB 10.6

### Cataloging

- [[19361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19361) Linking an authorised value category to a field in a framework can lose data
- [[33100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33100) Authority linking doesn't work for bib headings ending in two or more punctuation characters

### Circulation

- [[32653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32653) Curbside pickups - wrong dates available at the OPAC
- [[32891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32891) Curbside pickups - Cannot select slot in the last hour

### Command-line Utilities

- [[32798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32798) build_oai_sets.pl passes wrong parameter to Koha::Biblio::Metadata->record

### OPAC

- [[32674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32674) When placing a hold in OPAC page explodes into error 500
- [[33101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33101) Basket More details view doesn't work

### Packaging

- [[32994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32994) Remove compiled files from src (2)

### REST API

- [[32713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32713) x-koha-embed appears to no longer properly validate
- [[33020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33020) Unsupported method history
- [[33145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33145) Invalid specification for ERM routes

### SIP2

- [[33055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33055) SIP2 adding incorrect fines blocked message

### Searching - Elasticsearch

- [[32594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32594) Add a dedicated ES indexing background worker

### Serials

- [[33014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33014) Add link to serial advanced search

### Test Suite

- [[32898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32898) Cypress tests are failing

### Tools

- [[32804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32804) Importing and replacing items causes inconsistency when itemnumber match and biblio match disagree


## Other bugs fixed

### About

- [[32665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32665) warnPrefRequireChoosingExistingAuthority condition incorrect in about.pl
- [[32687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32687) About may list version of SQL client in container, not actual server

### Acquisitions

- [[31056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31056) Unable to 'Close and export as PDF' a basket group
- [[33002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33002) 'Archive selected' button missing?
- [[33082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33082) Add yellow buttons and page sections to 'copy order' pages

### Architecture, internals, and plumbing

- [[23247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23247) Use EmbedItems in opac-MARCdetail.pl
- [[30920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30920) Add caching to C4::Biblio::GetAuthorisedValueDesc
- [[32460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32460) Columns missing from table configuration for patron categories
- [[32585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32585) Followup on Bug 32583 - fix some variable references
- [[32678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32678) Add new line in authorized values tests in search_for_data_inconsistencies.pl
- [[32781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32781) CreateEHoldingsFromBiblios not dealing with non-existent package correcly
- [[32811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32811) Remove unused indexer.log
- [[32922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32922) Remove space in shebang
- [[32935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32935) basketgroup.js is not longer used and should be removed
- [[32975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32975) Error in package.json's definition of css:build vs css:build:prod
- [[32978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32978) 'npm install' fails in ktd on aarch64, giving unsupported architecture error for node-sass
- [[33211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33211) Fix failing test for basic_workflow.t when adding item

### Cataloging

- [[3831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3831) Add a warning/hint when FA framework is missing
- [[31665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31665) 952$d ( Date acquired ) no longer prefills with todays date when focused
- [[32812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32812) Fix cataloguing/value_builder/barcode_manual.pl
- [[32813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32813) Fix cataloguing/value_builder/barcode.pl
- [[32814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32814) Fix cataloguing/value_builder/callnumber-KU.pl
- [[32815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32815) Fix cataloguing/value_builder/callnumber.pl
- [[32816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32816) Fix cataloguing/value_builder/cn_browser.pl
- [[32819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32819) Fix cataloguing/value_builder/stocknumberam123.pl
- [[32820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32820) Fix cataloguing/value_builder/stocknumberAV.pl
- [[32821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32821) Fix cataloguing/value_builder/stocknumber.pl
- [[32822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32822) Fix cataloguing/value_builder/unimarc_field_010.pl
- [[32823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32823) Fix cataloguing/value_builder/unimarc_field_100_authorities.pl
- [[32824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32824) Fix cataloguing/value_builder/unimarc_field_100.pl
- [[32825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32825) Fix cataloguing/value_builder/unimarc_field_105.pl
- [[32826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32826) Fix cataloguing/value_builder/unimarc_field_106.pl
- [[32827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32827) Fix cataloguing/value_builder/unimarc_field_110.pl
- [[32828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32828) Fix cataloguing/value_builder/unimarc_field_115a.pl
- [[32829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32829) Fix cataloguing/value_builder/unimarc_field_115b.pl
- [[32835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32835) Fix cataloguing/value_builder/unimarc_field_122.pl
- [[33144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33144) Authority lookup in advanced editor overencodes HTML
- [[33173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33173) Save and continue button in standard cataloging module broken

### Circulation

- [[31209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31209) Add a span with class around serial enumeration/chronology data in list of checkouts for better styling
- [[31563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31563) Numbers on claims tab not showing in translated templates
- [[32503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32503) Holds awaiting pickup doesn't sort dates correctly

### ERM

- [[32180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32180) ERM - Mandatory fields don't have the 'required' class on the label
- [[32495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32495) Required fields in API and UI form don't match

  >This enhancement changes the new agreement form so that the description field is no longer required (to match with the API).
- [[32728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32728) ERM - Search header should change to match the section you are in
- [[32983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32983) Use REST API route to retrieve authorised values

### I18N/L10N

- [[22490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22490) Some strings in JavaScript files are untranslatable
- [[33076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33076) Add context to "Quotes"
- [[33151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33151) Improve translation of strings in cities and circulation desk administration pages

### ILL

- [[32525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32525) Standardize labels between ILL request list and detail page
- [[32566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32566) Don't show 'ILL request logs' button, when IllLog is turned off
- [[32799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32799) ILLSTATUS authorized value category name is confusing

### Installation and upgrade (command-line installer)

- [[33051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33051) 22600075.pl is not idempotent

### Installation and upgrade (web-based installer)

- [[32918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32918) ERM authorized values should be in installer/data/mysql/en/mandatory/auth_values.yml
- [[33059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33059) Capitalization: Fix sample authorised value descriptions

### Notices

- [[29354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29354) Make overdue_notices.pl send HTML attachment as .html

### OPAC

- [[31221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31221) Buttons overflow in OPAC search results in mobile view
- [[31248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31248) Fix responsive table style in the OPAC after switch to Bootstrap tabs
- [[32338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32338) OPAC - Mobile - Selection toolbar in search result is shifted and not adjusted
- [[32492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32492) Improve mark-up of OPAC messaging table to ease customization
- [[32611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32611) Not for loan items don't show the specific not for loan value in OPAC detail page
- [[32663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32663) Street number should not allow for entering more than 10 characters in OPAC
- [[32679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32679) CSS class article-request-title is doubled up in article requests list in staff patron account
- [[32946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32946) 'Send list/cart' forms in OPAC is misaligned
- [[32999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32999) Click handler to show QR code in OPAC lacks preventDefault

### Patrons

- [[31890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31890) PrefillGuaranteeField should include option to prefill surname

  >This bugfix adds the surname field to the list of fields (in the PrefillGuaranteeField system preference) that can be automatically prefilled when adding a guarantee to a patron's account.
- [[32675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32675) Cannot add a guarantor when there is a single quote in the guarantor attributes
- [[32770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32770) Patron search field groups no longer exist
- [[32904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32904) Patrons table processing eternally and not loading

  **Sponsored by** *Education Services Australia SCIS*
- [[33155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33155) Category and library filters from header patron search not taken into account

### Plugin architecture

- [[33189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33189) Plugin upload should prompt for .kpz files

### REST API

- [[32118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32118) Clarify expansion/embed modifiers
- [[32923]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32923) x-koha-embed must a header of collectionFormat csv
- [[33227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33227) OpenAPI validation is failing for paths/biblios.yaml

### Reports

- [[32805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32805) When recording localuse in the statistics table location is always NULL
- [[33063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33063) Duplicated reports should maintain subgroup of original

### Searching

- [[32639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32639) OpenSearch description format document generates search errors

### Searching - Elasticsearch

- [[31471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31471) Duplicate check in cataloguing fails with Elasticsearch for records with multiple ISBN
- [[32519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32519) In Elasticsearch mappings table use search field name

### Self checkout

- [[33150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33150) Add specific message for renewal too_soon situation

### Staff interface

- [[32568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32568) Add page section to list of checkins

  >This patch adds the page-section class to the checkedin table on the returns page.
- [[32576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32576) ILL needs the page-section treatment
- [[32768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32768) Autocomplete suggestions container should always be on top of other UI elements
- [[32941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32941) Sys prefs side menu styling applying where not intended
- [[32982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32982) 'Add/Edit group' modals in library groups is missing it's primary button
- [[33032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33032) Alternate holdings broken in staff interface search results

### System Administration

- [[32803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32803) EnableItemGroups and EnableItemGroupHolds options are wrong
- [[33004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33004) Add VENDOR_TYPE to default authorised value categories
- [[33060]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33060) Fix yes/no setting to 1/0 in system preference YAML files

### Templates

- [[31413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31413) Set focus for cursor to Selector when adding a new audio alert
- [[32159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32159) Uncertain prices has 2 level 1 headings
- [[32205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32205) Unnecessary sysprefs used in template params for masthead during failed OPAC auth
- [[32215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32215) 'You Searched for' for patron restrictions is not used
- [[32293]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32293) Terminology: Some budgets are not defined in item records
- [[32307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32307) Chocolat image viewer broken in the staff interface when Coce is enabled
- [[32757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32757) "Save changes" button on housebound tab should be yellow
- [[32912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32912) Use template wrapper for notices tabs
- [[32926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32926) Cannot expand or collapse some System preference sections after a search
- [[32933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32933) Use val() instead of attr("value") when getting field values with jQuery
- [[32973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32973) Use template wrapper for breadcrumbs: about, main, and error page
- [[33011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33011) Capitalization: Show in Staff interface?
- [[33015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33015) 'Cancel' link still points to tools home when it should be cataloguing home on some pages
- [[33016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33016) MARC diff view still shows tools instead of cataloging in title and breadcrumbs
- [[33048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33048) Empty email link on error page when opac login not allowed
- [[33056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33056) Terminology: change 'fine' to 'charge' when making a payment/writeoff
- [[33058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33058) Terminology: change 'fine' to 'charge' for viewing a guarantee's charges in OPAC
- [[33095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33095) Text is white on white when hovering over pay/writeoff buttons in paycollect
- [[33126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33126) Markup error in staff interface tab wrapper

### Test Suite

- [[32353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32353) reserves.item_group_id should be undefined in tests by default
- [[32979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32979) Add Test::Exception to Logger.t
- [[33054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33054) Koha/Acquisition/Order.t is failing randomly
- [[33214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33214) Make sure cache is cleared properly
- [[33235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33235) Cypress tests are failing
- [[33263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33263) selenium/patrons_search.t is failing randomly

### Tools

- [[22428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22428) MARC modification template cuts text to 100 characters
- [[30869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30869) Stock rotation rotas cannot be deleted

  **Sponsored by** *PTFS Europe*
- [[32685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32685) Display incorrect when matching authority records during import
- [[32967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32967) Recalls notices are using the wrong database columns

  **Sponsored by** *Catalyst*



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (72.6%)
- Armenian (100%)
- Bulgarian (91.6%)
- Chinese (Taiwan) (82.8%)
- Czech (59.4%)
- English (New Zealand) (68.8%)
- English (USA)
- Finnish (95.6%)
- French (100%)
- French (Canada) (96.1%)
- German (100%)
- German (Switzerland) (50.5%)
- Greek (50.5%)
- Hindi (99.5%)
- Italian (93.4%)
- Nederlands-Nederland (Dutch-The Netherlands) (78.9%)
- Norwegian Bokmål (56.7%)
- Persian (65.3%)
- Polish (92.4%)
- Portuguese (73.8%)
- Portuguese (Brazil) (100%)
- Russian (94.4%)
- Slovak (61.8%)
- Spanish (98.5%)
- Swedish (76%)
- Telugu (78.5%)
- Turkish (88.7%)
- Ukrainian (78.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.11.04 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - David Cook
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Manager: Mason James


- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Aude Charillon
  - David Nind
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.11 -- PTFS Europe (Martin Renvoize, Matt Blenkinsop, Jacob O'Mara, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.04

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Education Services Australia SCIS
- [PTFS Europe](https://ptfs-europe.com)
- Virginia Polytechnic Institute and State University

We thank the following individuals who contributed patches to Koha 22.11.04

- Aleisha Amohia (2)
- Pedro Amorim (21)
- Tomás Cohen Arazi (31)
- Alex Arnaud (2)
- Matt Blenkinsop (4)
- Jérémy Breuillard (1)
- Nick Clemens (20)
- David Cook (7)
- Frédéric Demians (1)
- Jonathan Druart (74)
- Magnus Enger (2)
- Katrin Fischer (33)
- Lucas Gass (9)
- Michael Hafen (1)
- Kyle M Hall (5)
- Mason James (3)
- Andreas Jonsson (1)
- Owen Leonard (25)
- Julian Maurice (17)
- Agustín Moyano (5)
- Martin Renvoize (26)
- Phil Ringnalda (1)
- Marcel de Rooy (8)
- Caroline Cyr La Rose (2)
- Andreas Roussos (2)
- Fridolin Somers (3)
- Koha translators (1)
- Hammat Wele (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.04

- Athens County Public Libraries (25)
- BibLibre (23)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (33)
- ByWater-Solutions (34)
- Catalyst Open Source Academy (2)
- Chetco Community Public Library (1)
- Dataly Tech (2)
- Independant Individuals (1)
- Koha Community Developers (74)
- KohaAloha (3)
- Kreablo AB (1)
- Libriotech (2)
- Prosentient Systems (7)
- PTFS-Europe (51)
- Rijksmuseum (8)
- Solutions inLibro inc (4)
- Tamil (1)
- Theke Solutions (36)

We also especially thank the following individuals who tested patches
for Koha

- Michael Adamyk (1)
- Pedro Amorim (27)
- Tomás Cohen Arazi (270)
- Matt Blenkinsop (207)
- Christopher Brannon (1)
- Alex Buckley (1)
- Nick Clemens (62)
- Paul Derscheid (7)
- Jonathan Druart (63)
- emlam (1)
- Laura Escamilla (4)
- Jonathan Field (1)
- Katrin Fischer (39)
- Andrew Fuerste-Henry (7)
- Lucas Gass (18)
- Kyle M Hall (26)
- Sally Healey (4)
- Janusz Kaczmarek (1)
- Jan Kissig (1)
- Owen Leonard (18)
- LMSCloudPaulD (1)
- Marius Mandrescu (1)
- Agustín Moyano (14)
- Solene Ngamga (3)
- David Nind (39)
- Jacob O'Mara (64)
- Martin Renvoize (94)
- Phil Ringnalda (1)
- Marcel de Rooy (18)
- Caroline Cyr La Rose (9)
- Michaela Sieber (1)
- Fridolin Somers (3)
- Emmi Takkinen (1)
- Hammat Wele (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 30 Mar 2023 13:21:58.
