# RELEASE NOTES FOR KOHA 17.05.12
23 mai 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.12 is a bugfix/maintenance release.

It includes 1 enhancement, 22 bugfixes.

## Enhancements

### Cataloging

- [[19267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19267) Advanced Editor - Rancor - Add warning before leaving page if there are unsaved modifications

## Security bugs fixed

- [[20701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20701) maninvoice.pl is vulnerable for CSRF attacks
- [[20730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20701) Missing authentication check in serials/routing.pl

## Critical bugs fixed

### Acquisitions

- [[19030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19030) Link order <-> subscription is lost when an order is edited

### Hold requests

- [[18474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18474) Placing multiple holds from results breaks when patron is searched for

### Lists

- [[20687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20687) Multiple invitations to share lists prevents some users from accepting

### Notices

- [[18725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18725) process_message_queue.pl sends duplicate emails if message_queue is not writable


## Other bugs fixed

### Acquisitions

- [[20318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20318) Merge invoices can lead to an merged invoice without Invoice number

### Command-line Utilities

- [[20234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20234) Make maintenance scripts use koha-zebra instead of koha-*-zebra

### Course reserves

- [[20282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20282) Wrong attribute in template calls to match holding branch when adding/editing a course reserve item

### Lists

- [[11943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11943) Koha::Virtualshelfshare duplicates rows for the same list

### Notices

- [[19578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19578) TT syntax for notices - There is no way to pre-process DB fields

### OPAC

- [[20122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20122) Empty and close link on cart page not working

### Patrons

- [[19673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19673) Patron batch modification tool cannot use authorised value "0"
- [[20455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20455) Can't sort patron search on date expired

### Reports

- [[19671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19671) Circulation wizard / issues_stats.pl does not populate itemtype descriptions correctly

### Searching

- [[20369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20369) Analytics search is broken with QueryAutoTruncate set to 'only if * is added'

### Staff Client

- [[20227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20227) admin/smart-rules.pl should pass categorycode instead of branchcode

### Templates

- [[20552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20552) Fix HTML tag for search facets

### Test Suite

- [[20490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20490) Correct wrong bug number in comment in Circulation.t
- [[20503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20503) Borrower_PrevCheckout.t  is failing randomly
- [[20721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20721) Circulation.t keeps failing randomly

### Tools

- [[20462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20462) Duplicate barcodes in batch item deletion cause software error if deleting biblio records



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

- [Koha Manual](http://koha-community.org/manual/17.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.2%)
- Armenian (100%)
- Basque (78.7%)
- Chinese (China) (83.3%)
- Chinese (Taiwan) (99.8%)
- Czech (94.2%)
- Danish (68.8%)
- English (New Zealand) (90.6%)
- English (USA)
- Finnish (99.7%)
- French (96.2%)
- French (Canada) (94.5%)
- German (100%)
- German (Switzerland) (99.8%)
- Greek (79.8%)
- Hindi (100%)
- Italian (100%)
- Korean (50.2%)
- Norwegian Bokmål (57.4%)
- Occitan (post 1500) (76.3%)
- Persian (57.4%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (84.3%)
- Slovak (89.7%)
- Spanish (100%)
- Swedish (95.6%)
- Turkish (100%)
- Vietnamese (70.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.05.12 is

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
  - 16.11 -- [Chris Cormack](mailto:chris@bigballofwax.co.nz)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.05.12:

- BULAC - http://www.bulac.fr/

We thank the following individuals who contributed patches to Koha 17.05.12.

- Nick Clemens (4)
- Christophe Croullebois (1)
- Marcel de Rooy (5)
- Jonathan Druart (13)
- Claire Gravely (1)
- Kyle M Hall (3)
- Fridolin Somers (4)
- Lari Taskula (1)
- Mark Tompsett (1)
- Koha translators (1)
- Jesse Weaver (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.12

-  (0)
- BibLibre (5)
- BSZ BW (1)
- bugs.koha-community.org (13)
- ByWater-Solutions (6)
- bywatetsolutions.com (2)
- jns.fi (1)
- Rijksmuseum (5)
- unidentified (1)

We also especially thank the following individuals who tested patches
for Koha.

- claude brayer (1)
- Nick Clemens (7)
- Tomas Cohen Arazi (1)
- Roch D'Amour (1)
- Marcel de Rooy (9)
- Jonathan Druart (26)
- Charles Farmer (2)
- Katrin Fischer (6)
- Claire Gravely (1)
- Amit Gupta (2)
- Julian Maurice (1)
- Kyle M Hall (7)
- Josef Moravec (6)
- Séverine QUEUNE (3)
- Maksim Sen (1)
- Fridolin Somers (31)
- Mark Tompsett (6)


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

Autogenerated release notes updated last on 23 mai 2018 19:17:17.
