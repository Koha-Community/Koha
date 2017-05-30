# RELEASE NOTES FOR KOHA 17.05.00
29 May 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.000.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.00 is a major release, that comes with many new features.

It includes 7 new features, 197 enhancements, 292 bugfixes.



## New features

### Circulation

- [[14610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14610) Add ability to place article requests in Koha

> Add ability to place article requests in Koha.
Article Requests are somewhat similar to holds, but are not requests for an item to check out. Instead, article requests are requests for a photocopy of a particular section of a book ( most often ). This is very common in academic libraries where researchers may request a copy of a
single article found in a journal.
This patch set adds the ability to place article requests in Koha. It allows the control of what can be requested via the circulation rules. Since article requests of electronic resources are not outside the realm of possibility, the feature will check not only the items for requstability, but the record itself as well ( i.e. both items.itype and
biblio.itemtype ).
Article requests can be placed for patrons from the opac and staff intranet and can be viewed in most areas where holds are viewed ( e.g. patron details, record details, etc ).
There is a script to view article requests in progress within the circulation module. Article requests can be Open ( i.e. new ), In Processing, Completed, or Canceled. The status of a given request can be updated from this script.


- [[17453]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17453) Inter-site holds improvement

> Without this feature users could reserve items and choose any library as a pick up location, but there was no mechanism to prevent users from reserving items that were available on the shelf at any given location from reserving the item at the same location, essentially creating a Fetch and Collect scenario.
This had an impact on staff workloads as they had to process reservations and check shelves for items that students could have collected from the open library shelves.
This enhancement decreases the impact on staff workload by
making it possible to prevent users from requesting items for pick up at a library where the item is currently available.



### Installation and upgrade (web-based installer)

- [[17855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17855) New onboarding tool feature to guide users through setting up Koha, and minor web installer UI improvements

> Koha now has a new tool to get Koha users up and running quickly after a new install. The user is prompted to create their first user, library, category code, item type, and circulation rule just after the database install has completed. Getting started with Koha has never been easier.



### Notices

- [[17762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17762) Ability to translate notices

> It's now possible to translate notice templates into different languages. There is a new 'preferred language' setting available in the user account, that controls which template will be used when generating notices.



### OPAC

- [[14224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14224) patron notes about item shown at check in

> This feature adds a "Note" input field to checked out items in the "your summary" section of the patron account in the OPAC. The field allows patrons to write notes about the item, such as "this DVD is scratched", "the binding was torn", etc. The note will be emailed to the library and displayed on check in.



### Patrons

- [[12461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12461) Add patron clubs feature

> This features adds the ability to create clubs which patrons may be enrolled in. It is particularly useful for tracking summer reading programs, book clubs and other such clubs.



### System Administration

- [[18066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18066) Hea - Version 2

> Hea is a service to collect usage data from libraries using Koha.
With this development Hea can collect the geolocations of the libraries in your installation and create a map. A new configuration page allows to configure easily what information is shared with the Koha community.
Hea statistics can been seen on https://hea.koha-community.org/



## Enhancements

### About

- [[15465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15465) README for github
- [[18302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18302) Release team 17.05

### Acquisitions

- [[4969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4969) Vendors can not be deleted / show only active vendors

> This patch provides the functionality to hide inactive vendors from the vendor search.


- [[10978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10978) redirect to basket list of a supplier after deleting a basket

> This patch redirects to the vendor's list of baskets after deleting a basket, fixes breadcrumbs after deletion and also hides the toolbar actions after deletion (seeing as you can't edit/export etc a basket that no longer exists).


- [[15503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15503) Grab Item Information from Order Files

> The goal of this development is to automatically generate items in Koha with populated information based on a 9XX field and subfield, with the new syspref MarcItemFieldsToOrder.


- [[17691]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17691) Add serial subscriptions info on vendor profile page
- [[17771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17771) Add link to bibliographic record on spent/ordered lists in acquisitions
- [[17784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17784) Ability to see funds with an amount of 0.00 when doing a new order
- [[17977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17977) Add acquisitions sidebar menu to suggestions
- [[18109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18109) Uncertain prices has no font awesome icon in acquisitions toolbar

### Authentication

- [[12026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12026) Shibboleth auto-provisioning - Create

> This feature allows it to add new patron records from Shibboleth into Koha ('provision'). It is possible to map Sbibboleth's attributes with Koha fields, the configuration is done in koha-conf.xml. Syncing existing Koha users with Shibboleth is not implemented yet.


- [[17486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17486) Remove 'Mozilla Persona' as an authentication method

> 'Persona' never really took off, and although many browsers currently support it, very few services actually implement it. This has lead its founders, Mozilla, to end the project. On November 30th, 2016, Mozilla closed the persona.org services. Now the feature is deleted from Koha.



### Cataloging

- [[16203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16203) Convert item plugins to new style (see bug 10480)
- [[18388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18388) Standardize serials volume information displaying in OPAC and staff

### Circulation

- [[8548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8548) Add callnumber sort option to overdue report
- [[12063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12063) Change date calculation for reserve expiration to skip all holidays
- [[14146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14146) Add option to add restriction period when checking-in several overdues for same patron
- [[14187]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14187) branchtransfer needs a primary key (id) for DBIx and common sense.
- [[15498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15498) Replace ExportWithCsvProfile with ExportCircHistory
- [[15582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15582) Ability to block auto renewals if the OPACFineNoRenewals amount is reached
- [[15705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15705) Notify the user on auto renewing
- [[16344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16344) Add a circ rule to limit the auto renewals given a specific date
- [[16530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16530) Add a circ sidebar navigation menu
- [[17398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17398) Enhance circulation message UI
- [[17466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17466) Show number of outstanding issues when checking in
- [[17472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17472) Borrower Previously Checked Out: Display title
- [[17560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17560) Hold fee placement at point of checkout
- [[17700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17700) Add columns configuration to fines table
- [[17812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17812) Return focus to barcode field after toggling on-site checkouts
- [[18073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18073) Holds to pull UI improvements
- [[18079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18079) Cleanup of holds to pull page

### Database

- [[15427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15427) Allow db connections using TLS

### Hold requests

- [[14876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14876) Show number of holds per record on the search results
- [[18037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18037) Hold notes template cleanup (from 15545)

### Installation and upgrade (command-line installer)

- [[7533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7533) Add template_cache_dir to the koha-conf.xml file
- [[16083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16083) Accept CLI params for the Makefile.pl

### Label/patron card printing

- [[15815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15815) Improve wording in popup warning when deleting patron from patron-batch
- [[17181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17181) Patron card creator replaces existing image when uploading image with same name

### Lists

- [[7663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7663) batch add barcodes to a list

### MARC Authority data support

- [[9988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9988) Leave larger authority merges to merge_authorities cronjob (pref AuthorityMergeLimit)

> This enhancement replaces dontmerge by a limit. The Zebra code in merge is removed. The cron job has been refactored, and is no longer optional; it also supports merges from one authority type to another (with a table revision).


- [[16018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16018) Merge.pl code cleanup
- [[17233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17233) Add 008 value builder plugin for MARC21 classifications

> This patch adds a 008 cataloguing value builder for MARC21 classifications records (LCC, DDC/Dewey, UDC and so on).
This is a starting point for supporting classification records in Koha.


- [[18070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18070) Support clean removal of authority records

### MARC Bibliographic data support

- [[17800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17800) Add admin sidebar menu to marc-subfields-structure.pl
- [[18200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18200) Fix a potential issue with preceding space in GetMarcUrls

### MARC Bibliographic record staging/import

- [[15541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15541) Prevent normalization during matching/import process

### Notices

- [[13029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13029) Allow to pass additional parameters to SMS::Send drivers
- [[17470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17470) overdue_notices.pl produces X emails with the SAME list of ALL overdue items if a patron has overdue items from X branches

### OPAC

- [[7626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7626) Delete multiple tags at once
- [[13685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13685) Sorting Patron Reading History
- [[13757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13757) Make patron attributes editable in the opac if set to 'editable in OPAC'
- [[14405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14405) Add datatable to fines table in OPAC patron account
- [[14764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14764) Add OPAC News branch selector

> This patch inserts a new system preference: "OpacNewsLibrarySelect". When it is active you can select to see the news of any library on the OPAC start page.


- [[16034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16034) Integration with OverDrive Patron API
- [[17209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17209) Remove use of onclick from masthead
- [[17946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17946) Show number of subscriptions on tab in OPAC record details
- [[17948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17948) Link to make a new list in masthead in OPAC does not take you straight to add form
- [[18108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18108) Sorting by author in opac summary
- [[18304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18304) Do not mail cart or list contents to the library
- [[18350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18350) Moving call number in subscriptions tab in OPAC biblio detail

### Packaging

- [[16733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16733) More flexible paths in debian scripts (for dev installs)

### Patrons

- [[6782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6782) Move auto member cardnumber generation to occur when record is "Saved" (avoid collisions)
- [[17334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17334) members-update.pl should show timestamp
- [[18314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18314) Account lockout

### Reports

- [[14365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14365) SQL Reports Last Edit Date column
- [[17465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17465) Add a System Preference to control number of Saved Reports displayed
- [[17898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17898) Add a way to automatically convert SQL reports

> Bug 17196 moved the column marcxml out of the biblioitems table and into a separate one.
That will break any SQL reports using marcxml, but in order to make it easy to fix them, a new column with a warning has been added to the Saved reports page (/reports/guided_reports.pl?phase=Use saved). There is also an update link that will help to modify the SQL query.


- [[18283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18283) Display improvements on report results - hide code and change wording

### SIP2

- [[16757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16757) Add ability to pay fee by id for SIP2
- [[16895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16895) Allow writeoffs via SIP2

### Searching

- [[8266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8266) remove location from pull down on search
- [[15108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15108) OAI-PMH provider improvements
- [[17169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17169) Add facets for ccode to elasticsearch
- [[17255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17255) Upgrade Elastic Search code to work with version 5.1
- [[18098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18098) Add an index with the count of not onloan items
- [[18394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18394) Add an option to item search to export a barcodes file

### Serials

- [[10357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10357) Send email when serial received subscription link is hard to find
- [[18035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18035) Front-end changes to serials -> Numbering patterns
- [[18181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18181) Can't tell which subscriptions already have routing lists if seeing all subs attached to a biblio

### Staff Client

- [[15179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15179) Marc field 084 does not show on bibliographic record
- [[17516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17516) Add CSV export option to item search *after* displaying output to screen
- [[18110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18110) Adds FR to the syspref AddressFormat

### System Administration

- [[14608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14608) HEA : add possibility of sharing usage statistics in Administration page

> This patch set adds:
- a reference to Hea at the end of the installation process
- a link to the new page from the admin home page
- a new page to easily configure shared statistics


- [[17208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17208) Classification sources and filing rules shouldn't allow 'New' with same code
- [[17793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17793) Make sysprefs search show on all Administration pages
- [[18122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18122) Audio alerts: Add hint on where to enable sounds
- [[18375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18375) Better readability of patron category table for zero ages and fees

### Templates

- [[5784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5784) link to acq from budgets & funds
- [[11932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11932) move delete checkbox on patron modification to right
- [[16072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16072) Include only one small spinner gif in the staff client
- [[16239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16239) Upgrade Bootstrap in the staff client
- [[17014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17014) Remove more event attributes from patron templates
- [[17416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17416) Move javascript in doc-head-close.inc into a separate include
- [[17418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17418) Move staff client home page JavaScript to the footer
- [[17859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17859) Move JavaScript to the footer on about and auth pages
- [[17874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17874) Bug 16239 followup - update bootstrap 3 usage
- [[17942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17942) Update style of the web installer with Bootstrap 3
- [[17972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17972) Reformat acquisitions sidebar menu with acquisitions and administration sections
- [[18063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18063) Remove dead code from tools/manage-marc-import.tt

### Test Suite

- [[17950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17950) Small improvements for Merge.t
- [[18036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18036) Improve test coverage for themelanguage
- [[18182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18182) TestBuilder should be able to return Koha::Object objects
- [[18222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18222) Fix tests broken by Bug 18026
- [[18413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18413) Fix Letters.t (follow-up of 17866)
- [[18448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18448) Fix a few db_dependent tests

### Tools

- [[14854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14854) Add DataTables on upload results table
- [[17669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17669) Add purging temporary uploads to cleanup_database
- [[18040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18040) Updating buttons on Tools->Upload Local Cover Image
- [[18077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18077) Batch item modification link is bold when batch item deletion is active in tools menu
- [[18099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18099) Put call number in its own column on inventory screen
- [[18134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18134) Batch authority record modification Preview MARC button needs updating

### Web services

- [[17317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17317) Adding "bib" type to GetAvailability method for ILSDI


## Critical bugs fixed

(this list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[14541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14541) Tax rate should not be forced to an arbitrary precision
- [[17668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17668) typo in parcel.pl listinct vs listincgst
- [[17692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17692) Can't add library EAN under Plack
- [[18013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18013) acqui/transferorder.pl typo in find method
- [[18115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18115) Fix use of Objects as hashref in acqui/addorderiso2709.pl - Bug 15503 followup
- [[18467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18467) Error calling count on undefined bib in basket.pl if order cancelled and record deleted
- [[18468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18468) When adding from a staged file order discounts are not passed into C4::Acquisitions::populate_order_with_prices
- [[18471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18471) Receiving order with unitprice greater than 1000 processing incorrectly
- [[18482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18482) False duplicates detected on adding a batch from a stage file
- [[18525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18525) Can't create order line from accepted suggestion
- [[18627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18627) Items created via MarcItemFieldsToOrder are not linked to orders

### Architecture, internals, and plumbing

- [[6979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6979) LDAP authentication fails during password comparison

> LDAP USER NOTICE:
The option to integrate LDAP via "auth by password" has been removed. Please update your LDAP integration setting to use "auth by bind" instead.


- [[16758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16758) Caching issues in scripts running in daemon mode
- [[17246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17246) GetPreparedLetter should not allow multiple FK defined in arrayref
- [[17676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17676) Default COLLATE for marc_subfield_structure is not set
- [[17720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17720) CSRF token is not generated correctly
- [[17785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17785) oai.pl returns wrong URLs under Plack
- [[17830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17830) CSRF token is not generated correctly (bis)
- [[17914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17914) The installer process tries to create borrowers.updated_on twice
- [[18242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18242) Move of checkouts to old_issues is not handled correctly
- [[18284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18284) Biblio metadata are not moved to the deleted table when a biblio is deleted
- [[18364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18364) LOCK and UNLOCK are not transaction-safe
- [[18373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18373) `make upgrade` is broken
- [[18457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18457) process_message_queue.pl will die if a patron has no sms_provider_id set but sms via email is enabled for that patron
- [[18647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18647) Internal server error on moremember.pl
- [[18663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18663) Missing db update for ExportRemoveFields

### Authentication

- [[14625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14625) LDAP: mapped ExtendedPatronAttributes cause error when updated on authentication
- [[17615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17615) LDAP Auth: regression causes attribute updates to silently fail and corrupt existing data
- [[17775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17775) Add new user with LDAP not works under Plack
- [[18144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18144) Removal of persona broke Google OAuth2
- [[18442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18442) Permission error when logging into staff interface as db user

### Cataloging

- [[17725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17725) Repeating a field or subfield clones content
- [[17817]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17817) Repeat this Tag (cloning) not working
- [[17922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17922) Default value substitution for month and day should be fixed length
- [[17929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17929) You can't edit indicators in the cataloging screen
- [[18305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18305) jquery.fixFloat.js breaks advanced MARC editor for some browsers
- [[18579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18579) Problem with :Filter::MARC::EmbedItemsAvailability

### Circulation

- [[8361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8361) Issuing rule if no rule is defined

> In the previous versions if no circulation rule was defined, Koha always allowed to check out. Now, with this development, Koha refuses check-out if no rule is found.


- [[16376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16376) Koha::Calendar->is_holiday date truncation creates fatal errors for TZ America/Santiago
- [[16387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16387) Incorrect loan period calculation when using  decreaseLoanHighHolds feature
- [[17709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17709) Article request broken
- [[17919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17919) circ/returns.pl caught in Object Name crossfire
- [[18150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18150) CanItemBeReserved doesn't work with (IndependentBranches AND ! canreservefromotherbranches)
- [[18179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18179) Koha::Objects->find should not be called in list context
- [[18266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18266) Internal Server Error when paying fine for lost item
- [[18372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18372) transits are not created at check in despite user responsing Yes to the prompt
- [[18435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18435) Message about Materials specified does not display when items are checked out and checked in
- [[18438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18438) Check in: Modal about holds hides important check in messages

### Hold requests

- [[17940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17940) Holds not going to waiting state after having been transferred
- [[17941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17941) CanBookBeRenewed is very inefficient/slow
- [[18001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18001) LocalHoldsPriority can cause multiple holds queue lines for same hold request
- [[18015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18015) On shelf holds allowed > "If all unavailable" ignores notforloan
- [[18409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18409) Error when updating pickup library on patron pages

### I18N/L10N

- [[16914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16914) Export csv in item search, exports all items in one line

### Installation and upgrade (command-line installer)

- [[17234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17234) ALTER IGNORE TABLE is invalid in mysql 5.7.  This breaks updatedatabase.pl
- [[17260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17260) updatedatabase.pl fails on invalid entries in ENUM and BOOLEAN columns
- [[17292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17292) Use of DBIx in updatedatabase.pl broke upgrade (from bug 12375)
- [[17986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17986) Perl dependency evaluation incorrect

### Installation and upgrade (web-based installer)

- [[18368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18368) DBversion 17.05.000.022 not set by updatedatabase.pl
- [[18642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18642) Internal Server Error in Guided reports wizard caused by debug messages

### Label/patron card printing

- [[14143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14143) Patron cards: Crash (confusion between table names creator_templates and club_template_enrollment_fields
- [[18044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18044) Label Batches not displaying

### MARC Bibliographic record staging/import

- [[18152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18152) UNIMARC bib records imported with invalid 'a' char in label pos.9

### Notices

- [[18439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18439) Resend button for notices being hidden by CSS and never unhidden

### OPAC

- [[8010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8010) Search history can be added to the wrong patron
- [[17764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17764) OPAC search fails when lost items are in the result set and there is no logged in user
- [[17924]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17924) Fix error in password recovery
- [[18025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18025) Expired password recovery links cause sql crash
- [[18160]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18160) Error when OverDriveCirculation not enabled
- [[18204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18204) Authority searches are not saved in Search history
- [[18275]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18275) opac-memberentry.pl security vulnerabilities
- [[18560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18560) RSS Feed link from OPAC shelves is broken
- [[18573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18573) Error when adding a suggestion in the OPAC

### Patrons

- [[14637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14637) Add patron category fails with MySQL 5.6.26
- [[17344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17344) Can't set guarantor in quick add brief form
- [[17782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17782) Patron updated_on field should be set to current timestamp when borrower is deleted
- [[18461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18461) Internal server error while approving OPAC-edited patron attributes containing umlauts (äöü)

### SIP2

- [[17758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17758) SIP checkin does not handle holds correctly

### Searching

- [[15822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15822) STAFF Advanced search error date utils
- [[16951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16951) Item search sorting not working properly for most columns
- [[17743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17743) Item search: indexes build on MARC do not work in item's search
- [[18005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18005) Pagination of the search result displayed wrong

### Serials

- [[15030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15030) Certain values in serials' items are lost on next edit

### Staff Client

- [[17933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17933) Internal software error when searching patron without birth date

### System Administration

- [[18111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18111) Import default framework is broken
- [[18376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18376) authority framework creation fails under Plack
- [[18662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18662) Can not delete currencies

### Templates

- [[17870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17870) Call to include file incorrectly moved into the footer
- [[18512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18512) GetAuthorisedValues.GetByCode Template plugin should return code (not empty string) if value not found

### Test Suite

- [[17917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17917) t/db_dependent/check_sysprefs.t fails on kohadev strangely

### Tools

- [[12913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12913) Fix wrong inventory results
- [[16295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16295) marc_modification_templates permission doesn't allow access to modify template
- [[18312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18312) Export is broken unless a file is supplied
- [[18329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18329) Batch record deletion broken
- [[18574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18574) Clean Patron Records tool doesn't limit to the selected library

### Web services

- [[17744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17744) OAI: oai_dc has no element named dcCollection

### Z39.50 / SRU / OpenSearch Servers

- [[17871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17871) Can't retrieve facets (or zebra::snippet) from Zebra with YAZ 5.8.1


## Other bugs fixed

(this list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[13835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13835) Popup with searches: results hidden by language menu in footer
- [[14535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14535) Late orders does not show orders with price = 0
- [[16984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16984) Standing orders - when ordering a JS error is raised
- [[17605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17605) EDI should set currency in order record on creation
- [[17872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17872) Fix small error in GetBudgetHierarchy and one of its calls
- [[17899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17899) Show only mine does not work in newordersuggestion.pl
- [[18429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18429) Receiving an item should update the datelastseen

### Cataloging

- [[17512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17512) Improve handling dates in C4::Items
- [[17780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17780) When choose an author in authority results new window shows a blank screen
- [[17988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17988) Select2 prevents correct tag expand/minimize functionality
- [[18119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18119) Bug 17988 broke cataloging javascript functionality
- [[18415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18415) Advanced Editor - Rancor - return focus to editor after successful macro

### Circulation

- [[12972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12972) Transfer slip and transfer message (blue box) can conflict
- [[16202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16202) Rental fees can be generated for fractions of a penny/cent
- [[17309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17309) Renewing and HomeOrHoldingBranch syspref
- [[17395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17395) exporting checkouts in CSV generates a file with wrong extension
- [[17671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17671) Remove unused variables in Reserves.pm
- [[17761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17761) Renewing or returning item via the checkouts table causes lost and damaged statuses to disappear
- [[17781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17781) Improper branchcode set during renewal
- [[17808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17808) When editing circulation conditions, only ask for confirmation when there is already a rule selected
- [[17840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17840) Add classes to internal and public notes in checkouts table
- [[17952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17952) Lost items not skipped by overdue_notices.pl
- [[18219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18219) "Not checked out." problem message displays twice on local use.
- [[18321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18321) One more checkouts possible than allowed by rules
- [[18335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18335) Check in: Make patron info in hold messages obey syspref AddressFormat
- [[18453]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18453) "Export" column is not hidden when ExportCircHistory is off

### Command-line Utilities

- [[18058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18058) 'borrowers-force-messaging-defaults --doit --truncate ' gives DBI error
- [[18502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18502) koha-shell broken on dev installs
- [[18548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18548) running  koha-create --request-db without an instance name should abort

### Course reserves

- [[18264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18264) Course reserves - use itemnumber for editing existing reserve items

### Database

- [[18383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18383) items.onloan schema comment seems to be incorrect.

### Developer documentation

- [[5395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5395) C4::Acquisition::SearchOrder POD inconsistent with function
- [[17935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17935) Adjust some POD lines, fix a few typos
- [[18432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18432) Most code comments assume male gender

### Documentation

- [[14424]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14424) Update Help Files for 3.20
- [[18554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18554) Adjust a few typos including responsability

### Hold requests

- [[11450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11450) Hold Request Confirm Deletion
- [[17749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17749) Missing l in '.pl' in link on waitingreserves.tt
- [[17766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17766) Patron notification does not work with multi item holds
- [[18076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18076) Error when placing a hold and holds per record is set to 999
- [[18534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18534) When IndependentBranches is enabled the pickup location displayed incorrectly on request.pl

### Installation and upgrade (command-line installer)

- [[17880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17880) C4::Installer::PerlModules lexicographical comparison is incorrect
- [[17911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17911) Message and timeout mismatch at the end of the install process

### Installation and upgrade (web-based installer)

- [[12930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12930) Web installer does not show login errors
- [[17190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17190) Mark REST API dependencies as mandatory in PerlDependencies.pm
- [[17469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17469) fr-CA web installer is missing some sample notices
- [[17577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17577) Improve sample notices for article requests
- [[18578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18578) Use subdirectory in /tmp for session storage during installation

### Label/patron card printing

- [[8603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8603) Patron card creator - 'Barcode Type' doesn't stick in layouts
- [[15711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15711) Deleting patroncard images has unexpected behaviour and is broken
- [[17879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17879) Possible to upload images with no image name
- [[18209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18209) Patron's card manage.pl page is not fully translatable
- [[18244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18244) Patron card creator does not take in account fields with underscore (B_address etc.)
- [[18246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18246) Patron card creator: Units not always display properly in layouts
- [[18535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18535) Clicking 'edit printer profile' in label creator causes software error
- [[18611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18611) Create labels action fails in manage-marc-import.pl if an item has been deleted from the import batch.

### Lists

- [[15584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15584) Staff client list errors are incorrectly styled
- [[17852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17852) Multiple URLs (856) in list email are broken

### MARC Authority data support

- [[17909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17909) Add unit tests for authority merge
- [[17913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17913) Merge three authority merge fixes
- [[18014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18014) AddAuthority should respect AUTO_INCREMENT

### MARC Bibliographic data support

- [[4126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4126) bulkmarcimport.pl allows -b and -a to be specified simultaneously
- [[17547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17547) (MARC21) Chronological term link subfield 648$9 not indexed
- [[17788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17788) (MARC21) $9 fields not indexed in authority-linked fields
- [[17799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17799) MARC bibliographic frameworks breadcrumbs broken for Default framework

### Notices

- [[11274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11274) Sent Notices Tab Not Working Correctly
- [[15854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15854) Race condition for sending renewal/check-in notices
- [[16568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16568) Talking Tech generates phone notifications for all overdue actions
- [[17866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17866) Change sender for claim and order notices
- [[17995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17995) HOLDPLACED notice should have access to the reserves table
- [[18478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18478) Some notices sent via SMS gateway fail

### OPAC

- [[4460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4460) Amazon's AssociateID tag not used in links so referred revenue lost
- [[15738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15738) Summary page says item has no fines, but Fines tab says otherwise
- [[16515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16515) Did you mean? links don't wrap on smaller screens
- [[17652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17652) opac-account.pl does not include login branchcode
- [[17696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17696) Two missing periods in opac-suggestions.tt
- [[17823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17823) XSLT: Add label for MARC 583 - Action note
- [[17895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17895) Small typo -'re-set'
- [[17936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17936) Search bar not aligned on right in small screen sizes
- [[17945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17945) Breadcrumbs broken on opac-serial-issues.pl
- [[17947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17947) Searching my library first shows the branchcode by the search bar rather than branchname
- [[17993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17993) Do not use modal authentication with CAS
- [[18307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18307) Branchname is no longer displayed in subscription tab view
- [[18400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18400) Noisy warns in opac-search.pl during itemtype sorting
- [[18466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18466) No article requests breaks the opac-user-views block
- [[18479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18479) Holds 'Placed on' column in opac-user.pl not sorting correctly
- [[18484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18484) opac-advsearch.tt missing closing div tag for .container-fluid
- [[18504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18504) Amount owed on fines tab should be formatted as price if <10 or credit
- [[18505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18505) OPAC Search History page does not respect OpacPublic syspref

### Packaging

- [[16749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16749) Additional fixes for debian scripts
- [[17265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17265) Make koha-create and koha-dump-defaults less greedy
- [[17618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17618) perl-modules Debian package name change
- [[18571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18571) koha-conf.xml should include ES entry

### Patrons

- [[15702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15702) Trim whitespace from patron details upon submission
- [[17891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17891) typo in housebound.tt div tag
- [[18094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18094) Patron search filters are broken by searchable attributes
- [[18263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18263) Make use of syspref 'CurrencyFormat' for Account and Pay fines tables
- [[18370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18370) Columns settings patrons>id=memberresultst : display bug
- [[18423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18423) Add child button not always appearing - problem in template variable
- [[18551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18551) Hide with CSS dynamic elements in member search
- [[18552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18552) Borrower debarments do not show on member detail page
- [[18553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18553) Incorrect "Loading..." tag on  moremember.tt when no clubs defined
- [[18569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18569) Quick add patron will not copy over details from cities and towns pull down into patron details
- [[18596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18596) Quick add form duplicating password confirm
- [[18597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18597) Quick add form does not transfer patron attributes values when switching forms/saving
- [[18598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18598) Quick add form doesn't clear values when switching

### Reports

- [[8306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8306) Patron stats, patron activity : no active doesn't work
- [[17925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17925) Disable debugging in reports/bor_issues_top.pl

### SIP2

- [[12021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12021) SIP2 checkin should alert on transfer and use CT for return branch
- [[17665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17665) SIP2 Item Information Response returns incorrect circulation status of '08' ( waiting on hold shelf ) if record has any holds

### Searching

- [[14699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14699) Intranet search history issues due to DataTables pagination
- [[16115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16115) JavaScript error on item search form unless NOT_LOAN defined
- [[17134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17134) Facet's area shows itemtypes' code instead of item's description
- [[17821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17821) due date in intranet search results should use TT date plugin
- [[17838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17838) Availability limit broken until an item has been checked out
- [[18047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18047) JavaScript error on item search form unless LOC defined
- [[18068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18068) Elasticsearch (ES): Location and (home|holding)branch facets mixed
- [[18189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18189) Elasticsearch sorting broken

### Self checkout

- [[7550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7550) Self checkout: limit display of patron image to logged-in patron
- [[16873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16873) Renewal error message not specific enough on self check.
- [[18405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18405) Self checkout: Fix broken silent printing

### Serials

- [[7728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7728) Fixing subscription endddate inconsistency: should be empty when the subscription is running
- [[14932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14932) serials/serials-collection.pl-page is very slow. GetFullSubscription* checks permission for each serial!
- [[17520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17520) Add serialsUpdate.pl to the list of regular cron jobs
- [[17865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17865) If a subscription has no history end date, it shows as expired today in OPAC
- [[18536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18536) Generating CSV using profile in serials late issues doesn't work as described

### Staff Client

- [[16933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16933) Alt-Y not working on "Please confirm checkout" dialogs
- [[17670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17670) Grammar mistakes - 'effect' vs. 'affect'
- [[18026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18026) URL to database columns link in system preferences is incorrect

### System Administration

- [[13968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13968) Branch email hints are misleading
- [[17346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17346) Enable the check in option in Columns settings
- [[18444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18444) Add TalkingTechItivaPhoneNotification to sysprefs.sql
- [[18600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18600) Missing db update for TalkingTechItivaPhoneNotification

### Templates

- [[15460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15460) Bug 13381 accidentally removed spaces after subfields c and h of 245
- [[17290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17290) Standardize on "Patron categories" when referring to patron category
- [[17790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17790) Fix js error on undefined autocomplete(...).data(...) in js_includes.inc
- [[17916]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17916) "Delete MARC modification template" fails to actually delete it
- [[17982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17982) Fix the use of uniq in sub themelanguage
- [[18419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18419) Broken patron-blank image in viewlog.tt
- [[18452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18452) Should say 'URL' instead of 'url' in catalog detail
- [[18529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18529) Template cleanup of patron clubs pages

### Tools

- [[14399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14399) Fix inventory.pl part two (following 12913)
- [[15415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15415) Warn when creating new printer profile for patron card creator
- [[17777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17777) koha-remove should deal with temporary uploads
- [[17794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17794) Menu items in Tools menu and Admin menu not bold when active but not on linked page
- [[18087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18087) Clarification on File type when using file of biblionumbers to export data
- [[18095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18095) Batch item modification: Better message if no item is modified
- [[18135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18135) Can submit batch deletion for authorities without selecting any
- [[18340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18340) Progress bar length is wrong

### Transaction logs

- [[17708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17708) Renewal log seems empty

### Web services

- [[17778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17778) Make "Earliest Registered Date" in OAI-PMH dynamic
- [[17836]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17836) (ILSDI) 'charges' always '1'
- [[17927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17927) REST API: /holds and /patrons attributes have wrong types

### Z39.50 / SRU / OpenSearch Servers

- [[17487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17487) Improper placement of select/clear all in Z39.50/SRU search dialog

### Test Suite

- [[17714]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17714) Remove itemtype-related t/db_dependent/Members/* warnings
- [[17715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17715) Remove itemtype-related t/db_dependent/Holds/RevertWaitingStatus.t warnings
- [[17716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17716) Remove itemtype-related t/db_dependent/CourseReserves.t warnings
- [[17722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17722) t/db_dependent/PatronLists.t doesn't run inside a transaction
- [[17742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17742) Test t/db_dependent/Patrons.t can fail randomly
- [[17759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17759) Fixing theoretical problems with guarantorid in Members.t
- [[17920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17920) t/db_dependent/Sitemapper.t fails because of permissions
- [[18009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18009) IssueSlip.t test fails if launched between 00:00 and 00:59
- [[18045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18045) Reserves.t can fail because of caching issues
- [[18233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18233) t/db_dependent/00-strict.t has non-existant resetversion.pl
- [[18243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18243) Bug 16034 follow-up: better handling of absence of WebService::ILS::OverDrive::Patron at testing
- [[18420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18420) Some tests fail without patron category 'S'
- [[18460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18460) Remove itemtype-related Serials.t warnings
- [[18494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18494) Fix Letters.t (follow-up of 15702)
- [[18620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18620) t/db_dependent/Letters.t failing on master

### Architecture, internals, and plumbing

- [[17257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17257) Cannot create a patron under MySQL 5.7
- [[17502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17502) Add type check to output_pref and use exceptions
- [[17666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17666) .perl atomic update does not work under kohadevbox
- [[17681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17681) Existing typos might thow some fees when recieved
- [[17713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17713) Members.t is failing randomly
- [[17726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17726) TestBuilder's refactoring removed default values
- [[17731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17731) Remove the noxml option from rebuild_zebra.pl
- [[17733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17733) Members.t is still failing randomly
- [[17814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17814) koha-plack --stop should make sure that Plack really stop
- [[17820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17820) Do not use search->next when find can be used
- [[17931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17931) Remove unused vars from reserves_stats.pl
- [[17960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17960) Rename opac_news.new with opac_news.content

> The database column opac_news.new is renamed to opac_news.content. The notice templates using that placeholder should have been updated automatically (bug 18121).


- [[17992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17992) REST api: Cities controller should not use ->unblessed
- [[18028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18028) install_misc directory is outdated and must be removed
- [[18069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18069) koha-rebuild-zebra still calls rebuild_zebra with -x
- [[18089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18089) All XSLT testing singleBranchMode = 0 fails to show even if install has only 1 branch
- [[18121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18121) Rename opac_news.new with opac_news.content - replace notice template
- [[18136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18136) Content of ExportRemoveFields is not picked to pre-fill field list
- [[18215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18215) Resolve warning on $tls in Database.pm
- [[18395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18395) Wrong article request methods in Koha::Patrons
- [[18443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18443) Get rid of warning 'uninitialized value $user' in C4/Auth.pm
- [[18557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18557) Mysqlim CURRENT_DATE in Koha::Clubs::get_enrollable
- [[18632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18632) CGI::param called in list context flooding erro logs
- [[18664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18664) IssueSlip.t is failing - IssueSlip should return if params are not valid
- [[18669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18669) RewriteCond affecting wrong rule in koha-httpd.conf
- [[13726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13726) Koha::Acquisition::Bookseller should use Koha::Object
- [[14537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14537) Rename system preference 'OverdueNoticeBcc' to 'NoticeBcc'

> The system preference 'OverdueNoticeBcc' is renamed to 'NoticeBcc' as it does not only apply to overdue notices, but to notices in general.


- [[15879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15879) Allow multiple plugin directories to be defined in koha-conf.xml

> It's now possible to define multiple plugin directories
in the Koha conf file. This allows for ease of plugin development so that each plugin installed can live in its own git repository. For compatibility, the first plugindir instance defined is used for uploading plugins via the web interface.


- [[15896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15896) Use Koha::Account::pay internally for makepayment
- [[15897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15897) Use Koha::Account::pay internally for recordpayment_selectaccts
- [[15898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15898) Use Koha::Account::pay internally for makepartialpayment
- [[15905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15905) Remove use of makepayment
- [[15906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15906) Remove use of makepayment in paycollect.pl
- [[15907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15907) Remove use of makepayment in opac/opac-account-pay-paypal-return.pl
- [[15908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15908) Remove use of recordpayment_selectaccts
- [[15909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15909) Remove the use of makepartialpayment
- [[16966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16966) Koha::Patrons - Move GetBorrowersWithIssuesHistoryOlderThan to search_patrons_to_anonymise
- [[17196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17196) Move marcxml out of the biblioitems table

> This development moves marcxml out of the biblioitems and deletedbiblioitems tables and moves it to two new tables: biblio_metadata and deletedbiblio_metadata. SQL queries using the biblioitems table but not the marcxml column will get a performance boost. Storing the marcxml in a specific table will allow us to store several metadata formats (USMARC, MARCXML, MIJ, etc.).
ATTENTION: all reports that use ExtractValue to retrieve MARC tags from biblioitems.marcxml need to be updated/rewritten.


- [[17216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17216) Add a new table to store authorized value categories

> This patch set adds a new table authorised_value_categories to store authori(s|z)ed value categories into a separate table. The problematic is explained on bug 15799 comment 4:
https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15799#c4


- [[17447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17447) Remove unused vars from batchRebuildItemsTables.pl
- [[17461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17461) Make plugins-home.pl complain about plugins that can not be loaded
- [[17501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17501) Koha Objects for uploaded files
- [[17556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17556) Move GetHideLostItemsPreference to Koha::Patron
- [[17557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17557) Move GetAge to Koha::Patron->get_age (and remove SetAge)
- [[17568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17568) Add the Koha::Patron->library method
- [[17569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17569) Move GetUpcomingMembershipExpires to Koha::Patrons
- [[17578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17578) Replace GetMemberDetails with GetMember
- [[17580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17580) Add the Koha::Patron->get_overdues method
- [[17583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17583) Use Koha::Patron->is_expired from circulation.pl
- [[17584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17584) Add the Koha::Patron->checkouts method
- [[17585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17585) Add the Koha::Patron->account method
- [[17586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17586) Add the Koha::Account->balance method
- [[17588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17588) Move GetMemberIssuesAndFines to Koha::Patron
- [[17610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17610) Allow the number of plack workers and max connections to be set in koha-conf.xml
- [[17627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17627) Move C4::Koha::GetItemTypesByCategory to Koha::ItemTypes
- [[17629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17629) Koha::Biblio - Remove ModBiblioframework
- [[17630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17630) Add the Koha::Biblio->holds method
- [[17631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17631) Koha::Biblio - Remove GetHolds
- [[17678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17678) C4::Acquisition - Replace GetIssues with Koha::Checkouts
- [[17679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17679) C4::Circulation - Remove unused GetItemIssues
- [[17689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17689) Add the Koha::Issue->is_overdue method
- [[17736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17736) Move GetReservesFromBiblionumber to Koha::Biblio->holds
- [[17737]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17737) Move GetReservesFromItemnumber to Koha::Item->holds
- [[17740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17740) Add the Koha::Patron->holds method
- [[17741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17741) Use Koha::Patron->holds in Koha::Patron->delete
- [[17755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17755) Introduce Koha::Patron::Attribute::Type(s)
- [[17767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17767) Let Koha::Patron::Modification handle extended attributes
- [[17783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17783) Optimize Koha::IssuingRules->get_effective_issuing_rule
- [[17792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17792) Introduce Koha::Patron::Attribute(s)
- [[17796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17796) Koha::Issues should be moved to Koha::Checkouts
- [[17804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17804) Remove some modules from showdiffmarc.pl
- [[17813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17813) Table borrower_attributes needs a primary key
- [[17824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17824) Remove C4::Members::GetBorrowersWhoHaveNeverBorrowed
- [[17825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17825) Remove C4::Members::AttributeTypes::AttributeTypeExists
- [[17828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17828) Koha::Patron::Attribute->store should raise an exception if unique_id is being broken
- [[17835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17835) Move C4::Koha::GetItemTypes to Koha::ItemTypes
- [[17844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17844) Move C4::Koha::get_notforloan_label_of to Koha::AuthorisedValues
- [[17846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17846) Remove C4::Koha::get_infos_of
- [[17847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17847) Move C4::Koha::GetAuthvalueDropbox to Koha::AuthorisedValues
- [[17894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17894) Remove and Replace WriteOffFee
- [[17932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17932) Koha::Object should provide a TO_JSON method
- [[17958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17958) Add the Koha::Notice::Template[s] packages (letter table)
- [[17959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17959) Add the Koha::Notice::Message[s] packages (message_queue table)
- [[17962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17962) TT syntax for notices - Prove that ACQ_NOTIF_ON_RECEIV is compatible
- [[17963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17963) TT syntax for notices - Prove that AR_* are compatible
- [[17964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17964) TT syntax for notices - Prove that CHECKIN and CHECKOUT are compatible
- [[17968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17968) Remove useless variable in C4::Overdues::parse_overdues_letter
- [[17970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17970) GetPreparedLetter does not warn when expected
- [[17971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17971) TT syntax for notices - Add support for plurals
- [[17973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17973) Add the Koha::Checkout->item method
- [[17974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17974) Add the Koha::Item->biblio method
- [[17990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17990) Code to check perl module versions is buggy
- [[18033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18033) If/else sometimes does not make sense after koha account  system refactoring
- [[18093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18093) Add the Koha::Objects->get_column method
- [[18169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18169) Date like 2999 should not be used arbitrarily
- [[18173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18173) Remove issues.return
- [[18174]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18174) Add the Koha::Object->update method
- [[18208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18208) Add RecordProcessor filter to inject not onloan count to MARC records
- [[18256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18256) Koha::Biblio - Remove GetItemsCount
- [[18258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18258) Add the Koha::Biblio->subscriptions method
- [[18269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18269) Move field mappings related code to Koha::FieldMapping[s]
- [[18270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18270) No need to fetch the MARC record when deleting an item
- [[18274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18274) C4::Items - Remove GetItemStatus
- [[18299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18299) Removal of  admin/env_tz_test.pl script
- [[18300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18300) Delete missing upload records
- [[18332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18332) Add the Koha::Objects->last method
- [[18401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18401) Add the Koha::Checkout->patron method
- [[18402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18402) Add the Koha::Item->checkout method
- [[18427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18427) Add a primary key to serialitems
- [[18459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18459) Add the Koha::Item->biblioitem method


## New sysprefs

- AllowCheckoutNotes
- AuthorityMergeLimit
- AuthorityMergeMode
- CircSidebar
- CumulativeRestrictionPeriods
- ExcludeHolidaysFromMaxPickUpDelay
- ExportCircHistory
- ExportRemoveFields
- FailedLoginAttempts
- LoadSearchHistoryToTheFirstLoggedUser
- MarcItemFieldsToOrder
- NoticeBcc
- NumSavedReports
- OPACFineNoRenewalsBlockAutoRenew
- OPACHoldsIfAvailableAtPickup
- OPACHoldsIfAvailableAtPickupExceptions
- OpacNewsLibrarySelect
- OverDriveCirculation
- RenewalLog
- TalkingTechItivaPhoneNotification
- TranslateNotices
- UploadPurgeTemporaryFilesDays
- UsageStatsGeolocation
- UsageStatsLibrariesInfo
- UsageStatsPublicID

## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook.The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://manual.koha-community.org//en/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)



Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.05.00 is

- Release Manager:
  - [Kyle M Hall](mailto:kyle@bywatersolutions.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
- QA Team:
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@biblibre.com)
  - [Tomas Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Nick Clemens](mailto:nick@bywatersolutions.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
- Continuous Integration Infrastructure Maintainer
  - [Tomas Cohen Arazi](mailto:tomascohen@gmail.com)
- Bug Wranglers:
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Marc Veron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager:
  - [Chris Cormack](mailtochrisc@catalyst.net.nz)
  - [David Nind](mailto:david@davidnind.com))
- Database Documentation Manager:
  - [David Nind](mailto:david@davidnind.com))
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators: 
  - [Brook](mailto:)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 17.05.00:

- ByWater Solutions
- Catalyst IT
- Cheshire Libraries
- Orex Digital
- Region Halland
- Universidad Nacional de Cordoba
- University of the Arts London

We thank the following individuals who contributed patches to Koha 17.05.00.

- Aleisha (1)
- Chloe (1)
- Emma (1)
- LeireDiez (1)
- remi (1)
- pongtawat (2)
- radiuscz (2)
- phette23 (3)
- Blou (6)
- Jacek Ablewicz (2)
- Brendan A Gallagher (3)
- Aleisha Amohia (41)
- Alex Arnaud (13)
- Maxime Beaulieu (2)
- Rebecca Blundell (2)
- Oliver Bock (1)
- Christopher Brannon (3)
- Alex Buckley (9)
- Colin Campbell (2)
- Frédérick Capovilla (1)
- Nick Clemens (61)
- Tomas Cohen Arazi (78)
- David Cook (8)
- Chris Cormack (3)
- Olivier Crouzet (2)
- Stephane Delaune (1)
- Frédéric Demians (3)
- Marcel de Rooy (171)
- Jonathan Druart (375)
- Dani Elder (1)
- Magnus Enger (5)
- Katrin Fischer (4)
- Petter Goksøyr Åsen (1)
- Caitlin Goodger (5)
- David Gustafsson (1)
- Luke Honiss (4)
- Mason James (1)
- Srdjan Jankovic (5)
- Karen Jen (2)
- Dimitris Kamenopoulos (1)
- Chris Kirby (1)
- Olli-Antti Kivilahti (6)
- David Kuhn (1)
- Nicolas Legrand (1)
- Owen Leonard (20)
- Ere Maijala (2)
- Patricio Marrone (2)
- Julian Maurice (16)
- Grace McKenzie (4)
- Tim McMahon (1)
- Matthias Meusburger (5)
- Kyle M Hall (110)
- Josef Moravec (30)
- Joy Nelson (1)
- Chris Nighswonger (1)
- Dobrica Pavlinusic (3)
- Paul Poulain (2)
- Meenakshi R (1)
- Liz Rea (3)
- Martin Renvoize (5)
- Francesco Rivetti (3)
- Benjamin Rokseth (3)
- Alex Sassmannshausen (2)
- Adrien Saurat (1)
- Zoe Schoeler (2)
- Emma Smith (1)
- Fridolin Somers (10)
- Zeno Tajoli (1)
- Lari Taskula (8)
- Lyon3 Team (2)
- Mirko Tietgen (3)
- Mark Tompsett (25)
- Oleg Vasylenko (2)
- Marc VÃ©ron (16)
- Jesse Weaver (4)
- Baptiste Wojtkowski (8)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.00

- abunchofthings.net (3)
- ACPL (20)
- aei.mpg.de (1)
- BibLibre (56)
- biblos.pk.edu.pl (2)
- BSZ BW (4)
- Bulac (1)
- ByWater-Solutions (171)
- Catalyst (23)
- cdalibrary.org (3)
- centrum.cz (2)
- Cineca (1)
- Foundations (1)
- helsinki.fi (2)
- ilsleypubliclibrary.org (1)
- inLibro.com (1)
- jns.fi (13)
- KohaAloha (1)
- kohadevbox (1)
- kylehall.info (5)
- Libeo (1)
- Libriotech (5)
- Marc Veron AG (16)
- Nucsoft OSS Labs (1)
- oha.it (3)
- Oslo Public Library (4)
- Prosentient Systems (8)
- PTFS-Europe (9)
- punsarn.asia (2)
- Rijksmuseum (171)
- rot13.org (3)
- scanbit.net (1)
- Solutions inLibro inc (8)
- student.uef.fi (1)
- Tamil (3)
- Theke Solutions (78)
- ub.gu.se (1)
- unidentified (121)
- Universidad Nacional de Córdoba (2)
- Universite Jean Moulin Lyon 3 (4)
- wegc.school.nz (7)
- wlpl.org (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (1)
- Aleisha Amohia (4)
- Alex Buckley (22)
- Andreas Roussos (1)
- Baptiste Wojtkowski (4)
- Barbara Johnson (1)
- Barton Chittenden (1)
- Benjamin Daeuber (8)
- Benjamin Rokseth (1)
- beroud (1)
- Cab Vinton (3)
- Caitlin Goodger (3)
- Cédric Vita (2)
- Chris Cormack (21)
- Chris Kirby (1)
- Christopher Brannon (6)
- Claire Gravely (22)
- Colin Campbell (2)
- Dani Elder (1)
- David Cook (3)
- David Kuhn (1)
- Dilan Johnpulle (3)
- Dobrica Pavlinusic (2)
- Edie Discher (1)
- Emma Smith (2)
- EricGosselin (1)
- Frédéric Demians (1)
- Grace McKenzie (4)
- Hector Castro (2)
- Hugo Agud (12)
- Jacek Ablewicz (14)
- Jane Leven (1)
- Janet McGowan (8)
- Jan Kissig (1)
- Jenny Schmidt (2)
- Jesse Maseto (4)
- Jesse Weaver (3)
- JMBroust (2)
- Joel Sasse (1)
- Jonathan Druart (451)
- Jonathan Field (13)
- Josef Moravec (195)
- Joy Nelson (2)
- J Schmidt (1)
- Julian Maurice (66)
- Julien Comte (1)
- Karam Qubsi (1)
- Karen Jen (1)
- Katrin Fischer (35)
- Lari Taskula (7)
- Larry Baerveldt (1)
- Laura Slavin (2)
- Lisa Gugliotti (1)
- Liz Rea (4)
- Luke Honiss (1)
- Magnus Enger (6)
- Marci Chen (1)
- Marc Veron (1)
- Marc VÃ©ron (136)
- Marjorie Barry-Vila (1)
- Mark Tompsett (77)
- Martin Renvoize (38)
- Mason James (9)
- Matthias Meusburger (2)
- mehdi (1)
- Mehdi Hamidi (1)
- Mika Smith (1)
- Mirko Tietgen (31)
- Nick Clemens (1)
- Nick Clemens (217)
- Nicolas Legrand (2)
- Oliver Bock (1)
- Olli-Antti Kivilahti (10)
- Owen Leonard (54)
- Paul POULAIN (1)
- Peggy Thrasher (1)
- Philippe (2)
- Radek Å iman (2)
- Rhonda Kuiper (3)
- sbujam (1)
- Séverine Queune (4)
- Sonia Bouis (3)
- Srdjan (7)
- Zeno Tajoli (11)
- Zoe Schoeler (2)
- Katrin Fischer  (3)
- Liz Rea  (1)
- Tomas Cohen Arazi (88)
- Brendan A Gallagher (47)
- Kyle M Hall (1124)
- Bernardo Gonzalez Kriegel (1)
- Andreas Hedström Mace (1)
- Marcel de Rooy (385)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

### Thanks
- Thanks to Brendan and Nick, without whom this release would not be what it is
- To Brendan, who never says no.
- To Nick, who always says yes.

### Special thanks from the Release Manager
I'd like to thank everyone who has contributed time and effort to this release. Many hands make light work!

A special thanks to the ByWater Solutions team. I could not have done this without all of you!
- Brendan Gallagher
- Nathan Curulla
- Joy Nelson
- Melissa Lefebvre
- Jesse Maseto
- Jacqueline Salter
- Barton Chittenden
- Nick Clemens
- Michael Cabus
- Jessie Zairo
- Karen Holt
- Kelly McElligott
- Larry Baerveldt
- Danielle Elder
- Rocio Dressler
- Jessica Beno
- Todd Goatley
- Josh Barron
- Adam Brooks
- Cindy Norman

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.05.x


## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 29 May 2017 23:12:14.
