# RELEASE NOTES FOR KOHA 16.5.14
13 Jun 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.14 is a bugfix/maintenance release.

It includes 3 bugfixes.






## Critical bugs fixed

### Patrons

- [[18740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18740) [16.05.12-16.05.13] Cannot modify patron password


## Other bugs fixed

### Test Suite

- [[18411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18411) t/db_dependent/www/search_utf8.t  fails
- [[18773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18773) t/db_dependent/www/history.t is failing



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
- Basque (78%)
- Chinese (China) (88%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (73%)
- English (New Zealand) (97%)
- Finnish (99%)
- French (98%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (100%)
- Greek (84%)
- Hindi (99%)
- Italian (100%)
- Korean (54%)
- Kurdish (52%)
- Norwegian Bokmål (59%)
- Occitan (80%)
- Persian (61%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (89%)
- Slovak (94%)
- Spanish (100%)
- Swedish (91%)
- Turkish (100%)
- Vietnamese (74%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.5.14 is

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
new features in Koha 16.5.14:


We thank the following individuals who contributed patches to Koha 16.5.14.

- Jonathan Druart (1)
- Mason James (2)
- Mark Tompsett (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.14

- bugs.koha-community.org (1)
- KohaAloha (2)
- unidentified (2)

We also especially thank the following individuals who tested patches
for Koha.

- Jonathan Druart (2)
- Lee Jamison (2)
- Mason James (3)
- Tomas Cohen Arazi (1)

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

Autogenerated release notes updated last on 13 Jun 2017 06:23:29.
