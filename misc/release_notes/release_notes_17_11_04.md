# RELEASE NOTES FOR KOHA 17.11.04
26 Mar 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.04 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.04.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.04 is a bugfix/maintenance release.

It includes 14 bugfixes.



## Critical bugs fixed

### Acquisitions

- [[20303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20303) Receive order fails if no "authorised_by" value
- [[20446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20446) QUOTES processing broken by run time error

### Architecture, internals, and plumbing

- [[20145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20145) borrowers.datexpiry eq '0000-00-00' means expired?

### Hold requests

- [[20167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20167) Item hold is set to bibliographic hold when changing pickup location

### OPAC

- [[20218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20218) Tracklinks fails when URL has special characters


## Other bugs fixed

### Acquisitions

- [[20148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20148) Don't allow adding same user multiple times to a basket or an order
- [[20201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20201) Silence warnings in admin/aqplan.pl

### Command-line Utilities

- [[19452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19452) The -truncate option in borrowers-force-messaging-defaults.pl should not remove category preferences

### Patrons

- [[20367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20367) userid resets to firstname.surname when BorrowerUnwantedField contains userid

### SIP2

- [[20348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20348) SIP2 patron identification fails to use userid

### Test Suite

- [[19979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19979) Search.t fails on facet info with one branch
- [[20250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20250) NoIssuesChargeGuarantees.t is still failing randomly
- [[20466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20466) Incorrect fixtures for active currency in t/Prices.t


## Security bugs fixed

- [[20083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20083) Information disclosure when (mis)using the MARC Preview feature

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
- Armenian (100%)
- Basque (76%)
- Chinese (China) (80%)
- Chinese (Taiwan) (100%)
- Czech (94%)
- Danish (66%)
- English (New Zealand) (99%)
- Finnish (96%)
- French (97%)
- French (Canada) (92%)
- German (99%)
- German (Switzerland) (99%)
- Greek (79%)
- Hindi (99%)
- Italian (99%)
- Norwegian Bokmål (55%)
- Occitan (73%)
- Persian (55%)
- Polish (97%)
- Portuguese (100%)
- Portuguese (Brazil) (81%)
- Slovak (97%)
- Spanish (100%)
- Swedish (91%)
- Turkish (100%)
- Vietnamese (68%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.04 is

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
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.04:


We thank the following individuals who contributed patches to Koha 17.11.04.

- Colin Campbell (1)
- Nick Clemens (2)
- Tomás Cohen Arazi (2)
- Marcel de Rooy (2)
- Jonathan Druart (6)
- Pasi Kallinen (1)
- Jose Martin (1)
- Andreas Roussos (1)
- Lari Taskula (1)
- Mark Tompsett (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.04

-  (0)
- bugs.koha-community.org (6)
- ByWater-Solutions (2)
- jns.fi (1)
- joensuu.fi (1)
- PTFS-Europe (1)
- Rijksmuseum (2)
- Theke Solutions (2)
- unidentified (4)

We also especially thank the following individuals who tested patches
for Koha.

- Brendan Gallagher (1)
- Charles Farmer (1)
- Claire Gravely (3)
- Colin Campbell (1)
- Jonathan Druart (12)
- Josef Moravec (4)
- Katrin Fischer (4)
- Mark Tompsett (2)
- Nick Clemens (21)
- Pasi Kallinen (1)
- Roch D'Amour (2)
- Kyle M Hall (1)
- Marcel de Rooy (4)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 1711_rel.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 Mar 2018 15:23:07.
