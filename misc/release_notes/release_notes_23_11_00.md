# RELEASE NOTES FOR KOHA 23.11.00
30 Nov 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.00 is a major release, that comes with many new features.

It includes 10 new features, 330 enhancements, 573 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## New features & Enhancements

### Acquisitions

#### New features

- [33105](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33105) Add vendor issues
  >For vendors who, in particular, provide electronic services (e.g. eJournal providers) it is useful to be able to record service issues.
  >
  >This new feature allows for recording such details, for example logging login problems, service interruptions and incorrect availability.
  >
  >This is important as evidence when submitting contract negotiations and judging vendor performance against existing contracts.
  >

  **Sponsored by** *Bywater Solutions* and *PTFS Europe Ltd*

#### Enhancements

- [12732](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12732) Allow sorting by basket creation date to the late orders table
  >This enhancement allows end users to sort the late orders table by basket creation date.
- [14092](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14092) Add ability to search on 'all statuses' to orders search
  >This enhancement adds an 'all statuses' option to the status select option in the orders search panel.
  >

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*
- [20755](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20755) Allow separate email configuration for acquisition and serials emails
  >This enhancement adds four new system preferences:
  >- `AcquisitionsDefaultEMailAddress`
  >- `AcquisitionsDefaultReplyTo`
  >- `SerialsDefaultEMailAddress`
  >- `SerialsDefaultReplyTo`
  >
  >These are used to set specific email addresses to send and receive replies to acquisitions orders notices, late orders claims notices and late serial issues claims notices.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [28449](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28449) Link from basket summary to invoice for an order line
  >This adds a new column 'Invoice' to the table of order lines on the basket summary page. It contains the invoicenumber for received order lines and is linked to the invoice if the staff user has the edit_invoices permission.

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [31631](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31631) Optionally choose for tax-exclusive values to be used for calculating fund values (spent, ordered)
  >Public and tertiary libraries in New Zealand can claim tax back on purchases.
  >
  >This enhancement adds a new system preference `CalculateFundValuesIncludingTax`. 
  >
  >When set to 'Exclude' these libraries can input order prices with tax included (so vendor invoice prices - which do contain tax - can be entered directly into Koha).
  >
  >However, the order prices removed from the Koha funds are the tax exclusive values (NZ libraries claim tax back so it should not be removed from their funds).

  **Sponsored by** *Waikato Institute of Technology*
- [32984](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32984) The EDIFACT message that receives an item should be linked on the 'Acquisition details' tab on catalogue details page

  **Sponsored by** *PTFS Europe Ltd*
- [33499](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33499) Make interface URL clickable on vendor details
- [33662](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33662) Add link to order search to acq module navigation

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [33664](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33664) Add ability to cancel order lines in closed baskets
  >With the new system preference `CancelOrdersInClosedBaskets` it's now possible to allow for cancelling order lines from closed baskets. This is useful if something cannot be delivered and you don't want to reopen the basket or use go through the receive shipment process.
  >

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [34169](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34169) Add validation for monetary input fields in acquisition module
  >At the moment Koha can only calculate with amounts that are formatted with a decimal comma, but inputs were not always validated which could lead to errors and wrong amounts. Now entered amounts are validated before saving throughout the acquisitions module.
  >

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [34501](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34501) Patron purchase suggestion table should include the non-public note
  >This adds a new column to the suggestions table for the non-public note.
- [34618](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34618) Add sort 1 and 2 fields to basket in acquisitions
  >This patch adds the option to display Statistic 1 and Statistic 2 columns in basket summary view in acquisitions.
  >The new columns are hidden by default in the updated table configuration.
- [34708](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34708) Ability to modify an order line to increase quantity of ordered item
  >This allows to add additional items to an already saved order lines when items are created on order.

  **Sponsored by** *Pymble Ladies' College*
- [34908](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34908) Sort item types alphabetically by description rather than code when adding a new empty record as an order to a basket

  **Sponsored by** *South Taranaki District Council*

### Architecture, internals, and plumbing

#### Enhancements

- [17499](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17499) Koha objects for messaging preferences

  **Sponsored by** *Koha-Suomi Oy* and *National Library of Finland*
- [29033](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29033) Add C4::Context->multivalue_preference
  >This addition adds a simple way to retrieve pipe delimited list type system preferences as arrays.
- [30825](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30825) Get rid of GetReservesControlBranch
- [31383](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31383) Additional contents: We need a parent and child table

  **Sponsored by** *Rijksmuseum, Netherlands*
- [32478](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32478) Remove Koha::Config::SysPref->find since bypasses cache

  **Sponsored by** *Gothenburg University Library*
- [32496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32496) Reduce unnecessary unblessings of objects in Circulation.pm

  **Sponsored by** *Gothenburg University Library*
- [33041](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33041) Use process_tt in C4::Serial::NewIssue
- [33043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33043) Use process_tt in SIP modules
- [33045](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33045) Use process_tt in C4::Record::marcrecord2csv
- [33046](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33046) Use process_tt in C4::Reports::Guided::EmailReport
- [33170](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33170) Refactor MarcItemFieldsToOrder code to make adding more fields simpler

  **Sponsored by** *ByWater Solutions*
- [33236](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33236) Move C4::Suggestions::NewSuggestion to Koha namespace
- [33245](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33245) Add $patron->is_active
- [33379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33379) virtualshelfcontents.flags seems useless
  >This patch set drops the column virtualshelfcontents.flag which is unused for a long time.
- [33444](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33444) AddRenewal should take a hash of parameters
- [33745](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33745) Speed up Koha::Object attribute accessors
- [33749](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33749) Move Koha::MetadataRecord::stripWhitespaceChars into a RecordProcessor filter
- [33837](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33837) Objects->filter_by_last_update: Does not allow time comparison
- [33843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33843) Use filter_by_last_update in Koha::Notice::Util
- [33940](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33940) Move get_cardnumber_length and checkcardnumber to Koha
- [33947](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33947) Move GetAllIssues to Koha
- [33948](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33948) Replace GetAllIssues with Koha::Checkouts - staff
- [33949](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33949) Replace GetAllIssues with Koha::Checkouts - opac
- [33952](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33952) Add Koha::Biblio->normalized_isbn
- [33953](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33953) Add Koha::Biblio->ratings
- [33954](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33954) Add Koha::Biblio->opac_summary_html
- [33955](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33955) Add Koha::Biblio->normalized_upc
- [33956](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33956) opac-user.pl should use Koha::Biblio->opac_summary_html
- [33958](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33958) Add Koha::Biblio->normalized_oclc
- [33962](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33962) Remove C4::BackgroundJob from process_koc
- [33963](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33963) Remove C4::BackgroundJob
- [34212](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34212) Bug 23336 follow-up code improvements
- [34321](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34321) Tidy skeleton too
- [34336](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34336) Test::DBIx::Class should be removed
- [34414](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34414) Remove DBD::Mock
- [34415](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34415) Remove Test::DBIx::Class from t/EdiTransport.t
- [34441](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34441) Typo: paramater
- [34468](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34468) Add a progress callback to job_progress.js
- [34787](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34787) Typo: gorup
- [34812](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34812) Remove Test::DBIx::Class from Koha.t
- [34825](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34825) Move Letters.t to t/db_dependent
- [34828](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34828) Add Koha::Biblio::Metadata::Extractor* classes
  >This development adds a new class for handling metadata extraction from the metadata registry in Koha. The way it is built provides a good framework for reorganizing the codebase around this area, as well as making it more streamlined to write tests.
- [34887](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34887) Merge Patron.t into t/db/Koha/Patron.t
- [34983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34983) Retranslating causes changes in locale_data.json
- [35001](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35001) Simplify patron->is_active in light of TrackLastPatronActivityTriggers
- [35043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35043) Handling of \t in PO files is confusing
- [35079](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35079) Add option to gulp tasks po:update and po:create to control if POT should be built
- [35103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35103) Add option to gulp tasks to pass a list of tasks
- [35174](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35174) Remove .po files from the codebase

### Authentication

#### Enhancements

- [30843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30843) TOTP expiration delay should be configurable
  >The mfa_range element in the koha-conf.xml file can now be used to change the default "range".

### Cataloging

#### Enhancements

- [26314](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26314) "Volumes: show volumes" showing regardless of whether there are volumes linked to the record
  >This development changes how the _Show volumes_ link is displayed in both OPAC and staff interface.
  >
  >The main change is that the link will only be displayed when it will have results. Currently the link will always display, sometimes leading to no results.
- [29732](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29732) Check alert in cataloguing authorities should be a static message
  >This patch changes the way error form validation error messages are displayed when editing authority records. Instead of a JavaScript alert, errors are now shown on the page itself, with links in the message to take you to the corresponding field. A new "Errors" button in the toolbar allows the user to jump back to the list of errors for easy reference.
- [31132](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31132) Add button to clear the cataloguing authority plugin form
  >This enhancement adds a 'Clear form' link to empty all of the input fields on the authority finder plugin form when cataloguing bibliographic records.

  **Sponsored by** *Education Services Australia SCIS*
- [31477](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31477) Switch icon for inventory
- [32335](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32335) Allow stock rotation items to be moved several stages ahead
- [34275](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34275) Add a button to easily toggle between advanced/basic cataloging editors
  >When the advanced cataloging editor is activated using `EnableAdvancedCatalogingEditor`, there is now a nice toggle button in the upper right corner of the cataloguing module when editing a record that allows to easily switch between the normal and the advanced editor.
- [34657](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34657) Merge cataloging plugins for UNIMARC 123d, e, f, and g
- [35198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35198) Sort database column names alphabetically on automatic item modification page

### Circulation

#### New features

- [9525](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9525) Add option to define float groups and rules for float
  >This feature makes it possible to use library groups for creating floating groups. It adds a checkbox "Is local
  >float group" to the library groups configuration and a new return policy "Item floats by librarygroup" to the circulation conditions.

  **Sponsored by** *Koha-Suomi Oy*
- [29002](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29002) Add ability to book items ahead of time
  >This lays the foundations for item bookings in Koha.
  >
  >An item can be made 'bookable' via the item modification screens; Once at least one item is `bookable`, a new "Place booking" button will appear as an option on the bibliographic record detail page and a "Bookings" tab will be available from the side menu to allow management of bookings.
  >
  >Bookings cannot overlap, and circulation will detect when an item has a booking on it and notify the librarian appropriately.
  >
  >*Note*: There are many further enhancements in the pipeline still to come.

  **Sponsored by** *PTFS Europe*

#### Enhancements

- [8367](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8367) How long is a hold waiting for pickup at a more granular level
  >This enhancement adds a new value to the circulation rules: 'holds pickup period'. It overrides the value set in the `ReservesMaxPickUpDelay` system preference and allows setting different delays for specific item type, patron category, and library combinations.

  **Sponsored by** *Catalyst*
- [21159](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21159) Update item shelving location (952$c) on checkout
  >This enhancement enables libraries to automatically update an item's shelving location using the new system preference `UpdateItemLocationOnCheckout`.
  >
  >It accepts pairs of shelving locations. On checkout the item's location is compared to the location on the left and, like `UpdateItemLocationOnCheckin`, is updated to the location on the right.
  >
  >Special values for this system preference are:
  >* *_ALL_* - used on left side only to affect all items, if it matches, but this is an easier to read option)
  >* *_PERM_* - used on right side only to set items to their permanent location
  >*_BLANK_* - used on either side to match on or set to blank (actual blanks will work) 
  >
  >Syntax highlighting is used in the text area to make it easier to read, as is already possible when checking in items.

  **Sponsored by** *Toi Ohomai Institute of Technology*
- [25393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25393) Create separate 'no automatic renewal before' rule
  >This new circulation rule allows libraries to control the no renewal before behaviour at the auto and non-auto renewals level.
- [25560](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25560) Define itemtype specific rules in the UpdateNotForLoanStatusOnCheckin system preference
  >The `UpdateNotForLoanStatusOnCheckin` system preference is now more configurable: you can define rules to be applied to specific item types upon check-in.
  >
  >Add the item type code followed by a colon, and then on separate lines below define each notforloan value pair with leading spaces. Example:
  >
  >BK
  > -1: 0
  >
  >You can use an _ALL_ wildcard to target all item types. The *_ALL_* wildcard does NOT override item-type specific rules.
  >Example:
  >
  >_ALL_:
  > -1: 2
  >
  >If an item type is not defined in the `UpdateNotForLoanStatusOnCheckin` system preference, and there are no *_ALL_* rules defined, then items of that type will not have their notforloan status change on check-in, irrespective of their current notforloan value.

  **Sponsored by** *Waikato Institute of Technology*
- [28805](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28805) Add on-site option to batch checkout functionality

  **Sponsored by** *Banco Central de la República Argentina*
- [29145](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29145) Allow patrons to have overdue items that would not result in debarment when removing overdue debarments
- [32740](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32740) Add a new option patron home library to OverdueNoticeFrom
- [33398](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33398) Show primary_contact_method when holds are triggered
- [33575](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33575) Add table settings to the holds table for a specific record in the staff interface
- [33725](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33725) Add item's collection code to search results location column in staff interface
- [33876](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33876) item-note-nonpublic and item-note-public are difficult to customize in the checkout table
- [33887](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33887) Automatic checkin should be able to optionally fill the next hold with the returned item
  >This enhancement adds an option for automatic checkins, so that for any holds, it automatically fills the next hold and sends a notification to the patron that a hold is waiting.
  >
  >This option is set using the new system preference `AutomaticCheckinAutoFill`.
- [33945](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33945) Add ability to delay the loading of the current checkouts table on the checkouts page
- [34300](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34300) Add link to place a hold on ordered items in baskets
- [34457](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34457) Add card number to hold details page
- [34529](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34529) Offline circulation should be able to accept userid as well as cardnumber
- [34547](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34547) Add transfer reason to list of checkins
- [34626](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34626) Add waiting since date to holdswaiting patron message
- [34924](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34924) Add ability to send 'final auto renewal notice'
- [34938](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34938) Add collection column to holds ratio report (circ/reserveratios.pl)
- [35068](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35068) Split 'Renew or check in selected items' button in issues table into separate buttons
- [35253](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35253) Make materials specified note easier to customize
  >This enhancement adds classes to the materials specified messages that are displayed when checking out and checking in an item, when there is a value for an item in 952$3.  The new classes available for customizing IntranetUserCSS are mats_spec_label and mats_spec_message.
  >
  >Example CSS customization:
  >```
  > .mats_spec_label { color: white; background: purple;  }
  > .mats_spec_message { color: white; background: green; }
  >```

### Command-line Utilities

#### Enhancements

- [28995](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28995) Add --added_after to writeoff_debts.pl
- [33050](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33050) Allow to specify quote char in runreport.pl
- [33204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33204) Add the ability to filter on patron library for borrowers-force-messaging-defaults.pl
- [33239](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33239) Add the ability to run borrowers-force-messaging-defaults.pl only on a specified message name
- [33698](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33698) Add fields to verbose output of cronjob delete_items.pl
- [33871](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33871) Add where parameter to sitemap.pl
- [34064](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34064) Compare kohastructure.sql against current database using database audit script
- [34213](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34213) False POD for matchpoint option in import_patrons.pl
- [35074](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35074) Add --patron_category to writeoff_debts.pl

### Database

#### Enhancements

- [34328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34328) Add Scottish Gaelic to the advanced search options

### Documentation

#### Enhancements

- [34955](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34955) One Koha manual
  >From 23.11, there is one Koha manual for all Koha versions.
  >
  >Notes are used in the manual to indicate in which Koha version a feature has appeared or changed.
  >
  >Previous manual versions (23.05 and older) are not affected.

### ERM

#### New features

- [34587](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34587) Add a Usage Statistics module to ERM
  >This feature adds the ability to create Data Providers and harvest usage data in COUNTER format. Data Providers (or Data Platforms) are the organisations who provide usage statistics for your electronic resources. This could be a vendor or a platform provider. The data provider record contains information about SUSHI credentials and any COUNTER data which has been harvested from the provider. There is also the ability to create custom reports using this COUNTER data.

  **Sponsored by** *ByWater Solutions* and *PTFS Europe*

#### Enhancements

- [32932](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32932) Re-structure Vue router-links to use "name" instead of urls
- [33417](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33417) Create one standard Toolbar component
- [33480](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33480) Improve display of the vendor aliases in the ERM module
- [34215](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34215) Vue Toolbar component should be more flexible

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34217](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34217) Add missing cypress tests for vendors in agreements and licenses
- [34418](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34418) Allow empty nodes in breadcrumb's elements
- [34448](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34448) ERM should be able to display error messages coming from the API
- [34497](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34497) Vue - Dialog component should allow for confirmation input options
- [34691](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34691) Active link in the menu is not always correctly styled - again

### Fines and fees

#### Enhancements

- [34377](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34377) Accounting transactions should show managing librarian info for credits/debits
- [34985](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34985) Add a quantity field to the manual invoice form
  >This patch add a quantity field and a cost field to the manual invoice form. This allows to automatically multiply the amount. The new fields will display and calculate when the selected debit has a default cost set.

### Hold requests

#### Enhancements

- [17617](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17617) Add the ability of sending a confirmation e-mail to patron when hold is placed
  >When the new system preference `EmailPatronWhenHoldIsPlaced` is activated, a notice will be sent to the patron to confirm their hold has been placed. The notice template used is HOLDPLACED_PATRON.

  **Sponsored by** *Fire and Emergency New Zealand*
