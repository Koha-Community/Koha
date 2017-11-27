# RELEASE NOTES FOR KOHA 17.11.00
28 Nov 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.00 is a major release, that comes with many new features.

It includes 9 new features, 138 enhancements, 350 bugfixes.



## New features

### Acquisitions

- [[15685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15685) Allow creation of items (AcqCreateItem) to be customizable per-basket

### Architecture, internals, and plumbing

- [[14826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14826) Store account offsets

> The account offsets table allows libraries to know the entire history of fees and payments in Koha. Previously there was no way to directly connect fees and payments. The addition of the account offsets table allows you to know which fees paid which fines visa versa. This data will be accessible via reports and later via the staff intranet ( via Bug 2696 ).


- [[19173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19173) Make OPAC online payments pluggable

> This development allows adding new payment methods through the use of Koha plugins. It provides institutions with more flexibility and an easier path to integrate local payment methods.



### Circulation

- [[7317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7317) Add an Interlibrary Loan Module to Circulation and OPAC

> Adds the ability to place interlibrary loan requests in Koha.   
Interlibrary loan requests are common especially in academic or special libraries where the enduser or librarian may be entitled to request a book or article from an external library such as the British Library (BLDSS) using their interlibrary loan service.   
This patch set comes with 3 configured backends - BLDSS, Freeform and a Dummy account which is the default for testing.  The BLDSS backend allows users to search stock held by the British Library using their api, and allows requests to be placed against it. The Freeform backend allows the creation of Interlibrary loan requests using a manual form.    
Interlibrary loan requests can be made from the OPAC or from the staff client. The enduser can query the backend database and place requests. Alternatively they can create requests using the manual form.  
From the OPAC interface endusers can view and comment on their requests if enabled.  
In the staff client librarians can manage requests placed on the OPAC, processing them against a backend (e.g. British Library). Alternatively the system allows requests to be placed with peer libraries. Peer libraries can be identified by an Organizational patron category type and requests can be sent to the peer library by email.  
Core request information such as links to borrowers, branch, request status, staff and customer notes, unique identifiers are stored in the database and can be displayed and reported on.



### OPAC

- [[2093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2093) Add OPAC dashboard for logged-in users

> Add a summary to the OPAC once the user has logged in that  
shows the users number of checkouts, overdues, holds pending, holds waiting and total fines. It can be turned on with the new system preference OPACUserSummary.



### Patrons

- [[14919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14919) Holds history for patrons

> This new feature adds new page called "Holds history". The page is accessible from left menu on every patron related page. It allows librarians to see the history of all holds of given patron, with the actual status. It could be useful especially when the hold is cancelled. Before this patch the hold just disappeared when cancelled (automatically or manually).


- [[18298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18298) Allow enforcing password complexity

> Add the option to enforce a strong password policy.  
That policy would mean that passwords should include 1 lowercase, 1 uppercase and 1 digit.  
This option is turned on for new installations.



### REST api

- [[18120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18120) CRUD endpoint for vendors

### System Administration

- [[10132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10132) Add option to set MarcOrgCode on branch level

> This development allows setting different MARC organization codes (http://www.loc.gov/marc/organizations) for each library/branch, instead of only the globally configured 'MARCOrgCode' syspref. This is particularly useful for consortia with different libraries and different MARC organization codes.



## Enhancements

### Acquisitions

- [[8612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8612) CSV export profile to have custom fields in export csv basket
- [[12349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12349) Link patron name on suggestions
- [[18399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18399) Add reasons on edit suggestion page
- [[18581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18581) Add standard edit and delete buttons to suggestions list
- [[18582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18582) Hide empty rows in detailed suggestion view
- [[19257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19257) Warn when reopening a basket

### Architecture, internals, and plumbing

- [[17554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17554) Move GetBorrowersWithEmail to Koha::Patron
- [[17680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17680) C4::Circulation - Replace GetItemIssue with Koha::Checkouts
- [[17738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17738) Move GetReservesFromBorrowernumber to Koha::Patron->holds
- [[17797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17797) Add XSLT_Handler in opac/unapi
- [[17807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17807) Use XSLT_Handler in oai.pl
- [[17829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17829) Move GetMember to Koha::Patron
- [[17843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17843) Move C4::Koha::getitemtypeinfo to Koha::ItemTypes
- [[17965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17965) TT syntax for notices - Prove that DUEDGST is compatible
- [[17966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17966) TT syntax for notices - Prove that ISSUESLIP is compatible
- [[17967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17967) TT syntax for notices - Prove that ODUE is compatible
- [[17969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17969) Refactor the way the items.content placeholder is generated
- [[17975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17975) TT syntax for notices - Prove that HOLD_SLIP is compatible
- [[17989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17989) Stricter control on source directory for html templates
- [[18149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18149) Move CountUsage calls to Koha namespace
- [[18226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18226) Remove "use Test::DBIx::Class" instantiations' dangerous code duplication
- [[18254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18254) Remove C4::Items::GetItemsByBiblioitemnumber call from additem.pl
- [[18259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18259) Koha::Biblio - Remove GetSubscriptionsId
- [[18260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18260) Koha::Biblio - Remove GetBiblio
- [[18262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18262) Koha::Biblios - Remove GetBiblioData - part 1
- [[18276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18276) Koha::Biblio - Remove GetBiblioFromItemNumber
- [[18277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18277) Koha::Biblio - Remove GetBiblionumberFromItemnumber
- [[18278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18278) C4::Items - Remove GetItemLocation
- [[18279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18279) C4::Items - Remove GetLostItems
- [[18285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18285) Koha::Database schema cache accessors
- [[18295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18295) C4::Items - Remove get_itemnumbers_of
- [[18296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18296) C4::Items - Remove GetItemInfosOf
- [[18361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18361) Koha::Objects->find should accept composite primary keys
- [[18539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18539) Forbid Koha::Objects->find calls in list context
- [[18643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18643) Remove dead code in reports/statistics 'Till reconciliation'
- [[18782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18782) Remove unused C4::Serials::getsupplierbyserialid
- [[18785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18785) Add Koha::Subscription::biblio
- [[18881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18881) Remove dead code in circ/view_holdsqueue.pl
- [[18894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18894) Add ability to limit the number of messages sent by misc/cronjobs/process_message_queue.pl at a time
- [[18931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18931) Add a "data corrupted" section on the about page
- [[19025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19025) Move C4::Reserves::GetReserveInfo to Koha::Holds
- [[19038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19038) Remove OPACShowBarcode syspref
- [[19040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19040) Change prototype of C4::Biblio::GetMarcBiblio
- [[19056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19056) Move C4::Reserves::GetReserveCount to the Koha namespace
- [[19057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19057) Move C4::Reserves::GetReserve to the Koha namespace
- [[19058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19058) Move C4::Reserves::GetReserveId to Koha::Holds
- [[19059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19059) Move C4::Reserves::CancelReserve to the Koha::Hold->cancel
- [[19178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19178) Remove outdated sms/* scripts
- [[19209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19209) Koha::Objects should provide ->is_paged method
- [[19256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19256) Koha::Acquisition::Order should use Koha::Object

### Authentication

- [[16892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16892) Add automatic patron registration via OAuth2 login

### Cataloging

- [[13912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13912) Add syspref for default place of publication (country code) for field 008, range 15-17
- [[16204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16204) Show friendly error message when trying to edit record which no longer exists
- [[17039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17039) Add cancel/new item option when editing an item
- [[17288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17288) Advanced Editor - Rancor - Helpers for 006 and 007 fields
- [[18735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18735) Print Barcode as soon as adding an item
- [[19348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19348) Title column in item search is too narrow

### Circulation

- [[10748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10748) Add option to block return of lost items
- [[14039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14039) Add patron title to checkout screen
- [[18708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18708) Show itemBarcodeFallbackSearch results in a modal window
- [[18882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18882) Add location code to statistics table for checkouts and renewals

### Command-line Utilities

- [[14533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14533) koha-create --use-db option shouldn't create any db or db user
- [[16187]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16187) Add a script to cancel unfilled holds after a specified number of days
- [[17467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17467) Introduce a single koha-zebra script to handle Zebra daemons for instances

> To ease multi-tenant sites maintenance, several handy scripts were introduced. For handling Zebra, 4 scripts were introduced: koha-start-zebra, koha-stop-zebra, koha-restart-zebra and koha-rebuild-zebra.  
This patch introduces a new script, koha-zebra, that unifies those actions regarding Zebra daemons on a per instance base, through the use of option switches.


- [[18877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18877) Add documentation on dbhost for koha-create help
- [[19462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19462) Add a koha-elasticsearch command

> A new command-line script is added for handling Elasticsearch indexing-related tasks for each Koha instance.


- [[19472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19472) Add perl extension to borrowers-force-messaging-defaults

### Course reserves

- [[19231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19231) No warning of number of attached items when deleting a course

### Hold requests

- [[14353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14353) Show 'damaged' and other status on the 'place holds' page in staff

### I18N/L10N

- [[18665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18665) Translatability: Add tt filter to allow html tags inside tt directives

### Label/patron card printing

- [[18465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18465) Patron card creator: Print on duplex card printer
- [[18528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18528) Patron card creator template: switch form fields for card height and card width
- [[18541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18541) Patron card creator: Add a grid to support layout design

### Lists

- [[17214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17214) Add records to lists by biblio number
- [[18228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18228) Make list permissions easier to use/understand
- [[18672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18672) Creation Date and Modification Date are the same for a list in the Lists Module
- [[18980]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18980) Add an explanation when Anyone permission has no actual effect
- [[19255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19255) Correct explanation about list categories on shelves.pl in staff

### MARC Bibliographic data support

- [[15140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15140) Add MARC21 776 to OPAC and staff display

### MARC Bibliographic record staging/import

- [[18389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18389) Allow using MARC modification templates in bulkmarcimport.pl

### Notices

- [[18847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18847) Add "Save and continue" option to notice editing

### OPAC

- [[13796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13796) Alert in OPAC when renewing an item with a rental charge
- [[16759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16759) Make OPAC holdings table configurable
- [[17834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17834) Change library news text for single-branch libraries
- [[18354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18354) Adding item type attribute to cover image div
- [[18616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18616) The "Add forgot password link to OPAC" should allow patrons to use their library card number in addition to username
- [[18775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18775) The "Password Reset" notice should use the patron's homebranch's email as "from" address
- [[18860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18860) OPAC Messaging Settings table is not styled with thead
- [[18949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18949) OPAC MARC details holdings table is not styled with thead
- [[19028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19028) Add 'shelving location' to holdings table in detail page
- [[19068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19068) OPAC purchase suggestion doesn't allow users to enter quantity of items
- [[19212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19212) Warns when asking for a discharge OPAC
- [[19216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19216) Patron clubs table has an empty column in OPAC

### Patrons

- [[6758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6758) Capture membership renewal date for reporting purposes
- [[13178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13178) cardnumber field length is too short
- [[13572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13572) Add not-expired parameter to borrowers-force-messaging-defaults script
- [[15644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15644) City dropdown default selection when modifying a patron matches only on city
- [[18555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18555) Create patron list from patron import
- [[19400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19400) Reminder to unset gone no address flag after patron makes a modification request

### REST api

- [[18137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18137) Migrate from Mojolicious::Plugin::Swagger2 to Mojolicious::Plugin::OpenAPI
- [[18282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18282) OpenAPI operationId must be unique
- [[19196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19196) Add pagination helpers

### Reports

- [[18667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18667) Show a diff view of SQL reports when converting

### SIP2

- [[16755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16755) Allow SIP2 field DA (hold patron name) to be customized
- [[16899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16899) Add ability to disallow overpayments via SIP
- [[18104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18104) Allow SIP2 field AE (personal name) to be customized

### Searching

- [[13205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13205) Last/First page options for result list paging
- [[18916]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18916) Add pagination to top of search results in staff client
- [[19461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19461) Add floating toolbar to staff client catalog search results

### Self checkout

- [[17381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17381) Add system preference SCOMainUserBlock

### Serials

- [[18184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18184) Subscriptions summaries don't show if seeing all subs attached to a biblio

### Staff Client

- [[12644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12644) Add subtitles to staff client cart
- [[18718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18718) Language selector in staff header menu similar to OPAC

### System Administration

- [[12768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12768) Replacement cost and processing fee management
- [[18857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18857) Have "actions" at both ends of the circulation rules table

### Templates

- [[12691]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12691) Use Koha.Preference for calls to SCOUserJS, SCOUserCSS, OPACUserCSS, opacuserjs, etc in Self-Checkout
- [[16545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16545) Make edit link a styled button in item search results
- [[17893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17893) Move JavaScript to the footer on staff client catalog pages
- [[18542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18542) Move and style "new field" link in item search form
- [[18739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18739) Add SVG version of staff-home-icons-sprite image
- [[18810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18810) Update Font Awesome to 4.7.0
- [[19356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19356) Move staff client cart JavaScript to the footer

### Test Suite

- [[15339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15339) TestBuilder build parameter warnings
- [[18286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18286) Test::DBIx::Class connection/schema is shadowed by a cached connection/schema
- [[18287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18287) Fix t/Koha.t having a Test::DBIx::Class cache issue
- [[18288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18288) Fix t/SocialData.t having a Test::DBIx::Class cache issue
- [[18289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18289) Fix t/Prices.t having a Test::DBIx::Class cache issue
- [[18292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18292) Tests do not need to return 1;
- [[18508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18508) Fix t/db_dependent/api/v1/swagger/definitions.t (follow-up of 18137)
- [[19119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19119) Remove t/db_dependent/api/v1/swagger/definitions.t
- [[19337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19337) Allow basic_workflow.t be configured by ENV
- [[19513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19513) More changes to MarkIssueReturned.t (after bug 19487)

### Tools

- [[18430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18430) Plugins page should have a link to viewing other types
- [[18869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18869) Patron clubs and templates tables look strange when empty
- [[18871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18871) It is unclear how to view a patron list
- [[18917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18917) Use font awesome buttons in CSV profiles
- [[19022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19022) Improve location and author display in inventory tool
- [[19420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19420) Improve display of errors from failure of uploading file during stage import


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[18351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18351) No warning when deleting budgets that have funds attached
- [[18756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18756) Users can view aq.baskets even if they are not allowed
- [[18900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18900) Wrong number format in receiving order
- [[18906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18906) Superlibrarian and budget_manage_all users should always see all funds
- [[18999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18999) Acq: Shipping cost not included in total spent on acq home and funds page
- [[19120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19120) Order cancelled status is reset on basket open
- [[19194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19194) Internal server error when receiving an order with no itemtype
- [[19277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19277) TT syntax - Data is not ordered in notices
- [[19296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19296) Tax is being subtracted from orders when vendor price does not include gst and ordering from a file
- [[19332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19332) Basket grouping PDF and CSV exports empty
- [[19372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19372) Selecting MARC framework doesn't work when adding to basket from an external source
- [[19425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19425) Adding orders from order file with multiple budgets per record triggers error
- [[19596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19596) Internal server error if open order with deleted biblio / null biblionumber
- [[19695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19695) Uncertain prices should not use find in list context

### Architecture, internals, and plumbing

- [[12363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12363) Marking an item as lost in koha always returns it, but longoverdue.pl may not
- [[16069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16069) XSS issue in basket.pl page
- [[18651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18651) Move of checkouts is still not correctly handled
- [[18726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18726) OPAC XSS - biblionumber
- [[18727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18727) System preferences loose part of values because of double quotes
- [[18966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18966) Move of checkouts - Deal with duplicate IDs at DBMS level
- [[19033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19033) XSS Flaws in Currencies and exchange page
- [[19034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19034) XSS Flaws in- Cities - Z39.50/SRU servers administration - Patron categories pages
- [[19035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19035) Stored XSS in patron lists -  lists.pl
- [[19050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19050) XSS Flaws in Quick spine label creator
- [[19051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19051) XSS Flaws in - Batch record deletion page - Batch item deletion page - Batch item modification page
- [[19052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19052) XSS Flaws in - vendor search page - Invoice search page
- [[19054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19054) XSS Flaws in Report - Top Most-circulated items
- [[19078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19078) XSS Flaws in System preferences
- [[19079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19079) XSS Flaws in Membership page
- [[19080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19080) Handle non existing patrons
- [[19086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19086) Multiple cross-site scripting vulnerabilities
- [[19100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19100) XSS Flaws in memberentry.pl
- [[19103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19103) Stored XSS in itemtypes.pl - patron-attr-types.pl - matching-rules.pl
- [[19105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19105) XSS Stored in holidays.pl
- [[19108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19108) Stored XSS in multiple scripts
- [[19110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19110) XSS Stored in branches.pl
- [[19112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19112) Stored XSS in basketheader.pl
- [[19114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19114) Stored XSS in parcels.pl
- [[19117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19117) paycollect.pl is vulnerable for CSRF attacks
- [[19125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19125) XSS - members.pl
- [[19127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19127) Stored XSS in csv-profiles.pl
- [[19128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19128) XSS - patron-attr-types.tt, authorised_values.tt and categories.tt
- [[19333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19333) XSS vulnerability in opac-shelves
- [[19655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19655) To.json doesn't escape newlines which can create invalid JSON

### Authentication

- [[18046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18046) Problem with redirect on logout with CAS
- [[18880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18880) Regression breaks local authentication fallback for all external authentications

### Cataloging

- [[18131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18131) Matching staged records when using elastic search fails
- [[19350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19350) Holds without link in 773 trigger SQL::Abstract::puke
- [[19503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19503) Duplicating a dropdown menu subfield yields an empty subfield tag

### Circulation

- [[18179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18179) Koha::Objects->find should not be called in list context
- [[18357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18357) On-site checkouts issues with 'Unlimited'
- [[18835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18835) SQL syntax error in overdue_notices.pl
- [[19048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19048) Self checkout: Internal server error in sco-main.pl
- [[19053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19053) Auto renewal flag is not kept if a confirmation is needed
- [[19198]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19198) Renewal as issue causes too many error
- [[19205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19205) Pay selected fine generates 500 error
- [[19208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19208) Pay select option doesn't pay the selected fine
- [[19334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19334) circulation history doesn't set biblionumber so left navigation is broken
- [[19374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19374) CircSidebar overlapping transferred items table
- [[19431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19431) Error when trying to checkout an unknown barcode
- [[19487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19487) Internal server error when writing off lost fine for item not checked out

### Command-line Utilities

- [[18927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18927) koha-rebuild-zebra is failing with "error retrieving biblio"

### Course reserves

- [[19388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19388) Error in course details on OPAC if an item is checked-out

### Hold requests

- [[18547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18547) On shelf holds allowed > "If all unavailable" ignores default hold policy
- [[19116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19116) Holds not set to waiting when "Confirm" is used
- [[19135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19135) AllowHoldsOnPatronsPossessions is not working
- [[19260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19260) Reservations / holds marked as problems being seen as expired ones and deleted wrongly.
- [[19626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19626) Database update for bug 12063 incorrectly calculates expirationdate for holds

### I18N/L10N

- [[18331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18331) Translated CSV exports need to be fixed once and for all

### Installation and upgrade (command-line installer)

- [[19067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19067) clubs/ is not correctly mapped in Makefile.PL

### Installation and upgrade (web-based installer)

- [[18741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18741) Web installer does not load default data

### MARC Authority data support

- [[19415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19415) FindDuplicateAuthority is searching on biblioserver since 16.05

### MARC Bibliographic record staging/import

- [[18577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18577) Importing a batch using a framework not fully set up causes and endless loop

### Notices

- [[19675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19675) Cannot save notices when setting the TranslateNotices preference

### OPAC

- [[17277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17277) Current Location column in Holdings table showing empty under OPAC
- [[18572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18572) Improper branchcode  set during OPAC renewal
- [[18653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18653) Possible privacy breach with OPAC password recovery
- [[18938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18938) opac/svc/patron_notes and opac/opac-issue-note.pl use GetMember
- [[18955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18955) Autocomplete is on in OPAC password recovery
- [[19122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19122) IncludeSeeFromInSearches is broken
- [[19235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19235) Password visible in OPAC self registration
- [[19366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19366) PatronSelfRegistrationEmailMustBeUnique pref makes it impossible to submit updates via OPAC

### Patrons

- [[18685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18685) Patron edit/cancel floating toolbar out of place
- [[18987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18987) When browsing for a patron by last name the page processes indefinitely
- [[19214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19214) Patron clubs: Template process failed: undef error - Cannot use "->find" in list context
- [[19418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19418) Patron search is broken

### REST api

- [[18826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18826) REST API tests do not clean up

### Reports

- [[18898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18898) Some permissions for Reports can be bypassed
- [[19495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19495) Automatic report conversion needs to do global replace on 'biblioitems' and 'marcxml'

### SIP2

- [[15438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15438) Checking out an on-hold item sends holder's borrowernumber in AF (screen message) field.
- [[18996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18996) SIP sets ok flag to true for refused checkin for data corruption
- [[19651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19651) SIP/ILS/Item missing title

### Searching

- [[16976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16976) Authorities searches with double quotes gives ZOOM error 20003
- [[18624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18624) Software error when searching authorities in Elasticsearch - incorrect parameter "any" should be "all"
- [[18854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18854) DoS Offset

### Searching - Elasticsearch

- [[18318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18318) Wrong unicode tokenization
- [[18374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18374) Respect QueryAutoTruncate syspref in Elasticsearch
- [[18434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18434) Elasticsearch indexing broken with newer catmandu version
- [[19481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19481) Elasticsearch - Set default fields for sorting in mappings.yaml
- [[19559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19559) Elasticsearch QueryAutoTruncate truncate field names with hyphens if data is quoted

### Serials

- [[19323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19323) Subscription edit permission issue

### Staff Client

- [[18884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18884) Advanced search on staff client, Availability limit not properly limiting

### System Administration

- [[15173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15173) SubfieldsToAllowForRestrictedEditing not working properly

### Templates

- [[19329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19329) IntranetSlipPrinterJS label is obsoleted
- [[19539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19539) Editing rules that contain 'Unlimited' values produces invalid data

### Test Suite

- [[18807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18807) www/batch.t is failing
- [[18851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18851) Use Test::DBIx::Class in tests breaks packaging

### Tools

- [[18689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18689) Fix calendar error with double quotes in title or description of holiday
- [[18806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18806) Cannot revert a batch
- [[18870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18870) Patron Clubs breaks when creating a club
- [[19023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19023) inventory tool performance
- [[19049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19049) Fix regression on stage-marc-import with to_marc plugin
- [[19073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19073) Can't change library with patron batch modification tool
- [[19163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19163) Critical typo in stage-marc-import process
- [[19357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19357) Error when submitting biblionumbers to batch record modification

### Z39.50 / SRU / OpenSearch Servers

- [[18910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18910) Regression: Z39.50 wrong conversion in Unimarc by Bug 18152


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[19397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19397) Release team 17.11

### Acquisitions

- [[11122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11122) Fix display of publication year/copyrightdate and publishercode on various pages in acquisitions
- [[13208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13208) More complete breadcrumbs when cancelling an order
- [[18722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18722) Subtotal information not showing fund source
- [[18830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18830) Message to user is poorly constructed
- [[18839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18839) suggestion.pl: 'unknown' is spelled 'unkown'
- [[18941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18941) C4::Budgets GetBudgetByCode should return active budgets over inactive budgets
- [[18942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18942) CanUserUseBudget.t and CanUserModifyBudget.t missing system user test cases
- [[18971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18971) Typo Koha::ItemsTypes for Koha::ItemTypes
- [[19024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19024) Order cancelled status is reset on basket close
- [[19083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19083) 'Show all details' checkbox on basket summary page is broken
- [[19118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19118) Due to wrong variable name passed vendor name is  not coming in browser title bar
- [[19180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19180) Vendor name is missing from breadcrumbs when closing an order
- [[19195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19195) Noisy warns when creating or editing a basket
- [[19328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19328) Internal server error because of missing currency
- [[19340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19340) Transferred orders show incorrect basket in transferred from/to
- [[19453]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19453) Client side validation broken for "Fund" select

### Architecture, internals, and plumbing

- [[13012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13012) suggestion.suggesteddate should be set to NOW if not defined
- [[14572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14572) insert_single_holiday() forces a value on an AUTO_INCREMENT column, during an INSERT
- [[17699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17699) DateTime durations are not correctly subtracted
- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[18605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18605) Remove TRUNCATE from C4/HoldsQueue.pm
- [[18633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18633) Logs are full of CGI::param called in list context - itemsearch.pl
- [[18716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18716) CGI::param in list context warns in updatesupplier.pl
- [[18771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18771) CGI.pm: Subroutine multi_param redefined
- [[18794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18794) OAI/Server.t fails on slow servers
- [[18824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18824) Remove stray i from matching-rules.tt
- [[18921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18921) Resolve a few warnings in C4/XSLT.pm
- [[18923]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18923) Resolve a warn in Biblio::GetCOinSBiblio
- [[18956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18956) Possible privacy breach with OPAC password recovery
- [[18961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18961) Datatable column filters of style 'select' should do an exact match
- [[19055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19055) GetReservesToBranch is not used
- [[19130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19130) K::A::Booksellers->search broken for attribute 'name'
- [[19276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19276) CanBookBeIssued: unsuccessfully refers to borrower category_type X
- [[19298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19298) allow_onshelf_holds is not calculated correctly in opac-shelves
- [[19317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19317) Move of checkouts - Remove leftover
- [[19344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19344) DB fields login_attempts and lang may be inverted
- [[19493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19493) Remove few warnings from circulation.pl
- [[19517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19517) dateexpiry.t is failing randomly
- [[19536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19536) Odd number of elements in anonymous hash in svc/bib

### Authentication

- [[19373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19373) CAS login for staff interface always goes back to home

### Cataloging

- [[18422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18422) Add Select2 to authority editor
- [[19367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19367) $biblio variable redefined in same scope in ISBDdetail
- [[19377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19377) Remove $5 charge from sample item types
- [[19413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19413) Move the location of the Ok and cancel buttons to the 008 cataloguing builder
- [[19537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19537) Authorities search doesn't correctly populate subfield $2 source of heading

### Circulation

- [[9031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9031) Overdue items crossing DST boundary throw invalid local time exception
- [[11580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11580) If returnBeforeExpiry is on, holidays are not taken into account to calculate the due date
- [[18449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18449) Renewal limit button on renew.pl misleading
- [[19007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19007) Allow paypal payments via debit or credit card again
- [[19027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19027) Circulation rules: Better wording for standard rules for all libraries
- [[19029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19029) Implement a security question for cloning circulation conditions
- [[19076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19076) Renewal via Checkout screen is logged as both a renewal and a checkout
- [[19371]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19371) Change template table column text from 'Delete?' to 'Cancel?'  on the patron circulation page holds tab
- [[19438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19438) Sorting by due date in overdues listing does not work as expected
- [[19484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19484) Checkout page does not like itemtype NULL

### Command-line Utilities

- [[18709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18709) koha-foreach should use koha-shell, internally
- [[19190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19190) Silly calculation of average time in touch_all scripts

### Course reserves

- [[19228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19228) Confirm delete doesn't show when deleting an item from course
- [[19229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19229) Clicking Cancel when editing course doesn't take you back to the course

### Database

- [[13766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13766) Make biblioitems.ean longer and add index
- [[18690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18690) Typos in Koha database description (Table "borrowers")
- [[18848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18848) borrowers.lastseen comment typo
- [[19422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19422) kohastructure.sql missing DROP TABLES

### Developer documentation

- [[19528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19528) Fixing a few typos like corrosponding

### Documentation

- [[18817]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18817) Update links in the help files for the new 17.11 manual

### Hold requests

- [[18469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18469) Suspend all holds when specifying a date to resume hold does not keep date

### I18N/L10N

- [[17827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17827) Untranslatable "by" in MARC21slim2intranetResults.xsl
- [[18367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18367) Fix untranslatable string from Bug 18264
- [[18537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18537) Update Ukrainian installer sample files for 17.05
- [[18641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18641) Translatability: Get rid of template directives in translations for *reserves.tt files
- [[18644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18644) Translatability: Get rid of pure template directives in translation for memberentrygen.tt
- [[18648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18648) Translatability: Get rid of tt directives in translation for macles.tt
- [[18649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18649) Translatability: Get rid of tt directive in translation for admin/categories.tt and onboardingstep2.tt
- [[18652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18652) Translatability: Get rid of tt directive in translation for uncertainprice.tt
- [[18654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18654) Translatability: Get rid of tt directives starting with [%% in translation for itemsearch.tt
- [[18660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18660) Translatability: Get rid of template directives [%% in translation for patroncards-errors.inc
- [[18675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18675) Translatability: Get rid of [%% in translation for csv-profiles.tt
- [[18681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18681) Translatability: Get rid of [%% in translation for about.tt
- [[18682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18682) Translatability: Get rid of [%% in translation for 2 files av-build-dropbox.inc
- [[18684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18684) Translatability: Get rid of %%] in translation for currency.tt
- [[18687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18687) Translatability: abbr tag should not contain lang attribute
- [[18693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18693) Translatability: Get rid of exposing a [%% FOREACH loop in translation for branch-selector.inc
- [[18694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18694) Translatability: Get rid of exposing  [%% FOREACH in csv/cash_register_stats.tt
- [[18695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18695) Translatability: Get rid of  [%% INCLUDE in translation for circulation.tt
- [[18699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18699) Get rid of %%] in translation for edi_accounts.tt
- [[18701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18701) Translatability: Get rid of exposed tt directives in matching-rules.tt
- [[18703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18703) Translatability: Resolve some remaining %%] problems for staff client in 6 Files
- [[18754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18754) Translatability: Get rid of exposed tt directives in opac-detail.tt
- [[18776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18776) Translatability: Get rid of exposed tt directives in opac-advsearch.tt
- [[18777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18777) Translatability: Get rid of exposed tt directives in opac-memberentry.tt
- [[18778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18778) Translatability: Get rid of  tt directive in translation for item-status.inc
- [[18779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18779) Translatability: Get rid of exposed tt directives in authorities-search-results.inc (OPAC)
- [[18780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18780) Translatability: Get rid of exposed tt directive in masthead-langmenu.inc
- [[18781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18781) Translatability: Get rid of exposed tt directives in openlibrary-readapi.inc
- [[18800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18800) Patron card images: Add some more explanation to upload page and fix small translatability issue
- [[18901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18901) Sysprefs translation: translate only *.pref files (not *.pref*)
- [[19274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19274) Translatability: Fix new splitting problems related to database warnings

### Installation and upgrade (command-line installer)

- [[9409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9409) koha-create --request-db should be able to accept a dbhost option
- [[18564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18564) koha-common.cnf parsing is too restrictive
- [[18712]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18712) make test is failing with an empty DB - t/Matcher.t
- [[18920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18920) Some config values are not saved in koha-install-log

### Installation and upgrade (web-based installer)

- [[17944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17944) Remove the sql code from itemtypes.pl administrative perl script
- [[18629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18629) Translatability: Fix problems with web installer 17.05
- [[18702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18702) Translatability: Get rid of exposed if statement in tt for translated onboardingstep2.tt
- [[19085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19085) Empty files in English web installer

### Label/patron card printing

- [[18550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18550) Patron card creator: Print output does not respect layout units

### Lists

- [[15924]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15924) Coce not enabled on lists
- [[18214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18214) Cannot edit list permissions of a private list

### MARC Authority data support

- [[17380]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17380) Resolve several problems related to Default authority framework
- [[18801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18801) Merging authorities has an invalid 'Default' type in the merge framework selector
- [[18811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18811) Visibility settings inconsistent between framework and authority editor

### MARC Bibliographic record staging/import

- [[17710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17710) C4::Matcher::get_matches and C4::ImportBatch::GetBestRecordMatch should use same logic
- [[19069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19069) "Doesn't match" option fails in MARC Modification Templates
- [[19414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19414) Move the location of the 'Import this batch into the catalog' button

### Notices

- [[19134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19134) C4::SMS does not handle drivers with more than two names well

### OPAC

- [[5471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5471) Quotes in tags cause moderation approval/rejection to fail
- [[9857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9857) Did you mean? from authorities uses incorrect punctuation
- [[13913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13913) Renewal error message in OPAC is confusing
- [[16463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16463) OPAC discharge page should warn the user about checkouts before they request
- [[16711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16711) OPAC Password recovery: Handling if multiple accounts have the same mail address
- [[18118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18118) Unexpected behaviour with 'GoogleOpenIDConnect' and 'OpacPublic' syspref combination
- [[18545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18545) Remove use of onclick from OPAC Cart
- [[18634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18634) Missing empty line at end of opac.pref / colliding translated preference sections
- [[18692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18692) When SMS is enabled the OPAC messaging table is misaligned
- [[18946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18946) Change language from external web fails
- [[19345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19345) SendMail error does not display error message in password recovery
- [[19576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19576) opac-detail has duplicate 'use Koha::Biblios;'

### Patrons

- [[12346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12346) False patron modification alerts on members-home.pl
- [[18447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18447) Datepicker only shows -10/+10 years for date of birth
- [[18621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18621) After duplicate message system picks category expiry date rather than manual defined
- [[18630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18630) Translatability (Clubs): 'Cancel' is ambiguous and leads to mistakes
- [[18636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18636) Can not save new patron on fresh install (Conflict between autoMemberNum and BorrowerMandatoryField)
- [[18832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18832) Missing space between icon and label in button 'Patron lists'
- [[18858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18858) Warn when deleting a borrower debarment
- [[19129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19129) Clean up templates for organisation patrons in staff
- [[19215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19215) Typo in URL when editing a patron club template
- [[19258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19258) Fix warns when paying or writing off a fine or charge
- [[19275]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19275) clubs table broken at the opac if public enrollment is not allowed
- [[19398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19398) Wrong date format in quick patron search table
- [[19443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19443) Error while attempting to duplicate a patron
- [[19531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19531) When editing patrons without circulation permission redirect should be to the patron's detail page

### Reports

- [[11235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11235) Names for reports and dictionary are cut off when quotes are used
- [[13452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13452) Average checkout report always uses biblioitems.itemtype
- [[18734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18734) Internal server error in cash_register_stats.pl when exporting to file
- [[18742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18742) Circulation statistics wizard no longer exports the total row
- [[18919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18919) "Transaction Branch" select field broken in Cash register statistics
- [[18985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18985) SQL reports 'Last edit' and 'Last run' columns sort alphabetically, not chronologically

### SIP2

- [[18755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18755) Allow empty password fields in Patron Info requests

> Some SIP devices expect an empty password field in a patron info request to be accepted as OK by the server. Since patch for bug 16610 was applied this is not the case. This reinstates the old behaviour for sip logins with the parameter allow_empty_passwords="1"


- [[18812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18812) SIP Patron status does not respect OverduesBlockCirc

### Searching

- [[16485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16485) Collection column in Item search is always empty
- [[19389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19389) Don't offer search option for libary groups when no groups are defined

### Searching - Elasticsearch

- [[16660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16660) Elasticsearch broken if OpacSuppression is activated

### Serials

- [[13747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13747) Fix problems with frequency descriptions containing quotes
- [[18356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18356) Prediction pattern wrong, skips years, for some year based frequencies
- [[18607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18607) Fix date calculations for monthly frequencies in Serials
- [[18697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18697) Fix date calculations for day/week frequencies in Serials
- [[19315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19315) Routing preview may use wrong biblionumber

### Staff Client

- [[18673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18673) News author does not display on staff client home page
- [[19193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19193) When displaying the fines of the guarantee on the guarantor account, price is not in correct format.

### System Administration

- [[16726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16726) Text in Preferences search box does not clear
- [[18700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18700) Fix ungrammatical sentence
- [[18934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18934) Warns in Admin -> SMS providers
- [[18965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18965) branch transfer limits pagination save bug
- [[19186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19186) SelfCheckoutByLogin should list 'cardnumber' as an option instead of 'barcode'

### Templates

- [[10267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10267) No error message when entering an invalid cardnumber
- [[17639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17639) Remove white filling inside of Koha logo
- [[18656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18656) Require confirmation of deletion of files from patron record
- [[19000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19000) about page - Typo in closing p tag
- [[19041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19041) footerjs = 1 removed by bug 17855

### Test Suite

- [[17664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17664) Silence non-zebra warnings in t/db_dependent/Search.t
- [[18290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18290) Fix t/db_dependent/Koha/Object.t, Mojo::JSON::Bool is a JSON::PP::Boolean :)
- [[18411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18411) t/db_dependent/www/search_utf8.t  fails
- [[18601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18601) OAI/Sets.t mangles data due to truncate in ModOAISetsBiblios
- [[18732]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18732) Noisy t/SMS.t triggered by koha_conf.xml without sms_send_config
- [[18746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18746) Text_CSV_Various.t parse failure
- [[18748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18748) Noisy t/db_dependent/AuthorisedValues.t
- [[18749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18749) xt/sample notices fails with "No sample notice to delete"
- [[18759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18759) Circulation.t is failing randomly
- [[18761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18761) AutomaticItemModificationByAge.t tests are failing
- [[18762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18762) Some tests are noisy
- [[18763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18763) swagger/definitions.t is failing
- [[18766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18766) ArticleRequests.t raises warnings
- [[18767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18767) Useless debugging info in GetDailyQuote.t
- [[18773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18773) t/db_dependent/www/history.t is failing
- [[18802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18802) Circulation.t fails if finesMode != "Do not calculate"
- [[18804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18804) Selenium tests are failing
- [[18951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18951) Some t/Biblio tests are database dependent
- [[18976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18976) Fix t/db_dependent/Auth.t cleanup
- [[18977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18977) Rollback branch in t/db_dependent/SIP/Message.t
- [[18982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18982) selenium tests needs too many prerequisites
- [[18991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18991) Fix cleanup in t/db_dependent/Log.t
- [[19003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19003) Add a TestBuilder default for borrowers.login_attempts
- [[19004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19004) Koha/Patrons.t fails when item-level_itypes is not set
- [[19009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19009) Circulation.t is still failing randomly
- [[19013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19013) sample_data.sql inserts patrons with guarantorid that do not exist
- [[19042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19042) Silence warnings t/db_dependent/Letters.t
- [[19047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19047) Fix AddBiblio call in Reserves.t
- [[19070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19070) Fix Circulation/Branch.t
- [[19071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19071) Fix Circulation/issue.t and Members/IssueSlip.t
- [[19126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19126) Fix Members.t with IndependentBranches set
- [[19176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19176) Dates comparison fails on slow server
- [[19227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19227) 00-merge-conflict-markers.t launches too many tests
- [[19262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19262) pod_spell.t does not work
- [[19268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19268) Fix wrong TestBuilder parameter in few unit tests
- [[19307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19307) t/db_dependent/Circulation/NoIssuesChargeGuarantees.t fails if AllowFineOverride set to allow
- [[19335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19335) 00-merge-markers.t fails
- [[19385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19385) t/Calendar.t is failing randomly
- [[19386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19386) t/db_dependent/SIP/Patron.t is failing randomly
- [[19391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19391) auth_values_input_www.t  is failing because of bug 19128
- [[19392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19392) auth_values_input_www.t does not clean up
- [[19403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19403) Again and again, Circulation.t is failing randomly
- [[19405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19405) t/db_dependent/api/v1/holds.t fails randomly
- [[19423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19423) DecreaseLoanHighHolds.t is failing randomly
- [[19437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19437) Rearrange CancelExpiredReserves tests
- [[19440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19440) XISBN tests should skip if XISBN returns overlimit error
- [[19455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19455) Circulation/SwitchOnSiteCheckouts.t is failing randomly
- [[19463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19463) TestBuilder.t is failing randomly
- [[19529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19529) NoIssuesChargeGuarantees.t is failing randomly

### Tools

- [[14316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14316) Clarify meaning of record number in Batch record deletion tool
- [[18613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18613) Deleting a Letter from a library as superlibrarian deletes the "All libraries" rule
- [[18704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18704) File types limit in tools/export.pl is causing issues with csv files generated by MS/Excel
- [[18706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18706) subfields to delete not disabled anymore in batch item modification
- [[18730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18730) Batch Mod Edit <label> HTML validation fails
- [[18752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18752) Automatic item modifications by age should allow 'blank' values
- [[18918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18918) Exporting bibs in CSV when you have no CSV profiles created causes error
- [[19021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19021) Inventory column sorting
- [[19074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19074) Show patron category description instead of code in patron batch modification list
- [[19081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19081) Plack preventing uninstalled plugins from being removed on the plugins list
- [[19088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19088) plugins-upload.pl causes uninitialized value noise
- [[19259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19259) Overdue rules do not save (delay field should only accept numbers)

### Web services

- [[16401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16401) System preference staffClientBaseURL hardcoded to 'http://'

### Z39.50 / SRU / OpenSearch Servers

- [[19043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19043) Z39.50 target clio-db.cc.columbia.edu:7090 is no longer publicly available.

## New system preferences

- BlockReturnOfLostItems
- DefaultCountryField008
- GoogleOpenIDConnectAutoRegister
- GoogleOpenIDConnectDefaultBranch
- GoogleOpenIDConnectDefaultCategory
- ILLModule
- ILLModuleCopyrightClearance
- MarkLostItemsAsReturned
- OPACUserSummary
- ProcessingFeeNote
- RequireStrongPassword
- SCOMainUserBlock
- SelfCheckoutByLogin
- StaffLangSelectorMode
- useDefaultReplacementCost

## Renamed system preferences

- OpacLocationBranchToDisplayShelving => OpacLocationOnDetail

## Deleted system preferences

- OPACShowBarcode

## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- English (USA)
- Arabic (95%)
- Armenian (96%)
- Chinese (China) (80%)
- Chinese (Taiwan) (100%)
- Czech (92%)
- Danish (66%)
- English (New Zealand) (100%)
- Finnish (95%)
- French (92%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (100%)
- Greek (77%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (55%)
- Occitan (73%)
- Persian (55%)
- Polish (98%)
- Portuguese (96%)
- Portuguese (Brazil) (81%)
- Slovak (92%)
- Spanish (100%)
- Swedish (92%)
- Turkish (97%)
- Vietnamese (68%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.00 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- QA Team:
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Nick Clemens](mailto:nick@bywatersolutions.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - Claire Gravely
  - Josef Moravec
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.00:

- BULAC - http://www.bulac.fr/
- ByWater Solutions
- Camden County
- Catalyst IT
- Dover
- Tulong Aklatan
- Washoe County Library System

We thank the following individuals who contributed patches to Koha 17.11.00.

- Blou (1)
- Nazlı (1)
- Aleisha Amohia (49)
- Michael Andrew Cabus (1)
- Alex Arnaud (6)
- Stefan Berndtsson (2)
- David Bourgault (2)
- Alex Buckley (12)
- Colin Campbell (9)
- Hector Castro (2)
- Nick Clemens (76)
- Tomás Cohen Arazi (86)
- David Cook (5)
- Chris Cormack (4)
- Christophe Croullebois (1)
- Marcel de Rooy (141)
- Yarik Dot (1)
- Jonathan Druart (332)
- Serhij Dubyk {Сергій Дубик} (2)
- Magnus Enger (3)
- Charles Farmer (3)
- Katrin Fischer (22)
- Amit Gupta (33)
- David Gustafsson (1)
- Mason James (2)
- Lee Jamison (6)
- Srdjan Jankovic (1)
- Dilan Johnpullé (1)
- Andreas Jonsson (1)
- Chris Kirby (1)
- Olli-Antti Kivilahti (10)
- Jon Knight (3)
- David Kuhn (2)
- Owen Leonard (24)
- Julian Maurice (16)
- Sophie Meynieux (1)
- Kyle M Hall (42)
- Josef Moravec (30)
- Joy Nelson (1)
- Dobrica Pavlinusic (3)
- Martin Persson (2)
- Dominic Pichette (1)
- Karam Qubsi (1)
- Liz Rea (1)
- David Roberts (1)
- Andreas Roussos (1)
- Rodrigo Santellan (1)
- Alex Sassmannshausen (4)
- Fridolin Somers (15)
- Lari Taskula (19)
- Mirko Tietgen (1)
- Mark Tompsett (29)
- Eric Vantillard (1)
- Oleg Vasylenko (1)
- Marc Véron (67)
- Jesse Weaver (1)
- Baptiste Wojtkowski (6)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.00

- abunchofthings.net (1)
- ACPL (24)
- BibLibre (45)
- BigBallOfWax (3)
- BSZ BW (44)
- bugs.koha-community.org (332)
- ByWater-Solutions (121)
- Catalyst (16)
- Devinim (1)
- evaxion.fr (1)
- Göteborgs universitet (2)
- Ilsley Public Library (1)
- informaticsglobal.com (33)
- jns.fi (29)
- KohaAloha (2)
- Kreablo AB (1)
- Libriotech (3)
- Loughborough University (3)
- Marc Véron AG (67)
- Marywood University (6)
- Prosentient Systems (5)
- PTFS-Europe (14)
- Rijksmuseum (141)
- rot13.org (3)
- Solutions inLibro inc (7)
- Theke Solutions (86)
- unidentified (122)

We also especially thank the following individuals who tested patches
for Koha.

- anafe (1)
- Blou (1)
- fcouffignal (1)
- Guillaume (1)
- Harold (1)
- iflora (1)
- m23 (2)
- maricris (1)
- mehdi (1)
- NickUCKohaCon17 (1)
- Srdjan (1)
- Brendan A Gallagher (8)
- Hugo Agud (11)
- Aleisha Amohia (8)
- Michael Andrew Cabus (2)
- Israelex A Veleña for KohaCon17 (3)
- sonia BOUIS (2)
- David Bourgault (20)
- Christopher Brannon (4)
- Alex Buckley (34)
- Michael Cabus (1)
- Colin Campbell (7)
- Axelle Clarisse (1)
- Nick Clemens (173)
- Tomas Cohen Arazi (192)
- David Cook (1)
- Chris Cormack (19)
- Caroline Cyr La Rose (5)
- Benjamin Daeuber (2)
- Indranil Das Gupta (L2C2 Technologies) (1)
- Frédéric Demians (3)
- Marcel de Rooy (383)
- Jonathan Druart (1105)
- Serhij Dubyk {Сергій Дубик} (1)
- Magnus Enger (12)
- Katrin Fischer (109)
- Barbara Fondren (1)
- Jessica Freeman (1)
- Eivin Giske Skaaren (2)
- Marijana Glavica (2)
- Eric Gosselin (1)
- Claire Gravely (7)
- Victor Grousset (1)
- Amit Gupta (6)
- Andreas Hedström Mace (2)
- Felix Hemme (3)
- Lee Jamison (62)
- Dilan Johnpullé (12)
- Eugene Jose Espinoza (4)
- Christopher Kellermeyer (1)
- Chris Kirby (2)
- Olli-Antti Kivilahti (7)
- Jon Knight (2)
- David Kuhn (1)
- Rhonda Kuiper (1)
- macon lauren KohaCon2017 (1)
- Owen Leonard (53)
- Jesse Maseto (7)
- Julian Maurice (48)
- Matthias Meusburger (4)
- Kyle M Hall (137)
- Josef Moravec (120)
- Jason Palmer (1)
- Dominic Pichette (5)
- Simon Pouchol (2)
- Séverine QUEUNE (4)
- Laurence Rault (1)
- Liz Rea (1)
- Martin Renvoize (2)
- David Roberts (1)
- Benjamin Rokseth (9)
- Fridolin Somers (3)
- Lari Taskula (7)
- Mirko Tietgen (4)
- Mark Tompsett (53)
- Marc Véron (62)
- George Williams (1)

And people who contributed to the Koha manual during the release cycle of Koha 17.11.00.

  * Daniel Brady (1)
  * Julie Cameron-Jones (2)
  * Nick Clemens (1)
  * Chris Cormack (39)
  * Kelly Drake (1)
  * Jonathan Druart (14)
  * Karl Eagle (1)
  * Katrin Fischer (48)
  * Jessica Freeman (1)
  * Jack Gilmour (1)
  * Bernardo Gonzalez Kriegel (2)
  * Lee Jamison (25)
  * Owen Leonard (1)
  * vicky Lin (1)
  * Steve Macgregor (1)
  * Kelly McElligott (9)
  * Joanne Morahan (2)
  * Jessica Zairo (4)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Special thanks

I would like to thank again all the people who contributed to this release: the author of the patches, the testers, the QA team, as well as the manual contributors and the translators.

And in particular Tomás and Katrin who were always available when I needed them!

Thanks to BibLibre, ByWater Solution and PTFS Europe to continue to support and trust me.

## Notes from the Release Manager

This release was mainly focussed on:
 * improving the manual - it will be translatable very soon, to add more work to our translators :)
 * making our testing suite even more robust than before
 * security fixes

We also focussed a lot on elastic search. If you are interested by using it and make it ready for production in the last version, you should consider testing it and reporting everything that can be useful.

I would add that this release contains less enhancements and bugfixes as the previous major releases.

The number of contributors is also significantly lower. We need your help to report bugs, test or write patches, improve the manual, translate Koha or the manual, join IRC meetings, etc.

But new contributors already joined us! Welcome to them!

Enjoy this version of Koha, the best one, before the next one :)

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is master.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Nov 2017 16:04:47.
