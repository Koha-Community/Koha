# RELEASE NOTES FOR KOHA 17.05.02
27 juil. 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.02 is a bugfix/maintenance release.

It includes 4 enhancements, 38 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[18782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18782) Remove unused C4::Serials::getsupplierbyserialid
- [[18931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18931) Add a "data corrupted" section on the about page

### Circulation

- [[18881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18881) Remove dead code in circ/view_holdsqueue.pl

### I18N/L10N

- [[18703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18703) Translatability: Resolve some remaining %%] problems for staff client in 6 Files


## Critical bugs fixed

### Acquisitions

- [[18756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18756) Users can view aq.baskets even if they are not allowed

### Architecture, internals, and plumbing

- [[18966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18966) Move of checkouts - Deal with duplicate IDs at DBMS level

### Authentication

- [[18880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18880) Regression breaks local authentication fallback for all external authentications

### MARC Bibliographic record staging/import

- [[18577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18577) Importing a batch using a framework not fully set up causes and endless loop

### OPAC

- [[18572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18572) Improper branchcode  set during OPAC renewal
- [[18938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18938) opac/svc/patron_notes and opac/opac-issue-note.pl use GetMember
- [[18955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18955) autocomplete is on in OPAC password recovery

### Searching

- [[18434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18434) Elasticsearch indexing broken with newer catmandu version

### Test Suite

- [[18807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18807) www/batch.t is failing
- [[18826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18826) REST API tests do not clean up

### Tools

- [[18806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18806) Cannot revert a batch
- [[18870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18870) Patron Clubs breaks when creating a club

### Z39.50 / SRU / OpenSearch Servers

- [[18910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18910) Regression: Z39.50 wrong conversion in Unimarc by Bug 18152


## Other bugs fixed

### Acquisitions

- [[18830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18830) Message to user is poorly constructed

### Architecture, internals, and plumbing

- [[14572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14572) insert_single_holiday() forces a value on an AUTO_INCREMENT column, during an INSERT
- [[18633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18633) Logs are full of CGI::param called in list context - itemsearch.pl
- [[18771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18771) CGI.pm: Subroutine multi_param redefined
- [[18824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18824) Remove stray i from matching-rules.tt

### Database

- [[18848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18848) borrowers.lastseen comment typo

### I18N/L10N

- [[18699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18699) Get rid of %%] in translation for edi_accounts.tt
- [[18800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18800) Patron card images: Add some more explanation to upload page and fix small translatability issue
- [[18901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18901) Sysprefs translation: translate only *.pref files (not *.pref*)

### Lists

- [[18214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18214) Cannot edit list permissions of a private list

### OPAC

- [[16711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16711) OPAC Password recovery: Handling if multiple accounts have the same mail address
- [[18634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18634) Missing empty line at end of opac.pref / colliding translated preference sections

### Patrons

- [[18630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18630) Translatability (Clubs): 'Cancel' is ambiguous and leads to mistakes
- [[18858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18858) Warn when deleting a borrower debarment

### Reports

- [[11235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11235) Names for reports and dictionary are cut off when quotes are used
- [[13452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13452) Average checkout report always uses biblioitems.itemtype

### SIP2

- [[18755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18755) Allow empty password fields in Patron Info requests

> Some SIP devices expect an empty password field in a patron info request to be accepted as OK by the server. Since patch for bug 16610 was applied this is not the case. This reinstates the old behaviour for sip logins with the parameter allow_empty_passwords="1"



### Serials

- [[18356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18356) Prediction pattern wrong, skips years, for some year based frequencies
- [[18607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18607) Fix date calculations for monthly frequencies in Serials
- [[18697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18697) Fix date calculations for day/week frequencies in Serials

### System Administration

- [[18934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18934) Warns in Admin -> SMS providers

### Templates

- [[17639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17639) Remove white filling inside of Koha logo

### Test Suite

- [[18748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18748) Noisy t/db_dependent/AuthorisedValues.t
- [[18804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18804) Selenium tests are failing

### Tools

- [[18613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18613) Deleting a Letter from a library as superlibrarian deletes the "All libraries" rule



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
- Armenian (100%)
- Chinese (China) (84%)
- Chinese (Taiwan) (99%)
- Czech (95%)
- Danish (69%)
- English (New Zealand) (91%)
- Finnish (99%)
- French (97%)
- French (Canada) (91%)
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
- Portuguese (100%)
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

The release team for Koha 17.05.02 is

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
new features in Koha 17.05.02:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 17.05.02.

- Aleisha Amohia (2)
- Colin Campbell (2)
- Nick Clemens (7)
- Tomás Cohen Arazi (3)
- Chris Cormack (1)
- Christophe Croullebois (1)
- Marcel de Rooy (15)
- Jonathan Druart (21)
- Katrin Fischer (2)
- Mason James (1)
- Lee Jamison (2)
- Owen Leonard (1)
- Julian Maurice (6)
- Josef Moravec (1)
- Rodrigo Santellan (1)
- Fridolin Somers (3)
- Mark Tompsett (3)
- Marc Véron (8)
- Baptiste Wojtkowski (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.02

- ACPL (1)
- BibLibre (12)
- BigBallOfWax (1)
- BSZ BW (2)
- bugs.koha-community.org (21)
- ByWater-Solutions (7)
- KohaAloha (1)
- Marc Véron AG (8)
- marywood.edu (2)
- PTFS-Europe (2)
- Rijksmuseum (15)
- Theke Solutions (3)
- unidentified (7)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (1)
- Alex Buckley (2)
- Blou (1)
- Chris Cormack (5)
- Chris Kirby (1)
- David Kuhn (1)
- Frédéric Demians (1)
- Fridolin Somers (83)
- Jonathan Druart (70)
- Josef Moravec (19)
- Julian Maurice (6)
- Katrin Fischer (2)
- Lee Jamison (12)
- Magnus Enger (1)
- Marc Véron (3)
- Mark Tompsett (2)
- Mirko Tietgen (1)
- Nick Clemens (6)
- Owen Leonard (2)
- Srdjan (1)
- Tomas Cohen Arazi (13)
- Brendan A Gallagher (4)
- Indranil Das Gupta (L2C2 Technologies) (1)
- Kyle M Hall (14)
- Marcel de Rooy (38)
- Israelex A Veleña for KohaCon17 (1)

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

Autogenerated release notes updated last on 27 juil. 2017 11:45:06.
