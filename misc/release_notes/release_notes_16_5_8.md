# RELEASE NOTES FOR KOHA 16.5.8
28 Jan 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.5.8 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.5.8 is a bugfix/maintenance release.

It includes 25 bugfixes.






## Critical bugs fixed

### Architecture, internals, and plumbing

- [[17785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17785) oai.pl returns wrong URLs under Plack
- [[17914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17914) The installer process tries to create borrowers.updated_on twice

### Authentication

- [[17615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17615) LDAP Auth: regression causes attribute updates to silently fail and corrupt existing data

### Installation and upgrade (command-line installer)

- [[17234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17234) ALTER IGNORE TABLE is invalid in mysql 5.7.  This breaks updatedatabase.pl
- [[17986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17986) Perl dependency evaluation incorrect

### OPAC

- [[17924]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17924) Fix error in password recovery

### Patrons

- [[14637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14637) Add patron category fails with MySQL 5.6.26

### Test Suite

- [[17917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17917) t/db_dependent/check_sysprefs.t fails on kohadev strangely


## Other bugs fixed

### Acquisitions

- [[17899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17899) Show only mine does not work in newordersuggestion.pl

### Architecture, internals, and plumbing

- [[17931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17931) Remove unused vars from reserves_stats.pl

### Circulation

- [[17781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17781) Improper branchcode set during renewal
- [[17808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17808) When editing circulation conditions, only ask for confirmation when there is already a rule selected

### Installation and upgrade (command-line installer)

- [[17880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17880) C4::Installer::PerlModules lexicographical comparison is incorrect

### Installation and upgrade (web-based installer)

- [[17469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17469) fr-CA web installer is missing some sample notices

### Label/patron card printing

- [[15711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15711) Deleting patroncard images has unexpected behaviour and is broken
- [[17879]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17879) Possible to upload images with no image name

### MARC Authority data support

- [[17909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17909) Add unit tests for authority merge

### Packaging

- [[17265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17265) Make koha-create and koha-dump-defaults less greedy

### Staff Client

- [[16933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16933) Alt-Y not working on "Please confirm checkout" dialogs

### Templates

- [[15460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15460) Bug 13381 accidentally removed spaces after subfields c and h of 245

### Test Suite

- [[17742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17742) Test t/db_dependent/Patrons.t can fail randomly
- [[17920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17920) t/db_dependent/Sitemapper.t fails because of permissions

### Tools

- [[17777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17777) koha-remove should deal with temporary uploads
- [[17794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17794) Menu items in Tools menu and Admin menu not bold when active but not on linked page

### Web services

- [[17778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17778) Make "Earliest Registered Date" in OAI-PMH dynamic



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
- Armenian (95%)
- Chinese (China) (89%)
- Chinese (Taiwan) (99%)
- Czech (97%)
- Danish (74%)
- English (New Zealand) (98%)
- Finnish (99%)
- French (99%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (99%)
- Greek (82%)
- Hindi (99%)
- Italian (100%)
- Korean (54%)
- Kurdish (52%)
- Norwegian Bokmål (60%)
- Occitan (81%)
- Persian (61%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (90%)
- Slovak (95%)
- Spanish (100%)
- Swedish (92%)
- Turkish (100%)
- Vietnamese (75%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.5.8 is

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
new features in Koha 16.5.8:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.5.8.

- Blou (1)
- Aleisha Amohia (3)
- Alex Arnaud (2)
- Maxime Beaulieu (1)
- David Cook (3)
- Marcel de Rooy (7)
- Jonathan Druart (10)
- Dani Elder (1)
- Magnus Enger (3)
- Katrin Fischer (1)
- Caitlin Goodger (1)
- Mason James (7)
- Julian Maurice (2)
- Tim McMahon (1)
- Kyle M Hall (2)
- Josef Moravec (2)
- Fridolin Somers (1)
- Mark Tompsett (4)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.5.8

- BibLibre (5)
- BSZ BW (1)
- bugs.koha-community.org (10)
- ByWater-Solutions (3)
- KohaAloha (7)
- Libriotech (3)
- Prosentient Systems (3)
- Rijksmuseum (7)
- Solutions inLibro inc (2)
- unidentified (9)
- wegc.school.nz (1)
- wlpl.org (1)

We also especially thank the following individuals who tested patches
for Koha.

- Andreas Roussos (1)
- Caitlin Goodger (1)
- Claire Gravely (2)
- David Kuhn (1)
- Emma Smith (1)
- Grace McKenzie (1)
- Jesse Maseto (1)
- Jonathan Druart (19)
- Josef Moravec (8)
- Julian Maurice (7)
- Karen Jen (1)
- Katrin Fischer (27)
- Mark Tompsett (12)
- Martin Renvoize (3)
- Mason James (23)
- Nick Clemens (3)
- Oliver Bock (1)
- Owen Leonard (4)
- Zoe Schoeler (2)
- Katrin Fischer  (1)
- Tomas Cohen Arazi (1)
- Kyle M Hall (29)
- Bernardo Gonzalez Kriegel (1)
- Marcel de Rooy (11)

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

Autogenerated release notes updated last on 28 Jan 2017 00:22:50.