- [31692](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31692) Let librarians change item level holds to record level holds when possible
- [33087](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33087) OPACHoldsIfAvailableAtPickup considers On order as available
- [33845](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33845) Hold notes should show when viewing a patron's hold list
- [34160](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34160) Link item barcode to the item more details page from the holds queue viewer

### I18N/L10N

#### Enhancements

- [34098](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34098) Improve translation of some strings in the patron import template
- [34228](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34228) Add translation context to "Managed by"
- [34247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34247) Improve translation of notice character count
- [34433](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34433) 'Custom cover image' in lightbox is untranslatable
- [34834](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34834) Add translation context for "Order"
  >This patch adds context for translators for the word Order, as it is sometimes used as a verb (e.g. to order) and a noun (e.g. an order).
- [35091](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35091) Improve translation of usage statistics country list

### ILL

#### New features

- [30719](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30719) ILL should provide the ability to create batch requests
  >This brings a new ILL request batches feature to the staff interface, allowing staff members to create groups of requests in batches using DOIs or PubmedIDs.
  >
  >The feature requires at least one compatible ILL backend and at least one metadata enrichment plugin (DOI or PubmedID, or both) to be used.
  >
  >Current backends that support batches available:
  >* [ReprintstDesk](https://github.com/PTFS-Europe/koha-ill-reprintsdesk)
  >* [FreeForm](https://github.com/PTFS-Europe/koha-ill-freeform)
  >
  >Current metadata enrichment plugins available:
  >* [Crossref](https://github.com/PTFS-Europe/koha-plugin-api-crossref)
  >* [Pubmed](https://github.com/PTFS-Europe/koha-plugin-api-pubmed)
  >

  **Sponsored by** *UKHSA - UK Health Security Agency* and *PTFS Europe Ltd*
- [33716](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33716) ILL - Allow for a disclaimer stage per request type
  >This introduces a new YAML system preference `ILLModuleDisclaimerByType` allowing for different text and dropdown options to be displayed to user (Staff+OPAC) depending on the request type introduced.
  >
  >The new type disclaimer screen is presented after the create request form has been submitted, but before the request is saved. Thus, only allowing for a request to be placed if the user accepts the disclaimer.
  >
  >The accepted disclaimer option is saved in the database to allow it to be viewed afterwards, as well as the timestamp it was accepted.
  >

  **Sponsored by** *NHS England*

#### Enhancements

- [18203](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18203) Add per borrower category restrictions on placing ILL requests in OPAC
  >When the ILL module is activated, the patron category administration page will include a setting "Can patron place ILL requests in OPAC". For existing installations the flag will be set for all patron categories on update. 
  >

  **Sponsored by** *PTFS Europe Ltd*
- [27542](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27542) It should be possible to cancel an ILL request sent to a partner
- [32911](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32911) Remove ILL partner_code config from koha-conf.xml and turn it into a system preference
  >The partner_code element in the koha-conf.xml was replaced by a new system preference `ILLPartnerCode`.
  >

  **Sponsored by** *PTFS Europe Ltd*
- [33970](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33970) We need a "backend" column in "illrequestattributes" table

### Label/patron card printing

#### Enhancements

- [10762](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10762) Make it possible to adjust the barcode height and width on labels
  >When creating a new layout for the label creator, you can now define the width and height for the printed barcode.
- [28726](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28726) Add sort1 and sort2 to patron card creator patron search

### Lists

#### Enhancements

- [15222](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15222) Add to cart option/other list options missing from OPAC lists display
  >This enhancement adds options to the OPAC for adding titles to the cart or another list, from an existing list. (These options already exist in the staff interface.)

### MARC Authority data support

#### Enhancements

- [27943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27943) MARC21 authorities not support 7XX on display

  **Sponsored by** *Keratsini-Drapetsona Municipal Library, Greece*
- [28166](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28166) Optionally add MARC fields to authority search
  >With the new system preference `AdditionalFieldsInZ3950ResultAuthSearch` it is now possible to display additional information from the MARC record in the authority Z39.50/SRU search result lists.

  **Sponsored by** *Steiermärkische Landesbibliothek*
- [34075](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34075) Allow specifying default tab view for authorities
  >This enhancement adds a new system preference DefaultAuthorityTab that allows libraries to choose which tab is selected first when viewing an authority record.

### MARC Bibliographic data support

#### Enhancements

- [29471](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29471) MARC21: 520 - Summary etc. doesn't display in staff interface
- [34020](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34020) Sequence of MARC 264 subfields different on XSLT result list and detail page
- [34648](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34648) Update MARC21 frameworks to Update 31 (December 2020)
  >This enhancement updates the default MARC21 bibliographic framework to reflect changes brought to the format by Update 31 (Dec. 2020). 
  >
  >Note that this only affects new installations. For existing installations, you can modify your MARC frameworks in Administration > MARC bibliographic framework.
  >
  >Details of Update 31 are on the Library of Congress Website: https://www.loc.gov/marc/up31bibliographic/bdapndxg.html
- [34649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34649) Update MARC21 default framework to Update 32 (June 2021)
  >This enhancement updates the default MARC21 bibliographic framework to reflect changes brought to the format by Update 32 (June 2021). 
  >
  >Note that this only affects new installations. For existing installations, you can modify your MARC frameworks in Administration > MARC bibliographic framework.
  >
  >Changes to the value builder will affect all installations.
  >
  >Details of Update 32 are on the Library of Congress Website: https://www.loc.gov/marc/up32bibliographic/bdapndxg.html
- [34658](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34658) Update MARC21 default framework to Update 33 (Nov. 2021)
  >This enhancement updates the default MARC21 bibliographic framework to reflect changes brought to the format by Update 33 (Nov. 2021). 
  >
  >Note that this only affects new installations. For existing installations, you can modify your MARC frameworks in Administration > MARC bibliographic framework.
  >
  >Changes to the value builder will affect all installations.
  >
  >Details of Update 33 are on the Library of Congress Website: https://www.loc.gov/marc/up33bibliographic/bdapndxg.html
- [34659](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34659) Update MARC21 default framework to Update 34 (July 2022)
  >This enhancement updates the default MARC21 bibliographic framework to reflect changes brought to the format by Update 34 (July 2022). 
  >
  >Note that this only affects new installations. For existing installations, you can modify your MARC frameworks in Administration > MARC bibliographic framework.
  >
  >Details of Update 34 are on the Library of Congress Website: https://www.loc.gov/marc/up34bibliographic/bdapndxg.html
- [34665](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34665) Update MARC21 default framework to Update 35 (Dec. 2022)
  >This enhancement updates the default MARC21 bibliographic framework to reflect changes brought to the format by Update 35 (December 2022). 
  >
  >Note that this only affects new installations. For existing installations, you can modify your MARC frameworks in Administration > MARC bibliographic framework.
  >
  >Details of Update 35 are on the Library of Congress Website: https://www.loc.gov/marc/up35bibliographic/bdapndxg.html
- [34667](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34667) Update MARC21 default framework to Update 36 (June 2023)
  >This enhancement updates the default MARC21 bibliographic framework to reflect changes brought to the format by Update 36 (June 2023). 
  >
  >Note that this only affects new installations. For existing installations, you can modify your MARC frameworks in Administration > MARC bibliographic framework.
  >
  >Details of Update 36 are on the Library of Congress Website: https://www.loc.gov/marc/bibliographic/bdapndxg.html
- [34677](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34677) Update to MARC21 relator terms list
  >This enhancement updates the marc21_relatorterms.yaml file with new relator codes and changes issued by the MARC21 committee in technical notices.
  >
  >It also makes additional updates required so that the codes match the Library of Congress's MARC Code List for Relators at https://www.loc.gov/marc/relators/relaterm.html and https://www.loc.gov/marc/relators/relacode.html
  >
  >Note that this list will only be available in new installations. For existing Koha installations, make the changes to the RELTERMS authorized value category in Administration > Authorized values.
  >
  >The complete list of additions, changes, and removals made:
  >
  >Additions:
  >abr - Abridger
  >adi - Art director
  >anc - Announcer
  >ape - Appellee
  >apl - Appellant
  >ato - Autographer
  >aue - Audio engineer
  >aup - Audio producer
  >bka - Book artist
  >brd - Broadcaster
  >brl - Braille embosser
  >cad - Casting director
  >cas - Caster
  >cop - Camera operator
  >cor - Collection registrar
  >cou - Court-governed
  >crt - Court reporter
  >dbd - Dubbing director
  >dgc - Degree committee member
  >dgs - Degree supervisor
  >djo - DJ
  >edc - Editor of compilation
  >edd - Editorial director
  >edm - Editor of moving image work
  >enj - Enacting jurisdiction
  >fds - Film distributor
  >fmd - Film director
  >fmk - Filmmaker
  >fmp - Film producer
  >fon - Founder
  >his - Host institution
  >isb - Issuing body
  >jud - Judge
  >jug - Jurisdiction governed
  >med - Medium
  >mka - Makeup artist
  >mtk - Minute taker
  >mup - Music programmer
  >mxe - Mixing engineer
  >nan - News anchor
  >onp - Onscreen participant
  >osp - On-screen presenter
  >pad - Place of address
  >pan - Panelist
  >pra - Praeses
  >pre - Presenter
  >prn - Production company
  >prs - Production designer
  >prv - Provider
  >rap - Rapporteur
  >rcd - Recordist
  >rdd - Radio director
  >rpc - Radio producer
  >rsr - Restorationist
  >rxa - Remix artist
  >sde - Sound engineer
  >sfx - Special effects provider
  >sgd - Stage director
  >sll - Seller
  >stg - Setting
  >swd - Software developer
  >tau - Television writer
  >tld - Television director
  >tlg - Television guest
  >tlh - Television host
  >tlp - Television producer
  >vac - Voice actor
  >vfx - Visual effects provider
  >wac - Writer of added commentary
  >wal - Writer of added lyrics
  >wat - Writer of added text
  >win - Writer of introduction
  >wpr - Writer of preface
  >wst - Writer of supplementary textual content
  >
  >Changes:
  >aui - Author of introduction -> Author of introduction, etc.
  >aus - Author of screenplay -> Screenwriter
  >coe - Contestant -appellee -> Contestant-appellee
  >cot - Contestant -appellant -> Contestant-appellant
  >cou - Court-governed -> Court governed
  >dpb -> dbp - Distribution place
  >dgg - Degree grantor -> Degree granting institution
  >orm - Organizer of meeting -> Organizer
  >osp - On-screen presenter -> Onscreen presenter
  >pte - Plaintiff -appellee -> Plaintiff-appellee
  >rcp - Recipient -> Addressee
  >red - Redactor -> Redaktor
  >wde - Wood-engraver -> Wood engraver
  >
  >Removals (deprecated relators):
  >clb - Collaborator
  >-grt - Graphic technician
  >voc - Vocalist

### Notices

#### Enhancements

- [8838](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8838) Digest option for HOLD notice
  >This adds a digest checkbox for "Hold filled" in the messaging preferences settings. When checked, all pickup notices for holds will be collected and send out in a single notice. The letter used is `HOLDDGST`.
- [32986](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32986) Add ability to generate custom slips for patrons
  >This feature makes it possible to create custom slips that will appear in the 'Print' menu in the patron's user account in staff. For this purpose a new module was added to the pull down in the notices and slips tool: 'Patrons (custom slip)'.

### OPAC

#### New features

- [27378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27378) Enable compliance with EU Cookie Legislation via cookie consent
  >This new features adds proper handling of tracking cookies into Koha.
  >
  >An administrator can now enable the option for end users to accept or deny non-essential cookies being stored in their browser using the new system preference `CookieConsent`.
  >
  >Once enabled, the administrator should add their non-essential cookie code into `CookieConsentedJS` as opposed to `OPACUserJS` and `IntranetUserJS`.
  >
  >This will enable a cookie banner to appear at the bottom of the screen with options to allow all, allow essential and view more information.
- [30979](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30979) Add ability for OPAC users to checkout to themselves
  >This new feature adds a new `OpacTrustedSelfCheckout` system preference.  When enabled, OPAC users will see a new checkout option in the header of the page when logged in. This option displays a modal where they can scan barcodes to perform a self checkout.
  >

  **Sponsored by** *European Southern Observatory*

#### Enhancements

- [12421](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12421) No way to get back to search results from overdrive results
- [23798](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23798) Convert OpacMaintenanceNotice system preference to additional contents
- [26824](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26824) Use confirmation modal when removing titles from a list in the OPAC
- [28130](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28130) Show list of serial email alerts a patron subscribed to in patron account in OPAC
  >This enhancement adds an 'Alert subscriptions' page to a patron account to easily view or cancel email alerts the patron has enabled for subscriptions. This new page is available on both the staff interface and the OPAC.

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*
- [29691](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29691) Use template plugins to display OPAC news on homepage
- [31503](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31503) Allow several consent types on the consents tab of OPAC account page
  >This enhancement adds plugin hooks to allow plugin authors to add their own consent requirements.  Consent types introduced will be added to the OPAC account page (Consents tab) using the new `patron_consent_type` hook.
  >
  >A very simple example is given on the Bugzilla report.
- [32711](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32711) Add biblio details to trusted self-checkout modal
- [32721](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32721) Allow specifying UserCSS and UserJS at library level for the OPAC
  >With this feature it's possible to add library specific CSS and JavaScript on the library administration pages.
  >This works in combination with the global '*UserJS' and '*UserCSS' functionality and allows for multiple OPACs with different CSS and JavaScript customizations.

  **Sponsored by** *PTFS Europe*
- [33808](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33808) Accessibility: Non-descriptive links
- [33809](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33809) Accessibility: OPAC results page needs more descriptive links
- [33812](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33812) Accessibility: OPAC messaging preferences is missing form labels
- [33818](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33818) Accessibility: Non descriptive title on ISBD detail
- [33819](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33819) Accessibility: More description required in OPAC search breadcrumbs
- [34438](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34438) OPAC self registration form does not include lang (preferred language for notices) field
  >This adds the 'preferred language' to the patron self registration form when `TranslateNotices` is activated. The field can be hidden using the `PatronSelfRegistrationBorrowerUnwantedField` and `PatronSelfRegistrationBorrowerMandatoryField` system preferences if not needed.
- [34865](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34865) Syspref OPACURLOpenInNewWindow not working for Library URLs
- [34869](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34869) Convert OPACResultsSidebar system preference to HTML customization
  >This enhancement removes the OPACResultsSidebar system preference and allows adding content in this area using the HTML customizations tool. This also means this content is translatable for any languages installed for the OPAC
  >
  >Note: Any existing content is moved to the HTML customizations tool (Tools > HTML customizations > location - OPACResultsSidebar).
- [34889](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34889) Convert PatronSelfRegistrationAdditionalInstructions system preference to HTML customization
- [34894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34894) Convert OpacSuppressionMessage system preference to HTML customization
- [35147](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35147) Add classes to Shibboleth text on OPAC login page

  **Sponsored by** *New Zealand Council for Educational Research*
- [35261](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35261) Update links for self registration avoiding "here"
- [35262](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35262) Improve OPAC self registration confirmation page

### Packaging

#### Enhancements

- [28493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28493) Make koha-passwd display the username

### Patrons

#### New features

- [12532](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12532) Copy guarantee email to guarantor (or redirect if guarantee has no email set)
  >This new feature allows libraries to set email notices for guaranteed users to be copied to their guarantors.
  >
  >If the guarantee doesn't have a valid email of their own, then enabling this feature will redirect the guarantee's email notices to the guarantor.
  >
  >A new system preference, `RedirectGuaranteeEmail`, is introduced.

#### Enhancements

- [12133](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12133) Guarantor requirements when registering a patron
  >This enhancement makes two changes to guarantors and guarantees when registering a new patron:
  >
  >- A child patron must have a guarantor - this is controlled by
  >  the new `ChildNeedsGuarantor` system preference.
  >- A guarantor cannot be a guarantee.

  **Sponsored by** *Koha-Suomi Oy*
- [15157](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15157) Cronjob to automatically restrict patrons with pending/unpaid charges

  **Sponsored by** *Koha-Suomi Oy*
- [15504](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15504) Track Patron's Last Activity
  >This enhancement changes how tracking patron activities (and updating the borrowers.lastseen field) works - you can now select what patron activities to track.
  >
  >Previously, with TrackLastPatronActivity enabled, the borrowers.lastseen field was updated when one of the "hard-coded" activities occurred - you could not select what patron activities to track
  >
  >With this enhancement, you can now individually select the patron activities to track. The current trackable activities are:
  >- All activities
  >- Checking in an item
  >- Checking out an item
  >- Connecting to Koha using SIP and ILS-DI
  >- Logging in (for both the OPAC and the staff interface)
  >- Placing a hold on an item (added by bug 35027)
  >- Placing an article request (added by bug 35030)
  >- Renewing an item 
  >
  >Notes:
  >- If no activities are selected, then patron activity is not tracked and the borrowers.lastseen field is not updated.
  >- The system preference TrackLastPatronActivity was renamed to TrackLastPatronActivityTriggers.
- [16223](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16223) Automatically remove any borrower debarments after a payment

  **Sponsored by** *Koha-Suomi Oy*
- [21431](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21431) Differentiate password change and password reset in action logs
- [26170](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26170) Add protected status for patrons
  >This enhancement makes it possible to protect patrons from being accidentally deleted or merged with other patrons, from the UI and from (well behaved) cron jobs. It adds a 'Protected' field (with Yes and No options) in the library use section for a patron's record.
- [26558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26558) Guarantor information is lost when an error occurs during new account creation

  **Sponsored by** *Koha-Suomi Oy*
- [28688](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28688) Automatically renew patron membership
  >This patch set allows you to renew patrons automatically when running the membership_expiry.pl cron job.
  >You can pass filters to do this only on selected patrons, like active patrons, etc.
  >Default behavior does not change.
- [31357](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31357) Separate holds history from intranetreadinghistory
- [32730](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32730) Add patron lists tab to patron details and circulation pages
- [33271](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33271) Show charges_guarantors_guarantees on patron details page
- [33522](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33522) Optionally skip (in)active patrons when sending membership expiry notices
- [33620](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33620) Don't show patron-privacyguarantor/patron-privacy_guarantor_fines if  borrowerRelationship is empty
- [34511](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34511) Typo in manage_staged_records permission description
  >This patch corrects a typo in the description of the manage_staged_records permission.
- [34517](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34517) Add option to search patron attribute in standard search
- [34719](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34719) Middle name doesn't show on autocomplete
- [35027](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35027) Add holds to patron activity triggers
- [35030](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35030) Extend TrackLastPatronActivity with placing article request

### Plugin architecture

#### Enhancements

- [25672](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25672) Administrators should be able to restrict client-side plugin upload to trusted sources
- [31339](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31339) Add Template::Toolkit WRAPPER for Koha Tool Plugins
- [33776](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33776) Add inLibro in default plugin repositories
  >This enhancement adds inLibro to the list of git repositories searched for plugins. 
  >
  >Notes: 
  >- The ability to search git repositories for plugins from the manage plugins page, and then install, requires a system-level configuration change for your Koha instance(s).
  >- To enable, copy the <plugin_repos> block from debian/templates/koha-conf-site.xml.in to your instance's koha-conf.xml file, remove comments, and restart.

### Preservation

#### New features

- [30708](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30708) Creation of a new 'Preservation' module
  >This new module allows libraries to integrate preservation treatments into their workflow and monitor them.
  >Its main goal is to attach data about the preservation treatments to items (contained in a new Koha table).

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

#### Enhancements

- [33547](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33547) Print slips from the preservation module

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34030](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34030) Print slips in a batch from the preservation module

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

### REST API

#### Enhancements

- [23336](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23336) Add an API endpoint for checking an item out to a patron
- [32739](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32739) REST API: Extend endpoint /auth/password/validation for cardnumber
  >This development adds a new attribute for identifying the patron for password validation: `identifier`. It expects to be passed a `userid` or a `cardnumber` in it. It the `identifier` doesn't match a `userid`, then Koha will try matching a `cardnumber`.
- [33690](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33690) Add ability to send welcome notice when creating patrons using the REST API
- [33974](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33974) Add ability to search biblios endpoint any biblioitem attribute
- [34008](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34008) REST API: Add a list (GET) endpoint for itemtypes
- [34054](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34054) Allow to embed biblio on GET /items

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34211](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34211) Add +strings for GET /api/v1/biblios/:biblio_id/items
- [34313](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34313) Make password validation endpoint return patron IDs
- [34333](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34333) Add cancellation request information embed option to the holds endpoint

### Reports

#### Enhancements

- [6419](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6419) Add customizable areas to intranet home pages
  >This enhancement adds several new locations to HTML customizations to add content to various staff interface pages. This supports multilingual content, as with any HTML customization.
  >
  >New locations are:
  >
  >- StaffAcquisitionsHome: adds content at the bottom of the acquisitions module home page
  >
  >- StaffAuthoritiesHome: adds content at the bottom of the authorities module home page
  >
  >- StaffCataloguingHome: adds content at the bottom of the cataloguing module home page
  >
  >- StaffListsHome: adds content at the bottom of the lists module home page
  >
  >- StaffPatronsHome: adds content at the bottom of the patrons module home page
  >
  >- StaffPOSHome: adds content at the bottom of the point of sale module home page
  >
  >- StaffSerialsHome: adds content at the bottom of the serials module home page
- [23059](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23059) reserves_stats.pl: Simplify reserve status handling
- [33608](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33608) Allow to get statistics about found/recovered books
- [34136](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34136) Add ability to render a report using a notice template
  >With this feature you can use a notice template for rendering the results of a report in the reports module. As you can use Template Toolkit and HTML in notices, this gives you a lot of flexibility to create for example a nice print format for your data.
  >
  >Once a notice has been created with the module 'Reports' selected, you will have the option to run your report using the template.
- [34456](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34456) Add the ability to download a template rendered report as a file
  >This allows to create new download formats for reports using notice templates. You can create different file formats, specifying the file name and ending in the accordingly labelled field when setting up the notice.

### SIP2

#### Enhancements

- [25814](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25814) SIP: Add a message on successful checkin
- [25816](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25816) Add OPAC messages in SIP display
  >New system preference `SIP2AddOpacMessagesToScreenMessage` allows to include patron OPAC messages in the SIP2 screen message.
  >Starting with "Messages for you: ".
- [33926](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33926) Add ability to specify fields allowed in a response

  **Sponsored by** *ByWater Solutions*
- [34016](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34016) Enable fulfillment of recalled items through SIP2
  >This enhancement allows SIP (using a self-check machines) to better handle recalled items - preventing the check-out of recalled items if they have been allocated to another patron, or fulfilling recalls if the item was recalled and allocated to this patron.

  **Sponsored by** *Auckland University of Technology*
- [34101](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34101) Limit items types that can be checked out via SIP2
- [34737](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34737) Enhance SIP2SortBinMapping to support additional match conditions

  **Sponsored by** *PTFS Europe Ltd*
- [34868](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34868) Add ability for SIP2 to distinguish missing item from other lost types

  **Sponsored by** *ByWater Solutions*

### Searching

#### Enhancements

- [26468](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26468) Item search should include a way to limit by damaged
- [33217](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33217) Allow different default sorting when click author links
  >Authors and contributors in the detail pages are linked to search for more materials of the same persons or institutions. Before this patch, these would use the normal default sorting, like relevancy, which isn't as helpful for these results. The new system preferences `AuthorLinkSortBy` and `AuthorLinkSortOrder` now allow to change the sort order for these links specifically.

### Searching - Elasticsearch

#### Enhancements

- [33353](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33353) Add compatibility with Elasticsearch 8 and OpenSearch 2
  >These changes to support ElasticSearch 8.x and OpenSearch 2.x come with a loss of support for ElasticSearch 6.x.
  >
  >Existing instances will have to upgrade to either ElasticSearch 7.x or 8.x or OpenSearch 1.x or 2.x
  >
  >Upgrade from ES 7.x or OS 1.X to ES 8.x or OS 2.x require a reindexation.

### Self checkout

#### Enhancements

- [35048](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35048) Convert SCOMainUserBlock system preference to HTML customization
- [35063](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35063) Convert SelfCheckInMainUserBlock system preference to HTML customization
- [35065](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35065) Convert SelfCheckHelpMessage system preference to HTML customization

### Serials

#### Enhancements

- [31846](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31846) Allow setting serials search results limit

  **Sponsored by** *Gothenburg University Library*
- [33039](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33039) Add ability to specify a template for serial subscription "Published on (text)" field
- [34199](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34199) Add part_name and part_number to subscription detail page

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [34230](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34230) Add part_name and part_number to subscription result list

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*

### Staff interface

#### Enhancements

- [14156](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14156) Add id tags to each MARC note in the display
  >This enhancement adds id and class tags to each MARC note in the description tab for the staff interface bibliographic detail page.
  >
  >It adds a unique id for each note (for unique styling of each repeated tag), and a general and unique class for each tag (for consistent styling across the same tag number). An example of the HTML output: 
  >```
  ><p id="marcnote-500-2" class="marcnote marcnote-500">...</p>
  >```
  >Styles can be defined for notes and individual tags in the `IntranetUserCSS` system preference - see the test plan for an example.
- [21246](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21246) Extend the 'Last patron' navigation feature to 'Last X patrons'

  **Sponsored by** *ByWater Solutions*
- [26916](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26916) Show searchable patron attributes in patron search dropdown
- [32910](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32910) Upgrade fontawesome icons to V6
- [33169](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33169) Improve vue breadcrumbs and left-hand menu
- [33988](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33988) Font awesome fa-gears on staff main page look wrong after upgrade to FA6
- [34055](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34055) Add API client class to get items

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34135](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34135) Show the icons for selected tab to the left of the search bar in the staff interface
- [34188](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34188) Require library selection when logging in
  >When the new system preference `ForceLibrarySelection` is activated, staff users will have to choose a library when logging into the staff interface.
- [34227](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34227) Add persistent selections and batch operations to item search
- [34660](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34660) Make the Deliveries table on housebound.tt a dataTable for easier sorting
- [34721](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34721) Change facet description for Limit to available items to accurately reflect what it does
- [34873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34873) "Sending your cart/list" headings are inconsistent
- [35037](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35037) Revise the appearance of the last patron button
- [35059](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35059) Display item's shelving location on the items tab
- [35119](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35119) Make bibliographic encoding errors more prominent and match current styling

### System Administration

#### Enhancements

- [27424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27424) One should be able to assign an SMTP server as the default
  >We have been able to define SMTP servers in the staff interface for a while now. But to utilize them you had to set the SMTP server for each library individually. With this you can now chose to apply an SMTP server as default to all your libraries.
- [29822](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29822) Use table column selection modal for DefaultPatronSearchFields preference
  >This enhancement changes the `DefaultPatronSearchFields` system preference from an input field where field values separated by a comma are entered, to a modal window listing all patron fields (non-selectable fields are greyed out).
  >
  >This makes it much easier to set the standard fields for patron search, and helps avoid breaking the patron search when incorrect field values are entered.
- [31731](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31731) Offer user a dropdown of authorized values instead of a text field in preferences
- [31832](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31832) Add reference for EnableItemGroups to EnableItemGroupHolds system preference
- [33390](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33390) Expand links to authorized values interface when an authval is mentioned in preferences
- [33828](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33828) ExportCircHistory description is misleading
- [34240](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34240) Add hint about having to use Koha-to-MARC mappings for Koha link in frameworks
- [34807](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34807) Move EnableItemGroups in cataloging preferences
  >The EnableItemGroups system preference is now under Cataloging preferences > Record structure.

### Templates

#### Enhancements

- [26053](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26053) Add styling to show expired patron restrictions as inactive
  >This enhancement highlights that a patron restriction is expired in the patron restriction table (Patrons > ([patron] > Check out or Details tab > Restrictions):
  >- adds the text "(expired)" after the expiration date, and
  >- changes the text color for the line to a light gray.
- [33029](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33029) Add wrapper method for dt_from_string to KohaDates template toolkit plugin
- [33242](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33242) Allow passing things like add_days => 3 to KohaDates filter
- [33426](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33426) Add client storage of user-selected DataTables configuration to suggestion.tt
  >This allows Koha to remember the changes that a user has made to the columns settings on the Purchase Suggestions Management page, so that the columns settings and sorts are kept when reloading the page.
- [33524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33524) Use template wrapper for tabs: Authority editor
- [33525](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33525) Use template wrapper for tabs: Basic MARC editor
- [33804](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33804) Implement as_due_date for $date (js-date-format)
- [33908](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33908) Improve translation of title tags: Acquisitions
- [33909](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33909) Improve translation of title tags: Administration
- [33910](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33910) Improve translation of title tags: Authorities
- [33911](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33911) Improve translation of title tags: Catalog, basket, and lists
- [33912](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33912) Improve translation of title tags: Cataloging
- [33913](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33913) Improve translation of title tags: Circulation, holds, and ILL
- [33914](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33914) Improve translation of title tags: Course reserves
- [33915](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33915) Improve translation of title tags: Installer and onboarding
- [33916](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33916) Improve translation of title tags: Labels
- [33917](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33917) Improve translation of title tags: Offline circulation and patron lists
- [33918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33918) Improve translation of title tags: Patron card creator
- [33919](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33919) Improve translation of title tags: Patron clubs
- [33920](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33920) Improve translation of title tags: Patrons
- [33921](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33921) Improve translation of title tags: Plugins and Point of sale
- [33922](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33922) Improve translation of title tags: Recalls
- [33923](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33923) Improve translation of title tags: Reports
- [33924](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33924) Improve translation of title tags: Rotating collections
- [33927](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33927) Improve translation of title tags: Tools
- [33928](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33928) Improve translation of title tags: Various
- [33983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33983) Move translatable strings out of OPAC's datatables.inc into JavaScript
- [34026](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34026) Move translatable cover-handling strings out of opac-bottom.inc
- [34031](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34031) Move various translatable strings out of opac-bottom.inc
- [34034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34034) Move translatable strings out of opac-bottom.inc: OverDrive and OpenLibrary
- [34035](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34035) Move translatable strings out of opac-bottom.inc: Tags
- [34043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34043) Improve translation of CSV header templates
- [34114](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34114) Replace the use of jQueryUI sortable
- [34124](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34124) Improve in-page navigation on table settings page
- [34196](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34196) UI adjustment to filters on funds administration page
- [34197](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34197) Group and label vendor contact settings
- [34226](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34226) Format dates from DT filters before querying the REST API
- [34270](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34270) Upgrade and prune jQueryUI assets in the staff interface
- [34323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34323) Enhance header search icon for more options
- [34344](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34344) Make item types breadcrumbs uniform
- [34345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34345) 'Circulation and fine rules' vs 'Circulation and fines rules'
- [34373](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34373) Improve layout of curbside pickups items ready list
- [34383](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34383) Inconsistencies in Patron attributes page titles, breadcrumbs, and header
- [34390](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34390) Inconsistencies in Credit types page titles, breadcrumbs, and header
  >This fixes a couple of inconsistencies in the credit types administration page, making sure the page title, breadcrumb navigation, and page headers are consistent with each other.
- [34392](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34392) Run automated Stylelint fixes on staff CSS
- [34395](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34395) Inconsistencies in Authority types page titles, breadcrumbs, and header
- [34422](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34422) Reindent facets.inc
- [34446](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34446) Typo: Can be guarantee
- [34453](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34453) Update background of quick spine label pop-up
- [34519](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34519) Add a template plugin for ExtendedAttributeTypes to fetch searchable patron attributes
- [34553](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34553) Update send list and send cart popup footers
- [34562](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34562) Update more pop-up windows with consistent footer markup
- [34566](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34566) Update MARC21 cataloging plugins with consistent footers
- [34619](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34619) Show debug mode column in list of SMTP servers
- [34630](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34630) Update MARC21 cataloging plugin templates with consistent body class
- [34661](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34661) Update UNIMARC cataloging plugins with consistent footers
- [34679](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34679) Description for RELTERMS authorized value category is wrong
  >This patch changes the description of the RELTERMS authorized value category to "List of relator codes and terms".
- [34769](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34769) Improve translation of title tags: Patron lists
- [34773](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34773) Improve translation of title tags: Cataloging tools
- [34796](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34796) Improve translation of title tags: Tools - Additional tools
- [34802](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34802) Improve translation of title tags: Tags and comments
- [34824](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34824) Add colon after "Title" in new acquisition order details
- [34831](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34831) Add input types "tel", "email" and "url" to vendor edit form
- [34940](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34940) Highlight logged-in library in facets
  >Like in patron searches, records search now uses class 'currentlibrary' to highlight logged-in library in facets.
- [35206](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35206) Adjust style of add button on curbside pickups administration

### Test Suite

#### Enhancements

- [33833](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33833) Remove  Test::DBIx::Class from t/SocialData.t
- [33869](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33869) Move Matcher.t to db_dependent
- [33870](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33870) Remove T::D::C from Sitemapper.t
- [34319](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34319) Upgrade Cypress
- [34690](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34690) Cypress - Fix random failure in Dialog_spec.ts

### Tools

#### Enhancements

- [21083](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21083) Batch patron modification does not allow to modify repeatable patron attributes
- [24480](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24480) Fields added with MARC modifications templates are not added in an ordered way
- [25079](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25079) Show club enrollment question answers in staff interface
- [26978](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26978) Add item type criteria to batch extend due date tool
- [29181](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29181) Allow patron card creator to use a report to get list of borrowers
- [29811](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29811) misc/export_records.pl add possibility to export with timestamp option on authority record type
- [34820](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34820) Improve inventory tool message for items with non-matching notforloan values
  >This fixes the inventory tool to clarify the message for items with non-matching not for loan values in the inventory results 'Problems' column.
  >
  >It:
  >- Adds a hint on the inventory tool page under 'Optional filters for inventory list or comparing barcodes' section.
  >- Clarifies the message in the 'Problems' column: from 'Unknown not-for-loan status' to 'Items has no not for loan status'. 
  >
  >If one or more not for loan values (Optional filters for inventory list or comparing barcodes > items.notforloan) are selected, and an item is scanned that has no NFL status or an unselected NFL status, the error message was "Unknown not-for-loan status". This could be interpreted as the item having an NFL status value that is not defined in the system, but that is not accurate. This is now clarified and the error message is now "Items has no not for loan status".
- [34964](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34964) Add descriptions for different HTML customization regions
- [34977](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34977) Allow to delete multiple patron lists at once
  >This enhancement enables selecting and deleting multiple patron lists at once, instead of having to delete patron lists one at a time.

### Web services

#### Enhancements

- [21284](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21284) ILS-DI: Allow GetPatronInfo to tell if a checked out item is on hold for someone else
  >This enhancement adds two new entries in the loans section of a GetPatronInfo response:
  >
  >- item_on_hold: number of holds on this specific item
  >- record_on_hold: number of holds on the record
  >
  >This allows an ILS-DI client to know if a loaned item is already on hold by someone else, and how many holds there are.
- [35008](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35008) ILS-DI should not ask for login with OpacPublic disabled

  **Sponsored by** *Auckland University of Technology*
## Bugfixes
This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintenance releases


#### Security bugs

- [22990](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22990) Add CSRF protection to boraccount, pay, suggestions and virtualshelves on staff (23.11.00,23.05.02,22.11.08)
- [30524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30524) Add base framework for dealing with CSRF in Koha (23.11.00,23.05.02,22.11.08,22.05.15, 21.11.25)
- [33881](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33881) SCO/SCI user leaving the module doesn't clear session (ie JWT) (23.11.00,23.05.02,22.11.09)
- [34023](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34023) HTML injection in "back to results" link from search page (23.11.00,23.05.02)
- [34287](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34287) Patron's should not be able to ask for checkoutability for different patrons (23.11.00)
- [34349](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34349) Validate inputs for task scheduler
- [34368](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34368) Add CSRF protection to Content Management pages (23.11.00,23.05.02,22.11.08)
- [34369](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34369) Add CSRF protection to system preferences
- [34513](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34513) Authenticated users can bypass permissions and view some privileged pages (23.11.00,23.05.04,22.11.10,22.05.16)
- [34761](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34761) Stored/reflected XSS with searches and saved search filters (23.11.00,23.05.04,22.11.10)
- [35290](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35290) SQL Injection vulnerability in ysearch.pl (23.11.00)
- [35291](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35291) File Upload vulnerability in upload-cover-image.pl (23.11.00)

#### Critical bugs fixed

- [33885](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33885) Get HTTP 500 when retrieving orders created by a non-existent (deleted) user (23.11.00,23.05.01)
  >This fixes an issue that prevents the receiving of items where the user who created the order has been deleted. When clicking on 'Receive' for an item, this error was displayed:
  >"Something went wrong when loading the table.
  >500: Internal Server Error."
- [33993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33993) The GET orders endpoint needs to allow users with order_receive permission (23.11.00,23.05.02,22.11.08)
- [34022](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34022) Adding items on receive is broken (23.11.00,23.05.01)
- [34080](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34080) Updating suggestion status can result in 500 error (23.11.00,23.05.02,22.11.08)
- [34109](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34109) When adding items on receive, mandatory fields are not checked (23.11.00,23.05.04)
- [34469](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34469) Modifying an order line of a standing order will delete linked invoice ID (23.11.00,23.05.03,22.11.09)
- [34509](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34509) Cannot create baskets if too many vendors (23.11.00,23.05.04,22.11.10)
- [34645](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34645) Add missing fields to MarcItemFieldsToOrder system preference (23.11.00,23.05.05,22.11.11)
- [34736](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34736) Item checkboxes move to wrong order line in multi-receive, breaking partial receive (23.11.00,23.05.04)
- [34880](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34880) Receive impossible if items created 'in cataloguing' (23.11.00,23.05.04)
- [35004](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35004) Cannot receive order lines with items created in cataloguing (23.11.00,23.05.06)
- [35254](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35254) Adding files to basket from a staged file uses wrong inputs for order information when not all records are selected (23.11.00,23.05.06)
- [35273](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35273) When editing items on receive, aqorders_items is not updated correctly (23.11.00,23.05.06)
- [32305](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32305) Background worker doesn't check job status when received from rabbitmq (23.11.00,23.05.05,22.11.12)
- [32894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32894) Objects cache methods' result without invalidation (23.11.00,23.05.02,22.11.08)
- [33270](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33270) OAI-PMH should not die on record errors (23.11.00,23.05.02,22.11.08)
- [33934](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33934) 'No encryption_key in koha-conf.xml' needs more detail (23.11.00,23.05.01,22.11.07)
  >This fixes an issue that can cause upgrades to Koha 23.05 to fail with an error message that includes 'No encryption_key in koha-conf.xml'. It also requires the configuration entry in the instance koha-conf.xml to be something other than __ENCRYPTION_KEY__.
  >It is recommended that the key is generated using pwgen 32
- [34193](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34193) Default HTTPS template has outdated SSLProtocol value (23.11.00,23.05.03,22.11.09)
- [34204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34204) Koha user needs to be able to login (23.11.00,23.05.05,22.11.12)
- [34494](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34494) Table tmp_holdsqueue fails to be created for MySQL 8 (23.11.00)
- [34720](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34720) UpdateNotForLoanStatusOnCheckin should be named UpdateNotForLoanStatusOnCheckout (23.11.00,23.05.04)
- [34731](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34731) C4::Letters::SendQueuedMessages can be triggered with an undef message_id (23.11.00,23.05.04)
  >This fixes an issue where generating a notice that is undefined (for example, where it is empty) will trigger the sending of any pending messages, even though the message queue cronjob isn't run. This can cause an issue for libraries that expect emails and SMS messages to be processed at specific times.
- [34959](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34959) Translator tool generates too many changes (23.11.00,23.05.06,22.11.12,22.05.17,21.11.26)
- [35014](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35014) Times should only be set for enable-time flatpickrs (23.11.00,23.05.05,22.11.11)
- [35111](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35111) Background jobs worker crashes on SIGPIPE when database connection lost in Ubuntu 22.04 (23.11.00,23.05.05,22.11.12)
- [35136](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35136) Error during database update after Bug 31383 (23.11.00)
- [35194](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35194) Javascript error: Uncaught TypeError: $(...).sortable is not a function (23.11.00)
- [35199](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35199) Fix error handling in http-client.js (23.11.00,23.05.05,22.11.12)
- [35304](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35304) Add new Sortable library to didyoumean configuration (23.11.00)
- [33880](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33880) "Enable two-factor authentication" fails if patron's library branchname is too long (23.11.00,23.05.02,22.11.08)
- [33904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33904) 2FA registration fails if library name has non-latin characters (23.11.00,23.05.01,22.11.08)
- [34028](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34028) Two factor authentication (2FA) shows the wrong values for manual entry (23.11.00,23.05.01,22.11.09)
  >This fixes the details displayed for manually entering two-factor authentication (2FA) details into a 2FA application (when enabling 2FA). Currently, the wrong information is displayed - so you can't successfully add the account manually to your 2FA application.
- [34163](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34163) CSRF error if try OAuth2/OIDC after logout (23.11.00,23.05.04,22.11.10)
- [35231](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35231) Cannot logout from OPAC and not login afterwards (23.11.00)
- [34014](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34014) There is no way to fix records with broken MARCXML (23.11.00,23.05.05)
- [34146](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34146) Add confirmation question when more than 99 items are to be added (23.11.00,23.05.02,22.11.08)
- [34218](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34218) XSLT parse on record directly breaks OPAC display (23.11.00,23.05.02,22.11.08)
- [34993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34993) Framework doesn't load defaults in existing records or duplicate as new (23.11.00,23.05.06,22.11.12)
- [35181](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35181) Can no longer edit sample records with advanced cataloguing editor (23.11.00,23.05.06)
- [17798](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17798) Checking out an item on hold for another patron prints a slip but does not update hold (23.11.00,23.05.06,22.11.12)
- [27249](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27249) Using the calendar to 'close' a library can create an infinite loop during renewals (23.11.00,23.05.05,22.11.12)
- [33888](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33888) Overdues with fines report displays error 500 (23.11.00,23.05.01,22.11.08)
  >This fixes the 'Circulation > Overdues > Overdues with fines' listing so that it lists overdue items where there are fines, instead of generating an error.
- [34279](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34279) overduefinescap of 0 is ignored, but overduefinescap of 0.00 is enforced (23.11.00,23.05.03,22.11.09,22.05.16)
- [34601](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34601) Cannot manage suggestions without CSRF error (23.11.00,23.05.04,22.11.10,22.05.16)
- [35295](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35295) No hold modal when checking in an item of a held record (23.11.00,23.05.06,22.11.12)
- [34764](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34764) sip_cli_emulator -fa/--fee_acknowledge does not act as expected (23.11.00,23.05.04,22.11.11)
- [33606](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33606) Access to ERM requires parameters => 'manage_sysprefs' (23.11.00,23.05.05,22.11.12)
- [35115](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35115) ERM - Potential MARC data loss when importing titles from list (23.11.00)
- [32271](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32271) Overdue fines cap (amount) set to 0.00 when editing rule (23.11.00,23.05.03,22.11.09)
- [33028](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33028) Wrongly formatted monetary amounts in circulation rules break scripts and calculations (23.11.00,23.05.03,22.11.09)
- [34620](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34620) Writeoff causes 500 error if  RequirePaymentType is on (23.11.00,23.05.04,22.11.10)
  >This fixes writing off a charge when the RequirePaymentType system preference is set to required. The write-off now completes successfully without generating an error page (Patrons > [patron account] > Accounting > Make a payment > Write off an individual charge).
- [35015](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35015) Regression: Charges table no longer filters out paid transactions (23.11.00,23.05.05,22.11.11)
- [34178](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34178) Add caching of ItemsAnyAvailableAndNotRestricted to IsAvailableForItemLevelRequest (23.11.00,23.05.02)
- [34233](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34233) Pickup location pulldowns when placing holds in staff are blank (23.11.00,23.05.02,22.11.08)
- [34609](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34609) Holds history errors 500 if old_reserves.biblionumber is NULL (23.11.00,23.05.04,22.11.10)
- [34666](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34666) _Findgroupreserve is not returning title level matches from the queue for holds with no item group (23.11.00,23.05.04,22.11.10)
- [35306](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35306) Expired holds are not displayed correctly in staff interface (23.11.00)
- [35258](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35258) Updating po files locally fails (23.11.00)
- [21983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21983) Better handling of deleted biblios on ILL requests (23.11.00,23.05.01,22.11.07)
- [33786](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33786) ILL requests table pagination in patron ILL history is transposing for different patrons (23.11.00,23.05.01,22.11.07)
- [33873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33873) ILL requests with linked biblio_id that no longer exists causes table to not render (23.11.00,23.05.01,22.11.07)
- [34130](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34130) ILL requests table won't load if request_placed date is null (23.11.00,23.05.02,22.11.08)
- [34598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34598) Error 500 is shown when ILL request is not found (23.11.00)
- [35093](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35093) ILL table is broken (23.11.00)
- [35094](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35094) ILL new request is broken (23.11.00)
- [35096](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35096) ILL request manage page explodes if it belongs to a batch (23.11.00)
- [35105](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35105) ILL - Saving 'Edit request' form with invalid Patron ID causes ILL table to not render (23.11.00,23.05.05,22.11.12)
- [34276](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34276) upgrading 23.05 to 23.05.002 (23.11.00,23.05.04,22.11.10)
- [34881](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34881) Database update for bug 28854 isn't fully idempotent (23.11.00,23.05.05,22.11.12)
- [33671](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33671) Database update 22.06.00.048  breaks update process (23.11.00,23.05.02,23.05.00,22.11.08,22.11.06)
- [34337](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34337) Web installer doesn't install patrons when select all is used (23.11.00,23.05.02,22.11.09)
- [34520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34520) Database update 22.06.00.078 breaks update process (23.11.00,23.05.05,22.11.12)
- [33404](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33404) Authorities imported from Z39.50 in encodings other than UTF-8 are corrupted (23.11.00,23.05.02,22.11.08,22.05.17)
- [34093](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34093) jQuery not loading on OAI XSLT pages (23.11.00,23.05.01)
- [34155](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34155) OPAC item level holds "force" option broken (23.11.00,23.05.03,22.11.09)
- [34174](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34174) Saving RIS results to Error 505 (23.11.00,23.05.02,22.11.08)
- [34518](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34518) "Renew all" button doesn't work in OPAC (23.11.00,23.05.04)
- [34694](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34694) OPAC bib record blows up with error 500 (23.11.00,23.05.04,22.11.11)
- [34768](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34768) Can't pay fines on OPAC if patron has a guarantee and they can see their fines (23.11.00,23.05.04,22.11.11)
- [34836](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34836) OPAC ISBD or MARC view blows up with error 500 (23.11.00,23.05.05,22.11.11)
  >This fixes an error that occurs when viewing the MARC and ISBD views of a record in the OPAC (when not logged in) - the detail pages cannot be viewed and there is an error trace displayed.
- [35242](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35242) Force memcache restart after koha upgrade (23.11.00,23.05.06,22.11.12)
- [34106](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34106) Patron search in member-search-box.inc always defaults to 'Starts with' search (23.11.00,23.05.02,22.11.08)
- [35335](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35335) Circulation history tab in patron information causes 500 error (23.11.00)
- [35366](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35366) Circulation history of patron is only visible when there is a current checkout (23.11.00)
- [29523](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29523) Add a way to prevent embedding objects that should not be allowed (23.11.00)
- [32801](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32801) /checkouts?checked_in=1 errors when itemnumber is null (23.11.00,23.05.02,22.11.08)
- [34024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34024) REST API should not allow changing the pickup location on found holds (23.11.00,23.05.03,22.11.09)
- [35167](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35167) GET /items* broken if notforloan == 0 and itemtype.notforloan == NULL (23.11.00,23.05.05,22.11.12)
- [35218](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35218) No tests for /erm/sushi_service (23.11.00)
- [35219](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35219) ERM usage endpoints not showing up in documentation (23.11.00)
- [33966](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33966) "Update and run SQL" for non-English templates (23.11.00,23.05.01)
- [34258](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34258) Cannot renew item via SIP2 (23.11.00,23.05.03)
- [34767](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34767) SIP2 fee acknowledgement flag on renewals is passed, but not used (23.11.00,23.05.04,22.11.11)
- [34857](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34857) OPAC advanced search operator "not" is searching as "and" on chrome (23.11.00,23.05.06,22.11.12)
  >This fixes a regression (from bug 33233) when using a Chrome-based browser with AND, OR, and NOT in OPAC > Advanced search > More options. Using these operators with keywords should now work as expected.
- [30451](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30451) Delete a subscription deletes the linked order (23.11.00,23.05.03,22.11.09)
  >When an order had been created using the 'from a subscription' option and the subscription was deleted, the order line would be deleted with it, independent of its status or age. This caused problems with funds and budgets. With this patch, we will unlink order line and subscription on delete, but the order line will remain.
- [35073](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35073) Serials batch edit deletes unchanged additional fields data (23.11.00,23.05.06,22.11.12)
- [34639](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34639) Item shown in transit on detail.pl even if marked as arrived or cancelled (23.11.00,23.05.04)
- [35284](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35284) No more delay between 2 DT requests (23.11.00,23.05.06,22.11.12)
- [35303](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35303) Staff interface header - patron search autocomplete no longer works (Uncaught TypeError: search_fields.forEach is not a function) (23.11.00)
- [34269](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34269) Regression in circulation rules for 'similar' patron categories (23.11.00,23.05.03,22.11.09)
- [34622](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34622) SMTP server edit page unsets is_default if editing default server (23.11.00,23.05.04)
- [35263](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35263) Cannot update patron categories (23.11.00)
- [34042](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34042) Item search broken by FontAwesome upgrade (23.11.00)
- [35110](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35110) Authorities editor with JS error when only one tab (23.11.00,23.05.05,22.11.12)
- [34911](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34911) Test suite no longer run test critic (23.11.00,23.05.05,22.11.11)
- [35201](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35201) Cypress tests for the Preservation module are failing (23.11.00)
- [34181](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34181) Batch patron modification tool missing checkboxes to clear field values (23.11.00,23.05.02,22.11.09)
- [34288](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34288) Cannot use cataloguing tools without cataloguing permissions (23.11.00,23.05.02,22.11.08)
- [34617](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34617) Patron expiration dates not updated during import when there is no dateexpiry column in the file (23.11.00,23.05.04,22.11.10)
- [34818](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34818) Cannot perform batch patron modification without selecting a patron attribute (23.11.00)
  >This fixes an issue with batch patron modifications that was introduced by bug 21083 - you can now successfully perform a batch update without needing to select patron attributes. Previously, if you submitted a batch of patrons for modification, you needed to select a patron attribute or the process will fail with an error trace.

#### Other bugs fixed

- [33877](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33877) Fix teams.yaml (23.11.00,23.05.00,22.11.07)
- [33899](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33899) Release team 23.11 (23.11.00,23.05.02,22.11.08)
- [34424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34424) Update release team on about page for new QA team member (23.11.00,23.05.06,22.11.12)
- [34800](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34800) Update contributor openhub links (23.11.00,23.05.05,22.11.12)
- [35033](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35033) Add a validation for biblioitems in about/system information (23.11.00,23.05.06,22.11.12)
- [35365](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35365) Incorrectly closed <th> tag on patron search page (23.11.00)
- [22712](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22712) Funds from inactive budgets appear on Item details if using MarcItemFieldstoOrder (23.11.00,23.05.06,22.11.12)
- [26994](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26994) Display list of names in alphabetical order when using the Suggestion information filter in Suggestions management (23.11.00,23.05.05,22.11.12)
- [32676](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32676) EDI message status uses varying case, breaking EDI status block (23.11.00,23.05.05,22.11.11)
- [33748](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33748) UI issue on addorderiso2709.pl page (23.11.00,23.05.01,22.11.07)
- [33798](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33798) Vendor details - improve consistency of edit forms and display (23.11.00,23.05.02)
  >This fixes display errors and improves the consistency of the vendor page and edit forms in acquisitions. Includes adding colons to field labels when adding an interface, making field labels all bold, and addressing some accessibility issues.
- [33863](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33863) On receive "change currency" is always checked (23.11.00,23.05.02)
- [33939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33939) JavaScript needs to distinguish between order budgets and default budgets when adding to staged file form a basket (23.11.00,23.05.02,22.11.08,22.05.16)
- [34002](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34002) Check for stage_marc_import permission when adding to basket from a new file (23.11.00,23.05.02,22.11.08)
- [34036](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34036) Single receive doesn't reload data and order lines don't appear in received section (23.11.00,23.05.04)

  **Sponsored by** *Toi Ohomai Institute of Technology*
- [34095](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34095) Shipping cost should default to a blank box instead of 0.00 (23.11.00,23.05.04,22.11.10)
- [34108](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34108) When items are added on order, item selection gets lost on editing items (23.11.00,23.05.03)
- [34261](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34261) Deleting an EDIFACT ordering account throws an error (23.11.00,23.05.02,22.11.08)
- [34305](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34305) If actual cost is negative, wrong price will display in the acq details tab (23.11.00,23.05.03,22.11.09)
- [34375](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34375) Shipping fund in an invoice defaults to the first fund from the list rather than 'no fund' after receiving (23.11.00,23.05.06,22.11.12)
- [34445](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34445) Default budget is not selected in addorderiso2709.pl (23.11.00,23.05.04,22.11.10)
- [34452](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34452) Button 'Update adjustments' is hidden (23.11.00,23.05.03,22.11.09)
- [34752](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34752) Use AV descriptions in display for sort1/sort2 in basket display (23.11.00)
- [34917](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34917) Fix suggestions.tt table default sort column (23.11.00,23.05.05,22.11.11)
- [35012](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35012) Framework item plugins fire twice on Acquisition item blocks (23.11.00,23.05.06,22.11.12)
- [18855](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18855) Fines cronjob can cause duplicate fines if run during active circulation (23.11.00,23.05.02,22.11.08)
- [21828](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21828) Improve efficiency of C4::Biblio::LinkBibHeadingsToAuthorities (23.11.00,23.05.04)
- [23241](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23241) Does misc/bin/koha-index-daemon-ctl.sh still belong in community koha? (23.11.00)
  >This script was never fully promoted or documented. It also required third party libraries to be installed. If you have been using this, please consider switching to the standard koha-indexer scripts.
- [24517](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24517) Zebra: date-entered-on-file misses 6th position (23.11.00,23.05.02,22.11.08)
  >This patch fixes the date-entered-on-file index so that it correctly uses all 6 characters instead of the 5 character it has used the last 11 years.
  >
  >Note: For this patch to have effect, Zebra must be re-indexed.
- [26700](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26700) Remove unused C4/SIP/t directory (23.11.00,23.05.02)
- [30002](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30002) Add project-level perltidyrc (23.11.00,23.05.02,22.11.08)
- [30362](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30362) GetSoonestRenewDate is technically wrong when NoRenewalBeforePrecision set to date soonest renewal is today (23.11.00,23.05.04,22.11.10)
- [30649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30649) Vendor EDI account passwords should be encrypted in the database (23.05.00,22.11.08,22.11.07)
- [32060](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32060) Improve performance of Koha::Item->columns_to_str (23.11.00,23.05.01,22.11.07)

  **Sponsored by** *Gothenburg University Library*
- [32379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32379) CRASH: Can't call method "itemlost" on an undefined value (23.11.00,23.05.06,22.11.12)
- [32464](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32464) Koha::Item->as_marc_field obsolete option mss (23.11.00,23.05.01,22.11.07)
- [33030](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33030) Add standardized subroutine for processing Template Toolkit syntax outside of notices (23.11.00)
- [33047](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33047) Local cover image fetchers return 500 internal error when image not available (23.11.00,23.05.02,22.11.08)
- [33493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33493) Add a filter relationship for branchtransfers (23.11.00,23.05.02)
- [33496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33496) Add 'host_items' param to Koha::Biblio->items (23.11.00,23.05.02)
- [33500](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33500) Failing test for t/db_dependent/Circulation.t when RecordLocalUseOnReturn is set to record (23.11.00,23.05.02,22.11.08)
- [33778](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33778) Move t/Auth_with_shibboleth.t to db_dependent (23.11.00,23.05.02)
- [33803](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33803) Some scripts contain info about tab width (23.11.00,23.05.01,22.11.07)
- [33844](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33844) item->is_denied_renewal should check column from associated pref (23.11.00,23.05.01,22.11.08)
- [33937](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33937) Incorrect export in C4::Members (23.11.00,23.05.02,22.11.08)
- [33950](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33950) Unnecessary processing in opac-readingrec if BakerTaylor and Syndetics off (23.11.00,23.05.02,22.11.08)
- [33951](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33951) normalized_oclc not defined in opac-readingrecord.tt (23.11.00,23.05.02,22.11.08)
- [33964](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33964) Use Email::Sender::Transport::SMTP::Persistent for sending email (23.11.00,23.05.03)
- [33967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33967) REMOTE_ADDR incorrect in plack.log when run behind a proxy (23.11.00,23.05.02,22.11.08)
- [34033](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34033) DB update problems from bug 30649 (23.11.00,23.05.02,22.11.08)
- [34051](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34051) Koha::AuthorisedValues->get_description_by_koha_field not caching results for non-existent values (23.11.00,23.05.02,22.11.08)
- [34056](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34056) authorised-values API client file is missing -api-client suffix (23.11.00,23.05.03,22.11.09)

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34243](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34243) Too many cities are created (at least in comments) (23.11.00,23.05.02,22.11.,22.05.16)
- [34271](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34271) Remove a few Logger statements from REST API (23.11.00,23.05.05,22.11.12)
- [34303](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34303) t/00-testcritic.t should only test files part of git repo (23.11.00,23.05.02,22.11.08,22.05.16)
- [34316](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34316) account->add_credit does not rethrow exception (23.11.00,23.05.03,22.11.09,22.05.16)
- [34354](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34354) Job progress typo (23.11.00,23.05.03,22.11.09)
- [34357](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34357) Subroutine Koha::ItemType::SUPER::imageurl redefined (23.11.00)
- [34359](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34359) Get rid of Koha/BiblioUtils/Iterator (23.11.00)
- [34364](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34364) Background job - Fix visual progress of progress bar (23.11.00,23.05.03)
- [34470](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34470) Real Time Holds Queue - make random numbers play nice with forked processes (23.11.00,23.05.03,22.11.09)
- [34570](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34570) Remove use of onclick for PopupMARCFieldDoc() (23.11.00,23.05.04,22.11.10)
- [34571](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34571) Remove use of onclick for ExpandField (23.11.00,23.05.04,22.11.10)
- [34589](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34589) Update on bug 20256 is not idempotent (23.11.00,23.05.04)
- [34656](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34656) CartToShelf should not trigger RealTimeHoldsQueue (23.11.00,23.05.04,22.11.11)
- [34786](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34786) after_biblio_action hooks: find after delete makes no sense (23.11.00,23.05.04,22.11.11)
- [34844](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34844) manage_item_editor_templates is missing from userpermissions.sql (23.11.00,23.05.04,22.11.11)
- [34885](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34885) Improve confusing pref description for OPACHoldsIfAvailableAtPickup (23.11.00,23.05.05,22.11.11)
- [34912](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34912) Account(s).t tests fail in UTC+1 and higher (23.11.00,23.05.05,22.11.11)
- [34916](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34916) ArticleRequests.t may fail on wrong borrowernumber (23.11.00,23.05.05,22.11.11)
- [34918](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34918) Koha/Items.t crashes on missing borrower 42 or 51 (23.11.00,23.05.05,22.11.11)
- [34930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34930) Fix timezone problem in Koha/Object.t (23.11.00,23.05.05,22.11.11)
- [34932](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34932) A missing manager (51) failed my patron test (23.11.00,23.05.05,22.11.11)
- [34982](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34982) Administration currencies table not showing pagination (23.11.00,23.05.05,22.11.11)
- [34990](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34990) Backgroundjob->enqueue does not send persistent header (23.11.00,23.05.05,22.11.12)
- [35000](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35000) OPACMandatoryHoldDates does not work well with flatpickr (23.11.00,23.05.05,22.11.12)
- [35024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35024) Do not wrap PO files (23.11.00,23.05.06,22.11.12,22.05.17,21.11.26)
- [35064](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35064) Syntax error in db_revs/220600072.pl (23.11.00,23.05.05,22.11.12)
- [35173](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35173) Call concat correctly for EDI SFTP Transport errors (23.11.00,23.05.06,22.11.12)
- [35190](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35190) Additional_fields table should allow null values for authorised_value_category (23.11.00,23.05.06)
- [35196](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35196) Remove misc/perlmodule_[ls|rm].pl (23.11.00)
- [35269](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35269) Koha::Item->update_item_location should be named `trigger_location_update` (23.11.00)
- [35278](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35278) CGI::param called in list context from /usr/share/koha/admin/columns_settings.pl line 76 (23.11.00,23.05.06,22.11.12)
- [35298](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35298) Flatpickr makes focus handler in dateaccessioned plugin useless (23.11.00,23.05.06,22.11.12)
- [31393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31393) Koha::Config->read_from_file incorrectly parses elements with 1 attribute named" content" (Shibboleth config) (23.11.00,23.05.06,22.11.12)
- [31651](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31651) Log message incorrect in Auth_with_shibboleth.pm (23.11.00,23.05.02,22.11.08)
- [33879](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33879) check_cookie_auth overwrites interface set by get_template_and_user (23.11.00,23.05.02,22.11.08)
  >This fixes an issue with recording the interface for the log viewer where installations run the OPAC and staff interface on the same domain name. Before this patch, if a user logged into the OPAC and then went to the staff interface and performed a logable action (such as a checkout), the interface in the log was incorrectly recorded as the OPAC.
- [31185](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31185) Link authorities automatically doesn't detect duplicate authorities (23.11.00,23.05.02)
- [32853](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32853) Fix cataloguing/value_builder/unimarc_field_125.pl (23.11.00,23.05.06,22.11.12)
- [32856](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32856) Fix cataloguing/value_builder/unimarc_field_126.pl (23.11.00,23.05.06,22.11.12)
- [33247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33247) Deleted authority still on results list (23.11.00,23.05.01,22.11.07)
- [33744](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33744) Plugins not working on duplicated MARC fields (23.11.00,23.05.04,22.11.10)
- [33755](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33755) Profile used is not saved when importing records (23.11.00,23.05.03,22.11.09)
- [33884](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33884) Remove unused Koha::RDF code (23.11.00)
- [34029](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34029) Import breaks when data exceeds size of mapped database columns (23.11.00,23.05.02,22.11.08)
- [34097](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34097) Using the three ellipses to set the date accessioned for an item repositions the screen to the top (23.11.00,23.05.02,22.11.08,22.05.16)
- [34171](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34171) item_barcode_transform does not work when moving items (23.11.00,23.05.05,22.11.12)
- [34182](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34182) AddBiblio shouldn't set biblio.serial based on biblio.seriestitle (23.11.00,23.05.02,22.11.08,22.05.16)
- [34251](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34251) MARC editor with JS error when using fast add framework (23.11.00,23.05.02,22.11.08)
- [34266](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34266) Item type should not default to biblio itemtype if it's not a valid itemtype (23.11.00,23.05.04,22.11.10)
- [34549](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34549) The cataloguing editor allows you to input invalid data (23.11.00,23.05.05,22.11.11)
  >This fixes entering data when cataloguing so that non-XML characters are removed. Non-XML characters (such as ESC) were causing adding and editing data to fail, with errors similar to:
  >  Error: invalid data, cannot decode metadata object
  >  parser error : PCDATA invalid Char value 27
- [34689](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34689) Add and duplicate item - Error 500 (23.11.00,23.05.05,22.11.11)
- [34794](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34794) Typo in recalls_to_pull.tt (23.11.00,23.05.05,22.11.11)
- [34966](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34966) Terminology: Add item form - "Add & duplicate" should be "Add and duplicate" (23.11.00,23.05.06,22.11.12)
  >This updates the add item form in the staff interface to
  >change the 'Add & duplicate' button to 'Add and duplicate'. (As per the terminology guidelines https://wiki.koha-community.org/wiki/Terminology)
- [35101](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35101) Clicking the barcode.pl plugin causes screen to jump back to top (23.11.00,23.05.05,22.11.12)
- [35245](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35245) Incorrect select2 width when cataloging authorities (23.11.00,23.05.06,22.11.12)
- [25023](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25023) Claims returned dates not formatted according to dateformat preference (23.11.00,23.05.04,22.11.10)
- [27992](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27992) When recording local use with statistical patron items are not checked in (23.11.00,23.05.06)
- [29007](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29007) Prompt for reason when cancelling waiting hold via popup (23.11.00,23.05.06)
  >This adds the option to record the hold cancellation reason on the check in form for waiting holds (similar to when cancelling holds from the record details' holds page).
- [31082](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31082) Add tooltip to buttons when item bundles cannot be changed while checked out (23.11.00,23.05.02,22.11.08)
- [31147](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31147) Recalls due date to the minute rather than 23:59 (23.11.00,23.05.02,22.11.08)
  >The current recalls behaviour adjusts the due date of the most appropriate checkout based on the 'recall due date interval' circulation rule. It also adjusts the due time, which is buggy behaviour. The due date should be adjusted based on the circulation rule, but the due time should remain the same.

  **Sponsored by** *Catalyst*
- [32765](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32765) Transfer is not retried after cancelling hold (23.11.00,23.05.04,22.11.10)
- [33164](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33164) Return claim message shows intermittently when BlockReturnOfLostItems enabled (23.11.00,23.05.06,22.11.12)

  **Sponsored by** *Pymble Ladies' College*
- [33806](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33806) Overridden checkin date not retained when CircConfirmItemParts enabled (23.11.00,23.05.02,22.11.08)
- [33817](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33817) Composition of an item bundle can be changed if checked out (23.11.00,23.05.02,22.11.08)
- [33858](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33858) Date for pending offline circulation is unformatted (23.11.00,23.05.02,22.11.08)
- [33944](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33944) When listing checkouts, don't fetch item object if not using recalls (23.11.00,23.05.02,22.11.08)
- [33961](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33961) In-built Offline circulation tool no longer working and should be removed (23.11.00,23.05.02)
  >This removed the in-built Koha offline circulation tool that could be activated using the AllowOfflineCirculation system preference. This won't have any effect on the KOCT Firefox plugin or on the Windows desktop offline circulation tool.
- [33976](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33976) Claims returned option is not disabled in moredetail.pl if the item has a different lost status (23.11.00,23.05.02,22.11.08)
- [33992](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33992) Only consider the date when labelling a waiting recall as problematic (23.11.00,23.05.03,22.11.09,22.05.16)

  **Sponsored by** *Auckland University of Technology*
- [34071](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34071) Change the phrasing of 'automatic checkin' to fit consistent terminology (23.11.00,23.05.02,22.11.08)
- [34072](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34072) Holds queue search interface hidden on small screens (23.11.00,23.05.02,22.11.08)
- [34086](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34086) On detail.tt if item.permanent_location is NULL no shelving location will show (23.11.00,23.05.02,22.11.08)
- [34232](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34232) Item groups dropdown on add item form does not respect display order (23.11.00,23.05.02,22.11.08)
- [34257](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34257) Library limitations for item types not respected when batch modding items (23.11.00,23.05.04,22.11.10)
- [34289](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34289) UI issue on checkin page when checking the forgive fines checkbox (23.11.00,23.05.03,22.11.09)
- [34302](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34302) Checkin and renewal error messages disappear immediately in checkouts table (23.11.00,23.05.04,22.11.11)
- [34341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34341) Revert Bug 34072: Holds queue search interface hidden on small screens (23.11.00,23.05.04,22.11.10)
- [34572](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34572) Simplify template logic around check-in input form (23.11.00,23.05.04,22.11.10)
- [34634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34634) Expiration date does not display on reserve/request.pl if date is today or in the past (23.11.00,23.05.04,22.11.10)
- [34704](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34704) Print templates are formatted incorrectly (23.11.00,23.05.06,22.11.12)
  >The patch removes the automated additional of html linebreak markup to print notices when using --html.
  >
  >If you are using this flag with gather_print_notices.pl you may need to revisit your notice templates to ensure they are properly marked up as expected for html notices. If you are using non-html notices then they should remain as before.
- [34722](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34722) All items display as recalled when an item-level recall is made (23.11.00,23.05.05,22.11.11)

  **Sponsored by** *Toi Ohomai Institute of Technology*
- [34910](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34910) Do not allow checkout for anonymous patron (23.11.00,23.05.06,22.11.12)
- [35188](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35188) force_checkout permission can override all blocks on a patron account but only shows when they are restricted (23.11.00)
- [35251](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35251) Issue table does not recalculate number of checkouts after a check in (23.11.00)
  >This fixes the number of checkouts shown on a patron's check-in and details page. Previously, if items were checked-in from either of these tabs, the number of checkouts was not updated.
- [31964](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31964) Missing manpage for koha-z3950-responder (23.11.00,23.05.04,22.11.10)
  >This adds a man page for the `koha-z3950-responder` command-line utility, documenting all available options and parameters that can be used when running this command.
- [34505](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34505) Patron invalid age in search_for_data_inconsistencies.pl should skip expired patrons (23.11.00,23.05.04,22.11.10)
- [34569](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34569) misc/cronjobs/holds/holds_reminder.pl problem with trigger arg (23.11.00,23.05.04,22.11.10)
- [34653](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34653) Make koha-foreach return the correct status code (23.11.00,23.05.04,22.11.11)
- [35141](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35141) Prevent link_bibs_to_authorities from dying on search error (23.11.00,23.05.06,22.11.12)
- [35171](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35171) runreport.pl cronjob should optionally send an email when the report has no results (23.11.00,23.05.06)
  >This enhancement adds a new 'send_empty' option to runreport.pl. Currently, if there are no results for a report, then no email is sent. This option lets libraries know that a report was run overnight and that it had no results. Example: perl misc/cronjobs/runreport.pl 1 --send_empty --email
- [33790](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33790) Fix and add various links to the manual (23.11.00,23.05.02,22.11.08)
- [33941](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33941) EBSCO Packages filter failing (23.11.00,23.05.02,22.11.08)
- [33973](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33973) Sorting broken on ERM tables (23.11.00,23.05.02,22.11.08)
- [34107](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34107) Sorting agreements by Name actually sorts by ID (23.11.00,23.05.02,22.11.08)
- [34201](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34201) Missing sorting indicator on the ERM tables (23.11.00,23.05.02,22.11.08)
- [34214](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34214) Toolbar component should make the icon configurable (23.11.00,23.05.02,22.11.08)

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34219](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34219) getAll not allowing additional parameters (23.11.00,23.05.04,22.11.10)
- [34447](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34447) "Actions" columns are exported (23.11.00,23.05.03,22.11.09)

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [34465](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34465) "Actions" columns are sortable (23.11.00,23.05.04,22.11.10)
- [34466](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34466) "Clear filter" always disabled (23.11.00,23.05.04,22.11.10)
- [34735](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34735) Current/disabled links in breadcrumbs are styled differently when in ERM module (23.11.00)
- [34789](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34789) Fix typo in erm_eholdings_titles (23.11.00,23.05.04,22.11.11)
- [34804](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34804) Translation fixes - ERM (23.11.00,23.05.05,22.11.11)
- [35229](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35229) Fix and add further cypress tests for Usage reporting (23.11.00)
- [35418](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35418) SUSHI harvest hangs (23.11.00)
- [33789](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33789) Checkout information is missing when adding a credit (23.11.00,23.05.01)
- [34331](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34331) Point of sale transaction history is showing the wrong register information (23.11.00,23.05.04,22.11.10)
- [34332](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34332) Syntax error in point of sale email template (23.11.00,23.05.03,22.11.09)
- [34340](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34340) Point of sale email template is showing 0.00 in the tendered field (23.11.00,23.05.04,22.11.10)
- [28966](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28966) Holds queue viewer too slow to load for large numbers of holds (23.11.00)
- [30846](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30846) "If any unavailable" doesn't consider negative notforloan values as unavailable (23.11.00,23.05.03,22.11.09)
- [30860](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30860) Performance: Add option for CanBookBeReserved to return all item values (23.11.00,23.05.02)
- [33074](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33074) ReservesControlBranch not taken into account in opac-reserve.pl (23.11.00,23.05.05)
- [33573](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33573) Add public endpoint for cancelling holds (23.11.00,23.05.02,22.11.08)
- [34137](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34137) Requested cancellation date column missing from holds awaiting pickup table config (23.11.00,23.05.02,22.11.08)
- [34320](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34320) Hold reordering arrows look broken after Font Awesome upgrade (23.11.00)
- [34678](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34678) Concurrent changes to the holds can fail due to primary key constraints (23.11.00,23.05.06,22.11.12)
- [34901](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34901) Item-level holds can show inaccurate transit status on the patron details page (23.11.00,23.05.05,22.11.12)
- [35003](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35003) Holds with cancellation requests table on waitingreserves.tt does not filter by branch (23.11.00,23.05.06,22.11.12)
- [35069](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35069) Items needed column on circ/reserveratios.pl does not sort properly (23.11.00,23.05.05,22.11.12)
- [3007](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3007) Remove untranslated unimarc_field_700-4 value builder (23.11.00)
- [32312](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32312) Complete database column descriptions for circulation module in guided reports (23.11.00,23.05.06,22.11.12)
  >This adds and clarifies database column descriptions shown for the statistics table when creating a guided report for the circulation module. Previously, some columns didn't have a description or were ambiguous.
- [34079](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34079) The phrase "Displaying [all|approved|pending|rejected] terms" was separated (23.11.00,23.05.04,22.11.10)
- [34081](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34081) Contextualization of "Approved" (one term) vs "Approved" (more than one term), and other tag statuses (23.11.00,23.05.04,22.11.10)
- [34310](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34310) Input prompt in datatables column search boxes untranslatable (23.11.00,23.05.04,22.11.10)
- [34334](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34334) 'Item(s)' in MARC detail view untranslatable (23.11.00,23.05.03,22.11.09)
- [34801](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34801) Fix incorrect use of __() in .tt and .inc files (bug 34038 follow-up) (23.11.00,23.05.05)
- [34833](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34833) "order number" untranslatable when editing estimated delivery date (23.11.00,23.05.05,22.11.11)
- [34870](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34870) Unrecognized special characters when writing off an invoice with a note (23.11.00,23.05.05,22.11.11)
  >This fixes the display of UTF-8 characters for write off notes under a patron's accounting section. Previously, if you added a note when writing off multiple charges ([Patron] > Accounting > Make a payment > Payment note column > + Add note), a note with special characters (for example, éçö) did not display correctly.
- [35081](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35081) "Your concern was sucessfully submitted." untranslatable (23.11.00,23.05.05)
- [35374](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35374) Translations contain config from ERM/data providers (23.11.00)
- [35377](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35377) Terminology: Callnumber shoudl be call number (23.11.00)
- [22440](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22440) Improve ILL page performance by moving to server side filtering (23.05.00,22.11.06)
- [34058](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34058) ILL - Left filters not considering all terms in input (23.11.00)
- [34133](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34133) ILL table should be sorted by request id descending by default (23.11.00,23.05.03,22.11.09)
- [34223](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34223) ILL status filter does not load immediately after selecting a backend filter (23.11.00,23.05.04,22.11.10)
- [34351](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34351) ILL list table - access_url column content should be clickable (23.11.00)
- [34905](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34905) ILL - "Place request with partners" icon is gone (23.11.00)
- [35098](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35098) ILL batch is not displayed in ILL table (23.11.00)
- [34684](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34684) 220600007.pl is failing if run twice (23.11.00,23.05.04,22.11.10)
- [34685](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34685) updatedatabase.pl does not propagate the error code (23.11.00,23.05.04,22.11.10)
- [35180](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35180) Fix typo in deletedbiblioitems.publishercode comment in kohastructure.sql (23.11.00,23.05.06,22.11.12)
- [33581](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33581) Error in web installer concerning sample holidays and patrons requiring sample libraries (23.11.00,23.05.02,22.11.08)
- [33935](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33935) Installer list deleted files which shows warning in the logs (23.11.00,23.05.01,22.11.07)
- [34558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34558) Update custom.sql for it-IT webinstaller (23.11.00,23.05.05,22.11.11)
- [34209](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34209) Follow up on Bug 28726 - move whole search header div into checkbox column condition (23.11.00,23.05.02,22.11.08)
- [34532](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34532) Silence warns in Patroncard.pm when layout values are empty (23.11.00,23.05.04,22.11.11)
- [34592](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34592) The patron search window, given just a sort field value, doesn't work (23.11.00,23.05.04,22.11.10)
- [32402](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32402) "Modification date" missing from OPAC lists table (23.11.00,23.05.02)
  >This enhancement adds the modification date column to the lists tables for the OPAC. This lets patrons know when the list was last updated.
- [34650](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34650) Editing/deleting lists from toolbar on virtualshelves/shelves.pl causes CSRF error (23.11.00,23.05.04,22.11.10)
- [30024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30024) link_bibs_to_authorities.pl relies on CatalogModuleRelink (23.11.00,23.05.06,22.11.12)
- [33978](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33978) Adding authority from automatic linker closes imported record (23.11.00,23.05.03,22.11.09)
- [34180](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34180) Template variable in JavaScript triggers error when showing authority MARC preview (23.11.00,23.05.02,22.11.08)
- [26862](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26862) MARC21 530 is missing from staff interface and has no label (23.11.00,23.05.02,22.11.08)
  >This fixes the display of the MARC21 530 tag and subfields so that it:
  >- now displays in the staff interface (was missing)
  >- improves the display of the values by adding
  >  . a description/label
  >  . separators between repeated 530 tags
  >  . missing spaces before $u and between repeated $u subfields
- [31618](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31618) Typo in POD for C4::ImportBatch::RecordsFromMARCXMLFile (23.11.00,23.05.02,22.11.08)
- [33865](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33865) JS error when importing a staged MARC record file (23.11.00,23.05.01,22.11.07)
- [35099](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35099) Cannot load records with invalid marcxml (23.11.00)
- [33759](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33759) Typo: Thankyou (23.11.00,23.05.04)
- [33900](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33900) advance_notices.pl cronjob hangs (23.11.00,23.05.02,22.11.08)
- [34059](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34059) advance_notices.pl -c --digest-per-branch does not work as intended (23.11.00,23.05.03,22.11.09)
- [34583](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34583) Overdue notices: wrong encoding in e-mail in 'print' mode (23.11.00,23.05.04,22.11.10)
- [35185](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35185) Remove is_html flag from sample notices for text notices (23.11.00,23.05.06,22.11.12)
- [35186](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35186) Remove html tags from sample notices (23.11.00,23.05.06,22.11.12)
  >This removes unnecessary <html></html> tags in two email notices:
  >* PASSWORD_RESET
  >* STAFF_PASSWORD_RESET
  >These notices are only updated in new installations, for existing installation manually change the notices.
- [35187](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35187) Fix line breaks in some HTML notices, including WELCOME (23.11.00,23.05.06,22.11.12)
- [27496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27496) Accessibility: Navigation buttons are poorly described by screen readers (23.11.00,23.05.04,22.11.10)
- [27634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27634) Turn off patron self-registration if no default category is set (23.11.00)
  >When there is no valid patron category defined in system preference PatronSelfRegistrationDefaultCategory the full feature is disabled.
- [29578](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29578) Search term highlighting breaks with titles containing characters with Greek diacritics (23.11.00,23.05.04,22.11.10)
  >This fixes an issue with the term highlighter which is used during catalog searches in both the OPAC and the Staff interface. Under certain conditions (searching for titles containing characters with Greek diacritics), the jQuery term highlighter would break and in the process make the "Highlight" / "Unhighlight" button disappear altogether. UNIMARC instances were affected the most by this.
- [32341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32341) Some OPAC tables are not displayed well in mobile mode (23.11.00,23.05.02,22.11.08)
- [33697](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33697) Remove deprecated RecordedBooks (rbdigital) integration (23.11.00,23.05.01,22.11.07)
- [33810](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33810) Accessibility: OPAC Advanced Search fields are not labelled (23.11.00,23.05.06,22.11.12)
- [33813](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33813) Accessibility: Lists button is not clearly identified (23.11.00,23.05.01,22.11.07)
  >This enhancement adds an aria-label to the Lists button in the OPAC masthead. It is currently not descriptive enough and doesn't identify what is displayed when clicking the button.
- [33848](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33848) Enabling Coce in the OPAC breaks cover images on bibliographic detail page (23.11.00,23.05.03,22.11.09,22.05.17)
- [33902](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33902) On opac-detail.tt the libraryInfoModal is outside of HTML tags (23.11.00,23.05.01,22.11.07)
  >This moves the HTML for the pop-up window with the information for a library (where it exists) on the OPAC detail page inside the <html> tag so that it validates correctly. There is no change to the appearance or behavior of the page.
- [33933](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33933) Use restrictions appear twice for items on OPAC (23.11.00,23.05.02,22.11.08)
- [33957](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33957) normalized_oclc not defined in opac-user.tt (23.11.00,23.05.02,22.11.08)
- [34005](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34005) Toggling the search term highlighting is not always working in the bibliographic record details page (23.11.00,23.05.02,22.11.08)
- [34015](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34015) Terminology: Relative issues should be Relative's checkouts (23.11.00,23.05.02,22.11.08)
- [34522](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34522) Suggestion for purchase displays wrong library in OPAC display if patron suggests for non-home library (23.11.00,23.05.04,22.11.10)
- [34584](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34584) Remove Twitter share button from the OPAC (23.11.00)
- [34613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34613) Remove onclick event attributes from Verovio midiplayer.js (23.11.00,23.05.04,22.11.11)
- [34627](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34627) Fix CMS page HTML structure so that footer content is displayed correctly (23.11.00,23.05.04,22.11.10)
- [34641](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34641) Novelist content does not display on OPAC detail page if NovelistSelectView is set to below (23.11.00,23.05.04,22.11.10)
- [34711](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34711) Remove use of onclick for opac-privacy.pl (23.11.00,23.05.04,22.11.11)
- [34723](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34723) opac-imageviewer.pl not showing thumbnails (23.11.00,23.05.04,22.11.10)
- [34724](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34724) Remove use of onclick for opac-imageviewer.pl (23.11.00,23.05.04,22.11.11)
- [34725](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34725) Remove use of onclick for OPAC cart (23.11.00,23.05.04,22.11.11)
- [34730](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34730) Add responsive behavior to more tables in the OPAC (23.11.00,23.05.04,22.11.11)
- [34760](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34760) Prevent error when logging into OPAC after conducting a search (23.11.00,23.05.04,22.11.11)

  **Sponsored by** *Toi Ohomai Institute of Technology*
- [34849](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34849) Use template wrapper for breadcrumbs: OPAC part 1 (23.11.00)
- [34852](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34852) Use template wrapper for breadcrumbs: OPAC part 2 (23.11.00)
- [34855](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34855) Use template wrapper for breadcrumbs: OPAC part 3 (23.11.00)
- [34866](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34866) Use template wrapper for breadcrumbs: OPAC part 4 (23.11.00)
- [34923](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34923) OPAC hold page flatpickr does not allow direct input of dates (23.11.00,23.05.05,22.11.11)
- [34934](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34934) Remove the use of event attributes from OPAC lists page (23.11.00,23.05.05,22.11.11)
- [34936](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34936) Remove the use of event attributes from OPAC detail page (23.11.00,23.05.05,22.11.11)
- [34944](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34944) Remove the use of event attributes from OPAC full serial issue page (23.11.00,23.05.05,22.11.11)
- [34945](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34945) Remove the use of event attributes from OPAC clubs tab (23.11.00,23.05.05,22.11.11)
- [34946](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34946) Remove the use of event attributes from self checkout and check-in (23.11.00,23.05.05,22.11.12)
- [34961](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34961) RSS feed link in OPAC is missing sort parameter (23.11.00,23.05.05,22.11.11)
  >This fixes two RSS links in the OPAC search results template so that they include the correct parameters, including the descending sort by acquisition date.
- [34980](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34980) Remove the use of event attributes from title-actions-menu.inc in OPAC (23.11.00,23.05.05,22.11.12)
- [35006](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35006) OPAC holdings table - sort for current library column doesn't work (23.11.00,23.05.05,22.11.12)
  >This fixes the holdings table on the OPAC's bibliographic detail
  >page so that home and current library columns are sorted correctly by
  >library name.
- [35144](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35144) 'Required' mention for patron attributes is not red in OPAC (23.11.00,23.05.06,22.11.12)
- [35266](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35266) opac-MARCdetail: Can't call method "metadata" on an undefined value (23.11.00,23.05.06)
  >This fixes the display of the MARC view page when a record does not exist - it now redirects to the 404 (page not found) page. Previously, it generated an error trace, where the normal and ISBD view pages redirected to the 404 (page not found) page.
- [35280](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35280) OPAC patron entry form: Patron attributes "clear" link broken (23.11.00,23.05.06,22.11.12)
- [33371](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33371) Add 'koha-common.service' systemd service (23.11.00,23.05.00,22.11.07)
- [33720](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33720) updatedatabase.pl should purge memcached (23.11.00,23.05.02,22.11.08)
- [33117](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33117) Patron checkout search not working if searching with second surname (23.11.00,23.05.02,22.11.09,22.11.08)
- [33176](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33176) Improve enforcing of RequirePaymentType (23.11.00,23.05.02,22.11.08)
- [33395](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33395) Patron search results shows only overdues if patron has overdues (23.11.00,23.05.05,22.11.11)
- [33428](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33428) Should only search in searchable patron attributes if searching in standard fields (23.11.00)
- [33820](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33820) Add hints to warn the librarian that they will be logged out if they change their username (23.11.00,23.05.02)
- [33875](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33875) Missing closing tag a in API key management page (23.11.00,23.05.01,22.11.07)
- [33882](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33882) member.tt Date of birth column makes it difficult to hide the age hint (23.11.00,23.05.01,22.11.07)
- [33968](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33968) Two colons missing on guarantor labels in memberentry.pl form (23.11.00,23.05.02,22.11.08)
- [34083](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34083) Patron auto-complete fails if organization patron full name is in a single field separated by a space (23.11.00,23.05.02,22.11.08)
- [34092](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34092) patron-autocomplete.js and patron-search.inc search logic should match (23.11.00,23.05.02,22.11.08)
- [34117](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34117) Duplicate patron sets dateenrolled incorrectly (23.11.00,23.05.03,22.11.09)
- [34256](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34256) Patron search: search for borrowernumber starts with fails (23.11.00,23.05.02,22.11.08)
- [34280](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34280) Patrons with no email address produce a warning when saving (23.11.00,23.05.03)
- [34356](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34356) Enabling RecordStaffUserOnCheckout causes bad default sorting in checkout history (23.11.00,23.05.04,22.11.10)
- [34402](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34402) Sorting holds on patron account includes articles (23.11.00,23.05.04)
- [34413](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34413) Flat picker birth date field does not display properly on initial load on iOS (23.11.00,23.05.06,22.11.12)
- [34435](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34435) get_password_expiry_date should not modify its parameter (23.11.00,23.05.03,22.11.09)
- [34462](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34462) Bug 25299 seems to have been reintroduced in more recent versions. (23.11.00,23.05.05,22.11.12)
  >This fixes the display of the card expiration message on a patron's page so that it now includes the date that their card will expire.
- [34531](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34531) Hiding Lost card flag and Gone no address flag via BorrowerUnwantedFields hides Patron restrictions (23.11.00,23.05.05,22.11.12)
- [34728](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34728) HTML notices should not be pre-formatted (23.11.00,23.05.04,22.11.11)
- [34743](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34743) Incorrect POD in import_patrons.pl (23.11.00,23.05.04,22.11.11)
- [34883](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34883) Regression in Patron Import dateexpiry function (23.11.00,23.05.05,22.11.11)
- [34891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34891) View restrictions button (patrons page) doesn't link to tab (23.11.00,23.05.05)
- [34931](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34931) Collapsed additional attributes and identifiers with a PA_CLASS don't display well (23.11.00,23.05.06,22.11.12)
- [35127](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35127) Patron search ignores searchtype from the context menu (23.11.00,23.05.05,22.11.12)
- [35264](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35264) Update patron import to use protected column (23.11.00)
- [35148](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35148) before_send_messages plugin hook does not pass the --where option (23.11.00,23.05.05,22.11.12)
- [32942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32942) Suggestion API doesn't support custom statuses (23.11.00,23.05.04,22.11.11)
- [33556](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33556) $c->validation should be avoided (part 1) (23.11.00,23.05.03)
- [33971](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33971) Remove support for x-koha-query header (23.11.00)
  >This patch removes support for the `x-koha-query` HTTP header. The implementation was problematic because no URL/Base64 encoding was being expected, and it broke things. As it didn't have real usage in the codebase, we decided to remove it.
  >
  >It could eventually be restored if there was interest on it, but it wouldn't work as before anyway, because of the aforementioned issue with non-ASCII queries.
- [33996](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33996) Authority objects missing mapping (23.11.00,23.05.02)
- [34339](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34339) $c->validation should be avoided (part 2) (23.11.00,23.05.04)
- [34365](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34365) Hold cancellation request workflow cannot be triggered on API (23.11.00,23.05.03,22.11.09)
- [34387](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34387) API docs tags missing descriptions (23.11.00,23.05.03,22.11.09)
- [35053](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35053) Item-level rules not checked if both item_id and biblio_id are passed (23.11.00,23.05.05,22.11.12)
- [35230](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35230) `catalogue_item` missing description (23.11.00)
- [27824](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27824) Report batch operations break with space in placeholder (23.11.00,23.05.02,22.11.08)
- [29664](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29664) Do not show voided payments in cash register statistics wizard (23.11.00,23.05.02,22.11.08)
- [34552](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34552) No Results when filtering "All payments to the library" or "payment" in Statistics wizards : Cash register (23.11.00,23.05.04,22.11.10)
- [34859](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34859) reports-home.pl has unnecessary syspref template parameters (23.11.00,23.05.05,22.11.11)
- [22873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22873) C4::SIP::ILS::Transation::FeePayment->pay $disallow_overpayment does nothing (23.11.00,23.05.05,22.11.11)
- [23548](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23548) AQ field required in checkin response (23.11.00,23.05.04,22.11.10)
  >This fixes SIP return messages so that there is an "AQ|" field, even if it is empty (this is a required field according to the specification, and some machines (such as PV-SUPA) crash if it is not present).
- [33411](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33411) SIP2 includes other guarantees with the same guarantor when calculating against NoIssuesChargeGuarantees (23.11.00,23.05.01,22.11.07)
- [34153](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34153) Add ability to allow items with additional materials notes to be checked out via SIP (23.11.00)
- [28196](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28196) In page anchors on additem.pl don't always go to the right place (23.11.00,23.05.02,22.11.08)
- [31253](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31253) Item search in staff interface should call barcodedecode if the search index is a barcode (23.11.00,23.05.02,22.11.08)
- [33140](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33140) Use facet label value in mouseover title attribute of facet removal link (23.11.00,23.05.03,22.11.09)
- [33896](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33896) Catalog search from the masthead searchbar produces a warning in the logs (23.11.00,23.05.02,22.11.08)
- [27153](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27153) ElasticSearch should search keywords apostrophe blind (23.11.00)
- [33406](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33406) Searching for authority with hyphen surrounded by spaces causes error 500 (with ES) (23.11.00,23.05.04,22.11.11)
- [34740](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34740) Sort option are wrong in search engine configuration (Elasticsearch) (23.11.00,23.05.04,22.11.11)
- [34557](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34557) Add option to prevent loading a patron's checkouts on the SCO (23.11.00,23.05.06)
- [35007](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35007) Configure self checkout tables consistently (23.11.00)
- [35013](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35013) Font Awesome icons broken in self checkout and self checkin (23.11.00)
- [23775](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23775) Claiming a serial issue doesn't create the next one (23.11.00,23.05.02,22.11.08)
- [33901](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33901) Only one issue shown when testing prediction pattern (23.11.00,23.05.02,22.11.08)
- [34052](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34052) Fix link to subscription from serial collection page (23.11.00,23.05.02,22.11.08)
- [31041](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31041) Cashup summary modal printing issue (23.11.00,23.05.06,22.11.12)
  >This bugfix updates the modal printing system to trigger a new page for dialogue printing.
  >
  >Whilst this causes a minor flash unsightly content at print preview, it significantly improves the reliability of modal printing where such dialogues appear on pages containing a lot of content or the modals themselves contain a enough content to require a scroll.
- [32245](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32245) Deleting news entries from Koha's staff start page is broken (23.11.00,23.05.02,22.11.08)
- [33497](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33497) Reduce DB calls on staff detail page (23.11.00,23.05.02)
- [33946](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33946) biblio-title.inc should not add a link if biblio does not exist (23.11.00,23.05.02,22.11.08)
- [34094](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34094) Apply DefaultPatronSearchMethod to all patron search forms (23.11.00,23.05.02,22.11.08)
- [34116](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34116) Add page-sectioning to item search in label creator (23.11.00,23.05.02,22.11.08)
- [34131](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34131) Plugins page breadcrumbs and side menu not consistent (23.11.00,23.05.02,22.11.08)
- [34292](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34292) Date formatting in checkouts list broken (23.11.00)
- [34616](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34616) "Edit SMTP server" page - Default SMTP configuration dialog has some issues (23.11.00,23.05.04)
- [34921](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34921) Tabs on Additional Content page need space above (23.11.00,23.05.05,22.11.11)
- [35019](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35019) Can't delete news from the staff interface main page (23.11.00,23.05.05,22.11.12)
- [35276](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35276) Suggestions form crashes on Unknown column 'auth_forwarded_hash' when logging in (23.11.00,23.05.06,22.11.12)
  >This fixes an issue when trying to directly access the suggestions management page in the staff interface ([YOURDOMAIN]/cgi-bin/koha/suggestion/suggestion.pl) when you are logged out. Previously, if you were logged out, tried to access the suggestions management page, and then entered your credentials, you would get an error trace.
- [33286](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33286) 'Catalog record' should be 'Bibliographic record' (23.11.00,23.05.03)
- [33578](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33578) Cannot edit patron restriction types (23.11.00,23.05.02,22.11.08)
- [33868](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33868) Upgrade the Multiple Select plugin in the staff interface (23.11.00,23.05.02)
  >This enhancement updates the jQuery Multiple Select plugin version from 1.1 to 1.6. This plugin is used in the staff interface system preferences area.
- [34748](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34748) Wrong column name basket_number in table settings for basket (23.11.00,23.05.04,22.11.11)
- [34791](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34791) CookieConsent preference should hint that there's HTML content blocks available for customisation (23.11.00)
- [35032](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35032) Remove the use of "onclick" from Koha to MARC mapping template (23.11.00)
- [35057](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35057) Improve table heading "Lib" in MARC field structure page (23.11.00)
- [35078](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35078) Invalid HTML in OpacShowSavings system preference (23.11.00,23.05.06)
- [35221](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35221) TrackLastPatronActivityTriggers description is misleading (23.11.00)
- [31014](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31014) Minor UI problems in QOTD editor tool (23.11.00)
- [31667](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31667) Merge 'tip' and 'hint' classes (23.11.00,23.05.03,22.11.09)
- [33343](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33343) Password fields should have auto-completion off (23.11.00,23.05.01)
- [33528](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33528) Use template wrapper for tabs: Patron details and circulation (23.11.00,23.05.02)
- [33734](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33734) Using custom search filters breaks diacritics characters in search term (23.11.00,23.05.04,22.11.11)
- [33779](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33779) Terminology: biblio record (23.11.00,23.05.01,22.11.07)
- [33781](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33781) Terminology: Item already issued to other borrower. (23.11.00,23.05.02,22.11.08)
- [33855](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33855) Clean up forms and page sections on 'manage MARC imports' page (23.11.00,23.05.02,22.11.08)
  >This enhancement makes minor changes to the structure of the "Manage staged MARC records" page for a batch so that sections are more clearly delineated and forms have the correct structure. It also shortens the new framework field labels and adds hints for clarification.
- [33859](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33859) Use the phrase 'Identity providers' instead of 'Authentication providers' (23.11.00,23.05.01,22.11.07)
- [33883](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33883) "Make sure to copy your API secret" message overlaps text (23.11.00,23.05.01,22.11.07)
- [33891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33891) Use template wrapper for tabs: OPAC advanced search (23.11.00,23.05.01,22.11.07)
- [33892](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33892) Use template wrapper for tabs: OPAC authority detail (23.11.00,23.05.01,22.11.07)
- [33893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33893) Use template wrapper for tabs: OPAC checkout history (23.11.00,23.05.02,22.11.08)
- [33894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33894) Use template wrapper for tabs: OPAC search history (23.11.00,23.05.02,22.11.08)
- [33895](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33895) Use template wrapper for tabs: OPAC user summary (23.11.00)
- [33897](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33897) Use template wrapper for tabs: OPAC bibliographic detail page (23.11.00,23.05.02,22.11.08)
- [33998](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33998) Installer and onboarding have incorrect Font Awesome asset links (23.11.00)
- [33999](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33999) Subscription details link on bibliographic detail page should have permission check (23.11.00,23.05.02,22.11.08)
- [34010](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34010) Template corrections to recall pages (23.11.00,23.05.02,22.11.08)
- [34012](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34012) Use template wrapper for tabs: Recalls awaiting pickup (23.11.00,23.05.02,22.11.08)
- [34013](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34013) Recalls awaiting pickup doesn't show count on each tab (23.11.00,23.05.02,22.11.08)
- [34038](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34038) Fix incorrect use of __() in .tt and .inc files (23.11.00,23.05.04,22.11.10)
- [34066](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34066) Datatable options don't fully translate on list of saved reports (23.11.00,23.05.04,22.11.10)
- [34074](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34074) Improve translations of strings on the about page (23.11.00,23.05.02,22.11.08)
- [34085](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34085) Remove the use of event attributes from basket groups template (23.11.00)
- [34103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34103) Capitalization: Currencies & Exchange rates (23.11.00,23.05.02,22.11.08)
- [34112](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34112) Replace fa.fa-pencil-alt with fa-solid.fa-pencil in edit buttons (23.11.00)
- [34115](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34115) Use a global tab select function for activating Bootstrap tabs based on location hash (23.11.00,23.05.04,22.11.10)
- [34119](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34119) Improve staff interface print stylesheet following redesign (23.11.00,23.05.05,22.11.12)
- [34129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34129) Responsive table button icon broken after FontAwesome upgrade (23.11.00)
- [34184](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34184) "Document type" in suggestions form should have an empty entry (23.11.00,23.05.02,22.11.08,22.05.16)
- [34244](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34244) Improve contrast in staff interface main page layered icons (23.11.00,23.05.02,22.11.08)
- [34307](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34307) Update plugin wrapper to use template wrapper for breadcrumbs (23.11.00,23.05.04)
- [34322](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34322) Correct icon triggering more fund search options (23.11.00)
- [34343](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34343) Z39.50 search background not updated (23.11.00,23.05.03,22.11.09)
- [34378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34378) Inconsistencies in Libraries page titles, breadcrumbs, and header (23.11.00)
- [34379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34379) Inconsistencies in Library groups page (23.11.00,23.05.04,22.11.10)
- [34380](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34380) Inconsistencies in Item types page titles, breadcrumbs, and header (23.11.00)
- [34381](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34381) Inconsistencies in Authorized values page title (23.11.00)
- [34382](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34382) Inconsistencies in Patron categories page titles, breadcrumbs, and header (23.11.00)
- [34384](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34384) Inconsistencies in Library transfer limits page titles, breadcrumbs, and header (23.11.00)
- [34385](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34385) Inconsistencies in Transport cost matrix page header (23.11.00,23.05.04,22.11.10)
- [34386](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34386) Inconsistencies in Cities and towns page titles, breadcrumbs, and header (23.11.00,23.05.04,22.11.10)
- [34388](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34388) Inconsistencies in Patron restriction types page headers (23.11.00)
- [34389](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34389) Inconsistencies in Debit types page titles, breadcrumbs, and header (23.11.00)
  >This fixes a couple of inconsistencies in the debit types administration page, making sure the page title, breadcrumb navigation, and page headers are consistent with each other.
- [34391](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34391) Inconsistencies in Cash registers page headers (23.11.00)
  >This fixes a couple of inconsistencies in the cash register administration page, making sure the page title, breadcrumb navigation, and page headers are consistent with each other.
- [34393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34393) Inconsistencies in MARC bibliographic framework page titles, breadcrumbs, and header (23.11.00)
  >This fixes some inconsistencies in the MARC bibliographic framework administration page, making sure the page title, breadcrumb navigation, and page headers are consistent with each other.
- [34394](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34394) Inconsistencies in MARC Bibliographic framework test page title and breadcrumbs (23.11.00)
- [34397](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34397) Inconsistencies in Classification sources page titles, breadcrumbs, and header (23.11.00)
- [34399](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34399) Inconsistencies in Record overlay rules page titles, breadcrumbs, and header (23.11.00)
- [34400](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34400) Inconsistencies in OAI sets page titles, breadcrumbs, and header (23.11.00)
- [34401](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34401) Inconsistencies in Item search fields page titles, breadcrumbs, and header (23.11.00)
- [34403](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34403) Inconsistencies in Currencies and exchange rates page titles, breadcrumbs, and header (23.11.00)
- [34404](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34404) Inconsistencies in Budgets and funds page titles, breadcrumbs, and header (23.11.00)
- [34405](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34405) Inconsistencies in EDI accounts/Library EAN page titles, breadcrumbs, and header (23.11.00)
- [34406](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34406) Inconsistencies in Identity providers/domains page titles, breadcrumbs, and header (23.11.00)
- [34407](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34407) Inconsistencies in Z39.50 servers page titles, breadcrumbs, and header (23.11.00)
- [34408](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34408) Inconsistencies in SMTP servers page titles, breadcrumbs, and header (23.11.00)
- [34409](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34409) Inconsistencies in Audio alerts page titles, breadcrumbs, and header (23.11.00)
- [34411](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34411) Inconsistencies in Additional fields page titles, breadcrumbs, and header (23.11.00)
- [34412](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34412) Inconsistencies in system preferences page titles, breadcrumbs, and header (23.11.00)
- [34434](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34434) Terminology: Biblio should be bibliographic (23.11.00,23.05.04,22.11.10)
- [34436](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34436) Some breadcrumbs lack <span> for translatability (23.11.00,23.05.04,22.11.10)
- [34443](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34443) Spelling: Patron search pop-up Sort1: should be Sort 1: (23.11.00,23.05.05,22.11.11)
- [34493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34493) Bad indenting in search_indexes.inc (23.11.00,23.05.03,22.11.09)
- [34502](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34502) Useless SEARCH_RESULT.localimage usage (23.11.00,23.05.04,22.11.10)
- [34533](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34533) jsdiff library missing from guided reports page (23.11.00,23.05.04,22.11.10)
- [34565](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34565) Label mismatch in MARC21 006 and 008 cataloging plugins (23.11.00,23.05.04,22.11.10)
- [34567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34567) Correct colors for advanced cataloging editor status bar (23.11.00,23.05.04,22.11.10)
- [34624](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34624) Many header search forms lack for attribute for label (23.11.00,23.05.06)
- [34625](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34625) Search engine configuration tables header problem (23.11.00,23.05.04,22.11.10)
- [34646](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34646) Two attributes class in OPAC masthead-langmenu.inc (23.11.00,23.05.04,22.11.10)
- [34781](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34781) Add a span tag around GDPR text in opac-memberentry (23.11.00,23.05.05,22.11.11)
- [34835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34835) Highlight logged-in library in patron searches does not work anymore in new staff interface (23.11.00,23.05.04,22.11.11)
- [34942](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34942) Typo: brower (23.11.00,23.05.05,22.11.11)
- [34954](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34954) Typo: datexpiry (23.11.00,23.05.06,22.11.12)
- [35010](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35010) In record checkout history should not show anonymous patron link (23.11.00,23.05.05,22.11.11)
- [35055](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35055) Don't export actions column from patron search results (23.11.00,23.05.05,22.11.12)
- [35058](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35058) No contents displaying when an authority record is saved (23.11.00)
- [35072](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35072) Invalid usage of "&amp;" in JavaScript intranet-tmpl script redirects (23.11.00,23.05.05,22.11.12)
- [35124](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35124) Incorrect item groups table markup (23.11.00,23.05.05,22.11.12)
- [35205](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35205) Fix duplicate id attribute in desks search form (23.11.00,23.05.06)
- [35212](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35212) Correct mismatched label on identity provider entry form (23.11.00,23.05.06,22.11.12)
- [35241](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35241) Markup errors in point of sale template (23.11.00)
- [35272](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35272) Add padding above vendor contracts section (23.11.00,23.05.06)
- [35283](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35283) XSLT 583 Action note is missing subfield h and x in staff interface (23.11.00,23.05.06,22.11.12)
- [33727](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33727) Merge Calendar tests (23.11.00,23.05.02,22.11.08,22.05.16)
- [33852](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33852) jobs.t is not testing only_current (23.11.00,23.05.02,22.11.08)
- [34489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34489) Koha/Patrons.t: Subtests get_age and is_valid_age do not pass in another timezone (23.11.00,23.05.05,22.11.11)
- [34842](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34842) t/db_dependent/Illrequest/Config.t is failing if the DB has been upgraded (23.11.00)
- [34843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34843) Koha/Database/Commenter.t is failing if the DB has been upgraded (23.11.00,23.05.04,22.11.11)
- [34845](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34845) GetBasketGroupAsCSV.t is failing if the DB has been upgraded (23.11.00)
- [34846](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34846) SIP/ILS.t is failing if the DB has been upgraded (23.11.00,23.05.04,22.11.11)
- [34847](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34847) Search.t is failing if the DB has been upgraded (23.11.00,23.05.04,22.11.11)
- [34848](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34848) SIP/Message.t is failing if the DB has been upgraded (23.11.00,23.05.04,22.11.11)
- [34967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34967) Move Prices.t to t/db_dependent (23.11.00,23.05.05,22.11.11)
- [34968](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34968) t/Search.t does not do anything with Test::DBIx::Class (23.11.00,23.05.05,22.11.11)
- [34969](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34969) t/Search/buildQuery.t does not do anything with Test::DBIx::Class (23.11.00,23.05.05,22.11.11)
- [34970](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34970) t/SuggestionEngine_AuthorityFile.t does not do anything with Test::DBIx::Class (23.11.00,23.05.05,22.11.11)
- [35041](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35041) Fix Jenkins failure on t_db_dependent_Koha_Patron_t (23.11.00)
- [35042](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35042) Members.t: should not set datelastseen to NULL everywhere (23.11.00,23.05.05,22.11.12)
- [35215](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35215) Make a few assumptions more explicit in Suggestions.t (23.11.00,23.05.06)
- [35393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35393) Fix Objects.t for a Jenkins failure when run just after midnight (23.11.00)
- [22135](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22135) Inventory tool doesn't export "out of order" problem to CSV (23.11.00,23.05.04,22.11.10)
  >This fixes the export of inventory results when "Check barcodes list for items shelved out of order" is selected. Currently, the problem column is blank for items shelved out of order when it should be "Shelved out of order".
- [29762](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29762) Patron batch modification tool - mobile phone number column naming (23.11.00,23.05.02,22.11.08)
- [32048](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32048) Calendar adding holidays repeated (23.11.00,23.05.04,22.11.11)
- [33667](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33667) 'Copy to all libraries' doesn't work on editing holidays (23.11.00,23.05.02,22.11.08)

  **Sponsored by** *Koha-Suomi Oy*
- [33972](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33972) Remove unnecessary batch status change in C4::ImportBatch (23.11.00,23.05.02,22.11.08)
- [33987](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33987) Combine multiple db updates in C4::ImportBatch::BatchCommitRecords for efficiency/avoiding possible deadlocks (23.11.00,23.05.02,22.11.08)
- [33989](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33989) Inventory tool performs unnecessary authorized value lookups (23.11.00,23.05.02,22.11.08)
- [34220](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34220) Running log viewer for only Catalog module loads wrong side navbar (23.11.00,23.05.02,22.11.08)
- [34225](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34225) KohaTable broken on batch item deletion and modification results (23.11.00,23.05.02)
- [34716](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34716) Typo in tools/stockrotation.tt (23.11.00,23.05.05,22.11.11)
- [34732](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34732) Barcode image generator doesn't generate correct Code39 barcode (23.11.00,23.05.04,22.11.11)
- [34822](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34822) BatchUpdateBiblioHoldsQueue should be called once per import batch when using RealTimeHoldsQueue (23.11.00,23.05.05,22.11.11)
- [34939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34939) When manually entering dates in flatPickr the hour and minute get set to 00:00 not 23:59 (23.11.00,23.05.05,22.11.11)
- [34467](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34467) OAI GetRecord bad encoding for UNIMARC (23.11.00,23.05.05,22.11.11)

## New system preferences

- AcquisitionsDefaultEMailAddress
- AcquisitionsDefaultReplyTo
- AdditionalFieldsInZ3950ResultAuthSearch
- AuthorLinkSortBy
- AuthorLinkSortOrder
- AutomaticCheckinAutoFill
- CalculateFundValuesIncludingTax
- CancelOrdersInClosedBaskets
- ChildNeedsGuarantor
- CookieConsent
- CookieConsentedJS
- DefaultAuthorityTab
- DefaultPatronSearchMethod
- EmailPatronWhenHoldIsPlaced
- ForceLibrarySelection
- ILLModuleDisclaimerByType
- ILLPartnerCode
- LoadCheckoutsTableDelay
- OpacTrustedCheckout
- PreservationModule
- PreservationNotForLoanDefaultTrainIn
- PreservationNotForLoanWaitingListIn
- RedirectGuaranteeEmail
- SCOLoadCheckoutsByDefault
- SIP2AddOpacMessagesToScreenMessage
- SerialsDefaultEMailAddress
- SerialsDefaultReplyTo
- SerialsSearchResultsLimit
- TrackLastPatronActivityTriggers
- UpdateItemLocationOnCheckout
- showLastPatronCount

## Deleted system preferences

- AllowOfflineCirculation
- OPACResultsSidebar
- OpacMaintenanceNotice
- OpacSuppressionMessage
- PatronSelfRegistrationAdditionalInstructions
- RecordedBooksClientSecret
- RecordedBooksDomain
- RecordedBooksLibraryID
- SCOMainUserBlock
- SelfCheckHelpMessage
- SelfCheckInMainUserBlock
- TrackLastPatronActivity

## New Authorized value categories

- ERM_REPORT_TYPES
- ERM_PLATFORM_REPORTS_METRICS
- ERM_DATABASE_REPORTS_METRICS
- ERM_TITLE_REPORTS_METRICS
- ERM_ITEM_REPORTS_METRICS
- VENDOR_ISSUE_TYPE

## New letter codes

- HOLDDGST
- HOLDPLACED_PATRON
- MEMBERSHIP_RENEWED
- PRES_TRAIN_ITEM

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.11//html/) (53%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (41%)
- [German](https://koha-community.org/manual/23.11/de/html/) (43%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (71%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (68%)
- Armenian (90%)
- Bulgarian (76%)
- Chinese (Traditional) (90%)
- Dutch (70%)
- English (100%)
- English (New Zealand) (72%)
- Finnish (90%)
- French (90%)
- French (Canada) (90%)
- German (100%)
- German (Switzerland) (52%)
- Hindi (90%)
- Italian (81%)
- Norwegian Bokmål (57%)
- Persian (90%)
- Polish (90%)
- Portuguese (Brazil) (90%)
- Portuguese (Portugal) (71%)
- Russian (85%)
- Slovak (56%)
- Spanish (100%)
- Swedish (63%)
- Telugu (69%)
- Turkish (81%)
- Ukrainian (77%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.11.00 is

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
  - Andrii Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize
  - ERM -- Pedro Amorim
  - ILL -- Pedro Amorim

- Bug Wranglers:
  - Aleisha Amohia

- Packaging Manager: Mason James

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.05 -- Fridolin Somers
  - 22.11 -- PTFS Europe (Matt Blenkinsop, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Danyon Sewell

- Release Maintainer assistants:
  - 21.11 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.11.00
<div style="column-count: 2;">

- Auckland University of Technology
- [Banco Central de la República Argentina](https://bcra.gob.ar)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)
- [Bibliothèque Universitaire des Langues et Civilisations (BULAC)](http://www.bulac.fr)
- [ByWater Solutions](https://bywatersolutions.com)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Education Services Australia SCIS
- Fire and Emergency New Zealand
- Gothenburg University Library
- [Karlsruhe Institute of Technology (KIT)](https://www.kit.edu)
- Keratsini-Drapetsona Municipal Library, Greece
- [Koha-Suomi Oy](https://koha-suomi.fi)
- National Library of Finland
- New Zealand Council for Educational Research
- [PTFS Europe](https://ptfs-europe.com)
- Pymble Ladies' College
- Rijksmuseum, Netherlands
- South Taranaki District Council
- Steiermärkische Landesbibliothek
- The Research University in the Helmholtz Association (KIT)
- Toi Ohomai Institute of Technology
- Waikato Institute of Technology
</div>

We thank the following individuals who contributed patches to Koha 23.11.00
<div style="column-count: 2;">

- Aleisha Amohia (32)
- Pedro Amorim (136)
- Tomás Cohen Arazi (254)
- Stefan Berndtsson (1)
- Matt Blenkinsop (100)
- Philippe Blouin (3)
- Jérémy Breuillard (2)
- Alex Buckley (10)
- Kevin Carnes (1)
- Aude Charillon (1)
- Nick Clemens (142)
- David Cook (58)
- Jake Deery (2)
- Frédéric Demians (2)
- Jonathan Druart (247)
- Magnus Enger (2)
- Laura Escamilla (11)
- Katrin Fischer (113)
- Emily-Rose Francoeur (3)
- Géraud Frappier (1)
- Lucas Gass (72)
- Salah Ghedds (1)
- Evan Giles (1)
- Victor Grousset (12)
- Thibaud Guillot (6)
- Amit Gupta (1)
- David Gustafsson (10)
- Michał Górny (1)
- Michael Hafen (5)
- Kyle M Hall (84)
- Mark Hofstetter (1)
- Andrew Isherwood (1)
- Mason James (4)
- Andreas Jonsson (3)
- Janusz Kaczmarek (1)
- Jan Kissig (2)
- Olli-Antti Kivilahti (1)
- Michał Kula (1)
- Emily Lamancusa (19)
- Per Larsson (1)
- Sam Lau (7)
- Brendan Lawlor (1)
- Owen Leonard (241)
- Julian Maurice (19)
- Matthias Meusburger (4)
- Fabricio Molina (2)
- Agustín Moyano (2)
- David Nind (11)
- Jacob O'Mara (2)
- Philip Orr (1)
- Martin Renvoize (211)
- Phil Ringnalda (3)
- David Roberts (1)
- Adolfo Rodríguez (1)
- Marcel de Rooy (158)
- Caroline Cyr La Rose (28)
- Andreas Roussos (6)
- Slava Shishkin (1)
- Fridolin Somers (18)
- Raphael Straub (1)
- Arthur Suzuki (4)
- Petr Svoboda (1)
- Zeno Tajoli (1)
- Emmi Takkinen (15)
- Lari Taskula (13)
- Koha translators (1)
- Pascal Uphaus (2)
- George Veranis (2)
- Hinemoea Viault (1)
- Shi Yao Wang (1)
- Hammat Wele (16)
- Wainui Witika-Park (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.00
<div style="column-count: 2;">

- Athens County Public Libraries (241)
- BibLibre (53)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (113)
- ByWater-Solutions (309)
- Catalyst (13)
- Catalyst Open Source Academy (31)
- Chetco Community Public Library (3)
- Cineca (1)
- clamsnet.org (1)
- Dataly Tech (8)
- David Nind (11)
- gentoo.org (1)
- gwdg.de (2)
- Göteborgs Universitet (11)
- hofstetter.at (1)
- Hypernova Oy (13)
- Independant Individuals (19)
- Informatics Publishing Ltd (1)
- Karlsruhe Institute of Technology (KIT) (1)
- Koha Community Developers (260)
- Koha-Suomi (13)
- KohaAloha (4)
- Kreablo AB (3)
- Libriotech (2)
- lmscloud.de (1)
- montgomerycountymd.gov (19)
- Prosentient Systems (58)
- PTFS-Europe (452)
- R-Bit Technology (1)
- Rijksmuseum (158)
- Solutions inLibro inc (54)
- Tamil (2)
- th-wildau.de (2)
- Theke Solutions (258)
- ub.lu.se (1)
- users.noreply.github.com (1)
- Xercode (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- AlexanderBlanchardAC (1)
- Aleisha Amohia (9)
- Pedro Amorim (40)
- Tomás Cohen Arazi (1840)
- Andrew Auld (14)
- Alexander Blanchard (2)
- Matt Blenkinsop (28)
- Christopher Brannon (1)
- Univ Brest (1)
- Emmanuel Bétemps (1)
- Barry Cannon (1)
- Catrina (1)
- Christine (1)
- Nick Clemens (221)
- Rebecca Coert (1)
- David Cook (35)
- Chris Cormack (15)
- Ray Delahunty (2)
- Michal Denar (12)
- Paul Derscheid (4)
- Jonathan Druart (172)
- Sharon Dugdale (1)
- ebal (1)
- Eesther (2)
- Danielle M Elder (4)
- Magnus Enger (1)
- Laura Escamilla (11)
- Jeremy Evans (1)
- Christina Fairlamb (1)
- Jonathan Field (6)
- Katrin Fischer (572)
- Toni Ford (6)
- Emily-Rose Francoeur (13)
- Andrew  Fuerste-Henry (1)
- Andrew Fuerste-Henry (30)
- Lucas Gass (108)
- Amaury GAU (1)
- Salah Ghedda (8)
- Nicolas Giraud (1)
- Stephen Graham (4)
- Victor Grousset (67)
- Kyle M Hall (150)
- Stina Hallin (2)
- Katariina Hanhisalo (3)
- Frank Hansen (1)
- Sally Healey (3)
- hebah (1)
- Juliet Heltibridle (1)
- Heather Hernandez (37)
- Amanda Hovey (1)
- BULAC - http://www.bulac.fr/ (35)
- Inkeri (1)
- Brandon J (1)
- Jason (1)
- Barbara Johnson (10)
- Janusz Kaczmarek (5)
- Jan Kissig (1)
- Thomas Klausner (1)
- Päivi Knuutinen (2)
- Kristi Krueger (2)
- Rhonda Kuiper (1)
- Tuomas Kunttu (1)
- Emily Lamancusa (41)
- Rachael Laritz (1)
- Sam Lau (133)
- Brendan Lawlor (3)
- Nicolas Legrand (2)
- Owen Leonard (98)
- Kelly McElligott (47)
- Janet McGowan (35)
- Silvia Meakins (13)
- Michaela (3)
- Johanna Miettunen (5)
- Agustín Moyano (1)
- Christian Nelson (4)
- Georgia Newman (1)
- Solene Ngamga (1)
- nicolas (2)
- David Nind (294)
- Andrew Nugged (1)
- Andrii Nugged (1)
- Björn Nylén (2)
- Laura ONeil (2)
- Philip Orr (7)
- Dominic Pichette (1)
- Reetta Pihlaja (1)
- Paul Poulain (2)
- Quinn (1)
- Laurence Rault (77)
- Martin Renvoize (272)
- Phil Ringnalda (18)
- Marcel de Rooy (324)
- Caroline Cyr La Rose (72)
- Andreas Roussos (3)
- Lisette Scheer (5)
- Michaela Sieber (92)
- Fridolin Somers (5)
- Edith Speller (5)
- Christian Stelzenmüller (2)
- Emmi Takkinen (10)
- Lari Taskula (1)
- Clemens Tubach (1)
- Ed Veal (1)
- Hinemoea Viault (1)
- Alexander Wagner (1)
- Chris Walton (1)
- George Williams (1)
- Jessica Zairo (66)
- Anneli Österman (4)
</div>

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Notes from the Release Manager

Another busy release cycle.

Thanks to everyone for the chance to be part of this, and for being around
when the team needed you.

Special thanks to:

- Brendan, Nate and Cindy
- my ByWater colleages for their unconditional support
- Katrina
- Martin and Pedro
- Andrii
- Jonathan and Loup

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is master.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 30 Nov 2023 18:21:04.
