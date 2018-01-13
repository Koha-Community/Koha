# RELEASE NOTES FOR KOHA 16.11.15
03 Jan 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.15 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.15 is a bugfix/maintenance release with security fixes.

It includes 7 security fixes, 3 bugfixes.


## Security bugs

### Koha

- [[19319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19319) Reflected XSS Vulnerability in opac-MARCdetail.pl
- [[19568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19568) Wrong html filter used in opac-opensearch.tt url
- [[19569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19569) X-Frame-Options=SAMEORIGIN is not set from opac-showmarc.pl
- [[19570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19570) autocomplete="off" no set for login forms at the OPAC
- [[19611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19611) XSS Flaws in supplier.pl
- [[19612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19612) Fix XSS in /cgi-bin/koha/members/memberentry.pl
- [[19614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19614) Fix XSS in /cgi-bin/koha/members/pay.pl




## Critical bugs fixed

### Acquisitions

- [[19593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19593) [16.11.x] "Delete vendor" button is always set

### Architecture, internals, and plumbing

- [[19655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19655) To.json doesn't escape newlines which can create invalid JSON


## Other bugs fixed

### Serials

- [[19796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19796) [16.11] Subscription info appears doubled up on OPAC detail page



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
- Basque (80%)
- Chinese (China) (85%)
- Chinese (Taiwan) (99%)
- Czech (95%)
- Danish (70%)
- English (New Zealand) (93%)
- Finnish (99%)
- French (99%)
- French (Canada) (93%)
- German (99%)
- German (Switzerland) (99%)
- Greek (84%)
- Hindi (100%)
- Italian (100%)
- Korean (51%)
- Norwegian Bokmål (56%)
- Occitan (78%)
- Persian (59%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (86%)
- Slovak (92%)
- Spanish (100%)
- Swedish (98%)
- Turkish (100%)
- Vietnamese (72%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.11.15 is

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
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 16.11.15:


We thank the following individuals who contributed patches to Koha 16.11.15.

- Chris Cormack (2)
- Marcel de Rooy (1)
- Jonathan Druart (6)
- Katrin Fischer (1)
- Bernardo González Kriegel (1)
- Amit Gupta (3)
- Gwendal Joncour (1)
- Kyle M Hall (2)
- Mark Tompsett (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.15

- BSZ BW (1)
- bugs.koha-community.org (6)
- ByWater-Solutions (2)
- Catalyst (2)
- informaticsglobal.com (3)
- Rijksmuseum (1)
- unidentified (1)
- Universidad Nacional de Córdoba (1)
- Université Rennes 2 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Chris Cormack (8)
- Fridolin Somers (2)
- Jonathan Druart (13)
- Josef Moravec (1)
- Katrin Fischer (7)
- Mark Tompsett (2)
- Nick Clemens (1)
- Simon Pouchol (1)
- Marcel de Rooy (6)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 03 Jan 2018 19:59:01.
