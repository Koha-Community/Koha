# RELEASE NOTES FOR KOHA 18.05.01
22 Jun 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.01 is a bugfix/maintenance release.

It includes 42 bugfixes.






## Critical bugs fixed

### Acquisitions

- [[20798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20798) Client side validation for for fund selection prevents adding only some records to a basket
- [[20827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20827) Can't add owner to a fund
- [[20861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20861) Correct EDI permissions on some pages

### Architecture, internals, and plumbing

- [[18821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18821) TrackLastPatronActivity is a performance killer
- [[20918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20918) left-side navigation broken on the checkout history page
- [[20922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20922) Koha::Number::Price must not be used in updatedatabase.pl

### Cataloging

- [[20761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20761) Advanced Cataloging Editor - Rancor - Some js files are not fetched using Asset

### Circulation

- [[20825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20825) Cannot checkout if item types at biblio level
- [[20889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20889) Items marked as not for loan can be checked out

### Fines and fees

- [[20840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20840) Internal Server Error when clicking on "Details" button

### Hold requests

- [[20822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20822) Can't find HOLD_SLIP template when printing

### OPAC

- [[20763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20763) AllowPurchaseSuggestionBranchChoice triggers error opac-suggestions.pl is visited without logging in
- [[20832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20832) Opac user page crash when there is an overdue fine and not any rental charge for a patron
- [[20875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20875) OpacAddMastheadLibraryPulldown displays an empty list

### Patrons

- [[20981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20981) Organization name missing from patron search results

### Searching

- [[20838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20838) Search by group of libraries is broken

### Staff Client

- [[20652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20652) Sort after item type search fails
- [[20899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20899) Patron name not showing on issuehistory.pl


## Other bugs fixed

### About

- [[20818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20818) Missing QA manager entry in 18.05 release notes

### Acquisitions

- [[20892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20892) Wrong basketgroup link in histsearch.pl

### Architecture, internals, and plumbing

- [[20696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20696) Remove a few ugly "eq undef" comparisons
- [[20767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20767) "The method is not covered by tests!" should give more information
- [[20851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20851) Missing module in circ/article-request-slip.pl
- [[20886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20886) Koha::Object::TO_JSON indiscriminately casting to integer
- [[20911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20911) Search history page forms use 'GET' and this limits the number of entries that can be submitted

### Cataloging

- [[19970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19970) Revise change of bug 19413 to work better for translations
- [[20760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20760) Advanced Cataloging Editor - Rancor - AuthorisedValues are incorrectly fetched
- [[20829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20829) 'Link to host item' gives internal server error

### Circulation

- [[17561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17561) ReserveSlip needs itemnumber for item level holds on same biblio
- [[20120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20120) Prevent writeoffs of more than the amount owed for a fee

### Fines and fees

- [[20285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20285) Lost item refund won't always pay down lost item fee first

### MARC Bibliographic data support

- [[20700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20700) Update MARC21 leader/007/008 codes

### OPAC

- [[20053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20053) Drop type attribute "text/javascript" for <script> elements used in OPAC templates

> Prevents warnings about type attribute being generated for <script> elements when testing the OPAC pages using W3C Validator for HTML5.


- [[20756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20756) OPAC "Share list" button should be styled with an icon

### Patrons

- [[3886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3886) Can't print receipt w/out allowing "Add or modify borrowers" permission

### Serials

- [[20778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20778) Unable to delete a subscription

### Staff Client

- [[20781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20781) 0 months is not a valid enrollment period and causes errors

### Templates

- [[20752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20752) Files tab in patron account is not properly capitalized
- [[20774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20774) Trivial HTML error in itemslost.tt
- [[20791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20791) Correct capitalization on 'Notices and slips' page
- [[20831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20831) (Bug 9573 follow-up) Pass id as first parameter instead of selector

### Test Suite

- [[20866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20866) ArticleRequests.t fails on existing requests



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

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98%)
- Armenian (99.9%)
- Basque (73.6%)
- Chinese (China) (77.9%)
- Chinese (Taiwan) (100%)
- Czech (92.2%)
- Danish (64.4%)
- English (New Zealand) (96.9%)
- English (USA)
- Finnish (93%)
- French (100%)
- French (Canada) (89.6%)
- German (100%)
- German (Switzerland) (99.9%)
- Greek (79.7%)
- Hindi (100%)
- Italian (98.2%)
- Norwegian Bokmål (65.7%)
- Occitan (post 1500) (71.2%)
- Persian (53.6%)
- Polish (95.1%)
- Portuguese (99.9%)
- Portuguese (Brazil) (82.1%)
- Slovak (95.3%)
- Spanish (99.9%)
- Swedish (95.1%)
- Turkish (99.9%)
- Vietnamese (65.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.01 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)

- Release Manager assistants:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)

- Module Maintainers:
  - REST API -- [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - Elasticsearch -- [Nick Clemens](mailto:nick@bywatersolutions.com)

- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)

- QA Team:
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - Josef Moravec
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)

- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.inc)
  - [Amit Gupta](mailto:amitddng135@gmail.com)

- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)

- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose

- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)

- Release Maintainers:
  - 18.05 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.01:


 We thank the following individuals who contributed patches to Koha 18.05.01.

- Nick Clemens (6)
- Marcel de Rooy (4)
- Jonathan Druart (26)
- Katrin Fischer (4)
- Bernardo González Kriegel (1)
- Owen Leonard (5)
- Kyle M Hall (10)
- Josef Moravec (2)
- Martin Renvoize (2)
- Benjamin Rokseth (1)
- Fridolin Somers (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.01

- ACPL (5)
- BibLibre (2)
- BSZ BW (4)
- bugs.koha-community.org (26)
- ByWater-Solutions (8)
- bywatetsolutions.com (8)
- deichman.no (1)
- PTFS-Europe (2)
- Rijksmuseum (4)
- unidentified (2)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Blou (1)
- Nick Clemens (60)
- Tomas Cohen Arazi (4)
- Chris Cormack (5)
- Marcel de Rooy (20)
- Jonathan Druart (17)
- Charles Farmer (2)
- Katrin Fischer (16)
- Brendan Gallagher (1)
- Amit Gupta (1)
- Andrew Isherwood (2)
- Jon Knight (1)
- Pierre-Luc Lapointe (2)
- Owen Leonard (6)
- Julian Maurice (1)
- Kyle M Hall (7)
- Josef Moravec (2)
- Séverine QUEUNE (3)
- Martin Renvoize (66)
- Maksim Sen (1)
- Maryse Simard (2)
- Mark Tompsett (5)
- Ed Veal (1)
- George Williams (1)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
t racker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jun 2018 09:34:17.
