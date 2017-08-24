# RELEASE NOTES FOR KOHA 17.05.03
24 août 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.03 is a security release.

It includes 3 enhancements, 13 bugfixes and 16 security fixes.


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

- [[18987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18987) When browsing for a patron by last name the page processes indefinitely


## Other bugs fixed

### Architecture, internals, and plumbing

- [[18605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18605) Remove TRUNCATE from C4/HoldsQueue.pm

### I18N/L10N

- [[18367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18367) Fix untranslatable string from Bug 18264

### OPAC

- [[18545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18545) Remove use of onclick from OPAC Cart

### Patrons

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
- Armenian (99%)
- Chinese (China) (83%)
- Chinese (Taiwan) (100%)
- Czech (95%)
- Danish (69%)
- English (New Zealand) (91%)
- Finnish (99%)
- French (97%)
- French (Canada) (91%)
- German (100%)
- German (Switzerland) (99%)
- Greek (78%)
- Hindi (96%)
- Italian (99%)
- Norwegian Bokmål (57%)
- Occitan (77%)
- Persian (57%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (85%)
- Slovak (90%)
- Spanish (100%)
- Swedish (96%)
- Turkish (99%)
- Vietnamese (71%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.05.03 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- RM Assistants :
  - [Alex Sassmannshausen](mailto:alex.sassmannshausen@ptfs-europe.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
- QA Team:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Alex Sassmannshausen](mailto:alex.sassmannshausen@ptfs-europe.com)
  - [Nick Clemens](mailto:nick@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- Bug Wranglers:
  - [Marc Véron](mailto:veron@veron.ch)
  - [Claire Gravely](mailto:claire_gravely@hotmail.com)
  - [Josef Moravec](mailto:josef.moravec@gmail.com)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators:
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mtj@kohaaloha.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 17.05.03:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 17.05.03.

- Aleisha Amohia (2)
- Alex Buckley (1)
- Nick Clemens (2)
- Tomás Cohen Arazi (2)
- Marcel de Rooy (9)
- Jonathan Druart (10)
- Amit Gupta (20)
- Chris Kirby (1)
- Owen Leonard (1)
- Fridolin Somers (1)
- Lari Taskula (4)
- Marc Véron (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.03

- ACPL (1)
- BibLibre (1)
- bugs.koha-community.org (10)
- ByWater-Solutions (2)
- Catalyst (1)
- ilsleypubliclibrary.org (1)
- informaticsglobal.com (20)
- jns.fi (4)
- Marc Véron AG (1)
- Rijksmuseum (9)
- Theke Solutions (2)
- unidentified (2)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (1)
- Amit Gupta (1)
- Axelle Clarisse (1)
- Chris Cormack (9)
- David Cook (1)
- fcouffignal (1)
- Frédéric Demians (1)
- Fridolin Somers (54)
- Jesse Maseto (1)
- Jonathan Druart (55)
- Julian Maurice (1)
- Katrin Fischer (6)
- Lee Jamison (5)
- Marc Véron (3)
- Mark Tompsett (2)
- Nick Clemens (8)
- sonia BOUIS (1)
- Tomas Cohen Arazi (8)
- Kyle M Hall (1)
- Marcel de Rooy (27)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.05.x.
The last Koha release was 17.05.02, which was released on Jully 27, 2017.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 août 2017 07:08:25.
