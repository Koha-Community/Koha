# RELEASE NOTES FOR KOHA 16.5.11
17 Mar 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.11 is a bugfix/maintenance release.

It includes 1 enhancements, 7 bugfixes.




## Enhancements

### System Administration

- [[18122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18122) Audio alerts: Add hint on where to enable sounds


## Critical bugs fixed

### Installation and upgrade (command-line installer)

- [[17260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17260) updatedatabase.pl fails on invalid entries in ENUM and BOOLEAN columns


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Circulation

- [[16202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16202) Rental fees can be generated for fractions of a penny/cent
- [[17840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17840) Add classes to internal and public notes in checkouts table

### OPAC

- [[17895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17895) Small typo -'re-set'
- [[17947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17947) Searching my library first shows the branchcode by the search bar rather than branchname

### System Administration

- [[13968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13968) Branch email hints are misleading



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
- Armenian (94%)
- Chinese (China) (89%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (73%)
- English (New Zealand) (97%)
- Finnish (99%)
- French (99%)
- French (Canada) (94%)
- German (99%)
- German (Switzerland) (99%)
- Greek (84%)
- Hindi (99%)
- Italian (99%)
- Korean (54%)
- Kurdish (52%)
- Norwegian Bokmål (59%)
- Occitan (81%)
- Persian (61%)
- Polish (99%)
- Portuguese (99%)
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

The release team for Koha 16.5.11 is

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
new features in Koha 16.5.11:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.5.11.

- Blou (1)
- Aleisha Amohia (2)
- Colin Campbell (1)
- Tomás Cohen Arazi (1)
- Marcel de Rooy (1)
- Jonathan Druart (1)
- Katrin Fischer (1)
- Mason James (2)
- Emma Smith (1)
- Mark Tompsett (1)
- Marc Véron (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.11

- BSZ BW (1)
- bugs.koha-community.org (1)
- KohaAloha (2)
- Marc Véron AG (2)
- PTFS-Europe (1)
- Rijksmuseum (1)
- Solutions inLibro inc (1)
- Theke Solutions (1)
- unidentified (4)

We also especially thank the following individuals who tested patches
for Koha.

- Caitlin Goodger (1)
- Claire Gravely (1)
- Jonathan Druart (9)
- Katrin Fischer (9)
- Mark Tompsett (7)
- Martin Renvoize (1)
- Mason James (2)
- Mehdi Hamidi (1)
- Owen Leonard (2)
- Tomas Cohen Arazi (2)
- Kyle M Hall (10)

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

Autogenerated release notes updated last on 17 Mar 2017 13:26:06.
