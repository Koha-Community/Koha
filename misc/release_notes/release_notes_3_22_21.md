# RELEASE NOTES FOR KOHA 3.22.21
22 May 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 3.22.21 can be downloaded from:

- [Download](http://download.koha-community.org/koha-3.22.21.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 3.22.21 is a bugfix/maintenance release.

It includes 1 new feature, 1 enhancement and 31 bugfixes.



## New features

### System Administration

- [[18066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18066) Hea - Version 2

> Hea is a service to collect usage data from libraries using Koha.
>
> With this development Hea can collect the geolocations of the libraries in
> your installation and create a map. A new configuration page allows to
> configure easily what information is shared with the Koha community.
>
> Hea statistics can been seen on https://hea.koha-community.org/



## Enhancements

### System Administration

- [[14608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14608) HEA : add possibility of sharing usage statistics in Administration page

> This patch set adds:
>
> - a reference to Hea at the end of the installation process
> - a link to the new page from the admin home page
> - a new page to easily configure shared statistics


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[18364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18364) LOCK and UNLOCK are not transaction-safe

### Authentication

- [[14625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14625) LDAP: mapped ExtendedPatronAttributes cause error when updated on authentication
- [[18442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18442) Permission error when logging into staff interface as db user

### Cataloging

- [[17818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17818) Duplicating a subfield yields an empty subfield tag [follow-up]

### MARC Bibliographic record staging/import

- [[18152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18152) UNIMARC bib records imported with invalid 'a' char in label pos.9

### System Administration

- [[18376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18376) authority framework creation fails under Plack


## Other bugs fixed

### Acquisitions

- [[18429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18429) Receiving an item should update the datelastseen

### Architecture, internals, and plumbing

- [[17257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17257) Cannot create a patron under MySQL 5.7
- [[17814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17814) koha-plack --stop should make sure that Plack really stop
- [[18443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18443) Get rid of warning 'uninitialized value $user' in C4/Auth.pm

### Circulation

- [[18335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18335) Check in: Make patron info in hold messages obey syspref AddressFormat

### Installation and upgrade (command-line installer)

- [[17911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17911) Message and timeout mismatch at the end of the install process

### Installation and upgrade (web-based installer)

- [[18578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18578) Use subdirectory in /tmp for session storage during installation

### Label/patron card printing

- [[18535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18535) Clicking 'edit printer profile' in label creator causes software error

### Notices

- [[16568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16568) Talking Tech generates phone notifications for all overdue actions

### OPAC

- [[4460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4460) Amazon's AssociateID tag not used in links so referred revenue lost
- [[16515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16515) Did you mean? links don't wrap on smaller screens
- [[17936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17936) Search bar not aligned on right in small screen sizes
- [[18484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18484) opac-advsearch.tt missing closing div tag for .container-fluid
- [[18504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18504) Amount owed on fines tab should be formatted as price if <10 or credit
- [[18505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18505) OPAC Search History page does not respect OpacPublic syspref

### Packaging

- [[17618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17618) perl-modules Debian package name change

### Patrons

- [[18370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18370) Columns settings patrons>id=memberresultst : display bug
- [[18423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18423) Add child button not always appearing - problem in template variable

### SIP2

- [[12021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12021) SIP2 checkin should alert on transfer and use CT for return branch

### Searching

- [[17821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17821) due date in intranet search results should use TT date plugin

### Serials

- [[18536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18536) Generating CSV using profile in serials late issues doesn't work as described

### System Administration

- [[18444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18444) Add TalkingTechItivaPhoneNotification to sysprefs.sql

### Test Suite

- [[18233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18233) t/db_dependent/00-strict.t has non-existant resetversion.pl
- [[18460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18460) Remove itemtype-related Serials.t warnings

### Tools

- [[18340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18340) Progress bar length is wrong

## New sysprefs

- TalkingTechItivaPhoneNotification
- UsageStatsGeolocation
- UsageStatsLibrariesInfo
- UsageStatsPublicID

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
- Arabic (97%)
- Armenian (99%)
- Chinese (China) (92%)
- Chinese (Taiwan) (96%)
- Czech (96%)
- Danish (76%)
- English (New Zealand) (97%)
- Finnish (99%)
- French (99%)
- French (Canada) (90%)
- German (100%)
- German (Switzerland) (98%)
- Greek (80%)
- Hindi (99%)
- Italian (100%)
- Korean (56%)
- Kurdish (54%)
- Norwegian Bokmål (62%)
- Occitan (94%)
- Persian (63%)
- Polish (99%)
- Portuguese (100%)
- Portuguese (Brazil) (93%)
- Slovak (98%)
- Spanish (99%)
- Swedish (94%)
- Turkish (99%)
- Vietnamese (78%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 3.22.21 is

- Release Manager: [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
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
new features in Koha 3.22.21:


We thank the following individuals who contributed patches to Koha 3.22.21.

- pongtawat (1)
- Brendan A Gallagher (1)
- Oliver Bock (1)
- Alex Buckley (1)
- Nick Clemens (8)
- Tomás Cohen Arazi (1)
- Stephane Delaune (1)
- Jonathan Druart (20)
- Olli-Antti Kivilahti (1)
- Owen Leonard (3)
- Kyle M Hall (1)
- Julian Maurice (3)
- Sophie Meynieux (1)
- Josef Moravec (1)
- Martin Renvoize (1)
- Benjamin Rokseth (1)
- Fridolin Somers (2)
- Lari Taskula (1)
- Mirko Tietgen (1)
- Mark Tompsett (3)
- Marc Véron (2)
- Marcel de Rooy (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 3.22.21

- abunchofthings.net (1)
- ACPL (3)
- aei.mpg.de (1)
- BibLibre (7)
- bugs.koha-community.org (20)
- ByWater-Solutions (10)
- Catalyst (1)
- jns.fi (2)
- Marc Véron AG (2)
- Oslo Public Library (1)
- PTFS-Europe (1)
- punsarn.asia (1)
- Rijksmuseum (3)
- Theke Solutions (1)
- unidentified (4)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (2)
- Barton Chittenden (1)
- Chris Cormack (8)
- Christopher Brannon (1)
- Jonathan Druart (20)
- Jonathan Field (1)
- Josef Moravec (2)
- Julian Maurice (66)
- Katrin Fischer (30)
- Lisa Gugliotti (1)
- Marc Véron (11)
- Mark Tompsett (3)
- Martin Renvoize (3)
- Mason James (11)
- Mirko Tietgen (1)
- Nick Clemens (5)
- Owen Leonard (3)
- Srdjan (1)
- Séverine Queune (1)
- Katrin Fischer  (1)
- Tomas Cohen Arazi (1)
- Brendan A Gallagher (11)
- Kyle M Hall (26)
- Marcel de Rooy (17)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 3.22.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 May 2017 14:38:48.
