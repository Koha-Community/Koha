# RELEASE NOTES FOR KOHA 16.11.12
19 Sep 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.12 is a bugfix/maintenance release.

It includes 31 bugfixes.


## Security bugs fixed

- [[19086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19086) Multiple cross-site scripting vulnerabilities
- [[19103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19103) Stored XSS in itemtypes.pl - patron-attr-types.pl - matching-rules.pl
- [[19108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19108) Stored XSS in multiple scripts
- [[19125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19125) XSS - members.pl
- [[19127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19127) Stored XSS in csv-profiles.pl
- [[19128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19128) XSS - patron-attr-types.tt, authorised_values.tt and categories.tt


## Critical bugs fixed

### Acquisitions

- [[18900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18900) wrong number format in receiving order
- [[18906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18906) Superlibrarian and budget_manage_all users should always see all funds

### Authentication

- [[18046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18046) Problem with redirect on logout with CAS

### Circulation

- [[19053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19053) Auto renewal flag is not kept if a confirmation is needed

### Command-line Utilities

- [[18927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18927) koha-rebuild-zebra is failing with "error retrieving biblio"

### I18N/L10N

- [[18331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18331) Translated CSV exports need to be fixed once and for all

### Installation and upgrade (web-based installer)

- [[18741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18741) Web installer does not load default data

### OPAC

- [[19235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19235) password visible in OPAC self registration

### Reports

- [[18898]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18898) Some permissions for Reports can be bypassed

### SIP2

- [[15438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15438) Checking out an on-hold item sends holder's borrowernumber in AF (screen message) field.
- [[18996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18996) SIP sets ok flag to true for refused checkin for data corruption

### Searching

- [[16976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16976) Authorities searches with double quotes gives ZOOM error 20003
- [[18624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18624) Software error when searching authorities in Elasticsearch - incorrect parameter "any" should be "all"

### Tools

- [[19023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19023) inventory tool performance
- [[19049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19049) Fix regression on stage-marc-import with to_marc plugin
- [[19073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19073) Can't change library with patron batch modification tool
- [[19163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19163) Critical typo in stage-marc-import process


## Other bugs fixed

### Architecture, internals, and plumbing

- [[18921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18921) Resolve a few warnings in C4/XSLT.pm

### I18N/L10N

- [[17827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17827) Untranslatable "by" in MARC21slim2intranetResults.xsl
- [[18649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18649) Translatability: Get rid of tt directive in translation for admin/categories.tt and onboardingstep2.tt
- [[18652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18652) Translatability: Get rid of tt directive in translation for uncertainprice.tt
- [[18654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18654) Translatability: Get rid of tt directives starting with [%% in translation for itemsearch.tt
- [[18660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18660) Translatability: Get rid of template directives [%% in translation for patroncards-errors.inc
- [[18778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18778) Translatability: Get rid of  tt directive in translation for item-status.inc

### Patrons

- [[18551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18551) Hide with CSS dynamic elements in member search



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
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (99%)
- Greek (83%)
- Hindi (98%)
- Italian (99%)
- Korean (52%)
- Norwegian Bokmål (56%)
- Occitan (78%)
- Persian (59%)
- Polish (99%)
- Portuguese (100%)
- Portuguese (Brazil) (86%)
- Slovak (92%)
- Spanish (99%)
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

The release team for Koha 16.11.12 is

- Release Managers:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
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
new features in Koha 16.11.12:


We thank the following individuals who contributed patches to Koha 16.11.12.

- root (1)
- Colin Campbell (1)
- Nick Clemens (2)
- Tomás Cohen Arazi (2)
- David Cook (1)
- Chris Cormack (3)
- Marcel de Rooy (11)
- Jonathan Druart (10)
- Serhij Dubyk {Сергій Дубик} (1)
- Katrin Fischer (8)
- Amit Gupta (12)
- Lee Jamison (1)
- Julian Maurice (1)
- Kyle M Hall (1)
- Josef Moravec (1)
- Alex Sassmannshausen (1)
- Fridolin Somers (5)
- Mark Tompsett (1)
- Marc Véron (6)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.12

- BibLibre (6)
- BigBallOfWax (2)
- BSZ BW (8)
- bugs.koha-community.org (10)
- ByWater-Solutions (3)
- Catalyst (1)
- informaticsglobal.com (12)
- Marc Véron AG (6)
- marywood.edu (1)
- Prosentient Systems (1)
- PTFS-Europe (2)
- Rijksmuseum (11)
- Theke Solutions (2)
- translate.koha-community.org (1)
- unidentified (3)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (2)
- Amit Gupta (4)
- Colin Campbell (4)
- Fridolin Somers (56)
- Jonathan Druart (61)
- Josef Moravec (5)
- Julian Maurice (1)
- Katrin Fischer (88)
- Lee Jamison (6)
- Liz Rea (1)
- Marc Véron (2)
- Mark Tompsett (1)
- Nick Clemens (4)
- Owen Leonard (4)
- Philippe (1)
- Tomas Cohen Arazi (6)
- Kyle M Hall (9)
- Marcel de Rooy (41)
- Serhij Dubyk {Сергій Дубик} (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.
The last Koha release was 16.11.11, which was released on August 29, 2017.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 19 Sep 2017 22:02:08.
