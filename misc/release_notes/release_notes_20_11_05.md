# RELEASE NOTES FOR KOHA 20.11.05
26 avril 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.05 is a bugfix/maintenance release.

It includes 8 enhancements, 61 bugfixes.

### System requirements

These are the [recommendations for deployment](https://wiki.koha-community.org/wiki/Release_maintenance#System_requirements_and_recommendations).




## Enhancements

### Command-line Utilities

- [[26459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26459) Allow sip_cli_emulator to handle cancelling holds
- [[27839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27839) koha-worker missing tab-completion in bash

### OPAC

- [[27991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27991) Message field for checkout notes should have a maxlength set

### Templates

- [[25846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25846) Improve handling of multiple covers on catalog search results in the staff client

  >This enhancement updates the staff interface catalog search results to improve the display of multiple covers associated with each search result:
  >- Adlibris
  >- Amazon
  >- Google
  >- OpenLibrary
  >- Local cover images (including multiple local cover images)
  >- Coce (serving up Amazon, Google, and OpenLibrary images)
  >- Images from the CustomCoverImages preference
  >A single cover is now displayed for each result, with controls for scrolling through any other available cover.
- [[26970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26970) Add row highlight on drag in Elasticsearch mapping template
- [[28006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28006) Restore "Additional fields" link on serials navigation menu
- [[28046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28046) Add "Additional fields" link on acquisition navigation menu
- [[28132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28132) Remove "this" from button descriptions on basket and basket group pages


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[26705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26705) System preference NoticeBcc not working

  >The Email::Stuffer library we use, doesn't handle Bcc as Mail::Sendmail does. So Bcc handling wasn't working as expected. This patchset adds support for explicitly handling Bcc (including the NoticeBcc feature) to our Koha::Email library.

### Circulation

- [[28136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28136) Transferred holds are not triggering

### Fines and fees

- [[25508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25508) Confusing renewal message when paying accruing fine with RenewAccruingItemWhenPaid turned off
- [[27796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27796) SIP payment types should not be available as refund types
- [[27927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27927) longoverdue cronjob renews items before marking lost when both RenewAccruingItemWhenPaid and  WhenLostForgiveFine  are enabled

### Hold requests

- [[27529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27529) Cannot place hold on OPAC if hold_fullfillment_policy is set to group and  OPACAllowUserToChooseBranch  not allowed

### Notices

- [[28023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28023) Typo in Reply-To header

### Patrons

- [[25946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25946) borrowerRelationship can no longer be empty
- [[26517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26517) Avoid deleting patrons with permission

### Searching - Elasticsearch

- [[26312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26312) Add some error handling during Elasticsearch indexing

### Tools

- [[28015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28015) Inventory tool fails when timeformat=12h


## Other bugs fixed

### Acquisitions

- [[27900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27900) regression: add from existing record with null results deadends
- [[28003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28003) Invoice adjustments using inactive budgets do not indicate that status
- [[28077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28077) Missing colon on suggestion modification page
- [[28103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28103) Barcode fails when adding item during order receival

### Architecture, internals, and plumbing

- [[24000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24000) Some modules do not return 1
- [[27807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27807) API DataTables Wrapper fails for ordered on multiple columns
- [[28053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28053) Warning in C4::Members::patronflags
- [[28156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28156) Koha::Account::Line->renewable must be named is_renewable

### Cataloging

- [[27738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27738) Set fallback for unset DefaultCountryField008 to |||, "no attempt to code"
- [[27739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27739) Advanced editor should use DefaultCountryField008 system preference rather than hardcoding xxu
- [[28123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28123) Commas in file names of uploaded files cause inconsistently broken 856$u links

### Circulation

- [[27969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27969) On checkin, relabel "Remember due date" as "Remember return date"

### Command-line Utilities

- [[27656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27656) misc/cronjobs/longoverdue.pl better error message

### Fines and fees

- [[28097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28097) t/db_dependent/Koha/Account/Line.t test fails with FinesMode set to calculate
- [[28147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28147) Pass itemnumber when writing off a single debit

### Hold requests

- [[18729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18729) Librarian unable to update hold pickup library from patron pages without "modify_holds_priority" permission
- [[26999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26999) "Any library" not translatable on the hold list
- [[27921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27921) Timestamp in holds log is out of date when a hold is marked as waiting
- [[28118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28118) Fix missing "selected" attribute in "Pickup at" dropdown

### Lists

- [[28069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28069) Can't sort lists on staff client

### Notices

- [[28017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28017) Allow non-FQDN and IP addresses in emails

### OPAC

- [[27726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27726) OPACProblemReports cuts off message text
- [[27748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27748) Encoding problem in link to OverDrive results
- [[27881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27881) Markup error in masthead-langmenu.inc
- [[27889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27889) Form fields in OPAC are "out of shape"

  >This patch tweaks the CSS for the advanced search form in the OPAC so that it adjusts well at various browser widths, including preventing the form from taking up the whole width of the page at higher browser widths.
- [[27940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27940) Fix missing email in OpacMaintenance page

  >This fixes no email address being shown on the OPAC maintenance page for "site administrator" link (when OpacMaintenance is set). Before this the link was showing as an empty "mailto:" instead of the value of KohaAdminEmailAddress
- [[27961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27961) External track clicks links should get uri filtered

  **Sponsored by** *Parliamentary Library New Zealand*
- [[27979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27979) Multiple item URIs break redirect if TrackClicks enabled

  **Sponsored by** *Catalyst*
- [[28094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28094) Fix bad encoding of OVERRIDE_SYSPREF_LibraryName

### Patrons

- [[27937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27937) Date of birth entered  without correct format causes internal server error
- [[28043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28043) Some patron clubs operations don't work from later pages of results

### SIP2

- [[27936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27936) AllowItemsOnHoldCheckoutSIP does not allow checkout of items currently waiting for a hold
- [[28052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28052) keys omitted in check for system preference override
- [[28054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28054) SIPServer.pm is a program and requires a shebang

### Searching

- [[26679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26679) Genre tags linking to subject search, causing null results
- [[27746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27746) Use of uninitialized value $oclc in pattern match (m//) error at C4/Koha.pm
- [[27928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27928) FindDuplicate is hardcoded to use Zebra
- [[28074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28074) Browse controls on staff detail pages are sometimes weird

### Serials

- [[27397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27397) Serials: The description input field when defining numbering patterns is too short

### Staff Client

- [[27926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27926) Date of birth sorting with British English format is broken

### System Administration

- [[27999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27999) Display the description of authorized values category
- [[28121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28121) Wrong punctuation on desk deletion

### Templates

- [[28004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28004) Incomplete breadcrumbs in authorized valued

  >This patch fixes some incorrect displays within the breadcrumbs on authorised_values.tt
- [[28032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28032) Button corrections in point of sale pages
- [[28042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28042) Button corrections in OAI set mappings template

### Tools

- [[26942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26942) TinyMCE in the News Tool is still doing some types of automatic code cleanup
- [[27963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27963) touch_all_items.pl script is not working at all
- [[28044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28044) Calendar: Tables with closed days are no longer color coded

### Z39.50 / SRU / OpenSearch Servers

- [[26528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26528) Koha return no result if  there's  invalid records in Z39.50/SRU server reply
- [[28112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28112) Z39.50 does not populate form with all passed criteria


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

- Arabic (99.6%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Catalan; Valencian (52.7%)
- Chinese (Taiwan) (89.2%)
- Czech (73.1%)
- English (New Zealand) (59.6%)
- English (USA)
- Finnish (78.2%)
- French (88.4%)
- French (Canada) (91.2%)
- German (100%)
- German (Switzerland) (67%)
- Greek (60.8%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (63.5%)
- Polish (83.7%)
- Portuguese (77.3%)
- Portuguese (Brazil) (94.6%)
- Russian (94.2%)
- Slovak (80.8%)
- Spanish (98.9%)
- Swedish (74.6%)
- Telugu (79.9%)
- Turkish (96.9%)
- Ukrainian (64.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.05 is


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
new features in Koha 20.11.05:

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Parliamentary Library New Zealand

We thank the following individuals who contributed patches to Koha 20.11.05.

- Aleisha Amohia (2)
- Tomás Cohen Arazi (17)
- Colin Campbell (2)
- Nick Clemens (12)
- David Cook (2)
- Jonathan Druart (13)
- Magnus Enger (2)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (2)
- Lucas Gass (3)
- Didier Gautheron (1)
- Joonas Kylmälä (1)
- Owen Leonard (14)
- Catherine Ma (1)
- James O'Keeffe (1)
- Séverine Queune (2)
- Martin Renvoize (15)
- Phil Ringnalda (2)
- Marcel de Rooy (1)
- Fridolin Somers (9)
- Koha Translators (1)
- Petro Vashchuk (4)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.05

- Athens County Public Libraries (14)
- BibLibre (10)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- Bibliothèque Universitaire des Langues et Civilisations (BULAC) (2)
- ByWater-Solutions (17)
- Catalyst Open Source Academy (2)
- Chetco Community Public Library (2)
- Independant Individuals (6)
- Koha Community Developers (13)
- Libriotech (2)
- Prosentient Systems (2)
- PTFS-Europe (17)
- Rijks Museum (1)
- Theke Solutions (17)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (3)
- Donna Bachowski (1)
- Nick Clemens (15)
- Jonathan Druart (96)
- Katrin Fischer (22)
- Andrew Fuerste-Henry (8)
- Lucas Gass (2)
- Victor Grousset (3)
- Amit Gupta (9)
- Kyle M Hall (13)
- Sally Healey (1)
- Joonas Kylmälä (11)
- Owen Leonard (13)
- Julian Maurice (2)
- Kelly McElligott (1)
- David Nind (22)
- Séverine Queune (5)
- Martin Renvoize (34)
- Phil Ringnalda (1)
- Marcel de Rooy (2)
- Fridolin Somers (100)
- Petro Vashchuk (2)

We thank the following individuals who mentored new contributors to the Koha project.

- Andrew Nugged


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

Autogenerated release notes updated last on 26 avril 2021 12:40:23.
