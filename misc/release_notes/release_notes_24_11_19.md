# RELEASE NOTES FOR KOHA 24.11.19
25 Aug 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.19 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.19.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.19 is a bugfix/maintenance releasei with security patches.

It includes 1 enhancements, 26 bugfixes (3 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [42736](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42736) SQL Injection in reports/cat_issues_top.pl via Criteria / Filter request parameters (unvalidated string context, no placeholders)
- [42800](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42800) Potential XSS in shelf list in the erm module
- [42904](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42904) Prevent XSS in patron restriction comments

## Bugfixes

### About

#### Other bugs fixed

- [41102](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41102) Error 500 on the "About" page when biblioserver Zebra configuration is missing
  >This fixes the About Koha page when Zebra is not running or not correctly configured in the Koha instance's koha-conf.xml file. Instead of a 500 error when you access the page, there is now a message in the server information tab for Zebra's status, such as "Zebra server seems not to be available. Is it started?".
- [42726](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42726) Release team 26.11
  >Updates changes to the 25.11 release team, and adds the details of people in the 26.05 release team. (More > About Koha > Koha team.)

### Acquisitions

#### Critical bugs fixed

- [42723](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42723) Purchase suggestion 500 page error when EmailPurchaseSuggestions is set to "email address of library"
  >This fixes a 500 page error[1] when creating a suggestion in the staff interface if:
  >- the EmailPurchaseSuggestions system preference is set to "email address of library", and
  >- the library for acquisition information is set to "Any".
  >
  >[1] Can't call method "inbound_email_address" on an undefined value at /kohadevbox/koha/Koha/Suggestion.pm line 107

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [30233](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30233) [ZDI-CAN-29165] Remote code execution in user-supplied regex
  >This change refactors the regular expression handling for Batch Item Modification, MARC Modification templates, and Callnumber splitting. It moves from Perl's traditional compile-time regular expression handling to a more dynamic (but restrictive) run-time regular expression handling more similar to Python's "sub" regex method. This functions to reduce vulnerabilities to code injection into Koha's Perl backend.
- [42746](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42746) Stored SQL injection via unvalidated 'agefield' in automatic_item_modification_by_age (C4::Items::ToggleNewStatus)
- [42747](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42747) Stored SQL injection via patroncard layout image_name (patroncards/edit-layout.pl -> create-pdf.pl)
- [42749](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42749) SQL injection in acqui/parcels.pl via the orderby parameter (ORDER BY direction) reaching C4::Acquisition::GetInvoices
- [42847](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42847) SIP authentication ignored after initial successful connection
- [43019](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43019) OPAC pages limited to library are readable by unauthenticated users

#### Other bugs fixed

- [42317](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42317) [CVE-2014-1626] Require MARC::File::XML > 1.0.2
  >This updates the CPAN file to reflect the minimum version
  >needed for the MARC::File::XML Perl module. This is important
  >because of the vulnerabilities in version 1.0.1.
  >
  >(Note: This should not cause any issues, as v1.0.5 is available and already used from Debian repositories for installation.)
- [42866](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42866) SQL Injection in Koha/AdditionalContents.pm search_for_display via the patron lang value (stored / second-order, executed on issue-slip print, unvalidated string context, no placeholder)

### Cataloging

#### Other bugs fixed

- [42262](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42262) MARC 006 tag editor plugin drops blank value in position 17 when editing existing tag

### Circulation

#### Other bugs fixed

- [41352](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41352) Bookings to Collect Help does not take you to the correct place in the manual
  >This fixes the link to the help for the Circulation > Holds and bookings > Bookings to collect page - it now links to the correct place in the documentation, instead of the documentation home page.
- [41510](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41510) Fallback on bookable itemtype can break if item has no itemtype
  >Catches the unlikely case of there not being an itemtype associated with item or bib for bookings.

### Command-line Utilities

#### Other bugs fixed

- [40744](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40744) Don't give noisy warning when PatronSelfRegistration is turned off
  >When PatronSelfRegistration is set to ignore (i.e. do nothing) if --del-exp-selfreg is passed to cleanup_database.pl we were issuing warnings.  This patch removes those.

### ERM

#### Other bugs fixed

- [42130](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42130) Holdings created in ERM with a linked bibliographic record does not index the record
  >This fixes indexing of records, so that when a new title is added in the ERM module (ERM > eHoldings > Local > Titles) and 'Create bibliographic record' is selected, the new record can be found when searching.

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [41337](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41337) koha-create --request-db and --populate-db creates log files owned by root (intranet-error.log, opac-error.log)
  >This fixes the UNIX user/group ownership of the log files `intranet-error.log` and `opac-error.log` inside `/var/log/koha/<instance>/`.
  >Previously, running `koha-create --request-db` followed by `koha-create --populate-db` would result in the two log files being owned by root/root.
  >The correct ownership is now applied, meaning the log files will be owned by the <instance>-koha/<instance>-koha UNIX user/group.

### MARC Bibliographic data support

#### Other bugs fixed

- [43085](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=43085) Fix typo in data/marc21_field_006.xml
  >This fixes the text label shown in the plugin/value builder for MARC21 006 tag when "CF - Computer Files" is selected. The label "12-18 - Undefined" was changed to "12-17 - Undefined".
  >
  >(Change only for Koha 25.05 - made to later releases by Bug 40284 - MARC21: Adjust maxlength for 005, 006 and 007.)

  **Sponsored by** *Toi Ohomai Institute of Technology, New Zealand*

### OPAC

#### Other bugs fixed

- [41690](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41690) Add MARC21 245$b (subtitle) to Cite option
  >This fixes citations generated using the "Cite" option in the OPAC - subtitles are now included in the title where they exist for MARC21 (245$b).

### Patrons

#### Other bugs fixed

- [37143](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37143) Patron registration allows for saving required fields with a single space instead of information
  >This changes the OPAC self-registration form validation so that required fields need actual information, and not just spaces.
  >
  >Before this, spaces could be entered into most required fields and the form would successfully submit. Now, when submitting, a warning is generated to fill in all missing fields for required fields with just spaces.

### Reports

#### Other bugs fixed

- [8127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8127) Most-circulated items report doesn't work when limited by library
  >This fixes some of the filters for the "Most-circulated items" report so that using limits (the Limits section with "Limit to" and "By") now works.
  >
  >Previously some options for "By" (such as Library and Week) generated an error message or there were no results (when results were expected).
- [41292](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41292) Add "force_password_reset_when_set_by_staff" to the allowed column name list
  >This adds the force_password_reset_when_set_by_staff field in the categories table to the list of allowed password-related fields that can be used in SQL reports.
  >
  >Currently, this field is treated as containing sensitive password-related data and generates an error when creating a report that uses it.

### Serials

#### Other bugs fixed

- [42277](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42277) JS error when viewing a subscription

## Enhancements 

### REST API

#### Enhancements

- [39900](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39900) Add public REST endpoint for additional_contents
  >A new public REST API endpoint has been added for retrieving additional contents (news items and HTML customisations) without authentication. This enables external applications and websites to access and display Koha news and custom content.
  >
  >**Endpoint details:**
  >- **Path:** `/api/v1/public/additional_contents`
  >- **Method:** GET
  >- **Authentication:** None required (public endpoint)
  >- **Query parameters:**
  >  - Standard search and filter parameters for finding specific content
  >  - `lang`: Filter by language code to retrieve content in a specific language
  >  - `embed`: Use `translated_contents` to include all available translations
  >
  >**Key features:**
  >
  >- **Public access**: No authentication required, making it suitable for displaying library news on external websites
  >- **Multi-language support**: Retrieve content in specific languages or fetch all translations at once using the `translated_contents` embed
  >- **Flexible filtering**: Search and filter additional contents using standard API query parameters
  >- **Content types**: Access both news items and HTML customisations through the same endpoint
  >
  >**For developers:**
  >
  >This endpoint follows the same patterns as other Koha public API endpoints. Use the `lang` parameter to retrieve content for a specific language, or use `embed=translated_contents` to get all available translations in a single request. This is particularly useful for multi-lingual library websites that need to display Koha news items.
  >
  >**Example use cases:**
  >- Displaying library news on an external website
  >- Integrating OPAC announcements into a library portal
  >- Building mobile applications that show library notices
  >- Creating custom displays of library information

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (83%)
- [German](https://koha-community.org/manual/24.11/de/html/) (84%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (91%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (62%)
- [Portuguese (Brazil)](https://koha-community.org/manual/24.11/pt_BR/html/) (28%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (100%)
- Azerbaijani (62%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (86%)
- Chinese (Traditional Han script) (99%)
- Czech (68%)
- Dutch (89%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- Greek (68%)
- Hindi (97%)
- Italian (84%)
- Khmer (Central) (55%)
- Norwegian Bokmål (73%)
- Persian (fa_ARAB) (96%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (95%)
- Slovak (61%)
- Spanish (99%)
- Swedish (88%)
- Telugu (67%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (77%)
- Uzbek (52%)
- Western Armenian (hyw_ARMN) (62%)
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

The release team for Koha 24.11.19 is


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
new features in Koha 24.11.19
<div style="column-count: 2;">

- Toi Ohomai Institute of Technology, New Zealand
</div>

We thank the following individuals who contributed patches to Koha 24.11.19
<div style="column-count: 2;">

- Pedro Amorim (1)
- David Cook (4)
- Paul Derscheid (3)
- Jonathan Druart (9)
- Laura Escamilla (1)
- Andrew Fuerste-Henry (1)
- Lucas Gass (2)
- Amit Gupta (1)
- Kyle M Hall (1)
- Sanjar Tulkinov Anvar o'g'li (4)
- Eric Phetteplace (1)
- Martin Renvoize (10)
- Marcel de Rooy (1)
- Andreas Roussos (1)
- Fridolin Somers (3)
- Hammat Wele (3)
- Baptiste Wojtkowski (6)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.19
<div style="column-count: 2;">

- [BibLibre](https://www.biblibre.com) (9)
- [ByWater Solutions](https://bywatersolutions.com) (5)
- [Dataly Tech](https://dataly.gr) (1)
- Independant Individuals (5)
- informaticsglobal.ai (1)
- Koha Community Developers (9)
- [LMSCloud](https://www.lmscloud.de) (3)
- [OpenFifth](https://openfifth.co.uk) (11)
- [Prosentient Systems](https://www.prosentient.com.au) (4)
- Rijksmuseum, Netherlands (1)
- [Solutions inLibro inc](https://inlibro.com) (3)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Nick Clemens (2)
- David Cook (7)
- Jonathan Druart (4)
- Laura Escamilla (1)
- Andrew Fuerste-Henry (2)
- Lucas Gass (15)
- Mason James (1)
- Jan Kissig (1)
- Brendan Lawlor (2)
- Owen Leonard (4)
- David Nind (15)
- Sanjar Tulkinov Anvar o'g'li (5)
- Jacob O'Mara (13)
- Lawrence O'Regan-Lloyd (1)
- Martin Renvoize (14)
- Phil Ringnalda (1)
- Marcel de Rooy (8)
- Fridolin Somers (24)
- Justin Swink (1)
- Wainui Witika-Park (18)
- Baptiste Wojtkowski (19)
- Chloe Zermatten (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Aug 2026 15:41:30.
