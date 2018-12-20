# RELEASE NOTES FOR KOHA 18.11.01
20 Dec 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.01 is a bugfix/maintenance release.

It includes 1 enhancement and 35 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[21896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21896) Add Koha::Account::reconcile_balance

> Adds a business logic level routine for reconciling user account balances.




## Critical bugs fixed

### Architecture, internals, and plumbing

- [[21910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21910) Koha::Library::Groups->get_search_groups should return the groups, not the children
- [[21955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21955) Cache::Memory should not be used as L2 cache

> Cache::Memory fails to work correctly under a plack environment as the cache cannot be shared between processes.



### Authentication

- [[21973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21973) CAS URL escaped twice, preventing login

### Cataloging

- [[21986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21986) Quotation marks are wrongly escaped in several places

### Circulation

- [[18805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18805) Currently it is impossible to apply credits against debits in patron accounts

> This patch adds an `Apply Credits` button to the accounts interface to allow a librarian to apply outstanding credits against outstanding debits.


- [[21065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21065) Data in account_offsets and accountlines is deleted with the patron leaving gaps in financial reports

### Database

- [[21931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21931) Upgrade from 3.22 fails when running updatedatabase.pl script

### Hold requests

- [[21608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21608) Arranging holds priority with dropdowns is faulty when there are waiting/intransit holds

### I18N/L10N

- [[21895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21895) Translations fail on upgrade to 18.11.00 (package installation)

### Installation and upgrade (web-based installer)

- [[22024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22024) Update translated web installer files with new class splitting rules

### MARC Authority data support

- [[21962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21962) The `searching entire record` option in authority searches is currently failing

### OPAC

- [[21911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21911) Scoping OPACs by branch does not work with new library groups
- [[21950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21950) Searching with 'accents' breaks on navigating to the second page of results

### Patrons

- [[21778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21778) Sorting is inconsistent on patron search based on permissions

### Reports

- [[21984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21984) Unable to load second page of results for reports with reused parameters
- [[21991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21991) Displaying more rows on report results does not work for reports with parameters

### Searching - Elasticsearch

- [[20261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20261) No result in some page in authority search opac and pro (ES)

### Staff Client

- [[21405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21405) Pagination in authorities search broken for Zebra and broken for 10000+ results in ES

### Test Suite

- [[21956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21956) Sysprefs not reset by regressions.t


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Architecture, internals, and plumbing

- [[21759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21759) Avoid manually setting amountoutstanding in _FixAccountForLostAndReturned

> This patch results in a proper offset always being recorded for auditing purposes when a user is refunded after returning a previously lost item.


- [[21848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21848) Resolve unac_string warning from Circulation.t
- [[21905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21905) Plugin hook intranet_catalog_biblio_enhancements_toolbar_button incorrectly filtered
- [[21969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21969) Koha::Account->outstanding_* should look for debits/credits by checking 'amount'

### Command-line Utilities

- [[21908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21908) biblio_metadata is missing from the rebuild_zebra.pl tables list

### Fines and fees

- [[21849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21849) Offsets not stored correctly in _FixOverduesOnReturn

### I18N/L10N

- [[21736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21736) Localization widget messages are not translatable

### MARC Authority data support

- [[21880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21880) "Relationship information" disappears when accessing paginated results in authority searches

### OPAC

- [[21947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21947) Filtering order generates html in notes

### Packaging

- [[21897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21897) Typo in postinst affecting zebra configuration file installation

### System Administration

- [[21961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21961) Typo in permission keeps Did you mean? config from showing up

### Test Suite

- [[14334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14334) DBI fighting DBIx over Autocommit in tests

### Tools

- [[21465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21465) Cannot overlay patrons when matching by cardnumber if userid exists in file and in Koha
- [[21861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21861) The MARC modification template actions editor does not always validate user input
- [[22022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22022) Authorised values on the batch item modification page are not displayed in order (order by code, not lib)



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

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (93.2%)
- Armenian (99.1%)
- Basque (63.9%)
- Chinese (China) (64.6%)
- Chinese (Taiwan) (96.2%)
- Czech (92.5%)
- Danish (56.1%)
- English (New Zealand) (89.2%)
- English (USA)
- Finnish (84.7%)
- French (95.2%)
- French (Canada) (98.1%)
- German (100%)
- German (Switzerland) (92.8%)
- Greek (76.3%)
- Hindi (94.6%)
- Italian (91.5%)
- Norwegian Bokmål (96%)
- Occitan (post 1500) (60.1%)
- Polish (86.2%)
- Portuguese (99.1%)
- Portuguese (Brazil) (77.7%)
- Slovak (87.3%)
- Spanish (93.2%)
- Swedish (91.5%)
- Turkish (97.9%)
- Ukrainian (60.5%)
- Vietnamese (53.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.01 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - Josef Moravec
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Ere Maijala
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
- Bug Wranglers:
  - Luis Moises Rojas
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager: Caroline Cyr La Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)

- Wiki curators: 
  - Caroline Cyr La Rose
- Release Maintainers:
  - 18.11 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
- Release Maintainer assistants:
  - 18.05 -- [Kyle Hall](mailto:kyle@bywatersolutions.com)

## Credits

We thank the following individuals who contributed patches to Koha 18.11.01.

- Tomás Cohen Arazi (9)
- Nick Clemens (17)
- Jonathan Druart (13)
- Katrin Fischer (3)
- Kyle Hall (3)
- Pasi Kallinen (1)
- Julian Maurice (3)
- Josef Moravec (1)
- Martin Renvoize (3)
- Marcel de Rooy (4)
- Andreas Roussos (3)
- Fridolin Somers (3)
- Mirko Tietgen (1)
- Mark Tompsett (2)
- Koha translators (1)
- Nazlı Çetin (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.01

- abunchofthings.net (1)
- BibLibre (6)
- BSZ BW (3)
- ByWater-Solutions (20)
- Devinim (1)
- Independant Individuals (6)
- Koha Community Developers (13)
- PTFS-Europe (3)
- Rijks Museum (4)
- The City of Joensuu (1)
- Theke Solutions (9)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (5)
- Christopher Brannon (3)
- Nick Clemens (66)
- Devinim (1)
- Jonathan Druart (16)
- Lucas Gass (1)
- Kyle Hall (7)
- Pasi Kallinen (1)
- Owen Leonard (6)
- Ere Maijala (1)
- Julian Maurice (5)
- Josef Moravec (4)
- Martin Renvoize (93)
- Marcel de Rooy (19)
- Pierre-Marc Thibault (4)
- Mirko Tietgen (2)
- Mark Tompsett (3)



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

Autogenerated release notes updated last on 20 Dec 2018 12:12:58.
