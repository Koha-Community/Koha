# RELEASE NOTES FOR KOHA 22.11.00 ROSALIE
25 nov 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.00 is a major release, that comes with many new features.

It includes 13 new features, 351 enhancements, 3 security fixes, 551 bugfixes.

## Dedications

The Koha Community would like to dedicate the release of Koha 22.11 to Rosalie Blake.

Rosalie was the Head Librarian at Horowhenua Library Trust when Koha was started and without her Koha
would not exist. She was an inspiring leader and innovator and took the risk of her career entrusting
Chris, Joanne, Rachel and Simon to deliver the original project that became the international sensation
we all know and love.

She was also a practicing Justice of the Peace, a stalwart of the Levin Pottery Club and much loved
mother of Simon and Jeremy, and grandmother of Ben, Toby, Anna, Charlotte and Billy.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## New features

### Authentication

- [[30588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30588) Add the option to require 2FA setup on first staff login

  **Sponsored by** *Rijksmuseum, Netherlands*

  >This adds a third option 'enforce' to the  TwoFactorAuthentication system preference. If chosen, staff will no longer be able to log into the staff client without setting up and using 2-factor authentication.
- [[31378]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31378) Add a generic OAuth2/OIDC client implementation

  **Sponsored by** *a ByWater Solutions partner*

  >This feature introduces a way to integrate Koha with any OAuth2/OIDC identity provider.
  >
  >It also prepares the ground for later adding more protocols and prioritizing authentication methods/identity providers.

### Cataloging

- [[24606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24606) Allow storing item values as a template for creating new items

  >This new feature allows librarians to create and share "item templates" where one or more item field values can be set for a template. Templates can be applied on a one by one basis, or set for the remainder of the logged in session. Each template may be optionally shared ( read only ) to other catalogers. Librarians with the manage_item_editor_templates permission may edit any template regardless of who created it.
- [[24857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24857) Add ability to group items for records

  >This feature allows for libraries to group items within a record.  A new system preference has been added for this feature, EnableItemGroups. This system preference, once enabled, will allow the library to group specific items on a record to each other. A library can name the group and add items from the same record to this group. From the record, a new tab will appear and display on that item if it is part of a group.

### Circulation

- [[24860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24860) Add ability to place item group level holds

  >With this feature you can now place holds on groups of items. A group consists of multiple items of the same record, representing for example, all items of a specific volume. When a hold for an item group is placed, only items of the requested group will be able to fill the hold.
  >The feature is enabled using the new EnableItemGroupHolds system preference. It also requires EnableItemGroups for managing item groups.
- [[28854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28854) Add ability to create bundles of items for circulation

  >This new feature adds the ability to create item bundles for loans.
  >
  >One can create a new collection level biblio record and add items to it as normal. Those items can then be converted to bundles by adding existing items to them using their barcodes. The items will be marked as 'not for loan' in their original parent records.
  >
  >Bundle items follow normal circulation rules for checkout. Upon check-in a new verification step is added where by the librarian is expected to scan each constituent item to varify it's presence in the bundle. If an item is missing from the bundle it is marked as lost with a new lost - Missing from bundle value.  If an item is found that is not expected to be in the bundle it it highlighted to the librarian after check-in so it can be placed to one side.
  >
  >**Sponsored by** *PTFS Europe*
- [[30650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30650) Add a curbside pickup module

  **Sponsored by** *Association KohaLa*

  >With this module staff and patrons will be available to manage curbside pickups from the OPAC and staff interface. 
  >It adds a new configuration page to the administration module which allows each library in an installation to set their own rules and time slots for scheduling pickups.
  >If a library chooses to activate curbside pickups, they will be able to manage all stages to the process from within Koha: scheduling a pickup time, preparing items for pickup and completing pickups. Patrons can indicate that they have arrived at the library for their pickup through the OPAC.
  >Use the CurbsidePickup system preference to enable this module.

### ERM

- [[32030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32030) Electronic resource management (ERM)

  **Sponsored by** *BibLibre*, *ByWater Solutions* and *PTFS Europe*

  >This new module adds a mechanism to track the selection, acquisition, licensing, access, maintenance, usage, evaluation, retention, and de-selection of a library’s electronic information resources. These resources include, but are not limited to, electronic journals, electronic books, streaming media, databases, datasets, CD-ROMs, and computer software.

### Patrons

- [[12446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12446) Enable an adult to have a guarantor

  >Before only categories of a certain type can be guarantees for other patron categories of certain types (Adult to child, organisation to professional). With this new feature it's possible to define which patron categories can be guarantees independent of the category type. This enables relationships like adult to adult or organisation to adult.
- [[23681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23681) Make patron restrictions user definable

  **Sponsored by** *Koha-Suomi Oy* and *Loughborough University*

  >This adds a new configuration page for managing user defined and Koha internal patron restrictions to the administration module.
  >
  >If the new system preference PatronRestrictionTypes is enabled, you will also be able to choose the restriction type when manually restricting a patron.

### Searching

- [[17170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17170) Add the ability to create 'saved searches' for use as filters when searching the catalog

  **Sponsored by** *Round Rock Public Library*

  >This patchset adds a new feature, the ability to save searches on the staff client and display them in the results page alongside facets (staff client and/or OPAC) as a search filter that can be applied to search result set.
  >
  >The feature is enabled/disabled by new system preference: SavedSearchFilters 
  >
  >New filters can be added from the results page after a search, and there is an admin page for updating deleting and renaming filters.
  >
  >There is a new permission, manage_search_filters, to control management of these filters.
  >
  >New filters can be added that are not displayed along with facets, this allows for building custom links using these filters to keep URLs shorter

### Staff interface

- [[15326]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15326) Add CMS feature

  **Sponsored by** *Chartered Accountants Australia and New Zealand* and *Horowhenua Libraries Trust*

  >This enhancement utilises the additional contents feature to add custom pages to the staff interface and the OPAC in the user's desired language.
- [[30952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30952) New design for staff interface

  >This is the result of a wide scale review of the staff interface user experience.
  >
  >A team of librarians, designers and developers has worked hard to refresh, modernize and increase consistency in the staff interface.
  >
  >We hope you like the fresh new look and feel.

## Enhancements

### Acquisitions

- [[10086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10086) No way to go back to the basket on uncertain prices page

  **Sponsored by** *Catalyst*

  >This updates the display of the uncertain prices page (Acquisitions > Uncertain prices):
  >1. The basket name is now linked to the basket in the list of orders with uncertain prices, making it easier to quickly view the basket.
  >2. The edit link is now formatted as a button and moved into a column (similar to other areas), instead of being a text link in the order column.
- [[15348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15348) Change/Edit estimated delivery date per order line

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >This enhancement allows you to specify an estimated delivery date per order line. The specified estimated delivery date is also considered (alongside the calculated estimated delivery date, if no date has been specified) when searching for late orders and exporting late orders. You can also edit the estimated delivery date from the late orders page.
- [[25763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25763) Allow update of order fund after receipt
- [[27817]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27817) Enhance display of title information throughout acquisitions

  >This adds remainder of title/subtitle, medium, part name, and part number to several pages in the acquisitions module.
- [[28269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28269) Order search should be possible with ISSN too

  >This adds ISSN as a new search option to the acquisitions advanced search form. If SearchWithISSNVariations is enabled, you'll be able to search for the ISSN with and without the hyphen.
- [[29983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29983) Display the return claims column in the circulation overdues page (overdue.tt)

  >This enhancement adds the "Return claims" column to the circulation overdues page, like it is on a patron's check out and details pages. Display or hide the column using the column settings options. It can also be configured using the table settings options in the administration area - it is hidden by default.
- [[31017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31017) Add type field for vendors

  >This enhancement adds a new field to record the vendor type when creating or editing vendors. This field can be used as a free text field, or a drop-down menu if there are authorized values in the VENDOR_TYPE authorized value category.
- [[31115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31115) Additional fields for invoices

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*

  >This new feature adds the ability to define additional fields to store information about vendor invoices.
  >There is a new 'Manage invoice fields' page in the acquisitions administration to configure the fields.
  >Users can name additional fields, tie them to authorised values, and specify whether the fields can be searched in the acquisitions module.
  >This also adds a new entry to the admin page for additional fields.
- [[31257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31257) Add a new English 1 page layout to export a basket as PDF

  **Sponsored by** *Pymble Ladies' College*

  >This patch adds a new English 1 page layout to be used when exporting a basket group as PDF. It can be selected as a new  option from the OrderPdfFormat system preference.
- [[31333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31333) Add the ability to limit purchase suggestions by patron category

  **Sponsored by** *Catalyst*

  >Exclude patron categories from submitting OPAC purchase suggestions by selecting them in the new suggestionPatronCategoryExceptions system preference.
- [[31374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31374) Add a non-public note column to the suggestions table

  >This enhancement adds a non-public notes field to the suggestions tables in the staff interface. It is displayed by default in the suggestion management tables, and is configurable using the table settings.
- [[31377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31377) Add basket's internal note to tables on vendor search result list
- [[31388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31388) Add select2 to fund selection in new order form
- [[31459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31459) Make order receive page faster on systems with many budgets
- [[31569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31569) Remove GetImportsRecordRange from acqui/addorderiso2709
- [[31586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31586) Log basket number as object when an email order is sent

### Architecture, internals, and plumbing

- [[15545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15545) Remove remainders of unfinished reqholdnotes functionality
- [[23991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23991) Move SearchSuggestion to Koha::Suggestions
- [[24295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24295) C4::Circulation::GetTransfers should be removed, use Koha::Item->get_transfer instead
- [[27272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27272) Move C4::Items::GetItemsInfo to Koha namespace

  >Another step on the old code refactoring. At this time, related to item information display.
  >
  >There are several DB queries that get avoided with this change as well, leading to more performant processing of requests.
- [[27342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27342) Improve readability and improvement of C4::Auth::get_template_and_user
- [[28186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28186) Use Koha::Authority in C4::AuthoritiesMarc::AddAuthority
- [[29454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29454) Stash itemtypes in plugin objects to reduce DB calls
- [[29623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29623) Cache effective circulation rules
- [[29672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29672) Increase performance of Koha::Plugins->call
- [[29697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29697) Replace GetMarcBiblio occurrences with $biblio->metadata->record
- [[29744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29744) Harmonize psgi/plack detection methods
- [[29883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29883) Uninitialized value warning when GetAuthorisedValues gets called with no parameters
- [[29939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29939) Replace opac-ratings-ajax.pl with a new REST API route
- [[29955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29955) Move C4::Acquisition::populate_order_with_prices to Koha::Acquisition::Order
- [[30016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30016) Remove GetOpenIssue subroutine
- [[30042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30042) Remove Date::Calc use
- [[30057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30057) Move Virtualshelves exceptions to their own file
- [[30168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30168) Use checkout object in GetSoonestRenewDate
- [[30275]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30275) Checkout renewals should be stored in their own table

  **Sponsored by** *Loughborough University*

  >This enhancement adds a renewals table to store details of a checkouts renewals.
- [[30420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30420) Rename Koha::Patron->get_overdues with ->overdues

  >This enhancement makes the method naming more consistent.
- [[30543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30543) Decouple DumpSearchQueryTemplate from other template dump preferences
- [[30578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30578) We should drop circ/ysearch.pl in preference to using the REST API's
- [[30612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30612) Add account_lines method to Koha::[Old::]Checkout
- [[30830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30830) Add Koha Objects  for Koha Import Items
- [[30848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30848) Introduce Koha::Filter::ExpandCodedFields
- [[30874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30874) Simplify patron category handling in memberentry
- [[30877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30877) use List::MoreUtils::uniq from recalls_to_pull.pl
- [[30901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30901) Add template method to be able to look up renewal data in Koha slips and notices

  >This adds a way to print information about renewals to notices with Template Toolkit. This includes the numbers for used renewals, allowed renewals and remaining renewals and more.
  >Documentation: https://wiki.koha-community.org/wiki/Notices_with_Template_Toolkit#Example:_CirculationRules.Renewals
- [[30921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30921) Replace use of C4::XSLT::transformMARCXML4XSLT with RecordProcessor
- [[30950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30950) timepicker.inc is no longer used and should be removed
- [[30982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30982) Use the REST API for background job list view
- [[31001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31001) "CGI::param called in list context" warning in basket.pl flooding error log

  >This fixes the cause of a warning message that appears in the system logs when emailing an order to a vendor (Acquisitions > [select a vendor] > [select a basket] > E-mal order). The warning message was "[WARN] CGI::param called in list context from /kohadevbox/koha/acqui/basket.pl line 175, this can lead to vulnerabilities. See the warning in "Fetching the value or values of a single named parameter" at /usr/share/perl5/CGI.pm line 414.".
- [[31183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31183) Add Koha::Item::Transfers->filter_by_current
- [[31306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31306) Add Koha::Items->search_ordered method
- [[31308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31308) Remove GetItemsInfo from basket/basket
- [[31309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31309) Remove GetItemsInfo from basket/sendbasket
- [[31310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31310) Remove GetItemsInfo from catalogue/imageviewer
- [[31311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31311) Remove GetItemsInfo from labels/label-item-search
- [[31312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31312) Remove GetItemsInfo from misc/migration_tools/rebuild_zebra.pl
- [[31313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31313) Remove GetItemsInfo from opac-detail
- [[31314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31314) Remove GetItemsInfo from opac-reserve.pl
- [[31315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31315) Remove GetItemsInfo from moredetail
- [[31316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31316) Remove GetItemsInfo from opac-sendbasket
- [[31317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31317) Remove GetItemsInfo from opac-tags
- [[31318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31318) Remove GetItemsInfo from serials/routing-preview
- [[31319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31319) Remove GetItemsInfo from tags/list.pl
- [[31320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31320) Remove GetItemsInfo from virtualshelves/sendshelf.pl
- [[31321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31321) Remove GetItemsInfo from catalogue/detail.pl
- [[31328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31328) Make Koha::Item->get_transfer* use Koha::Item::Transfers->filter_by_current
- [[31389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31389) Calculate user permissions in separate function
- [[31517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31517) C4::Tags should use Koha::Tags objects instead of raw SQL
- [[31519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31519) Unused template parameters in request.pl
- [[31590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31590) Remove Text::CSV::Unicode
- [[31666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31666) Add job progress bar to stage-marc-import.pl
- [[31776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31776) Typo in cleanup_database.pl cron's help/usage

### Authentication

- [[25936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25936) Notify users if their password has changed

  >When the system preference NotifyPasswordChange is set to 'Notify' a notification will be sent to the user when their password is changed. The new notification uses the letter code PASSCHANGE.
  >
  >**Sponsored by** *PTFS Europe*
- [[28787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28787) Send a notice with the TOTP token

  **Sponsored by** *Rijksmuseum, Netherlands*

  >Add the ability to send an email containing the token to the
  >patron once it's authenticated
  >
  >The new notice template is '2FA_OTP_TOKEN'.
- [[31495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31495) Allow viewing CMS pages when enforcing GDPR policy

### Cataloging

- [[23063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23063) Item table in cataloguing doesn't respect CurrencyFormat

  >This makes sure that the price and replacement price of an item is displayed according to the CurrencyFormat setting in the items table above the add/edit item form.
- [[26368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26368) Add support for OCLC Encoding level values
- [[27981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27981) Add option to automatically set the 001 control number to the biblionumber

  >This patch adds a new system preference:
  >autoControlNumber
  >
  >The systempreference has two options, Control Number (001) is:
  > - generated as biblionumber: will set field 001 to the biblionumber when you create a new record or edit an existing record and clear the 001 field. If a value is present in 001 when saving the record it will be preserved.When duplicating a record the pre-existing 001 will be removed.
  > - not generated automatically: the 001 field will not be touched
- [[30392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30392) Add a deleted_on column to deleteditems
- [[30504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30504) Value builder for UNIMARC field 181

  >This enhancement for UNIMARC field 181 adds value builders for subfields $a, $b, $c, and $2. These are based on the official UNIMARC codes.
- [[30506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30506) Value builder for UNIMARC field 182

  >This enhancement for UNIMARC field 182 adds value builders for subfields $a, $c, and $2. These are based on the official UNIMARC codes.
- [[30507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30507) Value builder for UNIMARC field 183

  >This enhancement for UNIMARC field 183 adds value builders for subfields $a and $2. These are based on the official UNIMARC codes.
- [[30716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30716) Add Collection column to cn_browser results table
- [[30775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30775) 952w should have datepicker plugin enabled for it by default

  >This enhancement adds the date picker to 952$w (price effective from). 
  >
  >This improves usability (952$d (date acquired) has the date picker enabled) and also adds date field validation (the date is added to the database as YYYY-MM-DD and when entered incorrectly it can lead to crashes in other areas).
- [[30871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30871) Make it clear that 008 Type of Material is controlled by Leader 6th position in MARC21

  >This enhancement adds title elements or clarifies existing title elements to indicate how default values are chosen (for both the default and advanced editor).
- [[30941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30941) Add value builders for UNIMARC 146 ($b, $c, $d, $e and $f)

  >This enhancement adds value builders for UNIMARC 146$b, $c, $d, $e, and $f.
- [[30997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30997) "CGI::param called in list context" warning in detail.pl flooding error log

  >This fixes the cause of "CGI::param called in list context from" warning messages that appear in the log files when viewing record detail pages in the staff interface.
- [[31250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31250) Don't remove advanced/basic cataloging editor cookie on logout
- [[31371]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31371) Value builder for UNIMARC field 283
- [[31372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31372) Value builder for UNIMARC field 325
- [[31417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31417) Re-instate the cataloguing sidebar menu
- [[31536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31536) Add UNIMARC framework plugin to fetch PPN from sudoc.fr

  >This enhancement adds a UNIMARC plugin (unimarc_field_009_ppn.pl) that uses sudoc.fr web services (isbn2ppn, issn2ppn, ean2ppn) to search for the Sudoc record identifier (PPN) using the ISBN, ISSN, or EAN identifiers as the search criteria. The plugin expects the ISBN in 010$a, ISSN in 011$a, and EAN in 073$a.

### Circulation

- [[7021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7021) Add patron category to the statistics table

  **Sponsored by** *Koha-Suomi Oy*
- [[20262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20262) Add ability to refund lost item fees without creating credits
- [[21381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21381) Add serial enumeration to circulation history
- [[23012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23012) Possibility to mark processing fee by default refund when item is found

  **Sponsored by** *Auckland University of Technology*

  >This enhancement gives the ability to set a policy for the lost item processing fee that may get charged additional to the lost item replacement cost. The processing fee can be:
  >- refunded
  >- refunded if unpaid
  >- kept
- [[23838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23838) Add ability to view item renew history

  **Sponsored by** *Loughborough University*

  >This enhancement adds a modal to display checkout renewal history details where appropriate. This includes the circulation history and the items tab of the staff detail page.
- [[29129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29129) The clear screen and print icons in circulation should be configuarable to print either ISSUESLIP or ISSUEQSLIP

  >This enhancement expands upon the 'DisplayClearScreenButton' allowing the choice of printing either the ISSUESLIP or the ISSUEQSLIP when using the printclearscreen icon.
- [[30407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30407) Add ability to syspref UpdateNotForLoanStatusOnCheckin to show only the notforloan values description

  **Sponsored by** *Koha-Suomi Oy*
- [[30802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30802) numReturnedItemsToShow doesn't show more than 20 items on the return screen
- [[30905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30905) Show waiting recalls in patron account on checkouts tab

  **Sponsored by** *Catalyst*

  >This enhancement shows recalls ready for pick-up on the patron's account so they can't be missed.
- [[30947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30947) Simplify date handling in CanbookBeIssued
- [[30964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30964) Add information about overdues and restrictions on the curbside pickup list

  **Sponsored by** *Association KohaLa*
- [[30965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30965) Add patron autocomplete search to curbside pickups

  **Sponsored by** *Association KohaLa*
- [[31157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31157) overdue_notices.pl --frombranch option should be available as a system preference

  >This patch adds a new system preference "OverdueNoticeFrom" that overrides the --frombranch parameter of the overdue_notices.pl cronjob. 
  >
  >This allows systems librarians the option to pick which address to use for overdues notices.
  >
  >The default value is "command-line option", meaning if there is a branch specified in the cronjob, the behavior will not change.
  >
  >**Sponsored by** *PTFS Europe*
- [[31261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31261) Curbside pickups - remove slots in the past

  **Sponsored by** *Association KohaLa*
- [[31262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31262) Curbside pickups - disable dates without slots

  **Sponsored by** *Association KohaLa*
- [[31265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31265) Curbside pickups - improve slots selection
- [[31419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31419) Add accesskeys to recall modal
- [[31485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31485) Move ItemsDeniedRenewal checks from C4::Circulation to Koha::Item
- [[31753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31753) Dialog boxes inside of modals don't seem wide enough

### Command-line Utilities

- [[17379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17379) Add a man page for koha-passwd
- [[21903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21903) koha-dump be able to include koha-upload

  **Sponsored by** *Orex Digital*
- [[26311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26311) Add patron invalid age to search_for_data_inconsistencies.pl

  >This enhancement to the command line script used for searching for data inconsistencies (misc/maintenance/search_for_data_inconsistencies.pl) now lists patrons where their age doesn't match the criteria set for the patron category. 
  >
  >This includes where there is:
  >- a minimum age required
  >- an upper age limit
  >- a minimum age and an upper age limit
  >
  >An example of the output:
  >
  > Patrons with invalid age for category:
  > * Patron borrowernumber=49 has an invalid age of 10 for their category 'PT' (24 to unlimited)
  > * Patron borrowernumber=49 has an invalid age of 71 for their category 'PT' (0 to 50)
  > * Patron borrowernumber=44 has an invalid age of 70 for their category 'PT' (20 to 60)
  >
  >Note: Where a patron's age can't be calculated (for example: a school or other organisation, or the date of birth is missing), then they are not included in the checks.
- [[28555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28555) Improve output of verbose option for overdue_notices.pl
- [[30684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30684) koha-* scripts --restart should start even when not running

  **Sponsored by** *Catalyst*

  >This enhancement restarts services if they are not running when using the --restart option for koha-plack, koha-indexer, koha-sip, koha-worker, koha-z3950-responder, and koha-zebra . 
  >
  >An example of a message if plack is not running and the service is restarted:
  >koha-plack --restart kohadev
  >[warn] Plack not running for kohadev. ... (warning).
  >[ ok ] Starting Plack daemon for kohadev:.
  >
  >Previously if a service was not running an error message was generated (Error: {servicename} not running for ${instancename}") and a start command for the service was required.
- [[31155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31155) Document --since option in help of borrowers-force-messaging-defaults.pl

  >This enhancement adds a brief explanation of the --since option for borrowers-force-messaging-defaults.pl.
- [[31203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31203) Cronjobs should log completion as well as logging begin
- [[31342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31342) process_message_queue can run over the top of itself causing double-up emails

  **Sponsored by** *ByWater Solutions*
- [[31854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31854) Document conflict with delete_patrons.pl --not_borrowed_since and anonymization
- [[31969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31969) Options for cleanup_database.pl to remove finished jobs from the background job queue

### Database

- [[30571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30571) Table z3950servers: Make host, syntax and encoding NOT NULL

### ERM

- [[32130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32130) Vue files must be kept tidy

### Fines and fees

- [[24865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24865) Customize the accountlines description

  >This patch adds a new notice/slip: OVERDUE_FINE_DESC
  >
  >This can be used to customize the accountlines description for overdue fines that can access objects for the checkout, the item, and the borrower
- [[27802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27802) Set focus for cursor on first input field when adding a cash register

  **Sponsored by** *Catalyst*
- [[30335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30335) Add ability to hide/disable manual invoices and manual credits in patron accounts
- [[30619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30619) Add the option to email receipts as an alternative to printing

  **Sponsored by** *Martin Renvoize*

  >This enhancement adds an email receipt option to the Point of Sale module, along with a sample notice (RECEIPT). When completing a transaction, there is now an 'Email receipt' button next to 'Print receipt' button - the email address is entered in a pop-up window if the email receipt option is selected.
- [[31121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31121) Format date range on top of cashup summary page

  >This fixes the formatting of dates on the cashup summary modal (it uses the existing $datetime JS include).
  >
  >**Sponsored by** *PTFS Europe*
- [[31163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31163) Sort cashup history so that newest entries are first
- [[31254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31254) Add additional fields for accountlines
- [[31713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31713) Allow easy printing of patron's fines

  >Adds the option to print an accounts summary from the print pull down in the patron's account in the staff interface. This uses the new notice ACCOUNTS_SUMMARY.

### Hold requests

- [[14364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14364) Allow automatically canceled expired waiting holds to fill the next hold
- [[14783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14783) Allow patrons to change pickup location for non-waiting holds

  **Sponsored by** *Lund University Library, Sweden*

  >This enhancement allows patrons to change the pickup location of non-waiting holds from the opac.
  >
  >The new system preference "OPACAllowUserToChangeBranch" controls at what stages the pickup location can be changed (Pending, In-transit, Suspended).
- [[29057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29057) Use font awesome icons on request.pl

  >This enhancement updates the arrows used on the holds page for a record to change the hold priority. Instead of using images for the arrows, Font Awesome icons are now used.
  >
  >In addition, you can now override the icons using any Font Awesome icons in the IntranetUserCSS system preference. For an example, see https://gitlab.com/-/snippets/2319364
- [[30500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30500) Add option to allow user to change the pickup location while a hold is in transit

  **Sponsored by** *Montgomery County Public Libraries*
- [[30878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30878) Canceling holds from 'Holds awaiting pickup' should not reset the selected tab
- [[31105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31105) Holds to pull counts items from other branches when independentbranches is active
- [[31948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31948) Add timestamp to tmp_holdsqueue

  >This adds a timestamp column to the tmp_holdsqueue table that the holds queue in circulation is built from. With RealTimeHoldsQueue this will enable reporting on the date and time an entry was added to the holds queue.

### I18N/L10N

- [[28708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28708) fr-CA localization file
- [[30028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30028) Patron message delete confirmation untranslatable

  >This fixes the patron delete messages dialogue box to make the message shown translatable.
- [[30733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30733) Simplify translatable strings

  >Cleanup of translatable text done by guiding the string extractor to make it do simpler strings for translators instead of large concatenation of long strings in the code with a lot of unnecessary %s placeholders.
- [[31068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31068) Context for translation: Print (verb) vs. Print (noun)

  >This enhancement adds context for translation purposes to the term 'Print' for notices and slips message transport types (email, print, SMS). (In English, the word "print" is the same whether it is a verb (to print something) or a noun (a print of something), however, for other languages different words may be used. When the word is in a sentence, it's not too difficult to translate, but in cases where the string to translate is simply "Print", it is often used in different cases (noun or verb). For example: in French there are two different spellings, "Imprimer" or "Imprimé".)
- [[31715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31715) Add missing German translations for language descriptions

  >This adds the missing German translations for languages, as seen in the language list on the advanced search in staff interface and OPAC.
- [[31807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31807) Context for translation: Filter (verb) vs. Filter (noun)

  >This enhancement adds some context for translators for the term "Filter" when used as a noun as opposed to a verb.

### ILL

- [[22321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22321) Make it possible to edit illrequests.borrowernumber
- [[24239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24239) Let the ILL module set ad hoc hard due dates
- [[28909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28909) Allow Interlibrary loans illview method to use backend template
- [[30484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30484) Interlibrary loans should have the ability to send notices based on request supplier updates

  >This interlibrary loans module enhancement allows backend developers to trigger notices to patrons upon certain backend actions.
  >
  >**Sponsored by** *PTFS Europe*

### Installation and upgrade (command-line installer)

- [[25622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25622) Change way MySQL password is generated by koha-create
- [[29673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29673) Allow an English sql localization script
- [[32191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32191) Consistent upgrade messages

### Installation and upgrade (web-based installer)

- [[31403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31403) Activate circulation sidebar (CircSidebar system preference) on default in new installations

### Label/patron card printing

- [[28512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28512) Quick spine label creator: Add CSS class with logged in library's branchcode
- [[31633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31633) Add home and holding data attributes to quick spine label print to help customizing

### Lists

- [[11889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11889) Option to keep public or shared lists when deleting patron

  **Sponsored by** *Catalyst*

  >This report adds the preference ListOwnershipUponPatronDeletion.
  >
  >It allows you to choose between the existing behavior of just deleting all lists when deleting a patron, or transfer ownership of public and shared lists to the staff member that deleted the patron.
  >
  >Follow-up reports will allow for even more flexibility.
- [[25498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25498) Allow to change owner of public or shared list

  >This enhancement allows staff members with sufficient permissions to change the owner of a public list.
  >
  >It also add the possibility for the owner of a shared list to transfer ownership to one of the other users of the list via the opac shelves form. Implicitly, we hereby add the option of showing which users are currently sharing the list to the owner.
- [[29114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29114) Can not add barcodes with whitespaces at the beginning to the list

  >This fixes an issue where barcodes with white spaces at the beginning could not be added to a list.
- [[30933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30933) Add a designated owner for shared and public lists at patron deletion

  >This enhancement enables the transfer of public list ownership when a patron is deleted (from the staff interface, and scripts or cron jobs such as misc/cronjobs/delete_patrons.pl). A new system preference ListOwnershipUponPatronDeletion sets the action to take when a patron with public lists is deleted (options: delete the lists or change owner of these lists). If set to change the owner, the lists are transferred to the borrower number set in the new ListOwnerDesignated system preference.

### MARC Authority data support

- [[30218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30218) Add subfield g to 150 heading_fields

  **Sponsored by** *Steiermärkische Landesbibliothek*
- [[30280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30280) Support authority records with common subject headings from different thesaurus

  **Sponsored by** *Lund University Library, Sweden*

  >This enhancement adds support for displaying and linking to subject headings from different thesaurus when using Elasticsearch. The thesaurus used for the term is added to the authority record using 040$f. For the bibliographic record, set the second indicator to 7 for 650 and add the source to 650$2. For local terms, use 4 (Source not specified) as the indicator.
  >
  >Example for a bibliographic record:
  >
  >650 _ 0 $a Feminism
  >650 _ 7 $a Feminism $2 sao
  >650 _ 7 $a Feminism $2 barn
  >
  >The first example above is the LCSH term. The other two terms are from sao (controlled Swedish subject heading system) and barn (Swedish children subject heading system). These three are using the same TOPIC_TERM Feminism, but they belong to different thesaurus.

### MARC Bibliographic data support

- [[21705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21705) Map copyrightdate to both 260/264c by default for new MARC21 installations

  >This enhancement adds a default mapping from 264c to biblio.copyrightdate for MARC21. Previously, it was only mapped to 260c. Now it is mapped to both. 
  >**This only affects new installations. For current installations, you need to add it manually through Administration > Koha to MARC mapping.
- [[25449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25449) Make itemtype mandatory by default
- [[30430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30430) UNIMARC XSLT : displaying field B_214

### MARC Bibliographic record staging/import

- [[27421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27421) Porting tools/stage-marc-import.pl to BackgroundJob

### Notices

- [[19966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19966) Add ability to pass objects directly to slips and notices
- [[26689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26689) Monetary accounts notices should be definable at the credit_type/debit_type level

  >**Sponsored by** *PTFS Europe*
  >
  >This enhancement allows end users to define their account notices (print receipt and print invoice for example) at the debit type and credit type level.
  >
  >Simply add a new notice with code 'DEBIT_your_debit_type_code' or 'CREDIT_your_credit_type_code' to the notices and we will pick that over the existing default 'ACCOUNT_DEBIT' and 'ACCOUNT_CREDIT' notices.
- [[27265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27265) process_message_queue.pl cron should be able to take multiple types as a parameter

  >This patch adds the ability to specify several types or letter codes when running the process_message_queue script. This allows libraries to consolidate calls when some message types or letter codes are scheduled differently than others
- [[31626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31626) Add letter ID to the message queue table
- [[31714]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31714) Add a more generic way to print patron slips

  >This is a first step towards drying out our slip printing code.  We add a new, modern, controller script that accepts any notice template to be passed to it for printing.
  >
  >Next steps would be to start migrating some of the old slips to use this controller and drop their respective controller scripts.

### OPAC

- [[7960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7960) Choice to not show the text labels for item types

  **Sponsored by** *Catalyst*

  >This enhancement adds the class "itypetext" around item type descriptions so they can be hidden with CSS. To hide the descriptions, add .itypetext { display:none; } to the OPACUserCSS (for the OPAC) or IntranetUserCSS (for the staff interface) system preferences.
- [[8305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8305) Add an icon for iOS home screens
- [[8948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8948) MARC21 field 787 doesn't display
- [[22456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22456) Allow patrons to cancel their waiting holds

  **Sponsored by** *Montgomery County Public Libraries*

  >This enhancement allows patrons to cancel holds waiting for pickup from their account (summary > holds > request cancellation button), instead of having to contact the library (for example, by email, phone, or in person).
  >
  >This is enabled by setting rules by library, patron type, and item type. The rules are set from a new "Default waiting hold cancellation policy" section under Administration > Patrons and circulation > Circulation and fines rules.
  >
  >Cancellation requests are listed in a new tab "Holds with cancellation requests" under Circulation > Holds > Holds awaiting pickup.
- [[23538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23538) Email library when new patrons self register

  **Sponsored by** *Catalyst*

  >This enhancement allows libraries to receive notifications when patrons self-register.
  >
  >This is enabled using the new system preference EmailPatronRegistrations (options are: none, email address of library, EmailAddressForPatronRegistrations, and KohaAdminEmailAddress) and a new notice (OPAC_REG).
  >
  >To use a specific email address for notifications, use the new system preference EmailAddressForPatronRegistrations.
  >
  >If verification is required for self-registrations (when PatronSelfRegistrationVerifyByEmail is enabled), then notifications are only sent to the library once the registration is confirmed.
- [[29144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29144) Move branches.opac_info to AdditionalContents allowing multi language

  >This reports moves the contents of column branches.opac_info to a HTML block under Additional contents, identified by the new location OpacLibraryInfo.
  >This allows translation of this block too.
- [[29897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29897) Display author identifiers for researchers

  **Sponsored by** *Orex Digital*

  >This new enhancement adds the capability to list the different identifiers of authors. It is helpful for research publications for instance.
  >It will add a new "Author identifiers" tab on the detail page (OPAC) of a bibliographic record, with the list of the authors and their identifiers.
  >On the detail page of the authority record, the same identifier list will be displayed.
  >The authority must have a 024$a (identifier) and 024$2 (source).
- [[29922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29922) Group of libraries are now displayed in alphabetical order

  >This fixes the display of library groups in the advanced search (Groups of libraries) for the OPAC and staff interface so that they correctly sort in alphabetical order. Before this:
  >- OPAC: were sorted in the order library groups were added, group names with diacritics and umlauts (such as Ä or À) came last (after something starting with Z)
  >- Staff interface: were sorted correctly, but had the same issue as the OPAC for group names with diacritics and umlauts
- [[30036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30036) Add XSLT for authority results view in OPAC

  >This enhancement enables the use of custom XSLT stylesheets for displaying OPAC authority search results.
- [[30195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30195) Suggestion form in OPAC should use ISBN to FindDuplicate

  **Sponsored by** *Steiermärkische Landesbibliothek*
- [[30508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30508) Do not display OPAC message about block from holds when OPACHoldRequests is disabled
- [[30566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30566) Incorporate link handling in OPAC's biblio-title include

  >Output of titles in the OPAC was centralized into an include file (biblio-title), but unlike the staff interface this didn't include the option of adding a link to the default bibliographic view. This enhancement provides that option. It also updates OPAC pages where the biblio-title include was previously wrapped in an anchor tag, to add a link parameter: [% INCLUDE 'biblio-title.inc' link=> 1 %]
- [[30678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30678) Add OCLC_NO as option to OPACSearchForTitleIn

  >This enhancement to the OPAC detail page allows you to search WorldCat using the OCLC number. (Example: add an entry to 035$a (such as (OCoLC)62385712) and use {OCLC_NO} in the OPACSearchForTitleIn system preference.)
- [[30880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30880) Expand OPACResultsUnavailableGroupingBy to have a 'branch only' option

  **Sponsored by** *Chartered Accountants Australia and New Zealand*
- [[30927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30927) Improve formatting or iCal files for checkout due dates
- [[31064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31064) Local login is difficult to style using CSS
- [[31217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31217) Fix Coce JavaScript to hide single-pixel cover images in the OPAC lightbox gallery

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*
- [[31294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31294) Article requests: Mandatory subfields in OPAC don't show they are required
- [[31605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31605) Improve style of OPAC suggestions search form
- [[31634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31634) Add part_number and part_name in OPAC result browser

  >This enhancement adds the title's part number and part name in the OPAC result browser.
- [[31635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31635) Empty title for current result in OPAC results browser's tooltip on paging
- [[31672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31672) Remove 'Your' from tab descriptions in OPAC patron account

### Packaging

- [[21366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21366) Add Plack reload

### Patrons

- [[7660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7660) Enhanced messaging preferences are not set when creating a child patron from the adult
- [[10950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10950) Add preferred pronoun field to patron record

  >This adds a new free text field 'pronouns' to the patron record. The pronouns also display prominently in the brief patron information section on the left side of the patron account pages.
- [[20439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20439) SMS provider sorting
- [[21978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21978) Add middle name field

  **Sponsored by** *Cheshire Libraries*

  >This adds a new free text field 'Middle name' to the patron record.
- [[29971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29971) Remember selections across patron search pages

  >This enhancement to patron search remembers selections across multiple pages of search results and multiple different searches. The selected patrons can be added to a patron list or submitted for merging. Selections can be cleared manually and are automatically removed upon logout. Previously, selections were only remembered for the current page of search results.
- [[30646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30646) Add option to send WELCOME notice for new patrons added at first login via LDAP/SAML

  >When LDAP or Shibboleth are used to create user accounts on first login, the WELCOME notice can be send automatically to the new users. This requires adding the new configuration option <welcome>1</welcome> to the respective configuration files.

### Plugin architecture

- [[31894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31894) Extend hold hooks with more actions

  >This patch adds three more hooks to the existing "after_hold_action", extending it to handle the different found values.
  >
  >* "transfer" when a hold calls "set_transfer()" (found=T)
  >* "waiting" when a hold calls "set_waiting()" (found=W)
  >* "processing" when a hold calls "set_processing()" (found=P)
- [[31895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31895) New account hook when adding credit

  >This patch adds a new hook "after_account_action" with the action "add_credit". This is triggered when a credit is added via for example PAYMENT or WRITEOFF.
- [[31896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31896) New recall hook when adding recall

  >This adds a new hook "after_recall_action" with the action "add".

### REST API

- [[22678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22678) Set 'Koha::Logger' as the default mojo logger for the REST API
- [[26635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26635) Expand coded values in REST API call

  **Sponsored by** *Virginia Polytechnic Institute and State University*
- [[30923]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30923) OAuth2 implementation is not experimental

  >This enhancement removes the [EXPERIMENTAL] text from the RESTOAuth2ClientCredentials system preference description. OAuth2 has been in use by third parties to securely interact with Koha since its introduction in 2018.
- [[31128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31128) Add effective_not_for_loan_status to API item objects
- [[31555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31555) Getting holds via REST API needs edit_borrowers permission

  **Sponsored by** *Koha-Suomi Oy*

### Reports

- [[29579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29579) Show saved SQL report ID in database query

  >This enhancement shows a saved SQL report's ID in the database process list (from example, "/* saved_sql.id: 123 */). This can help when troubleshooting reports that are causing issues, such as taking too long to run or taking up too many system resources.

### SIP2

- [[20058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20058) Option to use shelving location instead of homebranch for sorting
- [[31236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31236) Add ability to send custom item fields via SIP using Template Toolkit
- [[31296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31296) Add ability to disable demagnetizing items via SIP2 based on itemtypes

### Searching

- [[23919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23919) Make ISSN searchable with and without hyphen

  >This enhancement enables searching by ISSN without using hyphens and using a space instead of the hyphen. This works in the advanced search (staff interface and OPAC) and item search (staff interface).
  >
  >It is enabled using a new system preference, SearchWithISSNVariations, with two options - "don't search" (the default), and "search".
- [[27136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27136) Add additional languages

  >Adds Cree, Afrikaans and Multiple languages, Undetermined and No linguistic content to our language definitions.
- [[27546]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27546) Add option to search within results on the staff interface

  >This enhancement adds a new input above the search results allowing one to search within the results. The search
  >box will take a query and add it as a limit to the previous search.
- [[30858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30858) Add serial enumeration/chronology to itemsearch.pl

  >This enhancement to the item search in the staff interface adds a serial enumeration/chronology (952$h) column to the search results and export.
- [[31213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31213) When performing a basic search with no results, repeat the search with term quoted

  >This enhancement adds a second, automatic, search with the search terms between quotation marks when a search returns no results.
  >
  >For example, searches with special characters don't work with Elasticsearch.
  >A search for Ivy + Bean will return no results. But a search for "Ivy + Bean" will return results.
  >
  >With this enhancement, if a user searches for Ivy + Bean without quotation marks and gets no results, Koha will automatically search for "Ivy + Bean" and return those results.
  >
  >This targets both Zebra and Elasticsearch, but is more relevant for Elasticsearch.

### Searching - Elasticsearch

- [[27667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27667) Display the number of non-indexed records

  >This enhancement adds information about non-indexed records when using the Elasticsearch search engine on the About Koha > System information page.
  >
  >For example:
  >
  >Records are not indexed in Elasticsearch
  >- Warning 1 record(s) missing on a total of 435 in index koha_kohadev_biblios.record(s).
  >- Warning 1 record(s) missing on a total of 1705 in index koha_kohadev_authorities.
- [[31687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31687) Add see from and see also from tracings in Match index (Elasticsearch, MARC21)

  >This enhancement adds see from and see also from terms for uniform title, chronological term, topical term, geographic name, and genre/form term to the Match index in Elasticsearch for MARC21. These will now be searchable in the Authorities module, by selecting the 'Search all headings' tab.
  >
  >Previously, only see from/see also from for personal names,
  >corporate names, and meeting names were indexed and searchable this way.
- [[31689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31689) Add see from tracings in Match-heading-see-from index (Elasticsearch, MARC21)

  >This enhancement adds fields 430, 448, 450, 451, and 455 to the Match-heading-see-from.
  >
  >Previously, only 400, 410, and 411 were indexed.
- [[31690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31690) Add see from tracings in See-from index (Elasticsearch, MARC21)

  >This enhancement adds fields 450, 451, and 455 to the See-from index for MARC21.
  >
  >Previously, only 400, 410, 411, 430, 447, 448, and 462 were indexed.
- [[31691]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31691) Remove non-existent fields from the See-from index (Elasticsearch, MARC21)

  >This enhancement removes fields from the See-from index that don't exist in MARC21.
  >
  >The existing fields can be found here: https://www.loc.gov/marc/authority/ad4xx.html
- [[31693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31693) Remove non-existent fields from the See-also-from index (Elasticsearch, MARC21)

  >This enhancement removes fields from the See-from index that don't exist in MARC21.
  >
  >The existing fields can be found here: https://www.loc.gov/marc/authority/ad5xx.html

### Searching - Zebra

- [[31614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31614) Add configurable timeout for Zebra connections

### Serials

- [[26377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26377) Clearly label parts of subscription-add.pl that relate to optional item records
- [[26549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26549) Show value of global system preferences on subscription form
- [[29055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29055) Focus on keyword field when subscription biblio search window opens
- [[30039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30039) Add publication date column to serial claims table

### Staff interface

- [[27497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27497) Display Koha version in staff interface home page
- [[27779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27779) Cashup summary 'refunds' should denote what the refund was actioned against
- [[28864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28864) The patron search results in the patron card creator doesn't seem to use PatronsPerPage syspref
- [[29282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29282) Show items.issue and items.renewals in the holdings table on the detail page in the staff interface
- [[30077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30077) Add option for library dropdown in search function for staff interface

  >With the new system preference IntranetCatalogSearchPulldown enabled, you will be able to limit your simple searches in the staff interface by library.
- [[30922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30922) Make the "Relative's checkouts" table configurable by the table settings
- [[31116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31116) Article requests doesn't respect the 'CircSidebar' preference
- [[31162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31162) Add a clear cataloguing module home page

  >This enhancement brings more order to the cataloguing features. We create a new 'Cataloguing' module home page and collect the cataloguing tools into it.
- [[31750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31750) Need more padding in cataloguing
- [[31758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31758) Add 'page-section' to system preferences page
- [[31762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31762) Flat vs 3D or mixed
- [[31763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31763) Add 'page-section' to patron lists page
- [[31764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31764) Add 'page-section' to patron clubs page
- [[31765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31765) Add 'page-section' to import patrons page
- [[31766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31766) Add 'page-section' to notices and slips page
- [[31767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31767) Add 'page-section' to tags page
- [[31770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31770) Add 'page-section' to rotating collections page
- [[31771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31771) Add 'page-section' to stock rotation pages
- [[31773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31773) Add 'page-section' to manage MARC import page
- [[31780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31780) Add 'page-section' to audio alerts ( audio_alerts.tt )
- [[31781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31781) Transferred items table (branchtransfers.tt) needs page-section class
- [[31806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31806) Add 'page-section' to holds page
- [[31811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31811) Add 'page-section' to MARC modification templates pages
- [[31831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31831) Make inactive search options font slightly bigger
- [[31834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31834) Inconsistent table formatting for list of MARC imports
- [[31864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31864) Fix breadcrumbs for each link coming from the new cataloging module home page
- [[31879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31879) Convert mainpage.css to SCSS
- [[31882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31882) Fix page title of pages in the new cataloging module home page
- [[31906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31906) Managed by on basket summary page is misaligned
- [[31911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31911) Headings are inconsistent in rotating collections
- [[31917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31917) Headings don't seem quite right for system preference search
- [[31939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31939) Add page-section to admin > libraries area
- [[31940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31940) Add page-section to admin > library groups area
- [[31941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31941) Add page-section to admin > item types area
- [[31945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31945) Add page-section to admin > patron categories area
- [[31955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31955) Add page-section to additional fields (admin)
- [[32155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32155) Course reserves - instructors display is misaligned on course information page

### System Administration

- [[27519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27519) Normalize Show/Don't show vs Display/Don't display in system preferences

  >This enhancement replaces "Display/Don't display" with "Show/Don't show" for several system preferences to improve terminology consistency and make translation easier. A few preferences were also updated where "Yes/No" and "Show/Hide" were used.
- [[30462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30462) Improve the default display for the background jobs queue management page
- [[30850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30850) Add default mapping for biblio.author to 110$a (MARC21)

  >This enhancement maps 110$a (corporate author in MARC21) to biblio.author in the default framework. 
  >Having the corporate author in biblio.author ensures it will appear wherever the author usually appears in the staff interface.
- [[30937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30937) Add a detail view for libraries
- [[31191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31191) Specify FacetLabelTruncationLength is only for Zebra

  >This enhancement adds a note to the FacetLabelTruncationLength system preference description that it only works with Zebra. When using ElasticSearch, facets are displayed in full.
- [[31264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31264) CalendarFirstDayOfWeek not taken into account when configuring curbside pickups

  **Sponsored by** *Association KohaLa*
- [[31289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31289) Hide article requests column in circulation rules when ArticleRequests syspref is disabled
- [[31475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31475) Group system preferences for suggestions on OPAC tab under new heading
- [[31545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31545) ComponentSortField description is incorrect
- [[31577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31577) Use patron category multi-select for OpacHiddenItemsExceptions system preference
- [[31603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31603) Add search option for plugin page
- [[31730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31730) Link to authorized value interface when an authval is mentioned in preferences
- [[31923]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31923) 'Ignore' tab description is misleading

  >This enhancement modifies the description of the 'Ignore' tab in MARC bibliographic and authority framework administration to add that not only does the 'ignored' subfield not appear in the editor, but the subfield will also be deleted from the record. This is the normal behavior of the 'Ignore' tab, it has not changed. Only the description was updated to reflect it's actual behavior.

### Templates

- [[22276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22276) Add client storage of user-selected DataTables configuration

  >This allows Koha to remember the changes a user has made to the columns settings on a page so they are kept when reloading the page.
- [[26486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26486) Group edit buttons in reports toolbar
- [[27191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27191) Set focus for cursor to category code input box when creating new patron categories

  >This updates the new patron category input form so that the cursor focus is on the category code input field.
- [[27193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27193) Set focus for cursor to patron attribute type code input box when creating new patron attributes
- [[27195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27195) Set focus for cursor to city input box when creating new cities
- [[27436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27436) Set focus for cursor to report name field when creating new SQL report
- [[29723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29723) Add a "Configure table" button for KohaTable tables
- [[30304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30304) Reindent lists template in the staff interface
- [[30309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30309) Convert lists tabs in the staff interface to Bootstrap
- [[30333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30333) Move view actions on acquisitions receipt summary page into menu
- [[30389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30389) Switch to Bootstrap tabs on the page for adding orders from MARC file
- [[30487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30487) Convert checkout and patron details page tabs to Bootstrap
- [[30523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30523) Quiet console warning about missing shortcut-buttons map file
- [[30570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30570) Replace the use of jQueryUI tabs in OPAC templates
- [[30609]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30609) Reindent serial claims template

  >This enhancement updates the serial claims template in the staff interface (claims.tt) so that the indentation is consistent and replaces tabs with spaces. It also adds comments to highlight the markup structure.
- [[30718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30718) Use flatpickr's altInput option everywhere
- [[30786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30786) Capitalization in (Opac)AdvancedSearchTypes

  >This fixes the descriptions for the AdvancedSearchTypes and OpacAdvancedSearchTypes system preferences - sentence case is now used for "..Shelving location..".
- [[30806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30806) Use patron-title.inc in member-flags template

  >This enhancement updates the template for the patron set permissions page (members/member-flags.pl) to use the patron-title.inc include wherever patron names are referenced. This is used to format patron name names consistently, rather than a custom format each time the patron name is referenced. The patron name is now displayed as "Set permissions for firstname lastname (patron card number), instead of "Set permissions for lastname, firstname".
- [[30807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30807) Use patron-title.inc in patron payments pages

  >This enhancement updates the templates for patron accounting - make a payment tab and payment pages (pay and write off options) to use the patron-title.inc include wherever patron names are referenced. This is used to format patron name names consistently, rather than a custom format each time the patron name is referenced. The patron name is now displayed as "Make a payment for firstname lastname (patron card number)" and "Pay charges for firstname lastname (patron card number)".
- [[30859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30859) Upgrade jQuery Validation plugin from v1.19.1
- [[30917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30917) Improve course reserves breadcrumbs
- [[30936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30936) Reindent authority detail template in staff interface
- [[31228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31228) Fix Coce JavaScript to hide single-pixel cover images in both the staff client detail and results pages

  **Sponsored by** *Catalyst*
- [[31397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31397) Set focus for cursor to framework code field when creating a new bibliographic framework

  >This enhancement sets the cursor focus on the first input field (Framework code) for the new bibliographic framework form.
- [[31398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31398) Set focus for cursor to framework code field when creating a new authority type

  >This enhancement sets the focus on the first input field for the new authority type form.
- [[31399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31399) Set focus for cursor to first input field when adding new classification source, filing rule, or splitting rule

  >This enhancement sets the cursor/focus on the first form field when adding an entry on the classification configuration page (includes input forms for new classification source, filing rule, and splitting rule).
- [[31400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31400) Set focus for cursor to matching rule code when adding a new matching rule
- [[31404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31404) Update circulation sidebar to match circulation start page
- [[31414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31414) Set focus for cursor to Name when adding additional fields for baskets or subscriptions
- [[31425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31425) Minor correction to patron categories admin title
- [[31428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31428) Shorten new button text "Configure this table"
- [[31490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31490) Terminology: change "staff client" to "staff interface" in marc-overlay-rules
- [[31528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31528) Replace scss-lint configuration with one for stylelint
- [[31529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31529) Fix errors in SCSS files raised by stylelint
- [[31677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31677) Convert basic MARC editor tabs to Bootstrap
- [[31678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31678) Convert authority editor tabs to Bootstrap
- [[31718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31718) Change the IF ELSE values in MARC subfields structure breadcrumbs to facilitate translation

  >This enhancement changes the strings in the IF ELSE for the framework name in the breadcrumbs on the marc_subfields_structure.pl page. There is no change to the page in English. However, it will facilitate the translation by having complete strings.
- [[31759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31759) Improve styling of tabs
- [[31993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31993) Improve specificity of authorized values breadcrumbs
- [[32014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32014) Tweak style of checkout settings panel
- [[32022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32022) Style tweaks to fieldsets and page-section
- [[32038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32038) Sidebar and footer style improvements on suggestions page
- [[32050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32050) Add 'page-section' to calendar page
- [[32068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32068) Consistent classes for primary buttons: Administration
- [[32070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32070) Consistent classes for primary buttons: Acquisitions
- [[32071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32071) Consistent classes for primary buttons: Catalog
- [[32072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32072) Consistent classes for primary buttons: Cataloging
- [[32073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32073) Consistent classes for primary buttons: Circulation
- [[32085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32085) Consistent classes for primary buttons: Labels
- [[32086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32086) Consistent classes for primary buttons: Patrons
- [[32087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32087) Consistent classes for primary buttons: Course reserves
- [[32088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32088) Consistent classes for primary buttons: Patron card creator
- [[32091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32091) Consistent classes for primary buttons: Reports
- [[32094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32094) Consistent classes for primary buttons: Serials
- [[32096]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32096) Consistent classes for primary buttons: Tools
- [[32097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32097) Consistent classes for primary buttons: Lists
- [[32098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32098) Consistent classes for primary buttons: Clubs and rotating collections
- [[32099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32099) Consistent classes for primary buttons: Assorted templates
- [[32101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32101) Add padding to floating toolbars
- [[32102]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32102) Improve specificity of batch record modification breadcrumbs
- [[32112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32112) Move "Delete selected items" button to new line
- [[32147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32147) Capitalization: E-Resource management should be E-resource management
- [[32165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32165) Add page-section to some catalog pages
- [[32179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32179) ERM is missing page-sections
- [[32182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32182) Replace static tabs markup with Bootstrap
- [[32193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32193) Reindent item details template
- [[32254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32254) Add 'page-section' to various tools pages

### Test Suite

- [[31676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31676) Make db_dependent/Circulation.t tests more robust

  **Sponsored by** *Gothenburg University Library*
- [[31870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31870) Cleaning up t/db_dependent/Context.t

### Tools

- [[6936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6936) Allow to limit on multiple itemtypes when exporting bibliographic records

  >This allows multiple item types to be chosen when exporting
  >bibliographic records from the export catalog tool.
- [[22659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22659) Add 'save and continue' functionality to news and HTML customizations

  >Adds the ability to save & continue when working with either News or HTML customization editors.
- [[27920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27920) Add ability to update patron expiration dates when importing patrons

  >This adds a new option to the patron import from that allows to use the expiration date from the import file or recalculate the patron's expiration date using today's date or the original expiration date as base.
- [[31000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31000) Use of uninitialized value $record_type in string eq

  >This fixes the cause of an error message that appears in the system logs every time that Tools > Catalog > Export data (/cgi-bin/koha/tools/export.pl) is accessed. The error message was "AH01215: Use of uninitialized value $record_type in string eq at /kohadevbox/koha/tools/export.pl line 43.: /kohadevbox/koha/tools/export.pl,...".
- [[31062]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31062) Change description of QOTD tool in tools-home

  >This enhancement changes the name and description of the QOTD tool in order to make them more consistent with the other tool names and descriptions.
- [[31385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31385) Additional contents: Allow searching a CMS page by code in multilanguage env
- [[31553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31553) News item contents field does not always expand when you click on a non-default language

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[14680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14680) When creating orders from a staged file discounts supplied in the form are added
- [[31134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31134) t/Ediorder.t tests failing on 22.05.02
- [[31158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31158) Can't filter suggestions by date ranges
- [[32045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32045) Cannot order multiple from staged file
- [[32166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32166) When adding to a basket from a staged file we may use the wrong inputs
- [[32167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32167) When adding an order from a a staged file without item fields we only add price if there is a vendor discount
- [[32171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32171) Order prices not populated when adding to a basket from a staged file

### Architecture, internals, and plumbing

- [[30876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30876) recalls/recalls_to_pull.pl introduces an incorrect use of ->search in list context
- [[30939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30939) remove_unused_authorities.pl is broken

  >This fixes the ./misc/migration_tools/remove_unused_authorities.pl script so that it now works and deletes unused authority records. Before this, it generated an error message at the first unused authority record and stopped (without deleting any unused authority records).
- [[31133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31133) TestBuilder fragile on virtual fks
- [[31140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31140) TestBuilder.t is failing on item groups modules
- [[31245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31245) Job detail view for batch mod explode if job not started
- [[31274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31274) OPACSuggestionAutoFill must be 1 or 0
- [[31351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31351) Worker dies on reindex job when operator last name/first name/branch name contains non-ASCII chars
- [[31396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31396) OPAC shelf browser broken after removal GetItemsInfo from opac-detail
- [[31437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31437) ModItemTransfer triggers indexing twice
- [[31785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31785) Adding or editing library does not respect public flag
- [[32011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32011) 2FA - Problem with qr_code generation
- [[32119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32119) Cannot add new guarantee
- [[32242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32242) The job has not been sent to the message broker: (Wide character in syswrite ... )

### Authentication

- [[31247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31247) Staff interface 2FA blocks logging into the OPAC
- [[31382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31382) Cannot reach password reset page when password expired
- [[32178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32178) query parameters in check_api_auth lets anyone assume a user id

### Cataloging

- [[29958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29958) Missing dateaccessioned is set to today when storing an item

  >This fixes editing items without an accession date - the accessioned date will remain empty, instead of being updated to today's date.
- [[29963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29963) Date accessioned plugin should not automatically fill today's date on cataloguing screens
- [[30234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30234) Serial local covers don't appear in the staff interface for other libraries with SeparateHoldings

  >This fixes the display of item-specific local cover images in the staff interface. Before this, item images were not shown for holdings on the record's details view page.
- [[30909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30909) Regression, Permanent shelving location is always updated when editing location VIA ADDITEM.PL if both are mapped to MARC fields
- [[31179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31179) Duplicate item is duplicating internal item fields
- [[31223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31223) Batch edit items explodes if plugins disabled
- [[31234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31234) SubfieldsToAllowForRestrictedEditing : data from drop-down menu not stored
- [[31818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31818) Advanced editor doesn't show keyboard shortcuts

### Circulation

- [[28553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28553) Patrons can be set to receive auto_renew notices as SMS, but Koha does not generate them
- [[29012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29012) Some rules are not saved when left blank while editing a 'rule' line in smart-rules.pl
- [[29051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29051) Seen renewal methods incorrectly blocked
- [[29504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29504) Confirm item parts requires force_checkout permission (checkouts tab)
- [[30885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30885) Recall - detail page explosion

  **Sponsored by** *Catalyst*
- [[30886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30886) Recall status cannot be correct on OPAC detail page

  **Sponsored by** *Catalyst*
- [[30907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30907) Remaining incorrect uses of Koha::Recall->item_level_recall
- [[30924]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30924) Fix recalls-related errors in transfers and cancelling actions
- [[30944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30944) Fix single cancel recall button in recalls tab in staff interface and correctly handle cancellations with branch transfers

  **Sponsored by** *Catalyst*

  >This fixes the 'cancel' recall button in several places so that it now works as expected (including the recalls tab in a patron's details section, the recalls section for a record, and the circulation recalls queue and recalls to pull pages). It also ensures a correct cancellation reason is logged when cancelling a recall in transit.
- [[30971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30971) Recalls - log viewer error

  >This fixes an error that occurred when viewing recalls log entries. The error was caused by the renaming of itemnumber, biblionumber, and branchcode attributes.
- [[31395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31395) Checking in non-existent barcodes makes Koha explode
- [[32111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32111) Cannot schedule a pickup at the OPAC

### Command-line Utilities

- [[29325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29325) commit_file.pl error 'Already in a transaction'

  >This fixes the command line script misc/commit_file.pl and manage staged MARC records tool in the staff interface so that imported records are processed.
  >
  >The error message from The command line script was failing with this error message "DBIx::Class::Storage::DBI::_exec_txn_begin(): DBI Exception: DBD::mysql::db begin_work failed: Already in a transaction at /kohadevbox/koha/C4/Biblio.pm line 303". In the staff interface, the processing of staged records would fail without any error messages.
- [[30308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30308) bulkmarcimport.pl broken by OAI-PMH:AutoUpdateSets(EmbedItemData)
- [[30914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30914) cleanup_database.pl --transfers --old-reserves --confirm does not work
- [[32012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32012) runreport.pl should use binmode UTF-8

### Database

- [[30899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30899) Upgrade sometimes fails at "Upgrade to 21.11.05.004"

  >This database revision fixes the one from bug 30449 for table borrower_attribute_types.
- [[30912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30912) Database update fails for 21.12.00.016 Bug 30060

### Fines and fees

- [[24381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24381) ACCOUNT_CREDIT and ACCOUNT_DEBIT slip not printing information about paid fines/fees

### Hold requests

- [[29196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29196) Follow-up to Bug 27068 - Remove unnecessary check
- [[30742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30742) Confusion when placing hold on record with no items available because of not for loan
- [[30794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30794) 'Default checkout, hold and return policy' overrides Unlimited holds in 'Default checkout, hold policy by patron category'
- [[30892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30892) Holds not getting placed
- [[30960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30960) Koha lets you place item-level holds without a pick-up place
- [[31355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31355) Specific item holds table on OPAC only showing 10 items

### Installation and upgrade (command-line installer)

- [[30539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30539) Koha upgrade error "Column 'claimed_on' cannot be null"

  >This fixes an upgrade error that could result in data loss when upgrading from earlier releases to 20.05 (and later releases). It results in the claim_dates for orders being replaced with the date the upgrade was run. (This was caused by an error in the database update for bug 24161 - Add ability to track the claim dates of later orders.)
- [[31673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31673) DB update of bug 31086 fails: Cannot change column 'branchcode': used in a foreign key constraint
- [[32110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32110) Duplicated additional content entries on DBRev 210600016

### Lists

- [[30925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30925) Creating public list by adding items to new list creates a private list

### MARC Bibliographic data support

- [[29001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29001) Subfields attributes are not preserved when order is changed in framework
- [[31238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31238) Unable to save authorised value to frameworks subfields

  **Sponsored by** *Koha-Suomi Oy*
- [[31526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31526) Diff view on manage staged imports page is broken
- [[31869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31869) Unable to save thesaurus value to frameworks subfields

### OPAC

- [[29782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29782) Additional contents: Fix handling records without title or content
- [[31303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31303) Fatal error when viewing OPAC user account with waiting holds
- [[32114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32114) Template error in OPAC search results RSS
- [[32185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32185) Template error in opac-reserve.pl

### Packaging

- [[31499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31499) Add libhttp-tiny-perl 0.076 dependency for ES7
- [[31588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31588) Update cpanfile for new OpenAPI versions

### Patrons

- [[30868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30868) Modifying a patron - page not found error after fixing validation errors where the message is displayed at the top of the page

  >This fixes a page not found error message generated after fixing validation errors when editing a patron (where the validation/error message is shown at the top of the page - below the patron name, but before the Save and Cancel buttons). (This was introduced by bug 29684: Fix warn about js/locale_data.js in 22.05.)
- [[31005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31005) Cannot edit patrons in other categories if an extended attribute is mandatory and limited to a category

  >This fixes an error when a mandatory patron attribute limited to a specific patron category was causing a '500 error' when editing a patron not in that category.
- [[31421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31421) Library limitation on patron category breaks patron search
- [[31497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31497) Quick add: mandatory fields save as empty when not filled in before first save attempt

### REST API

- [[30677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30677) Unknown column 'biblioitem.title' in 'where clause' 500 error in API /api/v1/acquisitions/orders

### Searching

- [[26247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26247) Search terms retained in header search creates UX inconsistency

  >This fixes usability and consistency issues with the staff interface search header. Retaining or clearing search terms between searches is now configurable using two new system preferences - RetainCatalogSearchTerms (for searching the catalog) and RetainPatronsSearchTerms (for check out and searching patrons). Previously, search terms were retained when 1) searching the catalog and then switching to check out, check in, or renew 2) searching  from the check out or search patrons and then switching to check in, renew and search catalog. This then required manually clearing the input field.

### Searching - Elasticsearch

- [[30883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30883) Authorities merge is limited to 100 biblio with Elasticsearch

  >This fixes the hard-coded limit of 100 when merging authorities (when Elasticsearch is the search engine). When merging authorities where the term is used over 100 times, only the first 100 authorities would be merged and the old term deleted, irrespective of the value set in the AuthorityMergeLimit system preference.
- [[31076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31076) Bug 22605 breaks date of publication range search

  >This fixes the date of publication range searching in the staff interface when using Elasticsearch. It was working in the OPAC, but not the staff interface - caused by a regression from Bug 22605 introduced in Koha 22.05. For example: a search for 2005-2010 in the staff interface advanced search will now display the same results as the OPAC.

### Searching - Zebra

- [[31106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31106) Error searching for analytics in detail view

  **Sponsored by** *Theke Solutions*

  >This fixes two issues that affect searching and links for analytics on the detail view pages for records in the staff interface and OPAC:
  >
  >1. Several characters will break Zebra search engine queries, so search terms need to be quoted by the query builder for things to work. Double quotes in titles and used in search terms were not escaped, cuasing issues with results.
  >
  >2. This caused links to and from host records using 773$t and 773$a to fail (not find or display the expected results).
  >
  >Example: Before this was fixed, for a host record with the title 'Uncond"itional?¿' and child records linked using 773$t and 773$a:
  >- the 'Show analytics' link was not displayed in the staff interface and OPAC for the host record
  >- the link from the child record back to the host record ('In' Title of host record (linked)) didn't work.

### Staff interface

- [[31138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31138) DataTables is not raising error to the end user
- [[31749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31749) Detail view broken
- [[31819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31819) Formatting of item form in acq when ordering is broken
- [[31936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31936) Link to advanced search form in acquisitions is missing
- [[32035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32035) "Koha" less prominent in new staff interface

  >This adds "Koha" in front of the version number on the staff interface home page and links it to Koha Community website.
- [[32046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32046) When adding a new records from a staged files, there are style issues
- [[32172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32172) Random biblionumber passed when clicking 'Z3950  SRU/Search' from the search results in staff client

### System Administration

- [[29951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29951) Cannot add splitting rule to classification sources

  >This fixes an error* that was displayed when adding a splitting rule to classifications sources (Administration > Catalog > Classification configuration). 
  >
  >* Clicking 'Add a splitting rule' generates an error page starting "Can't locate object method "subclasses" via package "C4::ClassSplitRoutine" at /kohadevbox/koha/C4/ClassSplitRoutine.pm line 53".
- [[31364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31364) Saving multi-select system preference don't save when all checks are removed
- [[31422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31422) Library limitations might cause data loss when editing patrons

### Templates

- [[31558]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31558) Upgrade of TinyMCE broke image drag and drop
- [[32212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32212) Add separate Bootstrap 4 node module for the OPAC

### Test Suite

- [[31108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31108) rename ./t/00-check-atomic-updates.pl extension to *.t
- [[31992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31992) t::lib::Mocks::Zebra still using old stage for import page
- [[32010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32010) selenium/authentication_2fa.t is failing randomly

### Tools

- [[29828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29828) If no content is added to default, but a translation, news/additional content entries don't show in list
- [[30831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30831) Add unit test for BatchCommitItems
- [[30884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30884) Incomplete replace of jQuery UI tabs in batch patron modification breaks the form sending
- [[30889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30889) Background jobs lead to wrong/missing info in logs
- [[30972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30972) "Replace existing covers" checkbox replaces ALL local covers for a biblio, not only the specific item's covers
- [[31154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31154) Batch item modification fails when "Use default values" is checked

  **Sponsored by** *Koha-Suomi Oy*
- [[31782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31782) Patron autocomplete broken when using js/autocomplete/patrons.js

## Security bugs

### Koha

- [[28739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28739) Objects in notices should restrict  the methods that can be called
- [[30969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30969) Cross site scripting (XSS) attack in OPAC authority search ( opac-authorities-home.pl )
- [[31219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31219) Patron attribute types not cleaned/checked

## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[13614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13614) Replace usage of YUI on basket groups page

  >This enhancement:
  >1. Updates the basket groups interface so that it doesn't rely on YUI to move baskets in and out of groups.
  >2. Removes all YUI assets and many long-obsolete references to YUI-related classes and IDs.
  >
  >For basket groups, you no longer need to drag and drop baskets between columns (which could be a bit fiddly). 
  >
  >The basket group form is now in one column and ungrouped baskets in another. Baskets are listed in sortable tables, and using 'Add to group' and 'Remove' buttons lets you add and remove baskets from the group.
- [[23202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23202) Problems when adding multiple items to an order in acquisitions
- [[27017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27017) Add further defensive coding to EDI Invoice handling
- [[27550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27550) "Duplicate budget" does not keep users associated with the funds

  >Users linked to funds in acquisitions will now be kept when a budget and fund structure is duplicated.
- [[29554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29554) neworderempty.pl may create records with biblioitems.itemtype NULL
- [[29607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29607) addorderiso2709: The stored discount when importing an order from a file is invalid

  >This fixes how the discount amount for an order is stored and shown when an order is added to a basket using "From staged MARC records". The discount amount was incorrectly stored in the database and shown incorrectly when modifying the order (for example, a 25% discount shown as 0.2500 in the database and .25% on the form). This would result in the order amount changing when modifying an order.
- [[29658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29658) Crash on cancelling cancelled order
- [[29961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29961) Horizontal scroll bar in acquisition z39.50 search should always show
- [[30268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30268) When creating an order from a staged file, mandatory item subfields that are empty do not block form submission
- [[30359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30359) GetBudgetHierarchy is slow on order receive page

  **Sponsored by** *Koha-Suomi Oy*
- [[30658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30658) (Bug 29496 follow-up) CheckMandatorySubfields don't  work properly with select field in serials-edit.tt for Supplemental issue
- [[30938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30938) Fix column configuration to the acquisitions home page

  >This fixes the acquisitions home page to show the column configuration button.
- [[31054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31054) Manual importing for EDIFACT invoices fails with a 500 error page
- [[31144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31144) When modifying an order we should not load the vendor default discount
- [[31367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31367) Display of sub-funds does not include totals of sub-sub-funds on acquisitions home page
- [[31587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31587) Basket not accessible from ACQORDER notice

  >This makes sure that the basket object is passed to the ACQORDER notice in order to allow adding information about the basket and the order lines within it.
- [[31649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31649) Acquisition basket CSV export fails if biblio does not exist
- [[31711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31711) When creating order lines "From a new file" you are no longer redirected to acq after import
- [[31840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31840) Incorrect warning that order total amount exceeds allowed budget when editing existing order

  **Sponsored by** *Waikato Institute of Technology*

  >This patch deducts the current cost of an order if modifying it, so that the current cost isn't counted when checking whether the updated cost will take the order total amount above the allowed budget.
- [[32016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32016) Fix 'clear filter' button behavior on datatable saving their state
- [[32076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32076) Form for editing a basket group is misaligned

### Architecture, internals, and plumbing

- [[12758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12758) Failure when loading or parsing XSLT stylesheets over HTTPS
- [[20457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20457) Overdue and pre-overdue cronjobs not skipping phone notices
- [[25716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25716) Add ability to specify additional options in koha-conf.xml for z3950_responder.pl when using koha-z3950-responder
- [[26648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26648) Prevent internal server error if item attached to old checkout has been removed
- [[27259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27259) HomeOrHoldingBranch is not used in all places
- [[27849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27849) Koha::Token may access undefined C4::Context->userenv
- [[28167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28167) A warning when setting which library to use in intranet and UseCashRegisters is disabled
- [[28375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28375) Inefficiencies in fetching COinS
- [[29184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29184) Warn from chargelostitem when no replacement cost set for item
- [[29871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29871) Remove marcflavour param in Koha::Biblio->get_marc_notes
- [[30262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30262) opac/tracklinks.pl inconsistent with GetMarcUrls for whitespace
- [[30399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30399) Patron.t fails when there is a patron attribute that is mandatory
- [[30409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30409) barcodedecode() should always trim barcode
- [[30468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30468) koha-mysql does not honor Koha's timezone setting
- [[30731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30731) Noise from about script coming from Test::MockTime (or other CPAN modules)
- [[30744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30744) Use RecordProcessor in get_marc_notes to ensure non-public notes do not leak
- [[30813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30813) Refactor TransformMarcToKoha to remove TransformMarcToKohaOneField
- [[30822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30822) BatchCommit does not deal with indexation correctly
- [[30823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30823) Recalls should use 'FILL' in action logs

  **Sponsored by** *Catalyst*

  >This enhancement changes recall fulfillment actions to log with the FILL action, same as holds. It will also update existing recalls FULFILL actions in the database to use the FILL action.
- [[30824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30824) Improve performance of BatchCommitItems
- [[30954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30954) includes/background_jobs_update_elastic_index.inc  must be removed
- [[30974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30974) Job size not correct for indexing jobs
- [[30984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30984) Action logs should log the cronjob script name that generated the given log
- [[31053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31053) Add Context module to Koha/Encryption
- [[31058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31058) Bad import in auto_unsuspend_holds
- [[31145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31145) Add some defaults for acquisitions in TestBuilder
- [[31177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31177) Misplaced import in C4::ILSDI::Services
- [[31196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31196) Key "default_value_for_mod_marc-" cleared from cache but not set anymore
- [[31222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31222) DBIC queries for batch mod can be very large
- [[31288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31288) Check userenv in ->disown_or_delete
- [[31305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31305) Useless "type" parameter passed in detail.tt
- [[31307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31307) already_reserved never used in opac/opac-reserve.pl
- [[31390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31390) Remove noisy warns in C4::Templates
- [[31441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31441) Koha::Item::as_marc_field ignores subfields where kohafield is an empty string
- [[31468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31468) Koha::Logger should prefix interface with 'plack'
- [[31469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31469) log4perl.conf: Plack logfiles need %n in conversionpattern
- [[31473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31473) Test about bad OpacHiddenItems conf fragile
- [[31535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31535) Fix a staff warn or two
- [[31842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31842) admin/branches: DT search generates js error on col.data.split
- [[31871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31871) Due date not shown on items tab
- [[31873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31873) Can't call method "safe_delete" on an undefined value at cataloguing/additem.pl
- [[31889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31889) Insert 952 tags in correct order when embedding items
- [[31920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31920) Unit test t/db_dependent/Holds.t leaves behind database cruft
- [[32151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32151) [WARN] Use of uninitialized value in numeric ne (!=) at C4/Ris.pm line 834.
- [[32154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32154) Missing primary key on erm_user_roles table
- [[32161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32161) ErmEholdingsPackagesAgreement has wrong koha_object_class
- [[32162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32162) erm_eholdings_packages_agreements does not have a primary key
- [[32163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32163) ErmUserRole has wrong koha_object[s]_class
- [[32223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32223) package.json script paths too specific
- [[32224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32224) Add cypress and prettier to the yarn commands
- [[32248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32248) t/00-checkdatabase-version.t should be removed

### Authentication

- [[30842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30842) Two-factor  authentication code should be valid longer

  >This extends the time a two-factor authentication code is valid for, in case it is not entered quickly enough. (Example: wait for the code to change, then enter the previous code - this should still work, but will not work when the code changes again.)
- [[32066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32066) 2FA: User could get stuck temporarily on login screen when disabling pref
- [[32138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32138) OIDC client uses backwards default mapping
- [[32139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32139) "Update on login" setting not set when creating domain from new IdP page
- [[32141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32141) New and edit identity provider UIs inconsistent

### Cataloging

- [[25387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25387) Avoid merge different type of authorities
- [[27683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27683) Bind results of GetAnalyticsCount to the EasyAnalyticalRecords pref
- [[29662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29662) PrefillItem should apply to all subfields when SubfieldsToUseWhenPrefill is null
- [[30250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30250) Configure when to apply framework defaults when cataloguing

  **Sponsored by** *Catalyst* and *Education Services Australia SCIS*

  >This patch adds a system preference ApplyFrameworkDefaults to configure when to apply framework defaults - when cataloguing a new record, when editing a record as new (duplicating), or when changing the framework while editing an existing record, or when importing a record. This applies to both bibliographic records and authority records.
- [[30976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30976) Cover images for biblio should be displayed first
- [[31643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31643) Link authorities automatically requires ALL cataloging and authorities permissions
- [[31646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31646) Focus input by default when clicking on a dropdown field in the cataloguing editor
- [[31682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31682) Silence warn when using automatic linker in biblio editor

  **Sponsored by** *Catalyst*
- [[31724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31724) MARC framework subfield deletion - 'i' added to end of the breadcrumb on confirm deletion page

  >This fixes the breadcrumb when deleting a subfield for a framework. An 'i' was incorrectly added to the end of the breadcrumb on the deletion confirmation page, for example: ... > Confirm deletion of subfield bi
- [[31863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31863) Advanced cataloging editor no longer auto-resizes
- [[31876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31876) Capitalization: Click to Expand this Tag
- [[31877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31877) Capitalization: Delete this Tag and Repeat this Tag
- [[31881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31881) Link in MARC view does not work
- [[31987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31987) Update plugin unimarc_field_110.pl fields
- [[32188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32188) Only show template controls above item form if templates have been defined

### Circulation

- [[22115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22115) Table of checkouts doesn't respect CurrencyFormat setting
- [[25426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25426) Allow return policy to be selected via syspref and not just home library

  >This enhancement adds a new system preference, CircControlReturnsBranch. Previously circulation rules for return policies always used the item's home library. This new preference allows choosing between the item's home library, the item's holding library, and the logged in library when selecting the return policy from the circulation rules.
- [[26626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26626) When checking in a hold that is not found the X option is 'ignore' and when hold is found it is 'cancel'
- [[29050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29050) Add punctuation in Unseen Renewals message

  **Sponsored by** *Catalyst*
- [[29792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29792) Transfers created from 'wrong transfer' checkin are not sent if modal is dismissed
- [[30337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30337) Holds to pull ( pendingreserves.pl ) ignores holds if priority 1 hold is suspended
- [[30447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30447) pendingreserves.pl is checking too many transfers
- [[30755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30755) auto_too_soon should not be counted as an error in autorenewals

  >This patch alters the way errors/successes are counted in auto renewals. Prior to this patch, using [% error %] in a template would provide a count of all items not renewed, even if 'too_soon'
  >
  >After this patch [% error + results.auto_too_soon %] will provide the same count, or you can get a count of each error  in the results variable
  >
  >e.g.
  >Some items were not renewed:
  >[% FOREACH key in results.keys %]
  >    [% results.$key %] item(s) were not renewed for reason [% key %]
  >[% END %]
- [[31080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31080) Block adding the bundle item to its own bundle
- [[31083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31083) Part name (245$p) breaks item bundle detail view
- [[31085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31085) The return claims table no longer reloads on resolution
- [[31087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31087) Undefined notes in returns claims get stringified to 'null'
- [[31120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31120) Items will renew for zero ( 0 ) days if renewalperiod is blank/empty value
- [[31129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31129) Number of restrictions is always "0" on the "Check out" tab
- [[31192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31192) Checking in an unkown barcode causes error
- [[31343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31343) DataTables error on waitingreserves.tt
- [[31447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31447) "Please confirm checkout" message uses patron's home library not holds pick up library

  **Sponsored by** *Koha-Suomi Oy*
- [[31728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31728) Duplicate claims modal template markup
- [[31903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31903) Article requests: Edit URLs link missing in the New tab

### Command-line Utilities

- [[30781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30781) Use of uninitialized value $val in substitution iterator at /usr/share/koha/lib/C4/Letters.pm line 665.
- [[30788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30788) Argument "" isn't numeric in multiplication (*) at /usr/share/koha/lib/C4/Overdues.pm
- [[30893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30893) Typo: update_patrons_category.pl fine(s)

  >This updates the help text for the update patrons category cronjob script (misc/cronjobs/update_patrons_category.pl). It changes the full option names and associated information for -fo (--fineover to --finesover) and -fu (--fineunder to --finesunder), as well as some minor formatting and text tidy ups.
- [[31239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31239) search_for_data_inconsistencies.pl fails for Koha to MARC mapping using biblio table
- [[31282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31282) Broken characters in patron_emailer.pl verbose mode

  >This fixes the patron_emailer.pl script (misc/cronjobs/patron_emailer.pl) so that non-ASCII characters in notices display correctly.
- [[31299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31299) Duplicate output in search_for_data_inconsistencies.pl
- [[31325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31325) Fix koha-preferences get
- [[31356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31356) Itiva outbound script doesn't respect calendar when calculating expiration date for holds
- [[32093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32093) cleanup_database.pl bg-jobs parameter should be bg-days

### Course reserves

- [[30840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30840) Add support for barcode filters to course reserves

### Database

- [[30472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30472) Field borrower_relationships.guarantor_id should be marked as NOT NULL
- [[30483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30483) Do not allow NULL in issues.borrowernumber and issues.itemnumber
- [[30490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30490) Adjust foreign key for parent item type
- [[30497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30497) Constraint old_reserves_ibfk_4 should be SET NULL instead of CASCADE

### Documentation

- [[27315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27315) The man pages for the command line utilities do not display properly
- [[31465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31465) Link system preference tabs to correct manual pages

### ERM

- [[32181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32181) ERM - Cannot filter by expired when adding an agreement to EBSCO's package

### Fines and fees

- [[29987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29987) Manual credits are not recorded for a register

  >This fixes the recording of manual credits for patrons so that these transactions are now included in the cash summary report for a library. When adding a manual credit, there are now fields for choosing the transaction type and cash register.
- [[30458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30458) Librarian ( manager_id ) not included in accountline when using "Payout amount" button
- [[30567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30567) Create manual invoice with FR currency format show the incorrect format

  >This fixes the price formatting when CurrencyFormat = FR. When adding a manual invoice, the amount input field was shown with a comma for debit types with default amounts, but it should be a decimal point. (For input fields we always use the decimal point and the display format uses the decimal separator defined by CurrencyFormat.)
- [[31036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31036) Cash management doesn't take SIP00 (Cash via SIP2) transactions into account

  >This fix adds the last missing piece for cash management when involving transactions via a SIP client.
  >
  >We now understand that a SIP00 coded transaction is equal to 'CASH' in other register environments. This means we treat it as such in the cashup system and also that we now require a register for cash transactions.
  >
  >WARNING: This makes register a required configuration field for SIP devices when cash registers are enabled on the system.
- [[31513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31513) NaN errors when using refund and payout with CurrencyFormat = FR

### Hold requests

- [[12630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12630) Prioritizing "Hold starts on date" -holds causes all other holds to be prioritized as well!
- [[19540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19540) opac-reserve does not correctly warn of too_much reserves
- [[23659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23659) Allow hold pickup location to default to item home branch for item-level holds

  >This patch adds a new system preference 'DefaultHoldPickupLocation'
  >
  >This preference will allow the library to determine which library is the default for pickup location dropdowns while placing holds in the staff client. The options are logged in library, homebranch, or holdingbranch
  >
  >Previously the behavior was inconsistent, and varied between versions. Libraries may need to adjust this preference after upgrade to mirror their expected workflow
- [[28529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28529) Item type-constrained biblio-level holds should honour max_holds as item-level do
- [[29071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29071) HoldsSplitQueueNumbering not set for new installs
- [[29102]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29102) DecreaseLoanHighHolds will decrease loan period if patron has an 'unfound' hold
- [[29389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29389) Add holding branch to holds queue report
- [[30213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30213) Hide Delete (aka Priority) column when user only has place_hold permission
- [[30828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30828) Remove unused variable in placerequest.pl
- [[30935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30935) Holds to pull shows wrong first patron
- [[31086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31086) Do not allow hold requests with no branchcode
- [[31112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31112) Able to renew checkout when the number of holds exceeds available number of items

  >When AllowRenewalIfOtherItemsAvailable is set to Allow it now correctly takes into account all the holds instead of just one per patron.
- [[31518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31518) Hidden items count not displayed on hold request page
- [[31540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31540) Holds reminder cronjob should consider expiration date of holds, and not send notices if hold expired
- [[31575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31575) Missing warning for holds where AllowHoldPolicyOverride can be used to force a hold to be placed
- [[31808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31808) When placing a hold patron name is not displaying correctly
- [[31963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31963) Only show hold fee message on OPAC and charge hold fee if HoldFeeMode conditions are true as described in the system preference

  **Sponsored by** *Horowhenua Libraries Trust*

  >When HoldFeeMode is set to not_always or "only if all items are checked out and the record has at least one hold already", Koha will unexpectedly show a hold fee message and charge a hold fee if at least one of those conditions are met. 
  >
  >This patch fixes the behaviour so that a hold fee message is only shown, and hold fee only charged, if all items on the record are checked out, AND the record has at least one hold already - both of these conditions must be met, as the system preference implies.

### I18N/L10N

- [[28707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28707) Missing strings in translation of sample data
- [[30517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30517) Translation breaks editing parent type circulation rule
- [[30958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30958) OPAC Overdrive search result page broken for translations

  **Sponsored by** *Melbourne Athenaeum Library, Australia*
- [[30991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30991) [% ELSE %]0[% END %] will break translations if used for assigning variables

  **Sponsored by** *Catalyst*
- [[30992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30992) Hard to translate single word strings
- [[31292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31292) Untranslatable string in sample_notices.yaml
- [[31738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31738) Unstranslatable string in checkouts.js for recalls

### ILL

- [[28634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28634) ILL partner request notices are attached to the request creator rather than the partner recipient
- [[30890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30890) ILL breadcrumbs are wrong

### Label/patron card printing

- [[30837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30837) Fix table width on 'Print summary'

  >This fixes the width of the table for the print summary so that it fits the width of the page.
- [[31137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31137) Error editing label template
- [[31352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31352) Terminology: Borrower name

  **Sponsored by** *Catalyst*

  >This updates the table heading name from "Borrower name" to "Patron name" when adding a new batch in the patron card creator.

### Lists

- [[32237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32237) Batch delete records "no record IDs defined"

### MARC Authority data support

- [[19693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19693) Update of an authority record creates inconsistency when the heading tag is changed
- [[29260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29260) UNIMARC 210a is reported to Author (meeting/conference) when upgrading an authority through Z3950

  >This fixes UNIMARC authority editing when using 'Replace record via Z3950/SRU search'. When pre-populating the search form the value of 210$a (Authorized Access Point - Corporate Body Name) now goes into the Author (corporate) search form field instead of Author (meeting / conference).
- [[29333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29333) Importing UNIMARC authorities in MARCXML UTF-8 breaks the encoding
- [[29434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29434) In UNIMARC instances, the authority finder uses MARC21 relationship codes

  >This fixes the values displayed for the relationship codes in the authority finder 'Special relationships' drop down list in UNIMARC catalogs - UNIMARC values are now displayed, instead of MARC21 values.
- [[30025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30025) Split BiblioAddsAuthorities into 2 preferences

  >This patch splits the system preference BiblioAddsAuthorities into two new system preferences that more clearly define what the settings do:
  >1- RequireChoosingExistingAuthority: this preference indicates whether a cataloger must choose from existing authorities, or if they can enter free text into controlled fields
  >2- AutoLinkBiblios: this preference determines whether Koha will attempt to link a new record to existing authorities upon saving. In conjunction with the existing preference, AutoCreateAuthorities, unmatched headings will either be linked to a new authority, or remain uncontrolled
- [[31660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31660) MARC preview for authority search results comes up empty

### MARC Bibliographic record staging/import

- [[26632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26632) BatchStageMarcRecords passes a random number to AddBiblioToBatch / AddAuthToBatch
- [[30738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30738) Forked CGI MARC import warnings are not logged
- [[30789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30789) Improve performance of AddBiblio when importing records with many items
- [[31269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31269) DataTables error when managing staged MARC records

### Notices

- [[28355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28355) Add warning note about Email SMS driver option for SMSSendDriver

  >This updates the text for the SMSSendDriver system preference. The Email SMS driver option is no longer recommended unless you use a dedicated SMS to Email gateway. Many mobile providers offer inconsistent support for the email to SMS gateway (sometimes it works, and sometimes it doesn't), which can cause frustration for patrons.
- [[29409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29409) Update for bug 25333 can fail due to bad data or constraints
- [[30838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30838) to_address is misleading for SMS transports
- [[31122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31122) Terminology: Replace & with and for Notices & slips

  >This updates occurrences of 'Notices & slips' with 'Notices and slips', as per the terminology guidelines.
- [[31170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31170) Capitalization: Overdue Item Fine Description
- [[31281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31281) Overdue notices reply-to email address of a branch not respected
- [[31743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31743) Cannot change my notice language when EnhancedMessagingPreferencesOPAC is off

### OPAC

- [[20207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20207) Anonymous suggestions show in OPAC even when OPACViewOthersSuggestions is set to 'Don't show'

  **Sponsored by** *Library of the Natural History Museum Vienna*
- [[30231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30231) Don't display (rejected) forms of series entry in search results
- [[30746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30746) JS error on 'your personal details' in OPAC
- [[30844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30844) The OPAC detail page's browser is limited to the current page of results when using Elasticsearch

  **Sponsored by** *Lund University Library, Sweden*
- [[30847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30847) Cleanup opac-reserve.pl
- [[30918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30918) Non-public note is visible in OPAC in Title Notes tab

  >This fixes the display of nonpublic notes (583$x) in the OPAC. Before this, if the OPAC visibility setting in the framework for 583$x was set not to show, it was still showing.
- [[30989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30989) Tags with some special characters are not encoded right

  >This fixes tags with special characters (such as +) so that the searching returns results when the tag is selected (from the record detail view in the OPAC and staff interface, and from the search results, tag cloud, and list pages in the OPAC).
- [[31069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31069) Did you mean? in the OPAC - links have <span> tags

  >This removes <span> tags incorrectly displayed around the links for options available when 'Did you mean?' is enabled (for example, 'Search also for related subjects').
- [[31146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31146) Minor UI problem in recalls history in OPAC
- [[31186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31186) Search result numbering in OPAC got suppressed
- [[31272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31272) Show library name not code when placing item level holds in OPAC
- [[31331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31331) OPAC suggestions table doesn't sort correctly by suggestiondate in some dateformats
- [[31346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31346) On the OPAC detail page some Syndetics links are wrong
- [[31387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31387) Marking othernames as required via PatronSelfRegistrationBorrowerMandatoryField does not display required label

  >This fixes the patron self-registration form so that the 'Other names' (othernames) field correctly displays the text 'Required' when this is set as required (using the PatronSelfRegistrationBorrowerMandatoryField system preference). Currently, this text is not displayed (however, an error message is displayed when submitting the form).
- [[31463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31463) (Bug 31313 follow-up) Show item order status on opac-detail
- [[31483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31483) Minor UI problem in opac-reset-password.pl
- [[31527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31527) Breadcrumbs for anonymous suggestions are not correct
- [[31531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31531) Some modules loaded twice in opac-memberentry.pl
- [[31654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31654) Hide non-public libraries from MastheadLibraryPulldown

  **Sponsored by** *Steiermärkische Landesbibliothek*
- [[31685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31685) Article request count in table caption of opac-user missing
- [[31775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31775) Show opac_info of single library
- [[31907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31907) Show items as On hold when in processing

### Packaging

- [[29882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29882) Remove unrequired package definitions in list-deps script
- [[31348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31348) Plack stop should be graceful

### Patrons

- [[30026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30026) International phone number not supported for sending SMS
- [[30713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30713) Patron entry should limit date of birth selection to dates in the past

  >This fixes the date of birth field for the patron entry form so that the calendar widget does not let you select a date in the future.
- [[30891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30891) SMS provider shows on staff side even if SMS::Send driver is not set to "Email"
- [[31153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31153) Search bar not visible on recalls history page
- [[31486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31486) Deleting a message from checkouts tab redirects to detail tab in patron account

  >This patch corrects a problem where message deletion was improperly redirecting to the patron delete page when a message is deleted on the circulation page.
- [[31516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31516) Missing error handling for accessing deleted/non-existent club enrollment

  >This adds an error message when viewing enrollments for a non-existent club. Previously, a page with an empty title and table were displayed.
- [[31525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31525) Street number not being accessed correctly on patron search results page

  **Sponsored by** *Catalyst*
- [[31562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31562) Patron 'flags' don't respect unwanted fields
- [[31597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31597) Missing semicolon after try-catch in restrictions.pl

  **Sponsored by** *Koha-Suomi Oy*
- [[31739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31739) Password reset from staff fails if previous expired reset-entry exists

  **Sponsored by** *Lund University Library, Sweden*
- [[31937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31937) Prevent cleanup_database.pl from locking too many accounts

### Plugin architecture

- [[31684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31684) Plugin versions starting with a "v" cause unnecessary warnings

### REST API

- [[29105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29105) Add effective_item_type_id to the API items responses
- [[30780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30780) Librarians with only "place_holds" permissions can not update holds data via REST API

  **Sponsored by** *Koha-Suomi Oy*

  >This enhancement enables librarians with only "place_holds" permissions to cancel, suspend and resume holds using the REST API.
- [[30853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30853) Missing description for 'baskets' in swagger.yaml
- [[30854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30854) Missing description for 'import_record_matches' in swagger.yaml
- [[30855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30855) Rename /import => /import_batches
- [[31104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31104) Pagination generates HTTP "Link:" header which is over 8192 bytes apache's limit

### Reports

- [[21982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21982) Circulation statistics wizard does not count deleted items

  >This patch corrects a bug in the Circulation statistics wizard. Previously, the wizard only looked at existing items to calculate statistics. It now includes transactions made on items that are now deleted.
- [[27045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27045) Exports using CSV profiles with tab as separator don't work correctly
- [[28967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28967) Patrons with no checkouts report shows patrons from other libraries with IndependentBranches
- [[29312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29312) Punctuation: Total number of results: 961 (300 shown) .
- [[31276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31276) Report results are limited to 999,999 no matter the actual number of results
- [[31594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31594) Report results count of shown can be incorrect on last page

### SIP2

- [[12225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12225) SIP does not respect the "no block" flag
- [[29094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29094) Placing holds via SIP2 does not check if a patron can hold the given item

  >This fixes holds placed using SIP2 to check that the patron can actually place a hold for the item.
- [[31033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31033) SIP2 configuration does not correctly handle multiple simultaneous connections by default
- [[31202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31202) Koha removes optional SIP fields with a value of "0"
- [[31552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31552) SIP2 option format_due_date not honored for AH field in item information response

### Searching

- [[11158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11158) Authorities 'starts with'  search returns the same as 'contains' when using ICU

  >This fixes searching authorities when using ICU* so that 'starts with' searching works correctly. Before this, a 'starts with' search would return the same results as 'contains'.
  >
  >Technical details: this adds the "complete field" to the authority "starts with" search so that it uses the untokenized "p" register.
  >
  >(* ICU is a feature of the Zebra search engine that can be configured to make searching with non-latin languages (such as Chinese and Arabic) work correctly.)
- [[15048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15048) Genre/Form (655) searches fail on searches with $x 'General subdivision' subfield values
- [[15187]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15187) Adding 880 Fields to index-list in order to Increase Search for ALL non-latin Scripts

  >This fixes the Zebra search engine when using ICU* so that 880 fields are rewritten as their linked fields and the alternate graphic representation of fields are indexed, in the same way that it works for Elasticsearch. 
  >
  >Example: add 245-01 to 880$6 and 教牧書信 to 880$a - the Chinese characters are now indexed into the title index using the 245 rules.
  >
  >* ICU is a feature of the Zebra search engine that can be configured to make searching with non-latin languages (such as Chinese and Arabic) work correctly.
- [[24127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24127) Improve wording on location drop-down in advanced search in the staff interface

  >This amends the "Shelving location" option in the search option drop-down on the advanced search page in the staff interface to read "Shelving location (code)" to make it more obvious that the LOC authorised value code needs to be used for searching.
- [[27697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27697) Opening bibliographic record page prepopulates search bar text
- [[28372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28372) Use variables for 007 controlfield translations in MARC21slim2intranetResults.xsl
- [[30327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30327) Sort component parts
- [[30865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30865) Koha::Biblio->get_components_query should double quote Host-item search
- [[31252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31252) Advanced search in staff interface should call barcodedecode if the search index is a barcode
- [[31543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31543) MaxComponentRecords link is broken
- [[31847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31847) Add page section to item search results
- [[31967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31967) Search terms retained in header search when only one result

### Searching - Elasticsearch

- [[25375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25375) Elasticsearch: Limit on available items does not work
- [[25669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25669) ElasticSearch 6: [types removal] Specifying types in put mapping requests is deprecated (incompatible with 7)
- [[29048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29048) Incorrect search for linked authority records from authority search result list in OPAC
- [[29561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29561) Remove blank facet for languages

  >This removes blank facets from search results when using Elasticsearch. Currently, this only seems to affect language fields, but could affect any facetable field that contains blank values.
- [[29632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29632) Callnumber sorting is incorrect in Elasticsearch

  >This fixes the sorting of call numbers when using Elasticsearch. Sorting will now work correctly for non-numeric call numbers, for example, E45 will now sort before E7.
- [[30152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30152) Elasticsearch - queries with OR don't work with limits

  **Sponsored by** *Lund University Library, Sweden*
- [[30882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30882) Add max_result_window to index config

  >This updates the number of results set by default in Elasticsearch for the setting "index.max-result-window" from  10,000 to 1,000,000. This can be useful for really large catalogs.
- [[31013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31013) Reserved words as branchcodes cause search error in Elasticsearch
- [[31023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31023) Cannot create new GENRE/FORM authorities when  QueryRegexEscapeOptions  set to 'Unescape escaped'
- [[31537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31537) Elasticsearch - index mapping for 003 control-number-identifier is twice in mappings.yaml

### Searching - Zebra

- [[30528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30528) Limits are not correctly parsed when query contains CCL
- [[30879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30879) Add option to sort components by biblionumber
- [[31532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31532) Zebra search results including 880 with original script incorrect because of Bug 15187

### Self checkout

- [[31488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31488) Rephrase "You have checked out too many items" to be friendlier
- [[31496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31496) SCO slip uses data of patron's home library instead of the SCO staff users's library

### Serials

- [[24010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24010) Number of issues to display to staff accepts non-integer values

  >This adds validation to the subscription entry form to check that the values for these fields are numbers:
  >- Number of issues to display to staff
  >- Number of issues to display to the public
- [[28950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28950) serialsUpdate cron does not mark an issue late until the next issue is expected
- [[29608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29608) Editing numbering patterns does require full serials permission
- [[30973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30973) Serials search wrong body id

### Staff interface

- [[18556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18556) Message "Patron's address in doubt" is confusing
- [[28723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28723) Holds table not displayed when it contains a biblio without title
- [[30471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30471) Typo in circulation rules - lost item fee refund policy
- [[30499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30499) Keyboard shortcuts broken on several pages
- [[30798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30798) Columns Home library and Checked out from in wrong order on table settings for account_fines table

  **Sponsored by** *Koha-Suomi Oy*
- [[31038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31038) Amounts in cashup summary modal no longer properly formatted

  >This fixes the formatting of amounts on the cashup summary modal (it uses the existing format_price JS include to format prices).  For example, the amount for a product was formatted as 15 instead of 15.00.
- [[31039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31039) Rebase issues lead to duplicate JS for cash summary modal printing

  >This fixes a duplicate print dialogue box appearing when printing the cashup summary for cash registers - ins some circumstances when cancelling the print dialogue, it reappeared instead of closing.
- [[31067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31067) Sub-tools permission not applying on intranet-main.tt
- [[31229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31229) Column visibility broken on patron search view
- [[31244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31244) Logout when not logged in raise a 500
- [[31251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31251) "Clear" patron attribute link does not work
- [[31271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31271) "Edit search" always resets search options to keyword
- [[31439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31439) Item count bullet (&bull;) should be easier to style/remove
- [[31565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31565) Patron search filter by category code with special character returns no results
- [[31566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31566) 'Patrons selected' counter doubles on 'Select all'
- [[31601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31601) Materials specified note should include an ID on both the check in and checkout pages
- [[31663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31663) Item not showing transit status on detail page in staff interface
- [[31664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31664) Show pending transfers on catalog details page
- [[31747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31747) Round corners in boxes
- [[31751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31751) Breadcrumb style
- [[31760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31760) Fix contrast of separator in top header in staff client (WCAG)
- [[31774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31774) Add 'page-section' to Manage staged MARC records page
- [[31803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31803) "remove from cart" button displayed even if not in cart
- [[31810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31810) Place hold button should be yellow
- [[31812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31812) Add yellow button to stage imports page
- [[31813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31813) Specify white-space: normal for spans styled as labels
- [[31821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31821) Add page-section to vendor result list (acq)
- [[31822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31822) Add page-section to vendor detail page (acq)
- [[31829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31829) Change password form in patron account is misaligned
- [[31830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31830) Add page-section to budgets and funds table on acq start page (acq)
- [[31835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31835) Add page-section to holds queue
- [[31837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31837) Add page-section to basket summary page
- [[31848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31848) Holds queue: Submit button for filters on the left is closer to nav than to its form
- [[31850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31850) Patron import: welcome email option style as list
- [[31861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31861) Table controls on checkouts table are buttons
- [[31886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31886) No side menu when searching for syspref
- [[31902]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31902) Inconsistent table formatting for 'Existing holds'
- [[31905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31905) Buttons lack spacing on holds
- [[31910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31910) Article request form is misaligned/misformatted
- [[31919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31919) Hovered items in "More" should change background color
- [[31927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31927) Use bigger font-size for bibliographic information on staff details page
- [[31929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31929) On vendor edit page options are not aligned
- [[31952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31952) Sending an empty system preference search breaks layout
- [[31960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31960) Information on job detail view is misaligned
- [[31974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31974) Regression: Bug 31813 incorrectly affected labels in the header search
- [[32002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32002) Make submit button yellow on administration > Did you mean?
- [[32004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32004) Increase font size in top navigation pull downs
- [[32005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32005) Spacing between entries in left side navigation on staff catalog detail page is uneven
- [[32006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32006) Add page-section to local use system preference tab (admin)
- [[32028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32028) Add page-section to various administration pages (part 2)
- [[32122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32122) Wrong permissions check on item circulation alerts
- [[32169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32169) Add page-section to item list on top of batch item edit (tools)
- [[32170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32170) Add page-section to CSV profiles (tools)
- [[32214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32214) Staff interface toolbar - no options when search catalog selected
- [[32241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32241) Add page-section to list of records in batch record modificaton (tool)
- [[32260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32260) Prevent alert when searching patron (autocomplete)
- [[32298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32298) Add page-section to cataloguing search results (cat)

  **Sponsored by** *PTFS Europe*
- [[32299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32299) Add page-section to Z39.50/SRU results (cat)

### System Administration

- [[30585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30585) Table settings for course_reserves_table are wrong due to lack of "Holding library" option
- [[30862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30862) Typo: langues
- [[30864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30864) Patron category form - no validation for password expiration field

  >This adds validation to the "Password expiration" field on the patron category form. If letters or other characters were entered, there was no error message. If what was entered was not a number, then it was not saved.
- [[31020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31020) PassItemMarcToXSLT only applies on results pages

  >This fixes the note about the PassItemMarcToXSLT system preference so that it is only shown for the OPACXSLTResultsDisplay and XSLTResultsDisplay system preferences - it was appearing in all XSLT system preferences, when it only applies for results pages. (The note is removed from OPACXSLTListsDisplay, XSLTListsDisplay, OPACXSLTDetailsDisplay, and XSLTDetailsDisplay system preferences.)
- [[31117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31117) Cloning standard circulation rules for all libraries show up as from '*'
- [[31214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31214) Regression: subfield code editable in MARC framework editor
- [[31249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31249) update_patrons_category.pl cron does not log to action_logs
- [[31401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31401) Update administration sidebar to match entries on administration start page
- [[31489]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31489) Typo in EnableExpiredPasswordReset description
- [[31619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31619) Cannot select title when setting non-default value for OPACSuggestionMandatoryFields

  >This fixes the OPACSuggestionMandatoryFields system preference so that the title field is visible and marked as mandatory (in red).
- [[31887]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31887) Search on MARC field does not work in Elasticsearch mappings table
- [[31931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31931) Terminology for HoldsSplitQueue - staff client should be staff interface

  >This fixes the description for the HoldsSplitQueue system preference so that it says "In the staff interface, ..." instead of "In the staff client, ...", as per the terminology guidelines.
- [[31976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31976) Incorrect default category selected by authorized values page
- [[31995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31995) build_holds_queue.pl should check to see if the RealTime syspref is on

### Templates

- [[13600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13600) XSLT: 8xx not showing if there is no 4xx
- [[20395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20395) Use Price formatter in more templates (paycollect, request, parcel, smart-rules)
- [[27081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27081) Notes missing from lost items report column configuration when CSV export is active
- [[29671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29671) Dropbox mode is unchecked after check in confirm on item with Materials specified
- [[30384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30384) Reindent template for ordering from a MARC file
- [[30388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30388) Fix some errors in the template for ordering from a MARC file
- [[30629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30629) <span> in title of patron card creator template needs to be removed

  >This removes <span> tags incorrectly displaying in browser page titles for some pages in the staff interface (Tools > Patron card creator > Layouts; Tools > Label creator > Manage > Label batches; Administration > Budgets administration > select a budget > Plan by ...).
- [[30726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30726) Flatpickr's "yesterday" shortcut doesn't work if entry is limited to past dates
- [[30761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30761) Typo: PLease
- [[30762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30762) Terminology: Go to Staff client
- [[30763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30763) Typo: Barcode proceeds bibliographic data
- [[30764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30764) Terminology: Cancelled reserve

  **Sponsored by** *Catalyst*
- [[30766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30766) Typo: Cannot cancel receipt. Possible reasons :
- [[30767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30767) Terminology: Do not forget that the issue has not been checked in yet.

  **Sponsored by** *Catalyst*
- [[30768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30768) Typo: pin should be PIN
- [[30769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30769) Typo: Item typeX:
- [[30770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30770) Terminology: Lost reserve

  **Sponsored by** *Catalyst*
- [[30772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30772) Terminology: Replace instances of "reserve" with "hold"
- [[30773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30773) Standardize spelling i-tive / Itiva

  >This standardizes the spelling used for i-tiva in the staff interface. When modifying notices (Tools > Notices & slips > [select any notice]) the section is now labelled 'Phone ( i-tiva )' - this is now consistent with the table heading used for Tools > Overdue notice/status triggers.
- [[30774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30774) Typo: i %sEdit %sReserve %s
- [[30784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30784) Rephrase OPACMandatoryHoldDates slightly

  >This updates the text for the OPACMandatoryHoldDates system preference. It replaces the URL for the form (opac-reserve) with a description, formats the note similar to other notes, and links to other system preferences mentioned in the description.
- [[30785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30785) Typo in SIP2SortBinMapping
- [[30990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30990) Terminology: DefaultHoldPickupLocation
- [[30994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30994) Typo: item was on loan. couldn't be returned.

  >This updates some error messages for the inventory tool to make them more readable and consistent: punctuation fixed, capitalization made more consistent, and language corrections ("check in" instead of "return").
- [[31040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31040) jsTree image being used outside of jsTree plugin

  >This fixes OPAC templates which had a missing "spinner" image when queries were being performed (such as for OpenLibrary, RecordedBooks, and OverDrive). Previously, they were using an image from the jsTree plugin - this was upgraded (see bug 11873), and the plugin's folder structure was changed. Templates now use /images/spinner-small.gif instead.
- [[31071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31071) Regression: date due removed from staff search results

  >This fixes a regression introduced in Koha 21.11 that inadvertently removed the date due in the staff interface search results.
- [[31141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31141) We can remove 'select_column' from waiting_holds.inc
- [[31246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31246) <span> displayed in 'Additional fields' section
- [[31302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31302) Spelling: You can download the scanned materials via the following url(s):

  **Sponsored by** *Catalyst*
- [[31379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31379) Change results per page text for default
- [[31402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31402) Update tools sidebar to match tools start page
- [[31412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31412) Set focus for cursor to Name when adding a new SMTP server
- [[31420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31420) Managing funds: Labels of statistic fields overlap with pull downs
- [[31435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31435) "Configure this table" appears for non-configurable tables
- [[31530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31530) HTML tags in TT comments in patron-search.inc
- [[31542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31542) Home page links wrong font-family
- [[31559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31559) Staff results page doesn't always use up full available screen width
- [[31625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31625) Reindent tools home and tools sidebar
- [[31653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31653) jQuery upgrade broke search button hover effect
- [[31823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31823) Add page-section to uncertain prices page (acq)
- [[31824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31824) Add page-section to list of pending/received orders (acq)
- [[31826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31826) Add page-section to item form on order receive page (acq)
- [[31827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31827) Add page-section to list to log viewer
- [[31828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31828) Add page-section to list of open invoices on receive shipment page (acq)
- [[31884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31884) In check in page submit button should be yellow
- [[31885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31885) In renew page submit button should be yellow
- [[31888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31888) In Elasticsearch mappings page save button should be yellow
- [[31928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31928) Add page-section to callnumber browser value builder (cat)
- [[31943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31943) Date inputs wider than other inputs
- [[31973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31973) Restore background color to message-style alerts
- [[31986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31986) Add page-section to various administration pages
- [[31991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31991) Restore style of sidebar forms
- [[31996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31996) Make note-style messages consistent with dialogs
- [[32042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32042) Add page-section to catalog's item detail view
- [[32043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32043) Circulation alerts can overlap other elements on smaller screens
- [[32044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32044) Yellow buttons are styled differently in different spots
- [[32108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32108) Change "x" icon to replace patron when scheduling a pickup
- [[32109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32109) Toolbar containing text links lacks spacing
- [[32145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32145) Cancel hold modal confirm/submit button has a white background and text can't be read
- [[32146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32146) Add page-section to course reserves
- [[32148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32148) Buttons must inherit Bootstrap size classes
- [[32158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32158) Specify due date field is very long now
- [[32197]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32197) Add page-section to catalog's stock rotation page
- [[32198]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32198) Add page-section to stock rotation stages list (cat)
- [[32199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32199) Add page-section to various patron pages
- [[32207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32207) Add page-section to some circulation pages
- [[32238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32238) Add page-section to label creator pages
- [[32270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32270) Add page-section to label creator - manage label layouts

  **Sponsored by** *PTFS Europe*
- [[32303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32303) DT pagination on system preference search result
- [[32308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32308) Update Chocolat image viewer CSS to conform to redesign color scheme
- [[32310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32310) Correct CSS in the staff interface which still uses old color scheme

### Test Suite

- [[29860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29860) Useless warnings in regressions.t
- [[30756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30756) Get skip block out of Koha_Authority.t and add TestBuilder
- [[30870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30870) Don't skip tests if Test::Deep is not installed
- [[31139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31139) basic_workflow.t is failing
- [[31201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31201) Pseudonymization.t failing if selenium/patrons_search.t failed before
- [[31593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31593) Remove Test::DBIx::Class from Context.t
- [[31598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31598) Fix random failure on Jenkins for t/db_dependent/Upload.t
- [[31883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31883) Filter trim causes false warnings
- [[32064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32064) Add missing test to template permission calculation
- [[32131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32131) Cypress tests are failing if ERMModule is off
- [[32240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32240) api/erm_users.t fails if checkouts exist
- [[32267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32267) Koha/ERM/Agreements.t is failing
- [[32268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32268) t/db_dependent/XSLT.t is failing randomly
- [[32269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32269) Circulation.t is failing randomly
- [[32304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32304) Fix subtest search_limited and purge in BackgroundJobs.t
- [[32343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32343) Koha/Patron.t is failing randomly

### Tools

- [[28152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28152) Hidden error when importing an item with an existing itemnumber
- [[28290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28290) Record matching rules with no subfields cause ISE
- [[28327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28327) System preference CSVdelimiter special case for tabulation

  >This fixes the CSV export so that data is correctly exported with a tab (\t) as the separator when this format is selected. This was incorrectly using the word 'tabulation' as the separator. (The default export format is set using the CSVdelimiter system preference.) In addition, the code where this is used was simplified (including several of the default reports, item search export, and the log viewer), and the default for CSVdelimiter was set to the comma separator.
- [[30778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30778) ModBiblioInBatch is not used and can be removed
- [[30779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30779) Do not need to remove items from import biblios marc
- [[30903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30903) CSV import of quotes broken

  >This fixes the import of quotes from a CSV file for the Quote of the Day feature.
- [[30904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30904) (bug 24387 follow-up) Modifying library in news (additional contents) causes inconsistencies
- [[30911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30911) Datatables error on course-details.pl after adding a bib-level course reserve
- [[31066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31066) Can't use regex in batch modification on fields associated with a plugin
- [[31204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31204) Edit dropdown on results.tt should indicate it is record modification
- [[31211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31211) Check slips and notices for valid Template Toolkit and report errors
- [[31220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31220) Error when attempting to export selected labels as PDF
- [[31373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31373) Notice template validation is missing INCLUDE_PATH
- [[31455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31455) Batch modification tool orders found items by itemnumber
- [[31482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31482) Label creator does not call barcodedecode
- [[31564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31564) Pass start label when exporting single label as PDF
- [[31595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31595) Import patrons tool should not process extended attributes if no attributes are being imported
- [[31609]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31609) JavaScript error on Additional contents main page
- [[31644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31644) MARCModification template fails to copy to/from subfield 0
- [[31752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31752) Alignment of labels in notices is wonky
- [[31754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31754) Improve appearance of behavior of DataTables controls
- [[31891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31891) Regression: show "MARC staging results" with clear link to manage staged batch
- [[32037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32037) Circulation module in action logs has bad links for deleted items
- [[32103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32103) Content field in HTML customizations is too narrow ( CodeMirror )
- [[32104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32104) Console error on additional_content.pl after saving

### Transaction logs

- [[28799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28799) Action logs should capture lost items found

### Web services

- [[30636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30636) ILS-DI shows incorrect availability when not for loan by item type

  >This fixes the ILS-DI web service so that requests where item types are not for loan are correctly returned, the same as for the OPAC. Currently, the item not for loan status is ignored and records are shown as available.

## New system preferences

- ApplyFrameworkDefaults
- AuthorityXSLTOpacResultsDisplay
- AutoLinkBiblios
- AutomaticWrongTransfer
- BundleLostValue
- BundleNotLoanValue
- CircControlReturnsBranch
- ComponentSortField
- ComponentSortOrder
- CurbsidePickup
- DefaultHoldPickupLocation
- ERMModule
- ERMProviderEbscoApiKey
- ERMProviderEbscoCustomerID
- ERMProviders
- EmailAddressForPatronRegistrations
- EmailPatronRegistrations
- EnableItemGroupHolds
- EnableItemGroups
- ExpireReservesAutoFill
- ExpireReservesAutoFillEmail
- HoldsSplitQueueNumbering
- IntranetAddMastheadLibraryPulldown
- ListOwnerDesignated
- ListOwnershipUponPatronDeletion
- NotifyPasswordChange
- OPACAllowUserToChangeBranch
- OPACAuthorIdentifiers
- OverdueNoticeFrom
- PatronRestrictionTypes
- RequireChoosingExistingAuthority
- RetainCatalogSearchTerms
- RetainPatronsSearchTerms
- SavedSearchFilters
- SearchWithISSNVariations
- UseLocationAsAQInSIP
- UseOCLCEncodingLevels
- autoControlNumber
- suggestionPatronCategoryExceptions

## Deleted system preferences

- BiblioAddsAuthorities (replaced by AutoLinkBiblios and AllowManualAuthorityEditing)

## New Authorized value categories

- ERM_AGREEMENT_STATUS
- ERM_AGREEMENT_CLOSURE_REASON
- ERM_AGREEMENT_RENEWAL_PRIORITY
- ERM_USER_ROLES
- ERM_LICENSE_TYPE
- ERM_LICENSE_STATUS
- ERM_AGREEMENT_LICENSE_STATUS
- ERM_AGREEMENT_LICENSE_LOCATION
- ERM_PACKAGE_TYPE
- ERM_PACKAGE_CONTENT_TYPE
- ERM_TITLE_PUBLICATION_TYPE

## New letter codes

- 2FA_OTP_TOKEN
- ACCOUNTS_SUMMARY
- HOLD_CHANGED
- ILL_REQUEST_UPDATE
- NEW_CURBSIDE_PICKUP
- OPAC_REG
- OVERDUE_FINE_DESC
- PASSWORD_CHANGE
- RECEIPT

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (73.7%)
- Armenian (98%)
- Bulgarian (89.4%)
- Chinese (Taiwan) (84.2%)
- Czech (58.7%)
- English (New Zealand) (57.3%)
- English (USA)
- Finnish (92.1%)
- French (91.2%)
- French (Canada) (94.8%)
- German (100%)
- German (Switzerland) (51.2%)
- Greek (50.9%)
- Hindi (100%)
- Italian (94.3%)
- Nederlands-Nederland (Dutch-The Netherlands) (78.1%)
- Norwegian Bokmål (52.8%)
- Persian (55.5%)
- Polish (93.9%)
- Portuguese (74.6%)
- Portuguese (Brazil) (72.6%)
- Russian (73.7%)
- Slovak (60.2%)
- Spanish (100%)
- Swedish (76.9%)
- Telugu (79.8%)
- Turkish (86.5%)
- Ukrainian (68%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.11.00 is

- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Joonas Kylmälä
  - Andrew Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Aleisha Amohia
  - Jake Deery
  - Lucas Gass
  - Séverine Queune

- Packaging Manager: Mason James

- Documentation Manager: David Nind

- Documentation Team:
  - Donna Bachowski
  - Aude Charillon
  - Martin Renvoize
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Victor Grousset

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.00

- [Association KohaLa](https://koha-fr.org)
- Auckland University of Technology
- [BibLibre](https://www.biblibre.com)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)
- [ByWater Solutions](https://bywatersolutions.com)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Chartered Accountants Australia and New Zealand
- Cheshire Libraries
- Education Services Australia SCIS
- Gothenburg University Library
- Horowhenua Libraries Trust
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Library of the Natural History Museum Vienna
- Loughborough University
- Lund University Library, Sweden
- [Martin Renvoize](martin.renvoize@gmail.com)
- Melbourne Athenaeum Library, Australia
- Montgomery County Public Libraries
- [Orex Digital](https://orex.es)
- [PTFS Europe](https://ptfs-europe.com)
- Pymble Ladies' College
- Rijksmuseum, Netherlands
- [Round Rock Public Library](https://www.roundrocktexas.gov/departments/library)
- Steiermärkische Landesbibliothek
- The Research University in the Helmholtz Association (KIT)
- [Theke Solutions](https://theke.io)
- Toi Ohomai Institute of Technology, New Zealand
- Virginia Polytechnic Institute and State University
- Waikato Institute of Technology
- a ByWater Solutions partner

We thank the following individuals who contributed patches to Koha 22.11.00

- Aleisha Amohia (32)
- Pedro Amorim (24)
- Nuño López Ansótegui (1)
- Tomás Cohen Arazi (388)
- Andrew Auld (1)
- Stefan Berndtsson (7)
- Matt Blenkinsop (1)
- Philippe Blouin (1)
- Florian Bontemps (5)
- Jérémy Breuillard (10)
- Alex Buckley (18)
- Colin Campbell (1)
- Kevin Carnes (6)
- Galen Charlton (1)
- Nick Clemens (236)
- David Cook (28)
- Nisha Dahya (1)
- Frédéric Demians (1)
- Paul Derscheid (1)
- Solène Desvaux (12)
- Jonathan Druart (469)
- Marion Durand (4)
- Magnus Enger (3)
- Katrin Fischer (135)
- Géraud Frappier (1)
- Lucas Gass (74)
- Evan Giles (1)
- Isobel Graham (12)
- Victor Grousset (12)
- Thibaud Guillot (3)
- David Gustafsson (2)
- Michael Hafen (1)
- Kyle M Hall (108)
- Frank Hansen (4)
- Mark Hofstetter (1)
- Andrew Isherwood (16)
- Mason James (6)
- Janusz Kaczmarek (4)
- Pasi Kallinen (1)
- Olli-Antti Kivilahti (2)
- Thomas Klausner (3)
- Bernardo González Kriegel (2)
- Joonas Kylmälä (34)
- Owen Leonard (164)
- The Minh Luong (2)
- Julian Maurice (81)
- Tim McMahon (1)
- Matthias Meusburger (1)
- Lucio Moraes (1)
- Agustín Moyano (17)
- David Nind (11)
- Andrew Nugged (2)
- Björn Nylén (7)
- Jacob O'Mara (1)
- François Pichenot (1)
- Séverine Queune (1)
- Johanna Raisa (4)
- MJ Ray (1)
- Martin Renvoize (263)
- Adolfo Rodríguez (1)
- Marcel de Rooy (155)
- Caroline Cyr La Rose (24)
- Andreas Roussos (2)
- Danyon Sewell (2)
- Slava Shishkin (9)
- Maryse Simard (3)
- Fridolin Somers (40)
- Lari Strand (1)
- Arthur Suzuki (1)
- Logan Symons (1)
- Emmi Takkinen (10)
- Lari Taskula (11)
- Mark Tompsett (1)
- Christophe Torin (2)
- Karen Turner (1)
- Michal Urban (2)
- Petro Vashchuk (10)
- Andrii Veremeienko (1)
- Filip Vujičić (1)
- Tosca Waerea (1)
- Shi Yao Wang (9)
- Kris Wehipeihana (2)
- Wainui Witika-Park (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.00

- Athens County Public Libraries (164)
- BibLibre (158)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (135)
- Bibliothèque Universitaire des Langues et Civilisations (BULAC) (1)
- ByWater-Solutions (418)
- Catalyst (32)
- Catalyst Open Source Academy (30)
- Dataly Tech (2)
- David Nind (11)
- Equinox Open Library Initiative (1)
- Göteborgs Universitet (2)
- hofstetter.at (1)
- Hypernova Oy (11)
- Independant Individuals (109)
- jabra.com (1)
- Koha Community Developers (482)
- Koha-Suomi (10)
- KohaAloha (6)
- Libriotech (3)
- lmscloud.de (1)
- MASmedios (1)
- Prosentient Systems (28)
- PTFS-Europe (285)
- Rijksmuseum (155)
- Software.coop (1)
- Solutions inLibro inc (40)
- Tamil (1)
- The City of Joensuu (1)
- Theke Solutions (405)
- ub.lu.se (17)
- Universidad Nacional de Córdoba (2)
- University of Helsinki (3)
- Université Rennes 2 (2)
- ville-roubaix.fr (1)
- wlpl.org (1)
- Xercode (1)

We also especially thank the following individuals who tested patches
for Koha

- Michael Adamyk (1)
- Hugo Agud (1)
- Salman Ali (1)
- Aleisha Amohia (2)
- Pedro Amorim (3)
- Tomás Cohen Arazi (2160)
- Nason Bimbe (1)
- Christopher Brannon (2)
- Anke Bruns (1)
- Alex Buckley (1)
- Emmanuel Bétemps (7)
- Catrina Berka (1)
- Axelle Clarisse (1)
- Nick Clemens (213)
- Rebecca Coert (8)
- David Cook (3)
- Chris Cormack (26)
- Roch D'Amour (1)
- Claude Demeure (2)
- Paul Derscheid (13)
- Solène Desvaux (1)
- Orex Digital (5)
- Jonathan Druart (114)
- Magnus Enger (7)
- Victoria Faafia (1)
- Charles Farmer (1)
- Bouzid Fergani (1)
- Jonathan Field (192)
- Katrin Fischer (688)
- Andrew Fuerste-Henry (73)
- Lucas Gass (56)
- KIT Library Germany (5)
- Victor Grousset (37)
- Amit Gupta (2)
- Géraud Frappier (1)
- Kyle M Hall (436)
- Sally Healey (37)
- Samu Heiskanen (1)
- Mark Hofstetter (1)
- Barbara Johnson (19)
- Thibault Kero (3)
- Thibault Keromnès (3)
- Thomas Klausner (3)
- Lukasz Koszyk (17)
- Bernardo González Kriegel (1)
- Rhonda Kuiper (1)
- Joonas Kylmälä (95)
- Rachael Laritz (3)
- Owen Leonard (211)
- marie-luce (1)
- Julian Maurice (4)
- Kelly McElligott (2)
- Josef Moravec (1)
- David Nind (506)
- Andrew Nugged (5)
- Jacob O'Mara (1)
- Séverine Queune (1)
- Liz Rea (4)
- Martin Renvoize (665)
- Alexis Ripetti (1)
- Jason Robb (1)
- Marcel de Rooy (148)
- Caroline Cyr La Rose (16)
- Lisette Scheer (5)
- Michaela Sieber (9)
- Mika Smith (1)
- Fridolin Somers (44)
- Christian Stelzenmüller (12)
- Myka Kennedy Stephens (1)
- Lyon 3 Team (32)
- Michal Urban (6)
- Petro Vashchuk (4)
- Ben Veasey (1)
- Benjamin Veasey (9)
- George Veranis (1)
- Cab Vinton (1)
- Cédric Vita (3)
- Hammat Wele (2)
- George Williams (2)

We thank the following individuals who mentored new contributors to the Koha project

- Martin Renvoize

And people who contributed to the Koha manual during the release cycle of Koha 22.06.00

- Anke (13)
- Caroline Cyr La Rose (154)
- Katrin Fischer (10)
- David Nind (1)
- Martin Renvoize (10)
- Lucy Vaux-Harvey (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Notes from the Release Manager

From commit 1:, we expressed what this cycle was about:

```
The road of excess
leads to the palace of wisdom;
for we never know what is enough
until we know what is more than enough.

        William Blake.
```

It's been a particularly busy release with several big challenges. I'm grateful for the chance
I had to serve as Release Manager, and for this great community and its members, who invested
their time to make this happen.

Special thanks to:

- Martin
- Nick, Kyle and Lucas
- Katrina
- Owen
- the ByWater folks, for all the hugs and support

all of whom have been promptly available to tackle the different problems we faced through
this vertiginous cycle.

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

Autogenerated release notes updated last on 25 nov 2022 14:22:01.
