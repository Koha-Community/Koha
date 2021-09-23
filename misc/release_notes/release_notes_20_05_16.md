# RELEASE NOTES FOR KOHA 20.05.16
23 Sep 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 20.05.16 can be downloaded from:

- [Download](https://download.koha-community.org/koha-20.05.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.16 is a bugfix/maintenance release with security fixes.

It includes 6 security fixes, 1 enhancements, 3 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations


## Security bugs

### Koha

- [[28759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28759) Users with pretty basic staff interface permissions can see/add/remove API keys of any other user
- [[28772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28772) Any user that can work with reports can see API keys of any other user
- [[28929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28929) No filtering on borrowers.flags on member entry pages (OPAC, self registration, staff interface)
- [[28935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28935) No filtering on patron's data on member entry pages (OPAC, self registration, staff interface)
- [[28941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28941) No filtering on suggestion at the OPAC
- [[28947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28947) OPAC user can create new users


## Enhancements

### OPAC

- [[26847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26847) Make borrower category code accessible in all pages of the OPAC


## Critical bugs fixed

### OPAC

- [[28885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28885) OpacBrowseResults can cause errors with bad search indexes


## Other bugs fixed

### Staff Client

- [[28722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28722) tools/batchMod.pl needs to import C4::Auth::haspermission
- [[28802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28802) Untranslatable strings in browser.js



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.05/ar/html/) (43.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.05/zh_TW/html/) (100%)
- [Czech](https://koha-community.org/manual/20.05/cs/html/) (33.1%)
- [English (USA)](https://koha-community.org/manual/20.05/en/html/)
- [French](https://koha-community.org/manual/20.05/fr/html/) (70%)
- [French (Canada)](https://koha-community.org/manual/20.05/fr_CA/html/) (31.2%)
- [German](https://koha-community.org/manual/20.05/de/html/) (72.3%)
- [Hindi](https://koha-community.org/manual/20.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/20.05/it/html/) (78.9%)
- [Spanish](https://koha-community.org/manual/20.05/es/html/) (58.5%)
- [Turkish](https://koha-community.org/manual/20.05/tr/html/) (70.2%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.2%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (93.9%)
- Czech (80.6%)
- English (New Zealand) (66.6%)
- English (USA)
- Finnish (70.3%)
- French (86.6%)
- French (Canada) (96.9%)
- German (100%)
- German (Switzerland) (74.3%)
- Greek (62.6%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (70.9%)
- Polish (79.5%)
- Portuguese (87.8%)
- Portuguese (Brazil) (97.7%)
- Russian (86.1%)
- Slovak (89.3%)
- Spanish (99.6%)
- Swedish (79.2%)
- Telugu (100%)
- Turkish (100%)
- Ukrainian (66.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.16 is


- Release Manager: 

## Credits

We thank the following individuals who contributed patches to Koha 20.05.16

- Tomás Cohen Arazi (8)
- Nick Clemens (1)
- Jonathan Druart (8)
- Victor Grousset (4)
- Kyle M Hall (1)
- Martin Renvoize (2)
- Marcel de Rooy (2)
- Fridolin Somers (1)
- Koha translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.16

- BibLibre (1)
- ByWater-Solutions (2)
- Independant Individuals (1)
- Koha Community Developers (12)
- PTFS-Europe (2)
- Rijks Museum (2)
- Theke Solutions (8)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (2)
- Nick Clemens (5)
- Jonathan Druart (5)
- Lucas Gass (2)
- Victor Grousset (26)
- Kyle M Hall (5)
- Joonas Kylmälä (1)
- Owen Leonard (2)
- Julian Maurice (1)
- David Nind (1)
- Martin Renvoize (5)
- Marcel de Rooy (12)
- Fridolin Somers (5)
- Wainui Witika-Park (9)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 20.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Sep 2021 22:39:31.
