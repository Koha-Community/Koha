# RELEASE NOTES FOR KOHA 16.11.09
22 Jun 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.09 is a bugfix/maintenance release.

It includes 1 enhancement, 57 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[17974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17974) Add the Koha::Item->biblio method


## Critical bugs fixed

### Acquisitions

- [[18482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18482) False duplicates detected on adding a batch from a stage file

### Architecture, internals, and plumbing

- [[18647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18647) Internal server error on moremember.pl
- [[18663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18663) Missing db update for ExportRemoveFields
- [[18727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18727) System preferences loose part of values because of double quotes

### Circulation

- [[18179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18179) Koha::Objects->find should not be called in list context

### OPAC

- [[18204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18204) Authority searches are not saved in Search history

### Templates

- [[18512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18512) GetAuthorisedValues.GetByCode Template plugin should return code (not empty string) if value not found

### Tools

- [[16295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16295) marc_modification_templates permission doesn't allow access to modify template
- [[18689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18689) Fix calendar error with double quotes in title or description of holiday


## Other bugs fixed

### About

- [[15465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15465) README for github

### Acquisitions

- [[11122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11122) Fix display of publication year/copyrightdate and publishercode on various pages in acquisitions
- [[18722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18722) Subtotal information not showing fund source

### Architecture, internals, and plumbing

- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[18669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18669) RewriteCond affecting wrong rule in koha-httpd.conf
- [[18716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18716) CGI::param in list context warns in updatesupplier.pl

### Command-line Utilities

- [[18548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18548) running  koha-create --request-db without an instance name should abort

### Course reserves

- [[18264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18264) Course reserves - use itemnumber for editing existing reserve items

### Database

- [[18690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18690) Typos in Koha database description (Table "borrowers")

### Developer documentation

- [[5395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5395) C4::Acquisition::SearchOrder POD inconsistent with function

### I18N/L10N

- [[18641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18641) Translatability: Get rid of template directives in translations for *reserves.tt files
- [[18644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18644) Translatability: Get rid of pure template directives in translation for memberentrygen.tt
- [[18648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18648) Translatability: Get rid of tt directives in translation for macles.tt
- [[18675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18675) Translatability: Get rid of [%% in translation for csv-profiles.tt
- [[18681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18681) Translatability: Get rid of [%% in translation for about.tt
- [[18682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18682) Translatability: Get rid of [%% in translation for 2 files av-build-dropbox.inc
- [[18693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18693) Translatability: Get rid of exposing a [%% FOREACH loop in translation for branch-selector.inc
- [[18694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18694) Translatability: Get rid of exposing  [%% FOREACH in csv/cash_register_stats.tt
- [[18695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18695) Translatability: Get rid of  [%% INCLUDE in translation for circulation.tt
- [[18701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18701) Translatability: Get rid of exposed tt directives in matching-rules.tt

### Label/patron card printing

- [[18611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18611) Create labels action fails in manage-marc-import.pl if an item has been deleted from the import batch

### MARC Bibliographic record staging/import

- [[17710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17710) C4::Matcher::get_matches and C4::ImportBatch::GetBestRecordMatch should use same logic

### Notices

- [[18478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18478) Some notices sent via SMS gateway fail

### OPAC

- [[13913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13913) Renewal error message in OPAC is confusing

### Packaging

- [[17108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17108) Automatic debian/control updates (stable)

### Patrons

- [[18551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18551) Hide with CSS dynamic elements in member search
- [[18552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18552) Borrower debarments do not show on member detail page
- [[18569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18569) Quick add patron will not copy over details from cities and towns pull down into patron details
- [[18596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18596) Quick add form duplicating password confirm
- [[18598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18598) Quick add form doesn't clear values when switching

### Reports

- [[18734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18734) Internal server error in cash_register_stats.pl when exporting to file

### Serials

- [[13747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13747) Fix problems with frequency descriptions containing quotes

### System Administration

- [[18600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18600) Missing db update for TalkingTechItivaPhoneNotification
- [[18700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18700) Fix ungrammatical sentence

### Templates

- [[18656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18656) Require confirmation of deletion of files from patron record

### Test Suite

- [[18411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18411) t/db_dependent/www/search_utf8.t  fails
- [[18601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18601) OAI/Sets.t mangles data due to truncate in ModOAISetsBiblios
- [[18746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18746) Text_CSV_Various.t parse failure
- [[18759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18759) Circulation.t is failing randomly
- [[18761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18761) AutomaticItemModificationByAge.t tests are failing
- [[18762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18762) Some tests are noisy
- [[18767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18767) Useless debugging info in GetDailyQuote.t
- [[18773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18773) t/db_dependent/www/history.t is failing

### Tools

- [[14399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14399) Fix inventory.pl part two (following 12913)
- [[18704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18704) File types limit in tools/export.pl is causing issues with csv files generated by MS/Excel
- [[18706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18706) subfields to delete not disabled anymore in batch item modification
- [[18730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18730) Batch Mod Edit <label> HTML validation fails
- [[18752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18752) Automatic item modifications by age should allow 'blank' values



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
- German (Switzerland) (100%)
- Greek (81%)
- Hindi (99%)
- Italian (100%)
- Korean (52%)
- Norwegian Bokmål (57%)
- Occitan (78%)
- Persian (59%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (86%)
- Slovak (92%)
- Spanish (100%)
- Swedish (99%)
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

The release team for Koha 16.11.09 is

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
new features in Koha 16.11.09:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.11.09.

- LeireDiez (1)
- root (1)
- Aleisha Amohia (1)
- Colin Campbell (1)
- Nick Clemens (13)
- Tomás Cohen Arazi (2)
- David Cook (2)
- Olivier Crouzet (1)
- Marcel de Rooy (9)
- Jonathan Druart (16)
- Katrin Fischer (6)
- Koha instance kohadev-koha (1)
- Lee Jamison (1)
- Owen Leonard (3)
- Josef Moravec (3)
- Fridolin Somers (3)
- Mirko Tietgen (1)
- Mark Tompsett (6)
- Marc Véron (16)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.09

- abunchofthings.net (1)
- ACPL (3)
- BibLibre (3)
- BSZ BW (6)
- bugs.koha-community.org (16)
- ByWater-Solutions (13)
- kohadevbox (1)
- Marc Véron AG (16)
- marywood.edu (1)
- Prosentient Systems (2)
- PTFS-Europe (1)
- Rijksmuseum (9)
- scanbit.net (1)
- Theke Solutions (2)
- translate.koha-community.org (1)
- unidentified (10)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (4)
- David Roberts (1)
- Dilan Johnpulle (2)
- Fridolin Somers (44)
- Jason Palmer (1)
- Jonathan Druart (51)
- Josef Moravec (21)
- Julian Maurice (3)
- Katrin Fischer (84)
- Lee Jamison (9)
- Marc Véron (7)
- Mark Tompsett (4)
- Martin Renvoize (4)
- Michael Cabus (1)
- Mirko Tietgen (1)
- Nick Clemens (3)
- Tomas Cohen Arazi (2)
- Brendan A Gallagher (2)
- Kyle M Hall (23)
- Marcel de Rooy (23)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.
The last Koha release was 16.11.09, which was released on May 22, 2017.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jun 2017 09:29:41.
