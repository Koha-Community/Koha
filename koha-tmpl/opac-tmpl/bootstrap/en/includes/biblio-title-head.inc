[% IF ( biblio.title ) %]
    [% biblio.title | html %]
[% ELSE %]
    No title
[% END %]
[% FOREACH subtitle IN biblio.subtitle.split(' \| ') %][% IF Koha.Preference('marcflavour')=='UNIMARC' %],[% END %]
    [% subtitle | html %]
[% END %]
[% biblio.part_number | html %] [% biblio.part_name | html %]
