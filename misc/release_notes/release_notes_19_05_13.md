# RELEASE NOTES FOR KOHA 19.05.13
23 Jul 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.13 is a bugfix/maintenance release.

It includes 16 bugfixes.

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






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[24986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24986) Maximum row size reached soon for borrowers and deletedborrowers

### OPAC

- [[22672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22672) Replace <i> tags with <em> AND <b> tags with <strong> in the OPAC
- [[25769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25769) Patron self modification triggers change request for date of birth to null

### Patrons

- [[25858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25858) Borrower permissions are broken by update from bug 22868


## Other bugs fixed

### Circulation

- [[25587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25587) JavaScript issue - "clear" button doesn't reset some dropdowns

### Command-line Utilities

- [[22470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22470) Missing the table name on misc/migration_tools/switch_marc21_series_info.pl

### Documentation

- [[25576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25576) ILL requests Help does not take you to the correct place in the manual

### OPAC

- [[23276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23276) Don't show tags on tag cloud when tagging is disabled

### Patrons

- [[24353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24353) [19.05] privacy_guarantor_checkouts incorrectly shows No on moremember.pl

### REST API

- [[24862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24862) Wrong behaviour on anonymous sessions

  **Sponsored by** *ByWater Solutions*

### Serials

- [[25696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25696) Test prediction pattern button is invalid HTML

### Staff Client

- [[25537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25537) Page reload at branchtransfers.pl loses destination branch

### System Administration

- [[25394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25394) Cronjob path in the AuthorityMergeLimit syspref description is wrong

  >Updates the system preference description with the correct path for the cronjob (misc/cronjobs/merge_authorities.pl).
- [[25675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25675) System preference PatronSelfRegistration incorrectly described

### Templates

- [[25615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25615) Empty select in "Holds to pull" filters

### Test Suite

- [[25623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25623) Some tests in oauth.t do not roll back


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
- Armenian (99.9%)
- Armenian (Classical) (99.9%)
- Basque (59.2%)
- Chinese (China) (59.8%)
- Chinese (Taiwan) (99.4%)
- Czech (92.7%)
- Danish (52.1%)
- English (New Zealand) (82.7%)
- English (USA)
- Finnish (79%)
- French (98.4%)
- French (Canada) (99.1%)
- German (100%)
- German (Switzerland) (85.7%)
- Greek (73.5%)
- Hindi (100%)
- Italian (90.2%)
- Norwegian Bokmål (88.4%)
- Occitan (post 1500) (55.9%)
- Polish (82.7%)
- Portuguese (100%)
- Portuguese (Brazil) (94.2%)
- Slovak (86.6%)
- Spanish (100%)
- Swedish (87.9%)
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

The release team for Koha 19.05.13 is


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
We thank the following libraries who are known to have sponsored
new features in Koha 19.05.13:

- [ByWater Solutions](https://bywatersolutions.com/)

We thank the following individuals who contributed patches to Koha 19.05.13.

- Aleisha Amohia (3)
- Tomás Cohen Arazi (3)
- David Cook (1)
- Jonathan Druart (4)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (1)
- Lucas Gass (1)
- Victor Grousset (3)
- Kyle Hall (2)
- David Roberts (1)
- Caroline Cyr La Rose (1)
- Koha Translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.13

- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (4)
- Independant Individuals (4)
- Koha Community Developers (7)
- Prosentient Systems (1)
- PTFS-Europe (1)
- Solutions inLibro inc (1)
- Theke Solutions (3)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (15)
- Tomás Cohen Arazi (1)
- Alex Arnaud (1)
- Donna Bachowski (1)
- Nick Clemens (2)
- Jonathan Druart (10)
- Katrin Fischer (6)
- Andrew Fuerste-Henry (1)
- Lucas Gass (13)
- Victor Grousset (20)
- Owen Leonard (1)
- Julian Maurice (3)
- David Nind (4)
- Martin Renvoize (5)
- Andreas Roussos (1)
- Emmi Takkinen (1)
- Timothy Alexis Vass (1)

We thank the following individuals who mentored new contributors to the Koha project.

- Andrew Nugged


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

Autogenerated release notes updated last on 23 Jul 2020 01:33:36.
