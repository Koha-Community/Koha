# RELEASE NOTES FOR KOHA 16.11.10
25 Jul 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.10 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.10.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.10 is a bugfix/maintenance release.

It includes 1 enhancements, 35 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[18931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18931) Add a "data corrupted" section on the about page


## Critical bugs fixed

### Acquisitions

- [[18756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18756) Users can view aq.baskets even if they are not allowed

### Architecture, internals, and plumbing

- [[18966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18966) Move of checkouts - Deal with duplicate IDs at DBMS level

### MARC Bibliographic record staging/import

- [[18577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18577) Importing a batch using a framework not fully set up causes and endless loop

### OPAC

- [[18572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18572) Improper branchcode  set during OPAC renewal
- [[18955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18955) autocomplete is on in OPAC password recovery

### Test Suite

- [[18807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18807) www/batch.t is failing
- [[18826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18826) REST API tests do not clean up

### Tools

- [[18806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18806) Cannot revert a batch

### Z39.50 / SRU / OpenSearch Servers

- [[18910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18910) Regression: Z39.50 wrong conversion in Unimarc by Bug 18152


## Other bugs fixed

### Acquisitions

- [[18830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18830) Message to user is poorly constructed

### Architecture, internals, and plumbing

- [[14572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14572) insert_single_holiday() forces a value on an AUTO_INCREMENT column, during an INSERT
- [[18771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18771) CGI.pm: Subroutine multi_param redefined
- [[18824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18824) Remove stray i from matching-rules.tt

### Database

- [[18848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18848) borrowers.lastseen comment typo

### Documentation

- [[18554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18554) Adjust a few typos including responsability

### I18N/L10N

- [[18699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18699) Get rid of %%] in translation for edi_accounts.tt
- [[18703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18703) Translatability: Resolve some remaining %%] problems for staff client in 6 Files
- [[18800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18800) Patron card images: Add some more explanation to upload page and fix small translatability issue
- [[18901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18901) Sysprefs translation: translate only *.pref files (not *.pref*)

### Label/patron card printing

- [[17181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17181) Patron card creator replaces existing image when uploading image with same name

### Lists

- [[18214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18214) Cannot edit list permissions of a private list

### OPAC

- [[18400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18400) Noisy warns in opac-search.pl during itemtype sorting
- [[18634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18634) Missing empty line at end of opac.pref / colliding translated preference sections

### Patrons

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
- Armenian (96%)
- Chinese (China) (85%)
- Chinese (Taiwan) (99%)
- Czech (95%)
- Danish (71%)
- English (New Zealand) (93%)
- Finnish (100%)
- French (99%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (100%)
- Greek (82%)
- Hindi (99%)
- Italian (100%)
- Korean (52%)
- Norwegian Bokmål (57%)
- Occitan (78%)
- Persian (59%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (86%)
- Slovak (92%)
- Spanish (100%)
- Swedish (98%)
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

The release team for Koha 16.11.10 is

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
new features in Koha 16.11.10:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.11.10.

- apirak (1)
- root (1)
- Aleisha Amohia (3)
- Colin Campbell (2)
- Nick Clemens (4)
- Tomás Cohen Arazi (1)
- Chris Cormack (1)
- Christophe Croullebois (1)
- Marcel de Rooy (14)
- Jonathan Druart (19)
- Katrin Fischer (3)
- Koha instance kohadev-koha (1)
- Mason James (2)
- Lee Jamison (2)
- Owen Leonard (1)
- Julian Maurice (3)
- Josef Moravec (1)
- Rodrigo Santellan (1)
- Fridolin Somers (2)
- Mark Tompsett (3)
- Marc Véron (5)
- Baptiste Wojtkowski (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.10

- ACPL (1)
- BibLibre (8)
- BigBallOfWax (1)
- BSZ BW (3)
- bugs.koha-community.org (19)
- ByWater-Solutions (4)
- KohaAloha (2)
- kohadevbox (1)
- Marc Véron AG (5)
- marywood.edu (2)
- PTFS-Europe (2)
- punsarn.asia (1)
- Rijksmuseum (14)
- Theke Solutions (1)
- translate.koha-community.org (1)
- unidentified (8)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (2)
- Blou (1)
- Chris Cormack (4)
- Chris Kirby (1)
- Claire Gravely (1)
- David Kuhn (1)
- Frédéric Demians (1)
- Fridolin Somers (66)
- Jonathan Druart (56)
- Josef Moravec (17)
- Julian Maurice (5)
- Katrin Fischer (70)
- Lee Jamison (11)
- Magnus Enger (1)
- Marc Véron (2)
- Mark Tompsett (1)
- Mirko Tietgen (1)
- Nick Clemens (4)
- Owen Leonard (2)
- Srdjan (1)
- Tomas Cohen Arazi (8)
- Brendan A Gallagher (4)
- Indranil Das Gupta (L2C2 Technologies) (1)
- Kyle M Hall (16)
- Marcel de Rooy (32)
- Israelex A Veleña for KohaCon17 (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.
The last Koha release was 16.11.09, which was released on June 22, 2017.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Jul 2017 18:14:00.
