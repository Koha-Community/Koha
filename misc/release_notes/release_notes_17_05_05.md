# RELEASE NOTES FOR KOHA 17.05.05
23 oct. 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.05 is a bugfix/maintenance release.

It includes 6 enhancements, 70 bugfixes.




## Enhancements

### Acquisitions

- [[19257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19257) Warn when reopening a basket

### Circulation

- [[18292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18292) Tests do not need to return 1;

### Hold requests

- [[14353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14353) Show 'damaged' and other status on the 'place holds' page in staff

### OPAC

- [[17834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17834) Change library news text for single-branch libraries

### Patrons

- [[19258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19258) Warn when paying or writing off a fine or charge

### Tools

- [[18871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18871) It is unclear how to view a patron list

## Security bugs fixed

- [[18956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18956) Possibleprivacy breach with OPAC password recovery
- [[19117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19117) paycollect.pl is vulnerable for CSRF attacks
- [[19333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19333) XSS vulnerability in opac-shelves 

## Critical bugs fixed

### Acquisitions

- [[18351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18351) No warning when deleting budgets that have funds attached
- [[19120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19120) Order cancelled status is reset on basket open
- [[19372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19372) Selecting MARC framework doesn't work when adding to basket from an external source

### Cataloging

- [[19350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19350) Holds without link in 773 trigger SQL::Abstract::puke

### Hold requests

- [[19116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19116) Holds not set to waiting when "Confirm" is used
- [[19260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19260) Reservations / holds marked as problems being seen as expired ones and deleted wrongly.

### Lists

- [[19343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19343) Private lists displayed in search results list

### OPAC

- [[19122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19122) IncludeSeeFromInSearches is broken
- [[19366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19366) PatronSelfRegistrationEmailMustBeUnique pref makes it impossible to submit updates via OPAC

### Patrons

- [[19418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19418) Patron search is broken

### Searching - Elasticsearch

- [[18318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18318) Wrong unicode tokenization

### Serials

- [[19323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19323) subscription edit permission issue


## Other bugs fixed

### Acquisitions

- [[18941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18941) C4::Budgets GetBudgetByCode should return active budgets over inactive budgets
- [[19024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19024) Order cancelled status is reset on basket close
- [[19118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19118) Due to wrong variable name passed vendor name is  not coming in browser title bar

### Architecture, internals, and plumbing

- [[13012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13012) suggestion.suggesteddate should be set to NOW if not defined
- [[17699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17699) DateTime durations are not correctly subtracted
- [[19055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19055) GetReservesToBranch is not used
- [[19130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19130) K::A::Booksellers->search broken for attribute 'name'

### Circulation

- [[19007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19007) Allow paypal payments via debit or credit card again
- [[19027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19027) Circulation rules: Better wording for standard rules for all libraries
- [[19076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19076) Renewal via Checkout screen is logged as both a renewal and a checkout

### Course reserves

- [[19228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19228) Confirm delete doesn't show when deleting an item from course
- [[19229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19229) Clicking Cancel when editing course doesn't take you back to the course

### Documentation

- [[18817]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18817) Update links in the help files for the new 17.11 manual

### Hold requests

- [[18469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18469) Suspend all holds when specifying a date to resume hold does not keep date

### I18N/L10N

- [[18537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18537) Update Ukrainian installer sample files for 17.05
- [[18687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18687) Translatability: abbr tag should not contain lang attribute
- [[18754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18754) Translatability: Get rid of exposed tt directives in opac-detail.tt
- [[18776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18776) Translatability: Get rid of exposed tt directives in opac-advsearch.tt
- [[18777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18777) Translatability: Get rid of exposed tt directives in opac-memberentry.tt
- [[18779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18779) Translatability: Get rid of exposed tt directives in authorities-search-results.inc (OPAC)
- [[18780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18780) Translatability: Get rid of exposed tt directive in masthead-langmenu.inc
- [[18781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18781) Translatability: Get rid of exposed tt directives in openlibrary-readapi.inc

### Installation and upgrade (command-line installer)

- [[9409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9409) koha-create --request-db should be able to accept a dbhost option

### Lists

- [[15924]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15924) Coce not enabled on lists

### Notices

- [[19134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19134) C4::SMS does not handle drivers with more than two names well

### OPAC

- [[5471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5471) Quotes in tags cause moderation approval/rejection to fail
- [[9857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9857) Did you mean? from authorities uses incorrect punctuation
- [[18692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18692) When SMS is enabled the OPAC messaging table is misaligned
- [[18946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18946) Change language from external web fails

### Patrons

- [[18621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18621) After duplicate message system picks category expiry date rather than manual defined
- [[18636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18636) Can not save new patron on fresh install (Conflict between autoMemberNum and BorrowerMandatoryField)
- [[19129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19129) Clean up templates for organisation patrons in staff

### Reports

- [[18985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18985) SQL reports 'Last edit' and 'Last run' columns sort alphabetically, not chronologically

### SIP2

- [[18812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18812) SIP Patron status does not respect OverduesBlockCirc

### Searching

- [[16485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16485) Collection column in Item search is always empty

### Test Suite

- [[18802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18802) Circulation.t fails if finesMode != "Do not calculate"
- [[18897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18897) Elastic related tests do not skip when ES modules are not installed
- [[19003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19003) Add a TestBuilder default for borrowers.login_attempts
- [[19004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19004) Koha/Patrons.t fails when item-level_itypes is not set
- [[19009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19009) Circulation.t is still failing randomly
- [[19013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19013) sample_data.sql inserts patrons with guarantorid that do not exist
- [[19042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19042) Silence warnings t/db_dependent/Letters.t
- [[19047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19047) Fix AddBiblio call in Reserves.t
- [[19070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19070) Fix Circulation/Branch.t
- [[19071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19071) Fix Circulation/issue.t and Members/IssueSlip.t
- [[19126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19126) Fix Members.t with IndependentBranches set
- [[19227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19227) 00-merge-conflict-markers.t launches too many tests
- [[19335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19335) 00-merge-markers.t fails
- [[19385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19385) t/Calendar.t is failing randomly
- [[19391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19391) auth_values_input_www.t  is failing because of bug 19128
- [[19437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19437) Rearrange CancelExpiredReserves tests
- [[19440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19440) XISBN tests should skip if XISBN returns overlimit error

### Tools

- [[14316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14316) Clarify meaning of record number in Batch record deletion tool
- [[19081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19081) Plack preventing uninstalled plugins from being removed on the plugins list
- [[19088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19088) plugins-upload.pl causes uninitialized value noise



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
- Chinese (Taiwan) (99%)
- Czech (94%)
- Danish (69%)
- English (New Zealand) (91%)
- Finnish (99%)
- French (96%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (99%)
- Greek (79%)
- Hindi (96%)
- Italian (99%)
- Norwegian Bokmål (58%)
- Occitan (76%)
- Persian (58%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (84%)
- Slovak (90%)
- Spanish (99%)
- Swedish (96%)
- Turkish (100%)
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

The release team for Koha 17.05.05 is

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
new features in Koha 17.05.05:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 17.05.05.

- Aleisha Amohia (10)
- Alex Arnaud (1)
- Alex Buckley (1)
- Colin Campbell (2)
- Nick Clemens (10)
- Tomás Cohen Arazi (7)
- Marcel de Rooy (14)
- Jonathan Druart (33)
- Serhij Dubyk {Сергій Дубик} (1)
- Magnus Enger (1)
- Katrin Fischer (6)
- Amit Gupta (1)
- Lee Jamison (2)
- Olli-Antti Kivilahti (1)
- Owen Leonard (2)
- Kyle M Hall (3)
- Josef Moravec (6)
- Joy Nelson (1)
- Dobrica Pavlinusic (1)
- Karam Qubsi (1)
- Fridolin Somers (6)
- Lari Taskula (1)
- Mark Tompsett (10)
- Marc Véron (11)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.05

- ACPL (2)
- BibLibre (7)
- BSZ BW (6)
- bugs.koha-community.org (33)
- ByWater-Solutions (14)
- Catalyst (1)
- informaticsglobal.com (1)
- jns.fi (2)
- Libriotech (1)
- Marc Véron AG (11)
- marywood.edu (2)
- PTFS-Europe (2)
- Rijksmuseum (14)
- rot13.org (1)
- Theke Solutions (7)
- unidentified (28)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (4)
- Alex Buckley (9)
- anafe (1)
- Chris Kirby (1)
- Christopher Brannon (1)
- Claire Gravely (2)
- Dilan Johnpullé (1)
- Felix Hemme (1)
- Frédéric Demians (1)
- Fridolin Somers (116)
- George Williams (1)
- Hugo Agud (1)
- iflora (1)
- Jonathan Druart (134)
- Josef Moravec (5)
- Julian Maurice (10)
- Katrin Fischer (13)
- Laurence Rault (1)
- Lee Jamison (8)
- Magnus Enger (1)
- Marc Veron (1)
- Marc Véron (4)
- maricris (1)
- Marijana Glavica (2)
- Mark Tompsett (24)
- Nick Clemens (6)
- Owen Leonard (17)
- Tomas Cohen Arazi (16)
- Michael Andrew Cabus (2)
- Kyle M Hall (30)
- Caroline Cyr La Rose (1)
- Marcel de Rooy (38)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.05.x.
The last Koha release was 17.05.04, which was released on sept. 20, 2017.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 oct. 2017 12:36:12.
