# RELEASE NOTES FOR KOHA 25.05.13
05 Aug 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.05.13 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.05.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.05.13 is a bugfix/maintenance and security release.

It includes 37 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [30233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30233) Remote code execution in user-supplied regex
  >This change refactors the regular expression handling for Batch Item Modification, MARC Modification templates, and Callnumber splitting. It moves from Perl's traditional compile-time regular expression handling to a more dynamic (but restrictive) run-time regular expression handling more similar to Python's "sub" regex method. This functions to reduce vulnerabilities to code injection into Koha's Perl backend.
- [42471](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42471) /cgi-bin/koha/suggestion/suggestion.pl Multiple Parameters Stored Cross-Site Scripting
- [42746](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42746) Stored SQL injection via unvalidated 'agefield' in automatic_item_modification_by_age (C4::Items::ToggleNewStatus)
- [42747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42747) Stored SQL injection via patroncard layout image_name (patroncards/edit-layout.pl -> create-pdf.pl)
- [42749](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42749) SQL injection in acqui/parcels.pl via the orderby parameter (ORDER BY direction) reaching C4::Acquisition::GetInvoices
- [42847](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42847) SIP authentication ignored after initial successful connection
- [42866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42866) SQL Injection in Koha/AdditionalContents.pm search_for_display via the patron lang value (stored / second-order, executed on issue-slip print, unvalidated string context, no placeholder)
- [43019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43019) OPAC pages limited to library are readable by unauthenticated users

## Bugfixes

### About

#### Other bugs fixed

- [41102](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41102) Error 500 on the "About" page when biblioserver Zebra configuration is missing
  >This fixes the About Koha page when Zebra is not running or not correctly configured in the Koha instance's koha-conf.xml file. Instead of a 500 error when you access the page, there is now a message in the server information tab for Zebra's status, such as "Zebra server seems not to be available. Is it started?".

### Accessibility

#### Other bugs fixed

- [42236](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42236) OPAC lists table header contains no text

### Acquisitions

#### Other bugs fixed

- [41999](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41999) Suggestions table in staff interface no longer searches all data following title in Suggestion column
  >This fixes the search filter for the suggestions tables in the staff interface. The search filter now searches all suggestion column data, not just the title.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [42317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42317) [CVE-2014-1626] Require MARC::File::XML > 1.0.2
  >This updates the CPAN file to reflect the minimum version
  >needed for the MARC::File::XML Perl module. This is important
  >because of the vulnerabilities in version 1.0.1.
  >
  >(Note: This should not cause any issues, as v1.0.5 is available and already used from Debian repositories for installation.)

### Cataloging

#### Other bugs fixed

- [42262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42262) MARC 006 tag editor plugin drops blank value in position 17 when editing existing tag

### Circulation

#### Other bugs fixed

- [21941](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21941) Incorrect GROUP BY in circ/reserveratios.pl

  **Sponsored by** *Lund University Library*
- [41510](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41510) Fallback on bookable itemtype can break if item has no itemtype
  >Catches the unlikely case of there not being an itemtype associated with item or bib for bookings.

### Command-line Utilities

#### Other bugs fixed

- [40744](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40744) Don't give noisy warning when PatronSelfRegistration is turned off
  >When PatronSelfRegistration is set to ignore (i.e. do nothing) if --del-exp-selfreg is passed to cleanup_database.pl we were issuing warnings.  This patch removes those.
- [41967](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41967) cleanup_database.pl ignores integer values for --labels and --cards and defaults to 1 day
  >This fixes a bug in the cleanup_database.pl script to delete label batches and patron card batches older than X days. Before this fix, if the --labels  or --cards argument was passed in the cronjob, all batches older than 1 day were deleted, regardless of the value passed in the argument.

### Fines and fees

#### Critical bugs fixed

- [41761](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41761) Updating accountlines note sets accountlines.date to current date

#### Other bugs fixed

- [41386](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41386) Adding 0.00 as value for "Expired hold charge" in circulation rules can lead to exception Koha::Exceptions::Account::AmountNotPositive
  >Using value 0.00 in "Expired hold charge" rule on circulation rules caused Koha to die with exception Koha::Exceptions::Account::AmountNotPositive when expired hold charge was added for patron. This was caused by error in if statement in method Koha::Hold->cancel which allowed value 0.00 to be passed to method add_debit. This method then raised exception since value 0.00 is not positive. This patch fixes the erroneous if statement in method Koha::Hold->cancel.

  **Sponsored by** *Koha-Suomi Oy*

### ILL

#### Other bugs fixed

