# RELEASE NOTES FOR KOHA 20.05.09
23 Feb 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.09 is a bugfix/maintenance release with security fixes.

It includes 2 security fixes, 1 new features, 13 enhancements, 63 bugfixes.

### System requirements

You can learn about the system components (like OS and database) for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations

## Security bugs

### Koha

- [[27604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27604) PatronSelfRegistrationLibraryList can be bypassed
- [[27715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27715) Possibly SQL injection in virtualshelves

## New features

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

- [[27646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27646) Allow export of acquisitions home and funds table

### Architecture, internals, and plumbing

- [[24254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24254) Add Koha::Items->filter_by_visible_in_opac

  >This patch introduces an efficient way of filtering Koha::Items result sets, to hide items that that shouldn't be exposed on public interfaces.
  >
  >Filtering is governed by the following system preferences. A helper method is added to handle lost items:
  >- hidelostitems: Koha::Items->filter_out_lost is added to handle this.
  >
  >Some patrons have exceptions so OpacHiddenItems is not enforced on them. That's why the new method [1] has an optional parameter that expects the logged in patron to be passed in the call.
  >
  >[1] Koha::Items->filter_by_visible_in_opac

### Cataloging

- [[26943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26943) Show not for loan descriptions in cataloging search (addbooks.pl)

  >Adds the ability to see not for loan descriptions in the cataloging search results.
- [[27422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27422) HTML5Media is http by default but Youtube is https only

  **Sponsored by** *Banco Central de la República Argentina*

### Circulation

- [[27306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27306) Add subtitle to return claims table

### Command-line Utilities

- [[24272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24272) Add a command line script to compare the syspref cache to the database

  >This script checks the value of the system preferences in the database against those in the cache. Generally differences will only exist if changes have been made directly to the DB or the cache has become corrupted.

### OPAC

- [[27029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27029) Detail page missing Javascript accessible biblionumber value

### Reports

- [[26713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26713) Add pagination to bottom of saved SQL reports table

  >This enhancement adds a second pagination menu to the bottom of saved SQL reports tables.

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
- [[27192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27192) Set focus for cursor to item type input box when creating new item types
- [[27210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27210) Typo in patron-attr-types.tt


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[27580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27580) NULL values not correctly handled in Koha::Items->filter_by_visible_in_opac
- [[27586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27586) Import patrons script has a confirm switch that doesn't do anything

  >This fixes the misc/import_patrons.pl script so that patrons are not imported unless the --confirm option is used. Currently, if the script is run without "--confirm" option it reports that it is "Running in dry-run mode, provide --confirm to apply the changes", however it imports the patrons anyway.
- [[27676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27676) finesMode=off not correctly handled

### Circulation

- [[27707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27707) Renewing doesn't work when renewal notices are enabled

### Hold requests

- [[26634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26634) Hold rules applied incorrectly when All Libraries rules are more specific than branch rules
- [[27068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27068) HoldsQueue doesn't know how to use holds groups

  >Koha 20.05 introduced local hold groups, but neglected to add support of them in the holds queue. Because of this, the holds queue will not show items the could have filled holds from other libraries in a hold group. This patch set adds support for hold groups to the holds queue builder thus improving Koha's ability to find items to fill hold requests.

### OPAC

- [[15448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15448) Placing hold on specific items doesn't enforce OpacHiddenItems

### System Administration

- [[27569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27569) marc-framework import function doesn't accept LibreOffice csv/ods file formats


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[23767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23767) Spent and Ordered total values don't include child funds on acqui-home
- [[24469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24469) Record biblionumber in import_biblio when adding to basket via file
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

- [[27308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27308) Advanced editor should skip blank lines when inserting new fields

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
- [[17429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17429) Document the --plack option for koha-list

### Fines and fees

- [[20527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20527) <label> linked to the wrong <input> (wrong "for" attribute) in paycollect.tt

  >This fixes the HTML <label for=""> element for the Writeoff amount field on the Accounting > Make a payment form for a patron - changes "paid" to "amountwrittenoff".

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

- [[27297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27297) When itemtype is marked as required in OpacSuggestion MandatoryFields the field is not required
- [[27450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27450) Making password required for patron registration breaks patron modification
- [[27571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27571) "Add to lists" on MARC and ISBD view of OPAC detail page doesn't open in new window

### Patrons

- [[26059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26059) Create guarantor/guarantee links on patron import
- [[27454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27454) Additional patron attributes change sequence on every reload of edit page

  >This fixes the order that additional patron attributes are displayed on the patron edit form. They are now sorted by the attribute code, before this they displayed in a random order.

### REST API

- [[26181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26181) Holds placed via the REST API should not be forced by default even if AllowHoldPolicyOverride is enabled

  >This patch disables AllowHoldPolicyOverride by default in the /holds REST API. It also adds tests for this behaviour, and adds a header that can be used to request the override explicitly.

### SIP2

- [[25808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25808) Renewal via the SIP 'checkout' message gives incorrect message
- [[27204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27204) SIP patron information request with fee line items returns incorrect data

### Searching

- [[26957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26957) Find duplicate removes operators from the middle of search terms

### Searching - Elasticsearch

- [[27307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27307) "Keyword as phrase" option in search dropdown doesn't work with Elastic

### Searching - Zebra

- [[27299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27299) Zebra phrase register is incorrectly tokenized when using ICU

  >Previously, Zebra indexing in ICU mode was incorrectly tokenizing text for the "p" register. This meant that particular phrase searches were not working as expected. With this change, phrase searching works the same in ICU and CHR modes.

### Staff Client

- [[27653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27653) Do not include 'caption' row in print/copy export of datatables

### Templates

- [[20238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20238) Show description of ITEMTYPECAT instead of code in itemtypes summary table

  >This enhancement changes the item types page (Koha administration > Basic parameters > Item types) so that the search category column displays the ITEMTYPECAT authorized value's description, instead of the authorized value code. (This makes it consistent with the edit form where it displays the descriptions for authorized values.)
- [[24055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24055) Description of PayPalReturnURL system preference is unclear

  >This enhancement improves the description of the PayPalReturnURL. Changed from 'configured return' to 'configured return URL' as this is what it is called on the PayPal website.
- [[26602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26602) Datatables - Actions columns should not be exported
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

- Arabic (98.9%)
- Armenian (99.9%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.3%)
- Czech (80.8%)
- English (New Zealand) (66.7%)
- English (USA)
- Finnish (70.6%)
- French (81.9%)
- French (Canada) (97.4%)
- German (100%)
- German (Switzerland) (74.5%)
- Greek (62.1%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (71.1%)
- Polish (73.5%)
- Portuguese (86.9%)
- Portuguese (Brazil) (98%)
- Russian (86.7%)
- Slovak (89.8%)
- Spanish (99.9%)
- Swedish (79.7%)
- Telugu (89.6%)
- Turkish (100%)
- Ukrainian (66.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.09 is


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
We thank the following libraries who are known to have sponsored
new features in Koha 20.05.09:

- Banco Central de la República Argentina
- [Collecto](https://collecto.ca)

We thank the following individuals who contributed patches to Koha 20.05.09.

- Ethan Amohia (1)
- Tomás Cohen Arazi (17)
- Eden Bacani (3)
- Philippe Blouin (1)
- Nick Clemens (17)
- David Cook (2)
- Jonathan Druart (40)
- Katrin Fischer (3)
- Andrew Fuerste-Henry (5)
- Lucas Gass (2)
- Didier Gautheron (1)
- Kyle M Hall (14)
- Mazen Khallaf (2)
- Amy King (3)
- Bernardo González Kriegel (1)
- Joonas Kylmälä (1)
- Owen Leonard (9)
- Ava Li (3)
- Catherine Ma (1)
- Agustín Moyano (1)
- James O'Keeffe (1)
- Martin Renvoize (5)
- Marcel de Rooy (3)
- Caroline Cyr La Rose (1)
- Andreas Roussos (2)
- Fridolin Somers (2)
- Koha Translators (1)
- Petro Vashchuk (5)
- Ella Wipatene (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.09

- Athens County Public Libraries (9)
- BibLibre (3)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (38)
- Dataly Tech (2)
- gamil.com (2)
- Independant Individuals (19)
- Koha Community Developers (40)
- Prosentient Systems (2)
- PTFS-Europe (5)
- Rijks Museum (3)
- Solutions inLibro inc (2)
- Theke Solutions (18)
- Universidad Nacional de Córdoba (1)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Mark Hofstetter <mark@hofstetter.at> (1)
- Eden Bacani (1)
- Nick Clemens (15)
- David Cook (1)
- Sarah Daviau (1)
- Michal Denar (1)
- Jonathan Druart (92)
- Katrin Fischer (56)
- Martha Fuerst (1)
- Andrew Fuerste-Henry (149)
- Marti Fyerst (3)
- Lucas Gass (6)
- Victor Grousset (4)
- Amit Gupta (1)
- Kyle M Hall (18)
- Sally Healey (2)
- Ron Houk (7)
- Barbara Johnson (10)
- Mazen Khallaf (1)
- Joonas Kylmälä (7)
- Owen Leonard (6)
- Julian Maurice (1)
- Kelly McElligott (2)
- Telishia Mickens (1)
- Josef Moravec (1)
- David Nind (15)
- Andrew Nugged (1)
- Séverine Queune (1)
- Martin Renvoize (44)
- Phil Ringnalda (1)
- Marcel de Rooy (14)
- Fridolin Somers (136)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain2005.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Feb 2021 20:26:24.
