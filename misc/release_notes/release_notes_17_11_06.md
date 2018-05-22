# RELEASE NOTES FOR KOHA 17.11.06
22 May 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.06 is a bugfix/maintenance release.

It includes 4 enhancements, 35 bugfixes.




## Enhancements

### Cataloging

- [[19267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19267) Advanced Editor - Rancor - Add warning before leaving page if there are unsaved modifications

### Searching - Elasticsearch

- [[19582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19582) Elasticsearch: Auth-finder.pl must use search_auth_compat
- [[20386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20386) Improve warning and error messages for Search Engine Configuration

### Templates

- [[19892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19892) Replace numbersphr variable with Koha.Preference('OPACNumbersPreferPhrase') in OPAC


## Critical bugs fixed

### Acquisitions

- [[19030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19030) Link order <-> subscription is lost when an order is edited
- [[20426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20426) Can't import all titles from a stage file with default values

### Architecture, internals, and plumbing

- [[20325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20325) C4::Accounts::purge_zero_balance_fees does not check account_offsets

### Fines and fees

- [[20562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20562) issue_id is not stored in accountlines for rental fees

### Hold requests

- [[18474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18474) Placing multiple holds from results breaks when patron is searched for

### ILL

- [[20556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20556) Marking ILL request as complete results in "Internal server error"

### Lists

- [[20687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20687) Multiple invitations to share lists prevents some users from accepting

### Notices

- [[18725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18725) process_message_queue.pl sends duplicate emails if message_queue is not writable

### REST api

- [[19546]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19546) Make koha-plack run Starman from the instance's directory

### Searching - Elasticsearch

- [[20385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20385) ElasticSearch authority search raises Software error

### Staff Client

- [[19223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19223) Avoid encoding issues in plugins by providing helper methods to output headers correctly

> The current plugin writing practice is to craft the response header in the controller methods. This patchset adds new helper methods for plugin authors to use when dealing with output on their plugins. This way the end-user experience is better, and the plugin author's tasks easier.




## Other bugs fixed

### Acquisitions

- [[3841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3841) Add a Default ACQ framework
- [[19812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19812) Holds count in "Already received" table has confusing and unexpected values
- [[19916]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19916) Can't search keyword or standard ID from Acquisitions external source / z3950
- [[20318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20318) Merge invoices can lead to an merged invoice without Invoice number

### Circulation

- [[20536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20536) ILL: authnotrequired not explicitly unset

### Course reserves

- [[20282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20282) Wrong attribute in template calls to match holding branch when adding/editing a course reserve item

### I18N/L10N

- [[20330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20330) Allow translating more of quote upload

### Lists

- [[11943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11943) Koha::Virtualshelfshare duplicates rows for the same list

### Notices

- [[19578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19578) TT syntax for notices - There is no way to pre-process DB fields

### OPAC

- [[20122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20122) Empty and close link on cart page not working

### Patrons

- [[19673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19673) Patron batch modification tool cannot use authorised value "0"
- [[19907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19907) Email validation on patron add/edit not working
- [[20455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20455) Can't sort patron search on date expired

### Reports

- [[19583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19583) Report updater triggers on auth_header.marcxml
- [[19910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19910) Download report as 'Comma separated' is misleading

### Searching

- [[20369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20369) Analytics search is broken with QueryAutoTruncate set to 'only if * is added'

### Searching - Elasticsearch

- [[19564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19564) Fix extraction of sort order from sort condition name
- [[19581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19581) Elasticsearch - Catmandu split option adds extra null fields to indexes

### Templates

- [[20552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20552) Fix HTML tag for search facets

### Test Suite

- [[20490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20490) Correct wrong bug number in comment in Circulation.t
- [[20503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20503) Borrower_PrevCheckout.t  is failing randomly
- [[20584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20584) Koha/Patron/Categories.t is on slow servers
- [[20721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20721) Circulation.t keeps failing randomly

### Tools

- [[20462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20462) Duplicate barcodes in batch item deletion cause software error if deleting biblio records

## Security bugs fixed


- [[20701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20701) maninvoice.pl is vulnerable for CSRF attacks
- [[20730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20730) Missing authentication check in serials/routing.pl

## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.7%)
- Armenian (100%)
- Basque (75.5%)
- Chinese (China) (79.9%)
- Chinese (Taiwan) (100%)
- Czech (94%)
- Danish (65.8%)
- English (New Zealand) (99.7%)
- English (USA)
- Finnish (95.8%)
- French (98.4%)
- French (Canada) (92.2%)
- German (100%)
- German (Switzerland) (99.6%)
- Greek (80.1%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (54.6%)
- Occitan (post 1500) (73%)
- Persian (54.9%)
- Polish (97.7%)
- Portuguese (100%)
- Portuguese (Brazil) (83.7%)
- Slovak (96.6%)
- Spanish (100%)
- Swedish (91.9%)
- Turkish (100%)
- Vietnamese (67.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.06 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- Release Manager assistant: [Nick Clemens](mailto:nick@bywatersolutions.com)

- QA Team:
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - Claire Gravely
  - Josef Moravec
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.06:

- BULAC - http://www.bulac.fr/
- ByWater Solutions

We thank the following individuals who contributed patches to Koha 17.11.06.

- Alex Arnaud (1)
- Nick Clemens (16)
- Tomás Cohen Arazi (3)
- Charlotte Cordwell (1)
- Christophe Croullebois (1)
- Marcel de Rooy (5)
- Jonathan Druart (22)
- Claire Gravely (2)
- David Gustafsson (1)
- Andrew Isherwood (1)
- Pasi Kallinen (1)
- Owen Leonard (1)
- Kyle M Hall (7)
- Josef Moravec (1)
- Martin Renvoize (1)
- Lari Taskula (1)
- Mark Tompsett (1)
- Koha translators (1)
- Jesse Weaver (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.06

-  (0)
- ACPL (1)
- BibLibre (2)
- BSZ BW (2)
- bugs.koha-community.org (22)
- ByWater-Solutions (20)
- bywatetsolutions.com (4)
- Göteborgs universitet (1)
- jns.fi (1)
- joensuu.fi (1)
- PTFS-Europe (2)
- Rijksmuseum (5)
- Theke Solutions (3)
- unidentified (3)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan A Gallagher (1)
- Alex Arnaud (6)
- Sonia Bouis (1)
- David Bourgault (4)
- claude brayer (1)
- Nick Clemens (21)
- Tomas Cohen Arazi (3)
- Roch D'Amour (2)
- Marcel de Rooy (12)
- Jonathan Druart (61)
- Charles Farmer (2)
- Katrin Fischer (17)
- Victor Grousset (1)
- Amit Gupta (2)
- Pasi Kallinen (1)
- Nancy Keener (1)
- Nicolas Legrand (7)
- Owen Leonard (1)
- Julian Maurice (5)
- Kyle M Hall (11)
- Josef Moravec (9)
- Séverine QUEUNE (3)
- Maksim Sen (2)
- Mark Tompsett (9)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.11.X.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 May 2018 12:01:21.
