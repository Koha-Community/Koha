# RELEASE NOTES FOR KOHA 19.05.00
30 May 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.00 is a major release, that comes with many new features.

It includes 15 new features, 246 enhancements, 437 bugfixes.



## New features

### Acquisitions

- [[5770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5770) Email librarian when purchase suggestion made

> Sponsored by Northeast Kansas Library System, NEKLS (http://nekls.org/)  
This new feature adds the ability to send a notice to the library, branch or a specific email address whenever a purchase suggestion is created.


- [[15774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15774) Additional fields for baskets

> This new feature adds the ability to define additional fields to store information about acquisition baskets.  
It refactors and centralises the code used to add fields to subscriptions as well. There is a new 'Additional fields' page in the adminsitration module to configure the fields.  
Users can name additional fields, tie them to authorised values, and specify whether the fields can be searched in the acquisitions module.



### Circulation

- [[20912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20912) Rental fees based on time period

> Sponsored by: Huntsville-Madison County Public Library (http://hmcpl.org/)  
This new feature adds the ability to define a per day (or per hour) rental fee for rental items. The new fee may be used as an alternative to the fixed price rental fee or in conjunction with it.



### OPAC

- [[8995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8995) Show OpenURL links in OPAC search results

> This new feature allows you to link documents in your catalogue to an OpenURL resolver and possibly enable your patrons to get full texts in digital form.



### REST api

- [[13895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13895) Add routes for checkouts retrieval and renewal

> This new feature adds APIs for checkouts and renewals.


- [[16497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16497) Add routes for library retrieval, update and deletion

> This new feature adds APIs to list all or individual libraries, and to add, update or delete a library where appropriate permissions are held.


- [[17006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17006) Add route to change patron's password (authenticated)

> This new feature allows a administrators to change a users password via the API  
Sponsored by Municipal Library Ceska Trebova


- [[19661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19661) Add route for fund retrieval

> This new feature adds a REST API for working with acquisition funds, including listing, adding and deleting funds and fund users.


- [[22061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22061) Add route to change patron's password (public)

> This new feature allows a user to change their own password via the public API


- [[22132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22132) Add Basic authentication to the REST API

> This adds http BASIC authentication as an optional auth method to the RESTful APIs. This greatly aids developers when developing against our APIs.


- [[22206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22206) Add routes to enable suspension or resumption of holds

> This new feature adds a REST API that allows suspending a hold and resuming a suspended hold.



### Searching - Elasticsearch

- [[18235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18235) Elastic search - Configurable facets

> This new feature allows librarians with appropriate permissions to configure (show/hide/re-order) the search facets provided by elasticsearch.



### Self checkout

- [[14407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14407) Limit web-based self-checkout to specific IP addresses

> This new feature allows you to increase the security of your online self checkout facilities by allowing you to limit their operation to a specified IP address or address range.



### Web services

- [[17047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17047) Mana Knowledge Base : Data sharing

> This new feature adds the ability for Koha to talk to a Mana Knowledge Base server, allowing libraries to share a small, but hopefully growing, number sets of data.  
Currently this includes sharing serial subscription patterns and reports.



## Enhancements

### About

- [[21502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21502) Add checks for YAML formatted system preferences to about page

> This enhancement adds a warning to the about pages for any malformed yaml system preferences.


- [[21626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21626) Add 'current maintenance team' to the 'Koha team' page

> We have displayed the team responsible for the development of your installed version of Koha on the about page for some time, however we have not recognised those who are currently helping maintain it. This patch adds the current maintenance team (along with the end date for their tenure) to the about page.



### Acquisitions

- [[4833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4833) Show acquisition information when ordering from a suggestion

> This enhancement adds the following fields to the suggestions selection table when adding a new order by selecting from a suggestion:  
* library  
* fund  
* price  
* quantity  
* total


- [[16939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16939) Making all 'add to basket' actions buttons

> Sponsored by Catalyst IT


> This enhancement improves the consistency within our acquisitions module.


- [[18166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18166) Show internal and vendor notes for received orders

> This enhancement makes internal and vendor notes visible for received orders. Previously these were only shown for pending orders.


- [[18952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18952) Show internal note in acquisitions details tab

> This enhancement makes internal and vendor notes visible in the acquisitions details tab that is displayed for each bibliographic record when the `AcquisitionDetails` system preferences is enabled.


- [[21308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21308) Show the search filters used on the search results page for acquisitions history searches

> This enhancement modifies the orders search results page so that the search form appears in the sidebar.  
This allows the user to view and re-use their search parameters.


- [[21364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21364) Allow closing basket from vendor search/view

> This enhancement adds 'Close basket' to the available actions in the vendor search results view.


- [[22556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22556) Add ability to quickly filter funds/budgets by library on the Acquisitions home page

> This enhancement adds a "Filter by library" pulldown list to the budgets table on the acquisitions home page.


- [[22664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22664) Link basket name and basket group name instead of the, often short, basket numbers

> This enhancement moves the basket link from the basket number to the basket name aiding usability and improving consistency.



### Architecture, internals, and plumbing

- [[18925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18925) Move maxissueqty and maxonsiteissueqty to circulation_rules

> Part of the ongoing effort to improve the maintainability of our codebase.


- [[19302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19302) Pass objects to IsAvailableForItemLevelRequest

> Part of the ongoing effort to improve the maintainability of our codebase.


- [[21002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21002) Add Koha::Account::add_debit

> Sponsored by PTFS Europe


> Part of the ongoing effort to improve the maintainability of our codebase.  
This enhancement adds the `add_debit` method to Koha::Account as a parallel to the existing `add_credit` method.  This method should be used from now on for any code dealing with the addition of debts to a patrons account.


- [[21206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21206) C4::Items - Remove GetItem

> Part of the ongoing effort to improve the maintainability of our codebase.  
This enhamcement removes the `GetItem` method from C4::Items and replaces any existing occurrences with `Koha::Items->search()`.


- [[21547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21547) Use set_password in opac-passwd and remove sub goodkey

> Part of the ongoing effort to improve the maintainability of our codebase.


- [[21720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21720) Update C4::Circulation::AddIssuingCharge to use Koha::Account->add_debit

> Sponsored by PTFS Europe

- [[21721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21721) Update C4::Circulation::AddRenewal to use Koha::Account->add_debit

> Sponsored by PTFS Europe

- [[21722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21722) Update C4::Accounts::chargelostitem to use Koha::Account->add_debit

> Sponsored by PTFS Europe

- [[21727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21727) Add Koha::Account::Line->adjust

> Sponsored by PTFS Europe

- [[21728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21728) Update C4::Reserves::ChargeReserveFee to use Koha::Account->add_debit
- [[21747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21747) Update C4::Overdues::UpdateFine to use Koha::Account->add_debit and Koha::Account::Line->adjust
- [[21756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21756) Deprecate C4::Accounts::manualinvoice (use Koha::Account->add_debit instead)
- [[21757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21757) Patron detail script (moremember.pl) cleanup

> This enhancement tidies up the patron detail script (moremember.pl) and removes unused templates, uses objects as much as possible, and removes many template parameters.


- [[21875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21875) Handling subject line in Letters.pm

> This enhancement improves the display of subject lines in messages so that they correctly show non-Latin characters.


- [[21890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21890) Allow forgotten password functionality to be limited by patron category

> Libraries can now specify which patrons are allowed to change their password through the Forgotten Password functionality in the OPAC, per patron category. A common use case for this would be a system that combines LDAP (or other external authentication) patrons and local Koha patrons. This feature will allow libraries to present a better user experience for password management to all of their patrons, no matter how they are authenticated.


- [[21896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21896) Add Koha::Account::reconcile_balance

> Adds a business logic level routine for reconciling user account balances.


- [[21912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21912) Koha::Objects->search lacks tests
- [[21980]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21980) Add some new Exceptions for Koha::Account methods

> Sponsored by PTFS Europe

- [[21992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21992) Remove Koha::Patron::update_password
- [[21993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21993) Be userfriendly when the CSRF token is wrong
- [[21998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21998) Add pattern parameter in Koha::Token

> Preparatory patch for GDPR enhancements that may be forthcoming.


- [[21999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21999) C4::Circulation::AddIssue uses DBIx::Class directly
- [[22003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22003) Remove unused subroutines displaylog and GetLogStatus from in C4::Log
- [[22026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22026) Remove `use  Modern::Perl` from Koha::REST::classes
- [[22031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22031) C4::Auth->haspermission should allow checking for more than one subpermission
- [[22047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22047) set_password should have a 'skip_validation' param
- [[22048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22048) Use set_password instead of update_password in the codebase
- [[22049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22049) MarkIssueReturned should rely on returndate only
- [[22051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22051) Make Koha::Object->store translate 'Incorrect <type> value' exceptions
- [[22127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22127) Update dateaccessioned value builder
- [[22144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22144) Add method metadata() to Koha::Biblio
- [[22194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22194) Add Koha::Exceptions::Metadata
- [[22311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22311) Add a SysPref to allow adding content to the #moresearches div in the opac
- [[22363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22363) Move C4::Logs::GetLogs to Koha namespace
- [[22454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22454) Add Koha::Item::hidden_in_opac method
- [[22455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22455) Add Koha::Biblio::hidden_in_opac method
- [[22511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22511) Koha::Account::Line->void loses the original type of the credit
- [[22512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22512) accountlines.accountype mixes 'state' and 'type'
- [[22516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22516) accountlines.lastincrement can be removed
- [[22518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22518) accounttype 'O' is still referred to but is never set
- [[22521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22521) Convert fines handling to use 'status' instead of two accounttypes

> This patch clarifies the intended purpose of the various accounttypes used for fines calculations in the accounttline table.  
WARNING: You will need to update your reports to account for the introduced use of 'status' in accountlines for fines.  
"accounttype = 'FU'" needs changing to "accounttype = 'FINE' AND status = 'UNRETURNED'"  
"accounttype = 'F'" needs changing to "accounttype = 'FINE' AND status != 'UNRETURNED'"


- [[22532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22532) Remove "random" from Z39.50
- [[22564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22564) accounttype 'Rep' is still referred to but is never set
- [[22694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22694) Add a method for checking OpacHiddenItems exceptions in Koha::Patron::Category
- [[22696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22696) Simplify visibility logic in opac-ISBDdetail.pl
- [[22700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22700) Make biblio_metadata prefetchable from Koha::Biblio
- [[22701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22701) Make items prefetchable from Koha::Biblio
- [[22757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22757) Use YAML CodeMirror higlighting on YAML preferences
- [[22765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22765) Add class beside loggedinusername to indicate if logged in user is a superlibrarian

### Cataloging

- [[15496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15496) Delete bibliographic record after moving last item to another record(s)

> When transferring items from one record to another you are now presented with a button to delete the original host record if there are no more items remaining.


- [[20128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20128) Permission for advanced editor

> Adds a new permission, under the "cataloguing" module, that controls whether the advanced (direct text editor based) cataloging editor is available.


- [[21411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21411) Advanced cataloging editor - rancor - Allow configuration of Keyboard shortcuts

> This enhancement lets you globally redefine the keyboard shortcuts used in rancor.


- [[21826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21826) Automatic authority record generation improvements

> Sponsored by National Library of Finland


> This enhancement makes improvements to automatic authority record generation, including using only allowable subfields when creating authorities from bibliographic records.


- [[22045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22045) Cataloging UX enhancement - Improve access to tabs

> This enhancement makes style changes to the standard MARC editor with the goal of making it more responsive and easier to navigate among tabs and tags.  
Tabs are now part of the page toolbar, which floats as the page scrolls. In addition to the numbered tabs, there is also a section showing in-page links to the MARC tags which are available on that page.


- [[22525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22525) Navigation arrows on the bottom of Cataloging search pages

> This enhancement adds pagination links to the bottom of the cataloging search result page. Before this there were only pagination links at the top of the page.



### Circulation

- [[7088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7088) Cannot renew items on hold even with override

> Sponsored by Halton Borough Council


> Sponsored by Cheshire Libraries Shared Services


> Sponsored by Sefton Council


> This enhancement enables items that are on hold to be renewed with a due date specified by the user. It is enabled by the new "AllowRenewalOnHoldOverride" system preference.  
It can appear in two locations:  
1. In the "Checkouts" table on the Patron Details screen. It is now possible to select on loan items that would otherwise fulfil a hold request to be renewed. When such an item is selected, an additional date selection box is displayed to allow the user to specify the due date for all on hold items that are to be renewed.  
2. In the Circulation > Renew alert screen. When a barcode of an on loan item that would ordinarily fulfil a hold request is entered, the usual alert is displayed indicating that the item is on hold, it is still possible to override this, and renew, however it is now also possible to specify a due date.


- [[10300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10300) Allow transferring of items to be have separate IndependentBranches syspref

> This enhancement allows libraries to transfer items between themselves when they have IndependentBranches enabled.  
It adds a new system preference IndependentBranchesTransfers. Setting this to 'No' allows staff to transfer items, setting this to 'Yes' disables it.


- [[14576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14576) Allow automatic update of location on checkin

> Sponsored by Catalyst IT
> Sponsored by Arcadia Public Library (http://library.ci.arcadia.ca.us/)
> Sponsored by Middletown Township Public Library (http://www.mtpl.org/)
> Sponsored by Round Rock Public Library (https://www.roundrocktexas.gov/departments/library/)


> This enhancement adds a new system preference "UpdateItemLocationOnCheckin" which accepts pairs of shelving locations. On check in the item's location is compared to the location on the left and, if it matches, is updated to the location on the left.  
This preference replaces the ReturnToShelvingCart and InProcessingToShelvingCart preferences. Note that existing functionality for all items in the PROC location being returned to permanent_location is preserved by default. Also, any items issued from the CART location will be returned to their permanent location on check out (if it differs).  
Special values for this system preference are:  
_ALL_ - used on left side only to affect all items, and overrides all other rules  
_BLANK_ - used on either side to match on or set to blank (actual blanks will work, but this is an easier to read option)  
_PERM_ - used on right side only to return items to their permanent location  
Syntax highlighting is used in the text area to make it easier to read.


- [[17171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17171) Add a syspref to allow currently issued items to be issued to a new patron without staff confirmation

> Some libraries don't want to force librarians to manually confirm each checkout when an item is checked out to another patron. Instead, they would prefer to be alerted afterwards.  
This enhancement allows this behavior using a new system preference "AutoReturnCheckedOutItems".
> Sponsored by Round Rock Public Library (https://www.roundrocktexas.gov/departments/library/)


- [[17353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17353) Add phone number column to checkout search

> This enhancement adds patrons phone numbers to the checkout search results. It is hidden by default and is displayed by configuring the columns for circulation tables (Administration >  Additional parameters > Configure columns > Circulation > table_borrowers > untick the phone column).


- [[18816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18816) Make CataloguingLog work in production by preventing circulation from spamming the log

> This enhancement stops unnecessary logging of every check in and check out actions when the CataloguingLog system preference is enabled. This has previously prevented CataloguingLog being used in production.


- [[19066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19066) Add branchcode to accountlines

> This enhancements adds recording of the branch an account transaction was performed.  
For payments it will be the signed in branch when payment is collected.  
For manual invoices/credits it is the signed in branch when the line is created.


- [[20450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20450) Add collection to list of items when placing hold on specific copy
- [[21754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21754) If an item is marked as lost, any outstanding transfers upon it should be automatically cancelled

> Sponsored by Brimbank Library, Australia


> If an item is marked as lost, then any pending transfers the item had will now be removed.


- [[22761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22761) Move "Fee receipt" from template to a slip

> This enhancement allows the 'Fee receipt' to be configurable by the library in the Tools->Notices and slips page


- [[22809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22809) Move "INVOICE" from template to a slip

> This enhancement allows the 'Invoice' slip to be configurable by the library in the Tools->Notices and slips page



### Command-line Utilities

- [[18562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18562) Add koha-sip script to handle SIP servers for instances

> To ease multi-tenant sites maintenance, several handy scripts were introduced. For handling SIP servers, 3 scripts were introduced: koha-start-sip, koha-stop-sip and koha-enable-sip.  
This patch introduces a new script, koha-sip, that unifies those actions regarding SIP servers on a per instance base, through the use of option switches.


- [[20436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20436) Add ability to specify itemtypes for longoverdue.pl

> This enhancement increases the granularity of the long overdue cronjob, allowing the library to exclude some itemtypes from the process, and/or define different parameters for a specific itemtype.


- [[20485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20485) Don't account for items timestamps when combining "dont_export_items=1" and "date" in misc/export_records.pl

> Sponsored by Gothenburg University Library


> This enhancement changes the way dates are used to calculate records for export. If not including items in the export, we only consider the date of last biblio record edit, rather than including records where only the items were edited in the date range.


- [[22238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22238) Remove koha-*-sip scripts in favor of koha-sip

> The new koha-sip maintenance script replaces the old koha-start-sip, koha-stop-sip and koha-enable-sip scripts. This patch removes them, while keeping backwards compatibility (i.e. you can still run them until you get used to the new syntax).


- [[22580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22580) Remove deprecated delete_expired_opac_registrations.pl cronjob

> The functionality of delete_expired_opac_registrations.pl was moved into the cleanup_database.pl cronjob. Please make sure to adjust your conjob configuration accordingly.



### Course reserves

- [[21446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21446) Improve display of changed values on course reserves and show permanent location instead of cart

### Database

- [[21753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21753) issuingrules.chargename is unused and should be removed
- [[22008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22008) accountlines.manager_id is missing a foreign key constraint
- [[22155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22155) biblio_metadata.marcflavour should be renamed 'schema'
- [[22368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22368) Table suggestions lacks foreign key constraints

### Documentation

- [[8701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8701) Help for OpacHiddenItems pref should not point to text in install directory

### Fines and fees

- [[11373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11373) Add "change calculation" feature to the fine payment forms

> This enhancement adds an option to specify how much money was collected when paying a fine, as well as defining how much was paid on the fine. If these numbers are different (i.e. more money was collected) a popup displaying the amount of change to be given will be displayed and require confirmation before proceeding


- [[19489]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19489) Detailed description of charges on Accounting tab
- [[21578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21578) 'Pay fines' tab incorrectly describes the purpose

> This enhancement renames the tabs on a patrons account related to fines/payments -   
The 'Fines' tab is now 'Accounting'  
on the Accounting page  
'Account' is now 'Transactions'  
'Pay fines' is now 'Make a payment'


- [[21683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21683) Remove accountlines.accountno
- [[21844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21844) Add callnumber to fines descriptions
- [[21918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21918) Clean up pay fines template
- [[22148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22148) Cancelling some payments/writeoffs redirects to unexpected page
- [[22674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22674) Change wording of payments in the GUI

### Hold requests

- [[19469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19469) Add ability to split view of holds view on record by pickup library and/or itemtype

> This enhancement adds the ability to visually separate the holds list on a record by library and/or itemtype.  
This can make it a bit clearer who is in line next for a hold at each branch or if user has specified a specific type.  
The system preference HoldsSplitQueue and HoldsSplitQueueNumbering control this behaviour. When activated holds can only be adjusted using the arrows, the dropdown priority menu is disabled.


- [[19630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19630) "Hold is suspended" message appears in barcode field in holds table

> Sponsored by Catalyst IT

- [[19770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19770) Add cardnumber to holds awaiting pickup screen and add classes to borrower info
- [[20421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20421) Apply CheckPrevCheckout logic when placing a hold on the staff client

> This enhancement will now warn staff when placing a hold on an item that a borrower has previously checked out. Will only be displayed if CheckPrevCheckout system preference is enabled.


- [[21070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21070) request.pl details links to biblio instead of moredetail.pl for that item
- [[22372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22372) Add shelving location to Holds awaiting pickup report
- [[22631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22631) Make links on barcode on hold summary page consistent (bug 21070)

### I18N/L10N

- [[11375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11375) Improve patrons permissions display
- [[21789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21789) Example usage of I18N Template::Toolkit plugin

### ILL

- [[18589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18589) Show ILLs as part of patron profile
- [[18837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18837) Add an unmediated Interlibrary Loans workflow
- [[20563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20563) ILL request list gives no indication of source and/or target
- [[20581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20581) Allow manual selection of custom ILL request statuses
- [[20600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20600) Provide the ability for users to filter ILL requests
- [[20639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20639) Allow setting a default/single backend for OPAC driven requests
- [[20640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20640) Allow migrating a request between backends
- [[20750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20750) Allow timestamped auditing of ILL request events
- [[21063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21063) Allow columns in intranet ILL request datatable to be customisable

### Installation and upgrade (web-based installer)

- [[20000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20000) use Modern::Perl in installer perl scripts

> Sponsored by Catalyst IT


> Code cleanup which improves the readability, and therefore reliability, of Koha.



### Lists

- [[12759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12759) Add ability to pass list contents to batch record modification/deletion tools

> Sponsored by Catalyst IT


> This enhancement add batch modification/deletion options to user created lists of records



### MARC Bibliographic data support

- [[21899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21899) Update MARC21 frameworks to Update 27 (November 2018)

### MARC Bibliographic record staging/import

- [[19164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19164) Allow MARC modification templates to be used in staged MARC imports

> This enhancement allows applying MARC modification templates to batches of records during the import/staging process from the staff client



### Notices

- [[8000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8000) Test mode for notices

> This enhancement adds a system preference 'SendAllEmailsTo' which, when populated with a valid email address, will redirect all outgoing mail from Koha to this address. This feature is intended for use during testing/setup of Koha, to prevent spamming users.


- [[16149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16149) Generate and send custom notices based on report output

> This enhancement adds a cronjob which takes a report id, and a notice code to be used to send custom emails to users generated from the report content.  
The notices will be able to use any (and only) columns included in the report in the notice templates. User email addresses can be specified in the report, as well as the 'From' address for the email.  
Notices for this cronjob must be defined using Template Toolkit syntax.


- [[20478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20478) Advance notices: send separate digest messages per branch

> This enhancement add the `--digest-per-branch` option to advanced_notices.pl to allow notices to be grouped by branch rather than grouped by borrower if so required.


- [[21241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21241) Set suggestion notices message_transport_type to sms if syspref is enabled and patron has an smsalertnumber but no email address

> If the FallbackToSMSIfNoEmail syspref is enabled then when a borrower has no email address but does have a smsalertnumber then suggestion notice message_transport_type is set to sms.



### OPAC

- [[11969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11969) Show patrons star rating on their reading history
- [[12318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12318) Show subscription shelving location on subscription tabs
- [[14272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14272) Allow OPAC to show a single news entry

> Sponsored by Catalyst IT


> Allows to display OPAC news entries on their own page. The news entry will remain accessible by direct URL even after the entry itself has expired.


- [[14385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14385) Extend OpacHiddenItems to allow specifying exempt borrower categories

> This enhancement allows for specifying specific borrower categories in the preference OpacHiddenItemsExceptions who, when signed in to the opac, will be able to see items hidden by the OpacHiddenItems system preference.  
This is intended to allow staff/privileged users to view records that the general public cannot.


- [[21399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21399) Sort patron fines in OPAC by date descending as a default
- [[21533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21533) Do not allow password recovery for administrative locked patrons (see 21336)
- [[21850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21850) Remove search request from page title of OPAC result list
- [[21871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21871) Show authority 856 links in the OPAC
- [[22029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22029) Remove Google+ from social links on OPAC detail

> Google revealed that Google Plus accounts will be shut down on April 2, 2019.


- [[22102]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22102) Markup fixes for OPAC article request page
- [[22568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22568) Replace RSS icon in the OPAC with Font Awesome
- [[22576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22576) OPAC password change text changes
- [[22588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22588) Simplify getting account information in opac and self checkout module
- [[22638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22638) Self checkin CSS update
- [[22645]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22645) Add 'ISSN' option to OPAC's basic search
- [[22657]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22657) Remove JavaScript from OPAC suggestion validation of required fields
- [[22803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22803) Set dataTable width issue

### Patrons

- [[3766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3766) Cities/Towns only on one address

> This enhancement allows for using the City/Town dropdown for all patron addresses, not only the main address.


- [[10796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10796) Allow password changes for logged in OPAC users by patron category

> Libraries can now specify which patrons are allowed to change their password when logged into the OPAC, per patron category. A common use case for this would be a system that combines LDAP (or other external authentication) patrons and local Koha patrons. This feature will allow libraries to present a better user experience for password management to all of their patrons, no matter how they are authenticated.


- [[17854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17854) New Print slip and close button next to Close button

> Adds a 'Printer' button next to the 'X' (clear) button when viewing a patron record - this allows the librarian to print a slip for the patron and clear their account form the screen to prevent viewing of information by another user or patron.


- [[21312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21312) Show lockout on Patrons form

> This enhancement adds a notification for staff when an account is locked by password attempts or administratively.


- [[21336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21336) GDPR: Handle unsubscribe requests automatically by optional (administrative) lock, anonymize and remove

> Add preferences UnsubscribeReflectionDelay, PatronAnonymizeDelay and PatronRemovalDelay.  
Add db column borrowers.flgAnonymized.  
Add Koha::Patron->lock for administrative lockout.  
Add Koha::Patron->anonymize for scrambling patron data.  
Actions are controlled by preferences and run by cleanup_database cron job.


- [[22198]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22198) Add granular permission setting for Mana KB
- [[22505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22505) Add column configuration to patron list table
- [[22594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22594) Validate SMS messaging numbers using the E.164 format

> Adds validation to the SMS number field that conforms to international standards and adds a hint: "SMS number should be in the format 1234567890 or +11234567890" on both the OPAC and Intranet.



### REST api

- [[20006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20006) Adapt /v1/holds to new naming guidelines
- [[22227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22227) Make GET /cities staff only

### Reports

- [[8775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8775) Add collection column to built in  'Items lost' report
- [[22856]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22856) Show SQL code button should trigger CodeMirror view

### SIP2

- [[19619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19619) Add support for SIP2 field CM ( Hold Pickup Date ) to Koha
- [[22014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22014) Add ability to send "00" in SIP CV field on checkin success

> Sponsored by Pueblo City-County Library District

- [[22016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22016) Always send CT field for SIP checkin, even if empty

> Sponsored by Pueblo City-County Library District


### Searching

- [[14457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14457) Integrate LIBRIS spellchecking
- [[22418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22418) Authority link magnifying glass icon doesn't appear for 655 subject tags
- [[22424]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22424) Add search by all lost statuses to item search
- [[22649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22649) Add item type to item search results

### Searching - Elasticsearch

- [[18213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18213) Add language facets to Elasticsearch
- [[21872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21872) Elasticsearch indexing faster by making it multi-threaded

### Self checkout

- [[18251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18251) SCO alerts - need a trigger for successful checkouts

> This enhancement adds new triggers to ease defining custom sounds/alerts for the self checkout module


- [[19458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19458) Self-check module highlighting

> This enhancement highlights new checkouts/renewals in the self-check display to make it easier to see which actions have been performed in the user's session


- [[21772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21772) Add holds and account information tab to the SCO module

> Sponsored by City of Portsmouth Public Library

- [[22538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22538) Add a noticeable alert about waiting holds

> Sponsored by Theke Solutions


### Serials

- [[22408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22408) Subscription entry form cleanup

### Staff Client

- [[12283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12283) Set autocomplete=off for patron search input
- [[21582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21582) Use CodeMirror for *UserJS & *UserCSS

> This enhancement adds javascript syntax highlighting to aid users when editing the JS system preferences.


- [[22616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22616) Update error text messages

### System Administration

- [[3820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3820) More detailed patron record changes log

> This enhancement will add a log of the specific fields that were changed when modifying/editing a patron, including the before and after values for each updated field.


- [[22053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22053) Ability to disable some plugins

> The ability to enable/disable plugins is added. This is particularly handy when testing new plugins or when plugins are not (yet) fully configured for production use.


- [[22190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22190) Add column configuration to patron category administration
- [[22191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22191) Add column configuration to libraries administration

### Templates

- [[10659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10659) Upgrade jQuery star ratings plugin
- [[15911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15911) Use noEnterSubmit CSS class instead of prevent_submit.js
- [[20569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20569) Improve description of CheckPrevCheckout system preference

> A simple string patch that clarifies the intention of the CheckPrevCheckout system preference options.


- [[20729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20729) Update style of datepickers
- [[20809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20809) Link patron image to patron image add/edit form
- [[21034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21034) Re-indent circulation.tt
- [[21091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21091) Move add item template JavaScript to a separate file
- [[21304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21304) Update two-column templates with Bootstrap grid: Catalog
- [[21307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21307) Switch two-column templates to Bootstrap grid: Cataloging
- [[21436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21436) Switch two-column templates to Bootstrap grid: Tools part 4
- [[21438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21438) Switch two-column templates to Bootstrap grid: Patron card creator
- [[21442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21442) Switch two-column templates to Bootstrap grid: Circulation part 1
- [[21449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21449) Switch two-column templates to Bootstrap grid: Circulation part 2
- [[21569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21569) Switch two-column templates to Bootstrap grid: Circulation part 3
- [[21573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21573) Move lists barcode and biblionumber entry form to modal
- [[21646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21646) Clean up Overdrive template
- [[21672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21672) Switch templates to Bootstrap grid: Various
- [[21693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21693) Clean up checkout notes template
- [[21695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21695) Clean up access files template
- [[21783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21783) Reindent admin/columns_settings.tt
- [[21784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21784) Clean up js_includes.inc
- [[21785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21785) Add column configuration to hold ratios report
- [[21790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21790) Switch error page template to Bootstrap grid
- [[21792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21792) Switch two-column templates to Bootstrap grid: Serials part 3
- [[21795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21795) Switch two-column templates to Bootstrap grid: Notices and slips
- [[21797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21797) Update two-column templates with Bootstrap grid: Acquisitions part 5
- [[21803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21803) Redesign authorized values interface
- [[21870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21870) Convert browser alerts to modals: OPAC user summary
- [[21891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21891) Remove non-XSLT detail view in the staff client
- [[21913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21913) Clean up payment details page
- [[21942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21942) Clean up cataloging merge template
- [[21943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21943) Clean up holds template
- [[21945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21945) Clean up stock rotation template
- [[21948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21948) Clean up style of item detail page
- [[21963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21963) Switch two-column templates to Bootstrap grid: Patrons part 1
- [[21964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21964) Switch two-column templates to Bootstrap grid: Patrons part 2
- [[21965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21965) Switch two-column templates to Bootstrap grid: Patrons part 3
- [[22015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22015) Move DataTables CSS to global include
- [[22023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22023) Further improve responsive layout handling of staff client menu bar
- [[22032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22032) Improve local cover image tab on detail page
- [[22035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22035) Improve local cover image browser page
- [[22104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22104) Clean up patron API keys template
- [[22134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22134) Add account expiration information to patron details
- [[22195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22195) Change default DataTables configuration to consolidate buttons
- [[22196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22196) Clean up Mana KB administration template
- [[22261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22261) Revise style of DataTables menus
- [[22337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22337) Make it clearer that language preferences can be re-ordered
- [[22584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22584) Add YAML support for Codemirror
- [[22656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22656) Report charts broken after bug 22023
- [[22695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22695) Remove non-XSLT search results view from the staff client
- [[22697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22697) Reindent catalogue/result.tt
- [[22734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22734) Fund not marked as mandatory when ordering from a staged file
- [[22751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22751) Switch two-column templates to Bootstrap grid: Patron details
- [[22764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22764) More YUI grid cleanup
- [[22811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22811) Add button to clear DataTables filtering

### Test Suite

- [[21798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21798) We need t::lib::TestBuilder::build_sample_biblio
- [[21817]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21817) Mock userenv should be a t::lib::Mocks method
- [[21971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21971) TestBuilder::build_sample_item
- [[22349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22349) Overzealous deletion of data in t/db_dependant/Koha/Acquisitions/Booksellers.t
- [[22392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22392) TestBuilder::build_sample_item should allow defining barcode

### Tools

- [[18661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18661) Make "Replace only included patron attributes" default on patron import

> On the 'import patrons' page, the "Replace all patron attributes" is automatically selected which is the more dangerous option. This patch sets the default selection as "Replace only included patron attributes" as it is a safer option.


- [[19417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19417) Improve display of errors from background job during stage for import
- [[19722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19722) Add a MaxItemsToDisplayForBatchMod preference

> When batch editing large amounts of items, displaying all of the info could lead to a timeout while waiting for page load. This enhancement adds the ability to define a MaxItemsToDisplayForBatchMod system preference which will hide the list of individual items and allow libraries to edit larger batches without hitting a timeout.


- [[21216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21216) Notices - Add filter/search options to table
- [[22175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22175) Make stock rotation table sortable
- [[22318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22318) Extend Koha news feature to include other content areas

> This enhancement begins work to move system preferences that include displayed text to the 'News' module - this allows the user to define text in various languages and add ability for these preferences to show correctly in translated OPACs.  
Specifically, this patch set moves the 'OPACNavRight' preference into the 'News' module.



### Web services

- [[19380]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19380) Add transfer informations in ILS-DI GetRecords response
- [[19945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19945) ILSDI - Return the reason a reserve is impossible



## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[18723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18723) Dot not recognized as decimal separator on receive
- [[18736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18736) Problems in order calculations (rounding errors)

> This patch introduces to new system preference to govern how rounding is applied to values in acquisitions. It defaults to the american practice of rounding to the nearest 'cent' but future options should become available as we start to understand how other nations round for accounting purposes.


- [[20830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20830) Make sure a fund is selected when ordering from staged file
- [[21605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21605) Cannot create EDI account
- [[21989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21989) JS error in "Add orders from MARC file" - addorderiso2709.pl
- [[22282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22282) Internal software error when exporting basket group as PDF
- [[22293]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22293) Sticky toolbar making vendor form uneditable
- [[22296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22296) Invoice adjustments are not populating to budget views
- [[22390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22390) When duplicating existing order lines new items are not created
- [[22498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22498) Can not select any funds for invoice adjustments
- [[22565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22565) Partially receiving order and adding internal note on invoice updates note on every order on the system
- [[22611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22611) Typo introduced into Koha::EDI by bug 15685
- [[22669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22669) Cannot edit received item in acquisitions with acqcreateitem set to "when placing an order"
- [[22713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22713) Replacement price removed when receiving if using MarcItemFieldstoOrder
- [[22802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22802) When ordering from a staged file, if funds are populated per item order level fund should not be required
- [[22905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22905) Cannot update the status of suggestions if the branchcode filter is set to all
- [[22908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22908) Modsuggestion will generate a notice even if the modification failed

### Architecture, internals, and plumbing

- [[21610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21610) Koha::Object->store needs to handle incorrect values
- [[21910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21910) Koha::Library::Groups->get_search_groups should return the groups, not the children
- [[21955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21955) Cache::Memory should not be used as L2 cache

> Cache::Memory fails to work correctly under a plack environment as the cache cannot be shared between processes.


- [[22052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22052) DeleteExpiredOpacRegistrations should skip bad borrowers
- [[22388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22388) svc/split_callnumbers should have execute flag set
- [[22478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22478) Cross-site scripting vulnerability in paginations
- [[22483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22483) haspermissions previously supported passing 'undef' for $flagsrequired
- [[22600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22600) We should add an 'interface' field to accountlines
- [[22618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22618) Tests in t/Acquisition.t are actually context dependent
- [[22723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22723) Syntax error on confess call in Koha/MetadataRecord/Authority.pm
- [[22893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22893) contributors.yaml not correctly copied

### Authentication

- [[21973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21973) CAS URL escaped twice, preventing login
- [[22461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22461) Regression in #20287: LDAP user replication broken with mapped extended patron attributes
- [[22692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22692) Logging in via cardnumber circumvents account logout
- [[22717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22717) Google OAuth auto registration error

### Cataloging

- [[16232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16232) Edit as new (duplicate) doesn't work correctly with Rancor

> Sponsored by Carnegie-Stout Public Library

- [[16251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16251) Material type is not correctly set for Rancor 008 widget
- [[21049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21049) Rancor 007 field does not retain value
- [[21986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21986) Quotation marks are wrongly escaped in several places
- [[22140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22140) More use of EasyAnalyticalRecords pref
- [[22288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22288) Barcode file does not work in modifying items in batch

### Circulation

- [[18805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18805) Currently it is impossible to apply credits against debits in patron accounts

> This patch adds an `Apply Credits` button to the accounts interface to allow a librarian to apply outstanding credits against outstanding debits.


- [[21065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21065) Data in account_offsets and accountlines is deleted with the patron leaving gaps in financial reports
- [[21346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21346) Clean up dialogs in returns.pl
- [[21491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21491) When 'Default lost item fee refund on return policy' is unset it says no but acts as if 'yes'
- [[21915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21915) Add a way to automatically reconcile balance for patrons

> Sponsored by ByWater Solutions


> In the past, if a patron had any credit existing on their account (newly added, or pre-existing), if debts were present then the credit balance would always be immediately applied to the debt.  This functionality was inadvertently removed during refactoring efforts which debuted in 16.11.  
This patch adds code to restore the functionality and allows it to be optionally applied to the system via a new system preference, `AccountAutoReconcile`.  
Note: The new preference defaults to the post 16.11 behaviour, if you wish to restore the 16.11 functionality then you will need to update the preference after the upgrade.


- [[21928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21928) CircAutoPrintQuickSlip 'clear' is not working
- [[22020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22020) Configure Columns for Patron Issues checkin hides renewal
- [[22679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22679) circulation_rules are not deleted when accompanying issuingrules are deleted
- [[22759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22759) Circulation rules for maxissueqty are applied per branch even for defaults
- [[22896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22896) Item to be transferred at checkin clears overridden due date

### Command-line Utilities

- [[22396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22396) koha-sip script does not start the server correctly
- [[22593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22593) Cronjobs/Scripts dealing with accountlines need updating for bug 22008

### Course reserves

- [[22652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22652) Editing Course reserves is broken
- [[22899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22899) Cannot view course details

### Database

- [[13515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13515) Table messages is missing FK constraints and is never cleaned up
- [[21931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21931) Upgrade from 3.22 fails when running updatedatabase.pl script
- [[22476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22476) MarkLostItemsAsReturned has wrong defaults for new installs
- [[22642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22642) DB upgrade 18.06.00.005 can fail

### Fines and fees

- [[22301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22301) Paying fines is broken when using CurrencyFormat = FR
- [[22533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22533) Cannot create manual invoices
- [[22724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22724) Staff without writeoff permissions have access to 'Write off selected' button on Pay Fines tab

> Sponsored by Catalyst IT


### Hold requests

- [[17978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17978) Include 'Next available'/title level holds in holds count when placing holds (opac and staff)

> This patch set corrects the count of hold a user has to correctly enforce limits on the number of open holds being placed.


- [[21495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21495) Regression in hold override functionality
- [[21608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21608) Arranging holds priority with dropdowns is faulty when there are waiting/intransit holds
- [[22330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22330) Transfer limits should be respected for placing holds in staff interface and APIs
- [[22753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22753) Move hold to top button doesn't work if waiting holds exist

### I18N/L10N

- [[21895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21895) Translations fail on upgrade to 18.11.00 (package installation)

### Installation and upgrade (web-based installer)

- [[22024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22024) Update translated web installer files with new class splitting rules
- [[22489]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22489) Onboarding tool fails due to inserting maxissueqty into IssuingRule

### Label/patron card printing

- [[22275]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22275) 18.06.00.060 DB update fails (incomplete/incorrect defaults)
- [[22429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22429) Infinite loop in patron card printing

### MARC Authority data support

- [[21962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21962) The `searching entire record` option in authority searches is currently failing

### Notices

- [[22139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22139) Fields of ACCTDETAILS not working properly

### OPAC

- [[11853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11853) Cannot clear date of birth via OPAC patron update
- [[21589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21589) Series link formed from 830 field is incorrect
- [[21911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21911) Scoping OPACs by branch does not work with new library groups
- [[21950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21950) Searching with 'accents' breaks on navigating to the second page of results
- [[22030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22030) OverDrive requires configuration for field passed as username
- [[22085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22085) UNIMARC default XSLT broken by Bug 14716
- [[22360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22360) On order information missing in OPAC normal display
- [[22370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22370) OPAC users should not be allowed to view staff news items

> Sponsored by Catalyst IT

- [[22420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22420) Tag cloud feature broken
- [[22559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22559) OPAC Forgotten password functionality not working
- [[22735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22735) Broken MARC and ISBD views
- [[22881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22881) Trying to clear search history via the navbar X doesn't clear any searches

### Patrons

- [[21778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21778) Sorting is inconsistent on patron search based on permissions
- [[22253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22253) Koha throws an exception when updating a borrower with an insecure password
- [[22386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22386) Importing using attributes as matchpoint broken
- [[22715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22715) Searching for patrons with "" in the circulation note hangs patron search
- [[22928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22928) "Update child to adult patron" link no longer displayed

### REST api

- [[22071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22071) authenticate_api_request does not stash koha.user in the OAuth use case

### Reports

- [[18393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18393) Statistics wizard for acquisitions not filtering correctly by collection code
- [[21560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21560) Optimize ODS exports
- [[21984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21984) Unable to load second page of results for reports with reused parameters
- [[21991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21991) Displaying more rows on report results does not work for reports with parameters
- [[22357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22357) Every run of runreport.pl with --store-results creates a new row in saved reports

### Searching

- [[22442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22442) Item search CSV export broken

### Searching - Elasticsearch

- [[19575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19575) Use canonical field names and resolve aliased fields

> Sponsored by Gothenburg University Library


> This patchset makes some changes to Elasticsearch mappings in the database. The changes alter existing indices and are intended to fix issues with the current mappings, however, if you have done customization of mappings you may want to back them up before upgrading.


- [[20261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20261) No result in some page in authority search opac and pro (ES)
- [[20535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20535) ModZebra called with $record with items stripped in ModBiblioMarc
- [[21974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21974) cxn_pool must be configurable
- [[22705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22705) Change default value of Elasticsearch cxn_pool to 'Static'

### Self checkout

- [[22641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22641) Incorrect filter on SCO printslip
- [[22675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22675) SCO broken on invalid barcodes

### Serials

- [[22621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22621) Filters on subscription result list search the wrong column
- [[22812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22812) Cannot add new subscription with strict SQL modes turned on

### Staff Client

- [[21405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21405) Pagination in authorities search broken for Zebra and broken for 10000+ results in ES
- [[22553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22553) Unchecking a subpermission does not uncheck the top level permission

### System Administration

- [[22389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22389) Classification splitting sources regex - cannot consistentlyadd/delete
- [[22619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22619) Adding a new circ rule with unlimited checkouts is broken
- [[22847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22847) Specific circ rule by patron category is displaying the default (or not displaying)

### Templates

- [[13692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13692) Series link is only using 800a instead of 800t
- [[21813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21813) In-page JavaScript causes error on patron entry page
- [[22904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22904) Untranslatable strings in members-menu.js
- [[22974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22974) Patron password update validation broken

### Test Suite

- [[21956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21956) Sysprefs not reset by regressions.t
- [[22836]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22836) Tests catching XSS vulnerabilities in pagination are not correct

### Web services

- [[21738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21738) [ILS-DI] Error placing a hold on a title without item
- [[21832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21832) Restore is_expired in ILS-DI GetPatronInfo service
- [[22222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22222) Mana subscription search always returns all results
- [[22237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22237) Subscriptions are not linked to Mana upon edit
- [[22849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22849) Data shared without agreement
- [[22891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22891) ILS-DI: RenewLoan explodes in error


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[21441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21441) System information gives reference to a non-existant table
- [[21662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21662) Missing developers from history

### Acquisitions

- [[6730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6730) Rename 'basket' filter to 'basket name' on receive page
- [[14850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14850) Funds from inactive budgets appear in 'Funds' dropdown on acqui/invoice.pl
- [[20782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20782) EDI: Clicking the 'Invoice' link on the 'EDI Messages' page does not take you directly to the corresponding invoice
- [[20865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20865) Remove space before : on order receive filters
- [[21089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21089) Overlapping elements in ordering information on acqui/supplier.pl
- [[21427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21427) Format prices on ordered/spent lists
- [[21659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21659) Link to basket groups from order receive page are broken
- [[21929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21929) Typo in orderreceive.tt
- [[21966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21966) Fix descriptions of acquisition permissions to be more clear (again)
- [[22110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22110) Editing adjustments doesn't work for Currencyformat != US
- [[22171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22171) Format shipping cost on invoice.pl with with 2 decimals
- [[22225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22225) Tax hints and prices on orderreceive.pl may not match
- [[22444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22444) currencies_manage permission doesn't provide link to manage currencies when selected alone
- [[22541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22541) Invoice adjustments: show invoice number and include link on ordered.pl and spent.pl
- [[22762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22762) Collection codes not displayed on receiving
- [[22791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22791) Calculation differs on aqui-home/spent and ordered.pl
- [[22907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22907) Cannot add new suggestion with strict SQL modes turned on

### Architecture, internals, and plumbing

- [[7862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7862) Warns when creating a new notice

> Sponsored by Catalyst IT

- [[10577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10577) C4::Budgets::GetBudgetPeriod has inappropriate overloading of its behavior

> Part of the ongoing effort to improve the maintainability of our codebase.


- [[12159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12159) Duplicate borrower_add_additional_fields function
- [[13795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13795) Delete unused columns from statistics table
- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[19816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19816) output_pref must implement 'dateonly' for dateformat => rfc3339
- [[19920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19920) changepassword is exported from C4::Members but has been removed
- [[21036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21036) Fix a bunch of older warnings
- [[21170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21170) Warnings in MARCdetail.pl - isn't numeric in numeric eq (==)
- [[21172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21172) Warning in addbiblio.pl - Argument "01e" isn't numeric in numeric ne (!=)
- [[21478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21478) Koha::Hold->suspend_hold allows suspending in transit holds
- [[21622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21622) Incorrect GROUP BY clause in acqui/ scripts
- [[21759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21759) Avoid manually setting amountoutstanding in _FixAccountForLostAndReturned

> This patch results in a proper offset always being recorded for auditing purposes when a user is refunded after returning a previously lost item.


- [[21788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21788) C4::Circulation::ProcessOfflinePayment should pass library_id to ->pay
- [[21848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21848) Resolve unac_string warning from Circulation.t
- [[21905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21905) Plugin hook intranet_catalog_biblio_enhancements_toolbar_button incorrectly filtered
- [[21907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21907) Error from mainpage when Article requests enabled and either IndependentBranches or IndependentBranchesPatronModifications is enabled
- [[21909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21909) Koha::Account::outstanding_* methods should preserve call context
- [[21969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21969) Koha::Account->outstanding_* should look for debits/credits by checking 'amount'
- [[21987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21987) Local cover 'thumbnail' size is bigger than 'imagefile' size in biblioimages table
- [[22006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22006) Koha::Account::Line->item should return undef if no item linked
- [[22007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22007) KohaDates output does not need to be html filtered
- [[22033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22033) related_resultset is a hole in the Koha::Object logic
- [[22044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22044) NoRenewalBeforePrecision should be set by default for new installations
- [[22046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22046) Simplify C4::Matcher->get_matches
- [[22056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22056) Remove test/search.pl

> Sponsored by Catalyst IT

- [[22059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22059) Wrong exception parameters in Koha::Patron->set_password
- [[22084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22084) Plugin upgrade method and database plugin version storage will never be triggered for existing installs
- [[22097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22097) CataloguingLog should be suppressed for item branch transfers
- [[22124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22124) Update cataloguing plugin system to not generate type parameter in script tag
- [[22125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22125) branches.pickup_location should be flagged as boolean
- [[22219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22219) C4::Biblio->GetItemsForInventory can return wrong count / duplicated items when skipping waiting holds
- [[22391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22391) Incorrect GROUP BY in /acqui/ajax-getauthvaluedropbox.pl
- [[22451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22451) Asset plugin is using the version from the DB
- [[22472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22472) Should column_exists explode if the table does not exist?
- [[22542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22542) Back browser should not allow to see other patrons details (see bug 5371)
- [[22607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22607) Default value in issues.renewals should be '0' not null
- [[22729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22729) flgAnonymized shouldn't be NULL and should be renamed anonymized
- [[22748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22748) Wrong permission check in addbiblio.pl
- [[22749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22749) Koha::Item->hidden_in_opac should consider hidelostitems syspref
- [[22755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22755) Import Koha::Script to patron_emailer cronjob
- [[22813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22813) searchResults queries the Koha::Patron object inside two nested loops

### Cataloging

- [[10345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10345) Copy number should be incremented when adding multiple items at once
- [[20491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20491) Use "Date due" in table header of item table
- [[21709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21709) Addbiblio shows clickable tag editor icons which do nothing
- [[21937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21937) Syspref autoBarcode annual doesn't increment properly barcode in some cases
- [[22122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22122) Make sequence of Z39.50 search options match in acq and cataloguing
- [[22242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22242) Javascript error in value builder cased by Select2
- [[22886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22886) Missing space between fields from Keyword to MARC mapping in cataloguing search

### Circulation

- [[13763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13763) Renew feature does not check for the BarcodeInputFilter option

> Sponsored by Catalyst IT

- [[14591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14591) book drop / drop box mode incorrectly decrements accrued overdue fines
- [[17236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17236) Add minute and hours to last checked out item display for hourly loans
- [[17347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17347) 'Renew' tab should ignore whitespace at begining and end of barcode
- [[18957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18957) Item renewed online does not show the time of renewal
- [[21013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21013) Missing itemtype for checkut makes patron summary print explode
- [[21030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21030) Date widget on suspend modal not working correctly
- [[21877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21877) Show authorized value description for withdrawn in checkout
- [[22054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22054) Display a nicer error message when trying to renew an on-site checkout from renew page
- [[22083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22083) Typo in circulation_batch_checkouts.tt
- [[22111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22111) Correctly format fines when placing holds (maxoutstanding warning)
- [[22119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22119) Add price formatting in circulation
- [[22120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22120) Add price formatting to patron summary print
- [[22130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22130) Batch checkout: authorized value description is never shown with notforloan status
- [[22200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22200) Forgiving a fine (FOR) does not create a FORGIVEN credit line
- [[22203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22203) Holds modal no longer links to patron
- [[22351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22351) SCSS conversion broke style on last checked out information
- [[22536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22536) Display problem in Holds to Pull report

### Command-line Utilities

- [[12488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12488) Make bulkmarcimport.pl -d use DELETE instead of TRUNCATE
- [[17746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17746) koha-reset-passwd should use Koha::Patron->set_password
- [[20537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20537) Warnings in overdue_notices.pl

> Sponsored by Catalyst IT

- [[20692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20692) koha-plack doesn't check for Include *-plack.conf line in /etc/apache2/sites-available/$INSTANCE.conf
- [[21855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21855) Remove deprecated delete_unverified_opac_registrations.pl cronjob

> The functionality of delete_unverified_opac_registrations.pl was moved into the cleanup_database.pl cronjob. Please make sure to adjust your conjob configuration accordingly.


- [[21908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21908) biblio_metadata is missing from the rebuild_zebra.pl tables list
- [[21975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21975) Unnecessary substitutions in automatic item modification by age
- [[22235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22235) Make maintenance scripts use koha-sip instead of koha-*-sip
- [[22299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22299) Typo in parameter of import_patrons.pl: preserve_extended_atributes

> The --preserve-extended-atributes parameter for import_patrons.pl had a typo within it.  In this version we have fixed the typo and so the attribute name has been updated to --preserve-extended-attributes


- [[22323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22323) Cronjob runreport.pl has a CSV encoding issue
- [[22397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22397) Wrong message in koha-sip --start
- [[22875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22875) Documentation misleading for import_patrons command line script

### Course reserves

- [[21003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21003) Don't show warning when editing a reserve item

### Database

- [[22634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22634) Standardize table creation for stockrotation* tables in kohacstructure.sql
- [[22782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22782) Schema change for SocialData

### Developer documentation

- [[20544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20544) Wrong comment in database documentation for items.itemnotes
- [[21290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21290) POD of ModItem mentions MARC for items

### Documentation

- [[19747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19747) No help page linked for article requests
- [[22174]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22174) Add link to help page for API key management
- [[22687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22687) Typo in Koha::Manual breaks Portuguese links

### Fines and fees

- [[12166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12166) Improve display of hold charges in patron account
- [[21849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21849) Offsets not stored correctly in _FixOverduesOnReturn
- [[22066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22066) branchcode should be recorded for manual credits
- [[22138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22138) members/paycollect.pl has not been updated to have the new tab names
- [[22626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22626) 'Filter paid transactions' broken on Transactions tab in staff
- [[22628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22628) FFOR and VOID show up as codes to end users in OPAC, SCO and staff

### Hold requests

- [[7614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7614) Use branch transfer limits for determining available opac holds pickup locations
- [[15505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15505) Mark Hold Items 'On hold' instead of 'Available'

> Corrects the display of status for items on hold in the OPAC.


- [[20837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20837) CanItemBeReserved should follow ReservesControlBranch and not CircControl

> WARNING: This patch corrects the behaviour of reserve rules such that they match the system preference descriptions. This may initial lead to confusion as prior to this the CircControl branches were used incorrectly. Settings for ReservesControlBranch and CircControl should be reviewed to ensure proper behaviour is enforced.


- [[21263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21263) Pickup library not set correctly when using Default holds policy by item type
- [[21765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21765) AutoUnsuspendReserves manually sets holds fields instead of calling ->resume
- [[22650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22650) Can place multiple item level holds on a single item
- [[22688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22688) TT plugin for pickup locations code wrong

### Holidays

- [[21885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21885) Improve date selection on calendar for selecting the end date on a range

### I18N/L10N

- [[19497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19497) Translatability: Get rid of "Edit [% field.name |html %] field"

> Sponsored by Catalyst IT

- [[21736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21736) Localization widget messages are not translatable

### ILL

- [[21460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21460) Filtering ILL requests on borrowernumber does not work
- [[22101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22101) ILL requests missing in menu on advanced search page
- [[22121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22121) Display 'Price paid' on ILL requests according to CurrencyFormat pref
- [[22464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22464) Copyright notice does not pass forward request properties

### Installation and upgrade (command-line installer)

- [[17496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17496) install-CPAN.pl documentation/removal
- [[20174]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20174) Remove xml_sax.pl target from Makefile.pl

### Installation and upgrade (web-based installer)

- [[11922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11922) Add SHOW_BCODE patron attribute for Norwegian web installer
- [[21545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21545) Update German web Installer for 18.11
- [[21651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21651) Force insert of notices related tables during the install process
- [[21710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21710) Fix typo atributes in some installer files
- [[22095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22095) Dead link in web installer
- [[22527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22527) Web installer links to wrong database manual when database user doesn't have required privileges

> Sponsored by Hypernova Oy


### Label/patron card printing

- [[22878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22878) Cannot add a patron card layout with mysql strict mode on

### Lists

- [[20891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20891) Lists in staff don't load when \ was used in the description
- [[21751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21751) fixFloat toolbar not displaying properly in Chrome

### MARC Authority data support

- [[19994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19994) use Modern::Perl in Authorities perl scripts
- [[21450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21450) link_bibs_to_authorities.pl is caching searches without the auth type
- [[21880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21880) "Relationship information" disappears when accessing paginated results in authority searches
- [[21957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21957) LinkBibHeadingsToAuthorities can be called twice when running link_bibs_to_authorities

### MARC Bibliographic data support

- [[19648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19648) Repeated positions and some options missing in cataloguing plugin 007 (XML file)
- [[22034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22034) Viewing record with Default framework doesn't work on MARC tab

### Notices

- [[14358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14358) Changing the module refreshes the page and resets library choice
- [[20937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20937) PrintNoticesMaxLines is not effective for overdue notices with a print type specified where a patron has an email
- [[21571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21571) Translate notices fail on ACCTDETAILS
- [[21829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21829) Date displays as a datetime in notices
- [[22002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22002) Each message_transport_type in the letters table is showing as a separate notice in Tools > Notices and slips

### OPAC

- [[403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=403) Reserve process allows duplicate reserves
- [[10676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10676) OpacHiddenItems not working for restricted on OPAC detail
- [[13629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13629) SingleBranchMode removes both library and availability search from advanced search
- [[13782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13782) RSS for news needs a bit of styling
- [[19241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19241) Items with status of hold show as available in cart
- [[21192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21192) Borrower Fields on OPAC's Personal Details Screen Use Self Register Field Options Incorrectly
- [[21335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21335) Remove redundant includes of right-to-left.css
- [[21808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21808) Field 711 is not handled correctly in showAuthor XSLT for relator term or code
- [[21846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21846) Using emoji as tags doesn't discriminate between emoji when calculating weights or searching

> Please note, this patch fixes issues going forward. It includes a maintenance script to allow you to fix any possible existing cases. Please see bugzilla for details.


- [[21947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21947) Filtering order generates html in notes
- [[22058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22058) OPAC holdings table shows &nbsp; instead of blank
- [[22075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22075) Encoding problem with RIS export
- [[22118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22118) Format hold fee when placing holds in OPAC
- [[22207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22207) Course reserves page does not have unique body id
- [[22432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22432) Star ratings plugin replacement missing from a couple pages
- [[22501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22501) OPAC course reserves notes should allow html links
- [[22537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22537) Don't show Suspend all holds button when holds can no longer be susppended in OPAC
- [[22550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22550) OPAC suggestion form doesn't require mandatory fields
- [[22551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22551) Stray "//" appears at bottom of opac-detail.tt
- [[22560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22560) Forgotten password "token expired" page still shows boxes to reset password
- [[22561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22561) Forgotten password requirements hint doesn't list all rules for new passwords
- [[22620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22620) OPAC description for collection in opac-reserve.tt
- [[22624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22624) Show OPAC description for authorised values in OPAC
- [[22680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22680) OPAC language footer not positioned correctly
- [[22743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22743) OverDrive results page is missing overdrive-login include
- [[22772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22772) Menu link hover color incorrect in OPAC language choosers
- [[22816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22816) OPAC detail holdings table doesn't fill it's container

### Packaging

- [[21897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21897) Typo in postinst affecting zebra configuration file installation

### Patrons

- [[375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=375) When placing a reserve, item claims to have one reserve already
- [[19818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19818) Add id into tag html from moremember.tt
- [[20165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20165) Capitalization: Street Address should be Street address in patron search options
- [[20514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20514) Searching for a patrons using the address option doesn't work with streetnumber
- [[21535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21535) Anonymize function in Patron should not scramble email addresses
- [[21930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21930) Typo in the manage_circ_rules_from_any_libraries description
- [[21953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21953) Term "Lost item" is untranslatable
- [[22067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22067) Koha::Patron->can_see_patron_infos should return if no patron is passed
- [[22149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22149) Grammar fix in the manage_circ_rules_from_any_libraries description
- [[22646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22646) Fix use of PrivacyPolicyURL
- [[22781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22781) Fields on patron search results should be html/json filtered

### REST api

- [[21786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21786) Routes for credits should include library_id
- [[22216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22216) Make GET /patrons/{patron_id} staff only

### Reports

- [[447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=447) Bookcount page has a holder gif that needs to be commented out
- [[20274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20274) itemtypes.plugin report: not handling item-level_itypes syspref
- [[20679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20679) Remove 'rows per page' from reports print layout
- [[22082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22082) Ambiguous column in patron stats
- [[22090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22090) Cash register report missing data in CSV export
- [[22147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22147) Hide 'Batch modify' button when printing reports
- [[22168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22168) Improve styling of new chart settings for reports
- [[22278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22278) Newly created report group is not selected after saving an SQL report
- [[22287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22287) Correct new charts CSS

### SIP2

- [[15221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15221) SIP server always sets the alert flag when item not returned
- [[19832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19832) SIP checkout removes extra hold on same biblio
- [[21997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21997) SIP patron information requests can lock patron out of account
- [[22043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22043) SIP Checkin Response alert flag set to often set to Y incorrectly
- [[22076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22076) SIP checkin for withdrawn item returns ok in checkin response
- [[22790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22790) The system preference itemBarcodeInputFilter is not applied for barcodes inputed via SIP2

### Searching

- [[12441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12441) search.pl has incorrect reference to OPACdefaultSortField and OPACdefaultSortOrder

> Sponsored by Catalyst IT

- [[14716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14716) Correctly URI-encode URLs in XSLT result lists and detail pages
- [[18909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18909) Enable the maximum zebra records size to be specified per instance
- [[20823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20823) UNIMARC XSLT does not display 604$t
- [[22010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22010) RecordedBooks and OverDrive should check preferences over passing variables
- [[22154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22154) Subtype search for Format - Braille doesn't look for the right codes
- [[22595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22595) Items search is mixing inputs
- [[22596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22596) html TT filter is breaking items search with custom field
- [[22787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22787) Mapping missing for ů to u in word-phrase-utf-chr
- [[22901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22901) On item search authorised values select disappears on conditional change

### Searching - Elasticsearch

- [[19670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19670) search_marc_map.marc_field should have COLLATE= utf8mb4_bin
- [[21084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21084) Searching for authorities with 'contains' gives no results if search terms include punctuation
- [[22228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22228) Elasticsearch - standalone colons should be escaped when performing a search
- [[22246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22246) Elasticsearch indexing needs a maximum length for `__sort` fields
- [[22295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22295) Elasticsearch - Advanced search should group terms entered in a single input
- [[22339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22339) Elasticsearch - fixed field mappings should match MARC ranges
- [[22413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22413) Elasticsearch - Search settings are lost after sorting, faceting or paging
- [[22474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22474) Authority and biblio field mapping improperly shared
- [[22495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22495) Restore su-geo field in Elasticsearch mappings
- [[22892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22892) Warning when reindexing without parameters

### Searching - Zebra

- [[22073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22073) Diacritics Ž and ž not being mapped for searching (Non-ICU)

### Self checkout

- [[18387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18387) 404 errors on page causes SCO user to be logged out
- [[22274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22274) Self-checkout pages not covered by OPAC CSS changes
- [[22378]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22378) Fix sound alerts on SCO
- [[22739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22739) Self check in module JS breaks if  SelfCheckInTimeout  is unset

### Serials

- [[13735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13735) Item form in serials module doesn't respect max length set in the frameworks
- [[15149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15149) Serials: Test prediction pattern does not consider Subscription start and end date
- [[16231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16231) Correct permission handling in subscription edit menu
- [[21845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21845) Sort of issues in OPAC subscription table
- [[22156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22156) Subscription result list sorts on "checkbox" by default
- [[22239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22239) JavaScript error on subscription detail page when there are no orders
- [[22404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22404) Some labels in subscription add form has wrong parameter "for"
- [[22934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22934) Add missing use statement to Koha::AdditionalFieldValue

### Staff Client

- [[17698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17698) Make patron notes show up on staff dashboard

> RMNOTE - REMOVE FROM RELEASE NOTES - 18.11 FEATURE


- [[19046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19046) IntranetCatalogSearchPulldown doesn't retain last selection
- [[21802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21802) Edit notices form is not aligned with accordeon headers
- [[21904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21904) Patron search library dropdown should be limited  by group if "Hide patron info" is enabled for group
- [[22419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22419) Removing multiple records from intranet cart causes browser timeout
- [[22914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22914) Add holds column to batch item delete to fix show/hide columns behaviour

### System Administration

- [[7403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7403) Remove warning from CataloguingLog system preference
- [[15110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15110) Improve decreaseHighHolds system preference description
- [[18011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18011) Enrollment period date on patron category can be set in the past without any error/warning messages
- [[18143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18143) Silence floody MARC framework export
- [[21637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21637) Capitalization: EasyAnalyticalRecords syspref option "Don't Display" should be "Don't display"
- [[21926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21926) Enhance OAI-PMH:archiveID system preference description
- [[21961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21961) Typo in permission keeps Did you mean? config from showing up
- [[22009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22009) Fix error messages for classification sources and filing rules
- [[22170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22170) Library group description input field should be longer
- [[22575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22575) Item type administration uses invalid error class for dialog
- [[22962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22962) Wrong punctuation in RisExportAdditionalFields system preference
- [[22965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22965) Typo in Classification Sources description on Admin homepage (admin-home.tt)

### Templates

- [[8387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8387) Hide headings in tools when user has no permissions for any listed below
- [[10562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10562) Improve Leader06 Type Labels in MARC21slim2OPACResults.xsl
- [[20102]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20102) Remove attribute "text/css" for style element used in staff client templates
- [[20658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20658) Move template JavaScript to the footer: Installer and onboarding
- [[21130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21130) Detail XSLT produces translatable HTML class
- [[21840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21840) Fix some typos in the templates
- [[21866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21866) Rephrase "Warning: This *report* was written for an older version of Koha" to refer to plugins
- [[21990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21990) No background color for div.error, must be .alert
- [[22080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22080) Easier translation of ElasticSearch mappings page
- [[22113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22113) Add price formatting on item lost report
- [[22116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22116) Add price formatting to rental charge and replacement price on items tab in staff
- [[22197]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22197) Add Mana KB link to administration sidebar menu
- [[22236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22236) Translation should generate tags with consistent attribute order
- [[22250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22250) Clean up Mana KB integration with serials and reports
- [[22300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22300) Staff search results: Opt groups in 'sort' pull down are not well formatted
- [[22303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22303) Wrong bottom in virtualshelves/addbybiblionumber.tt
- [[22422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22422) improve item location display with class "shelvingloc"

> Expands CSS class "shelvingloc" to additional pages in both intranet and OPAC.


- [[22452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22452) Typos in add a comment to Mana modal
- [[22466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22466) TT methods must not be escaped
- [[22475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22475) Shelving location doesn't appear on tags list view
- [[22477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22477) Missing DataTables configuration when searching patrons for holds
- [[22586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22586) IntranetReportsHomeHTML no longer renders as HTML on reports-home.pl
- [[22698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22698) Fix incorrect button classes
- [[22702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22702) Circulation note on patron page should allow for HTML tags
- [[22716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22716) Use gender-neutral pronouns in system preference descriptions
- [[22746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22746) Another typo found in mana-subscription-search-result.inc (Mana KB)
- [[22800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22800) No need to raw filter the mandatory fields var (OPAC suggestions)
- [[22889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22889) Fix typos librairies and libaries
- [[22932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22932) GetLatestSerials should not return formatted date
- [[22973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22973) Remove type attribute from script tags: Staff client includes 2/2
- [[22975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22975) Remove type attribute from script tags: Acquisitions
- [[22979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22979) Remove type attribute from script tags: Authorities
- [[22981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22981) Remove type attribute from script tags: Catalog

### Test Suite

- [[14334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14334) DBI fighting DBIx over Autocommit in tests
- [[21671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21671) Koha/Patron/Modifications.t is failing randomly
- [[21692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21692) Koha::Account->new has no tests
- [[22107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22107) Avoid deleting data in some tests
- [[22254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22254) t/db_dependent/Koha/Patrons.t contains a DateTime math error
- [[22416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22416) Search.t tests need adjustment for EasyAnalyticRecords syspref
- [[22433]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22433) SIP/Transaction.t is failing randomly
- [[22453]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22453) TestBuilder should generate now() using the current timezone
- [[22493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22493) DecreaseLoanHighHolds.t creates some items/patrons with set values
- [[22547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22547) C4::Overdues - UpdateFine is barely tested
- [[22808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22808) Move Cache.t to db_dependent
- [[22850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22850) SharedContent.t wrongly use ->set_userenv
- [[22917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22917) Circulation.t fails if tests are ran slowly
- [[22930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22930) Make TestBuilder more strict about wrong arguments

### Tools

- [[19915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19915) Inventory tool doesn't use cn_sort for callnumber ranges

> This patch brings the inventory tool inline with other pages displaying data sorted by callnumbers by also adopting the use of cn_sort for sorting.


- [[20634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20634) Inventory form has 2 identical labels "Library:"
- [[21465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21465) Cannot overlay patrons when matching by cardnumber if userid exists in file and in Koha
- [[21831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21831) Marc modification templates move all action moves only one field
- [[21861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21861) The MARC modification template actions editor does not always validate user input
- [[22011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22011) Typo in Item Batch Modification
- [[22022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22022) Authorised values on the batch item modification page are not displayed in order (order by code, not lib)
- [[22036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22036) Tidy up tags/review script
- [[22069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22069) Log viewer not displaying item renewals

> This patch fixes the search for 'renewal', so both item renewals and patron renewals are found.


- [[22136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22136) Import patrons notes hides a note because the syspref isn't referenced correctly
- [[22365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22365) Warn on Log Viewer

> Sponsored by Catalyst IT

- [[22411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22411) Dates in log viewer not formatted correctly

### Web services

- [[22597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22597) Remove "more_subfields_xml" from GetPatronInfo response (xml broken)
- [[22742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22742) RenewLoan return wrong datetime format

## New sysprefs

- AccountAutoReconcile
- AllowRenewalOnHoldOverride
- AutoReturnCheckedOutItems
- AutoShareWithMana
- EmailAddressForSuggestions
- EmailPurchaseSuggestions
- FallbackToSMSIfNoEmail
- ILLModuleUnmediated
- ILLOpacbackends
- IllLog
- IndependentBranchesTransfers
- LibrisKey
- LibrisURL
- Mana
- MaxItemsToDisplayForBatchMod
- NoRenewalBeforePrecision
- OPACOpenURLItemTypes
- OPACShowOpenURL
- OpacMoreSearches
- OpenURLImageLocation
- OpenURLResolverURL
- OpenURLText
- OrderPriceRounding
- OverDriveUsername
- PatronAnonymizeDelay
- PatronRemovalDelay
- RESTBasicAuth
- RESTPublicAPI
- SelfCheckAllowByIPRanges
- SendAllEmailsTo
- UnsubscribeReflectionDelay
- UpdateItemLocationOnCheckin

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

- [Koha Manual](http://koha-community.org/manual/19.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (93.2%)
- Armenian (100%)
- Basque (60.3%)
- Chinese (China) (60.9%)
- Chinese (Taiwan) (96.5%)
- Czech (88.7%)
- Danish (52.9%)
- English (New Zealand) (84%)
- English (USA)
- Finnish (79.5%)
- French (93.4%)
- French (Canada) (94.1%)
- German (100%)
- German (Switzerland) (87.2%)
- Greek (74.6%)
- Hindi (98.7%)
- Italian (89%)
- Norwegian Bokmål (90.1%)
- Occitan (post 1500) (56.9%)
- Polish (81.6%)
- Portuguese (100%)
- Portuguese (Brazil) (92.4%)
- Slovak (85.6%)
- Spanish (100%)
- Swedish (89.7%)
- Turkish (93%)
- Ukrainian (58.2%)
- Vietnamese (50.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.00 is

- Release Manager: Nick Clemens
- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathan Druart
- QA Manager: Katrin Fischer
- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Chris Cormack
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Martin Renvoize
  - Marcel de Rooy
- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - UI Design -- Owen Leonard
  - Elasticsearch -- Ere Maijala
- Bug Wranglers:
  - Indranil Das Gupta
  - Jon Knight
  - Luis Moises Rojas
- Packaging Manager: Mirko Tietgen
- Documentation Manager: Caroline Cyr-La-Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Wiki curators: 
  - Caroline Cyr-La-Rose
- Release Maintainers:
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 18.11 -- Martin Renvoize
  - 17.11 -- Fridolin Somers
- Release Maintainer assistants:
  - 18.05 -- Kyle Hall

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.05.00:

- Arcadia Public Library
- Brimbank Library, Australia
- ByWater Solutions
- Carnegie-Stout Public Library
- Catalyst IT
- Cheshire Libraries Shared Services
- City of Portsmouth Public Library
- Gothenburg University Library
- Halton Borough Council
- Hypernova Oy
- Middletown Township Public Library
- National Library of Finland
- PTFS Europe
- Pueblo City-County Library District
- Round Rock Public Library
- Sefton Council
- Theke Solutions

We thank the following individuals who contributed patches to Koha 19.05.00.

- Morgane Alonso (2)
- Ethan Amohia (3)
- Aleisha Amohia (12)
- Jasmine Amohia (13)
- Tomás Cohen Arazi (175)
- Alex Arnaud (14)
- Philippe Blouin (1)
- Henry Bolshaw (1)
- David Bourgault (2)
- Christopher Brannon (7)
- Alex Buckley (4)
- Colin Campbell (3)
- Frédérick Capovilla (1)
- Galen Charlton (1)
- Nick Clemens (280)
- David Cook (2)
- Chris Cormack (2)
- Olivier Crouzet (1)
- Caroline Cyr-La-Rose (2)
- Frédéric Demians (2)
- Jonathan Druart (175)
- Nicole Engard (1)
- Magnus Enger (2)
- Charles Farmer (1)
- Katrin Fischer (88)
- Lucas Gass (5)
- Claire Gravely (2)
- David Gustafsson (11)
- Kyle Hall (71)
- Helene Hickey (9)
- Andrew Isherwood (63)
- Te Rauhina Jackson (1)
- Mackey Johnstone (1)
- Andreas Jonsson (4)
- Pasi Kallinen (2)
- Jack Kelliher (2)
- Olli-Antti Kivilahti (2)
- Jon Knight (1)
- Jiří Kozlovský (1)
- Bernardo González Kriegel (1)
- Thatcher Leonard (1)
- Owen Leonard (164)
- Olivia Lu (4)
- Ere Maijala (17)
- Hayley Mapley (12)
- Julian Maurice (17)
- Matthias Meusburger (4)
- Jose-Mario Monteiro-Santos (1)
- Josef Moravec (102)
- Agustín Moyano (8)
- Björn Nylen (2)
- Nicholas Van Oudtshoorn (2)
- Eric Phetteplace (1)
- Liz Rea (22)
- Martin Renvoize (175)
- Marcel de Rooy (43)
- Andreas Roussos (3)
- Maryse Simard (3)
- Kris Sinnaeve (1)
- Eivin Giske Skaaren (1)
- Fridolin Somers (36)
- Arthur Suzuki (2)
- Lari Taskula (4)
- Lyon 3 Team (1)
- Pierre-Marc Thibault (1)
- Mirko Tietgen (2)
- Mark Tompsett (9)
- Koha translators (1)
- Jesse Weaver (4)
- Baptiste Wojtkowski (1)
- Nazlı Çetin (9)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.00

- abunchofthings.net (2)
- ACPL (164)
- BibLibre (75)
- BSZ BW (90)
- ByWater-Solutions (359)
- Catalyst (19)
- Coeur D'Alene Public Library (7)
- Devinim (9)
- Equinox (1)
- etf.edu (1)
- f1ebe1bec408 (4)
- Göteborgs Universitet (7)
- Independant Individuals (165)
- jkozlovsky.cz (1)
- jns.fi (6)
- Koha Community Developers (175)
- Kreablo AB (4)
- Libeo (1)
- Libriotech (2)
- Loughborough University (1)
- parliament.uk (1)
- Prosentient Systems (2)
- PTFS-Europe (241)
- Rijks Museum (43)
- Solutions inLibro inc (10)
- stacmail.net (2)
- Tamil (2)
- The City of Joensuu (2)
- Theke Solutions (183)
- ub.lu.se (2)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (17)
- Université Jean Moulin Lyon 3 (2)
- Wellington East Girls' College (13)
- wgc.school.nz (9)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (2)
- Axel Amghar (1)
- Ethan Amohia (2)
- Aleisha Amohia (2)
- Jasmine Amohia (2)
- Tomás Cohen Arazi (192)
- Alex Arnaud (18)
- Marjorie Barry-Vila (3)
- Oliver Behnke (1)
- Bob Bennhoff (7)
- Anne-Claire Bernaudin (2)
- David Bourgault (1)
- Arthur Bousquet (2)
- Christopher Brannon (4)
- Mikaël Olangcay Brisebois (17)
- Alex Buckley (1)
- Galen Charlton (1)
- Barton Chittenden (3)
- Claudio (1)
- Nick Clemens (1619)
- David Cook (3)
- Chris Cormack (27)
- Sarah Cornell (4)
- Devlyn Courtier (2)
- Frédéric Demians (2)
- Michal Denar (85)
- John Doe (2)
- Jonathan Druart (88)
- Nicole Engard (1)
- Magnus Enger (7)
- Charles Farmer (20)
- Andrew Farthing (3)
- Bouzid Fergani (2)
- Katrin Fischer (466)
- Martha Fuerst (2)
- Brendan Gallagher (4)
- Lucas Gass (12)
- Stephen Graham (2)
- Claire Gravely (26)
- Victor Grousset (1)
- Kyle Hall (192)
- Geeta Halley (2)
- Frank Hansen (1)
- Helene Hickey (2)
- Andrew Isherwood (9)
- Dilan Johnpullé (1)
- Mackey Johnstone (3)
- Andreas Jonsson (1)
- Jose-Mario (1)
- Pasi Kallinen (2)
- Jack Kelliher (3)
- Jill Kleven (3)
- Jon Knight (1)
- Rhonda Kuiper (1)
- Marie-Luce Laflamme (1)
- Nicolas Legrand (6)
- Owen Leonard (96)
- Olivia Lu (1)
- Andreas Hedström Mace (1)
- Ere Maijala (3)
- Jayne Maisey (2)
- Hayley Mapley (35)
- Jesse Maseto (1)
- Julian Maurice (15)
- Martin McGovern (1)
- Janet McGowan (2)
- Jose-Mario Monteiro-Santos (22)
- Josef Moravec (395)
- Agustín Moyano (7)
- David Nind (29)
- Björn Nylen (3)
- Jessica Ofsa (2)
- Dobrica Pavlinušić (1)
- David Peacock (2)
- Eric Phetteplace (1)
- Séverine Queune (28)
- Liz Rea (170)
- Martin Renvoize (452)
- David Roberts (1)
- Benjamin Rokseth (3)
- Marcel de Rooy (177)
- Paola Rossi (1)
- BWS Sandboxes (2)
- Lisette Scheer (8)
- Maribeth Shafer (1)
- Maryse Simard (27)
- Jogiraju Tallapragada (2)
- Lari Taskula (1)
- Pierre-Marc Thibault (44)
- Mirko Tietgen (2)
- Mark Tompsett (11)
- Te Rahui Tunua (1)
- Ed Veal (1)
- Marc Véron (3)
- Niamh Walker-Headon (13)
- Bin Wen (26)
- George Williams (1)
- Mengü Yazıcıoğlu (6)
- Nazlı Çetin (4)

We thank the following individuals who mentored new contributors to the Koha project.

- Owen Leonard


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

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

Autogenerated release notes updated last on 30 May 2019 13:50:57.
