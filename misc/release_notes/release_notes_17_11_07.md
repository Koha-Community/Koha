# RELEASE NOTES FOR KOHA 17.11.07
25 juin 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.07 is a bugfix/maintenance release.

It includes 1 enhancements, 28 bugfixes.




## Enhancements

### Circulation

- [[20343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20343) Show number of checkouts by itemtype in circulation.pl


## Critical bugs fixed

### Acquisitions

- [[20798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20798) Client side validation for for fund selection prevents adding only some records to a basket
- [[20827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20827) Can't add owner to a fund
- [[20861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20861) Correct EDI permissions on some pages

### Architecture, internals, and plumbing

- [[18821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18821) TrackLastPatronActivity is a performance killer
- [[20922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20922) Koha::Number::Price must not be used in updatedatabase.pl

### OPAC

- [[20763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20763) AllowPurchaseSuggestionBranchChoice triggers error opac-suggestions.pl is visited without logging in

### Staff Client

- [[20652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20652) Sort after item type search fails


## Other bugs fixed

### Acquisitions

- [[20892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20892) Wrong basketgroup link in histsearch.pl

### Architecture, internals, and plumbing

- [[20696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20696) Remove a few ugly "eq undef" comparisons
- [[20767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20767) "The method is not covered by tests!" should give more information
- [[20851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20851) Missing module in circ/article-request-slip.pl
- [[20911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20911) Search history page forms use 'GET' and this limits the number of entries that can be submitted

### Cataloging

- [[19970]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19970) Revise change of bug 19413 to work better for translations
- [[20760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20760) Advanced Cataloging Editor - Rancor - AuthorisedValues are incorrectly fetched
- [[20829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20829) 'Link to host item' gives internal server error

### Circulation

- [[17561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17561) ReserveSlip needs itemnumber for item level holds on same biblio
- [[20546]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20546) Shelving location not displayed on checkin

### Fines and fees

- [[20285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20285) Lost item refund won't always pay down lost item fee first

### Hold requests

- [[19972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19972) Holds to pull should honor syspref "item-level_itypes"

### Notices

- [[20685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20685) Modify letter template does not render correctly

### Packaging

- [[17111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17111) Automatic debian/control updates (oldstable/17.11.x)

### Patrons

- [[3886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3886) Can't print receipt w/out allowing "Add or modify borrowers" permission

### Searching

- [[18799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18799) XSLTresultsdisplay hides the icons
- [[20722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20722) Searching only for an ITEMTYPECAT itemtype is impossible

### Staff Client

- [[20781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20781) 0 months is not a valid enrollment period and causes errors

### Templates

- [[20752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20752) Files tab in patron account is not properly capitalized
- [[20791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20791) Correct capitalization on 'Notices and slips' page

### Test Suite

- [[20191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20191) OAI/Server.t still fails on slow servers



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.6%)
- Armenian (99.9%)
- Basque (75.5%)
- Chinese (China) (79.8%)
- Chinese (Taiwan) (99.9%)
- Czech (93.9%)
- Danish (65.8%)
- English (New Zealand) (99.6%)
- English (USA)
- Finnish (95.8%)
- French (98.4%)
- French (Canada) (92.2%)
- German (100%)
- German (Switzerland) (99.6%)
- Greek (80.8%)
- Hindi (100%)
- Italian (99.9%)
- Norwegian Bokmål (54.6%)
- Occitan (post 1500) (72.9%)
- Persian (54.9%)
- Polish (97.6%)
- Portuguese (99.9%)
- Portuguese (Brazil) (84.6%)
- Slovak (96.8%)
- Spanish (99.9%)
- Swedish (91.8%)
- Turkish (99.9%)
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

The release team for Koha 17.11.07 is

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

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.07:


We thank the following individuals who contributed patches to Koha 17.11.07.

- Nightly Build Bot (1)
- Nick Clemens (3)
- Tomás Cohen Arazi (2)
- Marcel de Rooy (3)
- Jonathan Druart (10)
- Magnus Enger (1)
- Katrin Fischer (4)
- Victor Grousset (1)
- Owen Leonard (2)
- Julian Maurice (2)
- Kyle M Hall (8)
- Benjamin Rokseth (1)
- Fridolin Somers (2)
- Mark Tompsett (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.07

-  (0)
- abunchofthings.net (1)
- ACPL (2)
- BibLibre (5)
- BSZ BW (4)
- bugs.koha-community.org (10)
- ByWater-Solutions (5)
- bywatetsolutions.com (6)
- deichman.no (1)
- Libriotech (1)
- Rijksmuseum (3)
- Theke Solutions (2)
- unidentified (1)

We also especially thank the following individuals who tested patches
for Koha.

- Blou (1)
- claude (1)
- Barton Chittenden (1)
- Nick Clemens (29)
- Tomas Cohen Arazi (3)
- Chris Cormack (2)
- Marcel de Rooy (10)
- Jonathan Druart (23)
- Charles Farmer (2)
- Katrin Fischer (9)
- Brendan Gallagher (1)
- Lucie Gay (1)
- Victor Grousset (1)
- Amit Gupta (1)
- Pierre-Luc Lapointe (2)
- Owen Leonard (4)
- Jesse Maseto (1)
- Julian Maurice (2)
- Kyle M Hall (5)
- Martin Renvoize (29)
- Maksim Sen (1)
- Maryse Simard (1)
- Fridolin Somers (39)
- Mirko Tietgen (1)
- Mark Tompsett (5)
- Ed Veal (1)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 juin 2018 12:23:25.
