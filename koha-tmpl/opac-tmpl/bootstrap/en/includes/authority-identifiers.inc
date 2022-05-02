[% SWITCH identifier.source.lower %]
[% CASE 'orcid' %]
    <span>ORCID: </span>
    <a href="https://orcid.org/[% identifier.number | url %]">[% identifier.number | html %]</a>
[% CASE 'scopus' %]
    <span>ScopusID: </span>
    <a href="https://www.scopus.com/authid/detail.uri?authorId=[% identifier.number | url %]">[% identifier.number | html %]</a>
[% CASE 'loop' %]
    <span>loop: </span>
    <a href="https://loop.frontiersin.org/people/[% identifier.number | url %]">[% identifier.number | html %]</a>
[% CASE 'rid' %]
    <span>Publons: </span>
    <a href="https://publons.com/researcher/[% identifier.number | url %]">[% identifier.number | html %]</a>
[% CASE 'viaf' %]
    <span>VIAF: </span>
    <a href="https://viaf.org/viaf/[% identifier.number | url %]">[% identifier.number | html %]</a>
[% END %]
