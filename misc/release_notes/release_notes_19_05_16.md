# RELEASE NOTES FOR KOHA 19.05.16
27 Oct 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.16 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.16 is a bugfix/maintenance release with security fixes.

It includes 2 security fixes, 9 bugfixes.

### System requirements

- Debian 8 (Jessie) is not supported anymore
- MySQL 5.5 is not supported anymore

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian 9 (Stretch) with MariaDB 10.1 (and experimental MariaDB 10.3 support)
- Ubuntu 18.04 (Bionic) with MariaDB 10.1

Additional notes:
    
- Perl >= 5.14 is required and 5.24 or 5.26 are recommended
- Zebra or Elasticsearch is required


## Security bugs

### Koha

- [[26562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26562) Searches are shared between sessions
- [[26592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26592) XSS vulnerability when ysearch is used




## Critical bugs fixed

### Architecture, internals, and plumbing

- [[26434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26434) Plugin dirs duplicates in @INC with plack

### Circulation

- [[26510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26510) Transport Cost Matrix editor doesn't show all data when HoldsQueueSkipClosed is enabled

### MARC Bibliographic record staging/import

- [[26231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26231) bulkmarcimport.pl does not import authority if it already has a 001 field

### Notices

- [[26420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26420) Overdue notices script does not care about borrower's language, always takes default template


## Other bugs fixed

### Architecture, internals, and plumbing

- [[26511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26511) [19.11] PatronSelfRegistrationConfirmEmail preference shows

### Circulation

- [[23129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23129) Items holdingbranch should be set to the originating library when generating a transfer

### OPAC

- [[20783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20783) Cannot embed some YouTube videos due to 403 errors

### Templates

- [[25762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25762) Typo in linkitem.tt
- [[26049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26049) Replace li with span class results_summary in UNIMARC intranet XSLT


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

- Arabic (98.6%)
- Armenian (100%)
- Armenian (Classical) (99.9%)
- Basque (59.2%)
- Chinese (China) (59.7%)
- Chinese (Taiwan) (99.3%)
- Czech (92.8%)
- Danish (52%)
- English (New Zealand) (82.7%)
- English (USA)
- Finnish (79%)
- French (99.1%)
- French (Canada) (98.9%)
- German (100%)
- German (Switzerland) (85.7%)
- Greek (73.7%)
- Hindi (100%)
- Italian (90.2%)
- Norwegian Bokmål (88.3%)
- Occitan (post 1500) (55.9%)
- Polish (82.7%)
- Portuguese (99.8%)
- Portuguese (Brazil) (94.1%)
- Slovak (86.5%)
- Spanish (99.9%)
- Swedish (87.8%)
- Turkish (100%)
- Ukrainian (73.7%)
- Vietnamese (50.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.16 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Marcel de Rooy
  - Joonas Kylmälä
  - Josef Moravec
  - Tomás Cohen Arazi
  - Nick Clemens
  - Kyle Hall
  - Martin Renvoize
  - Alex Arnaud
  - Julian Maurice
  - Matthias Meusburger

- Topic Experts:
  - Elasticsearch -- Frédéric Demians
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize
  - CAS/Shibboleth -- Matthias Meusburger

- Bug Wranglers:
  - Michal Denár
  - Holly Cooper
  - Henry Bolshaw
  - Lisette Scheer
  - Mengü Yazıcıoğlu

- Packaging Manager: Mason James


- Documentation Managers:
  - Caroline Cyr La Rose
  - David Nind

- Documentation Team:
  - Martin Renvoize
  - Donna Bachowski
  - Lucy Vaux-Harvey
  - Kelly McElligott
  - Jessica Zairo
  - Chris Cormack
  - Henry Bolshaw
  - Jon Drucker

- Translation Manager: Bernardo González Kriegel


- Release Maintainers:
  - 20.05 -- Lucas Gass
  - 19.11 -- Aleisha Amohia
  - 19.05 -- Victor Grousset

- Release Maintainer mentors:
  - 19.11 -- Hayley Mapley
  - 19.05 -- Martin Renvoize

## Credits

We thank the following individuals who contributed patches to Koha 19.05.16.

- Aleisha Amohia (1)
- Nick Clemens (2)
- David Cook (1)
- Jonathan Druart (6)
- Lucas Gass (1)
- Victor Grousset (3)
- Kyle Hall (1)
- Mason James (1)
- Owen Leonard (1)
- Martin Renvoize (1)
- Fridolin Somers (3)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.16

- Athens County Public Libraries (1)
- BibLibre (3)
- ByWater-Solutions (4)
- Independant Individuals (1)
- Koha Community Developers (9)
- KohaAloha (1)
- Prosentient Systems (1)
- PTFS-Europe (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (8)
- Tomás Cohen Arazi (3)
- Nick Clemens (1)
- Jonathan Druart (7)
- Bouzid Fergani (2)
- Katrin Fischer (8)
- Lucas Gass (7)
- Claire Gravely (2)
- Victor Grousset (18)
- Kyle Hall (3)
- Sally Healey (1)
- Hayley Mapley (3)
- Julian Maurice (1)
- Kelly McElligott (2)
- David Nind (1)
- Martin Renvoize (6)
- Lisette Scheer (1)
- Jessica Zairo (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Oct 2020 20:58:26.
