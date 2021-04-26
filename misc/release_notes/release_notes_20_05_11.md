# RELEASE NOTES FOR KOHA 20.05.11
26 Apr 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.11 is a bugfix/maintenance release.

It includes 1 enhancements, 49 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5 (End of life)
- Debian Stretch with MariaDB 10.1
- Debian Buster with MariaDB 10.3
- Ubuntu Bionic with MariaDB 10.1 
- Debian Stretch with MySQL 8.0 (Experimental MySQL 8.0 support)

Additional notes:
    
- Perl 5.10 is required (5.24 is recommended)
- Zebra or Elasticsearch is required




## Enhancements

### OPAC

- [[27991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27991) Message field for checkout notes should have a maxlength set


## Critical bugs fixed

### Fines and fees

- [[25508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25508) Confusing renewal message when paying accruing fine with RenewAccruingItemWhenPaid turned off
- [[27927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27927) longoverdue cronjob renews items before marking lost when both RenewAccruingItemWhenPaid and  WhenLostForgiveFine  are enabled

### Hold requests

- [[27529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27529) Cannot place hold on OPAC if hold_fullfillment_policy is set to group and  OPACAllowUserToChooseBranch  not allowed

### Patrons

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

- [[27807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27807) API DataTables Wrapper fails for ordered on multiple columns
- [[28053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28053) Warning in C4::Members::patronflags
- [[28156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28156) Koha::Account::Line->renewable must be named is_renewable

### Cataloging

- [[27738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27738) Set fallback for unset DefaultCountryField008 to |||, "no attempt to code"
- [[27739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27739) Advanced editor should use DefaultCountryField008 system preference rather than hardcoding xxu
- [[28123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28123) Commas in file names of uploaded files cause inconsistently broken 856$u links

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

### OPAC

- [[27726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27726) OPACProblemReports cuts off message text
- [[27940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27940) Fix missing email in OpacMaintenance page

  >This fixes no email address being shown on the OPAC maintenance page for "site administrator" link (when OpacMaintenance is set). Before this the link was showing as an empty "mailto:" instead of the value of KohaAdminEmailAddress
- [[27979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27979) Multiple item URIs break redirect if TrackClicks enabled

  **Sponsored by** *Catalyst*
- [[28021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28021) OPAC detail page contains incorrect Bootstrap classes (20.05.x)

  >This patch fixes some bad Bootstrap classes introduced to 20.05 via a bad backport.
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

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/20.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.7%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.2%)
- Czech (80.7%)
- English (New Zealand) (66.7%)
- English (USA)
- Finnish (70.4%)
- French (85%)
- French (Canada) (97.3%)
- German (100%)
- German (Switzerland) (74.4%)
- Greek (62.2%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (71.1%)
- Polish (79.3%)
- Portuguese (86.7%)
- Portuguese (Brazil) (98%)
- Russian (86.5%)
- Slovak (89.7%)
- Spanish (99.7%)
- Swedish (79.5%)
- Telugu (92.5%)
- Turkish (100%)
- Ukrainian (66.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.11 is


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
new features in Koha 20.05.11:

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)

We thank the following individuals who contributed patches to Koha 20.05.11.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (6)
- Colin Campbell (2)
- Nick Clemens (8)
- David Cook (2)
- Jonathan Druart (11)
- Magnus Enger (1)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (6)
- Lucas Gass (4)
- Didier Gautheron (1)
- Joonas Kylmälä (1)
- Owen Leonard (7)
- Catherine Ma (1)
- Séverine Queune (2)
- Martin Renvoize (9)
- Phil Ringnalda (2)
- Fridolin Somers (3)
- Koha Translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.11

- Athens County Public Libraries (7)
- BibLibre (4)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- Bibliothèque Universitaire des Langues et Civilisations (BULAC) (2)
- ByWater-Solutions (18)
- Chetco Community Public Library (2)
- Independant Individuals (3)
- Koha Community Developers (11)
- Libriotech (1)
- Prosentient Systems (2)
- PTFS-Europe (11)
- Theke Solutions (6)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (4)
- Donna Bachowski (1)
- Nick Clemens (13)
- Jonathan Druart (57)
- Katrin Fischer (11)
- Andrew Fuerste-Henry (69)
- Lucas Gass (2)
- Victor Grousset (1)
- Amit Gupta (9)
- Kyle M Hall (2)
- Joonas Kylmälä (10)
- Owen Leonard (13)
- Julian Maurice (2)
- David Nind (13)
- Séverine Queune (3)
- Martin Renvoize (23)
- Marcel de Rooy (1)
- Fridolin Somers (62)
- Petro Vashchuk (2)



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

Autogenerated release notes updated last on 26 Apr 2021 19:42:03.
