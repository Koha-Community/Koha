# RELEASE NOTES FOR KOHA 17.05.14
05 oct. 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.14 is a bugfix/maintenance release.
Important /!\ It should be last 17.05.x release, please consider upgrading.

It includes 14 bugfixes.






## Critical bugs fixed

### Acquisitions

- [[20014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20014) When adding to basket from a staged file item budgets are selected by matching on code, not id
- [[20972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20972) If ISBN has 10 numbers only the first 9 numbers are used

### Authentication

- [[18947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18947) Unexpected Active Directory LDAP authentication failure mode
- [[20879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20879) Shibboleth in combination with LDAP as an alternative no longer works

### Command-line Utilities

- [[20811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20811) Fix wrong usage of ModBiblio in bulkmarcimport.pl

### Database

- [[20773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20773) bug 20724 follow-up - Database cleanup

### Hold requests

- [[20724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20724) ReservesNeedReturns syspref breaks "Holds awaiting pickup"

### OPAC

- [[21018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21018) OPAC Resource URL Broken if Tracklinks is enabled

### Packaging

- [[20693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20693) Plack fails, because 'libcgi-emulate-psgi-perl' package is not installed

### Patrons

- [[20903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20903) Print payment receipt on child patron could end with server error
- [[20951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20951) Koha::Patron::Discharge is missing use Koha::Patron::Debarments

### Self checkout

- [[21054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21054) Extra closing body tag in sco-main.tt prevents slip printing

### Web services

- [[21199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21199) Patron's attributes are displayed on GetPatronInfo's ILSDI output regardless opac_display


## Other bugs fixed

### Web services

- [[21226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21226) Remove use of retired OCLC xISBN service

> OCLC has now discontinued support for the xisbn service.  One can continue to use the functionality that this service provided to Koha by switching on the ThingISBN preferences as an alternative.





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

- [Koha Manual](http://koha-community.org/manual/17.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.2%)
- Armenian (100%)
- Basque (78.7%)
- Chinese (China) (83.3%)
- Chinese (Taiwan) (99.8%)
- Czech (94.6%)
- Danish (68.8%)
- English (New Zealand) (90.6%)
- English (USA)
- Finnish (99.7%)
- French (96.2%)
- French (Canada) (94.5%)
- German (100%)
- German (Switzerland) (99.8%)
- Greek (81.5%)
- Hindi (100%)
- Italian (100%)
- Korean (50.2%)
- Norwegian Bokmål (57.4%)
- Occitan (post 1500) (76.3%)
- Persian (57.4%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (84.4%)
- Slovak (89.7%)
- Spanish (100%)
- Swedish (95.6%)
- Turkish (100%)
- Vietnamese (70.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.05.14 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- Release Manager assistant: [Nick Clemens](mailto:nick@bywatersolutions.com)

- QA Team:
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - Claire Gravely
  - Josef Moravec
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.05.14:

- Gothenburg University Library

We thank the following individuals who contributed patches to Koha 17.05.14.

- xljoha (1)
- Colin Campbell (1)
- Nick Clemens (6)
- Marcel de Rooy (4)
- Jonathan Druart (8)
- Kyle M Hall (1)
- Josef Moravec (1)
- Martin Renvoize (2)
- Fridolin Somers (2)
- Mirko Tietgen (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.14

- abunchofthings.net (4)
- BibLibre (2)
- bugs.koha-community.org (8)
- ByWater-Solutions (6)
- bywatetsolutions.com (1)
- Göteborgs universitet (1)
- PTFS-Europe (3)
- Rijksmuseum (4)
- unidentified (1)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan A Gallagher (1)
- Colin Campbell (1)
- Nick Clemens (19)
- Tomas Cohen Arazi (2)
- Chris Cormack (3)
- Marcel de Rooy (8)
- Jonathan Druart (8)
- Katrin Fischer (9)
- Victor Grousset (5)
- Kyle M Hall (2)
- Martin Renvoize (27)
- Fridolin Somers (55)
- Mirko Tietgen (2)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 05 oct. 2018 07:09:13.
