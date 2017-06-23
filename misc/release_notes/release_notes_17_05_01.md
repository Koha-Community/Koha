# RELEASE NOTES FOR KOHA 17.05.01
23 juin 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.01 is a major release, that comes with many new features.

It includes 2 enhancements, 48 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[18278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18278) C4::Items - Remove GetItemLocation
- [[18295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18295) C4::Items - Remove get_itemnumbers_of


## Critical bugs fixed

(this list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Architecture, internals, and plumbing

- [[18651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18651) Move of checkouts is still not correctly handled
- [[18727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18727) System preferences loose part of values because of double quotes

### Circulation

- [[18179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18179) Koha::Objects->find should not be called in list context
- [[18835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18835) SQL syntax error in overdue_notices.pl

### Installation and upgrade (web-based installer)

- [[18741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18741) Web installer does not load default data

### Patrons

- [[18685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18685) Patron edit/cancel floating toolbar out of place

### Tools

- [[18689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18689) Fix calendar error with double quotes in title or description of holiday


## Other bugs fixed

(this list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[11122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11122) Fix display of publication year/copyrightdate and publishercode on various pages in acquisitions
- [[18722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18722) Subtotal information not showing fund source

### Architecture, internals, and plumbing

- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[18716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18716) CGI::param in list context warns in updatesupplier.pl
- [[18794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18794) OAI/Server.t fails on slow servers

### Database

- [[18690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18690) Typos in Koha database description (Table "borrowers")

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

### Installation and upgrade (web-based installer)

- [[17944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17944) Remove the sql code from itemtypes.pl administrative perl script
- [[18702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18702) Translatability: Get rid of exposed if statement in tt for translated onboardingstep2.tt

### MARC Bibliographic record staging/import

- [[17710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17710) C4::Matcher::get_matches and C4::ImportBatch::GetBestRecordMatch should use same logic

### OPAC

- [[13913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13913) Renewal error message in OPAC is confusing

### Reports

- [[18734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18734) Internal server error in cash_register_stats.pl when exporting to file

### Serials

- [[13747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13747) Fix problems with frequency descriptions containing quotes

### Staff Client

- [[18673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18673) News author does not display on staff client home page

### System Administration

- [[18700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18700) Fix ungrammatical sentence

### Templates

- [[18656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18656) Require confirmation of deletion of files from patron record

### Test Suite

- [[18411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18411) t/db_dependent/www/search_utf8.t  fails
- [[18601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18601) OAI/Sets.t mangles data due to truncate in ModOAISetsBiblios
- [[18732]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18732) Noisy t/SMS.t triggered by koha_conf.xml without sms_send_config
- [[18746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18746) Text_CSV_Various.t parse failure
- [[18749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18749) xt/sample notices fails with "No sample notice to delete"
- [[18759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18759) Circulation.t is failing randomly
- [[18761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18761) AutomaticItemModificationByAge.t tests are failing
- [[18762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18762) Some tests are noisy
- [[18763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18763) swagger/definitions.t is failing
- [[18766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18766) ArticleRequests.t raises warnings
- [[18767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18767) Useless debugging info in GetDailyQuote.t
- [[18773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18773) t/db_dependent/www/history.t is failing

### Tools

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
- Arabic (100%)
- Armenian (99%)
- Chinese (China) (84%)
- Chinese (Taiwan) (100%)
- Czech (95%)
- Danish (69%)
- English (New Zealand) (91%)
- Finnish (97%)
- French (97%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (100%)
- Greek (77%)
- Hindi (96%)
- Italian (100%)
- Korean (51%)
- Norwegian Bokmål (55%)
- Occitan (77%)
- Persian (58%)
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

The release team for Koha 17.05.01 is

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
new features in Koha 17.05.01:


We thank the following individuals who contributed patches to Koha 17.05.01.

- Alex Buckley (1)
- Colin Campbell (1)
- Nick Clemens (3)
- Tomás Cohen Arazi (3)
- David Cook (1)
- Marcel de Rooy (3)
- Jonathan Druart (25)
- Katrin Fischer (1)
- Lee Jamison (2)
- Owen Leonard (3)
- Julian Maurice (1)
- Josef Moravec (1)
- Fridolin Somers (4)
- Mark Tompsett (6)
- Marc Véron (18)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.01

- ACPL (3)
- BibLibre (5)
- BSZ BW (1)
- bugs.koha-community.org (25)
- ByWater-Solutions (3)
- Catalyst (1)
- Marc Véron AG (18)
- marywood.edu (2)
- Prosentient Systems (1)
- PTFS-Europe (1)
- Rijksmuseum (3)
- Theke Solutions (3)
- unidentified (7)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (4)
- Chris Cormack (5)
- David Roberts (1)
- Fridolin Somers (68)
- Jason Palmer (1)
- Jonathan Druart (59)
- Josef Moravec (12)
- Katrin Fischer (2)
- Lee Jamison (11)
- Marc Véron (5)
- Mark Tompsett (3)
- Michael Cabus (1)
- Nick Clemens (3)
- Owen Leonard (1)
- Tomas Cohen Arazi (3)
- Kyle M Hall (4)
- Marcel de Rooy (20)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.05.x.


## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 juin 2017 07:13:42.
