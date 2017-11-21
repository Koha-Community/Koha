# RELEASE NOTES FOR KOHA 16.11.14
21 Nov 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.14 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.14.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.14 is a bugfix/maintenance release.

It includes 5 enhancements, 23 bugfixes.




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

### Acquisitions

- [[18999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18999) Acq: Shipping cost not included in total spent on acq home and funds page

### Circulation

- [[19487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19487) Internal server error when writing off lost fine for item not checked out

### Hold requests

- [[19135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19135) AllowHoldsOnPatronsPossessions is not working

### MARC Authority data support

- [[19415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19415) FindDuplicateAuthority is searching on biblioserver since 16.05

### Staff Client

- [[18884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18884) Advanced search on staff client, Availability limit not properly limiting

### System Administration

- [[15173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15173) SubfieldsToAllowForRestrictedEditing not working properly


## Other bugs fixed

### Acquisitions

- [[19195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19195) Noisy warns when creating or editing a basket

### Architecture, internals, and plumbing

- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces

### Cataloging

- [[18422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18422) Add Select2 to authority editor

### MARC Authority data support

- [[18801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18801) Merging authorities has an invalid 'Default' type in the merge framework selector

### OPAC

- [[16463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16463) OPAC discharge page should warn the user about checkouts before they request
- [[19345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19345) SendMail error does not display error message in password recovery

### Patrons

- [[12346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12346) False patron modification alerts on members-home.pl
- [[19398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19398) Wrong date format in quick patron search table

### Reports

- [[18742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18742) Circulation statistics wizard no longer exports the total row

### Staff Client

- [[19193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19193) When displaying the fines of the guarantee on the guarantor account, price is not in correct format.

### System Administration

- [[16726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16726) Text in Preferences search box does not clear

### Test Suite

- [[17664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17664) Silence non-zebra warnings in t/db_dependent/Search.t
- [[19262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19262) pod_spell.t does not work
- [[19307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19307) t/db_dependent/Circulation/NoIssuesChargeGuarantees.t fails if AllowFineOverride set to allow
- [[19386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19386) t/db_dependent/SIP/Patron.t is failing randomly
- [[19392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19392) auth_values_input_www.t does not clean up
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
- Arabic (99%)
- Armenian (95%)
- Chinese (China) (85%)
- Chinese (Taiwan) (99%)
- Czech (95%)
- Danish (70%)
- English (New Zealand) (93%)
- Finnish (99%)
- French (99%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (100%)
- Greek (83%)
- Hindi (98%)
- Italian (100%)
- Korean (51%)
- Norwegian Bokmål (56%)
- Occitan (78%)
- Persian (59%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (86%)
- Slovak (92%)
- Spanish (99%)
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

The release team for Koha 16.11.14 is

- Release Managers:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
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
new features in Koha 16.11.14:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 16.11.14.

- root (1)
- Aleisha Amohia (5)
- David Bourgault (1)
- Alex Buckley (3)
- Pongtawat C (1)
- Nick Clemens (4)
- Tomás Cohen Arazi (2)
- David Cook (1)
- Marcel de Rooy (3)
- Jonathan Druart (12)
- Katrin Fischer (4)
- David Kuhn (1)
- Owen Leonard (1)
- Julian Maurice (2)
- Kyle M Hall (1)
- Dominic Pichette (1)
- Fridolin Somers (1)
- Mark Tompsett (1)
- Oleg Vasylenko (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.14

- ACPL (1)
- BibLibre (3)
- BSZ BW (4)
- bugs.koha-community.org (12)
- ByWater-Solutions (5)
- Catalyst (3)
- Prosentient Systems (1)
- punsarn.asia (1)
- Rijksmuseum (3)
- Solutions inLibro inc (2)
- Theke Solutions (2)
- translate.koha-community.org (1)
- unidentified (8)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (2)
- Amit Gupta (1)
- Christopher Brannon (2)
- Claire Gravely (1)
- David Bourgault (2)
- Dilan Johnpullé (2)
- Dominic Pichette (1)
- Fridolin Somers (40)
- Jonathan Druart (41)
- Josef Moravec (4)
- Julian Maurice (5)
- Katrin Fischer (43)
- Lee Jamison (2)
- Marc Véron (1)
- Mark Tompsett (1)
- Nick Clemens (6)
- Owen Leonard (1)
- Tomas Cohen Arazi (9)
- Kyle M Hall (2)
- Caroline Cyr La Rose (2)
- Marcel de Rooy (11)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 16.11.x. 

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 21 Nov 2017 01:35:34.
