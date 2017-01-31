# RELEASE NOTES FOR KOHA 3.22.16
31 Jan 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.16 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.16 is a bugfix/maintenance release.

It includes 6 bugfixes.




## Critical bugs fixed

### Architecture, internals, and plumbing

- [[17494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17494) Koha generating duplicate self registration tokens

### Koha

- [[17900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17900) Possible SQL injection in patroncards template editing
- [[17901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17901) Possible SQL injection in shelf editing
- [[17902]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17902) Possible SQL injection in serial editing
- [[17903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17903) Possible SQL injection in serial claims


## Other bugs fixed

### Koha

- [[9569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9569) IndependentBranches preference overrides AutoLocation security feature



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
- Arabic (98%)
- Armenian (99%)
- Chinese (China) (93%)
- Chinese (Taiwan) (97%)
- Czech (97%)
- Danish (77%)
- English (New Zealand) (98%)
- Finnish (99%)
- French (99%)
- French (Canada) (91%)
- German (100%)
- German (Switzerland) (99%)
- Greek (80%)
- Hindi (99%)
- Italian (100%)
- Korean (57%)
- Kurdish (54%)
- Norwegian Bokmål (63%)
- Occitan (94%)
- Persian (64%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (94%)
- Slovak (99%)
- Spanish (100%)
- Swedish (95%)
- Turkish (100%)
- Vietnamese (78%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.16 is

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
new features in Koha 3.22.16:


We thank the following individuals who contributed patches to Koha 3.22.16.

- Jonathan Druart (12)
- Katrin Fischer (1)
- Julian Maurice (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.16

- BibLibre (2)
- BSZ BW (1)
- bugs.koha-community.org (12)

We also especially thank the following individuals who tested patches
for Koha.

- Chris Cormack (7)
- Julian Maurice (13)
- Katrin Fischer (2)
- Mirko Tietgen (5)
- Nick Clemens (7)
- Tomas Cohen Arazi (2)
- Kyle M Hall (13)
- Marcel de Rooy (5)

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

Autogenerated release notes updated last on 31 Jan 2017 08:57:25.
