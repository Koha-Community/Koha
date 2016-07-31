# RELEASE NOTES FOR KOHA 3.22.9
31 Jul 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.9 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.9 is a bugfix/maintenance release.

It includes 5 enhancements, 7 bugfixes.


## Enhancements

### Architecture, internals, and plumbing

- [[16693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16693) reserve/renewscript.pl is not used and should be removed

### Patrons

- [[16729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16729) Use member-display-address-style*-includes when printing user summary

### Templates

- [[16127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16127) Add discharge menu item to patron toolbar
- [[16541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16541) Make edit and delete links styled buttons in cities administration
- [[16543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16543) Make edit and delete links styled buttons in patron attribute types administration




## Other bugs fixed

### Architecture, internals, and plumbing

- [[13074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13074) C4::Items::_build_default_values_for_mod_marc should use Koha::Cache
- [[16502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16502) Table koha_plugin_com_bywatersolutions_kitchensink_mytable not always dropped after running Plugin.t
- [[16670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16670) CGI->param used in list context
- [[16720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16720) DBIx ActionLogs.pm should be removed

### Database

- [[10459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10459) borrowers should have a timestamp

### Serials

- [[12748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12748) Serials - two issues with status of "Expected"

### Test Suite

- [[16717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16717) Remove hardcoded category from Holds.t



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
- Armenian (99%)
- Chinese (China) (95%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (78%)
- English (New Zealand) (99%)
- Finnish (98%)
- French (93%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (99%)
- Greek (81%)
- Italian (99%)
- Korean (58%)
- Kurdish (55%)
- Norwegian Bokmål (64%)
- Persian (65%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (96%)
- Slovak (100%)
- Spanish (100%)
- Swedish (83%)
- Turkish (100%)
- Vietnamese (79%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.9 is

- Release Manager: [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
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
  - [Brook](mailto:)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.05 -- [Frédéric Demians](mailto:f.demians@tamil.fr)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 3.22.9:


We thank the following individuals who contributed patches to Koha 3.22.9.

- remi (2)
- Tomás Cohen Arazi (2)
- Jonathan Druart (7)
- Owen Leonard (3)
- Julian Maurice (3)
- Mark Tompsett (1)
- Marc Véron (1)
- Marcel de Rooy (6)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.9

- ACPL (3)
- BibLibre (3)
- bugs.koha-community.org (7)
- inLibro.com (2)
- Marc Véron AG (1)
- Rijksmuseum (6)
- Theke Solutions (2)
- unidentified (1)

We also especially thank the following individuals who tested patches
for Koha.

- Frédéric Demians (23)
- Jacek Ablewicz (1)
- Jan Kissig (1)
- Jonathan Druart (20)
- Joy Nelson (3)
- Julian Maurice (23)
- Liz Rea (1)
- Marc Veron (1)
- Marc Véron (2)
- Mark Tompsett (2)
- Nick Clemens (2)
- Srdjan (6)
- mehdi (1)
- rainer (1)
- Tomas Cohen Arazi (2)
- Kyle M Hall (26)
- Bernardo Gonzalez Kriegel (2)
- Marcel de Rooy (7)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 Jul 2016 08:52:28.
