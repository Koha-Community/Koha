# RELEASE NOTES FOR KOHA 16.11.06
27 Mar 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.06 is a bugfix/maintenance release.

It includes 9 bugfixes.






## Critical bugs fixed

### Cataloging

- [[18305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18305) jquery.fixFloat.js breaks advanced MARC editor for some browsers

### Circulation

- [[18150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18150) CanItemBeReserved doesn't work with (IndependentBranches AND ! canreservefromotherbranches)


## Other bugs fixed

### Acquisitions

- [[17605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17605) EDI should set currency in order record on creation

### Architecture, internals, and plumbing

- [[18028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18028) install_misc directory is outdated and must be removed
- [[18069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18069) koha-rebuild-zebra still calls rebuild_zebra with -x

### Label/patron card printing

- [[8603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8603) Patron card creator - 'Barcode Type' doesn't stick in layouts
- [[18246]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18246) Patron card creator: Units not always display properly in layouts

### Notices

- [[15854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15854) Race condition for sending renewal/check-in notices

### Patrons

- [[18094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18094) Patron search filters are broken by searchable attributes



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
- Armenian (97%)
- Chinese (China) (86%)
- Chinese (Taiwan) (100%)
- Czech (96%)
- Danish (71%)
- English (New Zealand) (94%)
- Finnish (100%)
- French (99%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (100%)
- Greek (78%)
- Hindi (99%)
- Italian (100%)
- Korean (52%)
- Kurdish (51%)
- Norwegian Bokmål (57%)
- Occitan (79%)
- Persian (59%)
- Polish (99%)
- Portuguese (100%)
- Portuguese (Brazil) (87%)
- Slovak (93%)
- Spanish (100%)
- Swedish (99%)
- Turkish (100%)
- Vietnamese (73%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.11.06 is

- Release Managers:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@biblibre.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Nick Clemens](mailto:nick@bywatersolutions.com)
  - [Jesse Weaver](mailto:jweaver@bywatersolutions.com)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - [Magnus Enger](mailto:magnus@enger.priv.no)
  - [Mirko Tietgen](mailto:mirko@abunchofthings.net)
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Zeno Tajoli](mailto:z.tajoli@cineca.it)
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager: [Nicole C. Engard](mailto:nengard@gmail.com)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators: 
  - [Brooke Johnson](mailto:abesottedphoenix@yahoo.com)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.11 -- [Katrin Fischer](mailto:katrin.fischer.83@web.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.11.06:


We thank the following individuals who contributed patches to Koha 16.11.06.

- root (1)
- Colin Campbell (1)
- Marcel de Rooy (2)
- Jonathan Druart (6)
- Katrin Fischer (2)
- David Gustafsson (1)
- Nicolas Legrand (1)
- Marc Véron (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.06

- BSZ BW (2)
- bugs.koha-community.org (6)
- Bulac (1)
- Marc Véron AG (2)
- PTFS-Europe (1)
- Rijksmuseum (2)
- translate.koha-community.org (1)
- ub.gu.se (1)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (1)
- Chris Cormack (2)
- Christopher Brannon (1)
- Jesse Maseto (1)
- Jonathan Druart (4)
- Katrin Fischer (12)
- Marc Véron (4)
- Mark Tompsett (1)
- Martin Renvoize (2)
- Mason James (1)
- Mirko Tietgen (1)
- Nick Clemens (3)
- Brendan A Gallagher (12)
- Kyle M Hall (1)
- Marcel de Rooy (7)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.
The last Koha release was 16.11.05, which was released on March 17, 2017.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Mar 2017 13:20:20.
