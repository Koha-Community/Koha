# RELEASE NOTES FOR KOHA 16.11.08
17 May 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.08 is a bugfix/maintenance release.

It includes 5 enhancements, 50 bugfixes.




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


- [[18066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18066) Hea - Version 2

> Hea is a website to collect usage data from libraries using Koha. With this development Hea can collect the geolocations of the libraries in your installation create a map. A new configuration page allows to configure easily what information is shared with the Koha community.




## Critical bugs fixed

### Acquisitions

- [[18471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18471) Receiving order with unitprice greater than 1000 processing incorrectly
- [[18525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18525) Can't create order line from accepted suggestion

### Architecture, internals, and plumbing

- [[16758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16758) Caching issues in scripts running in daemon mode
- [[18457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18457) process_message_queue.pl will die if a patron has no sms_provider_id set but sms via email is enabled for that patron

### Authentication

- [[14625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14625) LDAP: mapped ExtendedPatronAttributes cause error when updated on authentication
- [[18442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18442) Permission error when logging into staff interface as db user

### Circulation

- [[18435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18435) Message about Materials specified does not display when items are checked out and checked in
- [[18438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18438) Check in: Modal about holds hides important check in messages

### Installation and upgrade (command-line installer)

- [[17260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17260) updatedatabase.pl fails on invalid entries in ENUM and BOOLEAN columns

### MARC Bibliographic record staging/import

- [[18152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18152) UNIMARC bib records imported with invalid 'a' char in label pos.9

### OPAC

- [[18560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18560) RSS Feed link from OPAC shelves is broken

### System Administration

- [[18376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18376) authority framework creation fails under Plack

### Tools

- [[18574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18574) Clean Patron Records tool doesn't limit to the selected library


## Other bugs fixed

### Acquisitions

- [[13835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13835) Popup with searches: results hidden by language menu in footer

### Architecture, internals, and plumbing

- [[17257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17257) Cannot create a patron under MySQL 5.7

### Cataloging

- [[18415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18415) Advanced Editor - Rancor - return focus to editor after successful macro

### Command-line Utilities

- [[18502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18502) koha-shell broken on dev installs

### Database

- [[18383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18383) items.onloan schema comment seems to be incorrect.

### Hold requests

- [[18534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18534) When IndependentBranches is enabled the pickup location displayed incorrectly on request.pl

### Installation and upgrade (web-based installer)

- [[17190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17190) Mark REST API dependencies as mandatory in PerlDependencies.pm
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
- [[18466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18466) No article requests breaks the opac-user-views block
- [[18484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18484) opac-advsearch.tt missing closing div tag for .container-fluid
- [[18504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18504) Amount owed on fines tab should be formatted as price if <10 or credit
- [[18505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18505) OPAC Search History page does not respect OpacPublic syspref

### Packaging

- [[16749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16749) Additional fixes for debian scripts
- [[17618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17618) perl-modules Debian package name change
- [[18571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18571) koha-conf.xml should include ES entry

### Patrons

- [[15702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15702) Trim whitespace from patron details upon submission
- [[18370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18370) Columns settings patrons>id=memberresultst : display bug
- [[18551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18551) Hide with CSS dynamic elements in member search
- [[18597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18597) Quick add form does not transfer patron attributes values when switching forms/saving

### Reports

- [[17925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17925) Disable debugging in reports/bor_issues_top.pl

### Self checkout

- [[7550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7550) Self checkout: limit display of patron image to logged-in patron
- [[18405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18405) Self checkout: Fix broken silent printing

### Serials

- [[18536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18536) Generating CSV using profile in serials late issues doesn't work as described

### System Administration

- [[18444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18444) Add TalkingTechItivaPhoneNotification to sysprefs.sql

### Templates

- [[17916]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17916) "Delete MARC modification template" fails to actually delete it
- [[18419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18419) Broken patron-blank image in viewlog.tt
- [[18452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18452) Should say 'URL' instead of 'url' in catalog detail

### Test Suite

- [[18233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18233) t/db_dependent/00-strict.t has non-existant resetversion.pl
- [[18494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18494) Fix Letters.t (follow-up of 15702)

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
- Arabic (99%)
- Armenian (96%)
- Chinese (China) (85%)
- Chinese (Taiwan) (99%)
- Czech (96%)
- Danish (71%)
- English (New Zealand) (93%)
- Finnish (99%)
- French (99%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (100%)
- Greek (78%)
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
- Swedish (99%)
- Turkish (99%)
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

The release team for Koha 16.11.08 is

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
new features in Koha 16.11.08:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.11.08.

- phette23 (1)
- pongtawat (1)
- Jacek Ablewicz (1)
- Aleisha Amohia (3)
- Oliver Bock (1)
- Alex Buckley (3)
- Nick Clemens (6)
- Tomás Cohen Arazi (2)
- Stephane Delaune (1)
- Marcel de Rooy (15)
- Jonathan Druart (24)
- Katrin Fischer (4)
- Bernardo González Kriegel (1)
- Olli-Antti Kivilahti (1)
- Owen Leonard (7)
- Julian Maurice (1)
- Kyle M Hall (5)
- Josef Moravec (2)
- Martin Renvoize (1)
- Fridolin Somers (5)
- Lari Taskula (1)
- Mirko Tietgen (1)
- Mark Tompsett (6)
- Marc Véron (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.08

- abunchofthings.net (1)
- ACPL (7)
- aei.mpg.de (1)
- BibLibre (7)
- biblos.pk.edu.pl (1)
- BSZ BW (4)
- bugs.koha-community.org (24)
- ByWater-Solutions (11)
- Catalyst (3)
- jns.fi (2)
- Marc Véron AG (2)
- PTFS-Europe (1)
- punsarn.asia (1)
- Rijksmuseum (15)
- Theke Solutions (2)
- unidentified (12)
- Universidad Nacional de Córdoba (1)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (5)
- Barton Chittenden (1)
- Chris Cormack (9)
- Dilan Johnpulle (1)
- Jonathan Druart (45)
- Jonathan Field (1)
- Josef Moravec (5)
- Julian Maurice (12)
- Katrin Fischer (99)
- Lisa Gugliotti (1)
- Marc Véron (14)
- Marjorie Barry-Vila (1)
- Mark Tompsett (5)
- Martin Renvoize (3)
- Mason James (1)
- Mirko Tietgen (7)
- Nick Clemens (13)
- Nicolas Legrand (1)
- Owen Leonard (8)
- Peggy Thrasher (1)
- Philippe (2)
- Séverine Queune (1)
- Srdjan (1)
- Katrin Fischer  (1)
- Tomas Cohen Arazi (2)
- Brendan A Gallagher (11)
- Kyle M Hall (62)
- Marcel de Rooy (27)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x.
The last Koha release was 16.11.07, which was released on April 22, 2017.  

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 17 May 2017 02:04:15.
