# RELEASE NOTES FOR KOHA 19.05.11
22 May 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.11 is a bugfix/maintenance release.

It includes 13 enhancements, 72 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required




## Enhancements

### Cataloging

- [[25231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25231) Remove alert when replacing a bibliographic record via Z39.50

### Command-line Utilities

- [[21865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21865) Add Elasticsearch support to, and improve verbose output of, `remove_unused_authorities.pl`

### Course reserves

- [[25341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25341) When adding a single item to course reserves, ignore whitespace

### Fines and fees

- [[24604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24604) Add 'Pay' button under Transactions tab in patron accounting

### Hold requests

- [[24547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24547) Add more action logs for holds

  >Trapping and filling holds will now create entries in the logs, when HoldsLog system preference is activated.

### Lists

- [[20754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20754) Db revision to remove double accepted list shares

### Reports

- [[25262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25262) [19.05.x] Cash register report truncates manual_inv values

### Searching - Elasticsearch

- [[22828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22828) Add display of errors encountered during indexing on the command line

### Staff Client

- [[23601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23601) Middle clicking a title from search results creates two tabs or a new tab and a new window in Firefox

  >This fixes an issue in Firefox where middle-clicking or CTRL-clicking a title in the results screen of the staff client opens two new tabs.
- [[24522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24522) Nothing happens when trying to add nothing to a list in staff
- [[25027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25027) Result browser should not overload onclick event
- [[25053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25053) PatronSelfRegistrationExpireTemporaryAccountsDelay system preference is unclear

### Templates

- [[22468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22468) Standardize on labeling ccode table columns as collection


## Critical bugs fixed

### Acquisitions

- [[25223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25223) Ordered.pl can have poor performance on large databases

### Cataloging

- [[25335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25335) Use of an authorised value in a marc subfield causes strict mode SQL error

### Circulation

- [[24013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24013) Transferring a checked out item gives a software error
- [[25133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25133) Specify Due date changes from PM to AM if library has their TimeFormat set to 12hr
- [[25184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25184) Items with a negative notforloan status should not be captured for holds

  >**New system preference**: `TrapHoldsOnOrder` defaults to enabled.
- [[25418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25418) Backdated check out date loses time

### ILL

- [[24043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24043) ILL module can't show requests from more than one backend

### MARC Authority data support

- [[22437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22437) Subsequent authority merges in cron may cause biblios to lose authority information

### OPAC

- [[25024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25024) OPAC incorrectly marks branch as invalid pickup location when similarly named branch is blocked

### Patrons

- [[24964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24964) Do not filter patrons AFTER they have been fetched from the DB (when searching with permissions)

### SIP2

- [[24966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24966) Fix calls to maybe_add where method call does not return a value

### Searching - Elasticsearch

- [[25342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25342) Scripts not running under plack can cause duplication of ES records

### System Administration

- [[25400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25400) Circulation and fine rules cloning from one table to another does not copy "current checkouts allowed"


## Other bugs fixed

### Acquisitions

- [[21927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21927) Acq: Allow blank values in pull downs in the item form when subfield is mandatory
- [[22778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22778) Suggestions with no "suggester" can cause errors

### Architecture, internals, and plumbing

- [[18670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18670) RewriteLog and RewriteLogLevel unavailable in Apache 2.4
- [[20370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20370) Misleading comment for bcrypt - #encrypt it; Instead it should be #hash it
- [[20882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20882) URI column in the items table is limited to 255 characters
- [[25008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25008) Koha::RecordProcessor->options doesn't refresh the filters
- [[25019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25019) Non standard initialization in ViewPolicy filter
- [[25095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25095) Remove warn left in FeePayment.pm
- [[25107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25107) Remove double passing of $server variable to maybe_add in C4::SIP::Sip::MsgType

### Cataloging

- [[11446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11446) Authority not searching full corporate name with and (&) symbol
- [[17232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17232) When creating a new framework from an old one, several fields are not copies (important, link, default value, max length, is URL)
- [[19312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19312) Typo in UNIMARC field 121a plugin
- [[25308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25308) When cataloguing search fields are prefilled from record, content after & is cut off

### Circulation

- [[13557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13557) Add hint for on-site checkouts to list of current checkouts in OPAC
- [[15751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15751) Koha offline circulation Firefox addon does not update last seen date for check-ins

### Command-line Utilities

- [[20101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20101) Cronjob automatic_item_modification_by_age.pl does not log run in action logs
- [[24266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24266) Noisy error in reconcile_balances.pl

  **Sponsored by** *Horowhenua District Council*
- [[25157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25157) delete_patrons.pl is never quiet, even when run without -v
- [[25480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25480) koha-create may hide useful error

### Course reserves

- [[24750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24750) Instructor search does not return results if a comma is included after surname or if first name is included

### Developer documentation

- [[22335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22335) Comment on column suggestions.STATUS is not complete

### Documentation

- [[25388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25388) There is no link for the "online help"

### I18N/L10N

- [[24636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24636) Acquisitions planning sections untranslatable

### Label/patron card printing

- [[23514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23514) Call numbers are not splitted in Label Creator with layout types other than Biblio

### MARC Bibliographic data support

- [[23119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23119) MARC21 added title 246, 730 subfield i should display before subfield a

### Notices

- [[24826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24826) Use of uninitialized value $mail{"Cc"} in substitution (s///) at /usr/share/perl5/Mail/Sendmail.pm

### OPAC

- [[17853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17853) MARC21: Don't remove () from link text for 780/785
- [[17938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17938) XSLT: Label of 583 is repeated for multiple tags and private notes don't display in staff

  >This fixes the display for records with multiple 583s. Previously the label "Action note" was repeated, now the label appears once and multiple fields are separated by a |. There is now a space between $z and other subfields.
  >
  >Private notes are now displayed in the staff interface.
  >
  >Notes:
  >Indicator 1 = private: These will not display in the OPAC.
  >Indicator 1 = 0 or empty: These will display in the OPAC.
  >The staff interface  will display all 583s.
- [[22515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22515) OPACViewOthersSuggestions if set to Show will only show when patron has made a suggestion
- [[24957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24957) OpenLibrarySearch shouldnt display if nothing is returned
- [[25211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25211) Missing share icon on OPAC lists page
- [[25233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25233) Staff XSLT material type label "Book" should be "Text"
- [[25274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25274) JavaScript error in OPAC cart when more details are shown

### Patrons

- [[18680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18680) sort1/sort1 dropdowns (when mapped to authorized value) have no empty entry
- [[21211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21211) Patron toolbar does not appear on all tabs in patron account in staff
- [[25046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25046) C4::Utils::DataTables::Members does not SELECT othernames from borrowers table

  **Sponsored by** *Eugenides Foundation Library*
- [[25069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25069) AddressFormat="fr" behavior is broken
- [[25299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25299) Date not showing on Details page when patron is going to expire
- [[25300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25300) Edit details in "Library use" section uses bad $op for Expiration Date

### Reports

- [[24940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24940) Serials statistics wizard: order vendor list alphabetically

### SIP2

- [[24993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24993) koha-sip --restart is too fast, doesn't always start SIP

### Searching

- [[22937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22937) Searching by library groups uses  group Title rather than Description
- [[23081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23081) Make items.issues and deleteditems.issues default to 0 instead of null

### Self checkout

- [[21565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21565) SCO checkout confirm should be modal

### Serials

- [[24903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24903) Special characters like parentheses in numbering pattern cause duplication in recievedlist

### Staff Client

- [[20501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20501) Unhighlight in search results when the search terms contain the same word twice removes the word
- [[25007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25007) AmazonCoverImages doesnt check for ISBN in details.tt

  >This fixes the display of cover images in the staff interface where there is no ISBN and both Amazon and local cover images are enabled.
  >
  >Covers different combinations:
  >- Amazon cover present, no local cover.
  >- No Amazon cover, local cover image present.
  >- Both Amazon and local cover image present.
- [[25022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25022) Display problem in authority editor with repeatable field
- [[25072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25072) Printing details.tt is broken
- [[25224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25224) Add "Large Print" from 008 position 23 to default XSLT

### System Administration

- [[10561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10561) DisplayOPACiconsXSLT and DisplayIconsXSLT descriptions should be clearer

### Templates

- [[25012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25012) Fix class on OPAC view link in staff detail page
- [[25013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25013) Fix capitalization: Edit Items on batch item edit
- [[25014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25014) Capitalization: Call Number in sort options in staff and OPAC
- [[25186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25186) Lots of white space at the bottom of each tab on columns configuration
- [[25409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25409) Required dropdown missing "required" class near label

### Tools

- [[9422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9422) Patron picture uploader ignores patronimages syspref
- [[24764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24764) TinyMCE shouldnt do automatic code cleanup when editing HTML in News Feature
- [[25247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25247) Exporting 'modification log' to a file should not send objects
## New sysprefs

- TrapHoldsOnOrder

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.7%)
- Armenian (100%)
- Basque (59.3%)
- Chinese (China) (59.9%)
- Chinese (Taiwan) (99.5%)
- Czech (92.4%)
- Danish (52.1%)
- English (New Zealand) (82.8%)
- English (USA)
- Finnish (79.1%)
- French (98.5%)
- French (Canada) (99.2%)
- German (100%)
- German (Switzerland) (85.8%)
- Greek (73.6%)
- Hindi (100%)
- Italian (90%)
- Norwegian Bokmål (88.5%)
- Occitan (post 1500) (56%)
- Polish (82.7%)
- Portuguese (99.8%)
- Portuguese (Brazil) (94.3%)
- Slovak (86.7%)
- Spanish (100%)
- Swedish (88%)
- Turkish (99.8%)
- Ukrainian (73.7%)
- Vietnamese (50.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.11 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathan Druart

- QA Manager: Katrin Fischer

- QA Team:
  - Jonathan Druart
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall

- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ILS-DI -- Arthur Suzuki
  - UI Design -- Owen Leonard
  - ILL -- Andrew Isherwood

- Bug Wranglers:
  - Michal Denár
  - Cori Lynn Arnold
  - Lisette Scheer
  - Amit Gupta

- Packaging Managers:
  - Mirko Tietgen
  - Mason James

- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Sugandha Bajaj

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley

- Release Maintainer mentors:
  - 19.11 -- Martin Renvoize
  - 19.05 -- Nick Clemens
  - 18.11 -- Chris Cormack

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.05.11:

- Eugenides Foundation Library
- Horowhenua District Council

We thank the following individuals who contributed patches to Koha 19.05.11.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (4)
- Nick Clemens (12)
- David Cook (2)
- Jonathan Druart (24)
- Katrin Fischer (14)
- Andrew Fuerste-Henry (4)
- Lucas Gass (12)
- Kyle Hall (11)
- Andrew Isherwood (1)
- Bernardo González Kriegel (2)
- Owen Leonard (7)
- Julian Maurice (1)
- Grace McKenzie (1)
- Josef Moravec (1)
- Joy Nelson (1)
- Liz Rea (1)
- Martin Renvoize (2)
- Phil Ringnalda (3)
- David Roberts (5)
- Marcel de Rooy (7)
- Andreas Roussos (1)
- Slava Shishkin (2)
- Joe Sikowitz (1)
- Fridolin Somers (4)
- Theodoros Theodoropoulos (1)
- Koha Translators (1)
- George Veranis (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.11

- Aristotle University Of Thessaloniki (Αριστοτέλειο Πανεπιστήμιο Θεσσαλονίκης) (1)
- Athens County Public Libraries (7)
- BibLibre (5)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (14)
- ByWater-Solutions (40)
- chetcolibrary.org (3)
- Dataly Tech (2)
- flo.org (1)
- Independant Individuals (8)
- Koha Community Developers (24)
- Prosentient Systems (2)
- PTFS-Europe (8)
- Rijks Museum (5)
- Theke Solutions (4)
- Universidad Nacional de Córdoba (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (1)
- Nick Clemens (7)
- David Cook (1)
- Frédéric Demians (3)
- Jonathan Druart (49)
- Bouzid Fergani (1)
- Katrin Fischer (40)
- Andrew Fuerste-Henry (2)
- Lucas Gass (121)
- Victor Grousset (3)
- Kyle Hall (6)
- Felix Hemme (1)
- Heather Hernandez (2)
- Catherine Ingram (1)
- Bernardo González Kriegel (10)
- Owen Leonard (8)
- Ere Maijala (1)
- Kelly McElligott (3)
- Josef Moravec (4)
- Joy Nelson (102)
- David Nind (22)
- Séverine Queune (1)
- Laurence Rault (3)
- Liz Rea (2)
- Martin Renvoize (111)
- Phil Ringnalda (2)
- David Roberts (6)
- Marcel de Rooy (11)
- Joel Sasse (1)
- Lisette Scheer (1)
- Fridolin Somers (3)
- Mark Tompsett (1)
- Mengü Yazıcıoğlu (2)
- Nazlı Çetin (1)

We thank the following individuals who mentored new contributors to the Koha project.

- Andrew Nugged
- Andreas Roussos
- Petro Vashchuk


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1905.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 May 2020 20:09:52.
