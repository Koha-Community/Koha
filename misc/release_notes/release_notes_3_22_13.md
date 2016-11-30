# RELEASE NOTES FOR KOHA 3.22.13
30 Nov 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.13 is a bugfix/maintenance release.

It includes 23 bugfixes.




## Critical bugs fixed

### Acquisitions

- [[16493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16493) acq matching on title and author

### Authentication

- [[17481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17481) Cas Logout: bug 11048 has been incorrectly merged

### Circulation

- [[14598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14598) itemtype is not set on statistics by C4::Circulation::AddReturn

### Command-line Utilities

- [[17376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17376) rebuild_zebra.pl in daemon mode no database access kills the process

### OPAC

- [[17484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17484) Searching with date range limit (lower and upper) does not work

### Searching

- [[17323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17323) MySQL 5.7 - Column search_history.time cannot be null

### Tools

- [[17420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17420) record export fails when itemtype on biblio


## Other bugs fixed

### Architecture, internals, and plumbing

- [[15690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15690) Unconstrained CardnumberLength preference conflicts with table column limit of 16
- [[17513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17513) koha-create does not set GRANTS correctly

### Cataloging

- [[17660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17660) Any $t subfields not editable in any framework

### Circulation

- [[14736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14736) AllowRenewalIfOtherItemsAvailable slows circulation down in case of a record with many items and many holds
- [[17394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17394) exporting checkouts with items selects without items in combo-box
- [[17395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17395) exporting checkouts in CSV generates a file with wrong extension

### Command-line Utilities

- [[16935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16935) launch export_records.pl with deleted_barcodes param fails

### I18N/L10N

- [[17518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17518) Displayed language name for Czech is wrong

### Installation and upgrade (web-based installer)

- [[17391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17391) ReturnpathDefault and ReplyToDefault missing from syspref.sql
- [[17504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17504) Installer shows PostgreSQL info when wrong DB permissions

### Packaging

- [[4880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4880) koha-remove sometimes fails because user is logged in

### Patrons

- [[17419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17419) Fix more confusion between smsalertnumber and mobile
- [[17434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17434) Moremember displaying primary and secondary phone number twice

### Reports

- [[17590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17590) Exporting reports as CSV with 'delimiter' SysPref set to 'tabulation' creates files with 't' as separator

### Staff Client

- [[17375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17375) Prevent internal software error when searching patron with invalid birth date

### Templates

- [[17417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17417) Correct invalid markup around news on the staff client home page

## New sysprefs

- ReplyToDefault
- ReturnpathDefault

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
- Armenian (99%)
- Chinese (China) (93%)
- Chinese (Taiwan) (97%)
- Czech (97%)
- Danish (77%)
- English (New Zealand) (98%)
- Finnish (99%)
- French (99%)
- French (Canada) (91%)
- German (99%)
- German (Switzerland) (99%)
- Greek (80%)
- Hindi (100%)
- Italian (100%)
- Korean (57%)
- Kurdish (54%)
- Norwegian Bokmål (63%)
- Occitan (94%)
- Persian (64%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (94%)
- Slovak (98%)
- Spanish (99%)
- Swedish (95%)
- Turkish (100%)
- Vietnamese (78%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.13 is

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
new features in Koha 3.22.13:

- Universidad Empresarial Siglo 21

We thank the following individuals who contributed patches to Koha 3.22.13.

- Brendan A Gallagher (1)
- Nick Clemens (2)
- Tomás Cohen Arazi (7)
- Jonathan Druart (9)
- Katrin Fischer (1)
- Owen Leonard (1)
- Kyle M Hall (10)
- Julian Maurice (2)
- Matthias Meusburger (1)
- Josef Moravec (2)
- Fridolin Somers (6)
- Lari Taskula (1)
- Koha Team Lyon 3 (1)
- Mark Tompsett (1)
- Marcel de Rooy (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.13

- ACPL (1)
- BibLibre (9)
- BSZ BW (1)
- bugs.koha-community.org (9)
- ByWater-Solutions (13)
- jns.fi (1)
- Rijksmuseum (1)
- Theke Solutions (5)
- unidentified (3)
- Universidad Nacional de Córdoba (2)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Barbara Fondren (1)
- Chris Cormack (1)
- Dani Elder (1)
- Frédéric Demians (9)
- Jacek Ablewicz (1)
- Jesse Maseto (2)
- Jonathan Druart (13)
- Josef Moravec (1)
- Julian Maurice (43)
- Lucio Moraes (3)
- Marc (4)
- Marc Véron (2)
- Mark Tompsett (2)
- Martin Renvoize (2)
- Mirko Tietgen (1)
- Nick Clemens (6)
- Nicolas Legrand (1)
- Owen Leonard (1)
- radiuscz (1)
- Katrin Fischer  (4)
- Tomas Cohen Arazi (16)
- Nicole C Engard (1)
- Kyle M Hall (42)
- Bernardo Gonzalez Kriegel (3)
- Marcel de Rooy (17)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 30 Nov 2016 13:57:45.
