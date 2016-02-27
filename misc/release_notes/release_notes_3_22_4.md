# RELEASE NOTES FOR KOHA 3.22.4
27 Feb 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.4 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.4 is a bugfix/maintenance release.

It includes 3 enhancements and 32 bugfixes.


## Enhancements

### Circulation

- [[15571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15571) reserveforothers permission does not remove Search to hold button from patron account

### System Administration

- [[15552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15552) Better wording of intranetreadinghistory syspref

### Tools

- [[15573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15573) String and translatability fix to Patron Card Creator


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[15578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15578) Authority tests skip and hide a bug

### Cataloging

- [[15358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15358) merge.pl does not populate values to merge

### Lists

- [[15810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15810) Can't create private lists if OpacAllowPublicListCreation is set to 'not allow'

### OPAC

- [[13534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13534) Deleting staff patron will delete tags approved by this patron

### Searching

- [[15818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15818) OPAC search with utf-8 characters and without results generates encoding error

### Serials

- [[15643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15643) Every datepicker on serials expected date column updates top issue


## Other bugs fixed

### Architecture, internals, and plumbing

- [[15517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15517) Tables borrowers and deletedborrowers differ again
- [[15742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15742) Unnecessary loop in j2a cronjob
- [[15743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15743) Allow plugins to embed Perl modules
- [[15777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15777) Refactor loop in which Record::Processor does not initialize parameters

### Authentication

- [[14507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14507) SIP Authentication broken when LDAP Auth Enabled
- [[15747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15747) Auth.pm flooding error log with "CGI::param called in list context"

### Cataloging

- [[15411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15411) "Non fiction" is incorrect
- [[15514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15514) New professional cataloguing editor does not handle repeatable fields correctly

### Circulation

- [[14930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14930) Leaving OpacFineNoRenewals blank blocks renewals, but should disable feature
- [[15841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15841) Final truth value in C4:Circulation has become displaced
- [[15845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15845) Renewal date in circulation.pl is not always correct and not even used

### Hold requests

- [[15652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15652) Allow current date in datepicker on opac-reserve

### Installation and upgrade (command-line installer)

- [[12549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12549) Hard coded font Paths (  DejaVu ) cause problems for non-Debian systems

### Lists

- [[15811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15811) Redirect after adding a new list in OPAC broken

### Patrons

- [[15622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15622) Spelling mistake in printfreercpt.pl
- [[15746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15746) A random library is used to record an individual payment
- [[15795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15795) C4/Members.pm is floody (Norwegian Patron DB)

### Reports

- [[15416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15416) Warns on Guided Reports page

### SIP2

- [[15479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15479) SIPserver rejects renewals for patrons with alphanumeric cardnumbers

### Serials

- [[15657]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15657) follow-up for bug 15501 : add a missing semi-colon

### Templates

- [[11937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11937) opac link doesn't open in new window
- [[15071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15071) In OPAC search results, "checked out" status should be more visible
- [[15600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15600) System preferences broken toolbar looks broken
- [[15844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15844) Correct JSHint errors in staff-global.js
- [[15847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15847) Correct JSHint errors in basket.js in the staff client

### Web services

- [[15764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15764) KOCT timestamp timezone problem



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
- Czech (98%)
- Danish (78%)
- Finnish (98%)
- French (90%)
- German (100%)
- Italian (99%)
- Korean (59%)
- Kurdish (56%)
- Persian (65%)
- Polish (95%)
- Portuguese (98%)
- Slovak (100%)
- Spanish (100%)
- Swedish (84%)
- Turkish (99%)
- Vietnamese (80%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.4 is

- Release Manager: [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Jesse Weaver](mailto:jweaver@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Paul Poulain](mailto:paul.poulain@biblibre.com)
  - [Jonathan Druart](mailto:jonathan.druart@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - [Magnus Enger](mailto:magnus@enger.priv.no)
  - [Mirko Tietgen](mailto:mirko@abunchofthings.net)
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Zeno Tajoli](mailto:z.tajoli@cineca.it)
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Galen Charlton](mailto:gmc@esilibrary.com)
- Documentation Manager: [Nicole C. Engard](mailto:nengard@gmail.com)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators: 
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Frédéric Demians](mailto:f.demians@tamil.fr)
  - 3.18 -- [Liz Rea](mailto:liz@catalyst.net.nz)
  - 3.16 -- [Mason James](mailto:mtj@kohaaloha.com)
  - 3.14 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 3.22.4:


We thank the following individuals who contributed patches to Koha 3.22.4.

- Briana (1)
- Gus (2)
- Aleisha (5)
- Colin Campbell (4)
- Tomás Cohen Arazi (1)
- Jonathan Druart (13)
- Brendan Gallagher (2)
- Owen Leonard (4)
- Kyle M Hall (5)
- Julian Maurice (7)
- Dobrica Pavlinusic (1)
- Juan Sieira (1)
- Lyon3 Team (2)
- Mark Tompsett (4)
- Jesse Weaver (2)
- Marcel de Rooy (2)
- Nicholas van Oudtshoorn (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.4

- ACPL (4)
- BibLibre (7)
- bugs.koha-community.org (13)
- ByWater-Solutions (9)
- PTFS-Europe (4)
- Rijksmuseum (2)
- rot13.org (1)
- stacmail.net (2)
- unidentified (11)
- Universidad Nacional de Córdoba (1)
- Université Jean Moulin Lyon 3 (2)
- Xercode (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (1)
- Briana (1)
- Hector Castro (13)
- Jesse Weaver (2)
- Jonathan Druart (20)
- Josef Moravec (1)
- Julian Maurice (55)
- Katrin Fischer (5)
- Liz Rea (1)
- Marc Veron (1)
- Marc Véron (8)
- Mark Tompsett (7)
- Mirko Tietgen (1)
- Owen Leonard (2)
- Philippe Blouin (1)
- Tomas Cohen Arazi (2)
- Nicole C Engard (1)
- Brendan A Gallagher (4)
- Kyle M Hall (22)
- Marcel de Rooy (5)
- Juan Romay Sieira (1)
- Brendan Gallagher brendan@bywatersolutions.com (40)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.
The last Koha release was 3.22.3, which was released on Feb 12, 2016.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Feb 2016 15:11:30.
