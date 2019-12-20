# RELEASE NOTES FOR KOHA 18.11.12
20 Dec 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.12 is a bugfix/maintenance release.

It includes 1 enhancements, 11 bugfixes.

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

### Reports

- [[23389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23389) Add 'All' option to report value dropdowns

  >This enhancement adds the ability to optionally include an `all` option in report placeholders allowing for an 'All' option to be displayed in filter select lists.
  >
  >**Usage**: `WHERE branchcode LIKE <<Branch|branches:all>>`


## Critical bugs fixed

### Searching - Elasticsearch

- [[23089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23089) Elasticsearch - cannot sort on non-text fields


## Other bugs fixed

### Course reserves

- [[23952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23952) Fix body id on OPAC course details page

### Fines and fees

- [[23483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23483) When writing off a fine, the title of the patron is shown as description

### I18N/L10N

- [[13749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13749) On loading holds in patron account 'processing' is not translatable

### OPAC

- [[23506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23506) Sound material type displays wrong icon in OPAC/Staff details

### Patrons

- [[21939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21939) Permission for holds history tab is too strict

### Searching

- [[23768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23768) ISBN search in IntranetCatalogPulldown searches nothing if passed an invalid ISBN and using SearchWithISBNVariations
- [[24120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24120) Search terms in search dropdown must be URI filtered

### Templates

- [[23954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23954) Format notes in suggestion management

### Test Suite

- [[24145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24145) Auth.t is failing because of wrong mocked ->param
- [[24199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24199) t/Auth_with_shibboleth.t is failing randomly


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)



Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.12 is


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
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - UI Design -- Owen Leonard
  - Elasticsearch -- Fridolin Somers
  - ILS-DI -- Arthur Suzuki
  - Authentication -- Martin Renvoize
  - ILL -- Andrew Isherwood

- Bug Wranglers:
  - Michal Denár
  - Cori Lynn Arnold
  - Lisette Scheer
  - Amit Gupta

- Packaging Manager:
  - Mirko Tietgen
  - Mason James

- Documentation Manager:
  - David Nind
  - Caroline Cyr La Rose

- Documentation Team:
  - Donna Bachowski
  - Sugandha Bajaj
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey
  - David Nind

- Translation Manager:
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley
## Credits

We thank the following individuals who contributed patches to Koha 18.11.12.

- Nick Clemens (8)
- Jonathan Druart (3)
- Katrin Fischer (3)
- Lucas Gass (1)
- Owen Leonard (2)
- Ere Maijala (1)
- Hayley Mapley (2)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.12

- ACPL (2)
- BSZ BW (3)
- ByWater-Solutions (9)
- Catalyst (2)
- Koha Community Developers (3)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (2)
- Bob Bennhoff (1)
- Nick Clemens (1)
- Jonathan Druart (8)
- Katrin Fischer (4)
- Ere Maijala (2)
- Hayley Mapley (15)
- Joy Nelson (1)
- Séverine Queune (4)
- Martin Renvoize (16)
- Lisette Scheer (1)



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

Autogenerated release notes updated last on 20 Dec 2019 00:44:09.
