# RELEASE NOTES FOR KOHA 16.5.15
30 Jul 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.15 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.15.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.15 is a bugfix/maintenance release.

It includes 2 enhancements, 68 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[17974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17974) Add the Koha::Item->biblio method
- [[18931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18931) Add a "data corrupted" section on the about page


## Critical bugs fixed

### Acquisitions

- [[18482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18482) False duplicates detected on adding a batch from a stage file
- [[18756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18756) Users can view aq.baskets even if they are not allowed

### Architecture, internals, and plumbing

- [[18663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18663) Missing db update for ExportRemoveFields
- [[18727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18727) System preferences loose part of values because of double quotes
- [[18966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18966) Move of checkouts - Deal with duplicate IDs at DBMS level

### OPAC

- [[18204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18204) Authority searches are not saved in Search history
- [[18572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18572) Improper branchcode  set during OPAC renewal
- [[18955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18955) autocomplete is on in OPAC password recovery

### Templates

- [[18512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18512) GetAuthorisedValues.GetByCode Template plugin should return code (not empty string) if value not found

### Test Suite

- [[18807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18807) www/batch.t is failing

### Tools

- [[12913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12913) Fix wrong inventory results
- [[16295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16295) marc_modification_templates permission doesn't allow access to modify template
- [[18689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18689) Fix calendar error with double quotes in title or description of holiday
- [[18806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18806) Cannot revert a batch

### Z39.50 / SRU / OpenSearch Servers

- [[18910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18910) Regression: Z39.50 wrong conversion in Unimarc by Bug 18152


## Other bugs fixed

### About

- [[15465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15465) README for github

### Acquisitions

- [[11122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11122) Fix display of publication year/copyrightdate and publishercode on various pages in acquisitions
- [[18722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18722) Subtotal information not showing fund source
- [[18830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18830) Message to user is poorly constructed

### Architecture, internals, and plumbing

- [[14572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14572) insert_single_holiday() forces a value on an AUTO_INCREMENT column, during an INSERT
- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[18669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18669) RewriteCond affecting wrong rule in koha-httpd.conf
- [[18771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18771) CGI.pm: Subroutine multi_param redefined

### Command-line Utilities

- [[18548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18548) running  koha-create --request-db without an instance name should abort

### Database

- [[18690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18690) Typos in Koha database description (Table "borrowers")

### Developer documentation

- [[5395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5395) C4::Acquisition::SearchOrder POD inconsistent with function

### Documentation

- [[18554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18554) Adjust a few typos including responsability

### I18N/L10N

- [[18641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18641) Translatability: Get rid of template directives in translations for *reserves.tt files
- [[18644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18644) Translatability: Get rid of pure template directives in translation for memberentrygen.tt
- [[18648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18648) Translatability: Get rid of tt directives in translation for macles.tt
- [[18675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18675) Translatability: Get rid of [%% in translation for csv-profiles.tt
- [[18682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18682) Translatability: Get rid of [%% in translation for 2 files av-build-dropbox.inc
- [[18695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18695) Translatability: Get rid of  [%% INCLUDE in translation for circulation.tt
- [[18699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18699) Get rid of %%] in translation for edi_accounts.tt
- [[18800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18800) Patron card images: Add some more explanation to upload page and fix small translatability issue
- [[18901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18901) Sysprefs translation: translate only *.pref files (not *.pref*)

### Label/patron card printing

- [[17181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17181) Patron card creator replaces existing image when uploading image with same name
- [[18611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18611) Create labels action fails in manage-marc-import.pl if an item has been deleted from the import batch

### Lists

- [[18214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18214) Cannot edit list permissions of a private list

### MARC Bibliographic record staging/import

- [[17710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17710) C4::Matcher::get_matches and C4::ImportBatch::GetBestRecordMatch should use same logic

### Notices

- [[18478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18478) Some notices sent via SMS gateway fail

### OPAC

- [[13913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13913) Renewal error message in OPAC is confusing
- [[18400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18400) Noisy warns in opac-search.pl during itemtype sorting
- [[18634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18634) Missing empty line at end of opac.pref / colliding translated preference sections

### Patrons

- [[18569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18569) Quick add patron will not copy over details from cities and towns pull down into patron details
- [[18858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18858) Warn when deleting a borrower debarment

### Reports

- [[11235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11235) Names for reports and dictionary are cut off when quotes are used
- [[13452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13452) Average checkout report always uses biblioitems.itemtype

### SIP2

- [[18755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18755) Allow empty password fields in Patron Info requests

> Some SIP devices expect an empty password field in a patron info request to be accepted as OK by the server. Since patch for bug 16610 was applied this is not the case. This reinstates the old behaviour for sip logins with the parameter allow_empty_passwords="1"



### Serials

- [[13747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13747) Fix problems with frequency descriptions containing quotes
- [[18356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18356) Prediction pattern wrong, skips years, for some year based frequencies
- [[18607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18607) Fix date calculations for monthly frequencies in Serials
- [[18697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18697) Fix date calculations for day/week frequencies in Serials

### System Administration

- [[18600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18600) Missing db update for TalkingTechItivaPhoneNotification
- [[18700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18700) Fix ungrammatical sentence
- [[18934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18934) Warns in Admin -> SMS providers

### Templates

- [[17639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17639) Remove white filling inside of Koha logo
- [[18656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18656) Require confirmation of deletion of files from patron record

### Test Suite

- [[18601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18601) OAI/Sets.t mangles data due to truncate in ModOAISetsBiblios
- [[18746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18746) Text_CSV_Various.t parse failure
- [[18759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18759) Circulation.t is failing randomly
- [[18761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18761) AutomaticItemModificationByAge.t tests are failing
- [[18767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18767) Useless debugging info in GetDailyQuote.t
- [[18804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18804) Selenium tests are failing

### Tools

- [[18613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18613) Deleting a Letter from a library as superlibrarian deletes the "All libraries" rule
- [[18704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18704) File types limit in tools/export.pl is causing issues with csv files generated by MS/Excel
- [[18706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18706) subfields to delete not disabled anymore in batch item modification
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
- Arabic (98%)
- Armenian (93%)
- Basque (78%)
- Chinese (China) (88%)
- Chinese (Taiwan) (99%)
- Czech (96%)
- Danish (72%)
- English (New Zealand) (96%)
- Finnish (98%)
- French (99%)
- French (Canada) (92%)
- German (99%)
- German (Switzerland) (99%)
- Greek (85%)
- Hindi (99%)
- Italian (100%)
- Korean (53%)
- Kurdish (51%)
- Norwegian Bokmål (59%)
- Occitan (80%)
- Persian (60%)
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

The release team for Koha 16.5.15 is

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
new features in Koha 16.5.15:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.5.15.

- apirak (1)
- Gus (1)
- LeireDiez (1)
- Aleisha Amohia (3)
- Colin Campbell (3)
- Nick Clemens (10)
- Tomás Cohen Arazi (2)
- David Cook (2)
- Chris Cormack (1)
- Christophe Croullebois (1)
- Olivier Crouzet (1)
- Marcel de Rooy (17)
- Jonathan Druart (27)
- Katrin Fischer (3)
- Mason James (9)
- Lee Jamison (1)
- Owen Leonard (4)
- Julian Maurice (3)
- Josef Moravec (3)
- Rodrigo Santellan (1)
- Fridolin Somers (6)
- Mirko Tietgen (1)
- Mark Tompsett (5)
- Marc Véron (14)
- Baptiste Wojtkowski (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.15

- abunchofthings.net (1)
- ACPL (4)
- BibLibre (12)
- BigBallOfWax (1)
- BSZ BW (3)
- bugs.koha-community.org (27)
- ByWater-Solutions (10)
- KohaAloha (9)
- Marc Véron AG (14)
- marywood.edu (1)
- Prosentient Systems (2)
- PTFS-Europe (3)
- punsarn.asia (1)
- Rijksmuseum (17)
- scanbit.net (1)
- stacmail.net (1)
- Theke Solutions (2)
- unidentified (12)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (3)
- Blou (1)
- Chris Cormack (3)
- Claire Gravely (1)
- David Kuhn (1)
- David Roberts (1)
- Dilan Johnpulle (2)
- Frédéric Demians (1)
- Fridolin Somers (36)
- Jason Palmer (1)
- Jonathan Druart (46)
- Josef Moravec (30)
- Julian Maurice (7)
- Katrin Fischer (45)
- Lee Jamison (15)
- Magnus Enger (1)
- Marc Véron (3)
- Mark Tompsett (2)
- Mason James (70)
- Michael Cabus (1)
- Mirko Tietgen (3)
- Nick Clemens (6)
- Owen Leonard (2)
- Srdjan (1)
- Tomas Cohen Arazi (10)
- Brendan A Gallagher (2)
- Indranil Das Gupta (L2C2 Technologies) (1)
- Kyle M Hall (16)
- Marcel de Rooy (45)
- Israelex A Veleña for KohaCon17 (1)

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

Autogenerated release notes updated last on 30 Jul 2017 16:07:37.
