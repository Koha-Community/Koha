# RELEASE NOTES FOR KOHA 20.11.03
23 févr. 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.03 is a bugfix/maintenance release.

It includes 2 new features, 22 enhancements, 74 bugfixes, 1 security fix.

### System requirements

You can learn about the system components (like OS and database) for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

## Security fix

- [[27715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27715) Possibly SQL injection in virtualshelves

## New features

### Plugin architecture

- [[25245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25245) Add a plugin hook to allow running code on a nightly basis

  >This patchset adds a new cronjob script to Koha, plugins_nightly.pl
  >
  >This script will check for plugins that have registered a cronjob_nightly method and execute that method.
  >
  >This enhancement allows users to install and setup plugins that require cronjobs without backend system changes and prevents the addition of new cronjob files for each plugin.

### Staff Client

- [[14004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14004) Add ability to temporarily disable added CSS and Javascript in OPAC and interface

  >This allows to temporarily disable any of OPACUserCSS, OPACUserJS, OpacAdditionalStylesheet, opaclayoutstylesheet, IntranetUserCSS, IntranetUserJS, intranetcolorstylesheet, and intranetstylesheet system preference via an URL parameter.
  >
  >Alter the URL in OPAC or staff interface by adding an additional parameter DISABLE_SYSPREF_<system preference name>=1. 
  >
  >Example:
  >/cgi-bin/koha/mainpage.pl?DISABLE_SYSPREF_IntranetUserCSS=1

## Enhancements

### Acquisitions

- [[27023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27023) Add class names in the suggestions column in suggestions management
- [[27606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27606) Breadcrumbs on parcel.pl should include a link to the vendor
- [[27646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27646) Allow export of acquisitions home and funds table

### Cataloging

- [[26943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26943) Show not for loan descriptions in cataloging search (addbooks.pl)

  >Adds the ability to see not for loan descriptions in the cataloging search results.
- [[27422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27422) HTML5Media is http by default but Youtube is https only

  **Sponsored by** *Banco Central de la República Argentina*

### Command-line Utilities

- [[24272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24272) Add a command line script to compare the syspref cache to the database

  >This script checks the value of the system preferences in the database against those in the cache. Generally differences will only exist if changes have been made directly to the DB or the cache has become corrupted.

### MARC Bibliographic data support

- [[12966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12966) Edition statement missing from card view in Z39.50 result list (acq+cataloguing)

  >This adds the edition statement (MARC21 250) to the card/ISBD views in the Z39.50 search results in the acquisition and cataloging modules.
- [[27022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27022) Add publisher number (MARC21 028) to OPAC and staff detail pages

### Notices

- [[11257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11257) Document <<items.content>> for DUEDGST and PREDUEDGST and update sample notices

### OPAC

- [[12260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12260) Printing a page from bootstrap shows unnecessary links
- [[27029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27029) Detail page missing Javascript accessible biblionumber value
- [[27098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27098) Rename 'Relatives fines' to 'Relatives charges' in OPAC

### Reports

- [[22152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22152) Hide printing the tools navigation when printing reports

### Searching - Elasticsearch

- [[26991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26991) Add action logs to search engine administration

  >This enhancement adds logging of changes made to Elasticsearch. These can be viewed in the log viewer tool, where you can view all search engine changes, or limit to edit mapping and reset mapping actions.

### Staff Client

- [[27582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27582) Breadcrumb incorrect for POS: Library details page

### System Administration

- [[27395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27395) Add warning to PatronSelfRegistrationDefaultCategory to avoid accidental patron deletion

  >This patch adds a warning to the PatronSelfRegistrationDefaultCategory system
  >preference to not use a regular patron category for self registration.
  >
  >If a regular patron category code is used and the cleanup_database cronjob is setup
  >to delete unverified and unfinished OPAC self registrations, it permanently and
  >and unrecoverably deletes all patrons that have registered more than
  >PatronSelfRegistrationExpireTemporaryAccountsDelay days ago.
  >
  >It also removes unnecessary apostrophes at the end of two self registration
  >and modification system preference descriptions.

### Templates

- [[26755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26755) Make the guarantor search popup taller
- [[26958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26958) Move Elasticsearch mapping template JS to the footer
- [[26982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26982) Typo in system preference UsageStats: statisics
- [[27192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27192) Set focus for cursor to item type input box when creating new item types
- [[27210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27210) Typo in patron-attr-types.tt
- [[27289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27289) Template tweaks for point of sale page


## Critical bugs fixed

### Acquisitions

- [[27671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27671) Missing include in orderreceive.tt

### Architecture, internals, and plumbing

- [[27580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27580) NULL values not correctly handled in Koha::Items->filter_by_visible_in_opac
- [[27586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27586) Import patrons script has a confirm switch that doesn't do anything

  >This fixes the misc/import_patrons.pl script so that patrons are not imported unless the --confirm option is used. Currently, if the script is run without "--confirm" option it reports that it is "Running in dry-run mode, provide --confirm to apply the changes", however it imports the patrons anyway.
- [[27676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27676) finesMode=off not correctly handled

### Circulation

- [[27707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27707) Renewing doesn't work when renewal notices are enabled

### Hold requests

- [[27068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27068) HoldsQueue doesn't know how to use holds groups

  >Koha 20.05 introduced local hold groups, but neglected to add support of them in the holds queue. Because of this, the holds queue will not show items the could have filled holds from other libraries in a hold group. This patch set adds support for hold groups to the holds queue builder thus improving Koha's ability to find items to fill hold requests.

### Installation and upgrade (command-line installer)

- [[27466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27466) Update process failing for 20.06.00.023

  >The update 20.06.00.023 for adding options and reconfiguring the QuoteOfTheDay feature would fail. This patch makes sure that the update can be processed correctly.

### SIP2

- [[27589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27589) Error when specifying CR field in SIP Config

### System Administration

- [[27569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27569) marc-framework import function doesn't accept LibreOffice csv/ods file formats

### Tools

- [[27669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27669) reverting and importing status never set when importing/reverting a batch


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[23767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23767) Spent and Ordered total values don't include child funds on acqui-home
- [[24469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24469) Record biblionumber in import_biblio when adding to basket via file
- [[27446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27446) Markup errors in suggestion/suggestion.tt

  >This patch fixes several markup errors in the suggestions template in the staff interface, including:
  >- Indentation
  >- Unclosed tags
  >- Non-unique IDs
  >- Adding comments to highlight markup structure
- [[27547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27547) Typo in parcel.tt
- [[27608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27608) Correct 'accepted by' inconsistency in suggestion.tt

  **Sponsored by** *Collecto*

### Architecture, internals, and plumbing

- [[25381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25381) XSLTs should not define entities
- [[25552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25552) Add missing Claims Returned option to MarkLostItemsAsReturned

  >Marking an item as a return claim checks the system preference MarkLostItemsAsReturned to see if the claim should be removed from the patron record. However, the option for "when marking an item as a return claim" was never added to the system preference, so there was no way to remove a checkout from the patron record when marking the checkout as a return claim. This patch set adds that missing option.
- [[27154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27154) Koha/Util/SystemPreferences.pm must be removed
- [[27179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27179) Misspelling of Method in REST API files

  >This fixes the misspelling of Method (Mehtod to Method) in REST API files.
- [[27327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27327) Indirect object notation in Koha::Club::Hold
- [[27333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27333) Wrong exception thrown in Koha::Club::Hold::add
- [[27530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27530) Sample patron data should be updated and/or use relative dates

### Cataloging

- [[27508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27508) Can't duplicate the MARC field tag with JavaScript if option "advancedMARCeditor" is set to "Don't display"

### Circulation

- [[8287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8287) Improve filter on checked out from overdues
- [[27011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27011) Warnings in returns.pl

  >This patch removes a variable ($name) that is no longer used in Circulation > Check in (/cgi-bin/koha/circ/returns.pl), and the resulting warnings (..[WARN] Use of uninitialized value in concatenation (.) or string at..) that were recorded in the error log.
- [[27538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27538) Cells in the bottom filtering row of the "Holds to pull" table shifted
- [[27548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27548) Warnings "use of uninitialized value" on branchoverdues.pl

  >This fixes the cause of unnecessary "use of uninitialized value" warnings in the log files generated by Circulation > Overdues with fines (/cgi-bin/koha/circ/branchoverdues.pl).
  >
  >This was caused by not taking into account that the "location" parameter for this form is initially empty.
- [[27549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27549) Warning "use of uninitialized value" on renew.pl

  >This fixes the cause of unnecessary "use of uninitialized value" warnings in the log files generated by Circulation > Renew (/cgi-bin/koha/circ/renew.pl).
  >
  >This was caused by not taking into account that the "barcode" parameter for this form is initially empty.
- [[27645]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27645) Duplicate message in batch checkout
- [[27655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27655) Barcode column is missing from "Holds to pull" table preferences yaml file

### Command-line Utilities

- [[11344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11344) Perldoc issues in misc/cronjobs/advance_notices.pl

### Fines and fees

- [[20527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20527) <label> linked to the wrong <input> (wrong "for" attribute) in paycollect.tt

  >This fixes the HTML <label for=""> element for the Writeoff amount field on the Accounting > Make a payment form for a patron - changes "paid" to "amountwrittenoff".
- [[27290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27290) Cash register allows for 'amount tendered' less than amount being paid

### I18N/L10N

- [[27398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27398) Serials: Values in subscription length pull down are not translatable when defining numbering patterns
- [[27416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27416) String 'Modify tag' in breadcrumb is untranslatable

### ILL

- [[25614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25614) "Clear filter" button permanently disabled on ILL request list

### Installation and upgrade (web-based installer)

- [[11996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11996) Default active currencies for ru-RU and uk-UA are wrong

  >This fixes the currencies in the sample installer files for Russia (ru-RU; changes GRN -> UAH, default remains as RUB) and the Ukraine (uk-UA; changes GRN -> UAH).
- [[24810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24810) French SQL files for "news" contain "Welcome into Koha 3!"

  >This removes the Koha version number from the sample news items for the French language installer files (fr-FR and fr-CA).
- [[24811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24811) French SQL files for "news" contain broken link to the wiki

  >This fixes a broken link in the sample news items for the French language installer files (fr-FR and fr-CA).

### MARC Bibliographic data support

- [[25632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25632) Update MARC21 frameworks to update Nr. 30 (May 2020)

### Notices

- [[24447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24447) POD of C4::Members::Messaging::GetMessagingPreferences() is misleading

### OPAC

- [[26406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26406) Suggestions filter does not work
- [[26578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26578) OverDrive results can return false positives when searches contain CCL syntax
- [[27261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27261) PatronSelfRegistrationBorrowerUnwantedField should exclude branchcode

  >This patch excludes the ability to add branchcode to the PatronSelfRegistrationBorrowerUnwantedField system preference.
- [[27450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27450) Making password required for patron registration breaks patron modification
- [[27543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27543) Tooltip on opac-messaging.pl obscured by table headers

  >This patch fixes the display of tooltips in a patrons OPAC account for the 'your messaging' section. It corrects which Bootstrap assets are compiled with the OPAC CSS - the file for Bootstrap tooltips should be included.
- [[27571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27571) "Add to lists" on MARC and ISBD view of OPAC detail page doesn't open in new window
- [[27628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27628) Fix minor HTML markup errors in OPAC search results templates
- [[27633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27633) Display of 440$v doubled up in the OPAC

  >This fixes the display of 440$v (Series Statement/Added Entry-Title - Volume/sequential designation ($v)) in the OPAC. Before this fix $v is included in the title link and then displayed after the ;. With the fix $v is only displayed after the ; and is not duplicated in the title link.

### Patrons

- [[17364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17364) branchcode in BorrowerUnwantedField causes software error when saving patron record

  >A more user friendly interface for selecting database columns for some system preferences (such as BorrowerUnwantedField) was added in Koha 20.11 (Bug 22844). 
  >
  >Some database columns should be excluded from selection as they can cause server errors. For example, branchcode in BorrowerUnwantedField is required for adding patrons - if selected it causes a server error and you can't add a patron, so it should not be selectable.
  >
  >This big fixes the issue by:
  >
  >- allowing developers to define the database columns to exclude from selection in the .pref system preference definition file using "exclusions: "
  >
  >- disabling the selection of the excluded database columns in the staff interface when configuring system preferences that allow selecting database columns
  >
  >- updating the BorrowerUnwantedField system preference to exclude branchcode
- [[26059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26059) Create guarantor/guarantee links on patron import
- [[27454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27454) Additional patron attributes change sequence on every reload of edit page

  >This fixes the order that additional patron attributes are displayed on the patron edit form. They are now sorted by the attribute code, before this they displayed in a random order.

### REST API

- [[26181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26181) Holds placed via the REST API should not be forced by default even if AllowHoldPolicyOverride is enabled

  >This patch disables AllowHoldPolicyOverride by default in the /holds REST API. It also adds tests for this behaviour, and adds a header that can be used to request the override explicitly.

### SIP2

- [[25808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25808) Renewal via the SIP 'checkout' message gives incorrect message
- [[27204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27204) SIP patron information request with fee line items returns incorrect data

### Staff Client

- [[27321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27321) Make excluded database columns in system preferences more clearly disabled

  >This enhancement styles non-selectable database columns in system preferences in a light grey (#cccccc), making them easier to identify. Currently the checkbox and label are the same color as selectable columns.
- [[27653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27653) Do not include 'caption' row in print/copy export of datatables

### System Administration

- [[27264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27264) Reword sentence of OPACHoldsHistory

### Templates

- [[20238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20238) Show description of ITEMTYPECAT instead of code in itemtypes summary table

  >This enhancement changes the item types page (Koha administration > Basic parameters > Item types) so that the search category column displays the ITEMTYPECAT authorized value's description, instead of the authorized value code. (This makes it consistent with the edit form where it displays the descriptions for authorized values.)
- [[24055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24055) Description of PayPalReturnURL system preference is unclear

  >This enhancement improves the description of the PayPalReturnURL. Changed from 'configured return' to 'configured return URL' as this is what it is called on the PayPal website.
- [[26602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26602) Datatables - Actions columns should not be exported
- [[27027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27027) Typo: has successfully been modified.. %s

  >This fixes a grammatical error in koha-tmpl/intranet-tmpl/prog/en/modules/admin/background_jobs.tt (has successfully been modified..) - it replaces two full stops at the end of the sentence with one.
- [[27430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27430) Use minimum length for patron category on password hint

  >This corrects the hint on the patron add/edit form to take into account that the minimum password length can now also be set on patron category level.
- [[27457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27457) Set focus for cursor to Debit type code field when creating new debit type
- [[27458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27458) Set focus for cursor to Credit type code field when creating new credit type
- [[27525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27525) 'wich' instead of a 'with' in a sentence

  >This patch fixes two spelling errors in the batchMod-del.tt template that is used by the batch item deletion tool in the staff interface: "wich" -> "with."
- [[27531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27531) Remove type attribute from script tags: Cataloging plugins
- [[27561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27561) Remove type attribute from script tags: Various templates
- [[27654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27654) "Table settings for Pages" need to be sorted on "Administration -> Table settings"

### Test Suite

- [[27554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27554) Clarify and add tests for Koha::Patrons->update_category_to child to adult

### Tools

- [[26298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26298) If MaxItemsToProcessForBatchMod is set to 1000, the max is actually 999
- [[27576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27576) Don't show import records table when cleaning a batch

### Web services

- [[17229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17229) ILS-DI HoldTitle and HoldItem should check if patron is expired


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

- Arabic (100%)
- Armenian (99.9%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (87.5%)
- Czech (73.3%)
- English (New Zealand) (59.8%)
- English (USA)
- Finnish (78.4%)
- French (77%)
- French (Canada) (91.5%)
- German (100%)
- German (Switzerland) (67.2%)
- Greek (60.7%)
- Hindi (95.4%)
- Italian (100%)
- Norwegian Bokmål (63.6%)
- Polish (71.1%)
- Portuguese (77.5%)
- Portuguese (Brazil) (89%)
- Russian (90.3%)
- Slovak (80.9%)
- Spanish (96%)
- Swedish (74.8%)
- Telugu (79.9%)
- Turkish (91.2%)
- Ukrainian (63.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.03 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - David Cook
  - Agustín Moyano
  - Martin Renvoize
  - Marcel de Rooy
  - Joonas Kylmälä
  - Julian Maurice
  - Tomás Cohen Arazi
  - Josef Moravec
  - Nick Clemens
  - Kyle Hall
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Amit Gupta
  - Mengü Yazıcıoğlu
  - Indranil Das Gupta

- Packaging Managers:
  - David Cook
  - Mason James
  - Agustín Moyano

- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey
  - Henry Bolshaw
  - David Nind

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 20.11 -- Fridolin Somers
  - 20.05 -- Andrew Fuerste-Henry
  - 19.11 -- Victor Grousset

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 20.11.03:

- Banco Central de la República Argentina
- [Collecto](https://collecto.ca)

We thank the following individuals who contributed patches to Koha 20.11.03.

- Ethan Amohia (1)
- Tomás Cohen Arazi (9)
- Eden Bacani (5)
- Philippe Blouin (1)
- Nick Clemens (16)
- David Cook (1)
- Jonathan Druart (45)
- Katrin Fischer (5)
- Lucas Gass (5)
- Didier Gautheron (1)
- Kyle M Hall (14)
- Mazen Khallaf (3)
- Amy King (4)
- Bernardo González Kriegel (1)
- Joonas Kylmälä (1)
- Owen Leonard (12)
- Ava Li (4)
- Catherine Ma (2)
- Julian Maurice (2)
- Agustín Moyano (1)
- James O'Keeffe (3)
- Martin Renvoize (10)
- Marcel de Rooy (3)
- Caroline Cyr La Rose (2)
- Andreas Roussos (1)
- Fridolin Somers (10)
- Arthur Suzuki (1)
- Emmi Takkinen (2)
- Petro Vashchuk (6)
- Ella Wipatene (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.03

- Athens County Public Libraries (12)
- BibLibre (14)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (5)
- ByWater-Solutions (35)
- Dataly Tech (1)
- gamil.com (3)
- Independant Individuals (27)
- Koha Community Developers (45)
- Koha-Suomi (2)
- Prosentient Systems (1)
- PTFS-Europe (10)
- Rijks Museum (3)
- Solutions inLibro inc (3)
- Theke Solutions (10)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Mark Hofstetter <mark@hofstetter.at> (1)
- Tomás Cohen Arazi (3)
- Eden Bacani (1)
- Marjorie Barry-Vila (1)
- Nick Clemens (17)
- David Cook (1)
- Sarah Daviau (1)
- Michal Denar (1)
- Jonathan Druart (122)
- Katrin Fischer (77)
- Martha Fuerst (1)
- Andrew Fuerste-Henry (8)
- Marti Fyerst (3)
- Brendan Gallagher (2)
- Lucas Gass (7)
- Victor Grousset (1)
- Amit Gupta (1)
- Kyle M Hall (16)
- Stina Hallin (1)
- Sally Healey (7)
- Ron Houk (7)
- Barbara Johnson (8)
- Joonas Kylmälä (8)
- Owen Leonard (11)
- Julian Maurice (2)
- Kelly McElligott (2)
- Telishia Mickens (1)
- David Nind (25)
- Andrew Nugged (1)
- Séverine Queune (1)
- Martin Renvoize (38)
- Phil Ringnalda (1)
- Marcel de Rooy (21)
- Fridolin Somers (169)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/Koha-community/Koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 févr. 2021 13:52:12.
