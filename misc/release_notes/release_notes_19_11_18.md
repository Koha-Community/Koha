# RELEASE NOTES FOR KOHA 19.11.18
25 May 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 19.11.18 can be downloaded from:

- [Download](https://download.koha-community.org/koha-19.11.18.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.18 is a bugfix/maintenance release with security fixes.

It includes 3 security fixes, 6 bugfixes.

### System requirements

You can learn about the system components (like OS and database) for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[15720]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15720) OCLC Connexion daemon does not verify username or password
- [[20982]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20982) opac-shelves.pl vulnerable to Cross-site scripting attacks
- [[27942]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27942) QOTD: quote CSV uploads may contain JavaScript payloads (XSS)




## Critical bugs fixed

### Acquisitions

- [[27203]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27203) Order unitprice is not set anymore and  totals are 0

### Architecture, internals, and plumbing

- [[28302]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28302) Koha does not work with CGI::Compile 0.24

### Cataloging

- [[24564]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24564) The adding of new subfields according to IFLA updates doesn't respect existing tab

### Circulation

- [[28064]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28064) Transits are not created at check in despite user responding 'Yes, print slip' to the prompt


## Other bugs fixed

### System Administration

- [[27968]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27968) MARC framework CSV and ODS import incomplete or corrupted

### Test Suite

- [[28249]](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28249) Selenium->wait_for_element_visible can fall in an infinite loop


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](https://koha-community.org/manual/19.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98%)
- Armenian (100%)
- Armenian (Classical) (100%)
- Basque (55.7%)
- Catalan; Valencian (50.5%)
- Chinese (China) (56.9%)
- Chinese (Taiwan) (98.6%)
- Czech (90.8%)
- English (New Zealand) (78.3%)
- English (USA)
- Finnish (74.2%)
- French (99.5%)
- French (Canada) (93.8%)
- German (100%)
- German (Switzerland) (80.8%)
- Greek (71.2%)
- Hindi (100%)
- Italian (87%)
- Nederlands-Nederland (Dutch-The Netherlands) (85.5%)
- Norwegian Bokmål (83.3%)
- Occitan (post 1500) (53%)
- Polish (85.6%)
- Portuguese (99.4%)
- Portuguese (Brazil) (100%)
- Slovak (83.1%)
- Spanish (100%)
- Swedish (85%)
- Telugu (100%)
- Turkish (100%)
- Ukrainian (75%)
- Vietnamese (51.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.18 is


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

We thank the following individuals who contributed patches to Koha 19.11.18.

- Nick Clemens (3)
- Jonathan Druart (4)
- Victor Grousset (2)
- Mason James (2)
- Julian Maurice (2)
- Martin Renvoize (2)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.18

- BibLibre (2)
- ByWater-Solutions (3)
- Koha Community Developers (6)
- KohaAloha (2)
- PTFS-Europe (2)

We also especially thank the following individuals who tested patches
for Koha.

- Marjorie Barry-Vila (1)
- Allison Blanning (1)
- Sonia Bouis (2)
- Nick Clemens (3)
- David Cook (1)
- Jonathan Druart (10)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (10)
- Victor Grousset (20)
- Kyle M Hall (1)
- Sally Healey (1)
- Marcel de Rooy (1)
- Fridolin Somers (10)
- Lyon 3 Team (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 May 2021 16:25:42.
