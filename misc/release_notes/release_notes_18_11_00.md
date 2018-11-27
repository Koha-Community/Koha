# RELEASE NOTES FOR KOHA 18.11.00
27 Nov 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.00 is a major release, that comes with many new features.

It includes 16 new features, 235 enhancements, 432 bugfixes.



## New features

### Acquisitions

- [[15184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15184) Ability to duplicate existing order lines to a given basket

> Sponsored by BULAC - http://www.bulac.fr/


> This enhancements adds the ability to add an order to a basket (duplicate) from existing order lines. It will help serials acquisitions or other workflows where the same publication is ordered frequently.


- [[19166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19166) Add the ability to add adjustments to an invoice

> This enhancement to acquisitions allows libraries to record adjustments to invoices.  These may be based on feedback from a vendor, for example, a credit for returned books or damaged books, or a debit for extra service charges etc.



### Authentication

- [[12027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12027) Shibboleth authentication for staff client

> Sponsored by PTFS Europe  
Shibboleth authentication has long been available for the OPAC, this patch adds support for the staff client.


- [[18507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18507) Shibboleth auto-provisioning - Sync

> Shibboleth authentication has the ability to send an arbitrary number of attributes to koha; These attributes can be used to dynamically create (bug 12026) and, now with this patchset, update user records in koha.



### Cataloging

- [[18586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18586) Create module to mint RDF subject URIs

> The Koha::RDF module presents a method for minting RDF subject URIs in the format of {{ OpacBaseURL }}/bib/{{ biblionumber }}.  
This functionality isn't directly used yet in Koha, but is a precursor to RDF support.



### Circulation

- [[11897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11897) Stock Rotation for Koha

> Sponsored by PTFS Europe and North West England Public Libraries  
This is a batch process to automate the rotation of stock.  
It includes a staff client page, under tools, to manage rotas (ordered lists of locations for items to rotate to with associated durations for the items stay) and assign them to items.  
Once at least one rota is configured, and your staff user has the permission to add a rota to an item, then an additional tab will appear on each biblio record page allowing the management of which rota, if any, individual items are assigned.



### Documentation

- [[19817]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19817) Merge local and online documentations

> Great strides have been taken to improve Koha's online documentation. This enhancement removes the outdated local help system from the software, opting instead to contextually link to the well maintained online manual.



### Fines and fees

- [[19191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19191) Add ability to email receipts for account payments and write-offs

> Let your library go paperless. This enhancement enables the ability to send payment and write-off receipts by email.



### OPAC

- [[17602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17602) Integrate support for RecordedBooks (formerly OneClickDigital) API

> This feature integrates RecordedBooks functionality into the catalog, following the model of OverDrive.  
Searches on the OPAC will return a link to results in the RecordedBooks catalog if they are found. From that results page a user that is signed in and has a valid email matching a RecordedBooks account will be able to checkout the books directly from the results, and download them via their account page on the OPAC. Users will also be able to place holds on unavailable items.



### Patrons

- [[20312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20312) Add a link towards the last consulted patron

> A first pass at adding a handy feature to allow quickly navigating back to the last searched user in the staff client.



### REST api

- [[20942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20942) Add route to get patron's account balance

> Introduces API endpoints for dealing with patron accounts, a highly requested feature for third-party integrations.


- [[20944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20944) Add routes to add credits to a patron's account

> Introduces the API endpoint for dealing with patron account credits, a highly requested feature for third-party integrations.


- [[21116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21116) Add API routes through plugins

> Allows the extension of the Koha API via plugins. This can allow for custom vendor integrations and prototyping of new routes.



### Reports

- [[17282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17282) Ability to create charts for SQL reports

> Adds a form under report's result that allows to configure and draw a  
chart (pie, bar, line and combination).



### Serials

- [[21467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21467) Allow several receipts for a given subscription

> Sponsored by BULAC - http://www.bulac.fr/


> Allows the user to set a quantity for a serial order, useful in the case where payments are made per receipt to find individual issues. This development also allows for altering the total expected quantity for a serial in the case of a periodicity change.



### Z39.50 / SRU / OpenSearch Servers

- [[19436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19436) Add SRU support for authorities

> Some record sources only offer SRU connections (and not Z39.50) this update allows Koha to utilize these resources for authority records as we can for bibliographic records



## Enhancements

### About

- [[21317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21317) Format long lists under Koha Team tab as columns

> Koha's team of developers is always growing ☺. This patch changes the display from a long list to a nicely formatted four column layout.


- [[21319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21319) Remove highlight and tooltip on Koha Team version

> Two years ago we switched the version numbering system from 3.x to YY.MM format. At that time we added a tooltip and highlighted the version in red on the Koha Team tab of the about page.  This patch removes that now that a sufficient period of time has passed.


- [[21782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21782) Release team 18.11

### Acquisitions

- [[7651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7651) Add separate permission for managing currencies and exchange rates
- [[12395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12395) Save order line's creator

> Allow finer grained auditing of acquisition orders.


- [[18480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18480) Use modal for displaying patron details on add_user_search.pl to avoid redirect
- [[18639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18639) Separate replacement cost and retail price fields in acquisitions

> This patch attempts to remove some confusion as the 'Replacement price/rrp' field was being used as retail price during ordering process, but for item replacement price when receiving.  
This patch splits these fields so that each may be set independently. RRP will be used to determine costs while ordering, and replacement price will populate the items replacement price upon receiving.


- [[20366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20366) More information about orders linked to subscriptions on "Acquisition details" tab

> Sponsored by BULAC - http://www.bulac.fr/

- [[20966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20966) Add column configuration to table of orders in a basket
- [[20969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20969) Use modal to add and edit notes from basket
- [[20970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20970) Reformat basket information on acquisitions basket page
- [[21333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21333) Add ability to add to basket from a file

### Architecture, internals, and plumbing

- [[10306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10306) Koha to MARC mappings (Part 1): Allow multiple mappings per kohafield (for say 260/RDA 264)

> This patchset adds the ability to map several MARC fields to a single Koha field. The first existing mapped field will be saved into the database. This allows for flexibility in a system using RDA and AACR2 records where some store the publication data in the 260 fields and others in the 264.


- [[14302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14302) Remove GRS1 indexing related code

> Final removal of the GRS1 indexing mode code after the two year deprecation period.


- [[18072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18072) Add Koha objects for Branch Transfer Limits
- [[18887]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18887) Introduce new table 'circulation_rules', use for 'max_holds' rules
- [[19490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19490) Add a 'holds' column to the Batch Item Modification Tool
- [[19620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19620) Allow skipping of patrons with valid emails for Talking Tech
- [[19633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19633) Use alphanumeric error codes in upload
- [[19820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19820) Add unsafe param to GetMarcSubfieldStructure

> Sponsored by Gothenburg University Library

- [[19933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19933) Move C4::Members::patronflags to the Koha namespace - part 1
- [[20079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20079) Display stack trace for development installations
- [[20226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20226) Get rid of CATCODE_MULTI param decision in patron perl scripts
- [[20272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20272) XSLT_Handler should use alphanumeric error codes
- [[20287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20287) Move AddMember and ModMember to Koha::Patron
- [[20456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20456) Remove the C4::Serials::GetSubscriptionsFromBorrower
- [[20509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20509) Data consistency - authority types
- [[20521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20521) dev installations should run with problematic SQL modes

> To aid in catching possible SQL issue's early in development, this patch allows enabling the strictest of SQL modes for development (and makes it the default for continuous integration) environments.


- [[20622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20622) Add some color to bootstrap modal headers and footers
- [[20661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20661) Implement blocking errors for circulation scripts
- [[20669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20669) Add upgrade method to plugins

> This enhancement standardises the methods used by plugin authors to maintain their plugin data across plugin versions.


- [[20727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20727) Replace usage of File::Spec->tmpdir with C4::Context->temporary_directory
- [[20968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20968) Plugins: Add hooks to enable plugin integration into catalogue

> Sponsored by PTFS Europe


- [[20978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20978) Add Koha::Account::add_credit
- [[20990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20990) Add Koha::Account::outstanding_credits
- [[20997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20997) Add Koha::Account::Line::apply
- [[21178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21178) Add Koha::Patron::set_password method
- [[21183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21183) C4::Items - Remove GetItemnumberFromBarcode
- [[21184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21184) C4::Items - Remove GetBarcodeFromItemnumber
- [[21201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21201) C4::Items - Remove GetItemnumbersForBiblio
- [[21202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21202) C4::Items - Remove GetItemsByBiblioitemnumber
- [[21205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21205) C4::Acquisition - Remove GetOrderFromItemnumber
- [[21221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21221) Implement blocking errors for members/memberentry.pl
- [[21233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21233) Add Koha::Exceptions::Password class
- [[21299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21299) Move referer code from changelanguage to module in opac and staff
- [[21352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21352) Allow plugins to add CSS and Javascript to Staff interface

> This enhancement allows plugin authors to make adaptations to the staff client using css and javascript.


- [[21474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21474) Add the Koha::Subscription->frequency method
- [[21501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21501) Remove dead code from course reserves module
- [[21650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21650) C4::Items::GetLastAcquisitions has never been used and should be removed
- [[21681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21681) Remove C4::Accounts::getcharges
- [[21694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21694) Add the Koha::Account->lines method
- [[21696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21696) Use Koha::Account->lines from Koha::Account
- [[21719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21719) Fix typos in codebase

### Authentication

- [[3511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3511) Integration with Moodle
- [[17776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17776) Shibboleth Authentication is broken in plack

> Sponsored by PTFS Europe  
This enhancement adds support for using Shibboleth in a Plack environment. Caution should, however, be taken before enabling it as there are security implications to be aware of regarding header spoofing attacks that can be mitigated with additional care whilst configuring the native service provider and Apache: Please see https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPSpoofChecking for further details.


- [[19625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19625) Shibboleth auto-provisioning is broken in plack

### Cataloging

- [[3509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3509) Batch item edit
- [[9701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9701) Configure default indicators

> This adds default indicators to bibliographic frameworks. The table marc_tag_structure is adjusted. In order to make effective use of this enhancement, you may want to add values in your MARC frameworks administration.


- [[12747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12747) Add configurable extra column in Z3950 search result

> Sponsored by CCSR (https://ccsr.qc.ca)


> This allows to display MARC fields and subfields from the record in an extra column on the Z30.50 result list. The content of the column can be configured via the AdditionalFieldsInZ3950ResultSearch system preference.


- [[19263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19263) Advanced Editor - Rancor - Add auto control number (001) widget
- [[19349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19349) Allow to store biblio record's creator and last modifier in MARC
- [[20435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20435) Allow lowercase prefix in inventory value builder
- [[21318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21318) Add control number to authority Z39.50 search form

### Circulation

- [[3510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3510) Allow staff to change checkin date and time
- [[15139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15139) Show non-public item note in overdues report
- [[15494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15494) Block renewals by arbitrary item values

> This enhancement offers the possibility to prevent renewals given certain item values. Using a yaml syntax the library can specify certain item field values that, when matched, will prevent renewals for affected items.  
If using automatic renewal notices your notice should be updated to account for the new reason that renewals may be denied "item_denied_renewal"


- [[15524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15524) Set limit on maximum possible holds per patron by category
- [[19383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19383) Print hold slips without confirmation
- [[19719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19719) Add a new column for collection in the patron checkouts data table
- [[20322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20322) Circulation page layout and design update

> These patches give a facelift to the circulation homepage. All functionality remains the same, however, things have been moved to make the interface little friendlier and more responsive on different screens.


- [[20343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20343) Show number of checkouts by itemtype in circulation.pl
- [[20450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20450) Add collection to list of items when placing hold on specific copy
- [[20468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20468) Multiselect on staff article requests form
- [[21121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21121) New syspref to allow hiding of private patron data in circulation page

> Sponsored by: Toi Ohomai Institute of Technology in New Zealand and Catalyst IT.


- [[21380]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21380) Circulation history UI improvements - make barcode clickable

### Command-line Utilities

- [[20393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20393) Remove redundant 'koha.psgi' and 'plackup.sh' files
- [[20486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20486) Add --marc_conditions option to export_records.pl

> Sponsored by Gothenburg University Library

- [[20795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20795) koha-rebuild-zebra should pass through increased verbosity
- [[20915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20915) Use date --iso-8601 instead of date +%Y-%m-%d to be more readable and crontab friendly
- [[21011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21011) Data inconsistencies - items.holdingbranch | items.homebranch
- [[21150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21150) Data inconsistencies - item types
- [[21576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21576) Add a developer script to automatically fix missing filters

### Course reserves

- [[20467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20467) Add ability to batch add items to a course

### Fines and fees

- [[19617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19617) Allow 'writeoff of selected'
- [[20629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20629) Remove ability to 'reverse' payments
- [[20703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20703) Add ability to void any credit
- [[21673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21673) Koha::Account::Lines->total_outstanding must be used when needed

### Hold requests

- [[7534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7534) New OPACAllowUserToChooseBranch setting for only showing libraries allowing holds
- [[15486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15486) Restrict number of holds placed by day
- [[19469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19469) Add ability to split view of holds view on record by pickup library and/or itemtype

> Sponsored by Stockholm University Library

- [[21628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21628) Simplify holds awaiting pickup report

### I18N/L10N

- [[15395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15395) Internationalization: plural forms, context, and more

### ILL

- [[18591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18591) Allow an arbitrary number of comments on ILLs
- [[20651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20651) Improve display of "Toggle full supplier metadata"
- [[20772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20772) Make request metadata editable and add price_paid field

> Added the new price_paid field to ILL requests


- [[20797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20797) If an Ill request has an associated bib record, the detail view should contain a link to the record
- [[20995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20995) Add request ID to OPAC ILL requests display table
- [[21079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21079) Unify metadata schema across backends

### Installation and upgrade (web-based installer)

- [[20683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20683) Update German web installer for 18.05

### Label/patron card printing

- [[15766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15766) Give label and patron card batches a description

> Sponsored by Catalyst IT

- [[15836]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15836) Labels: Offer configuration option for splitting call numbers

> Sponsored by Goethe-Institut


### Lists

- [[19039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19039) Results of virtual shelves (lists) not sortable by date added

### MARC Bibliographic data support

- [[19835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19835) Update MARC frameworks to Updates 23+24+25 (Nov 2016, May and Dec 2017)
- [[20709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20709) Update German MARC frameworks to Updates 23-26 (Nov 2016, May and Apr 2018)
- [[20710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20710) Update MARC21 frameworks to Update 26 (April 2018)

### Notices

- [[15280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15280) Switch default CHECKOUT notice to Template Toolkit
- [[15282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15282) Switch default CHECKIN notice to Template Toolkit
- [[19743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19743) Header and Footer should be updated on each item for checkin / checkout / renewal notices
- [[20356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20356) Add EmailSMSSendDriverFromAddress system preference for overriding Email SMS send driver from address

> Sponsored by Gothenburg University Library


### OPAC

- [[8630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8630) Add covers from AdLibris to the OPAC and Intranet
- [[14222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14222) Sort holds in OPAC by priority
- [[14385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14385) Extend OpacHiddenItems to allow specifying exempt borrower categories

> Sponsored by Catalyst IT

- [[15287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15287) Use font-awesome on the OPAC
- [[17153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17153) Logging in during a search navigates to account page instead of back to search results
- [[17530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17530) Don't show 'article request' link when no article requests are permitted
- [[18236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18236) MARC21: Add classes to material type icons on intranet result lists and detail pages
- [[20400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20400) Add routing list tab to the patron account in OPAC

> Adds a routing list tab to the patron account in the OPAC that will be visible if RoutingSerials is turned on and the user is at least on one routing list.


- [[20427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20427) Convert OPAC LESS to SCSS
- [[20554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20554) New OPAC CSS
- [[20876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20876) The form_serialized_itype cookie is not used and should be removed
- [[20898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20898) Replace OPAC detail's results browser with non-JavaScript version
- [[20921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20921) Expose borrowernumber and branch when user is logged in to OPAC
- [[21157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21157) Improve style of OPAC login modal
- [[21174]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21174) Change default behavior to open OPAC cart in one click
- [[21340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21340) Add spans with classes around callnumbers in OPAC for additional styling
- [[21568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21568) Add more spans with classes around callnumbers in OPAC for additional styling

### Patrons

- [[11401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11401) Add support for Norwegian national library card
- [[11911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11911) Add separate permission for managing suggestions
- [[12258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12258) Datatable in Patrons Account Fines
- [[14391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14391) Granular permissions for the administration module
- [[15136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15136) Display item's homebranch in patron's fines list
- [[18635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18635) Koha::Patron->guarantees() should return results alphabetically
- [[19524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19524) Share patron lists between staff
- [[20819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20819) GDPR: Add a consent field for processing personal data in account menu and self-registration

> This report adds a new table patron_consent in order to save user consent for processing personal data (GDPR), but allows for future extension.  
It adds two preferences: GDPR_Policy and PrivacyPolicyURL. The first pref allows you to enforce giving consent before using the OPAC as a specific user. In permissive mode, we only show a warning on the consent page. The second pref allows you to add a URL to a privacy policy page.  
On the self registration page we also add asking for consent if the pref is enabled.


- [[20867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20867) Ability to show membership renewal date on moremember.pl page
- [[21337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21337) Add Koha::Patrons->delete
- [[21755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21755) Show patron updated date in circ menu

### REST api

- [[21334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21334) Add bibliographic content type definitions

### Reports

- [[9188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9188) Remove 'debug' information from patron statistics
- [[20260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20260) Use CodeMirror for the SQL reports editor
- [[20495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20495) Refactor C4::Reports.Guided - remove get_saved_report

### Searching

- [[18322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18322) Add facets for ccode to zebra
- [[20758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20758) Typo in BrowseResultSelection syspref description

### Searching - Elasticsearch

- [[18316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18316) Add weighting/relevancy options to ElasticSearch
- [[19604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19604) Elasticsearch Fixes for build_authorities_query for auth searching
- [[19893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19893) Alternative optimized indexing for Elasticsearch

> Sponsored by Gothenburg University Library


> This patch significantly improves the performance of the ElasticSearch indexing process and also improves the maintainability of this area of the codebase.


- [[20073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20073) Move Elasticsearch settings to configuration files
- [[20244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20244) Elasticsearch - Indexing improvements

> * Index both ISBN10 and ISBN13 where possible.  
* Add handling for alternative scripts.  
* Improve sort field handling


- [[20248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20248) Elasticsearch - Improvements to mappings UI and indexing script
- [[20602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20602) Use search fields weight/relevancy on OPAC simple search

### Searching - Zebra

- [[20078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20078) Indexes 'arl' (Accelerated reading level) and 'arp' (Accelerated reading point) not usable in search menus

### Serials

- [[3355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3355) Pagination in bib search for subscriptions
- [[17877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17877) Show internal and vendor note in acquisition info on subscription detail page
- [[18327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18327) Add the ability to set the received date to today on multi receiving serials
- [[20365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20365) Allow several open orders on subscription

> Sponsored by BULAC - http://www.bulac.fr/

- [[20726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20726) Display acquisition details on the subscription detail page

> Sponsored by BULAC - http://www.bulac.fr/

- [[21511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21511) Don't show acquisition details on subscription detail when there is no acq data

### Staff Client

- [[13406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13406) Add classes to MARC Authority display to enable CSS styling
- [[16280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16280) purge_suggestions.pl: Cron job log should tell number of days used
- [[17698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17698) Make patron notes show up on staff dashboard

> Sponsored by Catalyst IT

- [[19550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19550) Add links to related authorities for UNIMARC
- [[19902]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19902) Add column configuration to bibliographic record checkouts history table
- [[20339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20339) Unify MARC21 ISBN/ISSN handling in XSL
- [[20896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20896) Move serial enumeration to the right of callnumber on staff detail page
- [[21158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21158) Add cronjob references to the system preference descriptions if a cronjob is required
- [[21376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21376) Catalogue detail date handling improvements

### System Administration

- [[12365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12365) Allow descriptive notes to be added to circulation and fine rules

> Sponsored by Catalyst IT

- [[15520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15520) Add more granular permission for only editing own library's circ rules
- [[21403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21403) Add Indian Amazon Affiliate option to AmazonLocale setting

### Templates

- [[7547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7547) Printing a sorted cart
- [[10348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10348) Show number of items on tab headings in the staff client
- [[13618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13618) Add additional template filter methods and a filter presence test to Koha

> This important improvement to Koha's security policy greatly decreases the likelihood of XSS vulnerabilities being introduced into the Koha codebase moving forward. We have introduced the requirement for all variables inside templates to be passed through a filter and added a test to check this requirement is being upheld.


- [[19474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19474) Convert staff client CSS to SCSS
- [[19608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19608) Move admin templates JavaScript to the footer: The rest
- [[19709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19709) Move template JavaScript to the footer: Labels
- [[19833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19833) Disambiguation of "biblio", "biblio record" and "bibliographic record"
- [[19946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19946) Update popup window templates to use Bootstrap grid: Authority Z39.50 search
- [[20044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20044) Switch single-column templates to Bootstrap grid: Cataloging
- [[20045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20045) Switch single-column templates to Bootstrap grid: Various
- [[20217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20217) Make header's catalog search menu into a split button
- [[20220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20220) Move template JavaScript to the footer: Holds
- [[20520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20520) Re-indent moremember.tt
- [[20534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20534) Floating toolbar when editing vendors
- [[20585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20585) Label surname as name for organisation type patrons
- [[20641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20641) Switch single-column templates to Bootstrap grid: Various, part 2
- [[20650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20650) Switch single-column templates to Bootstrap grid: Various, part 3
- [[20667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20667) Update two-column templates with Bootstrap grid: Acquisitions part 1
- [[20668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20668) Update two-column templates with Bootstrap grid: Acquisitions part 2
- [[20672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20672) Update two-column templates with Bootstrap grid: Acquisitions part 3
- [[20690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20690) Update two-column templates with Bootstrap grid: Acquisitions part 4
- [[20731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20731) Move template JavaScript to the footer: Call number browser MARC plugin
- [[20736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20736) Update two-column templates with Bootstrap grid: Administration part 1
- [[20738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20738) Update two-column templates with Bootstrap grid: Administration part 2
- [[20739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20739) Update two-column templates with Bootstrap grid: Administration part 3
- [[20740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20740) Update two-column templates with Bootstrap grid: Administration part 4
- [[20741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20741) Update two-column templates with Bootstrap grid: Administration part 5
- [[20742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20742) Update two-column templates with Bootstrap grid: Administration part 6
- [[20743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20743) Update two-column templates with Bootstrap grid: Administration part 7
- [[20744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20744) Replace staff client header Koha logo gif with transparent png
- [[20779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20779) Style refresh for patron detail page
- [[20807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20807) Lost items report: Improve the display of CSV profile errors
- [[20984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20984) MARC21 subfield 300f - Type of Unit  does not display
- [[21112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21112) Re-indent staff client cart template
- [[21125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21125) Shortcut moredetail.pl on nonexistent biblionumber
- [[21132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21132) Highlight active filters on saved report page
- [[21137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21137) Replace BORROWER_INFO and USER_INFO with logged_in_user
- [[21166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21166) Add columns settings to the acquisition details table (record detail view)

> Sponsored by BULAC - http://www.bulac.fr/

- [[21237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21237) Clean up staff client SCSS
- [[21305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21305) Update two-column templates with Bootstrap grid: Patron clubs
- [[21306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21306) Update two-column templates with Bootstrap grid: Tags
- [[21341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21341) Style button on acquisitions existing record search with Bootstrap
- [[21409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21409) Add column configuration to course reserves
- [[21428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21428) Switch two-column templates to Bootstrap grid: Reports part 1
- [[21429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21429) Switch two-column templates to Bootstrap grid: Reports part 2
- [[21430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21430) Switch two-column templates to Bootstrap grid: Reports part 3
- [[21433]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21433) Switch two-column templates to Bootstrap grid: Tools part 1
- [[21434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21434) Switch two-column templates to Bootstrap grid: Tools part 2
- [[21435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21435) Switch two-column templates to Bootstrap grid: Tools part 3
- [[21437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21437) Switch two-column templates to Bootstrap grid: Patron lists
- [[21439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21439) Switch two-column templates to Bootstrap grid: Rotating collections
- [[21492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21492) Show subscriptions count in the sidebar menu
- [[21519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21519) Switch two-column templates to Bootstrap grid: Serials part 1
- [[21523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21523) Switch two-column templates to Bootstrap grid: Serials part 2
- [[21570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21570) Switch two-column templates to Bootstrap grid: Various
- [[21645]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21645) Clean up library groups template
- [[21647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21647) Clean up SRU fields mapping templates
- [[21715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21715) Ease translation of account and account offset type descriptions

### Test Suite

- [[20757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20757) Capture a screenshot on selenium errors
- [[21393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21393) Make template filter checks code reusable

### Tools

- [[13560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13560) MARC modification templates - Add an 'Add' option
- [[21216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21216) Notices - Add filter/search options to table
- [[21408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21408) Inventory - Warn of items possibly scanned out of order
- [[21413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21413) Inventory - Allow skipping items with waiting holds

### Web services

- [[20676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20676) svc/barcode should allow barcode to be printed without text

> Extends Koha /svc/barcode HTTP API. Adds a notext=1 parameter to the entry point in order to prevent the display of barcode text under the barcode's image.



### Z39.50 / SRU / OpenSearch Servers

- [[18973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18973) Auto focus the ISBN field


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[20014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20014) When adding to basket from a staged file item budgets are selected by matching on code, not id
- [[20798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20798) Client side validation for for fund selection prevents adding only some records to a basket
- [[20827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20827) Can't add owner to a fund
- [[20861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20861) Correct EDI permissions on some pages
- [[20972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20972) If ISBN has 10 numbers only the first 9 numbers are used

> Sponsored by Gothenburg University Library

- [[20979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20979) Error message when deleting bib attached to order
- [[21282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21282) Ordered/spent lists should use prices including tax for calculations

> Corrects the prices shown on the ordered/spent lists for each fund in acquisitions to show the price with taxes included. This will make the total shown on these pages match the total shown in the table on the acq start and fund pages.


- [[21347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21347) bad code for input field in item information tab of addorderiso2709 page
- [[21385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21385) Vendor search: Item count is incorrectly updated on partial receive
- [[21587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21587) Patrons to notify on receiving doesn't work on new order creation, only on modification
- [[21758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21758) Navigation in Z39.50 result pages not working in Acquisitions

> The next page, previous page, and go buttons now work when navigating the search results when adding a record to a basket from an external source.


- [[21853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21853) Internal software error when exporting basket group as PDF with Perl > 5.24.1

### Architecture, internals, and plumbing

- [[18821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18821) TrackLastPatronActivity is a performance killer
- [[20918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20918) left-side navigation broken on the checkout history page
- [[20922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20922) Koha::Number::Price must not be used in updatedatabase.pl
- [[21087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21087) Patron's password is hashed twice when the object is saved
- [[21133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21133) Missing use C4::Accounts statement in Koha/Patron.pm
- [[21195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21195) Makefile.t is failing due to new files for SCSS
- [[21222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21222) Patron's creation is broken
- [[21432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21432) Internal Server Error in Checkout History
- [[21481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21481) Translation tool still references to help templates
- [[21526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21526) TT variables used to build a link should be uri filtered
- [[21593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21593) Remove Group by clause in GetAuthValueDropbox
- [[21598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21598) budget_parent_id isn't in GROUP BY - GetBudgetHierarchy
- [[21599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21599) Incorrect decimal value: '' for column 'defaultreplacecost' - Cannot create item type
- [[21604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21604) Cannot add/edit funds, cannot add budgets
- [[21607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21607) Koha::Account::Line->apply should store credit offsets as negative amounts
- [[21612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21612) Incorrect GROUP BY in Koha::Virtualshelves
- [[21635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21635) Incorrect GROUP BY clause in batchMod.pl
- [[21669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21669) TT assignment statements must not be html filtered
- [[21869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21869) Bad update statement loses values for MarkLostItemsAsReturned

### Authentication

- [[18947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18947) Unexpected Active Directory LDAP authentication failure mode
- [[20879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20879) Shibboleth in combination with LDAP as an alternative no longer works
- [[21311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21311) Remove locked message from opac-auth.tt

> It is good security practice to not provide details which could confirm or deny the existence of an account. Previously, the simple "This account has been locked!" confirmed its existence which would only encourage more attacks by hackers.  
To prevent aiding malicious attacks, the message has been changed to something that does not expressly state the account has been locked. It only mentions that accounts will be locked after a number of failed attempts, instead of saying whether it is locked or not.  
So while a successful attempt will seem to have an invalid username or password suggestion after the account is locked, users should be reminded that they can always reset their password or contact library staff for help.



### Cataloging

- [[14662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14662) Allow blank values in pull downs in cataloguing forms when subfield is mandatory
- [[20761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20761) Advanced Cataloging Editor - Rancor - Some js files are not fetched using Asset
- [[20928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20928) Checkout status not showing patron
- [[21448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21448) Field 606 doesn't add multiple x subfields
- [[21742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21742) Incorrect count of youtube videos
- [[21774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21774) Cloned item subfields disappear when editing an item

### Circulation

- [[2696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2696) Fine payments should show what was paid for

> This adds a details view for every fine and payment in a patron account that will show detailed information about the payments made forward a fine and how a payment has been split up to pay towards several fines.


- [[10382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10382) collection and location not returning to null when removed from course reserves

> These patches ensure that unset values for items added to course reserves are unset when the course is disabled.


- [[20825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20825) Cannot checkout if item types at biblio level
- [[20889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20889) Items marked as not for loan can be checked out
- [[20934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20934) Biblio checkout history shows only current checkout
- [[21176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21176) decreaseLoanHighHolds does not properly calculate date when  TimeFormat set to 12 hour
- [[21231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21231) BlockReturnofLostItems does not prevent lost items being found
- [[21257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21257) Patrons checkout table throws JS error when location/collection not defined
- [[21293]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21293) Display of housebound delivery information broken by Bug 13618
- [[21464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21464) Overdues export is missing lot of fields
- [[21620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21620) Errors when using email from stockrotation.pl cronjob
- [[21641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21641) Software error when checking out an item with a charge associated with it
- [[21777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21777) Checkouts table in circulation is out of alignment
- [[21796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21796) Patron Restriction do not restrict checkouts if patron also has a fee/fine on their account

### Command-line Utilities

- [[20811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20811) Fix wrong usage of ModBiblio in bulkmarcimport.pl
- [[21122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21122) Make check-url-quick.pl handle utf8 characters in urls gracefuly

### Course reserves

- [[21603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21603) Incorrect GROUP BY clause in SearchCourses

### Database

- [[20773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20773) bug 20724 follow-up - Database cleanup
- [[21129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21129) New ALTER IGNORE TABLE entries need correction in updatedatabase.pl
- [[21617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21617) statistics.ccode is not long enough (see also dbrev 18.06.00.032)
- [[21682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21682) Stock Rotation: Update DB is failing with strict_sql_modes ON

### Fines and fees

- [[13098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13098) Item lost multiple times by the same patron will create only be charged once
- [[20840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20840) Internal Server Error when clicking on "Details" button
- [[20946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20946) Cannot pay fines for patrons with credits
- [[21702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21702) mancredit.pl incorrectly passes user_id instead of the patron id

### Hold requests

- [[20822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20822) Can't find HOLD_SLIP template when printing
- [[21611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21611) Priority in request.pl shows 1 instead of Waiting

### I18N/L10N

- [[21823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21823) Cannot update or create translations

### ILL

- [[21377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21377) Variable declarations erroneously filtered

### Installation and upgrade (command-line installer)

- [[16690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16690) Improve security of remote database installations
- [[17234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17234) ALTER IGNORE TABLE is invalid in mysql 5.7.  This breaks updatedatabase.pl
- [[21440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21440) koha-create expects the file passed by $DEFAULTSQL to be in gzip format

> Add support to koha-create to allow it to accept both compressed and uncompressed files for DEFAULTSQL



### Installation and upgrade (web-based installer)

- [[21149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21149) Administrator creation in onboarding always fails

### Label/patron card printing

- [[8604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8604) Patron cards made for patrons which don't have patron images use preceding card's image
- [[21281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21281) Label Template - Creation not working

### MARC Bibliographic data support

- [[21749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21749) Importing MARC frameworks from pre-9701 fails

### Notices

- [[21529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21529) Fix display of HTML tags in print notices

### OPAC

- [[20763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20763) AllowPurchaseSuggestionBranchChoice triggers error opac-suggestions.pl is visited without logging in
- [[20832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20832) Opac user page crash when there is an overdue fine and not any rental charge for a patron
- [[20875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20875) OpacAddMastheadLibraryPulldown displays an empty list
- [[21018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21018) OPAC Resource URL Broken if Tracklinks is enabled
- [[21374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21374) Self registration e-mail verification does not work
- [[21475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21475) Error in the OPAC when viewing a record which has no biblio-level itemtype
- [[21476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21476) Incorrect filter prevents HTML5 media from playing in the OPAC
- [[21479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21479) Removing from cart removes 2 items
- [[21771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21771) Password recovery is broken (see 20023)
- [[21878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21878) Fix few links for opac pagination and facets (no uri filter)

### Patrons

- [[13655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13655) Can't save organisation type patron without entering userid/password
- [[20903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20903) Print payment receipt on child patron could end with server error
- [[20951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20951) Koha::Patron::Discharge is missing use Koha::Patron::Debarments
- [[20981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20981) Organization name missing from patron search results
- [[21068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21068) Remove NorwegianPatronDB related code
- [[21085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21085) Can't edit patrons with housebound module active
- [[21136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21136) Error "No property select_city for Koha::Patron" when saving patron record
- [[21208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21208) Housebound deliverer/chooser have wrong name when creating a visit

### SIP2

- [[21020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21020) Return branch not set for transfer when using SIP
- [[21471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21471) Misspelled variable name in _get_outstanding_holds
- [[21486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21486) SIP does not return  checked out (charged) items on patron_information request

### Searching

- [[20838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20838) Search by group of libraries is broken

### Searching - Elasticsearch

- [[19365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19365) link_bibs_to_authorities.pl doesn't work with Elasticsearch

> Sponsored by National Library of Finland

- [[21032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21032) Refining a search made on a specific index fail

### Self checkout

- [[21054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21054) Extra closing body tag in sco-main.tt prevents slip printing

### Serials

- [[21554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21554) Using Subscription Batch Edit produces Software Error

### Staff Client

- [[20652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20652) Sort after item type search fails
- [[20899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20899) Patron name not showing on issuehistory.pl
- [[20998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20998) Non superlibrarians cannot search for patrons using the quicksearch at the top
- [[21418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21418) Incorrectly filtered markup in staff client lists
- [[21703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21703) Placing holds in staff is broken (TT filter)

### System Administration

- [[21151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21151) SRU search fields mapping pop-up comes up empty

### Templates

- [[13692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13692) Series link is only using 800a instead of 800t
- [[20977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20977) Javascript vars used in confirm_deletion in catalog.js do not match strings in catalog-strings.inc
- [[21163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21163) Basket group detail page layout is broken
- [[21663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21663) Incorrect filter prevents predefined notes from being added to patron acccounts
- [[21704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21704) Editing subfields in bibliographic frameworks is broken (TT filter)

> Sponsored by Theke Solutions

- [[21706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21706) Editing subfields in authority frameworks is broken (TT filter)
- [[21805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21805) Duplicate include file in search results template causes JS error
- [[21814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21814) System preferences save button can be hidden by language menu

### Test Suite

- [[20906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20906) Fix Debian 9 Test Failures
- [[21567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21567) WebService:ILS related tests fail during package build
- [[21597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21597) Test suite is still failing with new default SQL modes
- [[21600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21600) t/db_dependent/api/v1/patrons.t is failing with new SQL modes

### Tools

- [[20084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20084) Patron card creator: layouts Industrial2of5 and COOP2of5 broken with error "Invalid Characters"
- [[21656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21656) Syntax Error in Stock Rotation Default Notice Template

### Web services

- [[21046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21046) ILSDI - AuthenticatePatron returns a wrong borrowernumber if cardnumber is empty
- [[21199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21199) Patron's attributes are displayed on GetPatronInfo's ILSDI output regardless opac_display
- [[21203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21203) ILS-DI - GetRecords crashes on non-existent records

### translate.koha-community.org

- [[21480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21480) misc/translator/translate does not work with perl 5.26


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[17597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17597) Outdated translation credits
- [[20720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20720) Add libraries (sponsors) to the about page
- [[20818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20818) Missing QA manager entry in 18.05 release notes

### Acquisitions

- [[3849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3849) Descriptions of acquisition permissions are unclear
- [[9775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9775) unitprice should be hidden when creating an order
- [[15408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15408) Timestamp on funds not updated when you duplicate a budget
- [[16739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16739) Generate EDIFACT on basket groups falsely showing when configuration is incomplete
- [[16754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16754) Use validation plugin in budgets, planning, and contracts
- [[19271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19271) Ordered/Spent lists should display vendor name, not vendor code
- [[19453]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19453) Client side validation broken for "Fund" select
- [[20892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20892) Wrong basketgroup link in histsearch.pl
- [[21033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21033) Remove few warns in acqui/basket.pl
- [[21048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21048) suggest_status not behaving properly
- [[21097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21097) Missing optgroup closing tag in orderreceive.tt
- [[21288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21288) Slowness in acquisition caused by GetInvoices
- [[21324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21324) Missing aoColumns definition in acqui/parcel receivedt table
- [[21356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21356) Missing space in parcel.tt
- [[21387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21387) Receive items from - form should include tax hints the same as the ordering form
- [[21398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21398) Search term when adding an order from an existing record should be required
- [[21417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21417) EDI ordering fails when basket and EAN libraries do not match
- [[21425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21425) basketno not being interpolated into error message
- [[21537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21537) Template error when creating a new order from a suggestion
- [[21619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21619) Tax hints should not be abbreviated
- [[21725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21725) Incorrect HAVING in group by in Acquisitions.pm
- [[21799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21799) Change wording for quantity input field on order receive page

### Architecture, internals, and plumbing

- [[15734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15734) Audio Alerts broken
- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[18720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18720) Get rid of "die" in favor of exceptions in C4::Acquisition::GetBasketAsCsv
- [[19687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19687) Recent upgrade to 17.05.04.000 bulkmarcimport started to fail

> Sponsored by Gothenburg University Library

- [[19991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19991) use Modern::Perl in OPAC perl scripts
- [[20187]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20187) New rewrite rules can break custom css
- [[20259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20259) Shorter JS and CSS rewrite rule
- [[20631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20631) C4::Acounts claims to use ReturnLostItem but doesn't
- [[20696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20696) Remove a few ugly "eq undef" comparisons
- [[20702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20702) Bind results of GetHostItemsInfo to the EasyAnalyticalRecords pref
- [[20767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20767) "The method is not covered by tests!" should give more information
- [[20851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20851) Missing module in circ/article-request-slip.pl
- [[20886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20886) Koha::Object::TO_JSON indiscriminately casting to integer
- [[20911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20911) Search history page forms use 'GET' and this limits the number of entries that can be submitted
- [[20980]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20980) Manual credit offsets are stored as debits

> This change may affect existing reports. Credits will no longer be recorded as 'debits' but rather get their own 'Manual Credit' type.


- [[21008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21008) pay.pl and paycollect.pl raise warning
- [[21022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21022) Exceptions should skip stringifying if message manually passed
- [[21056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21056) Changing the logged in library can fail sporadically
- [[21082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21082) OverDrive authentication method no longer supported
- [[21115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21115) Add multi_param call and add divider in cache key in svc/report and opac counterpart
- [[21154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21154) Remove unused subs from C4::Serials
- [[21182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21182) acqui/check_duplicate_barcode_ajax.pl is not longer in use
- [[21207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21207) C4::Overdues::GetItems is not used
- [[21238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21238) TemplateToolkit.t is failing on slow server
- [[21396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21396) Missing use statements in Koha::Account
- [[21404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21404) Remove unused variables in C4::Breeding->_auth_build_query
- [[21500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21500) Warnings in rotating collections
- [[21584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21584) Wrong offset type for Lost Item
- [[21621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21621) Incorrect GROUP BY in tools/letter.pl
- [[21639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21639) Phone notice transports do not exist for new installs
- [[21680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21680) Remove dead code C4::Accounts::fixaccounts
- [[21804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21804) Bad rebase reintroduced C4::Accounts::getcharges
- [[21867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21867) Replace remaining document.element.onchange calls in marc_modification_templates.js

### Authentication

- [[13779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13779) sessionID declared twice in C4::Auth::checkauth()
- [[20023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20023) Password recovery should be case insensitive
- [[21323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21323) Redirect page after login missing multiple params

### Cataloging

- [[15360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15360) Incorrect or mislabeled behavior on Authorities "New from Z39.50" Button
- [[16424]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16424) Advanced editor reverts records back to Default framework

> After this patch, frameworks will be handled correctly by the advanced cataloguing editor.


- [[18655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18655) Unimarc field 210c fails on importing fields with a simple quote
- [[18822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18822) Advanced editor - Rancor - searching broken under Elasticsearch
- [[19970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19970) Revise change of bug 19413 to work better for translations
- [[20592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20592) updateitem.pl causes database errors when empty non-public item notes updated
- [[20760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20760) Advanced Cataloging Editor - Rancor - AuthorisedValues are incorrectly fetched
- [[20785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20785) Advanced Editor does not honor MarcFieldDocURL
- [[20829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20829) 'Link to host item' gives internal server error
- [[21009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21009) Max length of inputs on editing/adding items is broken
- [[21053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21053) Editing 008 field with a hash overwrites data
- [[21064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21064) Advanced cataloging editor - rancor - check for changes should return 'undefined' instead of 'undef'
- [[21362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21362) Advanced MARC Editor - Rancor - Tab navigation not working in fixed fields
- [[21365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21365) BiblioAddsAuthorities does not work with the Advanced MARC Editor - Rancor
- [[21407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21407) Can't enter new macros in the advanced cataloging editor (rancor)
- [[21556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21556) Deleting same record twice leads to fatal software error
- [[21666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21666) Advanced editor search- error is given for 'Unsupported Use attribute' when searching on title + author

### Circulation

- [[16420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16420) Buttons inconsistent between "Hold found" and "Hold found (waiting)" dialogs in checkin
- [[17561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17561) ReserveSlip needs itemnumber for item level holds on same biblio
- [[18677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18677) issue_id is not added to accountlines for lost item fees
- [[20120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20120) Prevent writeoffs of more than the amount owed for a fee
- [[20487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20487) AddReturn should clear items.onloan for unissued items
- [[20598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20598) Accruing fines not closed out by longoverdue.pl if WhenLostForgiveFine is not enabled
- [[20660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20660) AddReturn should use return date override for debarments
- [[20793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20793) Don't show holds link in result list when staff user doesn't have place_holds permission
- [[20794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20794) Don't show holds tab when user doesn't have circulate_remaining_permissions
- [[21168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21168) Error on circ/returns.pl after deleting checked-in item
- [[21463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21463) Library is no longer displayed in the overdue list
- [[21553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21553) Javascript error on rota page
- [[21562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21562) Sorting on checkout date is broken

### Command-line Utilities

- [[20893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20893) batchRebuildItemsTables.pl has incorrect parameter
- [[21035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21035) runreport.pl prints only a newline when printing a row that has a field that contains an embedded newline
- [[21322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21322) process_message_queue.pl --type should take an argument
- [[21640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21640) Itivia outbound script doesn't print to STDOUT
- [[21698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21698) FIX POD of cancel_unfilled_holds.pl

### Course reserves

- [[21349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21349) Instructors with special characters (e.g. $, ., :) in their cardnumber cannot be removed from course reserves

### Database

- [[5458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5458) length of items.ccode disagrees with authorised_values.authorised_value
- [[20777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20777) Remove unused field accountlines.dispute
- [[21015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21015) Members.pm slow because it loads twice Koha::Schema

### Developer documentation

- [[21077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21077) Fix comment for statistics.type in installer/data/mysql/kohastructure.sql

### Fines and fees

- [[20285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20285) Lost item refund won't always pay down lost item fee first
- [[21167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21167) Price should be correctly formatted on printed fee receipt and invoice
- [[21196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21196) C4::Overdues::CalcFine should consider default item type replacement cost
- [[21462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21462) "Filter paid transactions" stopped working after html-table was changed

### Hold requests

- [[21075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21075) AutoUnsuspendHolds should unsuspend holds <= today
- [[21076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21076) Javascript error on article requests page
- [[21320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21320) Holds to pull should honor syspref AllowHoldsOnDamagedItems
- [[21389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21389) Javascript error on article requests page

### I18N/L10N

- [[16621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16621) Translatability: Issues in opac-user.tt (sentence splitting)

> Fix translatability issues due to sentence splitting in  
koha-tmpl/opac-tmpl/bootstrap/en/modules/opac-user.tt


- [[19500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19500) Make module names on letters overview page translatable
- [[20332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20332) Untranslatable strings in grouped OPAC results
- [[21029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21029) "Suspend until" in modal in staff patron account is not translatable
- [[21351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21351) Traditional Chinese Language pack should have file name "zh-Hant-TW" not "zh-Hans-TW"
- [[21490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21490) Disambiguation of "Order"

### ILL

- [[20548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20548) Remove copyright clearance workflow from staff created ILL requests
- [[20941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20941) Displaying requests does not display request material type
- [[20996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20996) Fix API response time on ILL request endpoint

> This patch makes the <branch> configuration section compulsory in the <interlibrary_loans> section of your Koha configuration file. The <branch> section allows you define per-branch Interlibrary loan options for each branch. In it's most basic form, the branch section can be:  
<branch><code>code_for_your_branch</code></branch>


- [[21289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21289) Error when sending emails to partner libraries
- [[21497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21497) Dates should be correctly formatted for ILL requests in OPAC
- [[21516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21516) Request notes CSS bug makes them unreadable
- [[21585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21585) Missing firstnames should be gracefully ignored in ILL requests table
- [[21835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21835) Request ID is displayed as NaN

### Installation and upgrade (command-line installer)

- [[8]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8) TransferLog ErrorLog apache parameters
- [[490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=490) Poor display
- [[21426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21426) setting USE_MEMCACHED to "no" in koha-sites.conf does not have any effect
- [[21654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21654) Installer is loading a non-existent file

### Installation and upgrade (web-based installer)

- [[15717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15717) Installer: Step 3 has HTML tag br showing

### Label/patron card printing

- [[6647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6647) Label item search should use standard pagination routine
- [[20765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20765) Search for items by acqdate does not work in label batch

### Lists

- [[17886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17886) Don't show option to add to existing list if there are no lists in staff
- [[21297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21297) "More lists" screen missing "Select an Existing list" fieldset when all lists are public
- [[21629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21629) List sort on call number does not use cn_sort

> With this patch lists sorted on call number will now use the machine sortable form of the callnumber from items.cn_sort for better results.


- [[21874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21874) Encoding broken in list and cart email subjects

### MARC Authority data support

- [[21581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21581) Matching rules for authorities do not respect 'Search index' setting
- [[21644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21644) UNIMARC XSLT display of 210 in intranet

### MARC Bibliographic data support

- [[20700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20700) Update MARC21 leader/007/008 codes
- [[20910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20910) 773$g not displayed if $0 is present

> Sponsored by Escuela de Orientacion Lacaniana


### Notices

- [[15971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15971) Serial claim letters should allow the use of all biblio and biblioitems fields (like issn)
- [[21277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21277) fr-CA translation for notices in sample_notices.sql

### OPAC

- [[16575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16575) Irregular behaviour using window.print() followed by window.location.href=
- [[17869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17869) Don't show pick-up library for list of holds in OPAC account when there is only one branch
- [[19291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19291) Make breadcrumbs for OPAC search history consistent with other patron account pages
- [[19849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19849) Rebase of bug 16621 partially reverted bug 12509
- [[20053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20053) Drop type attribute "text/javascript" for `<script>` elements used in OPAC templates

> Prevents warnings about type attribute being generated for `<script>` elements when testing the OPAC pages using W3C Validator for HTML5.


- [[20090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20090) Missing Script Statement for Novelist Select on Some Record Displays in OPAC
- [[20507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20507) Shelf browser does not update image sources when paging
- [[20756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20756) OPAC "Share list" button should be styled with an icon
- [[20953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20953) Discharge can be requested several times on OPAC
- [[20994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20994) Fix capitalization on OPAC result list "Save to Lists"
- [[21078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21078) Overdrive JS breaks when window opened from another site
- [[21094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21094) Syndetics: always use https instead of http
- [[21127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21127) Remove jqTransform jQuery plugin from the OPAC
- [[21493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21493) Remove incomplete icon style from serial issues tabs
- [[21590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21590) "send list" email uses the term "virtual shelf", this should be "list".

### Packaging

- [[17084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17084) Automatic debian/control updates (master)
- [[17237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17237) Stop koha-create from creating MySQL users without host restriction
- [[18250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18250) koha-common should start after memcached
- [[20920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20920) Plack timeout because of missing CGI::Compile Perl dependency
- [[20949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20949) Koha depends on Clone
- [[21267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21267) X_FORWARDED_PROTO header should be set in apache

### Patrons

- [[2426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2426) Management permissions is deprecated
- [[3886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3886) Can't print receipt w/out allowing "Add or modify borrowers" permission
- [[7996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7996) Patron modification log requires parameters permission
- [[20656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20656) Print summary for patron shows paid fines and formats payments badly

> Print summary for patron will now show only outstanding fines/payments. To print all fines/payments you can use the 'print' option for the table in the accounts page for the patron.


- [[20806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20806) Item type in holds history table should be written as description, not code
- [[20991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20991) Error will reset category when editing a patron
- [[21025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21025) Koha::Patron::Discharge is missing use C4::Letters
- [[21041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21041) "Merge patrons" button remains disabled with "Select all" option
- [[21080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21080) patron attribute classes break patron's edit view
- [[21096]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21096) Garbled username on intranet login page
- [[21209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21209) When trying to edit housebound roles, the edit button goes to patron attributes
- [[21353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21353) Merge patrons option only available with manage_patron_lists
- [[21596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21596) Handle default values when storing Koha::Patron
- [[21634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21634) "Circulation" option is lost when viewing patron's logs
- [[21649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21649) Add child button in the staff client is no longer automatically populating the parent address

### REST api

- [[21031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21031) Apache Rewrite rules don't work for API when using anything but Debian package Plack configuration

### Reports

- [[16653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16653) reports/cat_issues_top.pl does not export "Count of checkouts" column as CSV
- [[20945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20945) Report params not escaped when downloading
- [[21005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21005) Missing row/column defaults cause unexpected results in report wizards
- [[21541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21541) HTML filter breaks HTML rendering of SQL output
- [[21837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21837) Overdues report shoudln't set homebranchfilter as holdingbranchfilter

### Searching

- [[9968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9968) Incorrect index used for 'Standard number' in advanced search
- [[14716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14716) Correctly URI-encode URLs in XSLT result lists and detail pages
- [[18799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18799) XSLTresultsdisplay hides the icons
- [[19390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19390) OPAC view link in staff results should open in a new tab
- [[20151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20151) Search is broken when stemming has no language
- [[20864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20864) Only set bibs_selected cookie when BrowseResultSelection is activated
- [[21455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21455) Authority search options get shuffled around when you click on 'Search'

### Searching - Elasticsearch

- [[19502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19502) Result sets limited to 10000
- [[20273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20273) Elasticsearch: Auth-finder.pl autocomplete must use search_auth_compat

### Searching - Zebra

- [[20697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20697) Remove some Host-Item-Number noise from zebra-output.log when EasyAnalyticalRecords is not used
- [[21416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21416) 'gr' option missing from ZEBRA_LANGUAGE options in koha-sites.conf

### Serials

- [[7136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7136) Correct description of Grace period for subscriptions
- [[20241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20241) Fix display of publication year in subscription record search for MARC21
- [[20351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20351) Implement blocking errors for serials scripts
- [[20778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20778) Unable to delete a subscription
- [[21505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21505) Box around 'Additional fields' does not contain the fields
- [[21552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21552) RoutingListNote should use raw filter and display HTML unescaped

### Staff Client

- [[28]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28) testing to see if this posts to the list
- [[17625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17625) 245f and 245g are not displayed in XSLT
- [[18521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18521) Renew and search hotkeys are swapped on returns page.
- [[20329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20329) Text input fields are wider than the fieldset class they are inside of
- [[20504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20504) Language attribute in html tag is empty in system preference editor
- [[20647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20647) When ILL is enabled the hover effect on the ILL requests button is wrong.
- [[20781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20781) 0 months is not a valid enrollment period and causes errors
- [[20919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20919) A Zebra query is done for each item when opening a record detail page
- [[21248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21248) Fix COinS carp in MARC details page on unknown record
- [[21291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21291) Article requests page doesn't show MARC, LabeledMARC and ISBD in sidebar
- [[21456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21456) The 'New authority' button lists authority types inconsistently
- [[21470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21470) Due date no longer shown in red when viewing checkouts for a patron
- [[21583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21583) Novelist Select staff client not working in staff client - ns2init.js not loading
- [[21606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21606) Issues with matching rules

### System Administration

- [[221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=221) Add itemtypesearchgroups page mistitled
- [[255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=255) Form fields too small for text
- [[834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=834) Add Category Fields Need Descriptions
- [[14446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14446) Resolve "Use of uninitialized value in goto" in admin/preferences.pl
- [[19179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19179) Email option for SMSSendDriver is not documented as a valid setting
- [[21131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21131) Changing and restoring a WYSIWYG preference can result in unexpected behaviour
- [[21144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21144) ROADTYPE missing from authorised value categories list
- [[21279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21279) Transport cost matrix shows html entity in all empty cells
- [[21625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21625) Fix wording and typo in SMSSendDriver system preference description
- [[21730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21730) PA_CLASS missing from list of authorized values categories
- [[21815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21815) Rephrase HidePersonalPatronDetailOnCirculation a little bit

### Templates

- [[10442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10442) Remove references to non-standard "error" class
- [[13272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13272) Many inputs lack a type attribute
- [[14786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14786) Use text "MARC file" instead of "ISO2709" everywhere
- [[19511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19511) Local cover images not centered in table column in staff client search results
- [[20223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20223) Merge members-menu and circ-menu inc files
- [[20559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20559) Occurrences of loading-small.gif still exist
- [[20698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20698) Remove obsolete template: transfer-slip.tt
- [[20752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20752) Files tab in patron account is not properly capitalized
- [[20774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20774) Trivial HTML error in itemslost.tt
- [[20791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20791) Correct capitalization on 'Notices and slips' page
- [[20805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20805) Update child to adult patron process broken on several patron-related pages
- [[20814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20814) Display issue with 'Saved reports' tabs when memcached is off
- [[20828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20828) Step 4 of moremember is used for Housebound and additional attributes
- [[20831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20831) (Bug 9573 follow-up) Pass id as first parameter instead of selector
- [[20881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20881) Order receiving: Price filter missing on_editing
- [[20931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20931) JS error "ReferenceError: $ is not defined" when CircSidebar is turned on
- [[20974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20974) Remove files left behind after removing Solr
- [[20999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20999) Remove invalid 'style="block"' from OPAC templates
- [[21038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21038) Reserves should be holds
- [[21050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21050) Datepickers on LabelItemSearch broken
- [[21099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21099) Floating toolbars reposition too late
- [[21139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21139) The floating toolbars have some issues
- [[21145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21145) The "Column visibility" button should not be displayed at the OPAC
- [[21148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21148) Dropdowns styled by the Select2 plugin do not highlight missing required fields
- [[21164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21164) Fix alignment on new basket form in acquisitions
- [[21185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21185) Incorrect title tag on tags review page
- [[21186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21186) Incorrect Bootstrap modal event name in multiple templates
- [[21223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21223) Some floating values are wrong
- [[21229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21229) Correct nesting and specificity for some button styles
- [[21234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21234) Remove our .clearfix class in favor of Bootstrap's
- [[21239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21239) CSS regressions caused by SCSS move
- [[21243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21243) Regression: SRU mapping popup for bibliographic records is unstyled
- [[21285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21285) Select2 broken on high dpi screens
- [[21350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21350) Add Font Awesome icon for pending onsite checkouts link
- [[21397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21397) Routing list tab not marked as active
- [[21506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21506) DataTables four button pagination uses the wrong icon for First and Last buttons
- [[21513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21513) Add a 'Cancel' button to the authority editor and remove duplicate 'Save' button
- [[21531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21531) Subscription "New fields" button should read "New field"
- [[21550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21550) DataTables four button pagination uses the wrong icon for disabled buttons
- [[21740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21740) Fixed-length fields show _ instead of @ when editing subfields
- [[21838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21838) Wrong alignment of instructors in course reserves
- [[21839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21839) Fix capitalization for "Print Label"

### Test Suite

- [[18959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18959) Text_CSV_Various.t must skip if Text::CSV::Unicode is not installed
- [[20177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20177) Remove GROUP BY clause in GetCourses
- [[20776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20776) Add Selenium::Remote::Driver to dependencies
- [[20866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20866) ArticleRequests.t fails on existing requests
- [[20900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20900) Yet another test assumes that CPL is present
- [[21023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21023) Remove warning in t/db_dependent/Circulation/Chargelostitem.t
- [[21086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21086) Wrong mock of DateTime->now in tests
- [[21095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21095) Tests should expect ccodes facets now (since we have ccode facets)
- [[21134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21134) Wrong error handling in Koha/Patron/Modification.pm hides a bug
- [[21155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21155) SwitchOnSiteCheckouts.t is failing randomly
- [[21188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21188) t/db_dependent/Circulation/issue.t is failing
- [[21213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21213) Circulation.t needs diagnostics
- [[21230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21230) Reserves.t is failing randomly
- [[21262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21262) Do not format numbers for editing if too big
- [[21295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21295) Update selenium tests for Admin pages bootstrap updates
- [[21355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21355) GetDailyQuotes.t is fragile
- [[21360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21360) IssueSlip.t is failing if run at 23:59
- [[21454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21454) Price filtered variables should not need to be html filtered
- [[21536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21536) t/Koha_ExternalContent_RecordedBooks.t skips more tests than scheduled
- [[21613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21613) Turn strict SQL modes on for tests
- [[21717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21717) TestBuilder.t is failing randomly
- [[21770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21770) t::lib::QA::TemplateFilters should allow html_entity in href
- [[21775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21775) Lack of tests for audio alerts
- [[21787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21787) GetHardDueDate.t has a silly test

### Tools

- [[20131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20131) Inventory optional filters always shows "For loan" for value 0
- [[20564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20564) Error 500 displays when uploading patron images with a zipped file
- [[21113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21113) Hint Messages are misleading at "Merge Selected Patrons" in Patron Lists
- [[21141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21141) Batch item modification tool throws error 500 when an itemnumber is invalid
- [[21142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21142) Batch item/record modification/deletion tools does not open uploaded files in utf-8
- [[21242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21242) Modification log redirects you to circulation with no borrower if 'Object' field is not populated with borrowernumber
- [[21579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21579) showdiffmarc tool during manage staged batches always looks for biblios even when matching authorities
- [[21614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21614) Search bar on Stock rotation page displays both [-] and [+] simultaneously
- [[21615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21615) "Stock rotation" is at the wrong place in the Tools left side menu
- [[21819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21819) Marc modification templates action always checks Regexp checkbox
- [[21854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21854) Patron category is not showing during batch modification

### Web services

- [[21226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21226) Remove use of retired OCLC xISBN service

> OCLC has now discontinued support for the xisbn service.  One can continue to use the functionality that this service provided to Koha by switching on the ThingISBN preferences as an alternative.


- [[21235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21235) Remove services_throttle if not required for ThingISBN
- [[21542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21542) OverDrive password submission should use a password field to mask input

## New sysprefs

- AdditionalFieldsInZ3950ResultSearch
- AdlibrisCoversEnabled
- AdlibrisCoversURL
- ArticleRequestsLinkControl
- ElasticsearchIndexStatus_authorities
- ElasticsearchIndexStatus_biblios
- GDPR_Policy
- HoldsAutoFill
- HoldsAutoFillPrintSlip
- HoldsSplitQueue
- ItemsDeniedRenewal
- KohaManualBaseURL
- KohaManualLanguage
- MarcFieldForCreatorId
- MarcFieldForCreatorName
- MarcFieldForModifierId
- MarcFieldForModifierName
- OpacHiddenItemsExceptions
- OverDrivePasswordRequired
- PrivacyPolicyURL
- RecordedBooksClientSecret
- RecordedBooksDomain
- RecordedBooksLibraryID
- RotationPreventTransfers
- StockRotation
- UseEmailReceipts
- showLastPatron

## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (94%)
- Armenian (94%)
- Basque (64.4%)
- Chinese (China) (65.1%)
- Chinese (Taiwan) (96.1%)
- Czech (89.8%)
- Danish (56.5%)
- English (New Zealand) (89.9%)
- English (USA)
- Finnish (85.3%)
- French (94.4%)
- French (Canada) (94.1%)
- German (100%)
- German (Switzerland) (93.6%)
- Greek (76.7%)
- Hindi (95.5%)
- Italian (92.2%)
- Norwegian Bokmål (94.8%)
- Occitan (post 1500) (60.6%)
- Polish (86.8%)
- Portuguese (100%)
- Portuguese (Brazil) (78.2%)
- Slovak (87.5%)
- Spanish (94%)
- Swedish (92.3%)
- Turkish (95.7%)
- Ukrainian (58%)
- Vietnamese (54.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.00 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)

- Module Maintainers:
  - REST API -- [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - Elasticsearch -- [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)

- QA Team:
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - Josef Moravec
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.inc)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 18.05 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.11.00:

- BULAC - http://www.bulac.fr/
- CCSR (https://ccsr.qc.ca)
- Catalyst IT
- Escuela de Orientacion Lacaniana
- Goethe-Institut
- Gothenburg University Library
- National Library of Finland
- Stockholm University Library
- Theke Solutions

We thank the following individuals who contributed patches to Koha 18.11.00.

- Aleisha Amohia (16)
- Anonymous (3)
- Dimitris Antonakis (1)
- Tomás Cohen Arazi (110)
- Alex Arnaud (14)
- Cori Lynn Arnold (4)
- Zoe Bennett (3)
- Philippe Blouin (4)
- David Bourgault (3)
- Christopher Brannon (1)
- Alex Buckley (5)
- Colin Campbell (4)
- Barry Cannon (1)
- Jérôme Charaoui (1)
- Barton Chittenden (2)
- Nick Clemens (249)
- David Cook (8)
- Charlotte Cordwell (4)
- Chris Cormack (2)
- Jonathan Druart (400)
- Magnus Enger (5)
- Charles Farmer (2)
- Katrin Fischer (78)
- Caitlin Goodger (1)
- Isobel Graham (2)
- Claire Gravely (2)
- Victor Grousset (5)
- Amit Gupta (1)
- David Gustafsson (16)
- Margaret Hade (1)
- Kyle Hall (79)
- Andrew Isherwood (41)
- Mason James (1)
- Lee Jamison (1)
- Srdjan Janković (7)
- Pasi Kallinen (6)
- Vassilis Kanellopoulos (1)
- Olli-Antti Kivilahti (1)
- Jon Knight (1)
- Bernardo Gonzalez Kriegel (5)
- David Kuhn (1)
- Joonas Kylmälä (1)
- Pierre-Luc Lapointe (1)
- Johan Larsson (2)
- Owen Leonard (146)
- Thatcher Leonard (1)
- Ere Maijala (19)
- Alberto Martinez (1)
- Jesse Maseto (1)
- Julian Maurice (24)
- Matthias Meusburger (3)
- Josef Moravec (44)
- Joy Nelson (2)
- Chris Nighswonger (1)
- Dobrica Pavlinusic (1)
- Martin Persson (4)
- Liz Rea (1)
- Martin Renvoize (44)
- Benjamin Rokseth (1)
- Marcel de Rooy (82)
- Caroline Cyr La Rose (6)
- Andreas Roussos (7)
- Jane Sandberg (2)
- Alex Sassmannshausen (2)
- Maryse Simard (2)
- Grace Smyth (1)
- Fridolin Somers (13)
- Lari Taskula (13)
- Mirko Tietgen (9)
- Mark Tompsett (15)
- Koha translators (1)
- Marc Véron (1)
- Jenny Way (1)
- Jesse Weaver (3)
- Baptiste Wojtkowski (2)
- Nazlı Çetin (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.00

- abunchofthings.net (9)
- ACPL (146)
- BibLibre (59)
- BigBallOfWax (1)
- BSZ BW (80)
- bugs.koha-community.org (398)
- ByWater-Solutions (334)
- Catalyst (14)
- Coeur D'Alene Public Library (1)
- Collège de Maisonneuve (1)
- debian.diman (1)
- Deichman Public Library (1)
- Devinim (1)
- Foundations (1)
- Göteborgs Universitet (18)
- Informatics Publishing Ltd (1)
- Interleaf Technology (1)
- jns.fi (13)
- KohaAloha (1)
- kylehall.info (1)
- Libriotech (5)
- Linn-Benton Community College (2)
- Loughborough University (1)
- Marc Véron AG (1)
- Marywood University (1)
- Prosentient Systems (8)
- PTFS-Europe (91)
- Rijks Museum (82)
- rot13.org (1)
- Solutions inLibro inc (15)
- St. Photios Orthodox Theological Seminary (1)
- The City of Joensuu (6)
- The Donohue Group (4)
- Theke Solutions (110)
- unidentified (113)
- Universidad Nacional de Córdoba (5)
- University of Helsinki (20)
- Wellington East Girls' College (1)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (1)
- Sandy Allgood (3)
- Aleisha Amohia (6)
- José Anjos (1)
- Tomás Cohen Arazi (230)
- Alex Arnaud (7)
- Cori Lynn Arnold (5)
- Marjorie Barry-Vila (1)
- Philippe Blouin (1)
- Sonia Bouis (2)
- David Bourgault (1)
- Christopher Brannon (2)
- Claude Brayer (1)
- Alex Buckley (16)
- Colin Campbell (4)
- Barry Cannon (9)
- Axelle Clarisse (8)
- Claudio (1)
- Nick Clemens (1515)
- David Cook (1)
- Chris Cormack (73)
- Stephane Delaye (1)
- Frédéric Demians (1)
- Michal Denar (61)
- Devinim (5)
- John Doe (6)
- Jonathan Druart (325)
- Magnus Enger (9)
- Charles Farmer (15)
- Bouzid Fergani (1)
- Katrin Fischer (406)
- Martha Fuerst (1)
- Brendan Gallagher (18)
- Lucas Gass (1)
- Todd Goatley (1)
- Stephen Graham (6)
- Claire Gravely (43)
- Victor Grousset (6)
- Amit Gupta (2)
- Kyle Hall (69)
- Andrew Isherwood (16)
- Te Rauhina Jackson (2)
- Srdjan Janković (1)
- Dilan Johnpullé (9)
- Pasi Kallinen (6)
- Ulrich Kleiber (1)
- Jon Knight (1)
- Bernardo Gonzalez Kriegel (2)
- Petter von Krogh (1)
- Pierre-Luc Lapointe (11)
- Nicolas Legrand (2)
- Owen Leonard (126)
- Andreas Hedström Mace (1)
- Lauren Macon (1)
- Ere Maijala (19)
- Jesse Maseto (14)
- Julian Maurice (47)
- Matthias Meusburger (1)
- Kathleen Milne (3)
- Josef Moravec (234)
- Joy Nelson (1)
- Chris Nighswonger (1)
- David Nind (11)
- François Pichenot (1)
- Simon Pouchol (1)
- Séverine Queune (95)
- Martin Renvoize (244)
- Benjamin Rokseth (3)
- Marcel de Rooy (221)
- Caroline Cyr La Rose (14)
- Paola Rossi (2)
- Andreas Roussos (10)
- Jane Sandberg (2)
- BWS Sandboxes (1)
- Lisette Scheer (12)
- Maksim Sen (4)
- Margie Sheppard (2)
- Maryse Simard (26)
- Spencer Smith (1)
- Fridolin Somers (2)
- Christian Stelzenmüller (10)
- Myka Kennedy Stephens (1)
- John Sterbenz (1)
- Pierre-Marc Thibault (18)
- Mirko Tietgen (13)
- Mark Tompsett (52)
- Ed Veal (1)
- George Veranis (1)
- Cab Vinton (5)
- Marc Véron (4)
- George Williams (7)

We thank the following individuals who mentored new contributors to the Koha project.

- Owen Leonard
- Martin Renvoize


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Nov 2018 11:44:43.
