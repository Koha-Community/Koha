# RELEASE NOTES FOR KOHA 17.05.10
27 mars 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.10 is a bugfix/maintenance release.

It includes 1 enhancements, 13 bugfixes.




## Enhancements

### Staff Client

- [[19806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19806) Add class to items.itemnotes_nonpublic


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[20145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20145) borrowers.datexpiry eq '0000-00-00' means expired?

### Course reserves

- [[20276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20276) GetCourseItem is using the wrong call  to get itemnumber

### Hold requests

- [[20167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20167) Item hold is set to bibliographic hold when changing pickup location

### OPAC

- [[20218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20218) Tracklinks fails when URL has special characters


## Other bugs fixed

### Acquisitions

- [[20148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20148) Don't allow adding same user multiple times to a basket or an order

### Circulation

- [[19530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19530) Prevent multiple transfers from existing for one item

### Command-line Utilities

- [[19452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19452) The -truncate option in borrowers-force-messaging-defaults.pl should not remove category preferences

### Patrons

- [[20367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20367) userid resets to firstname.surname when BorrowerUnwantedField contains userid

### Test Suite

- [[19529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19529) NoIssuesChargeGuarantees.t is failing randomly
- [[19979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19979) Search.t fails on facet info with one branch
- [[20250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20250) NoIssuesChargeGuarantees.t is still failing randomly
- [[20466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20466) Incorrect fixtures for active currency in t/Prices.t

### Tools

- [[20098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20098) Inventory: CSV export: itemlost column is always empty



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook.The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://manual.koha-community.org//en/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- English (USA)
- Arabic (99%)
- Armenian (100%)
- Basque (79%)
- Chinese (China) (83%)
- Chinese (Taiwan) (99%)
- Czech (94%)
- Danish (69%)
- English (New Zealand) (91%)
- Finnish (99%)
- French (96%)
- French (Canada) (94%)
- German (99%)
- German (Switzerland) (99%)
- Greek (79%)
- Hindi (99%)
- Italian (99%)
- Norwegian Bokmål (57%)
- Occitan (76%)
- Persian (57%)
- Polish (99%)
- Portuguese (100%)
- Portuguese (Brazil) (84%)
- Slovak (90%)
- Spanish (100%)
- Swedish (96%)
- Turkish (100%)
- Vietnamese (71%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.05.10 is

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
  - 16.11 -- [Chris Cormack](mailto:chris@bigballofwax.co.nz)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.05.10:


We thank the following individuals who contributed patches to Koha 17.05.10.

- Nick Clemens (2)
- Tomás Cohen Arazi (2)
- Marcel de Rooy (2)
- Jonathan Druart (6)
- Victor Grousset (1)
- Pasi Kallinen (1)
- Kyle M Hall (2)
- Andreas Roussos (1)
- Fridolin Somers (2)
- Lari Taskula (1)
- Mark Tompsett (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.10

- BibLibre (3)
- bugs.koha-community.org (6)
- ByWater-Solutions (3)
- bywatetsolutions.com (1)
- jns.fi (1)
- joensuu.fi (1)
- Rijksmuseum (2)
- Theke Solutions (2)
- unidentified (3)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan Gallagher (1)
- Charles Farmer (1)
- Claire Gravely (3)
- Fridolin Somers (22)
- Jonathan Druart (16)
- Josef Moravec (6)
- Katrin Fischer (5)
- Maksim Sen (1)
- Mark Tompsett (4)
- Nick Clemens (17)
- Owen Leonard (1)
- Pasi Kallinen (1)
- Roch D'Amour (2)
- Kyle M Hall (1)
- Marcel de Rooy (5)


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

Autogenerated release notes updated last on 27 mars 2018 12:07:28.
