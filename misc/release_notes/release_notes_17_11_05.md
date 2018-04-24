# RELEASE NOTES FOR KOHA 17.11.05
24 Apr 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.05 is a bugfix/maintenance release.

It includes 4 enhancements, 28 bugfixes.




## Enhancements

### Command-line Utilities

- [[19955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19955) Add ability to process only one 'type' of message ( sms, email, etc ) for a given run of process_message_queue.pl

### I18N/L10N

- [[20295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20295) Allow translating link title in ILL module
- [[20296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20296) Untranslatable "All" in patrons table filter

### Staff Client

- [[19953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19953) Add column for invoice in acquisition details tab


## Critical bugs fixed

### Acquisitions

- [[18593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18593) Suggestions aren't updated when one biblio is merged with another

### Architecture, internals, and plumbing

- [[20229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20229) Remove problematic SQL modes

### Command-line Utilities

- [[12812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12812) Longoverdue.pl --mark-returned doesn't return items
- [[17717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17717) Fix broken cronjobs due to permissions of the current directory

### OPAC

- [[20286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20286) Subscribing to a search via rss goes to an empty page

### Patrons

- [[19908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19908) Password should not be mandatory


## Other bugs fixed

### Architecture, internals, and plumbing

- [[19739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19739) Add default ES configuration to koha-conf.xml

### Cataloging

- [[20067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20067) Wrong display of authorised value for items.materials on staff detail page
- [[20341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20341) Show authorized value description for withdrawn like damaged and lost

### Command-line Utilities

- [[11936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11936) Consistent log message for item insert
- [[20234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20234) Make maintenance scripts use koha-zebra instead of koha-*-zebra

### Database

- [[19547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19547) Maria DB doesn't have a debian.cnf

### I18N/L10N

- [[20140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20140) Allow translating more of OAI sets
- [[20141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20141) Untranslatable string in Transport cost matrix
- [[20142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20142) Allow translating offline circ message
- [[20147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20147) Allow translating prompt in label edit batch
- [[20301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20301) Allow translating "View" in manage MARC import
- [[20302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20302) Allow translating Delete button in Patron batch mod tool

### MARC Authority data support

- [[20430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20430) Z39.50 button display depends on wrong server count

### Notices

- [[18570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18570) Password recovery e-mail only sent after message queue is processed

### Serials

- [[20461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20461) New subscription form: "Item type" and "item type for older issues" fields are ignored

### System Administration

- [[20383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20383) Hide link to plugin management if plugins are not enabled

### Templates

- [[20239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20239) Fix spelling on authority linker plugin
- [[20240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20240) Remove space before : when searching for a vendor in serials (Vendor name :)
- [[20290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20290) Fix capitalization: Routing List
- [[20372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20372) Correct toolbar markup on some pages

### Test Suite

- [[20311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20311) get_age tests can fail on February 28th
- [[20474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20474) Passwordrecovery.t should mock Mail::Sendmail::sendmail

### Tools

- [[20376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20376) "Select all" button no longer selects disabled checkboxes in Batch Record Deletion Tool



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.7%)
- Armenian (100%)
- Basque (75.5%)
- Chinese (China) (79.9%)
- Chinese (Taiwan) (100%)
- Czech (94%)
- Danish (65.8%)
- English (New Zealand) (99.7%)
- English (USA)
- Finnish (95.8%)
- French (98.4%)
- French (Canada) (92.2%)
- German (99.9%)
- German (Switzerland) (99.6%)
- Greek (79.8%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (54.6%)
- Occitan (post 1500) (73%)
- Persian (54.9%)
- Polish (97.5%)
- Portuguese (100%)
- Portuguese (Brazil) (80.7%)
- Slovak (96.6%)
- Spanish (100%)
- Swedish (91.9%)
- Turkish (100%)
- Vietnamese (67.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.05 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- Release Manager assistant: [Nick Clemens](mailto:nick@bywatersolutions.com)

- QA Team:
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - Claire Gravely
  - Josef Moravec
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.05:

- Orex Digital

We thank the following individuals who contributed patches to Koha 17.11.05.

- Nick Clemens (2)
- Tomás Cohen Arazi (4)
- Marcel de Rooy (2)
- Jonathan Druart (5)
- Magnus Enger (1)
- Charles Farmer (1)
- Katrin Fischer (3)
- Victor Grousset (2)
- Pasi Kallinen (7)
- Owen Leonard (4)
- Julian Maurice (1)
- Kyle M Hall (2)
- Josef Moravec (3)
- Maksim Sen (1)
- Fridolin Somers (2)
- Mark Tompsett (7)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.05

- ACPL (4)
- BibLibre (5)
- BSZ BW (3)
- bugs.koha-community.org (5)
- ByWater-Solutions (2)
- bywatetsolutions.com (2)
- joensuu.fi (7)
- Libriotech (1)
- Rijksmuseum (2)
- Solutions inLibro inc (2)
- Theke Solutions (4)
- unidentified (10)

We also especially thank the following individuals who tested patches
for Koha.

- delaye (2)
- Hugo Agud hagud@orex.es (1)
- Hugo Agud hagud@orex.es (1)
- JM Broust (1)
- Nick Clemens (36)
- Tomas Cohen Arazi (3)
- Roch D'Amour (2)
- Marcel de Rooy (8)
- Jonathan Druart (38)
- Charles Farmer (1)
- Katrin Fischer (10)
- Brendan Gallagher (3)
- Lucie Gay (1)
- Claire Gravely (1)
- Dilan Johnpullé (1)
- Pasi Kallinen (8)
- Jesse Maseto (2)
- Julian Maurice (10)
- Kyle M Hall (4)
- Josef Moravec (7)
- Séverine QUEUNE (3)
- Maksim Sen (1)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Apr 2018 00:32:43.
