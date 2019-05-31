# RELEASE NOTES FOR KOHA 18.05.13
31 May 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.13 is a bugfix/maintenance release.

It includes 30 bugfixes.






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[22478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22478) Cross-site scripting vulnerability in paginations
- [[22723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22723) Syntax error on confess call in Koha/MetadataRecord/Authority.pm

### Authentication

- [[22692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22692) Logging in via cardnumber circumvents account logout

### OPAC

- [[21589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21589) Series link formed from 830 field is incorrect
- [[22735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22735) Broken MARC and ISBD views
- [[22881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22881) Trying to clear search history via the navbar X doesn't clear any searches

### Patrons

- [[22715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22715) Searching for patrons with "" in the circulation note hangs patron search

### Serials

- [[22621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22621) Filters on subscription result list search the wrong column

### Templates

- [[13692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13692) Series link is only using 800a instead of 800t


## Other bugs fixed

### Acquisitions

- [[22762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22762) Collection codes not displayed on receiving

### Architecture, internals, and plumbing

- [[21036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21036) Fix a bunch of older warnings
- [[21172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21172) Warning in addbiblio.pl - Argument "01e" isn't numeric in numeric ne (!=)
- [[22542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22542) Back browser should not allow to see other patrons details (see bug 5371)
- [[22813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22813) searchResults queries the Koha::Patron object inside two nested loops

### Cataloging

- [[21709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21709) Addbiblio shows clickable tag editor icons which do nothing
- [[21937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21937) Syspref autoBarcode annual doesn't increment properly barcode in some cases

### Command-line Utilities

- [[20692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20692) koha-plack doesn't check for Include *-plack.conf line in /etc/apache2/sites-available/$INSTANCE.conf

### Installation and upgrade (web-based installer)

- [[22527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22527) Web installer links to wrong database manual when database user doesn't have required privileges

> Sponsored by Hypernova Oy


### Lists

- [[20891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20891) Lists in staff don't load when \ was used in the description

### OPAC

- [[22743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22743) OverDrive results page is missing overdrive-login include
- [[22816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22816) OPAC detail holdings table doesn't fill it's container

### Reports

- [[22090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22090) Cash register report missing data in CSV export

### Searching

- [[22154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22154) Subtype search for Format - Braille doesn't look for the right codes
- [[22787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22787) Mapping missing for ů to u in word-phrase-utf-chr

### Self checkout

- [[22739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22739) Self check in module JS breaks if  SelfCheckInTimeout  is unset

### System Administration

- [[18011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18011) Enrollment period date on patron category can be set in the past without any error/warning messages

### Templates

- [[22716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22716) Use gender-neutral pronouns in system preference descriptions

### Test Suite

- [[21671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21671) Koha/Patron/Modifications.t is failing randomly
- [[22808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22808) Move Cache.t to db_dependent

### Tools

- [[22365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22365) Warn on Log Viewer

> Sponsored by Catalyst IT




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

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.3%)
- Armenian (100%)
- Basque (72.2%)
- Chinese (China) (77.3%)
- Chinese (Taiwan) (98.3%)
- Czech (92%)
- Danish (63.3%)
- English (New Zealand) (95.1%)
- English (USA)
- Finnish (92%)
- French (98.4%)
- French (Canada) (93.6%)
- German (100%)
- German (Switzerland) (98%)
- Greek (80.4%)
- Hindi (100%)
- Italian (97%)
- Norwegian Bokmål (67.2%)
- Occitan (post 1500) (70.1%)
- Persian (52.8%)
- Polish (93.3%)
- Portuguese (100%)
- Portuguese (Brazil) (87.1%)
- Slovak (97.5%)
- Spanish (100%)
- Swedish (93.5%)
- Turkish (99.4%)
- Vietnamese (64.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.13 is

- Release Manager: Nick Clemens
- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathan Druart
- QA Manager: Katrin Fischer
- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Chris Cormack
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Martin Renvoize
  - Marcel de Rooy
- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - UI Design -- Owen Leonard
  - Elasticsearch -- Ere Maijala
- Bug Wranglers:
  - Indranil Das Gupta
  - Jon Knight
  - Luis Moises Rojas
- Packaging Manager: Mirko Tietgen
- Documentation Manager: Caroline Cyr-La-Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Wiki curators: 
  - Caroline Cyr-La-Rose
- Release Maintainers:
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 18.11 -- Martin Renvoize
  - 17.11 -- Fridolin Somers
- Release Maintainer assistants:
  - 18.05 -- Kyle Hall

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.13:

- Catalyst IT
- Hypernova Oy

We thank the following individuals who contributed patches to Koha 18.05.13.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (3)
- Nick Clemens (5)
- Frédéric Demians (2)
- Jonathan Druart (10)
- Katrin Fischer (4)
- Lucas Gass (5)
- David Gustafsson (1)
- Kyle Hall (2)
- Owen Leonard (3)
- Josef Moravec (1)
- Liz Rea (2)
- Martin Renvoize (4)
- Marcel de Rooy (5)
- Fridolin Somers (1)
- Mirko Tietgen (1)
- Mark Tompsett (1)
- Koha translators (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.13

- abunchofthings.net (1)
- ACPL (3)
- BibLibre (1)
- BSZ BW (4)
- ByWater-Solutions (12)
- f1ebe1bec408 (1)
- Independant Individuals (5)
- Koha Community Developers (10)
- PTFS-Europe (4)
- Rijks Museum (5)
- Tamil (2)
- Theke Solutions (3)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (2)
- Arthur Bousquet (1)
- Nick Clemens (33)
- Chris Cormack (8)
- Michal Denar (6)
- Jonathan Druart (3)
- Bouzid Fergani (1)
- Katrin Fischer (15)
- Lucas Gass (47)
- Claire Gravely (2)
- Kyle Hall (3)
- Owen Leonard (3)
- Hayley Mapley (1)
- Josef Moravec (1)
- Liz Rea (9)
- Martin Renvoize (54)
- Marcel de Rooy (9)
- Lisette Scheer (1)
- Pierre-Marc Thibault (1)
- Bin Wen (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1805.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 May 2019 14:40:43.
