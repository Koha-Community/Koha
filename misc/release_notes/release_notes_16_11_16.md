# RELEASE NOTES FOR KOHA 16.11.16
22 Feb 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.16 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.16.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.16 is a bugfix/maintenance release.

It includes 1 enhancements, 4 bugfixes.




## Enhancements

### Web services

- [[18922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18922) Mana - Share review


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[19847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19847) tracklinks.pl accepts any url from a parameter for proxying

### OPAC

- [[19911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19911) Passwords displayed to user during self-registration are not HTML-encoded


## Other bugs fixed

### Architecture, internals, and plumbing

- [[19738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19738) XSS in serials module

### System Administration

- [[19560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19560) Unable to delete library when branchcode contains special characters



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
- Basque (80%)
- Chinese (China) (85%)
- Chinese (Taiwan) (99%)
- Czech (95%)
- Danish (70%)
- English (New Zealand) (93%)
- Finnish (99%)
- French (99%)
- French (Canada) (93%)
- German (100%)
- German (Switzerland) (99%)
- Greek (84%)
- Hindi (99%)
- Italian (99%)
- Korean (51%)
- Norwegian Bokmål (56%)
- Occitan (78%)
- Persian (59%)
- Polish (99%)
- Portuguese (99%)
- Portuguese (Brazil) (86%)
- Slovak (92%)
- Spanish (100%)
- Swedish (98%)
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

The release team for Koha 16.11.16 is

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
new features in Koha 16.11.16:


We thank the following individuals who contributed patches to Koha 16.11.16.

- root (1)
- Chris Cormack (4)
- Marcel de Rooy (1)
- Jonathan Druart (4)
- Josef Moravec (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.16

- bugs.koha-community.org (4)
- Catalyst (4)
- Rijksmuseum (1)
- translate.koha-community.org (2)
- unidentified (1)

We also especially thank the following individuals who tested patches
for Koha.

- Arturo (2)
- Chris Cormack (7)
- Fridolin Somers (6)
- Jonathan Druart (4)
- Josef Moravec (1)
- Julian Maurice (1)
- Katrin Fischer (4)
- Nick Clemens (4)
- Owen Leonard (2)
- Marcel de Rooy (2)


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

Autogenerated release notes updated last on 22 Feb 2018 19:52:14.
