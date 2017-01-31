# RELEASE NOTES FOR KOHA 16.5.9
31 Jan 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.9 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.9 is a bugfix/maintenance release.

It includes 1 enhancements, 4 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[17990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17990) Code to check perl module versions is buggy


## Critical bugs fixed

### Installation and upgrade (command-line installer)

- [[17986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17986) Perl dependency evaluation incorrect


## Other bugs fixed

### Architecture, internals, and plumbing

- [[16929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16929) Prevent opac-memberentry waiting for random chars

### Installation and upgrade (command-line installer)

- [[17880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17880) C4::Installer::PerlModules lexicographical comparison is incorrect

### Test Suite

- [[18009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18009) IssueSlip.t test fails if launched between 00:00 and 00:59



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
- Armenian (95%)
- Chinese (China) (89%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (74%)
- English (New Zealand) (98%)
- Finnish (99%)
- French (99%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (99%)
- Greek (82%)
- Hindi (99%)
- Italian (100%)
- Korean (54%)
- Kurdish (52%)
- Norwegian Bokmål (60%)
- Occitan (81%)
- Persian (61%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (90%)
- Slovak (95%)
- Spanish (100%)
- Swedish (92%)
- Turkish (100%)
- Vietnamese (75%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.5.9 is

- Release Manager: [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
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
new features in Koha 16.5.9:


We thank the following individuals who contributed patches to Koha 16.5.9.

- David Cook (3)
- Marcel de Rooy (3)
- Jonathan Druart (14)
- Katrin Fischer (1)
- Mason James (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.9

- BSZ BW (1)
- bugs.koha-community.org (14)
- KohaAloha (2)
- Prosentient Systems (3)
- Rijksmuseum (3)

We also especially thank the following individuals who tested patches
for Koha.

- Chris Cormack (7)
- David Cook (1)
- Jonathan Druart (5)
- Katrin Fischer (7)
- Marc (3)
- Mark Tompsett (2)
- Mason James (8)
- Mirko Tietgen (6)
- Nick Clemens (7)
- Tomas Cohen Arazi (2)
- Kyle M Hall (7)
- Marcel de Rooy (11)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 31 Jan 2017 03:05:05.
