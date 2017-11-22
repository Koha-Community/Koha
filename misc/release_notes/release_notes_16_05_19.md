# RELEASE NOTES FOR KOHA 16.05.19
22 Nov 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.05.19 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.19.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.05.19 is a bugfix/maintenance release.

It includes 5 enhancements, 15 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[17610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17610) [16.11.x] Allow the number of plack workers and max connections to be set in koha-conf.xml

### Cataloging

- [[16204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16204) Show friendly error message when trying to edit record which no longer exists

### OPAC

- [[18616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18616) The "Add forgot password link to OPAC" should allow patrons to use their library card number in addition to username

### Patrons

- [[15644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15644) City dropdown default selection when modifying a patron matches only on city

### Test Suite

- [[19337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19337) Allow basic_workflow.t be configured by ENV


## Critical bugs fixed

### MARC Authority data support

- [[19415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19415) FindDuplicateAuthority is searching on biblioserver since 16.05

### Patrons

- [[14637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14637) Add patron category fails with MySQL 5.6.26

### Searching

- [[17278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17278) Limit to available items returns 0 results


## Other bugs fixed

### Acquisitions

- [[19195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19195) Noisy warns when creating or editing a basket

### Architecture, internals, and plumbing

- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces

### MARC Authority data support

- [[18801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18801) Merging authorities has an invalid 'Default' type in the merge framework selector

### OPAC

- [[16463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16463) OPAC discharge page should warn the user about checkouts before they request
- [[19345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19345) SendMail error does not display error message in password recovery

### Staff Client

- [[19193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19193) When displaying the fines of the guarantee on the guarantor account, price is not in correct format.

### System Administration

- [[16726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16726) Text in Preferences search box does not clear

### Test Suite

- [[17664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17664) Silence non-zebra warnings in t/db_dependent/Search.t
- [[19262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19262) pod_spell.t does not work
- [[19307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19307) t/db_dependent/Circulation/NoIssuesChargeGuarantees.t fails if AllowFineOverride set to allow
- [[19386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19386) t/db_dependent/SIP/Patron.t is failing randomly
- [[19423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19423) DecreaseLoanHighHolds.t is failing randomly



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
- Arabic (98%)
- Armenian (93%)
- Basque (77%)
- Chinese (China) (88%)
- Chinese (Taiwan) (98%)
- Czech (95%)
- Danish (72%)
- English (New Zealand) (96%)
- Finnish (98%)
- French (98%)
- French (Canada) (92%)
- German (99%)
- German (Switzerland) (99%)
- Greek (85%)
- Hindi (99%)
- Italian (100%)
- Korean (53%)
- Kurdish (51%)
- Norwegian Bokmål (58%)
- Occitan (79%)
- Persian (60%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (88%)
- Slovak (94%)
- Spanish (99%)
- Swedish (90%)
- Turkish (100%)
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

The release team for Koha 16.05.19 is

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
  - [Claire Gravely]
  - [Josef Moravec]
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 16.05.19:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.05.19.

- Aleisha Amohia (5)
- David Bourgault (1)
- Pongtawat C (1)
- Nick Clemens (3)
- Tomás Cohen Arazi (1)
- Marcel de Rooy (3)
- Jonathan Druart (9)
- Mason James (7)
- David Kuhn (1)
- Owen Leonard (1)
- Dominic Pichette (1)
- Mark Tompsett (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.05.19

- ACPL (1)
- bugs.koha-community.org (9)
- ByWater-Solutions (3)
- KohaAloha (7)
- punsarn.asia (1)
- Rijksmuseum (3)
- Solutions inLibro inc (2)
- Theke Solutions (1)
- unidentified (7)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (1)
- Amit Gupta (1)
- Claire Gravely (1)
- David Bourgault (2)
- Dilan Johnpullé (1)
- Dominic Pichette (1)
- Fridolin Somers (10)
- Jonathan Druart (13)
- Josef Moravec (3)
- Katrin Fischer (11)
- Marc Véron (1)
- Mark Tompsett (1)
- Martin Renvoize (4)
- Mason James (15)
- Nick Clemens (4)
- Tomas Cohen Arazi (4)
- Kyle M Hall (1)
- Caroline Cyr La Rose (2)
- Marcel de Rooy (8)


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

Autogenerated release notes updated last on 22 Nov 2017 13:44:53.
