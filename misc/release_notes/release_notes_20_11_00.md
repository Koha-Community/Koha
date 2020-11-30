# RELEASE NOTES FOR KOHA 20.11.00
27 Nov 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.00 is a major release, that comes with many new features.

It includes 9 new features, 354 enhancements, 412 bugfixes.

A new <b>Technical highlights</b> section is included at the bottom of these notes for those seeking a short summary of the more technical changes included in this release.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian 9 (Stretch) with MariaDB 10.1
- Debian 10 (Buster) with MariaDB 10.3
- Debian 11 (Bullseye) with MariaDB 10.3 (Experimental)
- Ubuntu 18.04 (Bionic) with MariaDB 10.1
- Ubuntu 20.04 (Focal) with MariaDB 10.3
- Debian Stretch with MySQL 8.0 (Experimental MySQL 8.0 support)

Additional notes:
    
- Perl 5.10 is required (5.24 is recommended)
- Zebra or Elasticsearch is required


## New features

### Architecture, internals, and plumbing

- [[22417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22417) Add a task queue

  >There are long standing issues in Koha when working under Plack. Some scripts are only running in CGI mode.
  >In this first step we are introducing RabbitMQ (a message broker) to deal with asynchronous tasks.
  >
  >In this first iteration we are adapting the batch update record tools (both biblio and authority) to use it.
  >A list of the jobs that have been or is being processed is available, see the new view at /admin/background_jobs.pl.

### Circulation

- [[21946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21946) Group circulation by item type

  >This feature adds the ability to define some itemtypes as 'parent' to other item types for defining circulation limits.
  >
  >This allows to create 'groups' of related items types. E.g. - a library has both Blu-ray and DVD itemtypes - these can be grouped under the 'Media' itemtype. The checkout limit for Media will then apply to both Blu-ray and DVD. 
  >
  >So if a library says a patron can have 4 dvds - 4 blu-ray - and sets Media to have a limit of 4 then patrons can have up to 4 items of either type (e.g. 1 DVD, 3 blu-rays) but will be prevented from checking out more of either type by the limit on the parent.
  >
  >Parent rules only apply to checkout limits.
- [[25534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25534) Add ability to specifying and store a reason when cancelling a hold

  >This new feature adds an option to allow staff to add a reason for cancellation when cancelling a hold.
  >
  >The new 'CANCELLATION_REASON' authorized value is used to provide a configurable pick list of reasons.
  >
  >Optionally, the library may choose to define a 'HOLD_CANCELLATION' notice which will be sent whenever a cancellation reason is assigned.

### Fines and fees

- [[19036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19036) Number payment receipts / payment slips

### ILL

- [[22818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22818) ILL should be able to send notices

  **Sponsored by** *PTFS Europe*

  >This patch adds the ability for ILL to send notices, both triggered by staff and triggered by events.
  >
  >Staff can trigger notices to patrons from the "Manage ILL request" screen:
  >- ILL request ready for pickup
  >- ILL request unavailable
  >- Place request with partners
  >
  >The following notices to staff are triggered automatically:
  >- Request has been modified by patron
  >- Request has been cancelled by patron
  >
  >Branches can now specify an "ILL email" address to which notices intended to inform staff of changes to requests by patrons can be sent.
  >
  >The sending of notices is controlled by a few new sysprefs:
  >- "ILLDefaultStaffEmail" - Fallback email address for staff ILL notices
  >to be sent to in the absence of a branch address
  >- "ILLSendStaffNotices" - To specify which staff notices should be sent
  >automatically when requests are manipulated by patrons
  >
  >Patron notices are also controlled by the patron's messaging
  >preferences.

### Patrons

- [[24151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24151) Add a pseudonymization process for patrons and transactions

  **Sponsored by** *Association KohaLa*

  >This new feature adds a way to pseudonymize patron data, in a way that it will not be able to identify the person (https://en.wikipedia.org/wiki/Pseudonymization)
  >
  >There are different existing ways to anonymize patron information in
  >Koha, but by removing information we loose the ability to make useful reports. 
  >
  >This development introduces two new tables:
  >  * pseudonymized_transactions for transactions and patron data 
  >  * pseudonymized_borrower_attributesfor patron attributes 
  >Entries to pseudonymized_transactions are added when a new transaction (checkout, checkin, renew, on-site checkout) is done.
  >The table anonymized_borrower_attributes is populated if patron attributes are marked as "keep for pseudonymization".
  >
  >To make things configurable, three system preferences have been added:
  >  * Pseudonymization to turn on/off the whole feature
  >  * PseudonymizationPatronFields to list the information of the patrons to synchronize
  >  * PseudonymizationTransactionFields to list the information of the transactions to copy

### System Administration

- [[22343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22343) Add configuration options for SMTP servers

  >This patchset adds the ability to set SMTP servers and then pick them for using on each library when sending notices, cart, etc.
  >
  >SSL/TLS authentication is supported [*]
  >
  >A new administration page is added for managing the servers.
  >
  >
  >[*] ssl_mode=starttls is not supported under Ubuntu 16 due to old library versions.
- [[26290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26290) Add the ability to set a default SMTP server in koha-conf.xml

  >With this enhancement, systems administrators can set a default/global SMTP configuration when creating the Koha instance, or by manually editing the koha-conf.xml.

### Tools

- [[23019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23019) Ability to create 'matching profiles' when importing records

## Enhancements

### About

- [[26425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26425) Fix history.txt once and for all

### Acquisitions

- [[15329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15329) Show budget in addition to fund for late orders in acquisition

  >Adds a new column with the budget name to the late orders table in acquisitions. This will be helpful in combination with the already displayed fund.
- [[21882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21882) Add price column to acquisition details tab in staff interface
- [[21898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21898) Add basket info available for ACQORDER

  >This enhancement adds the aqbasket variable to the AQORDER notice processor. 
  >
  >This allows users to utilise basket details in the subject and content of their `AQORDER` notices.
- [[23420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23420) Add "SuggestionsUnwantedFields" to hide fields from the suggestions form

  >This enhancement allows a library to configure the visibility of the input fields on the OPAC suggestion form.
  >
  >**New system preference**: `OPACSuggestionUnwantedFields`
  >
  >**Removed system preference**: `AllowPurchaseSuggestionBranchChoice`
- [[23682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23682) Add ability to manually import EDI invoices as an alternative to automatic importing on download
- [[24157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24157) Additional acquisitions permissions

  **Sponsored by** *Galway-Mayo Institute of Technology*

  >Add more granularity in the acquisition permissions:
  >- reopen_closed_invoices to reopen and close invoices
  >- edit_invoices to edit invoices
  >- delete_invoices to delete invoices
  >- merge_invoices to merge invoices
  >- delete_baskets to delete baskets
- [[25033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25033) Counts of suggestions are confusing

  >This patch adds to the simple count of all suggestions in the system with a count filtered by the users branch. This means that on the homepage and other areas a user will see a count of local suggestions and total suggestions in the system.
  >
  >Previously clicking the link to suggestions would take the user to a page showing fewer suggestions that counted in the link. Now these numbers should be more consistent.
- [[26014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26014) Add publication year and edition to Z39.50 results in acquisition
- [[26089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26089) Add acquisitions-related reports to acquisitions sidebar menu

  >This patch modifies the menu shown in the sidebar of some acquisitions pages so that in contains links to these acquisitions-related reports: Acquisitions statistics wizard and Orders by fund.
- [[26503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26503) Allow to limit on standing orders in acquisition advanced search
- [[26582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26582) Add Koha::Acquisition::Basket->close
- [[26680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26680) Update (rcvd) to (received) with its own class in basket view
- [[26712]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26712) Set focus for cursor to basket name input box on basketheader.pl

  >This patch modifies the form for creating a new basket in acquisitions so that the user's cursor is automatically placed in the first field, the basket name input.
- [[26729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26729) When adding a new vendor set focus for cursor to name input box

  >This patch modifies the form for creating a new vendor in acquisitions so that the user's cursor is automatically placed in the first field, the vendor name input.

### Architecture, internals, and plumbing

- [[16357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16357) Plack error logs are not time stamped

  >This enhancements adds timestamped logs for Plack-enabled Koha, which makes it easier for system administrators to review warnings and errors in Koha.
- [[20582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20582) Turn Koha into a Mojolicious application

  >This allows to run Koha as a Mojolicious application. It's a first step towards rewriting CGI code as Mojolicious controllers, for cleaner code and more testability.
  >It's designed for developers only at this point, and should not be used in production.
- [[21395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21395) Make perlcritic happy
- [[22393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22393) Remove last remaining manualinvoice use
- [[22394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22394) Remove C4::Accounts::manualinvoice
- [[23070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23070) Use Koha::Hold in C4::Reserves::RevertWaitingStatus
- [[23092]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23092) Add 'daterequested' to the transfers table
- [[23166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23166) Simplify code related to orders in catalogue/*detail.pl
- [[23376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23376) Cleanup order receive page code
- [[23632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23632) Remove C4::Logs::GetLogs
- [[23895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23895) Tidy up the directories under installer/data/mysql/

  >The sql installer files that was present in installer/data/mysql have been moved in a 'mandatory' subdirectory.
  >For instance, installer/data/mysql/sysprefs.sql is now in installer/data/mysql/mandatory/sysprefs.sql
- [[25067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25067) Move PO file manipulation code into gulp tasks
- [[25070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25070) Include files to display address and contact must be refactored

  >This internal change simplifies the code for editing and displaying patron address and contact information. It removes duplicated code, reducing potential problems when the code is changed in the future.
  >
  >For example, there are currently 5 include files for each value of the address format (us, de, fr) with the code duplicated for each language. The change reduces the need for 5*3 files to 5 files.
- [[25114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25114) Remove duplicated logic from GetLoanLength()
- [[25287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25287) Add columns_settings support to API datatables wrapper

  >Tables are starting to use the new API to build their contents. This is done by using the API datatables wrapper. This development makes this wrapper support the current columns settings feature.
- [[25333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25333) Change message transport type for Talking Tech from "phone" to "itiva"

  >The itiva notices operate in a manner that is specific to itiva, the actual notices themselves are generated and handled by custom scripts only used for itiva.
  >
  >In order to allow integration with other phone notice vendors these patches rename the existing 'phone' message transport type to 'itiva'
- [[25334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25334) Add generic 'phone' message transport type

  >Previously the 'phone' message transport in Koha was tied to itiva and was not adaptable to other vendors. In this version that transport is renamed 'itiva' and we add a new 'phone' type that generates notices in the same manner as email, sms and print notices. Koha on it's own will not do anything with these notices. Instead, you will need a plugin such as https://github.com/bywatersolutions/koha-plugin-twilio-voice to handle making the phone calls and updating the notice status.
- [[25663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25663) Koha::RefundLostItemFeeRules should be merged into Koha::CirculationRules
- [[25723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25723) Improve efficiency of holiday calculation
- [[25998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25998) Add 'library' relation to Koha::Account::Line
- [[26132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26132) Improve readability of TooMany
- [[26133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26133) Unneeded calls in detail.pl can be removed
- [[26141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26141) Duplicated code in search.pl
- [[26251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26251) Remove unused routines from svc/split_callnumbers
- [[26268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26268) Remove items.paid for once and for all

  >The `paid` field in the `items` table is removed with this patch to prevent accidental re-introduction of syncing code and overhead.  The only place where the value is surfaced in the UI has been replaced with an on-demand calculated value.
- [[26325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26325) Add primary_key_exists function to Installer.pm
- [[26394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26394) .mailmap needs to be updated

  >The .mailmap file is used to map author and committer names and email addresses to canonical real names and email addresses. It has been improved to reflect the current project's history.
  >It helps to have a cleaner authors list and prevents duplicate
  >http://git.koha-community.org/stats/koha-master/authors.html
- [[26432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26432) Remove unused ModZebrations
- [[26485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26485) Simplify itemnumber handling in returns.pl
- [[26515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26515) Add Koha::Acquisition::Order->cancel

  **Sponsored by** *ByWater Solutions*
- [[26524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26524) Add Koha::Acquisition::Basket->orders
- [[26555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26555) Add a way for Koha::Object(s) to carry execution information

  >This enhancement adds a standardised way to pass execution information around within Koha::Objects.
  >
  >Execution data should be set by action methods calling `$self->add_message({ message => $message, type => $type, payload => $payload });` inside the action method.
  >
  >The caller can then access the execution data using `my $messages = $object->messages;`
- [[26577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26577) Make basket.pl and cancelorder.pl use $order->cancel

  >This patch refactors order cancelling code usage to prepare the ground for code cleanup.
- [[26579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26579) Remove unused C4::Acquisition::DelOrder function
- [[26580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26580) Remove unused C4::Acquisition::DelBasket function
- [[26584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26584) Remove unused C4::Acquisition::CloseBasket function
- [[26600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26600) Missing module in Indexer.pm
- [[26621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26621) .mailmap adjustments
- [[27002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27002) Make Koha::Biblio->pickup_locations return a Koha::Libraries resultset

### Cataloging

- [[5428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5428) Back to results after deleting a record

  >After deleting a bibliographic record in the cataloguing module the cataloguer will now be redirected back to the search results list if they had any, instead of the empty search form.
- [[12533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12533) Improve authority search result display

  >This patch changes authority record search results, linking each heading to the corresponding detail page, and adding column in the results table showing the heading type.
- [[15851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15851) Only display "Analytics: Show analytics" when records have linked analytics

  **Sponsored by** *Orex Digital*

  >This development changes how the _Show analytics_ link is displayed in both OPAC and staff interface.
  >
  >The main changes are:
  >* It is only displayed if it would actually have results (right now it always shows, and the link can point to empty results)
  >* It is no longer constrained to serials: _collections_, _subunits_, _integrating resources_, _monographs_ and _serials_, all will display the link.
  >
  >New CSS classes are added for each material type:
  >
  >* _analytic_collection_
  >* _analytic_subunit_
  >* _analytic_ires_
  >* _analytic_monograph_
  >* _analytic_serial_
  >
  >This way, libraries that wish to only display those links for serials (for example), can hide them for other resources:
  >
  >```
  >.analytic_collection .analytic_subunit .analytic_ires .analytic_monograph { display: none };
  >```
  >
  >This CSS classes can be used in both OPAC and admin interface.
- [[15933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15933) Add cataloguing plugin to search for existing publishers in other records

  >This patch adds the option to enable an autocomplete search for publisher name on the 260$b or 264$b input fields in the basic MARC editor.
- [[16314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16314) Show upload link for upload plugin in basic MARC editor
- [[20154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20154) Stay in the open tab when editing authority record
- [[22399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22399) Improve responsive behavior of the basic marc editor
- [[24134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24134) Add placeholder for 2 digit years to allow autogeneration of dates in 008
- [[24176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24176) Show the date of the last circulation in the items table in the staff interface
- [[25728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25728) Add the ability to create a new authorised value within the cataloguing module

  **Sponsored by** *Orex Digital*

  >When a librarian is cataloguing a bibliographic record and needs a new authorised value, they will now be able to create it directly from the edit form.
  >It also works on the item and authority editing forms.
  >They will need the necessary permission: manage_authorised_values.
- [[26145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26145) Add the ability to attach a cover image at item level

  **Sponsored by** *Gerhard Sondermann Dialog e.K. (presseplus.de, presseshop.at, presseshop.ch)*

  >If LocalCoverImages is turned on, it will now be possible to attach a local cover images for an item.
  >It can be especially useful for subscriptions. One cover image could be attach per serial number.
  >The cover images will be displayed on the item list table on the bibliographic record detail page.

### Circulation

- [[12656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12656) Allow a CANCELLATION_REASON to be specified on the cancel_expired_holds.pl job

  >These patches add a --reason flag to the cancel expired reserves cronjob. 
  >
  >If a reason is provided the cronjob will trigger a HOLD_CANCELLATION notice for the patron if one is configured.
  >
  >The reason will be available in the notice template to allow custom messages to be sent
- [[14866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14866) Make high holds work with different item types and number of open days

  **Sponsored by** *Catalyst*

  >This patch adds a new circulation rule - decreaseloanholds - which will override the value set in the decreaseLoanHighHoldsDuration system preference for specific item types, or patron categories, or branches.
- [[15780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15780) Include inventory number in patron account summary print
- [[16112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16112) Specify renewal date for batch renew

  >Add the ability to define the due date during a batch renew.
  >Like bug 16748 for batch checkout.
- [[16748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16748) Batch checkout needs set due date

  >Add the ability to specify the due date during a batch checkout, to prevent the default loan period to be used.
- [[19351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19351) Add copynumber in the checkouts table in staff interface
- [[19382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19382) Add ability to block guarantees based on fees owed by guarantor and other guarantees
- [[20469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20469) Add item status to staff article requests form
- [[21750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21750) Move collection to its own column in checkins table
- [[23916]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23916) Issuer should be recorded and visible in patron circulation history

  >This new enhancement enables the recording, and subsequent display, of who checked out an item. When viewing a checkout in a patron's circulation history and an item's checkout history, details of who carried out the checkout is displayed. The recording of this information is controlled by the new system preference "RecordStaffUserOnCheckout".
- [[23979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23979) "Account is locked" message should be displayed on all patron pages

  >This patch alters the display to show a message on all patron screens when a patron is locked out of their account due to too many login attempts or has an administrative lock.
  >
  >Login attempt locks are controlled by the 'FailedLoginAttempts' system preference
  >
  >Administrative locks are related to GDPR settings.
- [[24083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24083) Koha should support "seen" vs "unseen" renewals

  >This new feature allows the library to keep track of how many times an item has been renewed but not actually seen by the library, typically through renewing online.
  >
  >Additionally, this allows the library to set their circulation rules to require regular 'seen' renewals and thus prevent patrons from continually renewing an item which may actually have been lost.
- [[24159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24159) Allow daysMode for calculating due and renewal dates to be set at the circulation rules level

  **Sponsored by** *Institute of Technology Carlow*

  >This new enhancement is adding the ability to make hourly loan returned on a closed day, if checked out on the same close day.
  >
  >The useDaysMode system preference has been moved to a circulation rule to add more flexibility in the calculation of the due date.
- [[24201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24201) Attach desk to intranet session

  >When `UseCirculationDesks` is enabled and desks are defined and attached to a library, this feature makes it possible to chose your current desk on login or when changing library from the intranet. The desk is then attached to the session.
  >
  >Future developments are planned to allow associating hold pickup locations with desks and other features.
- [[25232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25232) Add ability to skip trapping items with a given notforloan value

  >This feature adds the system preference SkipHoldTrapOnNotForLoanValue. Adding a notforloan value to this system preference prevents items with that notforloan value from triggering holds at checkin, allowing for a temporary quarantine or any other circumstance in which an item should be temporarily delayed from circulation. This presents a more customizable alternative to the existing TrapHoldsOnOrder system preference.
- [[25261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25261) Multiple parts handling - confirmation alert

  **Sponsored by** *PTFS Europe* and *Royal College of Music*

  >This enhancement adds the option to require staff members to confirm that an item contains all its listed parts at check-in/check-out time.
  >
  >New system preference: `CircConfirmItemParts`
- [[25430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25430) Improve the styling of the claims returned tab
- [[25699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25699) Add edition information to Holds to pull report
- [[25717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25717) Improve messages for automatic renewal errors

  >This change improves the wording and grammar for automatic renewal error messages.
- [[25798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25798) Copyright year to Holds to pull report
- [[25799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25799) Edition information to Holds queue report
- [[25907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25907) When cancelling a waiting hold on returns.pl, looks for new hold to fill without rescanning barcode
- [[26424]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26424) Better performance of svc/checkouts
- [[26501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26501) Article requests: Add datatables to requests form in staff client
- [[26643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26643) Staff should be notified that a transfer has been completed on checkin

  >This patch introduces a notification message on the check-in screen to highlight when the check-in has resulted in the completion of a transfer.
- [[26694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26694) Set focus for cursor to search input box on guarantor_search.pl

### Command-line Utilities

- [[21111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21111) Add --exclude-indexes option to koha-run-backups
- [[21591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21591) Data inconsistencies - Item types and biblio level

  >When an item does not have an itemtype and the record (biblioitem) also has no itemtype defined the data inconsistencies script would error rather than reporting.
  >
  >We add a test for missing record level itemtypes so that we can correctly report these problems too.
- [[23696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23696) build_oai_sets.pl should take biblios from deletedbiblio_metadata too
- [[24152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24152) Add the ability to purge pseudonymized data

  **Sponsored by** *Association KohaLa*
- [[24153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24153) Add a confirm flag to the cleanup_database.pl cronjob

  **Sponsored by** *Association KohaLa*

  >This enhancement adds a --confirm flag to the cleanup_database.pl cronjob, that allows a dry-run mode with a verbose output.
- [[24306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24306) Add debug option to koha-indexer

  >These patches add a --debug switch to the koha-indexer script. This will vastly increase the logging output of the rebuild zebra daemon. This information may be useful for determining why some records are not being indexed.
- [[25511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25511) Add --force option to update_dbix_class_files.pl

  >Sometimes, if you know what you are doing, you may want to force a schema overwrite regardless of whether the hashes report there are changes above the fold.
  >
  >In these cases, we should expose said functionality via a --force option on the script.
  >
  >***WARNING***: Use this at your own risk.. it's helpful if you are maintaining a fork or in other such cases. You should always attempt to run the script without force first and only resort to using force if that fails. It is also very much worthwhile checking the diff after running with force to ensure you have not resulted in any unexpected changes.
- [[25624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25624) Update patrons category script should allow finding null and not null and wildcards
- [[26175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26175) Remove warn if undefined barcode in misc/export_records.pl
- [[26451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26451) Small typo in bulkmarcimport.pl
- [[26641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26641) link_bibs_to_authorities.pl: Add the ability to specify the MARC field to operate on

### Course reserves

- [[14648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14648) Batch remove reserve items

  >This allows to batch remove items from any course reserve they have been added to using a barcode list. Access the new feature using the "Batch remove reserves" button on the course reserves module start page.
- [[25606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25606) Adds "Remove all reserves" button to course details
- [[26880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26880) Add explanatory text to Add course reserve screens

### Database

- [[13535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13535) Table alert is missing FK and not deleted with the patron

### Fines and fees

- [[8338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8338) Add ability to remove fines with dropbox mode

  >This enhancement will remove any overdue fines that would be reversed on a backdated return if CalcFineOnBackdate is enabled and the user has not already attempted to pay off the accruing fine.
- [[23091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23091) Add options to charge new or restore forgiven overdues when a lost item is returned

  >This new feature allows libraries using the existing WhenLostForgiveFine functionality to reinstate forgiven overdue fines if a lost item is found and the lost item fee is refunded. Specifically, this adds two new options to the lost item fee refund on return policy dropdown in circulation rules.  When a lost item is found and the fee refunded, a forgiven overdue fine can be restored in its original accountlines entry or re-created as a new accountlines entry.
- [[24603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24603) Allow to cancel charges in patron accounting

  >This allows to cancel charges that have not been paid in full or partially yet. A cancelled charge will show up as cancelled in the account. Voiding a paid charge first will then allow to cancel it afterwards.
- [[24610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24610) Let user switch between 'Pay' and 'Write off' mode
- [[24786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24786) Allow setting a cash register for a login session and configuring library-default cash registers
- [[26160]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26160) Add column configuration to the Point of sale, Items for purchase table
- [[26172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26172) Add a cashup summary view (with option to print)
- [[26327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26327) Include checkout library in fines

  >This patch adds a new column in the accounting tables for a patron. The column will show the checkout library for charges that are tied to circulation.
- [[26506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26506) Koha::Account::pay will fail if $userenv is not set

### Hold requests

- [[19889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19889) LocalHoldsPriority needs exclusions

  **Sponsored by** *Cooperative Information Network (CIN)*
- [[22789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22789) Establish non-priority holds
- [[23820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23820) Club hold pickup locations should be able to default to patron's home library

  **Sponsored by** *South East Kansas Library System*
- [[24412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24412) Attach waiting hold to desk

  >When `UseCirculationDesks` is enabled and desks are defined and attached to a library, this feature makes it possible to attach a waiting reserve to a desk: when an item is checked in and marked as a waiting reserve, it is also attached to the current desk. The desk is then displayed in the intranet document request page, the intranet borrower holds tab, the item list of the document bibliographic details and the borrower's OPAC holds tab. You can move waiting reserve from desk to desk by checking in again the item at a different desk.
- [[25892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25892) Clarify the visual hierarchy of holds by library and itemtype
- [[26281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26281) Add cancellation reason to holds history

  >This adds the new column for cancellation reason to the holds history page in the staff interface. See bug 25534 for more details on the new hold cancellation reason feature.

### I18N/L10N

- [[25317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25317) Move translatable strings out of additem.js.inc
- [[25320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25320) Move translatable strings out of merge-record-strings.inc into merge-record.js
- [[25321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25321) Move translatable strings out of strings.inc into the corresponding JavaScript
- [[25351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25351) Move cart-related strings out of opac-bottom.inc and into basket.js
- [[25443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25443) Improve translation of "Select the host record to link%s to"
- [[25687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25687) Switch Y/N in EDI accounts table for Yes and No for better translatability
- [[25922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25922) aria-labels are currently not translatable
- [[26065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26065) Move translatable strings out of marc_modification_templates.tt and into marc_modification_templates.js
- [[26118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26118) Move translatable strings out of tags/review.tt and into tags-review.js
- [[26217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26217) Move translatable strings out of templates into acq.js
- [[26225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26225) Move translatable strings out of audio_alerts.tt and into audio_alerts.js
- [[26229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26229) Move translatable strings out of categories.tt and into categories.js
- [[26230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26230) Move translatable strings out of item_search_fields.tt and into item_search_fields.js
- [[26237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26237) Move translatable strings out of preferences.tt and into JavaScript files
- [[26240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26240) Move translatable strings out of sms_providers.tt and into sms_providers.js
- [[26242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26242) Move translatable strings out of results.tt and into results.js
- [[26243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26243) Move translatable strings out of templates and into circulation.js
- [[26256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26256) Move translatable strings out of templates and into serials-toolbar.js
- [[26291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26291) Move translatable strings out of z3950_search.inc into z3950_search.js
- [[26334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26334) Move translatable strings out of members-menu.inc into members-menu.js
- [[26339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26339) Move translatable strings out of addorderiso2709.tt into addorderiso2709.js
- [[26395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26395) Move translatable strings out of letter.tt into letter.js
- [[26439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26439) Move translatable cart-related strings out of js_includes.inc and into basket.js
- [[26441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26441) Move translatable strings out of catalog-strings.inc into catalog.js
- [[26697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26697) Make translation file for types and descriptions of charges consistent between OPAC and staff

### ILL

- [[20799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20799) Add a link from biblio detail view to ILL request detail view, if a biblio has an ILL request
- [[23391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23391) Hide finished ILL requests

  >This adds a new system preference ILLHiddenRequestStatuses that takes a list of ILL status codes to be hidden from the ILL requests table in the ILL module. This allows to hide finished and cancelled ILL requests improving the performance of the table in busy libraries but also making it easier to keep track of the pending requests.

### Installation and upgrade (web-based installer)

- [[24973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24973) Allow to localize and translate system preferences with new yaml based installer
- [[25129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25129) Update German (de-DE) web installer files for 20.05

### Lists

- [[24884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24884) Remove 'New list' button in 'Public lists' tab if OpacAllowPublicListCreation is disabled

### MARC Authority data support

- [[25313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25313) Add optional skip_merge parameter to ModAuthority

### MARC Bibliographic data support

- [[15141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15141) Add MARC21 770/772 to OPAC and staff detail pages

  >Adds display for 770 (Supplement/Special issue entry) and 772 (Supplement parent entry) to the OPAC and staff interface detail pages.
- [[15436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15436) MARC21: Use semicolon between series name and volume information
- [[15437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15437) MARC21: Show $i for 780/785

  >Adds $i (Relationship information) to 780 (Preceding entry) and 785 (Succeeding entry) in the OPAC and staff detail pages.
- [[16728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16728) Add MARC21 777 - Issued with entry to staff and OPAC detail pages
- [[24322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24322) National Library of Medicine (NLM) call number to XSLT Detail

### Notices

- [[16371]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16371) Quote of the Day (QOTD) for the staff interface

  **Sponsored by** *Koha-Suomi Oy*

  >This enhancement lets you choose where the Quote of the Day (QOTD) is displayed:
  >- OPAC: QOTD only appears in the OPAC.
  >- Staff interface: QOTD only appears in the staff interface.
  >- Both [Select all]: QOTD appears in the staff interface and OPAC.
- [[24197]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24197) Custom destination for failed overdue notices

  **Sponsored by** *Catalyst*

  >This adds a new system preference  AddressForFailedEmailNotices that allows to control where the summarized overdue email for patrons without email addresses is sent to.
- [[24591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24591) Add developer script to preview a letter
- [[25097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25097) Add option to message_queue to allow for only specific sending notices

  >This adds a new command line option -c|--code to the process_message_queue.pl cron job allowing to pick which letter codes will be processed and send when the job runs. This will allow to send different notices at different times depending on your cron job setup.
- [[25776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25776) Add last updated date for notices and slips

  >This adds a new column to the letter table to store the last date and time a notice was edited. On the notices summary page, the latest change will show and the individual changes for each transport type (email, print, ...) will show once the letter is edited on the different tabs.
- [[26745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26745) Notice titles/subjects should support Template Toolkit

  >This patch introduces the ability to use template toolkit syntax in the subject line of email notices.

### OPAC

- [[5927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5927) Show series information in search results page
- [[8732]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8732) Add a system preference to allow users to choose to display an icon based on the Koha bibliographic level itemtype

  >These patches add a new syspref: BiblioItemtypeInfo
  >
  >If enabled the icons for the record itemtype (942c) will be displayed on the record detail and search result pages in both the OPAC and staff interface
- [[16696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16696) Rename "Publisher" to "Publication details" on detail and result lists
- [[18911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18911) Option to set preferred language in OPAC

  >The OPAC users can now choose their preferred language for notices.
- [[19616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19616) Add MARC21 505$g - Formatted Contents Note / Miscellaneous information
- [[20168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20168) Update of the OPAC bootstrap template to bootstrap v4

  >This patch upgrades the version of the Bootstrap library used by the OPAC from version 2.3.1 to version 4.5.0. The Bootstrap library provides a framework of JavaScript and CSS to support responsive layouts and interface elements like toolbars, menus, buttons, etc. Although some aspects of the interface have been updated, the changes are largely invisible to the user.
- [[20936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20936) Holds history for patrons in OPAC

  >Northeast Kansas Library System (NEKLS)
- [[22807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22807) Accessibility: Add 'Skip to main content' link

  >This accessibility enhancement adds a hidden 'Skip to main content' link to the OPAC which will appear if a user uses 'tab' keyboard navigation.
- [[23795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23795) Convert OpacCredits system preference to news block
- [[23796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23796) Convert OpacCustomSearch system preference to news block
- [[23797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23797) Convert OpacLoginInstructions system preference to news block
- [[24405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24405) Links in facets are styled differently than other links on the results page in OPAC
- [[25151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25151) Accessibility: The 'Your cart' page does not contain a level-one header
- [[25154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25154) Accessibility: The 'Search results' page does not use heading markup where content is introduced
- [[25155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25155) Accessibility: The 'Login modal' contains semantically incorrect headings
- [[25236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25236) Accessibility: The 'Refine your search' box contains semantically incorrect headings
- [[25237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25237) Accessibility: The 'Author details' in the full record display contains semantically incorrect headings
- [[25238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25238) Accessibility: Multiple 'H1' headings exist in the full record display
- [[25239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25239) Accessibility: The 'Confirm hold page' contains semantically incorrect headings
- [[25242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25242) Accessibility: The 'Holdings' table partially obscures navigation links at 200% zoom
- [[25244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25244) Accessibility: Checkboxes on the search results page do not contain specific aria labels
- [[25402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25402) Put OPAC cart download options into dropdown menu

  >This enhancement adds the OPAC cart download format options into the dropdown menu, rather than opening in a separate pop up window. (This also matches the behaviour in the staff interface.)
- [[25639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25639) Add search queries to HTML so queries can be retrieved via JS

  >This patch adds global JS variables for the prepared search forms: query_desc_query_cgi, and query
  >
  >These are useful for plugins or custom JS wishing to perform searches outside of Koha and incorporate results.
- [[25771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25771) Allow the user to sort checkouts by the renew column in the OPAC
- [[25801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25801) Add itemnumber parameter to the OPAC detail page that allows to show a single item
- [[25871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25871) Add "only library" to OpacItemLocation options
- [[25984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25984) Accessibility: Shelf browse lacks focus visibility when cover image is missing
- [[26008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26008) Remove the use of jquery.checkboxes plugin from OPAC cart
- [[26039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26039) Accessibility: Shelf browser is not announced upon loading
- [[26041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26041) Accessibility: The date picker calendar is not keyboard accessible
- [[26094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26094) "Suggest for Purchase" button missing unique CSS class
- [[26148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26148) OpenLibrary "Preview" link target is unclear to patrons
- [[26266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26266) Add jQuery validator to opac-password-recovery.tt
- [[26299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26299) Help text for OPAC SMS number should be less North American-centric
- [[26454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26454) Add system preference to set meta description for the OPAC

  >Functionality to add meta description tag with content with the system preference OpacMetaDescription. This is used by search engines to add a description to the library in search results.
- [[26519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26519) Clean up OPAC buttons with incorrect classes
- [[26655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26655) Accessibility: Checkboxes on OPAC lists do not contain aria labels
- [[26695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26695) Set focus for cursor to login box on the login popup modal
- [[26706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26706) Fix btn-default styling for better contrast
- [[26718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26718) Change 'Your reading history" to "Your checkout history"

  >This changes "reading history" to "checkout history" in the staff interface and OPAC as libraries are not only leanding reading materials but a lot of different media.
- [[26753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26753) Set focus for cursor to password field on Overdrive login popup on OPAC
- [[26763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26763) Use standard information style for multi-hold message
- [[26783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26783) Set OpacRenewalAllowed to "Allowed" for new installations
- [[26805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26805) Remove remaining instances of jquery.checkboxes plugin from the OPAC
- [[26825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26825) Add span for publication date in OPAC
- [[26828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26828) Set focus for cursor to current password field when updating in the OPAC
- [[26830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26830) Set focus for cursor to name input box when creating a new list in the OPAC
- [[26881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26881) Remove the period at the end of 'Limit to currently available items' in facets

### Patrons

- [[6725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6725) Make patron duplicate matching flexible

  >The new system preference 'PatronDuplicateMatchingAddFields' adds more flexibility in the de-duplication of patrons.
  >Prior to this change only surname, firstname and dateofbirth where used. Now the list of fields is configurable.
- [[10910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10910) Add a warn when deleting a patron with pending suggestions

  >A warning is displayed if a staff member is trying to delete a patron with pending suggestions.
- [[13625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13625) RenewalSendNotice setting should be reflected in messaging preferences descriptions
- [[20057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20057) Auto-approve option for borrower modifications

  >Adds a new system preference AutoApprovePatronProfileSettings that allows to automatically approve any requests for patron detail modifications made by patrons from the OPAC.
- [[21345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21345) Patron records with attached files not obvious from patron details view

  >This patch adds a new section to the patron detail view in the staff interface when the "EnableBorrowerFiles" system preference is enabled. The page will now show a "Files" section with a link to manage files and a list of any attached files.
- [[22087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22087) Show city and state in patron search results
- [[23816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23816) Allow to have different password strength and length settings for different patron categories

  **Sponsored by** *Northeast Kansas Library System*
- [[25364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25364) Add "Other" to the gender options in a patron record
- [[25654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25654) Make the contact and non-patron guarantor sections separate on patron entry form
- [[26534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26534) Add a Font Awesome icon to help identify staff patrons

  >This adds a small shield icon to help identify staff members (having catalogue permission) in the staff interface. The icon displays next to the name on top of the brief patron information that is shown on all patron account pages.
- [[26687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26687) Add a Font Awesome icon for superlibrarian patrons

  >This adds a bolt icon next to the shield icon introduced by bug 26534, if the user is not only a staff member but also holds the superlibrarian permission.

### Plugin architecture

- [[21468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21468) Plugins need hooks for checkin and checkout actions

  >This enhancement adds plugin hooks to allow plugins to take action after check-in and check-out circulation events.
- [[24031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24031) Add plugin hook after_hold_create
- [[24633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24633) Add support for gitlab searching of plugins

  **Sponsored by** *Theke Solutions*

  >The enhancement allows setting Gitlab targets for retrieving plugins.
- [[25855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25855) Add hook to AddRenewal using a new _after_circ_actions method in circulation

  **Sponsored by** *ByWater Solutions*

  >This enhancement adds plugin hooks to allow plugins to take action after renewal circulation events.
- [[25961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25961) Add hooks for plugins to inject variables to XSLT

  >This enhancement adds the following plugin hooks:
  >- opac_results_xslt_variables
  >- opac_detail_xslt_variables
  >
  >This allows us to pass valuable information for XSLT customization.
  >
  >Plugins implementing this hooks, should return a hashref containing the variable names and values to be passed to the XSLT processing code.
- [[26063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26063) Use Koha::Plugins->call for other hooks

  **Sponsored by** *ByWater Solutions*
- [[26338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26338) Show tool plugins run in tools home

### Reports

- [[24665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24665) Add ability to run cash register report with new cash register feature

  >This enhancement exposes the ability to refine the cash register report by cash register the transactions have taken place upon if you are using the 'UseCashRegisters' feature.
- [[24834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24834) Display report number after running
- [[24958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24958) Remember last selected tab in SQL reports
- [[25605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25605) Exporting report as a tab delimited file can produce a lot of warnings

### SIP2

- [[12556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12556) SelfCheck machine starts the hold instantly with an email sent out

  >This new system preference HoldsNeedProcessingSIP allows the libraries to prepare the items in peace for the next patron before a notification about a waiting hold is sent to the patron. Without this system preference in some cases the item might not have been ready for pick up by the time patron came to the library to checkout the item they had on hold. This feature works only with SIP2 return machines for the time being.
- [[21979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21979) Add option to SIP2 config to send arbitrary item field in CR instead of collection code
- [[24165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24165) Add ability to send any item field in a library chosen SIP field
- [[25344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25344) Add support for circulation status 10 ( item in transit )
- [[25347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25347) Add support for circulation status 11 ( claimed returned )
- [[25348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25348) Add support for circulation status 12 ( lost )
- [[25541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25541) Add ability to prevent checkin via SIP of items with holds

  >Some libraries would like patrons to be unable to return items with holds via SIP. Instead, the screen message should indicate that the patron should return that item at the circ desk so a librarian can use it to fill the next hold right away and place it on the hold shelf. This feature is enabled by adding the flag holds_block_checkin to an account in the SIP configuration file, and setting the value of it to "1".

### Searching

- [[20888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20888) Allow use of boolean operator 'not' in item search
- [[25867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25867) Label holdingbranch as Current library rather than Current location
- [[26032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26032) Add 'is new' filter in items search

  >There is a new filter in item search, when the database column 'items.new_status' is used.
  >It allows searching items defined as new or not new, like the filter on damaged or not damaged.

### Searching - Elasticsearch

- [[19482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19482) Elasticsearch - prevent removal / editing of required indexes

  >These patches add the option to define some fields as 'mandatory' in the mappings.yaml file for elasticsearch.
  >
  >A 'mandatory' field cannot be deleted from the staff interface and must be mapped to at least one MARC field.
  >
  >The intention is to prevent removal of search fields that are required for Koha functionality - built in sorting fields, issues count, etc.
  >
  >These patches add the marker to 'issues' and 'title'  - more fields may be marked in the future
- [[24155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24155) Weights should be (optionally) applied to Advanced search

  >This patch adds the weighting of search results to searches made via the 'Advanced search' interface.
  >
  >Weights, defined in Administration section, boost ranking of results when specified fields are matched in a search query.
  >
  >The weights will not affect index-specific queries, but are useful for keyword or queries with limits applied and so should be applied unless the user specifies not to.
- [[24807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24807) Add "year" type to improve sorting by publication date
- [[26180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26180) Elasticsearch - Add option to index records in descending order
- [[26310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26310) Allow setting trace_to parameter in Elasticsearch config

  >By setting the 'trace_to' parameter in the elasticsearch config we can log the requests sent to the ES cluster to aid in debugging search or indexing issues

### Serials

- [[26484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26484) Add serials-related reports to serials sidebar menu

### Staff Client

- [[12093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12093) Add CSS classes to item statuses in detail view
- [[15400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15400) Display patron age in useful places in the staff interface

  **Sponsored by** *Catalyst*
- [[18170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18170) Show damaged status on check-in
- [[26007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26007) Warning/reminder for changes to Koha to MARC mapping

  >In current versions of Koha you can no longer change the Koha to MARC mappings from the frameworks, but only from the Koha to MARC mapping page in administration. This patch cleans up the hints on the framework page and adds a well visible note on the Koha to MARC mapping page. Any changes to the mappings require that you run the batchRebuildBiblioTables script to fully take effect.
- [[26182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26182) Clearly pair UpdateItemWhenLostFromHoldList and CanMarkHoldsToPullAsLost system preferences
- [[26435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26435) AutoSelfCheckID syspref description should warn it blocks OPAC access
- [[26458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26458) Get item details using only itemnumber
- [[26473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26473) Get items for editing using only itemnumber

### System Administration

- [[20815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20815) Add ability to choose if lost fee is refunded based on length of time item has been lost
- [[22844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22844) Simplify the process of selecting database columns for system preferences

  >This enhancement introduces a new way to select database columns for selected system preferences like BorrowerMandatoryField. Currently, this requires manually adding the database field names. The enhancement lets you select from a list of available fields in a new window, and also select and clear all fields.
  >
  >This is implemented for these system preferences:
  >- BorrowerMandatoryField
  >- BorrowerUnwantedField
  >- PatronQuickAddFields
  >- PatronSelfModificationBorrowerUnwantedField
  >- PatronSelfRegistrationBorrowerMandatoryField
  >- PatronSelfRegistrationBorrowerUnwantedField
  >- StatisticsFields
  >- UniqueItemFields
- [[23823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23823) Allow system preferences to be bookmarked
- [[25288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25288) Make the libraries list use the API
- [[25630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25630) More capitalization and terminology fixes for system preferences

  >This enhancement makes changes to the descriptions for many of the system preferences to help improve consistency with the terminology list* and readability.
  >
  >The changes made cover:
  >- Capitalization (such as Don't Allow to Don't allow).
  >- Terminology (such as staff client to staff interface, including the tab label).
  >- Punctuation (such as the placement of periods/full stops at the end of sentences).
  >- Readability (rearranging or rephrasing the description to make easier to understand).
  >
  >Some of the terminology changes include:
  >- bib and biblio => bibliographic
  >- branch => library
  >- borrower => patron
  >- Do not > Don't
  >- staff client => staff interface
  >- pref and syspref => system preference
  >
  >* https://wiki.koha-community.org/wiki/Terminology
- [[25709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25709) Rename systempreference from NotesBlacklist to NotesToHide

  >This patchset updates a syspref name to be clearer about what it does and to follow community guidelines on using inclusive language.
  >
  >https://wiki.koha-community.org/wiki/Coding_Guidelines#TERM3:_Inclusive_Language
- [[25945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25945) Description of AuthoritySeparator is misleading
- [[26595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26595) Add SMTP server column to libraries table

### Templates

- [[23148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23148) Replace Bridge icons with transparent PNG files
- [[23410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23410) Add submenus to system preferences sidebar menu
- [[23852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23852) Merge biblio-title.inc and biblio-default-view.inc
- [[24012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24012) Display 'Locked' budget with a lock icon

  **Sponsored by** *Catalyst*
- [[24156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24156) Basket - Make sort order and number of items to display configurable

  **Sponsored by** *Institute of Technology Tallaght*

  >This patch adds new options in the Table settings section to make the sort order and number of results per page in the basket table configurable.
- [[24625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24625) Phase out jquery.cookie.js:  showLastPatron
- [[24899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24899) Reindent record matching rules template
- [[25031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25031) Improve handling of multiple covers on the biblio detail page in the staff client

  >This enhancement improves the display of multiple covers for a record in the staff interface, including covers from these services:
  >- Amazon
  >- Local cover images (including multiple local cover images)
  >- Coce (serving up Amazon, Google, and OpenLibrary images)
  >- Images from the CustomCoverImages preference
- [[25354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25354) Clean up JavaScript markup in cataloging plugin scripts
- [[25363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25363) Merge common.js with staff-global.js
- [[25427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25427) Make authority subfield management interface consistent with bibliographic subfield management view
- [[25471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25471) Add DataTables to MARC subfield structure admin page for bibliographic frameworks
- [[25593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25593) Terminology: Fix "There is no order for this biblio." on catalog detail page
- [[25627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25627) Move OPAC problem reports from administration to tools
- [[25727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25727) Update the Select2 JS lib

  **Sponsored by** *Orex Digital*
- [[25827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25827) Add floating toolbar to the holds summary page in staff interface
- [[25832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25832) Add DataTables to MARC subfield structure admin page for authorities
- [[25834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25834) Relabel "Search to add" to "Search for guarantor" or "Add guarantor" on patron form
- [[25879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25879) Improve display of guarantor information in the patron entry form
- [[25906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25906) Style corrections for OPAC serial pages
- [[25941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25941) Reindent Upload local cover image page
- [[25968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25968) Make logs sort by date descending as a default and add column configuration options
- [[26004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26004) Remove unused jQuery plugin jquery.hoverIntent.minified.js from the OPAC
- [[26010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26010) Remove the use of jquery.checkboxes plugin from staff interface cart
- [[26011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26011) Remove unused jQuery plugin jquery.metadata.min.js from the OPAC
- [[26015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26015) Terminology: staff interface should be used everywhere
- [[26016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26016) Capitalization: MARC Preview
- [[26060]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26060) Replace staff interface table sort icons with SVG
- [[26061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26061) Improve style of sidebar datepickers
- [[26085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26085) Add the copy, print and export DataTables buttons to lost items report
- [[26087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26087) Add table configuration and export options to orders by fund report
- [[26091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26091) Add column configuration and export options to catalog statistics report
- [[26120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26120) Remove the use of jquery.checkboxes plugin from tags review template
- [[26149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26149) Remove jquery.checkboxes plugin from problem reports page
- [[26150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26150) Remove the use of jquery.checkboxes plugin from inventory page
- [[26151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26151) Remove the use of jquery.checkboxes plugin from suggestions management page
- [[26152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26152) Remove the use of jquery.checkboxes plugin from serial collection page
- [[26153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26153) Remove the use of jquery.checkboxes plugin from items lost report
- [[26154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26154) Remove the use of jquery.checkboxes plugin from batch item deletion and modification
- [[26159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26159) Remove the use of jquery.checkboxes plugin from batch record delete page
- [[26164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26164) Replace OPAC table sort icons with SVG
- [[26194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26194) Messages about missing cash registers should link to cash register management
- [[26201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26201) Remove the use of jquery.checkboxes plugin from batch extend due dates page
- [[26202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26202) Remove the use of jquery.checkboxes plugin from batch record modification page
- [[26204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26204) Remove the use of jquery.checkboxes plugin from staff interface lists
- [[26212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26212) Remove the use of jquery.checkboxes plugin from pending offline circulations
- [[26214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26214) Remove the use of jquery.checkboxes plugin on late orders page
- [[26215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26215) Remove the use of jquery.checkboxes plugin from Z39.50 search pages
- [[26216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26216) Remove the use of jquery.checkboxes plugin from catalog search results
- [[26245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26245) Remove unused functions from members.js
- [[26261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26261) Split calendar.inc into include file and JavaScript file
- [[26280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26280) Add unique IDs or class names for each condition in returns.tt
- [[26419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26419) Replace OPAC Koha logo with SVG
- [[26456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26456) Reindent MARC subfield structure template
- [[26504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26504) Remove the use of jquery.checkboxes plugin from checkout notes page
- [[26530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26530) Use patron card number as checkbox label during patron merge
- [[26767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26767) Remove the use of jquery.checkboxes plugin from duplicate orders template
- [[26768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26768) Remove the use of jquery.checkboxes plugin from library transfer limits page
- [[26769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26769) Remove the use of jquery.checkboxes plugin from staff interface search history
- [[26795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26795) Remove the use of jquery.checkboxes plugin from ILL pages
- [[26798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26798) Remove the use of jquery.checkboxes plugin from patron detail page
- [[26799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26799) Remove the use of jquery.checkboxes plugin from patron payment page
- [[26800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26800) Remove the use of jquery.checkboxes plugin from checkout page
- [[26806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26806) Remove the jquery.checkboxes plugin from the staff client
- [[26817]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26817) "Total" line in checkouts table is too short when ExportCircHistory is activated
- [[26826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26826) Set focus for cursor to name input box when creating a new list

### Test Suite

- [[25113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25113) Make CirculationRules.t flexible for new scope combinations

  **Sponsored by** *National Library of Finland*
- [[26157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26157) Redirect expected DBI warnings
- [[26462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26462) t/db_dependent/Holds.t tests delete data unnecessarily

### Tools

- [[4985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4985) Copy a change on the calendar to all libraries

  **Sponsored by** *Koha-Suomi Oy*
- [[5087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5087) Option to not show CSV profiles in OPAC

  **Sponsored by** *Catalyst*

  >This patch adds an option to show or not show a CSV profile in the OPAC cart and lists download formats list.
- [[21066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21066) Replace opac_news.timestamp by published_on and add updated_on as timestamp
- [[22660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22660) Allow use of CodeMirror for editing HTML in the news editor

  >This patch adds the ability to switch between the TinyMCE (WYSIWYG) text editor and the more robust CodeMirror text editor via the new system preference, NewsToolEditor, when editing News items.
- [[23114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23114) Inventory: allow to scan barcodes into input field
- [[25101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25101) Add ability to skip previewing results when batch extending due dates
- [[25694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25694) Add ability to delete a MARC modification template when viewing

  >This enhancement adds a 'Delete template' button on the page for viewing the actions of a MARC modification template.
- [[25845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25845) Cannot limit system logs to 'api' interface

  >This enhancement adds the option to limit viewing logged actions done by API only
- [[26013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26013) Date on 'manage staged MARC records' is not formatted correctly
- [[26086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26086) Add a 'cron' interface limit to the log viewer

  >This enhancement adds the option to limit viewing logged actions done by cron only
- [[26207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26207) Compare values of system preference log entries

  >This patch adds a feature to the log viewer in the staff interface for use when viewing system preference log entries. The feature allows the user to select two system preference values in the log for comparison. The two versions are shown in a modal window with the differences highlighted.
- [[26431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26431) Use split button to offer choice of WYSIWYG or code editor for news
- [[26572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26572) Add autocomplete to librarian field in log viewer
- [[26736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26736) Compare values of reports log entries
- [[26804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26804) News: Move the news preview out of the table and into a modal
- [[26844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26844) Log viewer does not indicate which logs are enabled

### Web services

- [[19353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19353) Make possible to have custom XSL template for marcxml and marc21 metadata prefixes in OAI server
- [[25460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25460) Allow using item information in OAI set mappings and automatically update sets when items are added, edited or deleted

  **Sponsored by** *Catalyst*

  >This allows library staff to use information from items when creating mappings for OAI sets. When the new system preference OAI-PMH:AutoUpdateSetsEmbedItemData is set, editing, deleting or adding items will update records listed in the OAI sets according to the mapppings.
- [[25650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25650) Add location and itype descriptions in ILS-DI GetRecords


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[14543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14543) Order lines updated that have a tax rate not in gist will have tax rate set to 0!
- [[18267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18267) Update price and tax fields in EDI to reflect DB changes
- [[25677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25677) Checkbox options for EDI accounts cannot be enabled
- [[25750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25750) Fallback to ecost_tax_included, ecost_tax_excluded not happening when no 'Actual cost' entered

  **Sponsored by** *Horowhenua District Council*
- [[26082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26082) Follow up to bug 23463 - need to call Koha::Item store to get itemnumber
- [[26134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26134) Error when adding to basket from new/staged file when using MARCItemFieldsToOrder
- [[26438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26438) Follow up to bug 23463 - return from Koha::Item overwrites existing variable
- [[26496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26496) Budget plan save button doesn't save plans
- [[26738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26738) Unable to change manager of purchase suggestion
- [[26908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26908) EDI vendor accounts edit no longer allows plugins to be selected for an account
- [[27082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27082) Problem when a basket has more of 20 orders with uncertain price

### Architecture, internals, and plumbing

- [[23634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23634) Privilege escalation vulnerability for staff users with 'edit_borrowers' permission and 'OpacResetPassword' enabled
- [[24663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24663) OPACPublic must be tested for all opac scripts
- [[24986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24986) Maximum row size reached soon for borrowers and deletedborrowers
- [[25504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25504) Wrong API spec breaks plack without meaningful error
- [[25634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25634) koha-foreach exits too early if any command has non-zero status
- [[25707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25707) Mappings update in bug 11529 causes incorrect MARC to DB data flow
- [[25898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25898) Prohibit indirect object notation
- [[25909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25909) Recent change to datatables JS in the OPAC causes errors
- [[25964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25964) Data loss possible when items are modified
- [[26253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26253) duplicated mana_config in etc/koha-conf.xml
- [[26322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26322) REST API plugin authorization is not checked anymore
- [[26341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26341) Database update for bug 21443 is not idempotent and will destroy settings
- [[26434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26434) Plugin dirs duplicates in @INC with plack
- [[26470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26470) itemnumber not available for plugin hook
- [[26562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26562) Searches are shared between sessions
- [[26639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26639) Turn auto_savepoint ON
- [[26911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26911) Update for 18936 can cause data loss if constraints are violated
- [[26963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26963) Improve Koha::Item::pickup_locations performance

  >Koha::Item::pickup_locations is very inefficient, causing timeouts on records with large numbers of holds/items.
  >
  >This development refactors the underlying implementation, and also makes the method return a resultset, to delay as much as possible the DB access, and thus allowing for further filtering  on the callers, through chaining.

### Cataloging

- [[18051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18051) Advanced Editor - Rancor - encoding issues with some sources
- [[26083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26083) Item editor defaults to lost
- [[26518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26518) Adding a record can succeed even if adding the biblioitem fails
- [[26750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26750) Deleted items are not removed from index
- [[27012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27012) Merging records with holds causes SQL error

### Circulation

- [[18501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18501) Automatic refunds need protection from failure
- [[25566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25566) Change in DecreaseLoanHighHolds behaviour
- [[25726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25726) Holds to Pull made empty by pathological holds
- [[25758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25758) Items scheduled for automatic renewal do not show that they will not renew due to a hold

  >Bug 19014 prioritized the 'too soon' message for renewals to prevent sending too many notifications. When displaying information about the hold elsewhere it is desired to see the 'on hold' status even when the renewal is too soon.
  >
  >This patch add a switch to the CanBookBeRenewed routine to decide which status has priority (i.e. whether we are checking from the renewal cron or elsewhere)
- [[25783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25783) Holds Queue treating item-level holds as bib-level
- [[25850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25850) CalcDateDue freezes with 'useDaysMode' set to 'Dayweek' and the due date lands on a Sunday
- [[25851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25851) 19.11 upgrade creates holdallowed rule with empty value
- [[25969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25969) Checking in a found hold at a different branch then confirming the hold causes internal server error
- [[26078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26078) "Item returns to issuing library" creates infinite transfer loop
- [[26108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26108) Checkins should not require item to have been checked out
- [[26232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26232) undefined fine grace period kills koha
- [[26510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26510) Transport Cost Matrix editor doesn't show all data when HoldsQueueSkipClosed is enabled
- [[26529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26529) Holds rules enforced incorrectly when not set at library level

### Command-line Utilities

- [[25538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25538) koha-shell should pass --login to sudo if no command
- [[25683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25683) update_patron_categories.pl should recognize no fine history = 0 outstanding fines
- [[25752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25752) Current directory not kept when using koha-shell

### Course reserves

- [[26819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26819) Error when adding items to course reserves - can't view items in the staff interface

  >This fixes an error introduced during the 20.11 development cycle with course reserves. After adding an item you could not list the items for a course in the staff interface (an error page was generated), and you could not add additional items.

### Database

- [[18050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18050) Missing constraint on aqbudgets.budget_period_id in aqbudgets
- [[24379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24379) Patron login attempts happen to be NULL instead of 0
- [[25826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25826) Hiding biblionumber in the frameworks breaks links in result list

### Fines and fees

- [[25526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25526) Using Write Off Selected will not allow for a different amount to be written off
- [[26023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26023) Incorrect permissions handling for cashup actions on the library level registers summary page
- [[26536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26536) "Writeoff/Pay selected" deducts from old unpaid debts first
- [[26915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26915) Koha explodes when writing off a fee with FinePaymentAutoPopup
- [[27079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27079) UpdateFine adds refunds for fines paid off before return

### Hold requests

- [[18958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18958) If patron has multiple record level holds on one record transferring first hold causes next hold to become item level
- [[24598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24598) Hold not reset properly if checked out to another patron
- [[24683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24683) Holds on biblios with different item types: rules for holds allowed are not applied correctly if any item type is available
- [[25786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25786) Holds Queue building may target the wrong item for item level requests that match holds queue priority
- [[26429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26429) If a waiting hold has expired the expiration date on the holds page shows for tomorrow
- [[26900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26900) Fixes Koka::Libraries typo in C4/Reserves.pm
- [[26990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26990) No feedback if holds override is disabled and hold fails

### I18N/L10N

- [[26158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26158) Z3950 search button broken for translations

### ILL

- [[26114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26114) ILL should mark status=RET only if a return happened

### Installation and upgrade (command-line installer)

- [[26265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26265) Makefile.PL is missing pos directory

### Label/patron card printing

- [[25852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25852) If a layout is edited, the layout type will revert to barcode

### MARC Authority data support

- [[25273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25273) Elasticsearch Authority matching is returning too many results
- [[25653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25653) Authorities search does not retain selection

### MARC Bibliographic record staging/import

- [[26231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26231) bulkmarcimport.pl does not import authority if it already has a 001 field
- [[26853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26853) Data lost due to "Data too long for column" errors during MARC import
- [[26854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26854) stage-marc-import.pl does not properly fork

### Notices

- [[26420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26420) Overdue notices script does not care about borrower's language, always takes default template
- [[27103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27103) Adding a hold cancellation reason should not always send a notice

### OPAC

- [[17842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17842) Broken diacritics on records exported as MARC from cart
- [[22672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22672) Replace `i` tags with `em` AND `b` tags with `strong` in the OPAC
- [[25492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25492) Your Account Menu button does nothing on mobile devices
- [[25769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25769) Patron self modification triggers change request for date of birth to null
- [[26005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26005) OPAC cart display fails with error

  >This fixes a problem with the OPAC cart - it should now work correctly when opened, instead of generating an error message.
- [[26037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26037) openlibrary.org is hit on every Koha requests
- [[26069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26069) Twitter share button leaks information to Twitter
- [[26505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26505) Suspend hold modal broken in the OPAC
- [[26735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26735) Overdrive login modal broken in the OPAC
- [[26752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26752) OPAC list download button broken by Bootstrap 4 upgrade
- [[26973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26973) extendedPatronAttributes not showing during selfregistration

### Packaging

- [[25591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25591) Update list-deps for Debian 10 and Ubuntu 20.04
- [[25633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25633) Update debian/control.ini file for 20.05 release cycle
- [[25693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25693) Correct permissions must be set on logdir after an upgrade
- [[25792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25792) Rename 'ttf-dejavu' package to 'fonts-dejavu' for Debian 11
- [[25920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25920) Add liblocale-codes-perl package to fix ubuntu-stable (focal)

### Patrons

- [[25322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25322) Adding a guarantor with no relationship defaults to first available relationship name
- [[25858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25858) Borrower permissions are broken by update from bug 22868
- [[26285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26285) Use country code + number (E.164) validation for SMS numbers
- [[26556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26556) Cities autocomplete broken in patron edition

### Plugin architecture

- [[25549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25549) Broken plugins should not break Koha (Install plugin script/method should highlight broken plugins)
- [[26138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26138) Errors if enable_plugins is zero
- [[26751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26751) Fatal exception if only one repo defined

### REST API

- [[23653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23653) Plack fails when http://swagger.io/v2/schema.json is unavailable and schema cache missing
- [[24003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24003) REST API should set C4::Context->userenv
- [[25774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25774) REST API searches don't handle correctly utf8 characters
- [[25944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25944) Bug in ill_requests patch schema
- [[26143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26143) The API does not handle requesting all resources

### Reports

- [[25942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25942) Batch biblio and borrower operations on report results should not concatenate biblio/cardnumbers into a single string
- [[26090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26090) Catalog by itemtype report fails if SQL strict mode is on

### SIP2

- [[25761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25761) Implementation of too_many_overdue has unintended consequences

  >This bugfix allows the circulation rules that prevent checkouts if a user has reached a maximum number of overdue to be overridden at the SIP login level.
  >
  >This is especially useful for ebook lending services where you may want this block to be disabled. 
  >
  >***New SIP config option***: `overdues_block_checkout` defaults to `1`
- [[25992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25992) SIP2 server doesn't start - Undefined subroutine set_logger
- [[26896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26896) SIP option holds_block_checkin does not actually block checkin of items on hold

### Searching

- [[7607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7607) Advanced search: Index and search term don't match when leaving fields empty

### Searching - Elasticsearch

- [[23828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23828) Elasticsearch - ES - Authority record results not ordered correctly
- [[25265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25265) Elasticsearch - Batch editing items on a biblio can lead to incorrect index
- [[25864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25864) Case sensitivity breaks searching of some fields in ES5
- [[25882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25882) Elasticsearch - Advanced search itemtype limits are being double quoted
- [[26309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26309) Elasticsearch cxn_pool must be configurable (again)
- [[26507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26507) New items not indexed
- [[26903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26903) Authority records not being indexed in Elasticsearch
- [[27070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27070) Elasticsearch - with Elasticsearch 6 searches failing unless all terms are in the same field

### Searching - Zebra

- [[23086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23086) Search for collection is broken
- [[26581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26581) Elasticsearch - Records can be indexed multiple times during returns

### Serials

- [[26604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26604) "Generate next" button gives error on serials-collection.pl
- [[26987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26987) No property notforloan for Koha::Serial::Item
- [[26992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26992) On serial collection page, impossible to delete issues and related items

### Staff Client

- [[23432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23432) Stock rotation: cancelled transfer result in stockrotation failures

### System Administration

- [[25651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25651) Modifying an authorised value make it disappear
- [[26948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26948) Some Koha Emails are double encoded (HOLD, ODUE, ...)

### Templates

- [[25839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25839) Typo patron.streetype in member-main-address-style.inc
- [[25842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25842) Typo "streetype" in member-main-address-style.inc

### Test Suite

- [[26031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26031) www/search_utf8.t is failing randomly and must be removed/replaced
- [[26033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26033) framapic is closing
- [[26250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26250) Test suite does not pass if Elastic is used as search engine

### Tools

- [[15032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15032) [Plack] Scripts that fork (like stage-marc-import.pl) don't work as expected
- [[25557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25557) Column config table in acquisitions order does not match the acq table in baskets
- [[26516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26516) Importing records with unexpected format of copyrightdate fails
- [[26557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26557) Batch import fails when incoming records contain itemnumber
- [[26592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26592) XSS vulnerability when ysearch is used

### Z39.50 / SRU / OpenSearch Servers

- [[23542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23542) SRU import encoding issue


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[25642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25642) Technical notes are missing from the release (20.05)
- [[27108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27108) Update team for 21.05 cycle

### Acquisitions

- [[6819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6819) Don't offer cancel order links for received order lines on basket summary
- [[10921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10921) You can edit an order even when it is in a closed basket
- [[11176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11176) Purchase suggestions should respect the 'active' switch on budgets
- [[17458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17458) When receiving an order, information about user and date on top are incorrect
- [[21268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21268) Can't add to basket from staged file if base-level allocated is zero
- [[21811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21811) Add warning when order receive form is saved without entering 'quantity received'
- [[25266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25266) Not all vendors are listed in the filters on the late order claims page
- [[25499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25499) Fund code column is empty when closing a budget
- [[25507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25507) PDF order print for German 2-pages is broken
- [[25545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25545) Invoice page - Adjustments are not included in the Total + adjustments + shipment cost (Column tax. inc.)
- [[25599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25599) Allow use of cataloguing placeholders when ACQ framework is used creating new record (UseACQFrameworkForBiblioRecords)
- [[25611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25611) Changing the vendor when creating the basket does not keep that new vendor
- [[25751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25751) When an ORDERED suggestion is edited, the status resets to "No status"
- [[25887]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25887) Filtering funds by library resets to empty in library pull down
- [[26190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26190) Cannot close baskets when all lines have been cancelled
- [[26497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26497) "Hide all columns" throws Javascript error on aqplan.pl

### Architecture, internals, and plumbing

- [[21539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21539) addorderiso2709.pl forces librarian to select a ccode and notforloan code when using MarcItemFieldsToOrder
- [[25360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25360) Use secure flag for CGISESSID cookie
- [[25875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25875) Patron displayed multiple times in add user search if they have multiple sub permissions
- [[25950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25950) REMOTE_ADDR set to null if client_ip in X-Forwarded-For matches a koha_trusted_proxies value
- [[26228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26228) Update gulpfile to work with Node.js v12
- [[26239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26239) Number::Format issues with large negative numbers
- [[26260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26260) elasticsearch>cnx_pool missing in koha-conf-site.xml.in
- [[26270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26270) XISBN.t is failing since today
- [[26331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26331) svc/letters/preview is not executable which prevents CGI functioning
- [[26384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26384) Missing test to catch for execution flags
- [[26464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26464) Code correction in opac-main when news_id passed
- [[26569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26569) Use gender-neutral pronouns in systempreference explanation field in DB
- [[26638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26638) System preference ArticleRequestsMandatoryFieldsItemsOnly is unused
- [[26673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26673) Remove Perl shebangs from Perl modules
- [[26721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26721) Debit and credit type pages should check for the specific permission
- [[26904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26904) OPAC password recovery allows regexp in email
- [[27021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27021) Chaining on Koha::Objects->empty should always return an empty resultset
- [[27072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27072) Don't process staff interface CSS with rtlcss
- [[27092]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27092) Remove note about "synced mirror" from the README.md

### Authentication

- [[26191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26191) Relocate track_login call in Auth.pm (see 22543)

### Cataloging

- [[11460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11460) Correction to default itemcallnumber system preference in UNIMARC
- [[17515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17515) Advanced Editor - Rancor - Z39 sources not sorted properly
- [[19322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19322) Typo in UNIMARC field 140 plugin
- [[19327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19327) Typo in UNIMARC field 128a plugin
- [[24780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24780) 952$i stocknumber does not display in batch item modification
- [[25189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25189) AutoCreateAuthorities can repeatedly generate authority records when using Default linker
- [[25353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25353) Correct eslint errors in additems.js
- [[25553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25553) Edit item date sort does not sort correctly
- [[26139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26139) 'Place hold' button isn't hidden in all detail views if there are no items available for loan
- [[26289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26289) Deleting biblio in labeled MARC view doesn't work
- [[26330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26330) jQueryUI tabs don't work with non-Latin-1 characters
- [[26605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26605) Correctly URI-encode query string in call number browse plugin
- [[26613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26613) In the unimarc_framework.sql file in the it-IT translation there are wrong value fields for 995 r record

### Circulation

- [[23695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23695) Items holdingbranch should be set to the originating library when generating a manual transfer
- [[24279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24279) Claims Returned does not work when set from moredetail.pl or additem.pl
- [[25293]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25293) Don't call escapeHtml on null
- [[25440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25440) Remove undef and CGI warnings and fix template variables list in circulation rules
- [[25584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25584) When a 'return claim' is added, the button disappears, but the claim date doesn't show up
- [[25587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25587) JavaScript issue - "clear" button doesn't reset some dropdowns
- [[25658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25658) Print icon sometimes obscures patron barcode
- [[25724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25724) Transferred item checked in to shelving cart has cart location removed when transfer is filled
- [[25807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25807) Version 3.008 of Template breaks smart-rules display
- [[25868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25868) Transfers page must show effective itemtype
- [[25890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25890) Checkouts table not sorting on check out date correctly
- [[25940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25940) Two separate print dialogs when checking in/transferring an item
- [[25958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25958) Allow LongOverdue cron to exclude specified lost values
- [[26012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26012) Date in 'Paid for' information not formatted to Time/DateFormat system preferences
- [[26076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26076) Paying selected accountlines in full may result in the error "You must pay a value less than or equal to $x"
- [[26136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26136) Prevent double submit of checkin form
- [[26224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26224) Prevent double submit of header checkin form
- [[26323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26323) Not_for_loan, damaged, location and ccode values must be retrieved from the correct AV category
- [[26362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26362) Overdue report shows incorrect branches for patron, holdingbranch, and homebranch
- [[26583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26583) Unnecessary code in AddIssue
- [[26627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26627) Print and confirming a hold can cause an infinite loop
- [[26675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26675) Typo in line 341 of process_koc.pl

### Command-line Utilities

- [[22470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22470) Missing the table name on misc/migration_tools/switch_marc21_series_info.pl
- [[25853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25853) update_patrons_category.pl has incorrect permissions in repo
- [[25955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25955) compare_es_to_db.pl broken by drop of Catmandu dependency
- [[26337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26337) Remove unused authorities script should skip merge
- [[26407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26407) fix query in 'title exists' in `search_for_data_inconsistencies.pl`
- [[26448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26448) koha-elasticsearch --commit parameter is not used
- [[26601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26601) Add utf8 output to text output of overdue_notices.pl

  **Sponsored by** *Styrian State Library*

### Developer documentation

- [[26617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26617) Add koha-testing-docker to INSTALL file and correct URL

### Documentation

- [[25576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25576) ILL requests Help does not take you to the correct place in the manual
- [[25700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25700) Recent Kohacons are missing from the timeline

### Fines and fees

- [[26161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26161) Confirm and cancel buttons should be underneath the right hand form on the POS page
- [[26189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26189) Table options on points of sale misaligned
- [[26541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26541) Apply discount button misleading
- [[27044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27044) Deprecate core support for PayPal payments

### Hold requests

- [[23485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23485) Holds to pull (pendingreserves.pl) should list barcodes
- [[25555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25555) Holds Queue sorts patrons by firstname
- [[25789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25789) New expiration date on placing a hold in staff interface can be set to a date in the past

  **Sponsored by** *Koha-Suomi Oy*
- [[26460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26460) Wrong line ending (semicolon vs comma) in request.tt
- [[26762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26762) OPAC hold template markup error
- [[26988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26988) Defer loading the hold pickup locations until the dropdown is selected

### I18N/L10N

- [[25346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25346) Only show warn about existing directory on installing translations when verbose is used
- [[25596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25596) "Overpayment refund" is not translatable
- [[25626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25626) Translation issues with OPAC problem reports (status and 'sent to')
- [[26398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26398) Credit and Debit types on creating a manual credits and manual invoices are not translatable
- [[26418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26418) The "description" for REFUND accountlines is not translatable

### Installation and upgrade (web-based installer)

- [[24972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24972) Remove de-DE installer data
- [[25448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25448) Update German (de-DE) framework files
- [[25491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25491) Perl warning at the login page of installer
- [[25695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25695) Missing logging of $@ in onboarding.pl after eval block
- [[26612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26612) Error during web install for it-IT translation

### Lists

- [[13701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13701) Sharing lists: Text hardcoded to 2 weeks, but could be any time frame
- [[25913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25913) Internal server error when calling get_coins on record with no title (245) but with 880 linked to 245

### MARC Authority data support

- [[26606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26606) Correctly URI-encode query string in URL loaded after deleting an authority record

### MARC Bibliographic data support

- [[25701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25701) Facets display in random order
- [[26018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26018) Not all subfields for the following tags are in the same tab (or marked 'ignored')

### Notices

- [[25629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25629) Fix capitalization in sample notices

### OPAC

- [[11994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11994) Fix OpenSearch discovery in the OPAC

  >OpenSearch (https://en.wikipedia.org/wiki/OpenSearch) allows you to search your library's catalog directly from the browser address bar or search box. This fixes the OpenSearch feature so that it now works correctly in Firefox. Note: make sure OPACBaseURL is correctly set.
- [[20783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20783) Cannot embed some YouTube videos due to 403 errors
- [[23276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23276) Don't show tags on tag cloud when tagging is disabled
- [[24352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24352) Wrong labels displaying in result list with OpacItemLocation

  >This fixes the OPAC's MARC21 search results XSLT so that OPAC search result information is correctly labelled based on the OpacItemLocation preference.
  >
  >Previously, search results showed the label "Location(s)" whether the
  >setting was "collection code" or "location."
- [[24473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24473) Syndetics content should be $raw filtered on opac-detail.tt

  >Syndetics provides enhanced content which is displayed in the OPAC under the tabs 'Title Notes', 'Excerpt', 'About the author', and 'Editions'. They provide this information as HTML but Koha currently displays the content with the HTML tags. This fixes this so that the enhanced content displays correctly.
- [[25434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25434) When viewing cart on small screen sizes selections-toolbar is hidden
- [[25597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25597) Javascript errors in self-checkout printslip.pl preventing printing
- [[25869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25869) Coce images not loading for lists (virtualshelves)
- [[25914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25914) Relative's checkouts have empty title in OPAC
- [[25982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25982) OPAC shelves RSS link output is HTML not XML
- [[26070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26070) Google Transliterate API has been deprecated

  >The Google Transliterate API has been deprecated by Google in 2011. This removes the remaining code and GoogleIndicTransliteration system preference from Koha as this is no longer functional.
- [[26119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26119) Patron attribute option to display in OPAC is not compatible with PatronSelfRegistrationVerifyByEmail
- [[26127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26127) When reporting an Error from the OPAC, the URL does not display
- [[26179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26179) Remove redundant import of Google font
- [[26184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26184) Wrap 'items available for pick-up' note when placing a hold in the OPAC in a div element
- [[26262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26262) Paging on course reserves tables in OPAC is broken
- [[26388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26388) Renew all and Renew selected buttons should account for items that can't be renewed
- [[26389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26389) OPAC renewal failure due to automatic renewal does not have a failure message
- [[26421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26421) Use Bootstrap screen reader text class for shelf browser messages
- [[26478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26478) Display issue with buttons on the self checkout screens
- [[26512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26512) Display issue with buttons for OPAC checkout note
- [[26526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26526) Use of checkout notes not clear in OPAC
- [[26619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26619) Cart - The "Print" button is only translated when you are in "More details" mode
- [[26647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26647) Add translation context to cancel hold button in OPAC
- [[26719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26719) Replace MSG_NO_RECORD_SELECTED with translatable string
- [[26747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26747) OverDrive always available titles display 999999 copies available
- [[26749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26749) Correct dropdown markup in OPAC cart
- [[26758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26758) Correct OPAC ILL requests page markup
- [[26766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26766) Don't show star rating in dialog when saving a checkout note
- [[26810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26810) OpacCustomSearch is no longer a system preference, we must use the template variable
- [[26886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26886) OPAC suggestions: possible duplicate message should stand out more

### Packaging

- [[17084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17084) Automatic debian/control updates (master)
- [[25509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25509) Remove useless libjs-jquery dependency
- [[25548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25548) Package install Apache performs unnecessary redirects
- [[25778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25778) koha-plack puts duplicate entries into PERL5LIB when multiple instances named
- [[25889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25889) Increase performance of debian/list-deps script
- [[26672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26672) Create metapackage to install Koha and all its dependencies
- [[26702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26702) Remove explicit libnet-stomp-perl from debian/control.in

### Patrons

- [[14708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14708) The patron set as the anonymous patron should not be deletable
- [[25336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25336) Show checkouts/fines to guarantor is in the wrong section of the patron file
- [[26125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26125) In 'Patron search' tab link should lead to patron details instead of checkout screen
- [[26594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26594) Patrons merge problem with restriction
- [[26666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26666) Display issue with address information
- [[26686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26686) Sorting for "Updated on" broken on patron's "Notices" tab

### Plugin architecture

- [[25953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25953) Add ID to installed plugins table to ease styling and DOM mods
- [[26803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26803) Fix PLUGIN_DIR when plugin_dirs is multivalued

### REST API

- [[25570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25570) Listing requests should be paginated by default
- [[25662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25662) Create hold route does not check maxreserves syspref
- [[26271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26271) Call to /api/v1/patrons/{patron_id}/account returns 500 error if manager_id is NULL

### Reports

- [[17801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17801) 'Top Most-circulated items' gives wrong results when filtering by checkout date
- [[26111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26111) Serials module does not appear in reports dictionary
- [[26165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26165) Duplicating large saved report leads to error due to length of URI

### SIP2

- [[25805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25805) SIP will show hold patron name (DA) as something like C4::SIP::SIPServer=HASH(0x88175c8) if there is no patron
- [[25903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25903) Sending a SIP patron information request with a summary field flag in indexes 6-9 will crash server

### Searching

- [[17661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17661) Differences in field ending (whitespace, punctuation) cause duplicate facets

### Searching - Elasticsearch

- [[24567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24567) Elasticsearch: CCL syntax does not allow for multiple indexes to be searched at once
- [[25872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25872) Advanced search on OPAC with limiter but no search term fails when re-sorted
- [[25873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25873) Elasticsearch - Records with malformed data are not indexed
- [[25957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25957) Elasticsearch 5.X - empty subfields cause error on suggestible fields
- [[26009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26009) Elasticsearch homebranch and holdingbranch facets are limited to 10
- [[26313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26313) "Show analytics" and "Show volumes" links don't work with Elasticsearch and UseControlNumber
- [[26487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26487) Add all MARC flavours for not-onloan-count search field
- [[26832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26832) Elasticsearch mappings export should use UTF-8

### Searching - Zebra

- [[26599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26599) Unused parameter name in POD of ModZebra

### Self checkout

- [[25349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25349) Enter in the username field submits the login, instead of moving focus to the password field
- [[25791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25791) SCO print dialog pops up twice
- [[26131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26131) console errors when attempting to open SCO related system preferences
- [[26301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26301) Self-checkout blocks renew for overdues even when OverduesBlockRenewing allows it in opac-user.pl

### Serials

- [[25696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25696) Test prediction pattern button is invalid HTML
- [[26846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26846) serial-collections page should select the expected and late serials automatically

### Staff Client

- [[11223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11223) Incorrect ind 1 semantics for MARC21 785 on the detail page in staff
- [[25521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25521) NewItemsDefaultLocation description should not mention cart_to_shelf.pl
- [[25537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25537) Page reload at branchtransfers.pl loses destination branch
- [[25744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25744) Replace i tags with em AND b tags with strong in the staff interface
- [[25756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25756) Empty HTML table row after OPAC "Appearance" preferences
- [[25804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25804) Remove HTML from title tag of bibliographic detail page
- [[26084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26084) ConsiderOnSiteCheckoutsAsNormalCheckouts description is unclear
- [[26137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26137) Warn on malformed param on log viewer (viewlog.pl)
- [[26249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26249) keep_text class not set inconsistently in cat-search.inc
- [[26445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26445) Search results browser in staff has broken link back to results
- [[26938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26938) Prevent flash of unstyled content on sales table
- [[26939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26939) Account payment_type in the cash register details page should use description instead of code.
- [[26944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26944) Help link from automatic item modification by age should go to the relevant part of the manual

### System Administration

- [[20804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20804) Sanitize input of timeout syspref
- [[25394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25394) Cronjob path in the AuthorityMergeLimit syspref description is wrong

  >Updates the system preference description with the correct path for the cronjob (misc/cronjobs/merge_authorities.pl).
- [[25675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25675) System preference PatronSelfRegistration incorrectly described
- [[25919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25919) Desks link is available in left side menu even if UseCirculationDesks is disabled
- [[26283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26283) dateexpiry and dateenrolled are missing in the new modal for BorrowerMandatoryField and others

  >This enhancement adds the dateenrolled and dateexpiry fields to the list of fields that can be selected in system preferences such as the BorrowerMandatoryField.
- [[26490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26490) Column configuration for account-fines hides the wrong columns
- [[26809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26809) Inconsistent use of full stops on admin-home.tt

  **Sponsored by** *Catalyst*
- [[26922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26922) SendAlerts does not correctly handle error on sending emails
- [[27026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27026) New circulation rule "Days mode" values are not explained anywhere

### Templates

- [[25447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25447) Terminology: Fix button text "Edit biblio"

  >This updates the text on the cataloging main page so that in the menu for each search result the "Edit biblio" link is now "Edit record."
- [[25469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25469) Typo: Item does not belongs to your library
- [[25582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25582) Don't show OPAC problems entry on dashboard when there are no reports
- [[25615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25615) Empty select in "Holds to pull" filters
- [[25718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25718) Correct typo in additem.tt
- [[25747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25747) Don't display a comma when patron has no firstname
- [[25762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25762) Typo in linkitem.tt
- [[25765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25765) Replace LoginBranchname and LoginBranchcode with use of Branches template plugin
- [[25896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25896) Missing closing `td` tag in smart-rules.tt
- [[25974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25974) Remove inline style from table settings administration page
- [[25987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25987) Radio buttons are misaligned in New label batches
- [[26049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26049) Replace li with span class results_summary in UNIMARC intranet XSLT
- [[26093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26093) Markup error after Bug 24279 creates formatting problem
- [[26098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26098) JS error on the fund list view if no fund displayed
- [[26213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26213) Remove the use of jquery.checkboxes plugin when adding orders from MARC file
- [[26234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26234) Default DataTables must know our own classes
- [[26324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26324) Spelling error resizeable vs resizable
- [[26449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26449) Small typo in web installer template
- [[26450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26450) Typo in UNIMARC field 105 plugin template
- [[26538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26538) Display cities list before input text
- [[26551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26551) When importing a framework, the modal heading is too long and runs outside of the dialog
- [[26576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26576) Subfield descriptions on authority detail view are cut off
- [[26678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26678) When putting an item into manual transfer, tabs from detail view show in table
- [[26696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26696) Make payment table has a display issue when credits exist
- [[26723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26723) Improve link text on OverDriveAuthName system preference
- [[26724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26724) Improve link text for downloading the CSV file on patron import page
- [[26725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26725) Improve link text on Patron attributes administration page
- [[26726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26726) Improve link text on Transport cost matrix page
- [[26727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26727) Fix closing `p` tag appearing in the templates
- [[26756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26756) Fix quotes showing behind some system preference descriptions
- [[26782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26782) Circulation conditions: first 2 columns show as sortable, but cannot be sorted
- [[26808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26808) Improve tab key access to circulation confirmation dialog
- [[26816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26816) Remove extra space before comma in staff results item list
- [[26833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26833) Logged in library doesn't show with suggestions count
- [[26889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26889) Remove extra space from "Damaged :" in item search
- [[26935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26935) Incorrect basketid sent for claimacquisition and claimissues

### Test Suite

- [[24147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24147) Objects.t is failing randomly
- [[25514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25514) REST/Plugin/Objects.t is failing randomly
- [[25623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25623) Some tests in oauth.t do not roll back
- [[25638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25638) API related tests failing on comparing floats
- [[25641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25641) Koha/XSLT/Base.t is failing on U20
- [[25729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25729) Charges/Fees.t is failing on slow servers due to wrong date comparison
- [[25811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25811) authentication.t is failing randomly
- [[26043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26043) Holds.t is failing randomly
- [[26115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26115) Remove leftover Carp::Always
- [[26162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26162) Prevent Selenium's StaleElementReferenceException
- [[26365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26365) Koha/Acquisition/Order.t is failing with MySQL 8
- [[26401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26401) xt/fix-old-fsf-address* are no longer needed
- [[26589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26589) t/db_dependent/OAI/Sets.t unit test fails due to OAI-PMH:AutoUpdateSets syspref
- [[26892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26892) Remove warnings from t/db_dependent/Koha/Patrons.t
- [[26971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26971) Remove obsolete test translatable-templates.t
- [[26984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26984) Tests are failing if AnonymousPatron is configured
- [[26986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26986) Second try to prevent Selenium's StaleElementReferenceException
- [[27007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27007) GetMarcSubfieldStructure called with "unsafe" in tests
- [[27062]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27062) pickup_location tests don't deal correctly with existing libraries

### Tools

- [[8437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8437) Large database backups and large exports from export.pl fail under plack
- [[9118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9118) Show only sensible options when editing a unique holiday
- [[25167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25167) Fix not for loan filter in inventory tool
- [[25862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25862) TinyMCE editor mangles  local url links  (relative_urls is true) in tools/koha-new.pl
- [[25893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25893) Log viewer no longer searches using wildcards
- [[25897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25897) Inventory table call number sort should use cn_sort value
- [[26017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26017) Cashup registers never shows on tools page
- [[26121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26121) When using CodeMirror in News Tool DatePicker is hard to see
- [[26124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26124) Console errors on tools_koha-news when editing with TinyMCE
- [[26236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26236) log viewer does not translate the interface properly
- [[26414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26414) Unable to export Withdrawn status using CSV profile

  >This patch fixes the export of MARC records and the withdrawn status when using CSV profiles. Before this fix the full 952 field was exported, rather than just the withdrawn status.
- [[26664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26664) Inventory: Sorting column 'Last seen' goes wrong
- [[26781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26781) Marc Modification Templates treat subfield 0 and no subfield set
- [[26784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26784) Editing a MARC modification template is noisy

### Web services

- [[22806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22806) CanBookBeReserve and CanItemBeReserve do not check AllowHoldsOnPatronsPossessions

  >This enhancement makes sure that checks for the "AllowHoldsOnPatronsPossessions" policy is now made for all interfaces (Staff interface, OPAC, WebServices). Before this change it was not checked for WebServices (ILS-DI).
  >
  >"AllowHoldPolicyOverride" can be used to override this setting for the Staff interface.
  >
  >Note: This enhancement introduces a behaviour change, so if you use either of these system preferences review the settings to make sure they work as expected.
- [[25793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25793) OAI 'Set' and 'Metadata' dropdowns broken by OPAC jQuery upgrade

### Z39.50 / SRU / OpenSearch Servers

- [[25702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25702) Actions button on Search results from Z39.50 is displayed incorrectly

## New system preferences

- AddressForFailedOverdueNotices
- ArticleRequestsMandatoryFieldsItemOnly
- AutoCreditNumber
- BiblioItemtypeInfo
- CircConfirmItemParts
- DefaultLongOverdueSkipLostStatuses
- EdifactInvoiceImport
- HoldsNeedProcessingSIP
- ILLDefaultStaffEmail
- ILLHiddenRequestStatuses
- ILLSendStaffNotices
- NewsToolEditor
- NoIssuesChargeGuarantorsWithGuarantees
- NoRefundOnLostReturnedItemsAge
- NotesToHide
- OAI-PMH:AutoUpdateSetEmbedItemData
- OPACHoldsHistory
- OPACSuggestionUnwantedFields
- OpacMetaDescription
- PatronDuplicateMatchingAddFields
- PhoneNotification
- Pseudonymization
- PseudonymizationPatronFields
- PseudonymizationTransactionFields
- RecordStaffUserOnCheckout
- SkipHoldTrapOnNotForLoanValue
- UnseenRenewals

## Renamed system preferences

- NotesBlacklist => NotesToHide

## Deleted system preferences

- opaccredits
- OpacCustomSearch
- OpacLoginInstructions
- GoogleIndicTransliteration
- AllowPurchaseSuggestionBranchChoice

## New authorized value categories

- HOLD_CANCELLATION

## New letter codes

- ILL_PICKUP_READY
- ILL_REQUEST_UNAVAIL
- ILL_REQUEST_CANCEL
- ILL_REQUEST_MODIFIED
- ILL_PARTNER_REQ

## Technical highlights

### Significant changes for developers

- [[22417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22417) A task queue is added to Koha

> It relies on the STOMP protocol to notify the worker about the tasks. Koha is now using RabbitMQ as the message broker.
> A new page is added for monitoring the background job execution (/cgi-bin/koha/admin/background_jobs.pl).
> This sets the ground for future improvements for asynchronous  and long running tasks. All background jobs that prevent us from full Plack experience, will be migrated in a short term. A way for plugin methods to be scheduled for execution is one of the things devs are working on as well. 

- [[20582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20582) Koha as a Mojolicious application

> While experimental at this point, this development prepares the ground for new ways to think of Koha pages and routes. It also allows us to think of relying on non-blocking application servers like Hypnotoad, and thus being able to implement asynchronous code.
> To test, use starman with the new `app.psgi` at the root of Koha source code, or use morbo/hypnotoad with scripts `bin/opac` and `bin/intranet`. A reverse proxy is not needed but you can use one, and basic configuration files for apache and nginx are provided in `etc/`.
> This also allows to generate simpler containerized deployments of Koha.


- [[26672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26672) Create metapackage to install Koha and all its dependencies

> Two new Koha packages have been created: `koha-full` and `koha-core`;  Both packages are currently considered as experimental, and are not recommended for production use until further notice. We will be testing them during the 20.11 release cycle.

- [[26893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26893) Debian 11 support

> Currently the Debian 11 version of JSON::Validator (v4.10) is incompatible with Koha. A temporary solution has been to provide JSON::Validator (v3.25). 
The package is named 'libjson-validator-perl-4.10+really3.25-koha1', following the '+really' naming convention described in section 5.6.12.1 here: https://www.debian.org/doc/debian-policy/ch-controlfields.html
> Installing Koha on Debian 11 now requires the 'bullseye' component to be added to the apt repo definition, example below...
> `$ echo 'deb http://debian.koha-community.org/koha stable main bullseye' | sudo tee /etc/apt/sources.list.d/koha.list`
> This requirement will eventually be removed as we upgrade to JSON::Validator (v4.10)

- Plack error logs are now timestamped  and split for each PSGI application for Plack-enabled Koha.
The new log files are `plack-opac-error.log`, `plack-intranet-error.log`, and `plack-api-error.log` and can be found in the Koha instance log directory.
- auto_savepoint has been turned on at database connection level to properly handle nested transactions ([[26639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26639))
- 3 system preferences have been moved to news block: `opaccredits`, `OpacCustomSearch` and `OpacLoginInstructions`
- The whole test suite passes when Elasticsearch is used ([[26250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26250))
- The `authnotrequired` parameter of get_template_and_user was audited this cycle. It should now only be used when we need to override the value of `OPACPublic`; It's presence will now provoke a QA script warning ([[24663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24663)).
- Removal of jquery.checkboxes ([[26006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26006))
- Update of the OPAC bootstrap template to bootstrap v4 ([[20168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20168))
- The .mailmap file has been updated to reflect the current project's history (26394 and 26621). It will provide us a better author mapping on http://git.koha-community.org/stats/koha-master/authors.html
- Removal of items.paid for once and for all ([[26268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26268))
The `paid` field in the `items` table has been removed to prevent accidental re-introduction of syncing code and overhead.  The only place where the value is surfaced in the UI has been replaced with an on-demand calculated value.
- Allow setting trace_to parameter in Elasticsearch config ([[26310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26310))
- The showLastPatron cookie has been removed and is now stored client-side only (localStorage)
- Add a generic 'phone' message transport type for notices ([[25333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25333) and [[25334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25334))

> The existing 'phone' message transport type has been first renamed 'itiva' and then another new generic 'phone' has been created.
> Talking Tech as a company has sold itiva, which is the actual name of the software. To pave the way for pluggable phone notices, it made sense to rename our existing 'phone' transport to itiva. It should be noted that the itvia transport doesn't operate in the same way as all the other transports.
> The new generic 'phone' transport behaves the same as email, sms, and print. That is, it generates the notice based on what is put in the content of the slips and notices module, just like all the transports except itiva. Koha does nothing with these notices. If you were to set up phone notices in Koha, they would remain pending forever. The idea is to have plugins to handle sending phone notices and updating the status of those notices. A plugin that utilises  Twilio to make phone notices calls is already available, but we could also have plugins for things like ShoutBomb, PBXs like Asterisk.

### Dev tools

- misc/devel/get-prepared-letter.pl is a new developer script to preview a letter ([[24591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24591))
It's a simple helper script to test the result of GetPreparedLetter. See `misc/devel/get-prepared-letter.pl --help`
- misc/devel/update_dbix_class_files.pl has the --force option to force a schema overwrite ([[25511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25511))
Sometimes, if you know what you are doing, you may want to force a schema overwrite regardless of whether the hashes report there are changes above the fold.
***WARNING***: Use this at your own risk.. it's helpful if you are maintaining a fork or in other such cases. You should always attempt to run the script without force first and only resort to using force if that fails. It is also very much worthwhile checking the diff after running with force to ensure you have not resulted in any unexpected changes.
- Add debug option to koha-indexer ([[24306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24306))
- gulp is now required to create or update PO files ([[25067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25067)). Use `gulp po:create [--lang xx-XX]` or `gulp po:update [--lang xx-XX]`
The old method using `misc/translator/translate create|update` still works, but is deprecated.

### Refactoring
- C4::Accounts::manualinvoice has been removed ([[22394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22394))
- C4 :: Logs :: GetLogs has been removed, use Koha::ActionLogs->search instead ([[23632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23632))
- C4 :: Acquisition :: DelOrder has been moved to Koha::Acquisition::Order->cancel
- C4 :: Acquisition :: DelBasket has been replaced by Koha::Acquisition::Basket->delete
- C4 :: Acquisition :: CloseBasket has been moved to Koha::Acquisition::Basket->close
- C4::Circulation::_RestoreOverdueForLostAndFound has been moved as a trigger of Koha::Item->store ([[23091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23091))
- The whole C4::Images module has been moved to Koha::CoverImage[s] ([[26145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26145))
- C4::Suggestions::CountSuggestion has been replaced by a call to Koha::Suggestions->search->count
- C4::Koha::GetDailyQuote has been replaced by Koha::Quote->get_daily_quote
- C4::Biblio::GetMarcHosts has been removed (it was not used)
- C4::Bookseller has been removed, its last remaining subroutine GetBooksellersWithLateOrders has been replaced by a call to Koha::Acquisition::Orders->search

### Improving the codebase
- All our codebase now passes perlcritic ([[21395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21395))
All perlcritic violations have been removed from the code, and a .perlcriticrc file has been added. When writing new code, please make sure that it does not add perlcritic errors. Run `perlcritic <modified_file.pl>` to check.  
- Expected DBI warnings have been hidden from the test output ([[26157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26157))
Tests should not output warnings, especially when they are expected. We still have lot of warnings that need to be hidden, see [[25515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25515) for the long term goal to reach.
- Preparing for Perl 7 - Prohibit indirect object notation ([[25898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25898))

> We encounter only one issue that we would face with Perl 7 and we fixed it.
> Indirect object notation will be forbidden by default in Perl 7. You must now write My::Class->new instead of new My::Class

- Installer files have been moved under the `mandatory` subdirectory (installer/data/mysql/) ([[23895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23895))
- Ability to localize and translate system preferences with new yaml based installer ([[24973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24973)) 

> If you are maintaining the translation of a language under installer/data/mysql, you should consider removing it and use the usual workflow for translation instead (using translate.koha-community.org).

### Accessibility improvements
An accessibility audit on the OPAC took place during the cycle which resulted in a number of bugs being reported, and subsequently fixed.

- Header levels - All OPAC pages should now contain just one H1 level heading and then consistent header increments without gaps.
- Skip to main content - A hidden button now appears upon first tab navigation to allow keyboard users skip to the main content of the page quickly without having to tab through all the navigation elements.
- We now consistently introduce content on all OPAC pages using properly defined headers.
- DataTables content overlap improvements were undertaken to prevent content overlapping at high zoom levels.
- The aria-label html tag was exposed to the translation tools to encourage a wider adoption of it's use.
- Some new coding guidelines were introduced focused on accessibility and bugs opened to collect cases where these new guidelines are not yet adhered to in the existing codebase: [[26926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26926) - Update all occurrences of `<input type="number">` to apply ACC2 coding guideline.
- Finally, to encourage continued focus on accessibility in future cycles, a new role 'Accessibility Advocate' was added to the team for the next cycle.

### REST API enhancements
- Add columns_settings support to API datatables wrapper ([[25287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25287))

> In order to properly use our API for server-side rendering of DataTables, a wrapper has been introduced. This wrapper has been added columns settings support. The libraries and cities pages are using this wrapper to render using the API and use server-side pagination and filtering. They can be used as sample implementations. A more complex example can be found on bug [[20212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20212) which is expected to land on the next cycle.

### Plugins support
4 new plugin's hooks are available:

- `after_hold_create`

> Once a hold has been placed, the 'after_hold_create' plugin hook is called. Each implementing plugin will be passed the related Koha::Hold object as parameter.

- `after_circ_action`

> After circulation actions take place, the 'after_circ_action' hook is called. Each implementing plugin will be passed a data structure like this:
```
{
        action => <string describing the action>,
        payload => { hashref with relevant information }
}
```

> Here' s a list of the possible actions and the payload they carry (this should be a table, with columns type, payload):

> - checkout: `{ type => 'onsite_checkout' | 'issue', checkout => Koha::Checkout object }`

> - checkin: `{ checkin => Koha::Checkout object }`

> - renewal: `{ checkout => Koha::Checkout object }`

- `opac_results_xslt_variables` and `opac_detail_xslt_variables`

> These hooks will be called when rendering the search results and detail page in the OPAC, respectively. The implemented methods on the plugin, need to return a hashref with key:value pairs. No nested structures are expected. Those variables will be injected into the XSLT pipeline so people tweaking their XSLTs can take advantage of them. As an example, take a look at the following link: https://bugs.koha-community.org/bugzilla3/attachment.cgi?id=107477

### Features deprecation

- We have announced the deprecation of OpacGroupResults ([[20410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20410)) on the mailing list.
https://lists.katipo.co.nz/pipermail/koha/2020-November/055362.html

- Also, the PayPal logic code will be removed from Koha ([[23215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23215)).
When the plugin hooks for payment plugins were introduced, many payment plugins were written and distributed. PayPal is not different than any of those, and there is an implementation already. The PayPal plugin provides interesting new features as it moved forward: support for per-library configurations, including minimum theresholds, credentials, etc.
As of now, the core PayPal payments feature is considered deprecated and is marked for removal on the next release (21.05). Instructions for migrating your current configuration into the plugin's can be found on the plugin site(https://gitlab.com/thekesolutions/plugins/koha-plugin-pay-via-paypal).


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:

- [English](http://koha-community.org/manual/20.11/en/html/)
- [Arabic](http://koha-community.org/manual/20.11/ar/html/)
- [Chinese - Taiwan](http://koha-community.org/manual/20.11/zh_TW/html/)
- [Czech](http://koha-community.org/manual/20.11/cs/html/)
- [French](http://koha-community.org/manual/20.11/fr/html/)
- [French (Canada)](http://koha-community.org/manual/20.11/fr_CA/html/)
- [German](http://koha-community.org/manual/20.11/de/html/)
- [Hindi](http://koha-community.org/manual/20.11/hi/html/)
- [Italian](http://koha-community.org/manual/20.11/it/html/)
- [Portuguese - Brazil](http://koha-community.org/manual/20.11/pt_BR/html/)
- [Spanish](http://koha-community.org/manual/20.11/es/html/)
- [Turkish](http://koha-community.org/manual/20.11/tr/html/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (89.2%)
- Armenian (93.4%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (85.4%)
- Czech (73.1%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (74.1%)
- French (73.5%)
- French (Canada) (89%)
- German (100%)
- German (Switzerland) (67.5%)
- Greek (57%)
- Hindi (91.3%)
- Italian (100%)
- Norwegian Bokmål (63.9%)
- Polish (65.8%)
- Portuguese (77.9%)
- Portuguese (Brazil) (88.7%)
- Slovak (80.4%)
- Spanish (94.2%)
- Swedish (75.3%)
- Telugu (80.3%)
- Turkish (86.1%)
- Ukrainian (61.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.00 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall
  - Martin Renvoize
  - Alex Arnaud
  - Julian Maurice
  - Matthias Meusburger

- Topic Experts:
  - Elasticsearch -- Frédéric Demians
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize
  - CAS/Shibboleth -- Matthias Meusburger

- Bug Wranglers:
  - Michal Denár
  - Holly Cooper
  - Henry Bolshaw
  - Lisette Scheer
  - Mengü Yazıcıoğlu

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Martin Renvoize
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Kelly McElligott
  - Jessica Zairo
  - Chris Cormack
  - Henry Bolshaw
  - Jon Drucker

- Translation Manager: Bernardo González Kriegel


- Release Maintainers:
  - 20.05 -- Lucas Gass
  - 19.11 -- Aleisha Amohia
  - 19.05 -- Victor Grousset

- Release Maintainer mentors:
  - 19.11 -- Hayley Mapley
  - 19.05 -- Martin Renvoize

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 20.11.00

- [Association KohaLa](https://koha-fr.org/)
- [ByWater Solutions](https://bywatersolutions.com/)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Cooperative Information Network (CIN)
- Galway-Mayo Institute of Technology
- Gerhard Sondermann Dialog e.K. (presseplus.de, presseshop.at, presseshop.ch)
- Horowhenua District Council
- Institute of Technology Carlow
- Institute of Technology Tallaght
- Koha-Suomi Oy
- National Library of Finland
- [Northeast Kansas Library System](http://www.nekls.org)
- Orex Digital
- [PTFS Europe](https://ptfs-europe.com)
- [Royal College of Music](https://www.rcm.ac.uk/)
- [South East Kansas Library System](http://www.sekls.org)
- Styrian State Library
- [Theke Solutions](https://theke.io/)

We thank the following individuals who contributed patches to Koha 20.11.00

- Aleisha Amohia (4)
- Tomás Cohen Arazi (138)
- Philippe Blouin (2)
- Henry Bolshaw (1)
- Alex Buckley (9)
- Colin Campbell (3)
- Nick Clemens (173)
- David Cook (29)
- Chris Cormack (1)
- Frédéric Demians (3)
- Jonathan Druart (545)
- Magnus Enger (2)
- John Fawcett (2)
- Katrin Fischer (126)
- Andrew Fuerste-Henry (13)
- Lucas Gass (22)
- Didier Gautheron (8)
- Caitlin Goodger (1)
- Victor Grousset (1)
- David Gustafsson (6)
- Kyle M Hall (91)
- Mark Hofstetter (1)
- Andrew Isherwood (29)
- Mason James (21)
- Andreas Jonsson (1)
- Olli-Antti Kivilahti (2)
- Bernardo González Kriegel (3)
- Joonas Kylmälä (22)
- Nicolas Legrand (10)
- Owen Leonard (209)
- Ere Maijala (1)
- Hayley Mapley (3)
- Ivan Masár (2)
- Julian Maurice (32)
- Matthias Meusburger (5)
- Josef Moravec (17)
- Agustín Moyano (36)
- David Nind (2)
- Andrew Nugged (11)
- Björn Nylén (1)
- Séverine Queune (2)
- Liz Rea (1)
- Martin Renvoize (229)
- Phil Ringnalda (2)
- Alexis Ripetti (1)
- David Roberts (4)
- Tal Rogoff (4)
- Marcel de Rooy (38)
- Caroline Cyr La Rose (3)
- Andreas Roussos (5)
- Lisette Scheer (3)
- Slava Shishkin (3)
- Joe Sikowitz (2)
- Fridolin Somers (29)
- Arthur Suzuki (3)
- Emmi Takkinen (16)
- Lari Taskula (2)
- Koha Translators (1)
- Petro Vashchuk (5)
- Timothy Alexis Vass (4)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.00

- Athens County Public Libraries (209)
- BibLibre (77)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (126)
- Bibliothèque Universitaire des Langues et Civilisations (BULAC) (12)
- ByWater-Solutions (299)
- cass.govt.nz (4)
- Catalyst (14)
- Catalyst Open Source Academy (4)
- centrum.sk (2)
- Chetco Community Public Library (2)
- Dataly Tech (5)
- David Nind (2)
- Fenway Library Organization (2)
- Göteborgs Universitet (2)
- hofstetter.at (1)
- Hypernova Oy (3)
- Independant Individuals (56)
- Koha Community Developers (547)
- KohaAloha (21)
- Kreablo AB (1)
- Latah County Library District (3)
- Libriotech (2)
- Prosentient Systems (29)
- PTFS-Europe (264)
- Rijks Museum (38)
- Solutions inLibro inc (6)
- Tamil (3)
- Theke Solutions (174)
- ub.lu.se (5)
- UK Parliament (1)
- Universidad Nacional de Córdoba (3)
- University of Helsinki (23)
- voipsupport.it (2)
- Wellington East Girls' College (1)

We also especially thank the following individuals who tested patches
for Koha

- Marco Abi-Ramia (2)
- Michael Adamyk (1)
- Hugo Agud (9)
- Aleisha Amohia (1)
- Tomás Cohen Arazi (168)
- Alex Arnaud (44)
- Donna Bachowski (3)
- Marjorie Barry-Vila (3)
- Bob Bennhoff (11)
- Henry Bolshaw (5)
- Sonia Bouis (20)
- Christopher Brannon (14)
- Alex Buckley (2)
- Jérôme Charaoui (3)
- Nick Clemens (146)
- Rebecca Coert (7)
- David Cook (27)
- Holly Cooper (4)
- Chris Cormack (12)
- Sarah Cornell (1)
- Frédéric Demians (6)
- Michal Denar (9)
- Jonathan Druart (1456)
- Magnus Enger (4)
- Bouzid Fergani (10)
- Katrin Fischer (711)
- Andrew Fuerste-Henry (65)
- Daniel Gaghan (3)
- Jeff Gaines (1)
- Bonnie Gardner (1)
- Lucas Gass (20)
- Didier Gautheron (9)
- Todd Goatley (1)
- Claire Gravely (2)
- Victor Grousset (54)
- Amit Gupta (18)
- Kyle M Hall (118)
- Stina Hallin (3)
- Sally Healey (63)
- Heather Hernandez (5)
- Abbey Holt (7)
- Andrew Isherwood (1)
- Mason James (1)
- Brandon Jimenez (7)
- Barbara Johnson (20)
- Pasi Kallinen (2)
- Jill Kleven (1)
- Bernardo González Kriegel (6)
- Rhonda Kuiper (1)
- Joonas Kylmälä (40)
- Peter Lau (1)
- Nicolas Legrand (3)
- Owen Leonard (78)
- Ere Maijala (1)
- Hayley Mapley (6)
- Jennifer Marlatt (1)
- Jesse Maseto (1)
- Ivan Masár (1)
- Julian Maurice (38)
- Kelly McElligott (17)
- Matthias Meusburger (1)
- Josef Moravec (29)
- Agustín Moyano (11)
- David Nind (233)
- Kim Peine (3)
- Emma Perks (8)
- Simon Perry (9)
- Séverine Queune (38)
- Laurence Rault (2)
- Liz Rea (14)
- Martin Renvoize (359)
- Phil Ringnalda (1)
- Alexis Ripetti (6)
- Jason Robb (4)
- Marcel de Rooy (92)
- Caroline Cyr La Rose (9)
- Andreas Roussos (2)
- Lisette Scheer (29)
- Maryse Simard (1)
- Fridolin Somers (14)
- Michael Springer (1)
- Debi Stears (1)
- Myka Kennedy Stephens (1)
- Deb Stephenson (1)
- Arthur Suzuki (7)
- Emmi Takkinen (7)
- Timothy Alexis Vass (10)
- Ben Veasey (6)
- Niamh Walker-Headon (5)
- George Williams (1)
- Mengü Yazıcıoğlu (3)
- Jessica Zairo (2)
- Amandine Zocca (1)
- Christofer Zorn (4)
- Martin Šťastný (2)

And people who contributed to the Koha manual during the release cycle of Koha 20.11.00

  * kellymc03 (6)
  * Aleisha Amohia (1)
  * Alexander Borkowski (7)
  * Alex Buckley (1)
  * Chris Cormack (3)
  * Caroline Cyr La Rose (143)
  * Katrin Fischer (8)
  * Mark Hofstetter (1)
  * Marie-Luce Laflamme (1)
  * Hayley Mapley (1)
  * Kelly McElligott (3)
  * Kyle M Hall (1)
  * David Nind (2)
  * Martin Renvoize (4)
  * Kathryn Tyree (2)
  * Lucy Vaux-Harvey (5)

We thank the following individuals who mentored new contributors to the Koha project

- Andrew Nugged


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Special thanks

I would like to thank the whole development core team for our constant communication improvement.

We managed to better focus on the same topics at the same time and we are going to enhance Koha quicker and greatly in the next cycle.

I am really looking forward to continue what we started over the last 6 months!

Mason, our package manager, did an impressive work the last couple of cycles to improve our packaging system, thanks to him!

Thanks to BibLibre, ByWater Solution and PTFS Europe for their continuous support and trust in me.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/Koha-community/Koha.git)

The branch for this version of Koha and future bugfixes in this release
line is master.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Nov 2020 13:45:33.
