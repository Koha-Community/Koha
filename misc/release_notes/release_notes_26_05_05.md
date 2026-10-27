# RELEASE NOTES FOR KOHA 26.05.05
27 Oct 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 26.05.05 can be downloaded from:

- [Download](https://download.koha-community.org/koha-26.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 26.05.05 is a bugfix/maintenance release.

It includes 6 enhancements, 50 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [42946](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42946) [CVE-2026-16031] Time-based Blind SQL Injection in itemsearch.pl functionality
- [43429](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43429) Stored XSS via OPAC Report a Problem executes in staff/intranet security context (8.7 HIGH)
- [43634](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43634) cancelBulk in waitingreserves.pl is not protected against CSRF attacks
- [43707](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43707) Fix stored XSS in DT's column filters in staff interface

## Bugfixes

### Accessibility

#### Other bugs fixed

- [42235](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42235) On OPAC messaging preferences page table header contains no text
  >This fixes two accessibility issues with the patron's OPAC messaging table (OPAC > [log in] > Your account > Messaging): "Table header text should not be empty".
  >
  >Previously:
  >1. The first column header has no text.
  >2. When responsive table controls were shown for the table, there was no title in the last column header with the controls (a green "+" button is shown when the browser window is narrower and all the columns can't be displayed).
  >
  >Now:
  >1. The first column header now has the text "Message type".
  >2. The responsive table control column header has the text "Expand" when the responsive controls are shown.

### Acquisitions

#### Critical bugs fixed

- [43211](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43211) Koha hangs when receiving order with AcqCreateItem set to 'receiving an order'
  >This fixes an error when receiving an order, when the basket has "Create items when" set to "receiving an order". Orders can now be received when this is the case.
  >
  >Previously, receiving an order would result in the page staying on "Processing", and nothing further happening (as well as a browser console JavaScript error "Uncaught TypeError: unique_item_fields.split is not a function").
- [43787](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43787) Adding orders from a staged file ( addorderiso2709.pl ) can use gigabytes of memory if there are many funds
- [43793](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43793) 26.05.04 backport of bug 42605 is incomplete

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [43330](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43330) C4::Tags fails to compile when TagsExternalDictionary is configured

#### Other bugs fixed

- [42924](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42924) Restore default MaxAge for CSRF token
- [43092](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43092) Koha::File::Transport::change_directory(undef) means three different things across FTP, SFTP and Local

### Authentication

#### Critical bugs fixed

- [43375](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43375) OAuth userinfo_url silently fails to parse JSON when Content-Type has extra parameters (e.g. Microsoft Graph)
  >This patch makes the content-type detection for the OAuth2 client more robust. The result is more robust integration with external identity providers.

### Cataloging

#### Critical bugs fixed

- [32748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32748) Library limitations will cause data loss when editing items
  >When an authorised value used on the item edition form (e.g. damaged status, withdrawn status, etc.) was restricted to a specific library, staff at other libraries could not see the item's current value in the dropdown list and risked silently overwriting it when saving.
  >
  >This is now fixed: the current value is always displayed, even if it comes from an authorised value restricted to another library, with a warning indicating it is not normally available for the logged-in library.

  **Sponsored by** *BibLibre*
- [35104](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35104) We should warn when attempting to save MARC records that contain characters invalid in XML

  **Sponsored by** *OpenFifth*

#### Other bugs fixed

- [43239](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43239) Serial items item type can be set incorrectly when receiving multiple items
  >This fixes the item type created for serials, when item records are created for subscriptions.
  >
  >Explanation:
  >
  >It is possible to create subscription item records with the wrong
  >item type if:
  >- the makePreviousSerialAvailablesystem preference is enabled, and 
  >- there is no value selected for the "Item type for older issues" field.
  >
  >In installations where item types differ between items and records, this causes data inconsistencies and leads to errors in a record's holdings table.
  >
  >This fix changes the behaviour of the serials subscription form so that if
  >makePreviousSerialAvailable is enabled and a subscription's "Item type for older issues" field is empty/not selected, the previous item type value is kept for item records. It also adds a hint text to the subscription form about this change.

  **Sponsored by** *Koha-Suomi Oy*

### Circulation

#### Other bugs fixed

- [42697](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42697) Home library and current library filters can filter incorrectly

### Command-line Utilities

#### Other bugs fixed

- [35061](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35061) Fix documentation for --preserve-field in import_patrons.pl

### Hold requests

#### Critical bugs fixed

- [43072](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43072) fill_other_biblio_holds_policy values display incorrectly in circ rules page
- [43378](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43378) Wrong hold can be selected when LocalHoldsPriority set to GiveLibraryAndGroup

### I18N/L10N

#### Other bugs fixed

- [43260](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43260) Debug options in navigation bar untranslatable
  >This fixes the "Debug controls" options in the staff interface so that they are translatable. It also changes the options to sentence case, as per the coding guidelines.
  >
  >The debug controls menu that is shown in the top right-hand side of the top menu in the staff interface (only shows if the staff patron has "Display the debug interface (debug)" permissions) - options are now in sentence case:
  >- Disable custom CSS
  >- Disable custom JS
  >- Disable custom stylesheets

  **Sponsored by** *Athens County Public Libraries*

### ILL

#### Other bugs fixed

- [43204](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43204) ILL availability search: Source column links to plain OPAC URL instead of the deep link
- [43354](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43354) ILL request table search returns a 500 error
  >This fixes the ILL requests history table for a patron, so that a search doesn't result in a 500 error (Patrons > [selected patron] > ILL requests history > Search [filter above the table]).

### Notices

#### Critical bugs fixed

- [40294](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40294) Mandatory patron expiration notice is not sent if patron does not have a primary contact method defined
  >This fixes a bug with the option to make expiration notices mandatory by patron category.
  >
  >Before this update, if a Primary Contact Method has not been selected on the patron's account, the expiration notice will not be sent.
  >
  >With the update, the standard patron messaging preferences can be set for the expiration notice.
  >
  >If the expiration notice is mandatory, but the patron does not have any messaging preferences enabled for that notice, the notice will fall back to the first possible messaging method (depending on available contact information and system settings), in this order:
  >- email
  >- phone
  >- sms
  >- print

#### Other bugs fixed

- [43342](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43342) Default OVERDUES_SLIP contains empty lines

### OPAC

#### Critical bugs fixed

- [30319](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30319) Patron self-modification values not retained if field blocked in PatronSelfRegistrationBorrowerUnwantedField
  >Fixes a problem in patron self-modification where the fields in PatronSelfRegistrationBorrowerUnwantedField were being discarded even when they were visible, and editable, on the patron self-modification page.

  **Sponsored by** *OpenFifth*
- [39589](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39589) Search returns 'No results found' despite existing matching records
- [41197](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41197) opac/opac-account-pay-return.pl should not require CSRF

#### Other bugs fixed

- [20846](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20846) Suppressed records still appear in public lists
- [40799](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40799) Loading spinner not removed because .cover-slider is now used instead of .cover-slides
  >This fixes the display of cover images on detail pages in the OPAC. For cover images with a shorter height, the loading spinner indicating that the image is currently loading was still shown after the image is loaded.
- [42634](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42634) Self-checkout Finish/logout does not reliably clear the JWT cookie

  **Sponsored by** *OpenFifth*

### Patrons

#### Other bugs fixed

- [42018](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42018) Inconsistent behavior for null values for fields selected in PatronDuplicateMatchingAddFields
- [43245](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43245) There should be a message in the staff interface if a patron has no email address and you reset their password (More > Send password reset)
  >This fixes resetting a password for a patron in the staff interface ("More > Send password reset" option when OpacResetPassword is set to "allowed").
  >
  >If a patron has no an email message, no message was sent. There was no indication about this and the reason why, so you would assume that a password reset notice was sent (apart from redirecting to the patron notices section, where you may have noticed that there isn't a password reset notice queued).
  >
  >Now, if the patron does not have an email address, a message is shown:
  >
  >       Unable to send password reset
  >
  >       The patron has no email address
- [43672](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43672) When a patron has no advance notices value and their category is changed to one with a value the checkboxes are not enabled

### Plugin architecture

#### Critical bugs fixed

- [41648](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41648) Incorrect 'update_date' breaks the plugins home page

  **Sponsored by** *OpenFifth*

### REST API

#### Critical bugs fixed

- [43196](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43196) PUT requests with a bad request body to biblios endpoint blanks a record

### Reports

#### Other bugs fixed

- [42451](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42451) "convert" op in guided_reports.pl is broken due to JS error
- [43249](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43249) A duplicate report limit of 1 prevents users from running reports at all

### SIP2

#### Other bugs fixed

- [40800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40800) TransferArrived needlessly triggers alerts in SIP

  **Sponsored by** *OpenFifth*
- [42700](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42700) In C4/SIP/ILS/Patron.pm, hold_items only counts waiting holds

### Searching - Elasticsearch

#### Other bugs fixed

- [39769](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39769) es_indexer_daemon.pl uses stale L1 cache
  >The Elasticsearch indexer daemon is a long-lived process that never cleared its L1 (in-process) cache, meaning changes to system preferences like IncludeSeeFromInSearches were not picked up until the daemon was manually restarted. The L1 cache is now flushed before each indexing batch, so preference changes take effect on the next indexing run without requiring a daemon restart.

### Staff interface

#### Other bugs fixed

- [42656](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42656) File transport test responses can be unclear
- [42661](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42661) Redudant repetition in "Patron: %s Patron's home library: (%s /%s )" when HidePatronName is activated
- [42727](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42727) Languages displayed in random order in language menu
  >This fixes how language selectors/tabs are shown in the staff interface for notices and slips and additional contents (such as news and customizations) - now shown in a consistent order, and removes the "randomness" when pages are refreshed:
  >
  >1. For the staff interface footer: shows enabled languages in the order shown in the StaffInterfaceLanguages system preference.
  >
  >2. For notices and slips (with TranslateNotices system preference enabled) the language tabs are now shown in this order: Default, English, then all languages installed in language code order (de-DE, fr-CA, fr-FR, pt-BR, pt-PT, ...) (notes: not in the order shown in the StaffInterfaceLanguages system preference, shows all installed languages - not just enabled languages).
  >
  >3. For additional contents (news, HTML customizations, ...) the language tabs are now shown in this order: Default, all enabled languages in the order shown in the StaffInterfaceLanguages system preference, then languages not enabled at the end (note: if there is more than one language code for a language installed (such as fr-CA and fr-FR) but one is not enabled, the languages are grouped together - the language not enabled doesn't go to the end).
- [43313](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43313) Item's permanent location not shown when item's location is set to CART

  **Sponsored by** *OpenFifth*
- [43331](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43331) No class on collection code in holdings table on bib detail
- [43373](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43373) Holdings table always displays the shelving location column

### System Administration

#### Other bugs fixed

- [43336](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43336) Remove support for LibrisSpellcheck
  >This removes support for LibrisSpellcheck, as the API that this feature was based on was removed by the Swedish National Library.
  >
  >It removes two system preferences: LibrisKey and LibrisURL. It also removes the LibrisSpellcheck option from "Did you mean?" (Administration > Additional parameters > Did you mean?).

### Templates

#### Critical bugs fixed

- [43570](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43570) Memory leak in SafeURL and HtmlScrubber Template::Toolkit filters

### Test Suite

#### Other bugs fixed

- [43203](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43203) Item.t doesn't clean up after itself correctly
- [43339](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43339) automatic_item_modification_by_age_configuration is not a real system preference

## Enhancements 

### Acquisitions

#### Enhancements

- [34166](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34166) Show total price in table of suggestions

  **Sponsored by** *OpenFifth*
- [39959](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39959) Add total amount column to invoice search results
- [42789](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42789) EDI ORDRSP: Item and suggestion status not updated when order line cancelled by supplier

  **Sponsored by** *OpenFifth*

### I18N/L10N

#### Enhancements

- [41842](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41842) Improve translation of course reserves headings

  **Sponsored by** *Athens County Public Libraries*

### OPAC

#### Enhancements

- [41706](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41706) "Use of uninitialized value..." warning in C4/Record.pm
  >Removes the cause of "[WARN] Use of uninitialized value $2 in split at /kohadevbox/koha/C4/Record.pm line 924." warnings from the plack-opac-error.log when viewing record detail pages in the OPAC. This was related to the Cite feature.

  **Sponsored by** *Ignatianum University in Cracow*

### Patrons

#### Enhancements

- [42112](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42112) Add option when changing a patron's category: allow choosing what to do for the expiry date and messaging preferences
  >This adds two new system preferences that let you control what happens when changing a patron's category:
  >- Updating the enrollment period expiry date: 
  >   UpdateDateExpiryOnCategoryChange
  >- Updating the messaging preferences:
  >   UpdateMessagingPrefsOnCategoryChange
  >
  >When changing a patron's category, a pop-up window with pre-populated checkboxes is shown and lets you select what to do (depending on the new system preference settings).
  >
  >The options for both the new system preferences are:
  >- Never update
  >- Ask before updating, default to no
  >- Ask before updating, default to yes (note: this is the default)
  >- Always update without asking

## New system preferences

- UpdateExpiryDateOnCategoryChange
- UpdateMessagingPrefsOnCategoryChange

## Deleted system preferences

- LibrisKey
- LibrisURL

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/26.05/en/html/)
- [French](https://koha-community.org/manual/26.05/fr/html/) (82%)
- [German](https://koha-community.org/manual/26.05/de/html/) (84%)
- [Greek](https://koha-community.org/manual/26.05/el/html/) (90%)
- [Hindi](https://koha-community.org/manual/26.05/hi/html/) (61%)
- [Portuguese](https://koha-community.org/manual/26.05/pt/html/) (61%)
- [Portuguese (Brazil)](https://koha-community.org/manual/26.05/pt_BR/html/) (61%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Afrikaans (99%)
- Arabic (ar_ARAB) (87%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (62%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (79%)
- Chinese (Traditional Han script) (92%)
- Czech (64%)
- Dutch (87%)
- English (100%)
- English (New Zealand) (99%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (63%)
- Hindi (89%)
- Italian (79%)
- Khmer (Central) (57%)
- Norwegian Bokmål (67%)
- Persian (fa_ARAB) (88%)
- Polish (99%)
- Portuguese (Brazil) (98%)
- Portuguese (Portugal) (88%)
- Russian (90%)
- Slovak (56%)
- Spanish (93%)
- Swedish (89%)
- Telugu (62%)
- Turkish (76%)
- Ukrainian (71%)
- Uzbek (68%)
- Western Armenian (hyw_ARMN) (57%)
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

The release team for Koha 26.05.05 is
- Release Manager: Pedro Amorim

- QA Manager: Lisette Scheer

- QA Team:
  - Marcel de Rooy
  - Martin Renvoize
  - Jonathan Druart
  - Laura Escamilla
  - Lucas Gass
  - Tomás Cohen Arazi
  - Lisette Scheer
  - Nick Clemens
  - Paul Derscheid
  - Emily Lamancusa
  - David Cook
  - Matt Blenkinsop
  - Andrew Fuerste-Henry
  - Brendan Lawlor
  - Pedro Amorim
  - Kyle M Hall
  - Aleisha Amohia
  - David Nind
  - Baptiste Wojtkowski
  - Jan Kissig
  - Katrin Fischer
  - Thomas Klausner
  - Julian Maurice
  - Owen Leonard
  - Lucas Gass

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Philip Orr
  - Caroline Cyr La Rose
  - David Nind
  - Marion Durand

- Translation Manager: Jonathan Druart


- Wiki curators:
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 26.05 -- Lucas Gass
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Wainui Witika-Park
  - 24.11 -- Fridolin Somers

- Release Maintainer assistants:
  - 26.05 --Jacob O'Mara
  - 25.05 -- Alex Buckley & Aleisha Amohia

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 26.05.05
<div style="column-count: 2;">

- Athens County Public Libraries
- [BibLibre](https://www.biblibre.com)
- Ignatianum University in Cracow
- [Koha-Suomi Oy](https://koha-suomi.fi)
- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 26.05.05
<div style="column-count: 2;">

- Pedro Amorim (4)
- Tomás Cohen Arazi (6)
- Matt Blenkinsop (4)
- Nick Clemens (6)
- David Cook (2)
- Roman Dolny (1)
- Jonathan Druart (21)
- Magnus Enger (1)
- Laura Escamilla (4)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (5)
- Lucas Gass (10)
- Thibaud Guillot (5)
- Kyle M Hall (12)
- Janusz Kaczmarek (1)
- Jan Kissig (4)
- Emily Lamancusa (7)
- Owen Leonard (5)
- Chris Mathevet (1)
- David Nind (1)
- Andrew Nugged (2)
- Martin Renvoize (24)
- Olivia Reynolds (5)
- Lisette Scheer (2)
- Fridolin Somers (1)
- Emmi Takkinen (1)
- Hammat Wele (3)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 26.05.05
<div style="column-count: 2;">

- Athens County Public Libraries (5)
- [BibLibre](https://www.biblibre.com) (7)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (2)
- [ByWater Solutions](https://bywatersolutions.com) (39)
- David Nind (1)
- Independant Individuals (3)
- [Jezuici](https://jezuici.pl/) (1)
- Koha Community Developers (21)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- [Libriotech](https://libriotech.no) (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (7)
- [OpenFifth](https://openfifth.co.uk) (37)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- [Solutions inLibro inc](https://inlibro.com) (4)
- [Theke Solutions](https://theke.io) (6)
- Wildau University of Technology (4)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (5)
- Stephanie Baker (1)
- Baptiste Bayche (8)
- Matt Blenkinsop (1)
- Nick Clemens (16)
- David Cook (8)
- Paul Derscheid (2)
- Jonathan Druart (5)
- Sharon Dugdale (3)
- Laura Escamilla (3)
- Katrin Fischer (7)
- Andrew Fuerste-Henry (14)
- Lucas Gass (120)
- Amit Gupta (2)
- Kyle M Hall (8)
- Juliet Heltibridle (2)
- Barbara Johnson (1)
- Jan Kissig (5)
- Kristi Krueger (1)
- Emily Lamancusa (7)
- Owen Leonard (5)
- Coleen Lilly (1)
- Michaela (1)
- David Nind (53)
- Jacob O'Mara (1)
- Lawrence O'Regan-Lloyd (3)
- Martin Renvoize (8)
- Marcel de Rooy (14)
- Mathieu Saby (1)
- Lisette Scheer (6)
- Edith Speller (1)
- Michelle Spinney (1)
- Emmi Takkinen (1)
- Jackie Usher (2)
- John Vinke (2)
- Baptiste Wojtkowski (8)
- Anneli Österman (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 26.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Oct 2026 14:20:18.
