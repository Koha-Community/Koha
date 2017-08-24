# RELEASE NOTES FOR KOHA 16.5.16
24 Aug 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.16 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.16 is a security release.

It includes 30 bugfixes.


## Security bugs fixed

-
[[19035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19035)
Stored XSS in patron lists - lists.pl
-
[[19114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19114)
Stored XSS in parcels.pl
-
[[19112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19112)
Stored XSS in basketheader.pl page
-
[[19110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19110)
XSS Stored in branches.pl
-
[[19100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19100)
XSS Flaws in memberentry.pl
-
[[19105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19105)
XSS Stored in holidays.pl
-
[[16069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16069)
XSS issue in basket.pl
-
[[19079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19079)
XSS Flaws in Membership page
-
[[19033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19033)
XSS Flaws in Currencies and exchange page
-
[[19034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19034)
XSS Flaws in- Cities - Z39.50/SRU servers administration - Patron
categories pages
-
[[19050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19050)
XSS Flaws in Quick spine label creator
-
[[19051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19051)
XSS Flaws in - Batch record deletion page - Batch item deletion page
- Batch item modification page
-
[[19052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19052)
XSS Flaws in - vendor search page - Invoice search page
-
[[19054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19054)
XSS Flaws in Report - Top Most-circulated items
-
[[19078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19078)
XSS Flaws in System preferences
-
[[18726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18726)
OPAC XSS - biblionumber


## Critical bugs fixed

### Patrons

- [[18685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18685) Patron edit/cancel floating toolbar out of place


## Other bugs fixed

### Architecture, internals, and plumbing

- [[18605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18605) Remove TRUNCATE from C4/HoldsQueue.pm
- [[18632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18632) CGI::param called in list context flooding error logs

### OPAC

- [[16711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16711) OPAC Password recovery: Handling if multiple accounts have the same mail address
- [[18545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18545) Remove use of onclick from OPAC Cart

### Patrons

- [[18551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18551) Hide with CSS dynamic elements in member search
- [[18832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18832) Missing space between icon and label in button 'Patron lists'

### System Administration

- [[18965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18965) branch transfer limits pagination save bug

### Templates

- [[19000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19000) about page - Typo in closing p tag

### Test Suite

- [[18951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18951) Some t/Biblio tests are database dependent
- [[18976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18976) Fix t/db_dependent/Auth.t cleanup
- [[18982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18982) selenium tests needs too many prerequisites
- [[18991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18991) Fix cleanup in t/db_dependent/Log.t

### Tools

- [[18918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18918) Exporting bibs in CSV when you have no CSV profiles created causes error



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
- Armenian (93%)
- Basque (77%)
- Chinese (China) (88%)
- Chinese (Taiwan) (98%)
- Czech (96%)
- Danish (72%)
- English (New Zealand) (96%)
- Finnish (98%)
- French (98%)
- French (Canada) (92%)
- German (99%)
- German (Switzerland) (99%)
- Greek (85%)
- Hindi (98%)
- Italian (99%)
- Korean (53%)
- Kurdish (51%)
- Norwegian Bokmål (59%)
- Occitan (79%)
- Persian (60%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (89%)
- Slovak (94%)
- Spanish (99%)
- Swedish (90%)
- Turkish (99%)
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

The release team for Koha 16.5.16 is

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
new features in Koha 16.5.16:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.5.16.

- Aleisha Amohia (2)
- Tomás Cohen Arazi (1)
- Marcel de Rooy (5)
- Jonathan Druart (11)
- Amit Gupta (20)
- Mason James (3)
- Owen Leonard (1)
- Josef Moravec (1)
- Fridolin Somers (1)
- Lari Taskula (3)
- Marc Véron (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.16

- ACPL (1)
- BibLibre (1)
- bugs.koha-community.org (11)
- informaticsglobal.com (20)
- jns.fi (3)
- KohaAloha (3)
- Marc Véron AG (2)
- Rijksmuseum (5)
- Theke Solutions (1)
- unidentified (3)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (1)
- Amit Gupta (1)
- Andrei (4)
- Axelle Clarisse (1)
- Chris Cormack (9)
- fcouffignal (1)
- Fridolin Somers (4)
- Jesse Maseto (1)
- Jonathan Druart (17)
- Josef Moravec (2)
- Julian Maurice (1)
- Katrin Fischer (9)
- Lee Jamison (4)
- Marc Véron (3)
- Mark Tompsett (2)
- Mason James (42)
- Nick Clemens (9)
- Owen Leonard (1)
- Philippe (1)
- Tomas Cohen Arazi (5)
- Kyle M Hall (1)
- Marcel de Rooy (22)

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

Autogenerated release notes updated last on 24 Aug 2017 06:36:21.
