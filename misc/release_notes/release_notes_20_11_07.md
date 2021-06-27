# RELEASE NOTES FOR KOHA 20.11.07
27 Jun 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.11.07 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.11.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.07 is a bugfix/maintenance release with security fixes.

It includes 1 security fixes, 2 enhancements, 17 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[28409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28409) Category should be validated in opac-shelves.pl


## Enhancements

### Architecture, internals, and plumbing

- [[28386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28386) Replace dev_map.yaml from release_tools with .mailmap

### Staff Client

- [[28091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28091) Add meta tag with Koha version number to staff interface pages


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[28200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28200) Net::Netmask 1.9104-2 requires constructor change for backwards compatibility

  >The code library Koha uses for working with IP addresses has dropped support for abbreviated values in recent releases.  This is to tighten up the default security of input value's and we have opted in Koha to follow this change through into our system preferences for the same reason.
  >
  >WARNING: `koha_trusted_proxies` and `ILS-DI:AuthorizedIPs` are both affected. Please check that you are not using abbreviated IP forms for either of these cases. Example: "10.10" is much less explicit than "10.10.0.0/16" and should be avoided.

### Circulation

- [[28538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28538) Regression - Date of birth entered without correct format causes internal server error

### Fines and fees

- [[28482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28482) Floating point math prevents items from being returned

### Hold requests

- [[28503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28503) When ReservesControlBranch = "patron's home library" and Hold policy = "From home library" all holds are allowed

### I18N/L10N

- [[28419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28419) Page addorderiso2709.pl is untranslatable

### Notices

- [[28487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28487) Overdue_notices does not fall back to default language

  >Previously overdue notices exclusively used the default language, but bug 26420 changed this to the opposite - to exclusively use the language chosen by the patron.
  >
  >However, if there is no translation for the overdue notice for the language chosen by the patron then no message is sent.
  >
  >This fixes this so that if there is no translation of the overdue notice for the language chosen by the patron, then the default language notice is used.

### Packaging

- [[28364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28364) koha-z3950-responder breaks because of log4perl.conf permissions

### Searching

- [[28475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28475) Searching all headings returns no results

  **Sponsored by** *Asociación Latinoamericana de Integración*

### Tools

- [[28158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28158) Lost items not charging when marked lost from batch item modification


## Other bugs fixed

### About

- [[27495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27495) The "Accessibility advocate" role is not yet listed in the about page.
- [[28442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28442) Release team 21.11

### Cataloging

- [[28383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28383) Log in via the itemsearch URL leads to Internal Server Error

  >When trying to access the item search form in the staff interface (/cgi-bin/koha/catalogue/itemsearch.pl) when not logged in, an internal server error (error code 500) is received after entering your login details. This fixes the problem so that the item search form is displayed as expected.

### OPAC

- [[28518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28518) "Return to the last advanced search" exclude keywords if more than 3

### Patrons

- [[28350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28350) Sort by "circ note" is broken on the patron search result view

  >This fixes the patron search result page so that the results can be sorted using the 'Circ note' column. Before this fix you could not sort the results by this column.

### Self checkout

- [[28488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28488) Javascript error in self-checkout (__ is not defined)

### Templates

- [[27899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27899) Missing description for libraryNotPickupLocation on request.pl

### Tools

- [[28353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28353) Regression: Batch item deletion no longer shows which items were not removed

  >This restores and improves the messages displayed when batch deleting items (Tools > Catalog > Batch item deletion).
  >
  >The messages displayed are:
  >- "Warning, the following barcodes were not found:", followed by a list of barcodes
  >- "Warning, the following items cannot be deleted:", followed by a list of barcodes



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.4%)
- [English (USA)](https://koha-community.org/manual/20.11/en/html/)
- [French](https://koha-community.org/manual/20.11/fr/html/) (49.6%)
- [French (Canada)](https://koha-community.org/manual/20.11/fr_CA/html/) (25.9%)
- [German](https://koha-community.org/manual/20.11/de/html/) (66.8%)
- [Hindi](https://koha-community.org/manual/20.11/hi/html/) (99.9%)
- [Italian](https://koha-community.org/manual/20.11/it/html/) (50%)
- [Spanish](https://koha-community.org/manual/20.11/es/html/) (36.4%)
- [Turkish](https://koha-community.org/manual/20.11/tr/html/) (41.9%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.3%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (79.4%)
- Catalan; Valencian (54.6%)
- Chinese (Taiwan) (92.1%)
- Czech (72.9%)
- English (New Zealand) (59.5%)
- English (USA)
- Finnish (79.2%)
- French (89.5%)
- French (Canada) (90.9%)
- German (100%)
- German (Switzerland) (66.8%)
- Greek (60.6%)
- Hindi (100%)
- Italian (99.8%)
- Nederlands-Nederland (Dutch-The Netherlands) (72.7%)
- Norwegian Bokmål (63.7%)
- Polish (97.8%)
- Portuguese (88.3%)
- Portuguese (Brazil) (95.7%)
- Russian (93.8%)
- Slovak (80.5%)
- Spanish (99.2%)
- Swedish (74.8%)
- Telugu (99.8%)
- Turkish (100%)
- Ukrainian (67.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.07 is


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
  - Kyle M Hall
  - Victor Grousset
  - Andrew Nugged
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager:
  - Mason James

- Documentation Manager: David Nind


- Documentation Team:
  - Lucy Vaux-Harvey
  - David Nind

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 21.05 -- Kyle Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 20.11.07

- Asociación Latinoamericana de Integración

We thank the following individuals who contributed patches to Koha 20.11.07

- Tomás Cohen Arazi (3)
- Eden Bacani (1)
- Nick Clemens (5)
- David Cook (2)
- Jonathan Druart (30)
- Lucas Gass (1)
- Victor Grousset (3)
- Kyle M Hall (1)
- Owen Leonard (2)
- Martin Renvoize (4)
- Alexis Ripetti (1)
- Fridolin Somers (8)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.07

- Athens County Public Libraries (2)
- BibLibre (8)
- ByWater-Solutions (7)
- Independant Individuals (5)
- Koha Community Developers (29)
- Prosentient Systems (2)
- PTFS-Europe (4)
- Solutions inLibro inc (1)
- Theke Solutions (3)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (5)
- Nick Clemens (9)
- Alvaro Cornejo (1)
- Jonathan Druart (21)
- Katrin Fischer (4)
- Andrew Fuerste-Henry (1)
- Lucas Gass (1)
- Victor Grousset (11)
- Kyle M Hall (16)
- Ere Maijala (1)
- David Nind (9)
- Martin Renvoize (18)
- Fridolin Somers (47)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Jun 2021 23:41:48.
