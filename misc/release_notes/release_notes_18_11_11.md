# RELEASE NOTES FOR KOHA 18.11.11
22 Nov 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.11 is a bugfix/maintenance release.

It includes 3 enhancements, 24 bugfixes.



## Enhancements

### Notices

- [[21180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21180) Allow Talking Tech outbound script to limit based on patron home library branchcode
### OPAC

- [[23537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23537) Overdrive won't show complete results if the Overdrive object doesn't have a primaryCreator
### Templates

- [[21058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21058) Missing class for results_summary spans

## Critical bugs fixed

### Authentication

- [[23526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23526) Shibboleth login url with query has double encoded '?' %3F
### Installation and upgrade (web-based installer)

- [[23353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23353) ACQ framework makes fr-CA web installer explode
### REST api

- [[23597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23597) Holds API is missing reserved parameters on the GET spec
### Searching - Elasticsearch

- [[23004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23004) Missing authtype filter in auth_finder.pl
### Serials

- [[23961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23961) [18.11] Menu "add subcription fields" has disappeared
### Tools

- [[18710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18710) Wrong subfield modified in batch item modification

## Other bugs fixed

### Acquisitions

- [[23101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23101) Contracts permissions for staff patron
### Circulation

- [[23658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23658) [18.11] WrongTransfer modal drops off specified checkin date on returns.pl
- [[23679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23679) Software error when trying to transfer an unknown barcode
### ILL

- [[21406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21406) Not adding author to request can cause JS errors
### Notices

- [[22744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22744) Remove confusing 'Do not notify' checkboxes from messaging preferences
### OPAC

- [[16111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16111) RSS feed for OPAC search results has wrong content type
- [[22602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22602) OverDrive circulation integration is broken when user is referred to Koha from another site
- [[22804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22804) OPAC Overdrive JavaScript contains untranslatable strings
- [[23625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23625) ArticleRequestsMandatoryFields* only affects field labels, does not make inputs required

  **Sponsored by** *California College of the Arts*
- [[23683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23683) Course reserves public notes on specific items should allow for HTML
### Patrons

- [[23688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23688) System preference uppercasesurnames broken by typo
### REST api

- [[23607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23607) Make /patrons/:patron_id/account privileged user only
### Reports

- [[23624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23624) Count rows in report without (potentially) consuming all memory

  >Sponsored and written by HELM/FLO
### SIP2

- [[22037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22037) regression: guarantor no longer blocked (debarred) if child is over limit, when checking out via SIP.
### Self checkout

- [[22929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22929) Enabling the GDPR_Policy will affect libraries using the SCO module in Koha
### Staff Client

- [[23651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23651) RestrictedPage system preferences should include the address of the page in the description
### Templates

- [[23575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23575) Template error causes item search to be submitted multiple times
- [[23605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23605) Terminology: Branches limitations should be libraries limitations


## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (97.9%)
- Armenian (99.9%)
- Basque (65.8%)
- Chinese (China) (63.9%)
- Chinese (Taiwan) (99.2%)
- Czech (93.7%)
- Danish (55.2%)
- English (New Zealand) (88.1%)
- English (USA)
- Finnish (84.3%)
- French (99.5%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (91.6%)
- Greek (78.6%)
- Hindi (100%)
- Italian (93.7%)
- Norwegian Bokmål (94.5%)
- Occitan (post 1500) (59.5%)
- Polish (86.5%)
- Portuguese (100%)
- Portuguese (Brazil) (87.3%)
- Slovak (89.8%)
- Spanish (99.9%)
- Swedish (90.2%)
- Turkish (98.1%)
- Ukrainian (62%)
- Vietnamese (54.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.11 is

- Release Manager: Martin Renvoize
- Release Manager assistants:
  - Tomás Cohen Arazi
  - Nick Clemens
- QA Manager: Katrin Fischer
- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Nick Clemens
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Marcel de Rooy
- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Kyle Hall
  - UI Design -- Owen Leonard
  - Elasticsearch -- Alex Arnaud
  - ILS-DI -- Arthur Suzuki
  - Authentication -- Martin Renvoize
- Bug Wranglers:
  - Michal Denár
  - Indranil Das Gupta
  - Jon Knight
  - Lisette Scheer
  - Arthur Suzuki
- Packaging Manager: Mirko Tietgen
- Documentation Manager: David Nind
- Documentation Team:
  - Andy Boze
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel
- Release Maintainers:
  - 19.05 -- Fridolin Somers
  - 18.11 -- Lucas Gass
  - 18.05 -- Liz Rea
## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.11.11:

- California College of the Arts

We thank the following individuals who contributed patches to Koha 18.11.11.

- Tomás Cohen Arazi (6)
- David Bourgault (2)
- Nick Clemens (8)
- Jonathan Druart (9)
- Magnus Enger (1)
- Katrin Fischer (2)
- Martha Fuerst (1)
- Lucas Gass (5)
- Kyle Hall (4)
- Paul Hoffman (1)
- Owen Leonard (2)
- Eric Phetteplace (1)
- Liz Rea (3)
- Martin Renvoize (2)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (1)
- Fridolin Somers (6)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.11

- ACPL (2)
- BibLibre (6)
- BSZ BW (2)
- ByWater-Solutions (17)
- flo.org (1)
- hmcpl.org (1)
- Independant Individuals (6)
- Koha Community Developers (9)
- Libriotech (1)
- PTFS-Europe (2)
- Rijks Museum (6)
- Solutions inLibro inc (1)
- Theke Solutions (6)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (19)
- Christopher Brannon (1)
- Nick Clemens (7)
- Holly Cooper (1)
- Jonathan Druart (2)
- Bouzid Fergani (2)
- Katrin Fischer (5)
- Lucas Gass (58)
- Kyle Hall (18)
- Owen Leonard (7)
- Jesse Maseto (1)
- Julian Maurice (1)
- Matthias Meusburger (1)
- Josef Moravec (1)
- Elizabeth Quinn (1)
- Liz Rea (9)
- Martin Renvoize (51)
- Marcel de Rooy (30)
- Lisette Scheer (2)
- Fridolin Somers (41)
- Mark Tompsett (1)
- Bin Wen (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is new-security-release-18.11.11.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Nov 2019 17:46:39.
