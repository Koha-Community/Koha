# RELEASE NOTES FOR KOHA 3.20.14
22 Aug 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.20.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.20.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.20.14 is a bugfix/maintenance release.

It includes 12 bugfixes.




## Critical bugs fixed

### Architecture, internals, and plumbing

- [[16476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16476) CGI->param('foo') in list context allows XSS (e.g. Javascript injection) in Koha

### Koha

- [[16958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16958) opac-imageviewer.pl is vulnerable to XSS
- [[17022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17022) branchtransfers.pl is vulnerable to XSS attacks
- [[17023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17023) z3950_search.pl are vulnerable to XSS attacks
- [[17026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17026) checkexpiration.pl is vulnerable to XSS attacks
- [[17028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17028) request.pl is vulnerable to XSS attacks
- [[17029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17029) *detail.pl are vulnerable to XSS attacks
- [[17036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17036) circulation.pl is vulnerable to XSS attacks
- [[17038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17038) search.pl is vulnerable to XSS attacks

### OPAC

- [[16593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16593) Access Control - Malicious user can delete the search history of another user


## Other bugs fixed

### Koha

- [[16587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16587) Reflected XSS in [opac-]sendbasket and [opac-]sendshelf
- [[16975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16975) DSA-3628-1 perl -- security update



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
- Chinese (China) (98%)
- Chinese (Taiwan) (97%)
- Czech (98%)
- Danish (81%)
- English (New Zealand) (99%)
- Finnish (99%)
- French (94%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (99%)
- Greek (85%)
- Italian (100%)
- Korean (62%)
- Kurdish (59%)
- Norwegian Bokmål (60%)
- Occitan (95%)
- Persian (68%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (97%)
- Slovak (100%)
- Spanish (100%)
- Swedish (88%)
- Turkish (100%)
- Vietnamese (84%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.20.14 is

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
new features in Koha 3.20.14:


We thank the following individuals who contributed patches to Koha 3.20.14.

- Chris Cormack (7)
- Jonathan Druart (11)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.20.14

- BigBallOfWax (3)
- bugs.koha-community.org (11)
- Catalyst (4)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan Gallagher (3)
- Chris Cormack (20)
- Frédéric Demians (3)
- Jonathan Druart (4)
- Katrin Fischer (9)
- Kyle M Hall (4)
- Marcel de Rooy (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.20.x.
The last Koha release was 3.16.9, which was released on March 29, 2015.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Aug 2016 23:02:40.
