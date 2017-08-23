# RELEASE NOTES FOR KOHA 16.11.11
23 Aug 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.11 is a security release.

It includes 3 enhancements, 32 bugfixes.

## Security bugs fixed

- [[19035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19035) Stored XSS in patron lists - lists.pl
- [[19114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19114) Stored XSS in parcels.pl
- [[19112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19112) Stored XSS in basketheader.pl page
- [[19110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19110) XSS Stored in branches.pl
- [[19100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19100) XSS Flaws in memberentry.pl
- [[19105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19105) XSS Stored in holidays.pl
- [[16069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16069) XSS issue in basket.pl
- [[19079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19079) XSS Flaws in Membership page
- [[19033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19033) XSS Flaws in Currencies and exchange page
- [[19034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19034) XSS Flaws in- Cities - Z39.50/SRU servers administration - Patron categories pages
- [[19050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19050) XSS Flaws in Quick spine label creator
- [[19051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19051) XSS Flaws in - Batch record deletion page - Batch item deletion page - Batch item modification page
- [[19052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19052) XSS Flaws in - vendor search page - Invoice search page
- [[19054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19054) XSS Flaws in Report - Top Most-circulated items
- [[19078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19078) XSS Flaws in System preferences
- [[18726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18726) OPAC XSS - biblionumber


## Enhancements

### Acquisitions

- [[18839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18839) suggestion.pl: 'unknown' is spelled 'unkown'

### Architecture, internals, and plumbing

- [[18361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18361) Koha::Objects->find should accept composite primary keys
- [[18539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18539) Forbid Koha::Objects->find calls in list context


## Critical bugs fixed

### Patrons

- [[18685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18685) Patron edit/cancel floating toolbar out of place


## Other bugs fixed

### Architecture, internals, and plumbing

- [[18605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18605) Remove TRUNCATE from C4/HoldsQueue.pm
- [[18632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18632) CGI::param called in list context flooding error logs

### I18N/L10N

- [[18367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18367) Fix untranslatable string from Bug 18264

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
- [[18977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18977) Rollback branch in t/db_dependent/SIP/Message.t
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
- Arabic (99%)
- Armenian (96%)
- Chinese (China) (85%)
- Chinese (Taiwan) (99%)
- Czech (95%)
- Danish (71%)
- English (New Zealand) (93%)
- Finnish (99%)
- French (99%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (99%)
- Greek (83%)
- Hindi (98%)
- Italian (99%)
- Korean (52%)
- Norwegian Bokmål (56%)
- Occitan (78%)
- Persian (59%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (86%)
- Slovak (92%)
- Spanish (100%)
- Swedish (98%)
- Turkish (99%)
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

The release team for Koha 16.11.11 is

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
new features in Koha 16.11.11:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.11.11.

- root (1)
- Aleisha Amohia (2)
- Nick Clemens (2)
- Tomás Cohen Arazi (1)
- Marcel de Rooy (7)
- Jonathan Druart (13)
- Katrin Fischer (3)
- Amit Gupta (20)
- Chris Kirby (1)
- Owen Leonard (1)
- Josef Moravec (1)
- Fridolin Somers (1)
- Lari Taskula (4)
- Marc Véron (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.11

- ACPL (1)
- BibLibre (1)
- BSZ BW (3)
- bugs.koha-community.org (13)
- ByWater-Solutions (2)
- ilsleypubliclibrary.org (1)
- informaticsglobal.com (20)
- jns.fi (4)
- Marc Véron AG (2)
- Rijksmuseum (7)
- Theke Solutions (1)
- translate.koha-community.org (1)
- unidentified (3)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (1)
- Amit Gupta (1)
- Axelle Clarisse (1)
- Chris Cormack (9)
- fcouffignal (1)
- Frédéric Demians (1)
- Fridolin Somers (26)
- Jesse Maseto (1)
- Jonathan Druart (35)
- Josef Moravec (2)
- Julian Maurice (1)
- Katrin Fischer (31)
- Lee Jamison (5)
- Marc Véron (4)
- Mark Tompsett (2)
- Nick Clemens (10)
- Owen Leonard (1)
- Philippe (1)
- sonia BOUIS (1)
- Tomas Cohen Arazi (8)
- Kyle M Hall (2)
- Marcel de Rooy (26)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.
The last Koha release was 16.11.10, which was released on July 28, 2017.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Aug 2017 18:12:27.
