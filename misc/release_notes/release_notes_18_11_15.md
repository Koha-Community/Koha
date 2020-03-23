# RELEASE NOTES FOR KOHA 18.11.15
23 Mar 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.15 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.15 is a bugfix/maintenance release.

It includes 5 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required






## Critical bugs fixed

### Acquisitions

- [[24389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24389) Claiming an order can display an invalid successful message

### Architecture, internals, and plumbing

- [[23290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23290) XSLT system preferences allow administrators to exploit XML and XSLT vulnerabilities

  >This patchset refines the XSLT processing configuration such that we are more secure by disallowing the processing of external stylesheets by default and adding a configuration option to re-enable the functionality.

### ILL

- [[23980]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23980) [18.11] Non existent include prevents template display


## Other bugs fixed

### Hold requests

- [[21296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21296) Suspend hold ignores system preference on intranet

### Serials

- [[23064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23064) Cannot edit subscription with strict SQL modes turned on


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (97.9%)
- Armenian (100%)
- Basque (65.8%)
- Chinese (China) (63.8%)
- Chinese (Taiwan) (99.1%)
- Czech (93.8%)
- Danish (55.2%)
- English (New Zealand) (88%)
- English (USA)
- Finnish (84.1%)
- French (99.9%)
- French (Canada) (98.8%)
- German (100%)
- German (Switzerland) (91.4%)
- Greek (78.6%)
- Hindi (100%)
- Italian (93.5%)
- Norwegian Bokmål (94.3%)
- Occitan (post 1500) (59.4%)
- Polish (86.3%)
- Portuguese (100%)
- Portuguese (Brazil) (87.3%)
- Slovak (89.6%)
- Spanish (100%)
- Swedish (90.1%)
- Tetun (53.6%)
- Turkish (97.9%)
- Ukrainian (61.9%)
- Vietnamese (54.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.15 is


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

We thank the following individuals who contributed patches to Koha 18.11.15.

- Jonathan Druart (3)
- Andrew Isherwood (2)
- Owen Leonard (1)
- Hayley Mapley (1)
- Marcel de Rooy (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.15

- ACPL (1)
- Catalyst (1)
- Koha Community Developers (3)
- PTFS-Europe (2)
- Rijks Museum (1)

We also especially thank the following individuals who tested patches
for Koha.

- Nick Clemens (2)
- Katrin Fischer (2)
- Lucas Gass (3)
- Bernardo González Kriegel (2)
- Joonas Kylmälä (1)
- Hayley Mapley (8)
- Kelly McElligott (1)
- Joy Nelson (2)
- Martin Renvoize (3)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Mar 2020 20:33:58.
