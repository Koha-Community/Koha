# RELEASE NOTES FOR KOHA 17.11.13
21 déc. 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.13 is a bugfix/maintenance release.

It includes 1 new features, 1 enhancements, 39 bugfixes.



## New features

### REST api

- [[21116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21116) Add API routes through plugins

> Allows the extension of the Koha API via plugins. This can allow for custom vendor integrations and prototyping of new routes.



## Enhancements

### Architecture, internals, and plumbing

- [[20968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20968) Plugins: Add hooks to enable plugin integration into catalogue

> Sponsored by PTFS Europe




## Critical bugs fixed

### Acquisitions

- [[21282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21282) Ordered/spent lists should use prices including tax for calculations

> Corrects the prices shown on the ordered/spent lists for each fund in acquisitions to show the price with taxes included. This will make the total shown on these pages match the total shown in the table on the acq start and fund pages.


- [[21853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21853) Internal software error when exporting basket group as PDF with Perl > 5.24.1

### Architecture, internals, and plumbing

- [[21955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21955) Cache::Memory should not be used as L2 cache

> Cache::Memory fails to work correctly under a plack environment as the cache cannot be shared between processes.




## Other bugs fixed

### About

- [[17597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17597) Outdated translation credits
- [[20720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20720) Add libraries (sponsors) to the about page

### Architecture, internals, and plumbing

- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[18720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18720) Get rid of "die" in favor of exceptions in C4::Acquisition::GetBasketAsCsv
- [[21867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21867) Replace remaining document.element.onchange calls in marc_modification_templates.js

### Cataloging

- [[20592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20592) updateitem.pl causes database errors when empty non-public item notes updated
- [[21556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21556) Deleting same record twice leads to fatal software error
- [[21666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21666) Advanced editor search- error is given for 'Unsupported Use attribute' when searching on title + author

### Circulation

- [[18677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18677) issue_id is not added to accountlines for lost item fees
- [[20598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20598) Accruing fines not closed out by longoverdue.pl if WhenLostForgiveFine is not enabled

### Command-line Utilities

- [[21640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21640) Itivia outbound script doesn't print to STDOUT
- [[21698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21698) FIX POD of cancel_unfilled_holds.pl

### Course reserves

- [[21349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21349) Instructors with special characters (e.g. $, ., :) in their cardnumber cannot be removed from course reserves

### Database

- [[21015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21015) Members.pm slow because it loads twice Koha::Schema

### ILL

- [[21497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21497) Dates should be correctly formatted for ILL requests in OPAC
- [[21585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21585) Missing firstnames should be gracefully ignored in ILL requests table

### Installation and upgrade (command-line installer)

- [[21654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21654) Installer is loading a non-existent file

### Lists

- [[21629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21629) List sort on call number does not use cn_sort

> With this patch lists sorted on call number will now use the machine sortable form of the callnumber from items.cn_sort for better results.


- [[21874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21874) Encoding broken in list and cart email subjects

### MARC Authority data support

- [[21581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21581) Matching rules for authorities do not respect 'Search index' setting
- [[21644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21644) UNIMARC XSLT display of 210 in intranet

### Packaging

- [[20952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20952) Automatic debian/control updates (oldoldstable/17.11.x)

### Patrons

- [[21080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21080) patron attribute classes break patron's edit view
- [[21634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21634) "Circulation" option is lost when viewing patron's logs

### Reports

- [[21005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21005) Missing row/column defaults cause unexpected results in report wizards
- [[21837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21837) Overdues report shoudln't set homebranchfilter as holdingbranchfilter

### System Administration

- [[21625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21625) Fix wording and typo in SMSSendDriver system preference description
- [[21730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21730) PA_CLASS missing from list of authorized values categories

### Templates

- [[10442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10442) Remove references to non-standard "error" class
- [[21186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21186) Incorrect Bootstrap modal event name in multiple templates
- [[21740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21740) Fixed-length fields show _ instead of @ when editing subfields

### Test Suite

- [[18959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18959) Text_CSV_Various.t must skip if Text::CSV::Unicode is not installed
- [[21787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21787) GetHardDueDate.t has a silly test

### Tools

- [[21819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21819) Marc modification templates action always checks Regexp checkbox
- [[21854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21854) Patron category is not showing during batch modification
- [[21861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21861) The MARC modification template actions editor does not always validate user input



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.1%)
- Armenian (100%)
- Basque (75.1%)
- Chinese (China) (79.5%)
- Chinese (Taiwan) (99.4%)
- Czech (93.8%)
- Danish (65.5%)
- English (New Zealand) (99.1%)
- English (USA)
- Finnish (95.3%)
- French (98.6%)
- French (Canada) (91.8%)
- German (100%)
- German (Switzerland) (99.1%)
- Greek (82.6%)
- Hindi (99.7%)
- Italian (99.5%)
- Norwegian Bokmål (54.3%)
- Occitan (post 1500) (72.6%)
- Persian (54.7%)
- Polish (97.2%)
- Portuguese (99.7%)
- Portuguese (Brazil) (84.2%)
- Slovak (96.3%)
- Spanish (99.7%)
- Swedish (91.4%)
- Turkish (99.7%)
- Vietnamese (67.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.13 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - Josef Moravec
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Ere Maijala
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
- Bug Wranglers:
  - Luis Moises Rojas
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager: Caroline Cyr La Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)

- Wiki curators: 
  - Caroline Cyr La Rose
- Release Maintainers:
  - 18.11 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
- Release Maintainer assistants:
  - 18.05 -- [Kyle Hall](mailto:kyle@bywatersolutions.com)

## Credits

We thank the following individuals who contributed patches to Koha 17.11.13.

- Dimitris Antonakis (1)
- Tomás Cohen Arazi (5)
- Nick Clemens (6)
- David Cook (3)
- Jonathan Druart (13)
- Magnus Enger (2)
- Katrin Fischer (3)
- Kyle Hall (5)
- Andrew Isherwood (3)
- Joonas Kylmälä (1)
- Owen Leonard (4)
- Thatcher Leonard (1)
- Jesse Maseto (1)
- Julian Maurice (1)
- Josef Moravec (3)
- Martin Renvoize (3)
- Marcel de Rooy (5)
- Andreas Roussos (3)
- Fridolin Somers (8)
- Mirko Tietgen (2)
- Mark Tompsett (4)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.13

- abunchofthings.net (2)
- ACPL (4)
- BibLibre (9)
- BSZ BW (3)
- ByWater-Solutions (11)
- bywatersolution.com (1)
- debian.diman (1)
- Independant Individuals (12)
- Koha Community Developers (13)
- Libriotech (2)
- Prosentient Systems (3)
- PTFS-Europe (6)
- Rijks Museum (5)
- Theke Solutions (5)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (3)
- Alex Arnaud (2)
- Cori Lynn Arnold (4)
- Nick Clemens (65)
- Michal Denar (5)
- Devinim (1)
- Jonathan Druart (13)
- Charles Farmer (1)
- Katrin Fischer (15)
- Lucas Gass (2)
- Stephen Graham (5)
- Kyle Hall (5)
- Andrew Isherwood (5)
- Pasi Kallinen (1)
- Owen Leonard (3)
- Jesse Maseto (16)
- Julian Maurice (1)
- Josef Moravec (9)
- Martin Renvoize (55)
- Benjamin Rokseth (1)
- Marcel de Rooy (21)
- Andreas Roussos (6)
- Maryse Simard (1)
- Fridolin Somers (70)
- Myka Kennedy Stephens (1)
- Pierre-Marc Thibault (4)
- Mirko Tietgen (2)
- Mark Tompsett (9)

We thank the following individuals who mentored new contributors to the Koha project.

- Owen Leonard


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

Autogenerated release notes updated last on 21 déc. 2018 08:27:15.