- [41861](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41861) ILL request cost and price paid don't show if 0
  >This updates how an ILL request cost and price paid are shown - if the amount is $0, then it is now shown. Previously, the fields were not shown if the amount was $0.
  >
  >(Note: 'Cost' is not editable in the user interface, but the backend used may set the value. 'Price paid' is editable through the 'Edit request' action)

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [41337](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41337) koha-create --request-db and --populate-db creates log files owned by root (intranet-error.log, opac-error.log)
  >This fixes the UNIX user/group ownership of the log files `intranet-error.log` and `opac-error.log` inside `/var/log/koha/<instance>/`.
  >Previously, running `koha-create --request-db` followed by `koha-create --populate-db` would result in the two log files being owned by root/root.
  >The correct ownership is now applied, meaning the log files will be owned by the <instance>-koha/<instance>-koha UNIX user/group.

### OPAC

#### Critical bugs fixed

- [42545](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42545) Koha::Calendar::days_between skips holiday subtraction for end date if time is early

#### Other bugs fixed

- [40481](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40481) The items table on koha/opac-MARCdetail.pl does not honor OPACHiddenItems
  >This fixes the MARC view in the OPAC where an item should be hidden when OPACHiddenItems rules should apply. The item was hidden in the normal view, but not in the MARC view.
- [41690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41690) Add MARC21 245$b (subtitle) to Cite option
  >This fixes citations generated using the "Cite" option in the OPAC - subtitles are now included in the title where they exist for MARC21 (245$b).

### Patrons

#### Critical bugs fixed

- [41145](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41145) Logging patron attributes logs even if there's no changes
  >This prevents misleading patron attribute modification logs, when a library batch imports patrons with the BorrowersLog system preference set to 'Log'. It now correctly only shows a log entry when a patron attribute value is changed.
  >
  >Example: 
  >- Before the change: for an existing patron with a patron attribute of INSTID:1234, with a re-import the log shows { "attribute.INSTID" : { "after" : "1234", "before" : "" } }, even though there is no change to the patron attribute.
  >- After the change: 
  >  . No log entry is shown if there is no change to the patron attribute.
  >  . If there is a change to the patron attribute (for example, changed to 5678 on a re-import), it is now correctly shown - { "attribute.INSTID" : { "after" : "5678", "before" : "1234" } }

  **Sponsored by** *Auckland University of Technology*

#### Other bugs fixed

- [29768](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29768) hidepatronname hides guarantor name on borrower edit screen
  >If the `HidePatronName` system preference was set to "Don't show" it hid the guarantor's name when:
  >- editing the guarantee's patron record (it shows the guarantor patron's card number)
  >- viewing the guarantee patron's details page
  >
  >With this change, you can now see the guarantor's name in these areas.
  >
  >As this information is viewable by clicking the card number, it doesn't make much sense to hide the patron name for guarantors and guarantees.

  **Sponsored by** *Koha-Suomi Oy*

### Reports

#### Other bugs fixed

- [41292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41292) Add "force_password_reset_when_set_by_staff" to the allowed column name list
  >This adds the force_password_reset_when_set_by_staff field in the categories table to the list of allowed password-related fields that can be used in SQL reports.
  >
  >Currently, this field is treated as containing sensitive password-related data and generates an error when creating a report that uses it.

### Serials

#### Other bugs fixed

- [42277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42277) JS error when viewing a subscription

### System Administration

#### Other bugs fixed

- [28297](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28297) Can't save system preference and field not marked as modified when changing value
  >System preferences with a text input field can now be saved when they are changed back to the original value.

### Templates

#### Other bugs fixed

- [42154](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42154) Bug 38714 hid the "New match check" link in record matching rules

  **Sponsored by** *Athens County Public Libraries*
- [42438](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42438) Remove event attributes from icon selection include file

  **Sponsored by** *Athens County Public Libraries*
- [42439](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42439) Remove event attributes from label-edit-batch.tt

  **Sponsored by** *Athens County Public Libraries*
- [42441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42441) Remove event attributes from authority merge template

  **Sponsored by** *Athens County Public Libraries*
- [42442](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42442) Remove event attributes from bibliographic record merge template

  **Sponsored by** *Athens County Public Libraries*
- [42475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42475) Terminology: OPAC is an abbreviation
  >Changes opac to OPAC for these system preference descriptions:
  >- NovelistSelectProfile
  >- item-level_itypes
  >- OpacSuppressionByIPRange

### Test Suite

#### Other bugs fixed

