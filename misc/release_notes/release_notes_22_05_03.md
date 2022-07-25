# RELEASE NOTES FOR KOHA 22.05.03
25 Jul 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.03 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 8 enhancements, 32 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[30969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30969) Cross site scripting (XSS) attack in OPAC authority search ( opac-authorities-home.pl )


## Enhancements

### Architecture, internals, and plumbing

- [[30057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30057) Move Virtualshelves exceptions to their own file
- [[30877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30877) use List::MoreUtils::uniq from recalls_to_pull.pl

### Cataloging

- [[30997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30997) "CGI::param called in list context" warning in detail.pl flooding error log

  >This fixes the cause of "CGI::param called in list context from" warning messages that appear in the log files when viewing record detail pages in the staff interface.

### REST API

- [[30923]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30923) OAuth2 implementation is not experimental

  >This enhancement removes the [EXPERIMENTAL] text from the RESTOAuth2ClientCredentials system preference description. OAuth2 has been in use by third parties to securely interact with Koha since its introduction in 2018.

### Reports

- [[29312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29312) Punctuation: Total number of results: 961 (300 shown) .

### System Administration

- [[27519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27519) Normalize Show/Don't show vs Display/Don't display in system preferences

  >This enhancement replaces "Display/Don't display" with "Show/Don't show" for several system preferences to improve terminology consistency and make translation easier. A few preferences were also updated where "Yes/No" and "Show/Hide" were used.

### Templates

- [[30806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30806) Use patron-title.inc in member-flags template

  >This enhancement updates the template for the patron set permissions page (members/member-flags.pl) to use the patron-title.inc include wherever patron names are referenced. This is used to format patron name names consistently, rather than a custom format each time the patron name is referenced. The patron name is now displayed as "Set permissions for firstname lastname (patron card number), instead of "Set permissions for lastname, firstname".
- [[30807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30807) Use patron-title.inc in patron payments pages

  >This enhancement updates the templates for patron accounting - make a payment tab and payment pages (pay and write off options) to use the patron-title.inc include wherever patron names are referenced. This is used to format patron name names consistently, rather than a custom format each time the patron name is referenced. The patron name is now displayed as "Make a payment for firstname lastname (patron card number)" and "Pay charges for firstname lastname (patron card number)".


## Critical bugs fixed

### Cataloging

- [[29963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29963) Date accessioned plugin should not automatically fill today's date on cataloguing screens

### Circulation

- [[29504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29504) Confirm item parts requires force_checkout permission (checkouts tab)
- [[30924]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30924) Fix recalls-related errors in transfers and cancelling actions

### Command-line Utilities

- [[30914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30914) cleanup_database.pl --transfers --old-reserves --confirm does not work

### Installation and upgrade (command-line installer)

- [[30539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30539) Koha upgrade error "Column 'claimed_on' cannot be null"

  >This fixes an upgrade error that could result in data loss when upgrading from earlier releases to 20.05 (and later releases). It results in the claim_dates for orders being replaced with the date the upgrade was run. (This was caused by an error in the database update for bug 24161 - Add ability to track the claim dates of later orders.)

### Lists

- [[30925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30925) Creating public list by adding items to new list creates a private list

### REST API

- [[30677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30677) Unknown column 'biblioitem.title' in 'where clause' 500 error in API /api/v1/acquisitions/orders


## Other bugs fixed

### Acquisitions

- [[29607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29607) addorderiso2709: The stored discount when importing an order from a file is invalid

  >This fixes how the discount amount for an order is stored and shown when an order is added to a basket using "From staged MARC records". The discount amount was incorrectly stored in the database and shown incorrectly when modifying the order (for example, a 25% discount shown as 0.2500 in the database and .25% on the form). This would result in the order amount changing when modifying an order.
- [[30938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30938) Fix column configuration to the acquisitions home page

  >This fixes the acquisitions home page to show the column configuration button.

### Architecture, internals, and plumbing

- [[29871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29871) Remove marcflavour param in Koha::Biblio->get_marc_notes
- [[30399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30399) Patron.t fails when there is a patron attribute that is mandatory
- [[30409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30409) barcodedecode() should always trim barcode
- [[30954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30954) includes/background_jobs_update_elastic_index.inc  must be removed
- [[30974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30974) Job size not correct for indexing jobs

### Hold requests

- [[12630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12630) Prioritizing "Hold starts on date" -holds causes all other holds to be prioritized as well!

### I18N/L10N

- [[30958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30958) OPAC Overdrive search result page broken for translations

  **Sponsored by** *Melbourne Athenaeum Library, Australia*

### MARC Authority data support

- [[29260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29260) UNIMARC 210a is reported to Author (meeting/conference) when upgrading an authority through Z3950

  >This fixes UNIMARC authority editing when using 'Replace record via Z3950/SRU search'. When pre-populating the search form the value of 210$a (Authorized Access Point - Corporate Body Name) now goes into the Author (corporate) search form field instead of Author (meeting / conference).

### MARC Bibliographic record staging/import

- [[30738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30738) Forked CGI MARC import warnings are not logged
- [[30789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30789) Improve performance of AddBiblio when importing records with many items

### Notices

- [[28355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28355) Add warning note about Email SMS driver option for SMSSendDriver

  >This updates the text for the SMSSendDriver system preference. The Email SMS driver option is no longer recommended unless you use a dedicated SMS to Email gateway. Many mobile providers offer inconsistent support for the email to SMS gateway (sometimes it works, and sometimes it doesn't), which can cause frustration for patrons.

### OPAC

- [[30989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30989) Tags with some special characters are not encoded right

  >This fixes tags with special characters (such as +) so that the searching returns results when the tag is selected (from the record detail view in the OPAC and staff interface, and from the search results, tag cloud, and list pages in the OPAC).

### Patrons

- [[30026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30026) International phone number not supported for sending SMS
- [[30713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30713) Patron entry should limit date of birth selection to dates in the past

  >This fixes the date of birth field for the patron entry form so that the calendar widget does not let you select a date in the future.
- [[30891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30891) SMS provider shows on staff side even if SMS::Send driver is not set to "Email"

### REST API

- [[30780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30780) Librarians with only "place_holds" permissions can not update holds data via REST API

  **Sponsored by** *Koha-Suomi Oy*

  >This enhancement enables librarians with only "place_holds" permissions to cancel, suspend and resume holds using the REST API.

### Serials

- [[30973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30973) Serials search wrong body id

### Staff Client

- [[30798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30798) Columns Home library and Checked out from in wrong order on table settings for account_fines table

  **Sponsored by** *Koha-Suomi Oy*

### System Administration

- [[30585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30585) Table settings for course_reserves_table are wrong due to lack of "Holding library" option
- [[30864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30864) Patron category form - no validation for password expiration field

  >This adds validation to the "Password expiration" field on the patron category form. If letters or other characters were entered, there was no error message. If what was entered was not a number, then it was not saved.

### Templates

- [[30768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30768) Typo: pin should be PIN

### Tools

- [[30778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30778) ModBiblioInBatch is not used and can be removed
- [[30904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30904) (bug 24387 follow-up) Modifying library in news (additional contents) causes inconsistencies



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (78.6%)
- Armenian (100%)
- Armenian (Classical) (71.6%)
- Bulgarian (85.1%)
- Chinese (Taiwan) (81.1%)
- Czech (62.4%)
- English (New Zealand) (56.6%)
- English (USA)
- Finnish (95.4%)
- French (96.8%)
- French (Canada) (94.1%)
- German (100%)
- German (Switzerland) (54.6%)
- Greek (53.4%)
- Hindi (91.4%)
- Italian (92.5%)
- Nederlands-Nederland (Dutch-The Netherlands) (79.3%)
- Norwegian Bokmål (55.9%)
- Polish (87.7%)
- Portuguese (79.9%)
- Portuguese (Brazil) (76.7%)
- Russian (78.2%)
- Slovak (64.2%)
- Spanish (98.2%)
- Swedish (77.5%)
- Telugu (85.4%)
- Turkish (90%)
- Ukrainian (69.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.03 is


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

- Packaging Manager: 


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
new features in Koha 22.05.03

- Koha-Suomi Oy
- Melbourne Athenaeum Library, Australia

We thank the following individuals who contributed patches to Koha 22.05.03

- Tomás Cohen Arazi (6)
- Florian Bontemps (2)
- Alex Buckley (1)
- Nick Clemens (5)
- David Cook (1)
- Jonathan Druart (10)
- Marion Durand (1)
- Katrin Fischer (5)
- Lucas Gass (6)
- Kyle M Hall (3)
- Olli-Antti Kivilahti (1)
- Joonas Kylmälä (1)
- Owen Leonard (1)
- Séverine Queune (1)
- Johanna Raisa (1)
- Martin Renvoize (6)
- Marcel de Rooy (1)
- Fridolin Somers (2)
- Emmi Takkinen (1)
- Christophe TORIN (1)
- Koha translators (1)
- Michal Urban (1)
- Petro Vashchuk (3)
- Shi Yao Wang (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.03

- Athens County Public Libraries (1)
- BibLibre (6)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (5)
- Bibliothèque Universitaire des Langues et Civilisations (BULAC) (1)
- ByWater-Solutions (14)
- Catalyst (1)
- Independant Individuals (6)
- Koha Community Developers (10)
- Koha-Suomi (1)
- Prosentient Systems (1)
- PTFS-Europe (6)
- Rijksmuseum (1)
- Solutions inLibro inc (1)
- Theke Solutions (6)
- Université Rennes 2 (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (50)
- Alex Buckley (1)
- Nick Clemens (3)
- Chris Cormack (1)
- Jonathan Druart (10)
- Katrin Fischer (15)
- Lucas Gass (59)
- Kyle M Hall (2)
- Sally Healey (1)
- Joonas Kylmälä (1)
- Owen Leonard (3)
- David Nind (29)
- Martin Renvoize (11)
- Marcel de Rooy (5)
- Fridolin Somers (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2205.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Jul 2022 16:05:06.
