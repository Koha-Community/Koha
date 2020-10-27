# RELEASE NOTES FOR KOHA 19.11.11
27 Oct 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.11 is a security and bugfix/maintenance release.

It includes 2 security fixes, 15 bugfixes.

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

## Koha security

- [[26562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26562) Searches are shared between sessions
- [[26592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26592) XSS vulnerability when ysearch is used

## Critical bugs fixed

### Architecture, internals, and plumbing

- [[26434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26434) Plugin dirs duplicates in @INC with plack

### Circulation

- [[26510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26510) Transport Cost Matrix editor doesn't show all data when HoldsQueueSkipClosed is enabled

### Hold requests

- [[18958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18958) If patron has multiple record level holds on one record transferring first hold causes next hold to become item level

### MARC Authority data support

- [[25273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25273) Elasticsearch Authority matching is returning too many results

### MARC Bibliographic record staging/import

- [[26231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26231) bulkmarcimport.pl does not import authority if it already has a 001 field

### Notices

- [[26420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26420) Overdue notices script does not care about borrower's language, always takes default template


## Other bugs fixed

### Acquisitions

- [[10921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10921) You can edit an order even when it is in a closed basket

### Architecture, internals, and plumbing

- [[26260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26260) elasticsearch>cnx_pool missing in koha-conf-site.xml.in
- [[26511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26511) [19.11] PatronSelfRegistrationConfirmEmail preference shows

### Cataloging

- [[24780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24780) 952$i stocknumber does not display in batch item modification

### Circulation

- [[26224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26224) Prevent double submit of header checkin form

### Lists

- [[25913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25913) Internal server error when calling get_coins on record with no title (245) but with 880 linked to 245

### OPAC

- [[20783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20783) Cannot embed some YouTube videos due to 403 errors

### Templates

- [[26049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26049) Replace li with span class results_summary in UNIMARC intranet XSLT

### Tools

- [[26414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26414) Unable to export Withdrawn status using CSV profile

  >This patch fixes the export of MARC records and the withdrawn status when using CSV profiles. Before this fix the full 952 field was exported, rather than just the withdrawn status.


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.3%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (55.9%)
- Catalan; Valencian (50.7%)
- Chinese (China) (57.1%)
- Chinese (Taiwan) (98.8%)
- Czech (91.1%)
- English (New Zealand) (78.6%)
- English (USA)
- Finnish (74.5%)
- French (97%)
- French (Canada) (94.1%)
- German (100%)
- German (Switzerland) (81.1%)
- Greek (71.3%)
- Hindi (100%)
- Italian (86.3%)
- Nederlands-Nederland (Dutch-The Netherlands) (68.4%)
- Norwegian Bokmål (83.6%)
- Occitan (post 1500) (53.2%)
- Polish (78.7%)
- Portuguese (99.7%)
- Portuguese (Brazil) (99.7%)
- Slovak (83.3%)
- Spanish (100%)
- Swedish (85.3%)
- Telugu (93.5%)
- Turkish (100%)
- Ukrainian (74.7%)
- Vietnamese (51.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.11 is


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

We thank the following individuals who contributed patches to Koha 19.11.11.

- Aleisha Amohia (5)
- Nick Clemens (6)
- David Cook (1)
- Jonathan Druart (11)
- Katrin Fischer (2)
- Lucas Gass (2)
- Kyle Hall (1)
- Alexis Ripetti (1)
- Fridolin Somers (2)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.11

- BibLibre (2)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (9)
- Independant Individuals (5)
- Koha Community Developers (11)
- Prosentient Systems (1)
- Solutions inLibro inc (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (23)
- Tomás Cohen Arazi (3)
- Henry Bolshaw (1)
- Nick Clemens (1)
- Jonathan Druart (18)
- Bouzid Fergani (1)
- Katrin Fischer (11)
- Andrew Fuerste-Henry (4)
- Bonnie Gardner (1)
- Lucas Gass (19)
- Victor Grousset (1)
- Kyle Hall (3)
- Heather Hernandez (1)
- Joonas Kylmälä (1)
- Hayley Mapley (3)
- Julian Maurice (1)
- Kelly McElligott (2)
- David Nind (3)
- Martin Renvoize (5)
- Marcel de Rooy (5)
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
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Oct 2020 19:50:11.