- [42359](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42359) t/db_dependent/Reports/Guided.t fails when ReportsLog is enabled
- [42578](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42578) Koha/Hold.t failing on date comparison

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.05/en/html/)
- [French](https://koha-community.org/manual/25.05/fr/html/) (80%)
- [German](https://koha-community.org/manual/25.05/de/html/) (85%)
- [Greek](https://koha-community.org/manual/25.05/el/html/) (91%)
- [Hindi](https://koha-community.org/manual/25.05/hi/html/) (61%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (92%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (64%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (83%)
- Chinese (Traditional Han script) (97%)
- Czech (67%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (61%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (66%)
- Hindi (94%)
- Italian (82%)
- Khmer (Central) (57%)
- Norwegian Bokmål (71%)
- Persian (fa_ARAB) (93%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (93%)
- Slovak (59%)
- Spanish (98%)
- Swedish (89%)
- Telugu (65%)
- Turkish (80%)
- Ukrainian (74%)
- Western Armenian (hyw_ARMN) (60%)
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

The release team for Koha 25.05.13 is


- Release Manager: Pedro Amorim

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize

- QA Manager: Lisette Scheer

- QA Team:
  - Lucas Gass
  - Laura Escamilla
  - Kyle M Hall
  - Baptiste Wojtkowski
  - Victor Grousset
  - David Cook
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Thomas Klausner
  - Paul Derscheid
  - Jan Kissig
  - Jacob O'Mara
  - Nick Clemens
  - Tomás Cohen Arazi
  - Marcel de Rooy
  - Emily Lamancusa
  - Aleisha Amohia
  - Martin Renvoize
  - David Nind

- Topic Experts:
  - Elasticsearch/OpenSearch -- Fridolin Somers
  - SIP2 -- Kyle M Hall
  - EDI -- Kyle M Hall
  - POS -- Martin Renvoize

- Bug Wranglers:
  - Michaela Sieber
  - Laura Escamilla

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - David Nind
  - Philip Orr

- Wiki curators: 
  - Thomas Dukleth
  - George Williams

- Release Maintainers:
  - 26.05 -- Lucas Gass
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Wainui Witika-Park (Catalyst IT)
  - 24.11 -- Fridolin Somers

- Release Maintainer assistants:
  - 26.05 -- Jacob O'Mara
  - 25.05 -- Alex Buckley & Aleisha Amohia (Catalyst IT)

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.05.13
<div style="column-count: 2;">

- Athens County Public Libraries
- Auckland University of Technology
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Lund University Library
</div>

We thank the following individuals who contributed patches to Koha 25.05.13
<div style="column-count: 2;">

- Pedro Amorim (1)
- apirak (1)
- Tomás Cohen Arazi (2)
- Alex Buckley (2)
- Kevin Carnes (1)
- Casey Conlin (1)
- David Cook (5)
- Paul Derscheid (2)
- Jonathan Druart (10)
- Laura Escamilla (2)
- Andrew Fuerste-Henry (1)
- Lucas Gass (3)
- Ayoub Glizi-Vicioso (2)
- Kyle M Hall (1)
- Jan Kissig (1)
- Emily Lamancusa (2)
- Owen Leonard (6)
- Sanjar Tulkinov Anvar o'g'li (3)
- Martin Renvoize (7)
- Andreas Roussos (1)
- Emmi Takkinen (2)
- Hammat Wele (3)
- Wainui Witika-Park (3)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.05.13
<div style="column-count: 2;">

- Athens County Public Libraries (6)
- [ByWater Solutions](https://bywatersolutions.com) (7)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (5)
- [Dataly Tech](https://dataly.gr) (1)
- Independant Individuals (4)
- Koha Community Developers (10)
- [Koha-Suomi Oy](https://koha-suomi.fi) (2)
- [LMSCloud](https://www.lmscloud.de) (2)
- Lund University Library (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (2)
- [OpenFifth](https://openfifth.co.uk) (8)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- punsarn.asia (1)
- [Solutions inLibro inc](https://inlibro.com) (5)
- [Theke Solutions](https://theke.io) (2)
- Wildau University of Technology (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Tomás Cohen Arazi (1)
- Nick Clemens (1)
- David Cook (7)
- Paul Derscheid (1)
- Jonathan Druart (5)
- Laura Escamilla (2)
- Andrew Fuerste-Henry (7)
- Lucas Gass (34)
- Kyle M Hall (2)
- Juliet Heltibridle (1)
- Mason James (1)
- Jan Kissig (1)
- Thomas Klausner (2)
- Emily Lamancusa (1)
- Brendan Lawlor (2)
- Owen Leonard (3)
- David Nind (21)
- Sanjar Tulkinov Anvar o'g'li (5)
- Jacob O'Mara (35)
- Martin Renvoize (21)
- Phil Ringnalda (4)
- Marcel de Rooy (7)
- Bernard Scaife (1)
- Edith Speller (1)
- Justin Swink (1)
- John Vinke (1)
- Wainui Witika-Park (59)
- Baptiste Wojtkowski (10)
- Chloe Zermatten (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.05.x

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 05 Aug 2026 04:34:37.
