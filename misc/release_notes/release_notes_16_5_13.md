# RELEASE NOTES FOR KOHA 16.5.13
24 May 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.13 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.13.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.13 is a bugfix/maintenance release.

It includes 1 new features, 4 enhancements, 36 bugfixes.



## New features

### System Administration

- [[18066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18066) Hea - Version 2

> Hea is a service to collect usage data from libraries using Koha.
With this development Hea can collect the geolocations of the libraries in your installation and create a map. A new configuration page allows to configure easily what information is shared with the Koha community.
Hea statistics can been seen on https://hea.koha-community.org/



## Enhancements

### Circulation

- [[17812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17812) Return focus to barcode field after toggling on-site checkouts

### Label/patron card printing

- [[15815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15815) Improve wording in popup warning when deleting patron from patron-batch

### Packaging

- [[16733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16733) More flexible paths in debian scripts (for dev installs)

### System Administration

- [[14608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14608) HEA : add possibility of sharing usage statistics in Administration page

> This patch set adds:
- a reference to Hea at the end of the installation process
- a link to the new page from the admin home page
- a new page to easily configure shared statistics




## Critical bugs fixed

### Acquisitions

- [[18525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18525) Can't create order line from accepted suggestion

### Architecture, internals, and plumbing

- [[16758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16758) Caching issues in scripts running in daemon mode
- [[18457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18457) process_message_queue.pl will die if a patron has no sms_provider_id set but sms via email is enabled for that patron

### Authentication

- [[18442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18442) Permission error when logging into staff interface as db user

### Installation and upgrade (command-line installer)

- [[17260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17260) updatedatabase.pl fails on invalid entries in ENUM and BOOLEAN columns

### MARC Bibliographic record staging/import

- [[18152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18152) UNIMARC bib records imported with invalid 'a' char in label pos.9

### System Administration

- [[18376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18376) authority framework creation fails under Plack


## Other bugs fixed

### Acquisitions

- [[13835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13835) Popup with searches: results hidden by language menu in footer

### Architecture, internals, and plumbing

- [[17257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17257) Cannot create a patron under MySQL 5.7

### Cataloging

- [[18415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18415) Advanced Editor - Rancor - return focus to editor after successful macro

### Database

- [[18383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18383) items.onloan schema comment seems to be incorrect.

### Installation and upgrade (web-based installer)

- [[18578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18578) Use subdirectory in /tmp for session storage during installation

### Label/patron card printing

- [[18535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18535) Clicking 'edit printer profile' in label creator causes software error

### Notices

- [[16568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16568) Talking Tech generates phone notifications for all overdue actions

### OPAC

- [[4460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4460) Amazon's AssociateID tag not used in links so referred revenue lost
- [[15738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15738) Summary page says item has no fines, but Fines tab says otherwise
- [[16515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16515) Did you mean? links don't wrap on smaller screens
- [[17936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17936) Search bar not aligned on right in small screen sizes
- [[17993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17993) Do not use modal authentication with CAS
- [[18484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18484) opac-advsearch.tt missing closing div tag for .container-fluid
- [[18504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18504) Amount owed on fines tab should be formatted as price if <10 or credit
- [[18505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18505) OPAC Search History page does not respect OpacPublic syspref

### Packaging

- [[16749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16749) Additional fixes for debian scripts
- [[17618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17618) perl-modules Debian package name change

### Patrons

- [[15702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15702) Trim whitespace from patron details upon submission
- [[18370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18370) Columns settings patrons>id=memberresultst : display bug
- [[18551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18551) Hide with CSS dynamic elements in member search

### Reports

- [[17925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17925) Disable debugging in reports/bor_issues_top.pl

### Self checkout

- [[7550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7550) Self checkout: limit display of patron image to logged-in patron

### Serials

- [[18536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18536) Generating CSV using profile in serials late issues doesn't work as described

### System Administration

- [[18444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18444) Add TalkingTechItivaPhoneNotification to sysprefs.sql

### Templates

- [[18419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18419) Broken patron-blank image in viewlog.tt
- [[18452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18452) Should say 'URL' instead of 'url' in catalog detail

### Test Suite

- [[18233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18233) t/db_dependent/00-strict.t has non-existant resetversion.pl
- [[18494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18494) Fix Letters.t (follow-up of 15702)

### Tools

- [[18340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18340) Progress bar length is wrong

## New sysprefs

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
- Arabic (99%)
- Armenian (94%)
- Basque (78%)
- Chinese (China) (88%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (73%)
- English (New Zealand) (97%)
- Finnish (99%)
- French (98%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (100%)
- Greek (84%)
- Hindi (99%)
- Italian (100%)
- Korean (54%)
- Kurdish (52%)
- Norwegian Bokmål (59%)
- Occitan (80%)
- Persian (61%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (89%)
- Slovak (94%)
- Spanish (100%)
- Swedish (91%)
- Turkish (99%)
- Vietnamese (74%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.5.13 is

- Release Manager: [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
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
new features in Koha 16.5.13:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.5.13.

- pongtawat (1)
- Jacek Ablewicz (1)
- Aleisha Amohia (3)
- Alex Buckley (1)
- Nick Clemens (3)
- Stephane Delaune (1)
- Marcel de Rooy (11)
- Jonathan Druart (13)
- Katrin Fischer (1)
- Mason James (14)
- Olli-Antti Kivilahti (1)
- Owen Leonard (5)
- Kyle M Hall (2)
- Josef Moravec (2)
- Martin Renvoize (1)
- Fridolin Somers (5)
- Lari Taskula (1)
- Mirko Tietgen (1)
- Mark Tompsett (4)
- Marc Véron (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.13

- abunchofthings.net (1)
- ACPL (5)
- BibLibre (6)
- biblos.pk.edu.pl (1)
- BSZ BW (1)
- bugs.koha-community.org (13)
- ByWater-Solutions (5)
- Catalyst (1)
- jns.fi (2)
- KohaAloha (14)
- Marc Véron AG (1)
- PTFS-Europe (1)
- punsarn.asia (1)
- Rijksmuseum (11)
- unidentified (9)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (2)
- Barton Chittenden (1)
- Chris Cormack (3)
- Jonathan Druart (31)
- Jonathan Field (1)
- Josef Moravec (5)
- Julian Maurice (5)
- Katrin Fischer (36)
- Lisa Gugliotti (1)
- Marc Véron (10)
- Marjorie Barry-Vila (1)
- Mark Tompsett (3)
- Martin Renvoize (2)
- Mason James (31)
- Mirko Tietgen (4)
- Nick Clemens (9)
- Owen Leonard (7)
- Philippe (2)
- Séverine Queune (1)
- Srdjan (1)
- Katrin Fischer  (1)
- Tomas Cohen Arazi (1)
- Brendan A Gallagher (2)
- Kyle M Hall (19)
- Marcel de Rooy (18)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 May 2017 17:39:49.
