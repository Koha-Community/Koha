# RELEASE NOTES FOR KOHA 20.05.00
31 May 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.00 is a major release, that comes with many new features.

It includes 13 new features, 275 enhancements, 592 bugfixes.

A new <b>Technical highlights</b> section is included at the bottom of these notes for those seeking a short summary of the more technical changes included in this release

### System requirements

Koha is continuously tested against the following configurations and as such, these are the recommendations for
deployment:

- Debian Jessie with MySQL 5.5 (End of life)
- Debian Stretch with MariaDB 10.1
- Debian Buster with MariaDB 10.3
- Ubuntu Bionic with MariaDB 10.1 
- Debian Stretch with MySQL 8.0 (Experimental MySQL 8.0 support)

Additional notes:

- Perl 5.10 is required (5.24 is recommended)
- Zebra or Elasticsearch is required



## New features

### Acquisitions

- [[24347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24347) Add a 'search to order' function

  **Sponsored by** *Athens County Public Libraries*

  >This new feature allows staff to add items to an order via a new 'Search to order' function accessible from the basket. The order can then be created either directly from the result list or the detail pages of the catalog.
  >This replaces the former search functionality for existing records within the acquisitions module and makes it possible to use all search features and information shown in the normal catalog.

### Circulation

- [[13881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13881) Add ability to defined circulation desks

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

  >When enabled, this feature makes it possible to define circulation desks per library.
  >
  >Future developments are planned to allow associating hold pickup locations with desks and other features.
  >
  >**New system preference**: `UseCirculationDesks` defaults to disabled.
- [[24846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24846) Add a tool to enable bulk edit of due dates

  **Sponsored by** *BibLibre*, *ByWater Solutions* and *PTFS Europe*

  >With events sometimes leading to unforeseen library closures, (Coronavirus for example), this new tool allows librarians to update due dates in bulk based on library and current due date of the materials on loan.
  >
  >Access to the tool requires a new permission `batch_extend_due_dates`.

### Fines and fees

- [[23354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23354) Add a 'Point of sale' screen to allow anonymous payments

  **Sponsored by** *Cheshire Libraries Shared Services* and *PTFS Europe*

  >The new feature adds point of sale functionality to Koha.
  >
  >When enabled, a new "Point of sale" screen will be available from the staff client home page. From this screen, one can build up a transaction consisting of various items defined in the account debit types administration area and then process the transaction anonymously making a 'sale' to the end-user.  The payment type, cash register and staff user id's are all stored for later auditing purposes.
  >
  >**New system preference**: `EnablePointOfSale` defaults to disabled.
- [[23355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23355) Add a 'cashup' process to accounts

  **Sponsored by** *Cheshire Libraries Shared Services* and *PTFS Europe*

  >This new feature complements the new 'Point of sale' page introduced in bug 23354 by adding a page to display historic transactions that have taken place on the selected cash register since the last 'cashup' event.  One can record a 'cashup' from this page by comparing the summary values displayed on the page to the actual amounts found in the cash register and then clicking the 'cashup' button to record that this process has taken place.
- [[23442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23442) Add a 'refund' process to accounts

  **Sponsored by** *Cheshire Libraries Shared Services* and *PTFS Europe*

  >This enhancement adds a workflow that allows staff with the new `refund` permission to refund/reimburse patrons when they have been incorrectly charged for a transaction. It records an audit trail for the process.
- [[24080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24080) Add a 'payout' process to accounts

  **Sponsored by** *Cheshire Libraries Shared Services* and *PTFS Europe*

  >This new feature adds an audited process for paying out excess credits on a patrons account.

### ILL

- [[23112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23112) Add circulation process to inter-library loans

  **Sponsored by** *Loughborough University*

  >This new feature, when enabled, adds the option for library staff to immediately issue a received inter-library loan item to the patron who requested it.  The checkout is immediate and due date is set, either as a fixed date entered by the librarian or based upon the standard circulation rules.
  >
  >**New system preference**: `CirculateILL` defaults to disabled.

### OPAC

- [[4461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4461) Add a context-sensitive report a problem process

  **Sponsored by** *Catalyst*

  >This new feature, when enabled, lets patrons report problems using the OPAC.
  >
  >It adds a link to each page of the OPAC to a form so that patrons can report problems. Problems are then available via a new problem report management area in the staff interface.
  >
  >**New system preference**: `OPACReportProblem` defaults to disabled.

### Plugin architecture

- [[23975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23975) Add ability to search and install plugins from GitHub

  >This patch makes public plugins discoverable from within Koha itself via a search box at the top of the plugin management page.
  >
  >One can search for plugins and install them directly from their source.
  >
  >WARNING: Plugins are not yet verified by the community, use at your own risk.  The feature is **disabled** by default; to enable it an administrator must uncomment, or add new lines to, the relevant configuration lines inside the `plugin_repos` config block within koha-conf.xml.

### REST API

- [[24302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24302) Add a way to specify nested objects to embed in OpenAPI

  >This development introduces a way to define embeddable objects on API routes. On the path specs, they will be specified using dot notation for nested embeddings:
  >
  >"x-koha-embed": [
  >    'biblio',
  >    'biblio.items',
  >    'fund'
  >]
  >
  >The consumer will need to add a header to the request, specifying the things they want to embed using comma-separated values like this:
  >
  >x-koha-embed: 'biblio,fund'
  >
  >This header will be validated against the endpoint spec and an error code will be returned if the request is not appropriate.

### Searching - Elasticsearch

- [[14567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14567) Add an elasticsearch driven browse interface to the OPAC

  >This is an interface for quick and efficient browsing through records with Elasticsearch.
  >
  >It presents a page at /cgi-bin/koha/opac-browse.pl that allows you to enter the prefix of an author, title, or subject and it'll give you a list of the options that begin with the text you entered. You can then scroll forward through these and select the one you're after.
  >
  >Selecting a result provides a list of records
  >that match that particular search.
  >
  >**New system preference**: `OpacBrowseSearch` defaults to disabled.

### Web services

- [[24369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24369) Add ability to set CORS header in Koha

  >This development adds support for setting the Access-Control-Allow-Origin header in Koha using the new AccessControlAllowOrigin system preference. This is especially useful for integrating data from the services provided by Koha on sites other than Koha itself.
  >
  >**New system preference**: `AccessControlAllowOrigin` defaults to empty.

## Enhancements

### Acquisitions

- [[12502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12502) Add columns for note, order number and ISBN to late orders page

  >This adds the internal note, vendor note, order number and ISBN to the late orders table. The notes are editable directly from the table using a modal dialog.
- [[14963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14963) Add the ability to suggest purchase from existing titles

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

  >This enhancement adds the ability to create a new purchase suggestion from an existing catalogue record.
- [[14973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14973) Add an alert during purchase suggestion submissions to warn the user when an existing biblio appears to satisfy the request

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

  >This enhancement to the suggestions process adds a warning to alert the user to the presence of an apparent holding that already satisfies the suggestion they are about to submit.
- [[16784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16784) Add table configuration for the suggestions table
- [[22774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22774) Add ability to limit the number of purchase suggestions a patron may submit in a specified time period

  >This enhancement allows the library to limit the number of purchase suggestions a user may submit within a given time period.
  >
  >**New system preferences**: `MaxTotalSuggestions` defaults to empty (unrestricted) and `NumberOfSuggestionDays` defaults to empty (disabled).
- [[22784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22784) Add the ability to archive purchase suggestions

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

  >This enhancements to the suggestions process adds a way to archive completed purchase suggestions.
- [[23590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23590) Add the ability to change the manager of a suggestion and notify the new manager

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

  >This enhancement to the purchase suggestions process adds the ability to modify the manager of a suggestion.
  >
  >When assigning a suggestion to a new manager, the new notice `NOTIFY_MANAGER` will be sent to the manager to alert them.
  >
  >To keep track of the different modifications, 2 new columns are added to the suggestion table: `lastmodificationby` and `lastmodificationdate`, which will be updated automatically when a suggestion is edited.
- [[23591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23591) Add a new "Suggestions details" tab on bibliographic record

  >This enhancement adds a new 'Suggestion details' tab to the bibliographic record details view.
- [[23592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23592) Add a shortcut from suggestion details to the bibliographic details in the staff client

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [[23593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23593) Add a shortcut from suggestion details to the bibliographic record in the OPAC

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [[23594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23594) Add ability to batch modify itemtypes from the suggestions page

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

  >This enhancement allows users to update the item types for selected suggestions on the suggestions management page.
- [[23596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23596) Add ability to modify the suggestions 'reason' field when receiving the item

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

  >The suggestion 'reason' field is often used to communicate additional information about a suggestion between the patron making the suggestion and the staff member acting upon it.
  >
  >This enhancement allows staff to update the field upon receipt of the item and thus update the patron regarding the current state of the new material.
- [[24158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24158) Add ability to receive items in multiple currencies

  **Sponsored by** *Athlone Institute of Technology*

  >This enhancement adds a currency dropdown to the actual cost field on the accounting details panel at the point of receipt.
- [[24161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24161) Add ability to track the claim dates of later orders

  **Sponsored by** *Cork Institute of Technology*

  >This enhancement adds the ability to track multiple claim dates for a late order and exposes this audit record via the late orders and basket pages.
- [[24162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24162) Add quantity column to the late orders table

  **Sponsored by** *Cork Institute of Technology*

  >This enhancement adds a quantity column to the late orders table.
- [[24163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24163) Add ability to define a CSV profile for late orders export

  **Sponsored by** *Institute of Technology Tralee*
- [[24276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24276) Add functionality to apply defaults from the ACQ framework for mandatory fields when adding records from external sources
- [[24308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24308) Add ability to sort by dates in the suggestions table

  >Separates information about dates and roles into separate columns so they can be sorted nicely.
- [[24819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24819) Add ability for librarians to choose a patron when entering a purchase suggestion

### Architecture, internals, and plumbing

- [[18936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18936) Move issuingrules into circulation_rules

  >As part of ongoing efforts to simplify and enhance the circulation rules system, the `issuingrules` table has been removed and replaced by a new `circulation_rules` table.
  >
  >Any reports that may have used the issueingrules table will need to be updated to utilise the updated database structure.
- [[19735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19735) Move Perl deps definitions into a cpanfile

  >This enhancement moves us away from custom-built dependency management and to the widely adopted cpanfile format for perl dependency listing.
  >
  >If you are running koha from git for development purposes you can now install perl dependencies using standard perl tooling and the included cpanfile.
  >
  >This patch also introduces the ability to set maximum versions in our dependancy listing (and excluded versions too), which should help us better track our compatibility.
- [[20116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20116) Improve performance by caching the language list
- [[20443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20443) Move C4::Members::Attributes to Koha namespace
- [[20728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20728) Remove subroutines GetLastOrder*
- [[21294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21294) Add identification of boolean fields in the database
- [[21503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21503) Update AuthorisedValues.pm to fall back to code if description doesn't exist
- [[21746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21746) Remove NO_LIBRARY_SET
- [[21800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21800) TransformKohaToMarc should respect non-repeatability of item subfields
- [[22529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22529) /svc/members/search relies on quirks of haspermission
- [[22589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22589) Remove sub C4::Overdues::BorType
- [[22823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22823) Koha::Library needs a method for obtaining the inbound email address

  >This patch adds a new `inbound_email_address` method to the Koha::Library class. This allows for a consistent way of getting a libraries branch email address for incoming mail.
- [[23463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23463) Move C4::Items CRUD subroutines to Koha::Item
- [[24052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24052) Koha::XSLT housekeeping for bug 23290 (follow-up)
- [[24066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24066) Koha::Patron->has_permission has no POD
- [[24103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24103) Add option to dump built search query to templates

  >This enhancement allows you to view the search query used by Zebra or Elasticsearch, to help with troubleshooting. To use, enable the new system preference DumpSearchQueryTemplate, enable `DumpTemplateVarsIntranet` and `DumpTemplateVarsOpac`, and then search the page source in the staff interface or OPAC for 'search_query'.
  >
  >**New system preference**: `DumpSearchQueryTemplate` defaults to disabled.
- [[24149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24149) Add new Koha::Statistic[s] classes

  **Sponsored by** *Association KohaLa*
- [[24252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24252) Add credits, debits, credit_offsets and debit_offsets relationships to Koha::Account::Line

  **Sponsored by** *Cheshire Libraries Shared Services* and *PTFS Europe*

  >This enhancement allows for fetching related credits, debits and offsets directly from an existing Koha::Account::Line object and includes compatibility for prefetching of relations for performance.
- [[24255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24255) Add totals methods Koha::Account::Lines

  **Sponsored by** *Cheshire Libraries Shared Services* and *PTFS Europe*

  >This enhancement completes the set of summation methods available from a Koha::Account::Lines resultset object, complimenting the existing `total_outstanding` method.
  >
  >It introduces the following methods:
  >
  >* `total` - Sum of all `amount` fields in the accountlines set.
  >* `credits_total` - Sum of all `amount` fields for credits in the accountlines set.
  >* `debits_total` - Sum of all `amount` fields for debits in the accountlines set.
- [[24356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24356) objects.search prefetch

  >This enhancement makes the Koha::Object(s) derived classes expose information about prefetch-able relations. This is then used by a new helper to generate the prefetch information for the DBIC query.
- [[24368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24368) Koha::Libraries->pickup_locations needs refactoring/ratifying
- [[24418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24418) Add Koha::Biblio->suggestions
- [[24419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24419) Add Koha::Suggestion->suggester accessor
- [[24430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24430) Remove C4::Biblio::CountBiblioInOrders
- [[24435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24435) Add Koha::Biblio->items_count
- [[24440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24440) Add ->current_item_level_holds to Koha::Acquisition::Order
- [[24448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24448) Add Koha::Biblio->subscriptions_count
- [[24455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24455) Add ability to apply Koha formatting to dates from Javascript

  >This patchset lays the foundations for applying date formatting as described in the Koha system preferences to datetimes returned by the API in RFC3339 format.
- [[24463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24463) Consistent accessor-relationship naming for basket_group in Basket.pm
- [[24467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24467) *_count methods should be avoided
- [[24468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24468) C4::Reserves::_get_itype is no longer used
- [[24529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24529) Uninitialised value warnings in C4::Reserves
- [[24545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24545) Replace Franklin Street by gnu.org/licenses in copyright

  >This enhancement updates the GNU GPL license and copyright statement in all files so they are the same. It also updates the QA check to catch all new files.
- [[24561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24561) Add a datatables API wrapper

  >This patch adds a datatables wrapper that allows using datatables against Koha's API. It implements:
  >- Server side pagination
  >- Filtering/searching
  >- Embedding related objects in the request
  >- Sorting and filtering by nested objects
- [[24642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24642) Cache::Memcached::Fast::Safe must be marked as mandatory
- [[24715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24715) Cache repeatable subfield in TransformKohaToMarc
- [[24721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24721) emailLibrarianWhenHoldIsPlaced should use Koha::Library->inbound_email_address
- [[24723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24723) EmailPurchaseSuggestions should use Koha::Library->inbound_email_address when set to 'BranchEmailAddress'
- [[24726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24726) overdue_notices.pl should use Koha::Library->inbound_email_address
- [[24732]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24732) Make DumpTemplateVars more readable
- [[24735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24735) Remove QueryParser-related code
- [[24759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24759) OpacRenewalBranch code should be a Koha::Item method
- [[24837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24837) selectbranchprinter needs to be renamed
- [[24994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24994) TableExists should be used instead of IF NOT EXISTS in updatedatabase
- [[25045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25045) Add a way to restrict anonymous access to public routes (OpacPublic behaviour)

  >This enhancement allows libraries to distinctly disable the OPAC but allow the public facing API's to be enabled.
  >
  >**New system preference**: `RESTPublicAnonymousRequests` defaults to enabled.
- [[25109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25109) Add execution locking to Koha::Script
- [[25172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25172) Koha::Logger init is failing silently
- [[25296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25296) Add a way to force an empty Koha::Objects resultset
- [[25297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25297) Consistent return value in K::A::Order->current_item_level_holds
- [[25303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25303) Koha::Objects->delete should not skip overridden object class ->delete

### Authentication

- [[21190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21190) Add logging of successful/unsuccessful login attempts

  >This enhancement adds two new logging preferences `AuthFailureLog` and `AuthSuccessLog` in order to keep track of bad login attempts and successful ones.
  >
  >NOTE: In some countries, this may be a requirement as a local application of GDPR legislation.
  >
  >**New system preferences**: `AuthFailureLog` and `AuthSuccessLog` both default to disabled.

### Cataloging

- [[3426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3426) Add support for multiple tags to the itemcallnumber system preference

  >The itemcallnumber system preference now allows to specify multiple fields from which Koha can pull a suggestion for the itemcallnumber to use when adding items.
- [[7882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7882) Add ability to move and reorder fields and subfields in MARC editor

  >This feature allows to change the sequence of tags and subfields in the cataloguing editor usind drag & drop.
- [[8643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8643) Add ability to mark some MARC tags and subfields as important and alert on saving the record if they are found to be empty

  **Sponsored by** *Centre collégial des services regroupés*

  >This feature allows tags and subfields in bibliographic frameworks to be marked as important. The important attribute will trigger a confirmation message on saving the record, but will allow you to save the record without filling the fields.
- [[23349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23349) Add batch operations to staff interface catalog search results

  >With this enhancement there is a new "Edit" menu on the catalog search that allows to "Batch edit", "Batch delete," and "Merge" selected records from the result list.
- [[24173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24173) Add `subtitle` & `published date` to the search page in the advanced editor

  >This enhancement adds subtitle (all parts) and date published to the results that come up for the Advanced editor search.
- [[24452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24452) Add visual cue for whitespace in the advanced editor

  >Multiple spaces will now be highlighted by a red dotted underline in the editor.
- [[25231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25231) Remove alert when replacing a bibliographic record via Z39.50

### Circulation

- [[18355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18355) Add 'permanent location' alongside 'shelving location' when located on cart
- [[21443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21443) Add ability to exclude holidays when calculating rentals fees by time period

  >Allows to configure on item type level, if the calendar will be taken into account when calculating hourly or daily rental fees.
- [[23051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23051) Add ability to optionally renew fine accruing items when all fines on item are paid off

  **Sponsored by** *Loughborough University*

  >With the addition of a new `RenewAccruingItemWhenPaid` system preference, we gain the ability to automatically renew items with accruing fines at the point of payment of those fines.
  >
  >**New system preferences**: `RenewAccruingItemWhenPaid` and `RenewAccruingItemInOpac` both default to disabled.
- [[24287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24287) Add ability to record what triggered a given transfer

  >With the addition of the `reason` field to the `branchtransfers` table this allows us to track what triggered a transfer which is helpful both for later audit and for later use in code where we may want to cancel or replace existing transfers.
- [[24296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24296) Move stock rotation transfer triggers from `comments` to `reason`
- [[24297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24297) Record if a transfer was triggered 'manually'
- [[24298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24298) Record if a transfer was triggered by 'return to homebranch'
- [[24299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24299) Record if a transfer was triggered by 'rotating collections'
- [[24436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24436) Record if a transfer was triggered by a 'hold'
- [[24585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24585) Add 'Managed on' and 'Suggested on' columns to suggestions tab in patron account in staff
- [[25188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25188) Make circulation notes more prominent on the patron details tab

  **Sponsored by** *PTFS Europe*

### Command-line Utilities

- [[15214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15214) Add logging of authority updates to bulkmarcimport
- [[18414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18414) Add ability to pass a file of borrowernumbers for deletion to delete_patrons.pl

  >Adds the ability to specify a file with the --file flag that
  >should be a list of borrowernumbers for deletion.
  >
  >If used without other flags it will delete the list of borrowers, if used with other flags it will treat the other criteria as filters for the list.
- [[19008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19008) Add more options to cleanup database script

  >The cleanup_database.pl cronjob now also includes options for deleting:
  >
  >- entries from the statistics table
  >- deleted bibliographic records and items (deletedbiblio, deletedbiblioitems, deletedbiblio_metadata, deleteditems)
  >- deleted patrons (deleted_patrons)
  >- returend checkouts (old_issues)
  >- filled and cancelled holds (old_reserves)
  >- finished transfers between libraries (branchtransfers)
- [[21177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21177) Add ability to run misc/devel/update_dbic_class_files.pl without passing parameters by defaulting to koha-conf.xml
- [[21865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21865) Add Elasticsearch support to, and improve verbose output of, `remove_unused_authorities.pl`
- [[23571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23571) Add measures to prevent concurrent execution of fines.pl

  **Sponsored by** *Orex Digital*
- [[23871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23871) Add check for 'title exists' to `search_for_data_inconsistencies.pl`
- [[24340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24340) Add ability to disable SIP using koha-sip

  >This enhancement adds --enable and --disable options to the koha-sip Debian package command.
  >
  >Usage:
  >- koha-sip --enable instancename => Enables the Koha SIP server
  >- koha-sip --disable instancename => Disables and stops the Koha SIP server
- [[24526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24526) Add verbose and test modes to the `automatic_renewals.pl` cronjob

  >This patchset adds new options to the automatic_renewals.pl script to allow test and verbose modes.
  >
  >**Important:** The patches make the --confirm switch required, without it script will be run in test mode. Existing scheduled cronjobs will need to be updated to supply this switch.
  >
  >Running without --confirm will default in verbose mode as well.
- [[24651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24651) Add --maxdays option to the `fines.pl` cronjob to reduce the chance of re-processing very old, already capped, fines.

  >Improve the performances of the fines.pl cronjob by reducing the number of accountlines it targets by this new `--maxdays` option.
- [[24883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24883) Add `misc/load_yaml.pl` utility script to allow manual loading of yaml data files

  >During the 20.05 cycle a number of improvements were made to the installation mechanisms to enhance the translation workflows for this area.  As part of that work many existing translated .sql files were moved to a yaml based file.

### Course reserves

- [[15377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15377) Add ability to remove 'checked out' items from course reserves

  >This enhancement allows the removal of items that are listed on a course reserve and are checked out. Previously, checked out items could not be removed.
- [[22630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22630) Add ability to change the homebranch in course reserves

  **Sponsored by** *Université Jean Moulin Lyon 3*
- [[22970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22970) Add ability to change homebranch in batch add course reserves

  **Sponsored by** *Université Jean Moulin Lyon 3*
- [[23784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23784) Show subtitle, number and parts in course reserves list of items in OPAC
- [[24343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24343) Show subtitle, number and parts in course reserves list of titles in staff client
- [[25341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25341) When adding a single item to course reserves, ignore whitespace

### Database

- [[18177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18177) Remove unused columns in aqbooksellers
- [[22887]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22887) authorised_values is missing a unique constraint on category + authorised_value
- [[22987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22987) Add biblioimages.timestamp
- [[25152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25152) subscription.closed is a boolean and must be tinyint(1)

### Developer documentation

- [[24774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24774) Specify 2 space indentation for JSON files in .editorconfig

  **Sponsored by** *Hypernova Oy*

### Fines and fees

- [[6508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6508) Show indication of existing 'Charges' on tab of the same name

  >With this enhancement the amount of pending charges/credits will be shown in the tab description on the checkouts and details pages of a patron account in the staff interface. When there are no pending charges, the tab won't be visible.
- [[14898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14898) Add 'Save and pay' button to use after adding a manual invoice
- [[17702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17702) Create configuration for account credit types

  >This adds a new configuration page for credit types to the administration module. It shows all internal credit types used by Koha and allows to configure additional credit types. Additional credit types might be used for anonymous transactions with the Point of sale feature.
- [[24081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24081) Add a 'discount' process to accounts

  >Allows to specify and apply a discount on a patron's charges.  Staff will require the new permission 'discount' to use this new functionality.
- [[24082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24082) Add a 'refund' option to anonymous payments
- [[24380]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24380) Add option to recalculate fines upon a backdated return distinctly from `CalculateFinesOnReturn`

  >This enhancement allows libraries to set the option to calculate fines upon a backdated return distinctly from the broader option to always recalculate fines on return option.
  >
  >**New system preference**: `CalculateFinesOnBackdate` defaults to enabled on new installations or the value of `CalucalteFinesOnReturn` during upgrades.
- [[24478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24478) Make it possible to deactivate point of sale
- [[24479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24479) POS doesn't follow CurrencyFormat
- [[24492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24492) Add a 'library cashup' workflow to the point of sale system

  >This enhancement adds a new 'library details' page to the POS system which displays a summary of the cash register transactions for a library since each register was last cashed up. It also allows for cashing up individual registers or cashing up all registers at a given library in one transaction.
- [[24592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24592) Clarify LOST_RETURN process by using FOUND over RETURNED
- [[24604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24604) Add 'Pay' button under Transactions tab in patron accounting
- [[24775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24775) Payment submit button on POS page should have an ID
- [[24812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24812) Add permission for 'discount' process
- [[24818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24818) Accountline creation dates should be datetimes
- [[24828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24828) Add cash register support to SIP2
- [[24951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24951) Payout modal confirm button should have an ID
- [[24952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24952) Refund modal confirm button should have an ID

### Hold requests

- [[16547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16547) Can't place item level hold directly from search results screen

  >This enhancement lets you place and an item level hold from a search results list.
- [[19718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19718) Create message for patrons with multiple holds on the same item
- [[22284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22284) Add ability to define groups of locations for hold pickup

  **Sponsored by** *Vermont Organization of Koha Automated Libraries*

  >Adds the ability to define groups of libraries for use in holds policy.
- [[24547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24547) Add more action logs for holds

  >Trapping and filling holds will now create entries in the logs, when HoldsLog system preference is activated.
- [[24907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24907) Optionally exclude suspended holds from holds ratio report
- [[24953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24953) Minor corrections to hold ratios report sidebar

### I18N/L10N

- [[13897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13897) Use YAML files for installer data
- [[21156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21156) Internationalization: plural forms, context, and more for JS files
- [[23790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23790) fr-CA translation of ACCOUNT_DEBIT and ACCOUNT_CREDIT notices
- [[24063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24063) Add Sami language characters to Zebra

  >This patch adds some additional characters to the default zebra mappings for Sami languages to aid in searching on systems with such data present.
- [[24211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24211) Compress/uncompress translation files
- [[24262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24262) Translate installer data in YAML format
- [[24583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24583) Rewrite mandatory installation files to YAML
- [[24584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24584) Rewrite optional installation files to YAML
- [[24593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24593) Rewrite MARC21 optional data to YAML
- [[24594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24594) Rewrite MARC21 mandatory data to YAML
- [[24648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24648) Contextualization of past tense "Created"
- [[24662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24662) Remove global variables MSG_* from datatables.inc
- [[24664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24664) Add missing *-messages-js.po

### ILL

- [[23173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23173) ILL should be able to search third party sources prior to request creation

  **Sponsored by** *Public Health England*

  >This feature adds the required infrastructure to enable ILL availability plugins to intercept the request creation process and, using the supplied metadata, search for and display possible relevant items from whichever availability plugins are installed.
  >
  >**New system preference**: `ILLCheckAvailability` defaults to disabled.

### Installation and upgrade (command-line installer)

- [[24696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24696) We should output completion times in the updatedatabase output.

### Installation and upgrade (web-based installer)

- [[22655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22655) Add setup of a hold rule to the onboarding tool

  **Sponsored by** *Catalyst*
- [[24131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24131) Improved formatting for output of updatedatabase
- [[24314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24314) Update de-DE MARC21 frameworks for updates 28+29 (May and November 2019)
- [[24707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24707) Remove AMICUS from default fr-CA z39.50 servers

  >This removes AMICUS from the fr-CA sample z39.50 servers list as it is no longer valid.
- [[24708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24708) Update Z39.50 server attribute in fr-CA installation file

  >This enhancement adds a PQF attribute to the BANQ entry in the fr-CA sample z39.50 servers list, enabling the search to work correctly.

### Label/patron card printing

- [[7468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7468) Add label to batch by barcode range

  >This enhancement to the label creator tool adds an option to let you generate a range of barcode numbers (for example, from 05000 to 05500) and save these as a PDF, ready for printing.

### Lists

- [[20754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20754) Db revision to remove double accepted list shares

### MARC Authority data support

- [[25235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25235) Don't alert when replacing an authority record via Z39.50

### MARC Bibliographic data support

- [[15727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15727) Add 385$a - Audience to MARC21 detail pages
- [[23783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23783) Add display of languages from MARC21 field 041 to the OPAC

  >This enhancement adds display handling for the 041 MARC21 languages field, into the OPAC results and item details pages.
- [[24312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24312) Update MARC21 frameworks to Updates 28+29 (May and November 2019)
- [[25011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25011) Improve display of Production credits (MARC21 508) in OPAC and staff

  >This change makes some tiny changes to improve the display and consistency between the OPAC and staff interface:
  >- Capitalization: Production Credits --> Production credits.
  >- Change div to span to avoid display issues.
  >- Make sequence of fields in display match (505, 508, 586).

### Notices

- [[10269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10269) Add a way to utilise a specific replyto email address for some notices

  >This patchset adds the foundations needed to make use of a reply-to address if passed when calling EnqueueLetter.
  >
  >Further bugs will be used to add interfaces for adding such addresses.
- [[23673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23673) Separate time sent from time created in message_queue table

  >The time a message was created and the time it was sent are now separate columns in the message_queue table and will shown in the patron's account on the notice tab.
  >
  >Sponsored by: Northeast Kansas Library System (NEKLS)
- [[24588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24588) Set `Mailer-X` and `MessageID` mail headers to reduce the likelihood of Koha mail being marked as spam

### OPAC

- [[7611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7611) Show the NOT_LOAN authorised values for item status in XSLT OPAC search results

  **Sponsored by** *Centre collégial des services regroupés*
- [[13121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13121) Move search results "action" links ("Place hold," "Add tag," etc) into include file

  >This patch moves markup for controls repeated across several OPAC templates into a single include (making it easier to maintain in the future): Place hold, Request article, Add tag, Save to lists, and Add to cart.
- [[13388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13388) Add library pages to the OPAC

  >This adds a new link "Libraries" or "Library" to the navigation in the OPAC. The new page it links to gives information about all libraries in the Koha installation, using the data from the library configuration.
- [[13547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13547) Item field 'Materials specified' would be useful to see in OPAC

  >This enhancement allows you to make a new column visible on the OPAC. The new column shows the materials specified field after the call number column. You have to turn the column on in the "Columns settings" section.
- [[14715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14715) Results per page setting for catalog search in staff client and OPAC

  **Sponsored by** *Region Halland*

  >This enhancement adds a 'results per page' dropdown list to catalog search results pages in the OPAC and staff interface. This lets you set the number of results to show (20, 40, 60, 80, and so on).
  >
  >This is enabled by two new system preferences: `OPACnumSearchResultsDropdown` for the OPAC, and `numSearchResultsDropdown` for the staff interface.
  >
  >The default number of search results is set using existing system preferences: `OPACnumSearchResults` for the OPAC, and `numSearchResults` for the staff interface.
  >
  >This enhancement works for both Zebra and Elasticsearch search engines.
  >
  >**New system preferences**: `OPACnumSearchResultsDropdown` and `numSearchResultsDropdown` both default to disabled.
- [[15775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15775) Show message on OPAC summary if holds are blocked due to fines

  **Sponsored by** *Catalyst*

  >This adds a note to the patron account in the OPAC if the user is over the maxoutstanding fines limit and can no longer place holds.
- [[22880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22880) Convert opacheader system preference to news block
- [[23261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23261) RecordedBooks - notify patron of need to login / register to see availability

  >This enhancement makes the RBDigital Recorded Books subscription more discoverable to library patrons by adding a notice to the OPAC for patrons to register and login with RBDigital if they have not already done so.
- [[23547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23547) Add column configuration to course reserves table in the OPAC
- [[23794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23794) Convert OpacMainUserBlock system preference to news block
- [[23913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23913) Use a single menu to sort lists in the OPAC

  >This enhancement modifies the sorting form on the OPAC list contents view so that the two menus (sort field and direction) are combined into one.
  >
  >This makes it consistent with the sort menu on the search results page.
- [[23915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23915) Replace OPAC list sort menu with Bootstrap menu button

  >This patch adds JavaScript to the list contents page which converts the resort form's <select> menu into a Bootstrap dropdown menu. This allows for a more compact and consistent display.
- [[24336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24336) Ask for confirmation before deleting a suggestion in the OPAC
- [[24344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24344) Modify OPAC link to suggest existing record for purchase
- [[24530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24530) Show the number of title notes in the tab label on the OPAC detail page
- [[24699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24699) Split items.uri on OPAC detail page
- [[24701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24701) Add column configuration to course reserves items table in the OPAC
- [[24740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24740) Use biblio title if available rather than biblio number in OPAC search result cover images tooltips
- [[24913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24913) Add option to require users to enter email address twice during self-registration.

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >This enhancement, when enabled, requires users self-registering via the OPAC to manually enter their primary email address twice. This is to prevent users from incorrectly entering their email address and consequentially never receiving a verification email from the library.
  >
  >**New system preference**: `PatronSelfRegistrationConfirmEmail` defaults to disabled.
- [[25110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25110) Allow patrons to add star ratings to titles on their summary/checkout page

  >This enhancement lets logged-in patrons add star ratings to titles listed on their current checkouts and reading history pages.
- [[25166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25166) Add aria-hidden = "true" to Font Awesome icons in the OPAC
- [[25234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25234) Update OPAC search results pagination with aria labels
- [[25271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25271) Add floating toolbar to OPAC cart
- [[25280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25280) Use modal confirmation when removing share from a list in the OPAC
- [[25281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25281) Use modal confirmation when deleting a list in the OPAC
- [[25294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25294) Don't show deletion button if user can't delete suggestions
- [[25350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25350) Load Emoji picker assets more efficiently

### Patrons

- [[3137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3137) Allow to collapse areas of the patron add form by default

  **Sponsored by** *Catalyst*

  >This enhancement, when utilised, allows administrators to control which field sets are collapsed by default on the add patron form.
  >
  >Each collapsed section can still easily be uncollapsed by clicking on the section heading.
  >
  >**New system preference**: `CollapseFieldsPatronAddForm` defaults to empty.
- [[14229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14229) Link to accounting tab from fines column in patron search results
- [[20847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20847) Add main address, phone, and mobile fields to the Batch patron modification tool

  **Sponsored by** *PTFS Europe*

  >With this enhancement the fields of the main address, telephone and mobile of patrons can be changed using the batch patron modification tool.
- [[22534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22534) Add ability to choose which fields are copied from guarantor to guarantee

  **Sponsored by** *Waitaki Distict Council*

  >This enhancement allows administrators to configure which fields from the guarantor's patron record will be copied to the guarantees record when the link between the accounts is created.
  >
  >**New system preference**: `PrefillGuaranteeField` defaults to `phone,email,streetnumber,address,city,state,zipcode,country`.
- [[23409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23409) Show circulation note and OPAC note with line feeds
- [[23495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23495) Show SMS provider on details tab in patron account in staff
- [[24008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24008) Attempting to delete a patron with outstanding credits will warn, but not block the deletion
- [[24476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24476) Allow patrons to opt-out of auto-renewal

  >This development will allow a patron to opt-out of auto-renewals - the regular job will ignore these checkouts and items will remain renewable both via the staff interface and OPAC.
  >
  >Patrons will be able to set this flag themselves, staff will also be able to.
  >
  >**New system preference**: `AllowPatronToControlAutorenewal` defaults to disabled.

### Plugin architecture

- [[24183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24183) Introduce `before_send_messages` hook

  >This patch adds a new `plugin hook` to allow pre-processing of the message queue prior to sending messages.

### REST API

- [[18731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18731) Add routes for acquisition orders

  **Sponsored by** *Camden County*

  >This development adds API routes to perform CRUD operation on acquisition order lines.
- [[22615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22615) Add routes for /ill_backends
- [[23893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23893) Add ->new_from_api and ->set_from_api methods to Koha::Object

  >This development introduces generic methods to deal with API-to-DB attribute names translations, and some data transformations (dates and booleans).
  >
  >With this design we can overload this methods to handle specific cases without repeating the code as we did on initial implementations of API controllers.
  >
  >Testing becomes easier as well.
- [[24228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24228) Add a parameter to recursively embed objects in Koha::Object(s)->to_api

  >This patch introduces a parameter to the Koha::Object class ('embed') that should be a hashref pointing to a data structure following what's documented in the code. This parameter allows the caller to specify things to embed recursively in the API representation of the object. For example: you could request a biblio object with its items attached, like this:
  >
  >    $biblio_json = $biblio->to_api({ embed => { items => {} } });
  >
  >The names specified for embedding, are used as attribute names on the resulting JSON object, and are expected to be class accessors.
  >
  >The main use of this is the API, as introduced by bug 24302.
  >
  >Koha::Objects->to_api is adjusted to pass its parameters down to the Koha::Object.
- [[24321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24321) Make objects.search use mappings from Koha::Object(s)

  >This development takes advantage of the mappings that have been added to the Koha::Object level, and refactors the objects.search Mojolicious helper so it uses it internally.
  >
  >This allows us to remove the 'to_model' parameter, and makes the need of any kind of mapping on the controllers irrelevant. All the existing mappings are removed and the controllers simplified in this move.
- [[24461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24461) Add to_api_mapping to Koha::Acquisition::BasketGroup
- [[24464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24464) Add K::A::Basket->creator
- [[24502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24502) Add a query language and param (q=) to the API
- [[24528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24528) Add a syntax for specifying counts on x-koha-embed

  **Sponsored by** *ByWater Solutions*
- [[24615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24615) Add support for ordering by related object columns in the REST API
- [[24700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24700) Improve Mojo startup speed for REST APIs

  **Sponsored by** *National Library of Finland*
- [[24908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24908) Allow fetching text-formatted MARC data
- [[24909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24909) Add unprivileged route to get a bibliographic record
- [[25032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25032) Generic unhandled exception handling

  >The current code in the controllers is a bit heterogeneous regarding how unhandled exceptions are treated.
  >This enhancement introduces a generic way to write 'something happened' as a fallback after expected exceptions handling. This way the catch blocks are easier to read, and devs can follow this simple pattern when writing their endpoints.
- [[25279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25279) Make the cities list use the API

### SIP2

- [[15253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15253) Add Koha::Logger based logging for SIP2
- [[20816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20816) Add ability to send custom field(s) containing patron information in SIP patron responses

### Searching

- [[18433]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18433) Allow to select results to export in item search

  >This enhancement to the item search in the staff interface (Home > Search > Item search) adds the ability to export selected items. Before this enhancement the only option available was to export all the search results.
- [[24847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24847) Select AND by default in items search

### Searching - Elasticsearch

- [[22828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22828) Add display of errors encountered during indexing on the command line
- [[22831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22831) Add a maintenance script for checking DB vs index counts
- [[23137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23137) Add a command line tool to reset elasticsearch mappings
- [[23204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23204) Add script for exporting elasticsearch mappings to YAML
- [[24823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24823) Drop Catmandu dependency

### Self checkout

- [[25147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25147) AllowSelfCheckReturns is in the wrong system preference section

### Serials

- [[16962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16962) Remove the use of "onclick" from serial collection template

  >This patch removes the use of event attributes like "onclick" from the serial collection template. Events are now defined in JavaScript. This is a behind the scenes improvement - everything should continue to work as it did before.
- [[17674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17674) Allow UI to delete serials issues in batch

  **Sponsored by** *Centre collégial des services regroupés*

  >This allows to select multiple issues to be deleted from the 'serial collection' page in the serials module. A checkbox allows to optionally delete linked items as well.
- [[24877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24877) Add link from vendor to linked subscriptions

  >Adds a link on the vendor detail page to a subscription search for the vendor's name to get a list of all linked subscriptions.

### Staff Client

- [[17374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17374) Make use of fields from syspref 'DefaultPatronSearchFields' in patron search fields dropdown

  >This patch preserves the current dropdown choices for patron search, but adds fields additionally defined in the DefaultPatronSearchFields system preference to the list of available options.
- [[23601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23601) Middle clicking a title from search results creates two tabs or a new tab and a new window in Firefox

  >This fixes an issue in Firefox where middle-clicking or CTRL-clicking a title in the results screen of the staff client opens two new tabs.
- [[24522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24522) Nothing happens when trying to add nothing to a list in staff
- [[24617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24617) Add title notes count in staff detail (following 24530)
- [[24697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24697) Split items.uri on staff detail view
- [[24995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24995) Add issuedate to table_account_fines and finest in Accounting tab
- [[25027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25027) Result browser should not overload onclick event
- [[25053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25053) PatronSelfRegistrationExpireTemporaryAccountsDelay system preference is unclear

### System Administration

- [[4944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4944) Create separate noItemTypeImages preferences for OPAC and staff client

  >With this patch the noItemTypeImages preference will be used for the staff interface, while a new preference OpacNoItemTypeImages is added for the OPAC. For existing installations, the OpacnoItemTypeImages will be set to the same value as noItemTypeImages on update, so there is no change in behaviour.
  >
  >**New system preference**: `OpacNoItemTypeImages` defaults to disabled.
- [[5614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5614) Add sections/headings to Patron system preferences tab

  >This enhancement organizes the patron system preferences into sections. This makes them easier to find, instead of being one long unorganized list.
- [[15668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15668) Add column configuration to the items table in staff detail pages
- [[15686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15686) Rename "item level holds" circ rule column to "OPAC item level holds"
- [[17016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17016) Button to clear all fields in budget planning

  **Sponsored by** *Catalyst*
- [[20399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20399) Remove "did you mean" for the staff interface
- [[20415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20415) Remove UseKohaPlugins system preference

  >`UseKohaPlugins` system preferences is removed.
  >Koha plugins now only depends on config key `enable_plugins`.
- [[20484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20484) Always show Elasticsearch configuration page when permission is set
- [[20648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20648) "Display in check-out" renamed to "Display in patron's brief information" on patron attributes configuration page
- [[21520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21520) More complex OAI sets mappings

  >Prior to this patchset, the rules used to create OAI sets are processed with the 'or'
  >boolean operator between each rule.
  >
  >This patch allows to use 'or' or 'and' between the rules.
  >
  >The evaluation of the rules is done according to the boolean operators
  >precedence: AND has a higher precedence than OR.
- [[24193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24193) Add CodeMirror linting of JavaScript, CSS, HTML, and YAML system preferences

  >This enhancement adds CodeMirror plugins for linting system preferences that include JS, CSS, HTML, and YAML. When invalid data is entered in a linted CodeMirror editor an icon is displayed in the editor's "gutter." Hovering over the icon displays the error message.
- [[24291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24291) Explanation next to limit item types by library is confusing

  >This enhancement updates the explanation on the item type add and edit form for the 'Library limitation' field. The text now says "Select 'All libraries' if all libraries use this item type. Otherwise, select the specific libraries that use this item type."
- [[24475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24475) Reword FinesMode system preference
- [[24576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24576) StoreLastBorrower preference is in the wrong tab and is confusing
- [[24844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24844) Focus on the system preferences searchbar when going to admin home

  **Sponsored by** *Catalyst*

### Templates

- [[10469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10469) Display more when editing subfields in frameworks
- [[15352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15352) Use URLLinkText instead of URL for item links
- [[16457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16457) Remove the use of "onclick" from the patron entry form
- [[22468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22468) Standardize on labeling ccode table columns as collection
- [[23268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23268) "Suspend all holds" calendar allows to select past date
- [[23493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23493) jquery.dataTables.rowGrouping.js is no longer maintained, but there is an official DataTables version we could switch to
- [[23533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23533) Reindent patron entry form (memberentrygen.tt)
- [[23534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23534) Use patron-title.inc on patron entry page
- [[23856]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23856) Split author and ISBN/ISSN out of citation in staged MARC record management
- [[23884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23884) Merge strings.inc and browser-strings.inc
- [[23889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23889) Improve style of menu header in advanced cataloging editor

  >This enhancement updates the styling of dropdown menu headers to make them apply more consistently across the system.
- [[24181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24181) Improve  the display of our datepickers
- [[24341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24341) Add support for more complex markup in OPAC confirmation dialogs
- [[25135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25135) Improve clarity and navigation of columns settings administration
- [[25416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25416) Add information about anonymous session for XSLT use

  **Sponsored by** *Universidad ORT Uruguay*

### Test Suite

- [[22001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22001) Add RaiseError and PrintError flags for all tests

### Tools

- [[18127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18127) Add ability to add batch modified records to an existing list

  **Sponsored by** *Catalyst*

  >With this enhancement you can add all the records of a batch record modification to an existing list after successful modification.
- [[19793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19793) Add email to batch patron modification

  **Sponsored by** *PTFS Europe*

  >With this enhancement the primary email of patrons can be changed using the batch patron modification tool.
- [[21959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21959) Add ability to apply regular expressions to text fields in the batch item modification tool

  **Sponsored by** *City of Nîmes*

  >This adds a 'RegEx' link to the fields on the batch item modification form that allows you to rewrite the content of the fields using regular expressions. For example this could be used to add prefix or suffixes to callnumbers and barcodes  or to rewrite item URLs.
- [[23473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23473) Add option to import/overwrite passwords when using the patron import tool

  **Sponsored by** *ByWater Solutions*

  >This adds a new checkbox to the patron import tool that will allow to overwrite patrons' passwords with the password from the import file.
- [[24390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24390) Add item total to rotating collections (addItems.tt)

### Web services

- [[24384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24384) Add Access-Control-Allow-Origin support to OPAC reports svc

  >Using the foundations laid with bug 24369 this enhancement allows the CORS headers to be set on the OPAC Reports SVC routes.
- [[24537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24537) Add support for IP ranges in ILS-DI:AuthorizedIPs using Net::Netmask

  >It's now possible to not only allow a single IP, but multiple IPs, IP ranges and subnets access to the ILS-DI API.

### Z39.50 / SRU / OpenSearch Servers

- [[11297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11297) Add support for custom PQF attributes for Z39.50 server searches
- [[21921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21921) Add publication year to the Z39.50 search form for bibliographic records


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[24215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24215) Warnings about guarantor relationships show ARRAY errors

### Acquisitions

- [[17667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17667) Standing orders - cancelling a receipt increase the original quantity
- [[22868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22868) Circulation staff with suggestions_manage can have access to acquisition data
- [[24242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24242) Funds with no library assigned do not appear on edit suggestions page
- [[24244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24244) Cannot create suggestion with branch set to 'Any'
- [[24277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24277) Date Received in acquisitions cannot be changed
- [[24294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24294) Creating an order with ACQ framework using 00x fields doesn't work with default value
- [[24389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24389) Claiming an order can display an invalid successful message
- [[24672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24672) Error on receiving orders when there is an order with a deleted record
- [[25223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25223) Ordered.pl can have poor performance on large databases
- [[25473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25473) Can't add order from MARC file, save button does nothing
- [[25563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25563) Cannot submit "add order from MARC file" form after alert

### Architecture, internals, and plumbing

- [[13193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13193) Make Memcached usage fork safe

  **Sponsored by** *National Library of Finland*

  >*Important Note*: You will need to make sure you install `Cache::Memcached::Fast::Safe` to continue to use memcached after this.
- [[21674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21674) Data integrity not enforced for library groups
- [[21761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21761) Koha::Object supports passing through 'update' which means we can side step 'set' + 'store'
- [[22522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22522) API authentication breaks with updated Mojolicious version
- [[23185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23185) Koha::Objects supports passing through 'update' which means we can side step 'set' + 'store'
- [[23290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23290) XSLT system preferences allow administrators to exploit XML and XSLT vulnerabilities

  >This patchset refines the XSLT processing configuration such that we are more secure by disallowing the processing of external stylesheets by default and adding a configuration option to re-enable the functionality.
- [[24243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24243) Bad characters in MARC cause internal server error when searching catalog
- [[24263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24263) borrowers.relationship should not contain an empty string
- [[24552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24552) Koha does not work with Search::Elasticsearch 6.00
- [[24719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24719) C4::Context::set_remote_address() prevents file upload for non-Plack Koha
- [[24727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24727) Typo in circulation.js
- [[24741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24741) Recent creation of unique index on library_groups erroneously removes rows
- [[24754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24754) UserEnv not set for ISLDI requests
- [[24788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24788) Koha::Object->store calls column names as methods, relying on AUTOLOAD, with possibly surprising results
- [[25009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25009) opac-showmarc.pl allows fetching data directly from import batches
- [[25040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25040) Problematic current_timestamp syntax generated by DBIx::Class::Schema::Loader
- [[25131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25131) Web installer broken if enable_plugin is set
- [[25142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25142) Staff can access patrons' infos from outside of their group
- [[25481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25481) koha-plack not working under D10
- [[25485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25485) TinyMCE broken in Debian package installs
- [[25567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25567) borrower_attribute_types.category_code must be set to undef if not set
- [[25608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25608) (regression) Inventory is broken

### Authentication

- [[16719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16719) LDAP: Using empty strings as 'failsafe' attribute mapping defeats database constraints
- [[24673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24673) CSRF vulnerability in opac-messaging.pl
- [[24878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24878) Authentication check missing on calendar tools

### Cataloging

- [[13420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13420) Holdings table sorting on volume information incorrect
- [[24027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24027) Adding multiple items is slow
- [[25335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25335) Use of an authorised value in a marc subfield causes strict mode SQL error

### Circulation

- [[24138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24138) suspension miscalculated when Suspension charging interval bigger than 1 and Max. suspension duration  is defined
- [[24259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24259) Circulation fails if no circ rule defined but checkout override confirmed
- [[24441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24441) Error when checking in an item with BranchTansferLimitsType set to itemtype
- [[24474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24474) Lost items that are checked out are always returned, even when attempting to renew them
- [[24542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24542) Checkout page - Can't locate object method "search" via package "Koha::Account::DebitTypes"
- [[24669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24669) Editing circulation rule breaks holds when total holds unlimited

  **Sponsored by** *National Library of Finland*
- [[24765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24765) Updated on date in Claims returned starts off as 01/01/1970
- [[24802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24802) Updating holds can cause suspensions to apply to wrong hold
- [[25133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25133) Specify Due date changes from PM to AM if library has their TimeFormat set to 12hr
- [[25184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25184) Items with a negative notforloan status should not be captured for holds

  >**New system preference**: `TrapHoldsOnOrder` defaults to enabled.
- [[25418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25418) Backdated check out date loses time
- [[25531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25531) Patron may not be debarred if backdated return

### Command-line Utilities

- [[24164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24164) Patron emailer cronjob is not generating unique content for notices
- [[24527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24527) misc/cronjobs/update_totalissues.pl problem with multiple items
- [[25482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25482) Wrong permissions in spec break Plack on Debian 10

### Course reserves

- [[23727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23727) Editing course reserve items is broken
- [[24772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24772) Deactivating course reserves before deleting the same course empties/resets course reserve values in the items
- [[25444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25444) Course reserve settings are not saved on edit

### Database

- [[8132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8132) Batch delete tool deletes items with holds on them
- [[13518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13518) Table borrower_modifications is missing FK and not deleted with the patron
- [[24377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24377) Record branch in statistics for auto-renewal

### Fines and fees

- [[23443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23443) Paying off a lost fee will return the item, even if it is checked out to a different patron
- [[24146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24146) Paying Accruing Fines prior to return causes another accruing fine when returned
- [[24177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24177) Internal Server error when clicking cash register (Report)
- [[24339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24339) SIP codes are missing from the default payment_types on installation
- [[24477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24477) No permissions check for POS feature
- [[24481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24481) Incorrect permission in admin/cash_registers.pl
- [[24532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24532) Some account types are converted to debits when they shouldn't be
- [[24820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24820) The cashup workflow should use the static 'date' field rather than the transient 'timestamp' field in accountlines
- [[25123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25123) MaxFines does not count the current updating fine
- [[25127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25127) Fines with an amountoutstanding of 0 can be created due to maxFine but cannot be forgiven
- [[25139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25139) POS explodes in error when trying to display older transactions
- [[25389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25389) Inconsistent naming of account_credit_type for lost and returned items
- [[25417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25417) Backdating returns and forgiving fines causes and internal server error

### Hold requests

- [[20567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20567) "Holds per record (count)" limit is not enforced after item is captured for hold
- [[20948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20948) Item-level hold info displayed regardless its priority (detail.pl)
- [[21944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21944) Fix waiting holds at wrong location bug
- [[24168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24168) Errors with use of CanItemBeReserved return value
- [[24350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24350) Can't place holds
- [[24410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24410) Multi holds broken
- [[24485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24485) AllowHoldPolicyOverride should allow Staff to override the Holds Per Record Rule
- [[25516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25516) Item/pickup_locations wantarray removed, so dies on Perl >=5.24 where "autoderef" feature absent
- [[25556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25556) Holds blocked when empty holdallowed value present in circulation_rules

### I18N/L10N

- [[24365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24365) Using strict from TmplTokenizer.pm broke the translator script
- [[25305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25305) Double UTF-8 encoding on translation files
- [[25501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25501) Encoding issues in the translation process

### ILL

- [[24043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24043) ILL module can't show requests from more than one backend
- [[24565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24565) ILL requests do not display in patron profile in intranet

### Installation and upgrade (command-line installer)

- [[24316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24316) Fix non-English web installers by removing obsolete authorised value MANUAL_INV
- [[24445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24445) Add missing Z3950 updates to Makefile.PL
- [[24904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24904) New YAML files for installer are slow to insert
- [[25284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25284) Can't open /var/log/koha/kohadev/opac-error.log (Permission denied)

### Installation and upgrade (web-based installer)

- [[24137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24137) Marc21 bibliographic fails to install for ru-Ru and uk-UA
- [[24317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24317) Sample patron data not loading for non-English installations

### MARC Authority data support

- [[22437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22437) Subsequent authority merges in cron may cause biblios to lose authority information
- [[24421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24421) Generated authorities are missing subfields

### MARC Bibliographic record staging/import

- [[24348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24348) Record matching rules: required match checks does not work

### Notices

- [[24235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24235) /misc/cronjobs/advance_notices.pl DUEDGST does NOT send sms, just e-mail
- [[24268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24268) advance_notices.pl dies on undefined letter

### OPAC

- [[17896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17896) BakerTaylorEnabled is not plack safe in the OPAC
- [[24711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24711) Can't log in to OPAC after logout if OpacPublic disabled
- [[24803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24803) Clicking "Log in to your account" throws fatal Javascript error
- [[24874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24874) Printing is broken on opac-results.pl page
- [[24980]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24980) Date formatting from JS - use timezone only with dates with offset
- [[25024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25024) OPAC incorrectly marks branch as invalid pickup location when similarly named branch is blocked
- [[25086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25086) OPAC Self Registration - Field 'changed_fields' doesn't have a default value

  **Sponsored by** *Orex Digital*
- [[25137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25137) PatronSelfRegistrationLibraryList results in empty branch list on opac-memberentry.pl

### Packaging

- [[25068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25068) koha-common build error caused by missing /etc/searchengine
- [[25510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25510) Typo in koha-common.postinst causing shell errors
- [[25524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25524) Debian packages always append to /etc/koha/sites/$site/log4perl.conf
- [[25527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25527) Package does not build because of missing log4perl.conf
- [[25591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25591) Update list-deps for Debian 10 and Ubuntu 20.04

### Patrons

- [[5161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5161) Patron attributes clearing if duplicate warning
- [[14759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14759) Replacement for Text::Unaccent
- [[24964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24964) Do not filter patrons AFTER they have been fetched from the DB (when searching with permissions)
- [[24988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24988) autorenew_checkouts should default to yes

### REST API

- [[24191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24191) Sorting doesn't use to_model

  **Sponsored by** *ByWater Solutions*
- [[24432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24432) order_by broken for date columns
- [[24487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24487) build_query_params helper builds path parameter with matching criteria
- [[25411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25411) Plugin routes cannot have anonymous access

  **Sponsored by** *ByWater Solutions*

### Reports

- [[25000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25000) SQL report not updated

### SIP2

- [[23403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23403) SIP2 lends to wrong patron if cardnumber is missing
- [[23640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23640) L1 cache too long in SIP Server
- [[24175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24175) Cannot cancel holds - wrong parameter passed for itemnumber
- [[24800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24800) Koha does incomplete checkin when no return date is provided
- [[24966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24966) Fix calls to maybe_add where method call does not return a value

### Searching

- [[23970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23970) itemsearch - publication date not taken into account if not used in the first field
- [[24458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24458) Search results don't use Koha::Filter::MARC::ViewPolicy

### Searching - Elasticsearch

- [[23676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23676) Elasticsearch - 0 is not a valid boolean for suppress
- [[24123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24123) bulkmarcimport.pl doesn't support UTF-8 encoded MARCXML records
- [[24269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24269) Authority matching in Elasticsearch is broken when authority has subdivisions
- [[24286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24286) FindDuplicateAuthority does not escape forward slash in 'GENRE/FORM'
- [[24506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24506) Multibranch limit does not work with ElasticSearch
- [[25050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25050) Elasticsearch - authority indexing depends on mapping order
- [[25342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25342) Scripts not running under plack can cause duplication of ES records

### Serials

- [[21232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21232) Problems when linking a subscription to a non-existing biblionumber
- [[21901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21901) Foreign keys are missing on the serials and subscriptions tables
- [[25081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25081) new item for a received issue is (stochastically) not created

### Staff Client

- [[24482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24482) Purchase Items broken by costs containing a comma
- [[24858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24858) Incorrect labels on wording in ExcludeHolidaysFromMaxPickUpDelay system preference

### System Administration

- [[24329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24329) Patron cardnumber change times are lost during upgrade for bug 3820
- [[24670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24670) Circulation and fine rules page has performance issues since issuingrules change
- [[25601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25601) Error when unsetting default checkout, hold and return policy for a specific library
- [[25617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25617) Error on about page when TimeFormat preference is set to 12hr

### Templates

- [[24241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24241) Description missing for subpermission manage_accounts
- [[24713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24713) JavaScript error on staff client catalog search results page

  >This patch modifies the output of template toolkit variables so that values in the in-page JavaScript are quoted. This avoids JavaScript errors when the template variable is empty.

### Test Suite

- [[24817]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24817) Fix timing issues in t/db_dependant/Koha/Cash/Register.t

### Tools

- [[24900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24900) Fix 'MARC modification templates' to not assume that 'from field' will match 'conditional field'

  **Sponsored by** *Catalyst*

  >This patch ensures MARC modification template actions work as expected when the 'from field' doesn't match the 'conditional field'.

### Web services

- [[24531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24531) OAI-PMH set mappings only consider first field with a given tag
- [[24769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24769) DataTable error on patron hold page when hold placed (ILS-DI and other bugs)

  >This fixes a problem introduced by another patch in this release cycle. The patron's hold page now correctly lists holds where holds are placed using ILS-DI (and in some other situations).

### Z39.50 / SRU / OpenSearch Servers

- [[25277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25277) Z3950responder keyword search does not work with Elasticsearch 6


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[24136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24136) Update libraries (sponsors) on the about page
- [[24402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24402) Some roles missing from about page
- [[25506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25506) Perl undef warning on the "About Koha" page
- [[25592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25592) Add Devinim to about page

### Acquisitions

- [[5016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5016) Fix some terminology and wording issues on English PDF order templates
- [[9993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9993) On editing basket group delivery place resets to logged in library
- [[11161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11161) Relabel 'child fund' to 'sub fund'
- [[17611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17611) Searching for orders uses misleading column name "Pending order"
- [[21927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21927) Acq: Allow blank values in pull downs in the item form when subfield is mandatory
- [[22778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22778) Suggestions with no "suggester" can cause errors
- [[23031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23031) Restore 'Add to basket' as immediately accessible option on vendor search page
- [[23926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23926) In EDI Order limit GIR segment to five pieces of information
- [[24033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24033) Fix column labelling on basket summary page (ecost)
- [[24386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24386) Double submit should be prevented when adding to a basket
- [[24404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24404) Add missing space on invoices page
- [[24569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24569) Cannot add to basket if it is the only action
- [[24733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24733) Cannot search for duplicate orders using 'Basket created by' field
- [[25041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25041) Links to 'pending' #ASKED tab in suggestions.pl is broken
- [[25130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25130) Reason for accepting/rejecting a suggestion is not visible when viewing (not editing)

  **Sponsored by** *PTFS Europe*

### Architecture, internals, and plumbing

- [[14711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14711) C4::Reserves::AddReserves should take a hashref in parameters
- [[16922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16922) Add RewriteRule to apache-shared-intranet for dev package installs
- [[17532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17532) koha-shell -c does not propagate the error code

  >Before this development, the koha-shell script would always return a successful error code, making it hard for the callers to notice there was a problem with the command being run inside the instance's shell.
  >
  >This development makes koha-shell propagate the running scripts' error code so the caller can take the required actions.
  >
  >Note: this implies a behaviour change (for good) but a warning should be added to the release notes.
  >
  >Right now it always returns
- [[17845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17845) Printers related code should be removed
- [[18227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18227) Koha::Logger utf8 handling defeating "wide characters in print"
- [[18308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18308) Default value of minPasswordLength should be increased

  >This patch increases the value of minPasswordLength to 8 characters to encourage more secure passwords, for all new installs.
- [[18670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18670) RewriteLog and RewriteLogLevel unavailable in Apache 2.4
- [[19809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19809) Koha::Objects::find no longer need to be forbidden in list context
- [[20370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20370) Misleading comment for bcrypt - #encrypt it; Instead it should be #hash it

  **Sponsored by** *PTFS Europe*
- [[20882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20882) URI column in the items table is limited to 255 characters
- [[21684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21684) Koha::Object[s]->delete methods must behave identically as the corresponding DBIx::Class ones
- [[22098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22098) The stocknumberAV cataloguing plugin should be updated to use Koha::Objects
- [[22220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22220) Error in ReWriteRule for 'bib' in apache-shared-intranet.conf
- [[22685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22685) Koha::Acquisition::Bookseller methods should return Koha::Objects using the DBIx::Class relationships
- [[22943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22943) The in_ipset C4::Auth function name can be confusing

  **Sponsored by** *Catalyst*
- [[23084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23084) Replace grep {^$var$} with grep {$var eq $_}
- [[23384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23384) Calling Koha::Article::Status::* without "use" in Patron.pm can cause breakage
- [[23407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23407) XSLT Details pages don't use items, we shouldn't pass them
- [[23896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23896) logaction should pass the correct interface to Koha::Logger
- [[23974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23974) hours_between and days_between lack tests
- [[24016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24016) manager_id in Koha::Patron::Message->store should not depend on userenv alone

  **Sponsored by** *Koha-Suomi Oy*

  >Using `userenv` within Koha::* object classes is deprecated in favour of passing parameters.
- [[24018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24018) No need to die "Not logged in"
- [[24051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24051) batchMod.pl: DBIx::Class::ResultSet::search_rs(): search( %condition ) is deprecated
- [[24089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24089) Upgrade jQuery Validate plugin in the staff client
- [[24106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24106) In returns.pl, don't search for item if no barcode is provided
- [[24114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24114) Remove warn statements from Koha::Patrons
- [[24150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24150) Add missing Koha::Old::*[s] classes

  **Sponsored by** *Association KohaLa*
- [[24213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24213) Koha::Object->get_from_storage should return undef if the object has been deleted
- [[24217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24217) use strict for all modules
- [[24313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24313) XSLT errors should show in the logs
- [[24367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24367) With strict enabled, Search.t is too verbose
- [[24388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24388) Useless test in acqui/lateorders.tt
- [[24457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24457) K::A::Basket->to_api is not passing the parameters to the parent class implementation
- [[24459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24459) Overloaded ->to_api needs to pass $params through
- [[24538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24538) REMOTE_USER set to undef if koha_trusted_proxies contains invalid value
- [[24573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24573) Catmandu::Store::ElasticSearch and Catmandu::MARC are missing from cpanfile
- [[24595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24595) Warnings displayed by Circulation.t
- [[24602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24602) The fallback value for onshelfholds should be 0
- [[24643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24643) Koha::DateUtils::dt_from_string rfc3339 cannot handle high precision seconds
- [[24647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24647) PDF::API2::Simple is declared as a required dependency but it is not used
- [[24693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24693) GD is declared as an optional dependency but Koha dies without it
- [[24722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24722) reserves.priority must be NOT NULL
- [[24725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24725) xgettext does not support (yet) ES template literals
- [[24760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24760) BackgroundJob tests fail with latest versions of YAML or YAML::Syck
- [[24809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24809) OAI PMH can fail on fetching deleted records
- [[24815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24815) Koha::Cash::Register relations should return sets not undef
- [[24830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24830) dbic_merge_prefetch is not handling recursive cases correctly
- [[25006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25006) Koha::Item->as_marc_field generates undef subfields
- [[25008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25008) Koha::RecordProcessor->options doesn't refresh the filters
- [[25018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25018) Jenkins is not running the test with $ENV{_} eq 'prove'
- [[25019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25019) Non standard initialization in ViewPolicy filter
- [[25044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25044) No need to define koha_object[s]_class for standard object class names
- [[25095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25095) Remove warn left in FeePayment.pm
- [[25107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25107) Remove double passing of $server variable to maybe_add in C4::SIP::Sip::MsgType
- [[25311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25311) Better error handling when creating/updating a patron
- [[25423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25423) Methods update and empty from Koha::Objects are not class methods
- [[25535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25535) Hold API mapping maps cancellationdate to cancelation_date, but it should be cancellation_date

### Authentication

- [[24333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24333) AutoSelfCheckPass needs to be masked

### Cataloging

- [[5103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5103) Dates in MARC details not formatted correctly

  **Sponsored by** *Catalyst*

  >This fixes how dates are displayed for the list of items on the MARC view pages (in the OPAC and staff interface) and the add item page (staff interface) so that they use the 'dateformat' system preference.
- [[7947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7947) 440/490 Koha Mapping
- [[8595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8595) Link to 'host item' confusing

  **Sponsored by** *Catalyst*
- [[9156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9156) System preference itemcallnumber not pulling more than 2 subfields
- [[11446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11446) Authority not searching full corporate name with and (&) symbol
- [[11500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11500) Use dateformat syspref and datepicker on additems.pl (and other item cataloguing pages)
- [[13574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13574) Repeatable item subfields don't show correctly in MARC view (OPAC and staff)
- [[13775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13775) Set main headings to mandatory in authority frameworks
- [[15850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15850) Correct eslint errors in cataloging.js
- [[16683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16683) Help links to fields 59X in cataloguing form are broken

  >This fix updates the help links for 09x, 59x, and 69x fields in the basic and advanced MARC21 editor. The links now go to the correct Library of Congress documentation pages.
- [[17232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17232) When creating a new framework from an old one, several fields are not copies (important, link, default value, max length, is URL)
- [[17268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17268) Advanced cataloging editor - rancor - macros are lost when browser storage cleared
- [[18499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18499) Make 'Call number browser' on edit items screen use the correct item specific classification scheme
- [[19312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19312) Typo in UNIMARC field 121a plugin
- [[19313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19313) Typo in UNIMARC field 130 plugin
- [[21708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21708) Editing a record moves field 999 to first in the marcxml
- [[23777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23777) Text converted to html entity codes in cataloguing edit form
- [[23800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23800) Batch modification tool orders items by barcode incremental by default (regression to 17.11)
- [[23844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23844) Noisy warns in addbiblio.pl when importing from Z3950
- [[24090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24090) Subfield text in red when mandatory in record edition
- [[24185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24185) 'If all unavailable' state for 'on shelf holds' makes holds page very slow if there's a lot of items
- [[24232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24232) Fix permissions for deleting a bib record after attaching the last item to another bib
- [[24236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24236) Using quotes in a cataloging search, resulting in multiple pages, will not allow you to advance page
- [[24305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24305) Batch Item modification via item number in reports does not work with CONCAT in report
- [[24323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24323) Advanced editor - Invalid 008 with helper silently fails to save
- [[24420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24420) Cataloging search results Location column should account for waiting on hold items
- [[24423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24423) Broken link to return to record after batch item modification or deletion
- [[24503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24503) Missing use in value builder barcode_manual.pl
- [[24789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24789) Remove 'ITS' macro format

  >During the initial Rancor (advanced cataloging editor) development an existing macro language was copied. As development continued a Rancor macro language was developed. The new language accomplished all needs of the prior language. The old macro language was intended to be removed before submission to community, but was missed. These patches remove the legacy support in favour of the Koha specific model.
- [[25248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25248) Delete All Items should redirect to detail.pl, not additem.pl
- [[25308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25308) When cataloguing search fields are prefilled from record, content after & is cut off

### Circulation

- [[13557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13557) Add hint for on-site checkouts to list of current checkouts in OPAC
- [[15751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15751) Koha offline circulation Firefox addon does not update last seen date for check-ins
- [[23233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23233) AllowItemsOnHoldCheckout is misnamed and should only work for for SIP-based checkouts
- [[24085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24085) Double submission of forms on returns.pl
- [[24166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24166) Barcode removal breaks circulation.pl/moremember.pl
- [[24171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24171) Cannot do automatic renewal with itemBarcodeFallbackSearch
- [[24214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24214) Due date displayed in ISO format (when sticky)
- [[24257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24257) item-transfer-modal does not initiate transfer when 'yes, print slip' is selected
- [[24335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24335) Cannot mark checkout notes seen/not seen in bulk
- [[24337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24337) Checkout note cannot be marked seen if more than 20 exist
- [[24413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24413) MarkLostItemsAsReturned functionality does not lift restrictions caused by long overdues
- [[24456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24456) previousIssuesDefaultSortOrder and todaysIssuesDefaultSortOrder sort incorrectly
- [[24514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24514) Holds Awaiting Pickup sorting by title before surname
- [[24620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24620) Existing transfers not closed when hold is set to waiting
- [[24767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24767) "Claim returned" feature cannot be turned off
- [[24768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24768) "Return claims" column is missing from column configuration page
- [[24829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24829) ClaimReturnedWarningThreshold is always triggered if patron has one or more claims
- [[24839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24839) branchtransfers does not deal with holds
- [[24840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24840) Datetime issues in automatic_renewals / CanBookBeReserved
- [[25291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25291) Barcode should be escaped everywhere in html code
- [[25468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25468) Preserve line breaks in hold notes

### Command-line Utilities

- [[19465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19465) Allow choosing Elasticsearch server on instance creation
- [[20101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20101) Cronjob automatic_item_modification_by_age.pl does not log run in action logs
- [[21466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21466) Data inconsistencies - koha fields linked to AV cat values must have a corresponding authorised value
- [[22025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22025) Argument "" isn't numeric in numeric eq (==) at /usr/share/perl5/DBIx/Class/Row.pm line 1018 for /usr/share/koha/bin/import_patrons.pl
- [[24105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24105) Longoverdue gives error message when --itemtypes are specified
- [[24266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24266) Noisy error in reconcile_balances.pl

  **Sponsored by** *Horowhenua District Council*
- [[24324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24324) delete_records_via_leader.pl cron error with item deletion
- [[24397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24397) populate_db.pl is out of sync and must be removed
- [[24511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24511) Patron emailer report not using specified email column
- [[25157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25157) delete_patrons.pl is never quiet, even when run without -v
- [[25480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25480) koha-create may hide useful error

### Course reserves

- [[24283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24283) Missing close parens and closing strong tag in course reserves
- [[24750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24750) Instructor search does not return results if a comma is included after surname or if first name is included

### Database

- [[22273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22273) Column article_requests.created_on should not be updated
- [[24289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24289) Deleting branch will not delete entry in special or repeatable holidays
- [[24640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24640) quotes.timestamp should default to NULL

  >This fixes a problem with the QOTD tool - you can now add and edit quotes again.

### Developer documentation

- [[22335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22335) Comment on column suggestions.STATUS is not complete

### Documentation

- [[21633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21633) Did finesMode = test ever send email?
- [[25388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25388) There is no link for the "online help"

### Fines and fees

- [[21879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21879) Code cleaning in printinvoice.pl
- [[22359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22359) Improve usability of 'change calculation' (bug 11373)
- [[24208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24208) Remove change calculation for writeoffs
- [[24490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24490) Clarify wording and function of Purchase Items link on POS
- [[24495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24495) Reword change collection feature

  >This patch changes the text "Collect from patron" to "Amount tendered" for all payment options in the patron record, and in the Point of Sale screen.
- [[24525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24525) Hide SIP payment types from the Point of Sale page
- [[24790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24790) POS missing from the 'More' dropdown
- [[25119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25119) When paying or writing off a single fee, the account type doesn't display correctly
- [[25138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25138) Terminology: Point of sale should use library instead of branch

  >This fixes menu items and messages for the point of sale feature so that it uses 'library' instead of 'branch'.

### Hold requests

- [[19288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19288) Holds placed on a specific item after a next available hold will show varied results
- [[20708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20708) Withdrawn status should show when placing a request in staff client
- [[21296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21296) Suspend hold ignores system preference on intranet
- [[23934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23934) Item level holds not checked for LocalHoldsPriority in Holds Queue
- [[24510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24510) When placing a hold, cursor doesn't focus on patron name
- [[24688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24688) Hold priority isn't adjusted correctly if checking out a middle priority hold

  **Sponsored by** *Chartered Accountants Australia and New Zealand*
- [[24736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24736) "Enrollments" not correctly disabled when nobody is enrolled to a club yet
- [[25421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25421) Make Koha::Item and Koha::Biblio ->pickup_locations return an arrayref

### I18N/L10N

- [[18688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18688) Warnings about UTF-8 charset when creating a new language
- [[24046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24046) 'Activate filters' untranslatable
- [[24358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24358) "Bibliographic record does not exist!" is not translatable
- [[24636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24636) Acquisitions planning sections untranslatable
- [[24661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24661) Inclusion of locale-related javascript files is broken
- [[24734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24734) LangInstaller is looking in wrong directory for js files
- [[24808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24808) Untranslatable strings in results.js
- [[24870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24870) Translate installer data label
- [[24871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24871) Add new *-installer-*.po translation files
- [[25118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25118) Return claims has some translation issues
- [[25517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25517) Koha.mo not found on package installations / Translations not working

### ILL

- [[21270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21270) "Not finding what you're looking" display needs to be fixed
- [[24518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24518) Partner filtering does not work in IE11

### Installation and upgrade (command-line installer)

- [[17464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17464) Order deny,allow / Deny from all was deprecated in Apache 2.4 and is now a hard error
- [[24328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24328) Bibliographic frameworks fail to install
- [[24851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24851) No sample libraries for UNIMARC installations
- [[24856]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24856) invalid itemtypes.imageurl in fr-FR sample data
- [[24905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24905) log4perl-site.conf.in missing entries for the z39.50 server

### Installation and upgrade (web-based installer)

- [[24872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24872) Set languages system preferences after web install
- [[24897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24897) Remove es-ES installer data

### Label/patron card printing

- [[14369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14369) Only show 'Create labels' link on staged records import when status is 'Imported'
- [[23488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23488) Line wrapping doesn't always respect word order in Patron card creator
- [[23514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23514) Call numbers are not splitted in Label Creator with layout types other than Biblio
- [[23900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23900) Label maker cannot concatenate database fields

### MARC Authority data support

- [[24094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24094) Authority punctuation mismatch prevents linking to correct records
- [[24267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24267) C4::Breeding::ImportBreedingAuth is ineffective
- [[25428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25428) Escaped HTML shows in authority detail view when subfield is a link

### MARC Bibliographic data support

- [[17831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17831) Remove non-existing bibliosubject.subject mapping from frameworks
- [[22969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22969) fix biblionumber on 001 in UNIMARC XSLT
- [[23119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23119) MARC21 added title 246, 730 subfield i should display before subfield a

  **Sponsored by** *PTFS Europe*
- [[24274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24274) New installations should not contain field 01e Coded field error (RLIN)
- [[24281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24281) Fix the list of types of visual materials
- [[25082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25082) Unknown language code if 041 $a is linked to an authorized value list
- [[25410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25410) MARC21 out of sync intranet/opac subfield descriptions

### MARC Bibliographic record staging/import

- [[24827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24827) MARC preview fails when staged record contains items with UTF-8 characters

### Notices

- [[19014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19014) Patrons should not get an 'on_reserve' notification if the due date is far into the future
- [[23411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23411) SMS messages sent as print should not fall back to 'email'
- [[23787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23787) Add AUTO_RENEWALS in sample_notices.sql
- [[24378]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24378) Change wording on AUTO_RENEWALS notice in updatedatabase
- [[24612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24612) expirationdate blank if patron has more than one item from bib on hold
- [[24826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24826) Use of uninitialized value $mail{"Cc"} in substitution (s///) at /usr/share/perl5/Mail/Sendmail.pm

### OPAC

- [[13327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13327) OPACPopupAuthorsSearch doesn't work with XSLT views

  >This enhancement improves the OPACPopupAuthorsSearch feature so that it works in both the normal and XSLT views (OPACXSLTDetailsDisplay).
- [[17221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17221) Orphan comma in shelf browser

  **Sponsored by** *California College of the Arts*
- [[17697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17697) Improve NotesBlacklist system preference description to make clear where it will apply
- [[17853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17853) MARC21: Don't remove () from link text for 780/785
- [[17938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17938) XSLT: Label of 583 is repeated for multiple tags and private notes don't display in staff

  >This fixes the display for records with multiple 583s. Previously the label "Action note" was repeated, now the label appears once and multiple fields are separated by a |. There is now a space between $z and other subfields.
  >
  >Private notes are now displayed in the staff interface.
  >
  >Notes:
  >Indicator 1 = private: These will not display in the OPAC.
  >Indicator 1 = 0 or empty: These will display in the OPAC.
  >The staff interface  will display all 583s.
- [[18933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18933) Unable to set SMS number in OPAC messaging preferences to empty

  **Sponsored by** *Catalyst*
- [[22302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22302) ITEMTYPECAT description doesn't fall back to description if OPAC description is empty
- [[22515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22515) OPACViewOthersSuggestions if set to Show will only show when patron has made a suggestion
- [[22821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22821) Use reply-to address for item notes notifications if available to avoid being flagged as spam

  >Prior to this patch when a patron added an item note the system would send a notification email to the branchemail with a from address of the patrons email.
  >
  >This patch updates the notification system to use the 'reply-to' address in preference to the 'branchemail' if it is defined and it also sets the 'from' address to the 'branchemail' and adds the patron email as a 'reply-to' as this was the intended functionality.
- [[23383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23383) IdRef link appears even with syspref is off
- [[23482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23482) BakerTaylor images broken on OPAC lists
- [[23527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23527) BakerTaylorBookstoreURL is converted to escaped characters by template, rendering it invalid
- [[23785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23785) Software error Can't call method "get_coins" on an undefined value at /usr/share/koha/opac/cgi-bin/opac/opac-search.pl line 692.
- [[24061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24061) Print List (opac-shelves.pl) broken in Chrome
- [[24206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24206) Change URLs for default options in OPACSearchForTitleIn

  >Updates URLs for the default entries (sites now use https, and an update to the Open Library's URL search pattern).
- [[24212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24212) OPAC send list dialog opens too small in IE

  **Sponsored by** *Toi Ohomai Institute of Technology*
- [[24240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24240) List on opac missing close form tag under some conditions
- [[24245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24245) opac-registration-confirmation.tt has incorrect HTML body id
- [[24249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24249) OPAC lists page should require login for login-dependent operations

  >Enhancements to lists:
  >- Log in links to create a new list now take you to the 'Create a new list' form after you log in, instead of to your account summary page.
  >- Logging in is required for any action other the viewing public lists.
- [[24327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24327) Anonymous suggestions should not be allowed if AnonymousPatron misconfigured
- [[24345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24345) Fix process of suggesting purchase of existing title for non-logged-in users
- [[24371]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24371) OPAC 'Showing only available items/Show all items' is double encoded
- [[24486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24486) Account Wording Information is duplicated in Patron's Fines Tab on OPAC
- [[24523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24523) Fix opac-password-recovery markup mistake
- [[24560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24560) Don't show "Public Lists" in OPAC List menu if no public lists exist
- [[24605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24605) Series link from 830 is not uri encoded
- [[24654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24654) Trailing double-quote in RDA 264 subfield b on OPAC XSLT
- [[24676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24676) opac-auth.tt contains trivial HTML error
- [[24706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24706) Toolbar not rendered correctly when a list is empty
- [[24745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24745) OPAC news block plugin should evaluate as false if there are no items
- [[24746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24746) Duplicate id in opacheader markup
- [[24854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24854) Remove IDreamBooks integration
- [[24892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24892) Resolve some warnings in opac-memberentry
- [[24957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24957) OpenLibrarySearch shouldnt display if nothing is returned
- [[24996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24996) Unwanted CSS change unhides OPAC results sorting button
- [[25004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25004) Search results place hold button not enabled when checking result checkboxes on opac-search.pl
- [[25038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25038) OPAC reading history checkouts and on-site tabs not working
- [[25136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25136) PatronSelfRegistrationLibraryList controls both self-reg and self-modification
- [[25211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25211) Missing share icon on OPAC lists page
- [[25233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25233) Staff XSLT material type label "Book" should be "Text"
- [[25274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25274) JavaScript error in OPAC cart when more details are shown
- [[25276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25276) Correct hover style of list share button in the OPAC
- [[25340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25340) opac-review.pl doesn't show title when commenting

### Packaging

- [[17084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17084) Automatic debian/control updates (master)
- [[25618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25618) Upgrading Koha to packages made of latest master version breaks Z3950

### Patrons

- [[18680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18680) sort1/sort1 dropdowns (when mapped to authorized value) have no empty entry
- [[19791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19791) Patron Modification log redirects to circulation page
- [[21211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21211) Patron toolbar does not appear on all tabs in patron account in staff
- [[23808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23808) Creating Child Guarantee doesn't populate Guarantor Information

  **Sponsored by** *South Taranaki District Council*
- [[24666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24666) Non Koha Guarantors should be able to be seen from the Patron Detail page
- [[24962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24962) Don't show floating toolbar when duplicate patron record was detected
- [[25046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25046) C4::Utils::DataTables::Members does not SELECT othernames from borrowers table

  **Sponsored by** *Eugenides Foundation Library*
- [[25069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25069) AddressFormat="fr" behavior is broken
- [[25299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25299) Date not showing on Details page when patron is going to expire
- [[25300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25300) Edit details in "Library use" section uses bad $op for Expiration Date
- [[25301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25301) Category code is blank when renewing or editing expired/expiring patron
- [[25309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25309) Unable to save patron if streetnumber is too long
- [[25452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25452) Alternate email contact not displayed

### Plugin architecture

- [[25099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25099) Sending a LANG variable to plug-in template

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

### REST API

- [[24366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24366) Merging biblioitems should happen in Koha::Biblio->to_api
- [[24462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24462) Adjust K::A::Invoice API mapping to voted RFC
- [[24554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24554) Only embed relations from Koha::Biblio in to_api
- [[24611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24611) Wrong budget_id query parameter in /acquisitions/orders
- [[24680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24680) Hold modification endpoints don't always work properly
- [[24862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24862) Wrong behaviour on anonymous sessions

  **Sponsored by** *ByWater Solutions*
- [[24918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24918) Wrong attribute mappings in Koha::Acquisition::Basket
- [[25048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25048) Successful resource deletion should return 204
- [[25327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25327) Cannot access API spec
- [[25493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25493) Koha::Logger is not suitable for using as Mojo::Log
- [[25502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25502) /advanced_editor/macros doesn't follow coding guidelines

### Reports

- [[13806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13806) No input sanitization where creating Reports subgroup
- [[24614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24614) Can't edit reports if not using cache
- [[24940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24940) Serials statistics wizard: order vendor list alphabetically
- [[24959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24959) Fix id/label pairs in saved reports table
- [[24976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24976) Guided report - "Save" button on last step is misleading

  **Sponsored by** *PTFS Europe*

### SIP2

- [[24250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24250) SIP2 returns debarred comment twice in patron screen message AF field
- [[24449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24449) SIP2 - too_many_overdue flag is not implemented
- [[24553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24553) Cancelling hold via SIP returns a failed response even when cancellation succeeds
- [[24566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24566) UpdateItemLocationOnCheckin triggers SIP2 alert flag, even with checked_in_ok enabled
- [[24629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24629) SIP2 logs garbage
- [[24705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24705) Holds placed via SIP will be given first priority
- [[24993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24993) koha-sip --restart is too fast, doesn't always start SIP
- [[25227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25227) SIP server returns wrong error message if item was lost and not checked out

### Searching

- [[10879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10879) OverDrive should check for OverDriveLibraryID before performing search
- [[15142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15142) Titles facet does not work in UNIMARC
- [[19279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19279) Performance of linked items in search
- [[22937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22937) Searching by library groups uses  group Title rather than Description
- [[23081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23081) Make items.issues and deleteditems.issues default to 0 instead of null
- [[24121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24121) Item types icons in intra search results are requesting icons from opac images path

  **Sponsored by** *Governo Regional dos Açores*
- [[24219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24219) Elasticsearch needs to remember sort preference when returning to result list
- [[24443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24443) Consider NULL as 0 for issues in items search

### Searching - Elasticsearch

- [[17885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17885) Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings throws DBD::mysql Duplicate entry exceptions
- [[22426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22426) Elasticsearch - Index location is missing in advanced search
- [[22771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22771) Sort by title does not consider second indicator of field 245 (MARC21)

  >This Elasticsearch enhancement strips the initial characters from search fields in accordance with nonfiling character indicators.
- [[23521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23521) ES 6 - limit terms with many words can make the search inaccurate
- [[24128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24128) Add alias for biblionumber => local-number
- [[24902]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24902) Elasticsearch - different limits are joined with OR instead of AND
- [[25229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25229) Elasticsearch should use the authid (record id) rather than the 001 when returning auth search results
- [[25278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25278) Search fields cache must be separate for different indexes under Elasticsearch
- [[25325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25325) ElasticSearch mapping export lacks staff_client/opac fields

### Searching - Zebra

- [[25149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25149) The Zebra language option for Greek should be 'el', not 'gr'

  >Please note that the configuration file (/etc/koha/koha-sites.conf) of existing installations that have been set up using ZEBRA_LANGUAGE="gr" will not be affected by this change.

### Self checkout

- [[21250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21250) Auto-self-checkout not fully compatible with multi-branch library setup
- [[21565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21565) SCO checkout confirm should be modal

### Serials

- [[7046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7046) subscription renewal period should be a pull down

  >This enhancement changes the form for the serials renewal period for a subscription into a drop down list - this is consistent with the create subscription form.
- [[7047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7047) Renewing serials note not visible
- [[23064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23064) Cannot edit subscription with strict SQL modes turned on
- [[23888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23888) Incorrect vendor id in subscription creation causes internal server error
- [[24903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24903) Special characters like parentheses in numbering pattern cause duplication in recievedlist
- [[24941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24941) Serials: Link to basket in acqusition details is broken

### Staff Client

- [[13305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13305) Fix tab order in cataloguing/item editor
- [[20501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20501) Unhighlight in search results when the search terms contain the same word twice removes the word
- [[22381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22381) Wording on Calendar-related system preferences not standardized
- [[23246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23246) Record detail page jumps into the 'images' tab if no holdings

  **Sponsored by** *American Numismatics Society*
- [[23987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23987) batchMod.pl provides a link back to the record after the record is deleted
- [[24515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24515) Column Configuration for pay-fines-table does not hide Account Type properly
- [[24516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24516) Column Configuration does not hide Return Date

  >This fixes an issue where hiding the return date column for the "Pay Fines" and "Account Fines" screens does not work.
- [[24540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24540) Unexpected behaviour on 'enter' in point of sale payment fields
- [[24549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24549) Cookies for last patron link are always set - even if showLastPatron is turned off
- [[24646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24646) RoundFinesAtPayment is not a self check in preference
- [[24649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24649) Cloning item subfields misses a <li> tag
- [[24747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24747) Library Transfer Limit page incorrectly describes its behavior
- [[24838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24838) Help link from patron categories should go to relevant manual page
- [[24848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24848) Help link from label creator batch/layout/template points to card creator in manual
- [[25007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25007) AmazonCoverImages doesnt check for ISBN in details.tt

  >This fixes the display of cover images in the staff interface where there is no ISBN and both Amazon and local cover images are enabled.
  >
  >Covers different combinations:
  >- Amazon cover present, no local cover.
  >- No Amazon cover, local cover image present.
  >- Both Amazon and local cover image present.
- [[25022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25022) Display problem in authority editor with repeatable field
- [[25072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25072) Printing details.tt is broken
- [[25224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25224) Add "Large Print" from 008 position 23 to default XSLT

### System Administration

- [[10561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10561) DisplayOPACiconsXSLT and DisplayIconsXSLT descriptions should be clearer
- [[17355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17355) Authorised value categories cannot be deleted
- [[24025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24025) Make CodeMirror content searchable
- [[24170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24170) sysprefs search result does not have a consistent order
- [[24184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24184) Reword FallbackToSMSIfNoEmail syspref text
- [[24394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24394) Typo when adding a new cash register
- [[24395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24395) Floats in cash registers have 6 decimals
- [[24682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24682) Clarify UsageStatsGeolocation syspref description and behaviour
- [[25005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25005) Admin Rights issue for Suggestion to Purchase
- [[25120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25120) In system preference editor first tab is now Accounting and not Acquisitions

### Templates

- [[11281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11281) Add column configuration to 'Holds awaiting pickup' tables allowing to print both tables separately
- [[23113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23113) members/pay.tt account_grp is not longer used

  >This patch removes markup that is no longer required in the pay.tt template (this template is used in the accounting section for patrons).
- [[23433]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23433) Make consistent use of patron-title.inc in hold confirmation dialogs
- [[23536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23536) Remove obsolete category markup from patron entry
- [[23753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23753) Add missing humanMsg library to pages using background job JavaScript
- [[23885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23885) Move staff client search results JavaScript into separate file

  >As part of the coding guidelines (JS1 - Whenever possible JavaScript should be placed in a separate file), this patch patch moves most of the JavaScript embedded in results.tt for the staff interface into a separate file.
- [[23944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23944) Phase out use of jquery.cookie.js in favor of js.cookie.js
- [[23947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23947) Phase out jquery.cookie.js: Authority merge
- [[23956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23956) Replace famfamfam calendar icon in staff client with CSS data-url
- [[23957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23957) Remove button style with famfamfam icon background and replace with Font Awesome
- [[24053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24053) Typo in FinePaymentAutoPopup description
- [[24054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24054) Typo in ClaimReturnedWarningThreshold system preference
- [[24056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24056) Capitalization: Cash Register ID on cash register management page
- [[24057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24057) Hea is not an acronym
- [[24059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24059) Remove unused Greybox assets from detail.tt
- [[24098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24098) Standardize Fines/Fees & Charges

  >This patch implements a terminology change - using 'charges' instead of 'fines' or 'fees' (this is also the same terminology used in the OPAC).
- [[24104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24104) Item search - dropdown buttons overflow
- [[24110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24110) Template vars are incorrectly html filtered when dumped
- [[24126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24126) Article requests tab appears twice on patron's checkout screen
- [[24169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24169) Advanced editor: icons/buttons for sorting the search results are missing
- [[24230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24230) intranet_js plugin hook is after body end tag
- [[24282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24282) SCSS conversion broke style in search results item status
- [[24363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24363) Datepicker calendar is not always sexy

  >This bug fixes display issues with the date picker and some other style changes that were inadvertently introduced by bug 24181.
- [[24373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24373) Correct basic cataloging editor CSS
- [[24391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24391) Remove event attributes from patron clubs edit template
- [[24393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24393) Remove event attributes from patron clubs list template
- [[24433]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24433) OPAC account page no longer asks for confirmation before deleting hold
- [[24619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24619) Phase out jquery.cookie.js: MARC Frameworks
- [[24621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24621) Phase out jquery.cookie.js: Basic MARC editor
- [[24627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24627) Correct style of clubs search results during hold process
- [[24776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24776) Remove useless Borrowers Template Toolkit plugin
- [[24777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24777) Use patron.is_debarred instead of patron.debarred in return.tt
- [[24798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24798) smart-rules.tt has erroneous comments
- [[24875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24875) Remove extra punctuation from tools home page
- [[24876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24876) Fix capitalization on patron search for holds
- [[24886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24886) Reports template should be reindented
- [[24939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24939) Labels in system preferences not following capitalization rules
- [[24963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24963) Terminology: auto renewal, auto-renewal or autorenewal?
- [[25002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25002) JS Includes should be wrapped with template comments
- [[25010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25010) Fix typo in debit type description: rewewal
- [[25012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25012) Fix class on OPAC view link in staff detail page
- [[25013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25013) Fix capitalization: Edit Items on batch item edit
- [[25014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25014) Capitalization: Call Number in sort options in staff and OPAC
- [[25016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25016) Coce should not return a 1-pixel Amazon cover image

  >This patch improves the display of cover images where Coce is enabled and Amazon is a source. Where the image from Amazon is a 1x1 pixel placeholder (meaning Amazon has no image) it is no longer displayed.
- [[25176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25176) Styling problem with checkout form
- [[25186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25186) Lots of white space at the bottom of each tab on columns configuration
- [[25282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25282) Menu for Action menubutton in dataTables like MARC frameworks page separated from the button
- [[25343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25343) Use of item in review/comment feature is misleading
- [[25409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25409) Required dropdown missing "required" class near label

### Test Suite

- [[22860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22860) Selenium tests authentication.t does not remove all data it created
- [[22898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22898) Selenium tests for placing holds from the staff interface
- [[23274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23274) t/db_dependent/XISBN.t fails with Elasticsearch
- [[24002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24002) Test suite is failing on MySQL 8
- [[24144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24144) regressions.t tests have not been updated after bug 23836
- [[24145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24145) Auth.t is failing because of wrong mocked ->param
- [[24199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24199) t/Auth_with_shibboleth.t is failing randomly
- [[24200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24200) Borrower_PrevCheckout.t failing randomly
- [[24229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24229) /items API tests fail on Ubuntu 18.04
- [[24361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24361) Fix warnings (or failing tests) from bug 24217
- [[24396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24396) Suggestions.t is failing with MySQL 8
- [[24408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24408) Comparing floats in tests should not care about precision
- [[24494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24494) 00-valid-xml.t shouldn't check node_modules
- [[24507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24507) Checkouts/ReturnClaim.t is failing on MySQL 8
- [[24509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24509) API related tests failing on MySQL8
- [[24543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24543) Wrong test in api/v1/checkouts.t
- [[24546]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24546) Club/Hold.t has a wrong call to build_sample_item
- [[24590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24590) Koha/Object.t is failing on MySQL 8
- [[24657]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24657) Fix tests of bug 22284 - Groups of pickup locations for holds
- [[24739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24739) Buster ships with Net::Netmask 1.9104 which supports IPv6
- [[24753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24753) Typo in filepath for test t/Koha/Middlware/RealIP.t
- [[24756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24756) Occasional failures for Koha/XSLT/Security.t
- [[24757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24757) t/db_dependent/Koha/Patrons.t get_age fails on February 28 in a Leap Year
- [[24801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24801) selenium/administration_tasks.t failing if too many categories/libraries displayed
- [[24813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24813) api/v1/holds.t is failing randomly
- [[24881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24881) Circulation.t still fails if tests are ran slowly
- [[24901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24901) C4::Circulation::transferbook lacks tests
- [[25513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25513) Integer casting in Koha::Object->TO_JSON causes random test failures
- [[25540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25540) Biblio.t is failing randomly

### Tools

- [[9422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9422) Patron picture uploader ignores patronimages syspref
- [[10352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10352) Cataloguing log search mixing itemnumber/bibnumber
- [[14647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14647) When exporting records, the file name extension should match the selected export format

  **Sponsored by** *Catalyst*

  >This enhancement to the catalog export data tool automatically changes the file extension in the file name to the selected export format (such as as CSV, or XML), rather than leaving it as .mrc.
- [[17510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17510) MARC modification templates ignore subfield $0
- [[19475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19475) Calendar copy creates duplicates

  **Sponsored by** *Koha-Suomi Oy*
- [[22245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22245) MARC modification templates does not allow move or copy control fields
- [[23236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23236) Remove 'its items may still be processed' in action if no match is found
- [[23377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23377) bulkmarcimport.pl disables syspref caching
- [[24124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24124) Cannot select authorities in batch deletion tool in Chrome
- [[24275]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24275) Inventory table should be sortable by title without leading articles (allow for title sort with anti-the)
- [[24330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24330) When importing patrons from CSV, automatically strip BOM from file if it exists
- [[24484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24484) Add explanatory text to batch patron deletion

  **Sponsored by** *PTFS Europe*
- [[24497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24497) CodeMirror indentation problems
- [[24764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24764) TinyMCE shouldnt do automatic code cleanup when editing HTML in News Feature
- [[24982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24982) Update the log viewer to use checkboxes instead of select lists

  **Sponsored by** *Catalyst*

  >This patch changes the dropdowns in the Log viewer to checkboxes so that the user can see all of their available options and select multiple options more easily.
- [[25020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25020) Extending due dates to a specified date should preserve time portion of original due date
- [[25247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25247) Exporting 'modification log' to a file should not send objects
- [[25249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25249) When viewing a patron's modification log we should see both the MEMBERS and CIRCULATION modules
- [[25250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25250) JS code for checkboxes also affects hidden modules inputs

### Web services

- [[23531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23531) ILS-DI doesn't implement needed_before_date and pickup_expiry_date parameters (renamed start_date and expiry_date)

  >This patch implements the documented "start_date" and "expiry_date" parameters for hold requests using Koha's ILS-DI service.
  >
  >Note: the previously documented but not implemented parameter names were changed: 
  >- needed_before_date => start_date
  >- pickup_expiry_date => expiry_date

## Technical highlights

Some significant technical changes were made behind the scenes in this release and it was felt that they should be additionally highlighted in the notes as they could be easily missed above.

### Refactoring

- C4::Members::Attributes has been moved to Koha::Patron::Attributes.
   - GetBorrowerAttributeValue has been replaced by Koha::Patron-&gt;get_extended_attribute_value
   - GetBorrowerAttributes has been replaced by Koha::Patron-&gt;get_extended_attributes
   - DeleteBorrowerAttribute has been replaced by Koha::Patron-&gt;get_extended_attribute-&gt;delete
   - UpdateBorrowerAttribute and SetBorrowerAttributes has been replaced by Koha::Patron-&gt;extended_attributes($attributes)
   - C4::Members::AttributeTypes::GetAttributeTypes has been replaced by Koha::Patron::Attribute::Types-&gt;filter_by_branch_limitations
- C4::Items CRUD subroutines have moved to Koha::Item
   - Pay special attention to Koha::Item-&gt;store,-&gt;delete and-&gt;safe_delete
- QueryParser has been completely removed from the codebase
- The issuingrules table has been completely removed in favour of using the new circulation_rules table. Please use Koha::CirculationRules now
- Dependancy management has been moved from the customer Koha code into a cpanfile

### Dev tools

A number of developer tools and processes have been refined
- misc/devel/update_dbix_class_files.pl learned a new option --koha-conf to use values from koha-conf.xml so you are not required to always append parameters now to run the script
- The installer files are now translatable using the pootle process
   - A new YAML format has been migrated to for the installer files
   - A new command line script may be used to load the new yaml formatted installer files manually where required
   - Work is ongoing to migrate and remove the original .SQL files which are still supported during the period of the migration (bug 24897 is a good example of the process)
   - Work is underway to add a 'localization' process to the installer allowing for localization to be applied distinctly to translation

- Strings found inside JavaScript are now directly translatable

  >Prior to bug 21156 a translatable string would have taken the form
  >
  >`var my_string = _("my string");` # Within the .tt
  >
  >`alert(my_string);` # Within the .js
  >
  >Now we can simply use
  >
  >`alert(__("my string");` # Note the double underscore

- The database update script now outputs timestamps and skeleton.perl has an updated simplified syntax to follow
- Koha::Script added support for simple execution locking: fines.pl is a good example of how to utilise the new functionality

### Plugins support

A number of improvements have been made to the plugins system to allows better discoverability and code interaction
- One can configure the new `plugin_repos` config option to point to their github organisation to allow plugins to be discovered by end users in the koha staff client
- Additional hooks have been added in this release, please see the 'Plugin architecture' section above.

### API Enhancements

The code that is used to implement the REST API has seen many relevant structural changes on this release.

Several generic methods have been added to the Koha::Object(s) classes:
- to_api [[23770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23770) [[23843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23843)
- new_from_api [[23893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23893)
- set_from_api [[23893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23893)
- attributes_from_api
- from_api_mapping

They are designed to simplify DB &lt;-&gt; API attribute name mapping. They allowed us to make our controllers thin and really simple to read and understand (and thus maintain). Tests become easier to write as well.
One of the goals behind this move to Koha::Object-level, was that we intended to embed arbitrary data on the responses. So the attribute mapping responsibility (between the DB and our OpenAPI spec) was moved from the controllers to the Koha::Object(s) level (i.e. for an arbitrary object you can now ask for its API representation like in $patron-&gt;to_api).

This 'to_api' method is designed to be passed parameters. Right now it only accepts the 'embed' parameter which expects a hashref representing the recursive data structures we would like to embed in the object representation (see POD for more details). For example: my $api = $patron-&gt;to_api({ embed =&gt; { children =&gt; { checkouts =&gt; {} } } }) will make the resulting $api variable contain the representation of the Koha::Patron object, with the added 'checkouts' attribute, which will be the result of calling $patron-&gt;checkouts-&gt;to_api and so on (if more nested objects need to be included). [[24228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24228). A special syntax has been added for requiring counts (for result sets). And there is a plan to add a 'for_opac' parameter so we know what kind of representation we need to generate. There's been some discussion about having a 'brief' representation of objects as well, for some use cases but that's an ongoing discussion.

The API spec got its counter-part additions: an 'x-koha-embed' attribute that specifies what things are allowed to be requested for embedding on a route. A special syntax was added to request counts (for example, x-koha-embed: [ checkouts+count] will be interpreted as a request to get the count, and will be placed in an attribute called checkouts_count) [[24302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24302) [[24321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24321) [[24528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24528).

Now we are embedding things, it was natural to think we would like to:
- automatically build DBIC queries that would prefetch the required tables [[24356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24356)
- filter by those nested objects in a WHERE condition [[[24487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24487)](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24487)
- order by those nested properties [[24615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24615)

All the above features have been introduced as well.

And the last bit, we introduced a 'q' parameter that allows building DBIC-ish queries on the resources we are fetching, as well as on the nested resources. [[24487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24487) [[24502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24502)

## New sysprefs

- AccessControlAllowOrigin
- AllowItemsOnHoldCheckoutSIP
- AllowPatronToControlAutorenewal
- AuthFailureLog
- AuthSuccessLog
- CalculateFinesOnBackdate
- CirculateILL
- CollapseFieldsPatronAddForm
- DumpSearchQueryTemplate
- EnablePointOfSale
- IllCheckAvailability
- MaxTotalSuggestions
- NumberOfSuggestionDays
- OPACReportProblem
- OPACnumSearchResultsDropdown
- OpacBrowseSearch
- OpacNoItemTypeImages
- PatronSelfRegistrationConfirmEmail
- PrefillGuaranteeField
- RESTPublicAnonymousRequests
- RenewAccruingItemInOpac
- RenewAccruingItemWhenPaid
- SCOAllowCheckin
- TrapHoldsOnOrder
- UseCirculationDesks
- numSearchResultsDropdown

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/20.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (84.9%)
- Armenian (100%)
- Chinese (Taiwan) (89.1%)
- Czech (81.4%)
- English (New Zealand) (68.2%)
- English (USA)
- Finnish (70.2%)
- French (90.5%)
- French (Canada) (89.5%)
- German (100%)
- German (Switzerland) (76%)
- Greek (61%)
- Hindi (100%)
- Italian (81.8%)
- Norwegian Bokmål (79.9%)
- Polish (74.9%)
- Portuguese (86.7%)
- Portuguese (Brazil) (88%)
- Slovak (71.5%)
- Spanish (100%)
- Swedish (79.3%)
- Turkish (91.6%)
- Ukrainian (71.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.00 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathan Druart

- QA Manager: Katrin Fischer

- QA Team:
  - Jonathan Druart
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall

- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ILS-DI -- Arthur Suzuki
  - UI Design -- Owen Leonard
  - ILL -- Andrew Isherwood

- Bug Wranglers:
  - Michal Denár
  - Cori Lynn Arnold
  - Lisette Scheer
  - Amit Gupta

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Sugandha Bajaj

- Translation Manager: Bernardo González Kriegel


- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley

- Release Maintainer mentors:
  - 19.11 -- Martin Renvoize
  - 19.05 -- Nick Clemens
  - 18.11 -- Chris Cormack

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 20.05.00:

- American Numismatics Society
- [Association KohaLa](https://koha-fr.org/)
- Athens County Public Libraries
- Athlone Institute of Technology
- BibLibre
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)
- [Bibliothèque Universitaire des Langues et Civilisations (BULAC)](http://www.bulac.fr/)
- [ByWater Solutions](https://bywatersolutions.com/)
- California College of the Arts
- Camden County
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- [Centre collégial des services regroupés](http://www.ccsr.qc.ca)
- Chartered Accountants Australia and New Zealand
- Cheshire Libraries Shared Services
- City of Nîmes
- Cork Institute of Technology
- Eugenides Foundation Library
- Governo Regional dos Açores
- Horowhenua District Council
- Hypernova Oy
- Institute of Technology Tralee
- Koha-Suomi Oy
- Loughborough University
- National Library of Finland
- Orex Digital
- [PTFS Europe](https://ptfs-europe.com)
- Public Health England
- Region Halland
- South Taranaki District Council
- Toi Ohomai Institute of Technology
- Universidad ORT Uruguay
- Université Jean Moulin Lyon 3
- [Vermont Organization of Koha Automated Libraries](http://gmlc.org/index.php/vokal)
- Waitaki Distict Council

We thank the following individuals who contributed patches to Koha 20.05.00.

- Aleisha Amohia (35)
- Pedro Amorim (1)
- Tomás Cohen Arazi (190)
- Alex Arnaud (12)
- Cori Lynn Arnold (2)
- Oliver Behnke (2)
- Philippe Blouin (1)
- David Bourgault (4)
- Christopher Brannon (5)
- Alex Buckley (7)
- Colin Campbell (1)
- Nick Clemens (173)
- David Cook (18)
- Simith D'oliveira (1)
- Frédéric Demians (2)
- Jonathan Druart (634)
- Gus Ellerm (1)
- Magnus Enger (3)
- Charles Farmer (5)
- Katrin Fischer (108)
- Andrew Fuerste-Henry (8)
- Lucas Gass (28)
- Didier Gautheron (3)
- Victor Grousset (1)
- David Gustafsson (6)
- Kyle Hall (75)
- Rogan Hamby (2)
- Mehdi Hamidi (1)
- Andrew Isherwood (27)
- Mason James (5)
- Andreas Jonsson (2)
- Janusz Kaczmarek (1)
- Pasi Kallinen (1)
- Olli-Antti Kivilahti (1)
- Ulrich Kleiber (1)
- Bernardo González Kriegel (50)
- David Kuhn (1)
- Joonas Kylmälä (19)
- Nicolas Legrand (4)
- Owen Leonard (118)
- Ere Maijala (5)
- Hayley Mapley (1)
- Julian Maurice (24)
- Kelly McElligott (1)
- Grace McKenzie (1)
- Matthias Meusburger (6)
- Josef Moravec (20)
- Agustín Moyano (39)
- David Nind (1)
- Andrew Nugged (5)
- Eric Phetteplace (1)
- Liz Rea (4)
- Martin Renvoize (433)
- Phil Ringnalda (4)
- David Roberts (17)
- Marcel de Rooy (87)
- Caroline Cyr La Rose (6)
- Andreas Roussos (6)
- Lisette Scheer (4)
- Robin Sheat (1)
- Slava Shishkin (3)
- Joe Sikowitz (1)
- Maryse Simard (13)
- Fridolin Somers (33)
- Arthur Suzuki (2)
- Emmi Takkinen (3)
- Lari Taskula (4)
- Theodoros Theodoropoulos (1)
- Pierre-Marc Thibault (1)
- Mirko Tietgen (1)
- Mark Tompsett (1)
- Koha Translators (2)
- Petro Vashchuk (4)
- George Veranis (2)
- Ian Walls (1)
- Jesse Weaver (6)
- Mengü Yazıcıoğlu (3)
- Nazlı Çetin (6)
- Radek Šiman (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.00

- Aristotle University Of Thessaloniki (Αριστοτέλειο Πανεπιστήμιο Θεσσαλονίκης) (1)
- Athens County Public Libraries (118)
- BibLibre (79)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (109)
- Bibliothèque Universitaire des Langues et Civilisations (BULAC) (4)
- ByWater-Solutions (286)
- Catalyst (9)
- Chetco Community Public Library (4)
- Coeur D'Alene Public Library (5)
- Dataly Tech (6)
- David Nind (1)
- Devinim (9)
- Equinox Open Library Initiative (1)
- Fenway Library Organization (1)
- Göteborgs Universitet (6)
- Hypernova Oy (4)
- Independant Individuals (95)
- Koha Community Developers (636)
- Koha-Suomi (1)
- KohaAloha (5)
- Kreablo AB (2)
- Latah County Library District (1)
- Libriotech (3)
- Max Planck Institute for Gravitational Physics (2)
- Mirko Tietgen (1)
- Prosentient Systems (18)
- PTFS-Europe (478)
- R-Bit Technology (1)
- Rijks Museum (85)
- Solutions inLibro inc (32)
- Tamil (2)
- The Donohue Group (2)
- Theke Solutions (229)
- Universidad Nacional de Córdoba (50)
- University of Helsinki (24)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (3)
- Aleisha Amohia (4)
- Tomás Cohen Arazi (148)
- Alex Arnaud (2)
- Cori Lynn Arnold (4)
- Donna Bachowski (2)
- Bob Bennhoff (1)
- Sonia Bouis (3)
- Christopher Brannon (1)
- Alex Buckley (1)
- Nick Clemens (202)
- Kevin Cook (1)
- David Cook (12)
- Holly Cooper (9)
- Chris Cormack (4)
- Christophe Croullebois (1)
- Gabriel DeCarufel (3)
- Frédéric Demians (10)
- Michal Denar (32)
- Angela O'Connor Desmond (10)
- Jonathan Druart (562)
- Maxime Dufresne (2)
- Clemens Elmlinger (2)
- Nicole Engard (1)
- Magnus Enger (6)
- Bouzid Fergani (23)
- Katrin Fischer (472)
- Mathilde Formery (3)
- William Frazilien (1)
- Martha Fuerst (4)
- Andrew Fuerste-Henry (77)
- Brendan Gallagher (1)
- Lucas Gass (29)
- Didier Gautheron (5)
- Victor Grousset (62)
- Kyle Hall (230)
- Stina Hallin (3)
- Frank Hansen (1)
- Lucy Harrison (3)
- Sally Healey (26)
- Felix Hemme (1)
- Heather Hernandez (8)
- Abbey Holt (2)
- Catherine Ingram (1)
- Andrew Isherwood (12)
- Mason James (4)
- Dilan Johnpullé (2)
- Barbara Johnson (2)
- Daniel Jones (1)
- Minna Kivinen (40)
- Jon Knight (10)
- Bernardo González Kriegel (114)
- Rhonda Kuiper (2)
- Joonas Kylmälä (54)
- Nicolas Legrand (1)
- Owen Leonard (73)
- Ere Maijala (11)
- Hayley Mapley (17)
- Ron Marion (1)
- Julian Maurice (5)
- Kelly McElligott (25)
- Matthias Meusburger (2)
- Josef Moravec (70)
- Agustín Moyano (2)
- David Nind (247)
- Hannah Olsen (3)
- Guillaume Paquet (1)
- Hans Pålsson (2)
- Séverine Queune (43)
- Johanna Raisa (1)
- Laurence Rault (3)
- Liz Rea (28)
- Martin Renvoize (2006)
- Phil Ringnalda (3)
- David Roberts (14)
- Marcel de Rooy (147)
- Caroline Cyr La Rose (2)
- Andreas Roussos (3)
- Joel Sasse (1)
- Lisette Scheer (17)
- Maksim Sen (1)
- Maribeth Shafer (1)
- Maryse Simard (18)
- Fridolin Somers (18)
- Myka Kennedy Stephens (12)
- Debra Stephenson (1)
- Emmi Takkinen (1)
- Lari Taskula (6)
- Pierre-Marc Thibault (1)
- Mark Tompsett (7)
- Ed Veal (1)
- George Veranis (1)
- Marc Véron (1)
- Niamh Walker-Headon (6)
- Chris Walton (1)
- George Williams (6)
- Maggie Wong (1)
- Mengü Yazıcıoğlu (10)
- Jessica Zairo (5)
- Christofer Zorn (1)
- Nazlı Çetin (4)

We thank the following individuals who mentored new contributors to the Koha project.

- Joonas Kylmälä
- Andrew Nugged
- Martin Renvoize
- Andreas Roussos
- Petro Vashchuk

# Special thanks from the release manager

It has been a privilege and an honour to have served as the Release Manager for the past 12 months.

I would like to extend my personal thanks to PTFS Europe for their support in allowing me to take on this role, my family for putting up with me running the late night meetings and finally I'd like to thank the team around me for doing such a great job. Katrin has been fantastic managing an excellent quality assurance team and it's been brilliant having a close group of allies whom I could trust to get things done, experiment alongside me and work quickly on fixes when bugs inevitably happen.  For this release, Tomas Cohen, Jonathan Druart and Mason James also deserve special mention for their diligent efforts in the last weeks of the cycle to ensure Debian packaging issues were resolved.

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.12.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 May 2020 20:36:02.
