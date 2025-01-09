# RELEASE NOTES FOR KOHA 23.11.11
09 Jan 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 23.11.11 can be downloaded from:

- [Download](https://download.koha-community.org/koha-23.11.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.11 is a bugfix/maintenance release.

It includes 3 enhancements, 141 bugfixes and 3 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [37727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37727) CVE-2024-24337 - Fix CSV formula injection - client side (DataTables)
- [38468](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38468) Staff interface detail page vulnerable to reflected XSS
- [38470](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38470) Subscription detail page vulnerable to reflected XSS

## Bugfixes

### About

#### Other bugs fixed

- [37575](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37575) Typo 'AutoCreateAuthorites' in about.pl
- [38517](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38517) Release team 25.05

### Acquisitions

#### Critical bugs fixed

- [38437](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38437) Modal does not appear on single order receive

#### Other bugs fixed

- [34159](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34159) Remove plan by AR_CANCELLATION choice in aqplan

  **Sponsored by** *Chetco Community Public Library*
- [35087](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35087) Discount rate should only allow valid input formats
  >This fixes the vendor discount field so that it now only accepts values that will save correctly:
  >- a decimal number in the format 0.0 (if a comma is entered, you are now prompted to enter a decimal point)
  >- numbers with up to two digits before the decimal and up to three digits after the decimal, for example: 9, 99, -99, 99.9, 0.99, 99.99, 99.999
- [35823](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35823) When uploading a MARC file to a basket it is showing inactive funds without them being selected
- [36049](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36049) Rounding prices sometimes leads to incorrect results
  >This fixes the values and totals shown for orders when rounding prices using the OrderPriceRounding system preference. Example: vendor price for an item is 18.90 and the discount is 5%, the total would show as 17.95 instead of 17.96.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [37184](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37184) Special character encoding problem when importing MARC file from the acquisitions module
- [37265](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37265) Consideration of UniqueItemFields setting when receiving items in an order
  >This fixes receiving orders so that values added to fields selected in the UniqueItemFields system preference are treated as unique when receiving items. 
  >
  >Example of incorrect behavour that is fixed:
  >- For the UniqueItemFields system preference, the Public note (itemnotes) is set as unique.
  >- Multiple quantities of the same item are ordered.
  >- When receiving the order, a note is added to the public note for the first copy of item received.
  >- For the second copy of the item received, the public note from the first item was incorrectly added.

  **Sponsored by** *kohawbibliotece.pl*
- [37304](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37304) Created by filter in acquisitions advanced orders search always shows zero results
- [37854](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37854) Barcode fails when adding item during order receive (again)
- [38271](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38271) Missing 008 field in bibliographic records created via EDIFACT
- [38297](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38297) The "New vendor" button needs a permissions guard
- [38303](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38303) Item's replacement price not set to defaultreplacecost if 0.00
- [38329](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38329) Remove orphan confirm_deletion() in supplier.tt

  **Sponsored by** *Chetco Community Public Library*

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [38035](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38035) "sound" listed as an installed language

#### Other bugs fixed

- [33188](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33188) Warning in Koha::Items->hidden_in_opac
- [36317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36317) Koha::Biblio->host_items fails with search_ordered()
- [36873](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36873) Koha::Objects->delete should accept parameters and pass them through
- [36901](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36901) Add logging for uncaught exceptions in background job classes
  >This fixes the logging of uncaught exceptions in background jobs. Some rare situations like DB connection drops can make jobs get marked as failure, but no information about the reasons was logged anywhere.
- [37628](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37628) Remove get_opac_news_by_id
- [38000](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38000) Redundant code import in search.pl
- [38027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38027) Clearing a flatpickr datetime causes errors
- [38234](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38234) Remove unused vulnerable jszip library file
- [38274](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38274) Typo in Arabic language description
  >This fixes the language description for Arabic (displayed in OPAC and the staff interface advanced search) - from "Arabic (لعربية)" to "Arabic (العربية)".

### Authentication

#### Critical bugs fixed

- [36822](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36822) When creating a new patron via LDAP or Shibboleth 0000-00-00 is inserted for invalid updated_on

### Cataloging

#### Critical bugs fixed

- [35125](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35125) AutoCreateAuthorities creates separate authorities when thesaurus differs, even with LinkerConsiderThesaurus set to Don't
- [37964](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37964) Only show host items when system preference EasyAnalyticalRecords is enabled

#### Other bugs fixed

- [26929](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26929) Koha will only display the first 20 macros Advanced Editor

  **Sponsored by** *Chetco Community Public Library*
- [27769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27769) Advanced editor shouldn't break copying selected text with Ctrl+C
  >This fixes a shortcut key clash introduced by bug 17179 - Advanced editor: Add keyboard shortcuts to repeat (duplicate) a field, and cut text. It updates the default Ctrl+C shortcut for 'Copy line' to 'Ctrl+Alt+C' so that it doesn't clash with the system copy shortcut.
  >
  >This is only fixed for new installs, so if you are experiencing this issue with an existing Koha installation, you may wish to manually apply the new mapping.
- [36375](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36375) Inconsistencies in ContentWarningField display
- [36821](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36821) Authority type text for librarians and OPAC limited to 100 characters
- [36976](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36976) Warning 'Argument "" isn't numeric in numeric' in log when merging bibliographic records

  **Sponsored by** *Ignatianum University in Cracow*
- [37293](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37293) MARC bibliographic framework text for librarians and OPAC limited to 100 characters
  >This fixes the staff and OPAC description fields for the MARC bibliographic framework forms - it increases the number of characters that can be entered to 255. Previously, the tag description fields were limited to 100 characters and the subfield description fields to 80 characters, even though the database allows up to 255 characters.

  **Sponsored by** *Chetco Community Public Library*
- [37403](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37403) Wrong progress quantity in job details when staging records with match check
- [37871](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37871) Remove extraneous 246 subfields from the title mappings (Elasticsearch, MARC21)
  >This patch limits indexing of field 246 to $a, $b, $n, and $p in various title indexes.
  >Previously, all 246 subfields were indexed, including non-title subfields such as $i (Display text), $g (Miscellaneous information), and linking subfields, making the title index very large and giving false results, especially when looking for duplicates in cataloging.
- [38158](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38158) Typo in inventory 'Items has no "not for loan" status'

### Circulation

#### Critical bugs fixed

- [35709](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35709) [23.11] Renew selected items button is inactive when overdue items are preselected automatically

#### Other bugs fixed

- [37076](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37076) Incorrect needsconfirmation code RESERVED_WAITING
  >This fixes an incorrect value used in the OPAC self-checkout code (this new feature was added to Koha 23.11 by Bug 30979 - Add ability for OPAC users to checkout to themselves). 
  >
  >Because of the incorrect value in the code (RESERVED_WAITING instead of RESERVE_WAITING - the 'D' is incorrect), patrons could self check out an item on hold for another patron, instead of getting an error message "This item appears to be on hold for another patron, please return it to the desk".
- [37271](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37271) Recall status should be 'requested' in overdue_recalls.pl

  **Sponsored by** *Ignatianum University in Cracow*
- [37444](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37444) Can't filter holds to pull by pickup location
- [37505](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37505) Statistical patrons don't display information about item status if item wasn't checked out
- [37836](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37836) Prevent submitting empty barcodes in self check-in
- [37983](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37983) "Search a patron" box no longer has auto focus
- [38097](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38097) Add class to "Item was not checked out" message in checkin table
- [38117](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38117) "Item was not checked in" should not always show

### Command-line Utilities

#### Critical bugs fixed

- [37075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37075) Message queue processor will fail to send any message unless letter_code is passed

#### Other bugs fixed

- [14565](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14565) koha-run-backups does not backup an instance called demo
  >This removes a hard-coded exclusion for backups of instances named "demo".
- [18273](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18273) bulkmarcimport.pl inserts authority duplicates
  >This fixes the misc/migration_tools/bulkmarcimport.pl script when importing authority records so that the "--match" option works as expected, and no duplicates are created. Previously, this option was not working for authority records and duplicate records were being created even when there was a match.
- [37038](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37038) koha-elasticsearch creates a file named 0
- [37709](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37709) bulkmarcimport.pl should die when the file cannot be opened
- [37787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37787) Undocument koha-worker --queue elastic_index
  >This fixes the documentation for the koha-worker script. It removes the elastic_index queue from the script, as this is now handled by koha-es-indexer (added by bug 33108 to Koha 23.05.00 and backported to 22.11.06).
- [38173](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38173) Fix description of koha-dump --exclude-indexes
- [38237](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38237) Add logging to erm_run_harvester cronjob
- [38249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38249) `koha-list` help typo about elastic

### Database

#### Other bugs fixed

- [38522](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38522) Increase length of erm_argreements.license_info
  >This fixes the ERM agreements license information field (ERM > Agreements) so that more than 80 characters can be entered. It is now a medium text field, which allows entering up to 16,777,215 characters.

### ERM

#### Other bugs fixed

- [34920](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34920) ERM breaks if an ERM authorized value is missing a description
- [37277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37277) Identifiers need a space between the ISBN (Print) and ISBN (Online) in ERM
  >This fixes the display of identifiers for local titles so that are on separate lines, instead of joined together on the same line.
- [38177](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38177) ERM - HoldingsIQ pagination does not work

### Fines and fees

#### Other bugs fixed

- [34585](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34585) "When to charge" columns value not copied when editing circulation rule

  **Sponsored by** *Koha-Suomi Oy*

### Hold requests

#### Other bugs fixed

- [35771](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35771) Unselecting titles when making multi-hold does not have any effect
  >This fixes placing multiple holds for a patron from search results in the staff interface:
  >- The place holds page has checkboxes for unselecting some of the listed items - unselecting an item did not work and holds were placed on all items where a hold could be placed.
  >- Unselected items without a pickup location generated a 500 error.
- [36970](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36970) (Bug 34160 follow-up) Barcode should be html filtered, not uri filtered in holds queue view
  >This fixes the display of barcodes with spaces in the holds queue. Barcodes are now displayed correctly with a space, rather than with '%20'.

### Holidays

#### Critical bugs fixed

- [38357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38357) When adding new holidays Koha sometimes copies same holidays to other librarys

### I18N/L10N

#### Critical bugs fixed

- [36171](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36171) Extraction of Template Toolkit directive as translatable string causes patron view error in several languages
  >This fixes the extraction of strings that were causing translation errors. Template Tookit tags that contained HTML tags were split and treated as text that could be translated, instead of a Template Toolkit tag.

#### Other bugs fixed

- [35769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35769) Untranslatable strings when placing holds in staff
  >This fixes some strings that were not made available for translating for holds in the staff interface.
- [37257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37257) Copy in OPAC datatable untranslatable

  **Sponsored by** *Athens County Public Libraries*
- [37814](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37814) Wrong use of '__()' in .tt files

  **Sponsored by** *Athens County Public Libraries*
- [38138](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38138) Main contact method in hold pop-up untranslatable

### ILL

#### Other bugs fixed

- [37178](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37178) Column "comments" in ILL requests table gives error on sorting, paging cannot be changed

### Label/patron card printing

#### Other bugs fixed

- [37863](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37863) Patron card batches don't detect when the patron is already in the list

### MARC Bibliographic data support

#### Other bugs fixed

- [28075](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28075) Add missing UNIMARC value for coded data 135a
  >This updates the UNIMARC 135$a subfield to add missing values.
- [34346](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34346) Adding duplicate tag to a framework should give user readable message
- [37357](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37357) Authorised values in control fields cause Javascript errors

### Notices

#### Other bugs fixed

- [32575](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32575) gather_print_notices.pl sends attachment as body of email or poorly named txt file
  >This fixes emails generated by the misc/cronjobs/gather_print_notices.pl script. It adds empty text to the body of the email, so that the HTML file with the print notices is correctly attached to the email, and can be correctly printed. Because of the way the notices were being sent, and the way that different email clients handle different types of attachments, the notices were sometimes inserted into the body of the email or attached as poorly named text files.
- [37642](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37642) Generated letter should use https in header
  >This updates http links to W3C standards used in notice headers to https links.
- [37891](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37891) Editing a notice's name having SMSSendDriver disabled causes notice to be listed twice

### OPAC

#### Other bugs fixed

- [22223](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22223) Item url double-encode when parameter is an encoded URL
- [24690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24690) Make OPACPopupAuthorsSearch work with search terms containing parenthesis
  >This fixes the OPAC so that when OPACPopupAuthorsSearch is enabled, author names not linked to an authority record that have parenthesis (for example, Criterion Collection (Firm)) correctly return results. Previously, author names with parenthesis did not return search results.

  **Sponsored by** *Athens County Public Libraries*
- [35126](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35126) Remove the use of event attributes from when adding records to lists in the OPAC
- [36950](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36950) Improve placement of catalog concern banner in the OPAC
- [37057](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37057) OPACShowUnusedAuthorities displays unused authorities regardless
  >This fixes authority searching in the OPAC. Using the OPACShowUnusedAuthorities system preference now works as expected when using Zebra and Elasticsearch search engines:
  >- if set to "Show", unused authorities are shown in the search results
  >- if set to "Don't show", unused authorities are not shown in the search results.
  >A regression was causing unused authorities to show in the search results when the system preference was set to "Don't show".
- [37158](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37158) OPAC recalls history table not responsive

  **Sponsored by** *Athens County Public Libraries*
- [37629](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37629) Link to news are broken
- [37679](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37679) Dublin Core export option broken
- [37684](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37684) Direct links to expired news are broken
- [38100](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38100) Items with damaged status are shown in OPAC results as "Not available" even with AllowHoldsOnDamagedItems
- [38132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38132) Add data-isbn to shelfbrowser images
- [38362](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38362) Printing lists only prints the ten first results in the OPAC
  >This fixes printing lists in the OPAC so that all the items are printed, instead of only the first 10.

### Patrons

#### Critical bugs fixed

- [37892](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37892) Patron category 'can be a guarantee' means that same category cannot be a guarantor

#### Other bugs fixed

- [30397](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30397) Duplicate '20' option in dropdown 'Show entries' menu
  >This fixes the options for the number of entries to show for patron search results in the staff interface - 20 was listed twice.
- [34610](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34610) ProtectSuperlibrarianPrivileges, not ProtectSuperlibrarian
  >This fixes the hover message when attempting to grant the `superlibrarian` permission (Access to all librarian functions) to a patron. It changes the message to use the correct system preference name "The system preference ProtectSuperlibrarianPrivileges is enabled", instead of "..ProtectSuperlibrarian...". 
  >
  >(The message appears over the tick box next to the permission name if the patron attempting to set the permissions is not a super librarian, and the ProtectSuperlibrarianPrivileges is set to "Allow only superlibrarians" - only super librarians can give other staff patrons superlibrarian access.)
- [37365](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37365) Bad redirect when adding a patron message from members/files.pl
  >This fixes a redirect when adding a patron message straight after uploading a patron file (when EnableBorrowerFiles is enabled). Before this fix, an error message "Patron not found. Return to search" was displayed if you added a message straight after you finished uploading a file (the "Add message" option on other pages worked as expected).
- [37528](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37528) Using borrowerRelationship while guarantor relationship is unchecked from BorrowerMandatoryField results in error

  **Sponsored by** *Koha-Suomi Oy*
- [38005](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38005) 500 error on self registration when patron attribute is set as mandatory
- [38109](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38109) Patron category types are not sorted when entering/editing patrons
- [38188](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38188) Fix populating borrowernumberslist from patron_search_selections

  **Sponsored by** *Koha-Suomi Oy*

### REST API

#### Other bugs fixed

- [37032](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37032) REST API: Unable to call item info via holds endpoint

  **Sponsored by** *Koha-Suomi Oy*
- [37535](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37535) Adding a debit via API will show the patron as the librarian that caused the debit
- [37687](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37687) API query operators list doesn't match documentation
  >This restores "-not_in" so that it is now listed as a valid operator for filtering API responses.

### Reports

#### Other bugs fixed

- [37108](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37108) Cash register statistics wizard is wrongly sorting payment by home library of the manager

### SIP2

#### Other bugs fixed

- [23426](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23426) Empty AV field returned in 'patron info' in addition to those requested
  >This fixes SIP2 responses to remove the empty AV field in patron information responses, when fine information is requested. It also:
  >- adds the active currency as part of the response (BH)
  >- fixes the number of items in the response which are specified in BP and BQ, when other items as fine items are requested.
- [37582](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37582) SIP2 responses can contain newlines when a patron has multiple debarments
- [38284](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38284) handle_patron_status dies if patron not found
  >This fixes patron status SIP2 request responses if the request has an invalid or empty card number or PIN, and options are set for the TrackLastPatronActivityTriggers system preference. The SIP request was silently dying.

  **Sponsored by** *PTFS Europe*

### Searching

#### Other bugs fixed

- [37167](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37167) Fix mapping call number searches to Z39.50
  >This fixes how the Z39.50 search form is populated when using the Z39.50/SRU search option, from advanced search results in the staff interface where a "Call number" search is made. It now autofills the searched for value in the "Dewey" field instead of the "Title" field. 
  >
  >(Even though the field is labelled "Dewey", it also searches for Library of Congress call numbers in the 050 tag. Note that there are other issues with the search form, the labels used, and what is actually searched for - there are separate bugs for these).
- [37244](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37244) Selecting home library or holding library facet changes library dropdown
- [37249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37249) Item search column filtering broken
- [37333](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37333) Search filters using OR are not correctly grouped
- [37369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37369) Item search column filtering can't use descriptions

  **Sponsored by** *Koha-Suomi Oy*
- [37801](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37801) Search results with limits create URLs that cause XML errors in RSS2 output

  **Sponsored by** *Chetco Community Public Library*
- [37998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37998) Tabs and backslashes in the data break item search display

  **Sponsored by** *Ignatianum University in Cracow*

### Searching - Elasticsearch

#### Other bugs fixed

- [33348](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33348) Show authority heading use with Elasticsearch
  >This fixes the ShowHeadingUse system preference so that it now works with Elasticsearch. When enabled, this option adds a new column to authority search results in the staff interface - it lists what the heading can be used for (based on the values in the MARC entry for 008/14-16), for example:
  >  ✔ Main/Added Entry
  >  ✔ Subject
  >  x Series Title
  >
  >(This feature was originally added to Koha 22.05.00 by bug 29990, but only worked with the Zebra search engine.)

  **Sponsored by** *Education Services Australia SCIS*

### Self checkout

#### Other bugs fixed

- [37027](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37027) Some dataTable controls in SCO seem unnecessary

### Serials

#### Other bugs fixed

- [29818](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29818) Cannot save subscription frequency without display order

  **Sponsored by** *Chetco Community Public Library*

### Staff interface

#### Other bugs fixed

- [37233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37233) Library URL broken in the libraries table
  >This fixes the URL link for a library in the staff interface (Administration > Basic parameters > Libraries) so that it works as expected. The link was not correctly formatted and it generated a 404 page not found error.
- [37954](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37954) Unable to hide barcode column in holdings table
  >This fixes hiding the barcode column on the staff interface for a record's holdings table. You can now turn on or off hiding the barcode by default, and select the display of the barcode column using the 'Columns' setting.

### System Administration

#### Other bugs fixed

- [35257](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35257) Only admin start page uses "circulation desks"
  >This changes the Koha administration page title for "Circulation desks" to "Desks" for consistency - all other areas such as the sidebar, page titles, and breadcrumbs all use just "Desks". It also updates the UseCirculationDesks system preference description.
- [37229](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37229) Table configuration listings for course reserves incorrect

  **Sponsored by** *Athens County Public Libraries*
- [37404](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37404) Typo in intranetreadinghistory description
- [37606](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37606) Framework export module should escape double quotes

### Templates

#### Other bugs fixed

- [35232](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35232) Misspelled ID breaks label on patron lists form
- [35238](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35238) Incorrect label markup in patron card creator printer profile edit form
  >This fixes an accessibility issue in the HTML markup for the patron card creator printer profile edit form.
- [35239](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35239) Missing form field ids in batch patron modification template
  >This fixes the batch patron modification edit form labels so that they all have IDs, and the input box now receive the focus when clicking on the label (this includes patron attribute fields, but excludes date fields). This is an accessibility improvement. Before this, you had to click in the input box to add a value.

  **Sponsored by** *Athens County Public Libraries*
- [37231](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37231) (Bug 34940 follow-up) Highlight logged-in library in facets does not work with ES

  **Sponsored by** *Ignatianum University in Cracow*
- [37242](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37242) Don't use the term branch in cash register administration
- [37595](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37595) Double HTML escaped ampersand in pagination bar
- [37848](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37848) "Run with template" options need formatting

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Other bugs fixed

- [36919](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36919) t/db_dependent/Koha/Object.t produces warnings
- [36936](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36936) api/v1/bookings.t generates warnings
- [36944](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36944) Auth.t should not fail when AutoLocation is enabled
- [37289](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37289) t/db_dependent/api/v1/authorised_values.t is failing under specific circumstances
- [37490](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37490) Add test to detect when yarn.lock is not updated
- [37963](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37963) Improve error handling and testing of ERM eUsage SUSHI
- [38322](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38322) Wrong comment in t/db_dependent/api/v1/erm_users.t
  >This fixes ERM user tests in t/db_dependent/api/v1/erm_users.t. It was not correctly testing the permissions for listing users. It was supposed to check that two users were returned, but only one was returned.
- [38526](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38526) Auth_with_* tests fail randomly

### Tools

#### Other bugs fixed

- [36132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36132) Allow users to delete multiple patron lists at once on any page
  >This fixes patron lists so that when there are more than 20 lists, the lists on the next pages can be deleted. Previously, you were only able to delete the lists on the first page.
- [37326](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37326) Batch modification should decode barcodes when using a barcode file
- [37730](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37730) Batch patron modification table horizontal scroll causes headers to mismatch
  >This fixes the table for the batch patron modification tool (Tools > Patrons and circulation > Batch patron modification). When you scrolled down the page so that table header rows are "sticky", and then scrolled to the right, the table header columns were fixed instead of changing to match the column contents.
- [37965](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37965) Fix regression of convert_urls setting in TinyMCE which causes unexpected URL rewriting
- [38266](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38266) Incorrect attribute disabled in patron batch modification

### Web services

#### Other bugs fixed

- [35442](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35442) Script migration_tools/build_oai_sets.pl is missing ORDER BY
- [38131](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38131) ILS-DI documentation still shows renewals instead of renewals_count

## Enhancements 

### Database

#### Enhancements

- [31143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31143) We should attempt to fix/identify all cases where '0000-00-00' may still remain in the database
  >This enhancement:
  >
  >1. Updates the misc/maintenance/search_for_data_inconsistencies.pl script so that it identifies any date fields that have 0000-00-00 values.
  >
  >2. Adds a new script misc/maintenance/fix_invalid_dates.pl that fixes any date fields that have '0000-00-00' values (for example: dateofbirth) by updating them to 'NULL'. 
  >
  >Patron, item, and other date fields with a value of '000-00-00' can cause errors. This includes:
  >- API errors
  >- stopping the patron autocomplete search working
  >- generating a 500 internal server error:
  >  . for normal patron searching
  >  . when displaying item data in the holdings table

### ERM

#### Enhancements

- [37856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37856) Some SUSHI providers require the platform parameter
  >This enhancement adds a new "platform" field to ERM's usage data providers, allowing the harvest of SUSHI usage data from providers that require this parameter.

### MARC Bibliographic data support

#### Enhancements

- [37114](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37114) Update MARC21 default framework to Update 38 (June 2024)
  >This enhancement updates the default MARC21 bibliographic framework for new installations to reflect the changes from Update 38 (June 2024).
  >
  >NOTES:
  >- For existing installations, manually updating the default and other frameworks with the changes is required.
  >- For new installations, only the default framework is updated. Manually updating other frameworks with the changes is required.

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Armenian (hy_ARMN)](https://koha-community.org/manual/23.11//html/) (58%)
- [Bulgarian (bg_CYRL)](https://koha-community.org/manual/23.11//html/) (98%)
- [Chinese (Traditional)](https://koha-community.org/manual/23.11/zh_Hant/html/) (92%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (55%)
- [German](https://koha-community.org/manual/23.11/de/html/) (69%)
- [Greek](https://koha-community.org/manual/23.11//html/) (78%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (72%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (99%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified) (89%)
- Chinese (Traditional) (91%)
- Czech (70%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (52%)
- Greek (60%)
- Hindi (99%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (98%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (87%)
- Russian (95%)
- Slovak (62%)
- Spanish (100%)
- Swedish (87%)
- Telugu (70%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (74%)
- hyw_ARMN (generated) (hyw_ARMN) (65%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 23.11.11 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Martin Renvoize

- QA Team:
  - Victor Grousset
  - Lisette Scheer
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Julian Maurice
  - Baptiste Wojtowski
  - Paul Derscheid
  - Aleisha Amohia
  - Laura Escamilla
  - Tomás Cohen Arazi
  - Kyle M Hall
  - Nick Clemens
  - Lucas Gass
  - Marcel de Rooy
  - Matt Blenkinsop
  - Pedro Amorim
  - Brendan Lawlor
  - Thomas Klausner

- Security Manager: Tomás Cohen Arazi

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers

- Bug Wranglers:
  - Michaela Sieber
  - Jacob O'Mara
  - Jake Deery

- Packaging Manager: Mason James

- Documentation Manager: Philip Orr

- Documentation Team:
  - Aude Charillon
  - David Nind
  - Caroline Cyr La Rose

- Wiki curators: 
  - George Williams
  - Thomas Dukleth
  - Jonathan Druart
  - Martin Renvoize

- Release Maintainers:
  - 24.11 -- Paul Derscheid
  - 24.05 -- Wainui Witika-Park
  - 23.11 -- Fridolin Somers
  - 22.11 -- Laura Escamilla

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.11.11
<div style="column-count: 2;">

- Athens County Public Libraries
- Chetco Community Public Library
- Education Services Australia SCIS
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [PTFS Europe](https://ptfs-europe.com)
- kohawbibliotece.pl
</div>

We thank the following individuals who contributed patches to Koha 23.11.11
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Pedro Amorim (32)
- Tomás Cohen Arazi (8)
- Noémie Ariste (1)
- Matt Blenkinsop (6)
- Kevin Carnes (1)
- Nick Clemens (19)
- David Cook (11)
- Paul Derscheid (2)
- Jonathan Druart (18)
- Michał Dudzik (1)
- Magnus Enger (3)
- Eugene Jose Espinoza (1)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (1)
- Eric Garcia (2)
- Lucas Gass (13)
- Didier Gautheron (1)
- Thibaud Guillot (1)
- Bo Gustavsson (1)
- Kyle M Hall (5)
- Andrew Fuerste Henry (3)
- Mason James (1)
- Andreas Jonsson (1)
- Janusz Kaczmarek (9)
- Jan Kissig (6)
- Emily Lamancusa (2)
- Brendan Lawlor (1)
- Owen Leonard (11)
- Julian Maurice (1)
- Matthias Meusburger (1)
- David Nind (1)
- Alexandre Noel (2)
- Katariina Pohto (1)
- Martin Renvoize (8)
- Phil Ringnalda (7)
- Adolfo Rodríguez (1)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (4)
- Johanna Räisä (2)
- Fridolin Somers (11)
- Catalyst Bug Squasher (1)
- Raphael Straub (2)
- Emmi Takkinen (3)
- Lari Taskula (2)
- Petro Vashchuk (1)
- George Veranis (1)
- Hinemoea Viault (1)
- wainuiwitikapark (3)
- Hammat Wele (2)
- Wainui Witika-Park (1)
- Baptiste Wojtkowski (6)
- Chloe Zermatten (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.11
<div style="column-count: 2;">

- Athens County Public Libraries (11)
- [BibLibre](https://www.biblibre.com) (19)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- [ByWater Solutions](https://bywatersolutions.com) (40)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (6)
- Catalyst Open Source Academy (3)
- Chetco Community Public Library (7)
- [Dataly Tech](https://dataly.gr) (1)
- David Nind (1)
- Dubuque County Library District (1)
- gustavsson.one (1)
- [Hypernova Oy](https://www.hypernova.fi) (2)
- Independant Individuals (15)
- Karlsruhe Institute of Technology (KIT) (2)
- Koha Community Developers (18)
- [Koha-Suomi Oy](https://koha-suomi.fi) (4)
- KohaAloha (1)
- kohawbibliotece.pl (1)
- Kreablo AB (1)
- laposte.net (2)
- [Libriotech](https://libriotech.no) (3)
- [LMSCloud](lmscloud.de) (2)
- Lund University Library, Sweden (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (2)
- [Prosentient Systems](https://www.prosentient.com.au) (11)
- [PTFS Europe](https://ptfs-europe.com) (47)
- Rijksmuseum, Netherlands (6)
- [Solutions inLibro inc](https://inlibro.com) (9)
- [Theke Solutions](https://theke.io) (8)
- Wildau University of Technology (6)
- [Xercode](https://xebook.es) (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (5)
- Pedro Amorim (8)
- Tomás Cohen Arazi (7)
- Baptiste (1)
- Sukhmandeep Benipal (5)
- Matt Blenkinsop (3)
- Sonia Bouis (2)
- Nick Clemens (13)
- David Cook (3)
- Chris Cormack (9)
- Jake Deery (1)
- Paul Derscheid (15)
- Roman Dolny (14)
- Jonathan Druart (13)
- Magnus Enger (3)
- Laura Escamilla (4)
- Katrin Fischer (198)
- Eric Garcia (1)
- Lucas Gass (228)
- Victor Grousset (6)
- Kyle M Hall (2)
- Olivier Hubert (1)
- Thomas Klausner (3)
- Kristi Krueger (1)
- Emily Lamancusa (9)
- Sam Lau (2)
- Laura_Escamilla (1)
- Brendan Lawlor (9)
- Owen Leonard (12)
- Lucas (1)
- Julian Maurice (4)
- Kelly McElligott (1)
- David Nind (62)
- Eric Phetteplace (1)
- Hannah Prince (1)
- Martin Renvoize (67)
- Riomar Resurreccion (1)
- Phil Ringnalda (15)
- Jason Robb (1)
- Marcel de Rooy (21)
- Caroline Cyr La Rose (4)
- Michaela Sieber (1)
- Fridolin Somers (222)
- Sam Sowanick (3)
- Michelle Spinney (2)
- Emmi Takkinen (3)
- Olivier V (12)
- wainuiwitikapark (9)
- Shi Yao Wang (4)
- Baptiste Wojtkowski (6)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 09 Jan 2025 09:13:32.
