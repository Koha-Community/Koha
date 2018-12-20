# RELEASE NOTES FOR KOHA 18.05.07
20 Dec 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.07 is a bugfix/maintenance release.

It includes 28 bugfixes.






## Critical bugs fixed

### Acquisitions

- [[21853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21853) Internal software error when exporting basket group as PDF with Perl > 5.24.1

### Architecture, internals, and plumbing

- [[21869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21869) Bad update statement loses values for MarkLostItemsAsReturned
- [[21910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21910) Koha::Library::Groups->get_search_groups should return the groups, not the children
- [[21955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21955) Cache::Memory should not be used as L2 cache

> Cache::Memory fails to work correctly under a plack environment as the cache cannot be shared between processes.



### Cataloging

- [[21774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21774) Cloned item subfields disappear when editing an item

### Circulation

- [[21796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21796) Patron Restriction do not restrict checkouts if patron also has a fee/fine on their account

### MARC Authority data support

- [[21962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21962) The `searching entire record` option in authority searches is currently failing

### Notices

- [[21529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21529) Fix display of HTML tags in print notices

### OPAC

- [[805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=805) OPAC no longer offers subject search
- [[21911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21911) Scoping OPACs by branch does not work with new library groups

### Patrons

- [[21778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21778) Sorting is inconsistent on patron search based on permissions

### Staff Client

- [[21405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21405) Pagination in authorities search broken for Zebra and broken for 10000+ results in ES

### Test Suite

- [[21567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21567) WebService:ILS related tests fail during package build


## Other bugs fixed

### Architecture, internals, and plumbing

- [[21867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21867) Replace remaining document.element.onchange calls in marc_modification_templates.js
- [[21905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21905) Plugin hook intranet_catalog_biblio_enhancements_toolbar_button incorrectly filtered

### Circulation

- [[18677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18677) issue_id is not added to accountlines for lost item fees
- [[20598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20598) Accruing fines not closed out by longoverdue.pl if WhenLostForgiveFine is not enabled

### Fines and fees

- [[21849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21849) Offsets not stored correctly in _FixOverduesOnReturn

### Lists

- [[21874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21874) Encoding broken in list and cart email subjects

### MARC Authority data support

- [[21644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21644) UNIMARC XSLT display of 210 in intranet

### Packaging

- [[17111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17111) Automatic debian/control updates (oldstable/18.05.x)

### Patrons

- [[21649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21649) Add child button in the staff client is no longer automatically populating the parent address

### Reports

- [[21837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21837) Overdues report shoudln't set homebranchfilter as holdingbranchfilter

### System Administration

- [[21730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21730) PA_CLASS missing from list of authorized values categories
- [[21815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21815) Rephrase HidePersonalPatronDetailOnCirculation a little bit

### Tools

- [[21819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21819) Marc modification templates action always checks Regexp checkbox
- [[21854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21854) Patron category is not showing during batch modification
- [[21861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21861) The MARC modification template actions editor does not always validate user input



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.8%)
- Armenian (100%)
- Basque (72.6%)
- Chinese (China) (77.1%)
- Chinese (Taiwan) (98.9%)
- Czech (92.5%)
- Danish (63.7%)
- English (New Zealand) (95.6%)
- English (USA)
- Finnish (92.5%)
- French (98.9%)
- French (Canada) (94.1%)
- German (100%)
- German (Switzerland) (98.5%)
- Greek (80.4%)
- Hindi (98.8%)
- Italian (97.4%)
- Norwegian Bokmål (67.7%)
- Occitan (post 1500) (70.4%)
- Persian (53%)
- Polish (93.8%)
- Portuguese (99.9%)
- Portuguese (Brazil) (87.6%)
- Slovak (94.5%)
- Spanish (98.8%)
- Swedish (94%)
- Turkish (100%)
- Vietnamese (65.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.07 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- Release Manager assistant: [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: 

- QA Team:
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - Josef Moravec
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.11 -- [Nick Clemens](mailto:nick@bywatersolutions.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.07:


We thank the following individuals who contributed patches to Koha 18.05.07.

- Nightly Build Bot (1)
- Nick Clemens (12)
- Marcel de Rooy (8)
- Jonathan Druart (8)
- Katrin Fischer (4)
- Lucas Gass (1)
- “Lucas Gass” (3)
- Andrew Isherwood (1)
- Jesse Maseto (6)
- Julian Maurice (1)
- Kyle M Hall (6)
- Josef Moravec (1)
- Andreas Roussos (3)
- Fridolin Somers (2)
- Mirko Tietgen (1)
- Mark Tompsett (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.07

-  (0)
- abunchofthings.net (2)
- BibLibre (3)
- BSZ BW (4)
- bugs.koha-community.org (8)
- ByWater-Solutions (20)
- bywatersolution.com (6)
- bywatetsolutions.com (1)
- Lucass-MacBook-Pro.local (1)
- PTFS-Europe (1)
- Rijksmuseum (8)
- unidentified (5)

We also especially thank the following individuals who tested patches
for Koha.

- Devinim (2)
- Nick Clemens (47)
- Tomas Cohen Arazi (5)
- Michal Denar (3)
- Marcel de Rooy (35)
- Jonathan Druart (5)
- Katrin Fischer (2)
- Lucas Gass (4)
- “Lucas Gass” (3)
- Andrew Isherwood (1)
- Pasi Kallinen (1)
- Owen Leonard (4)
- Ere Maijala (1)
- Jesse Maseto (32)
- Julian Maurice (1)
- Josef Moravec (3)
- Martin Renvoize (25)
- Andreas Roussos (5)
- Maryse Simard (1)
- Fridolin Somers (2)
- Pierre-Marc Thibault (4)
- Mirko Tietgen (1)
- Mark Tompsett (2)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1805.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 20 Dec 2018 14:49:52.
