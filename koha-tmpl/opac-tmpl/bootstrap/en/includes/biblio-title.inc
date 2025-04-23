[%- IF link && ! biblio %][% link = 0 %][% END %]
[%- IF ( link ) -%]
    <a href="[%- PROCESS biblio_a_href biblionumber => biblio.biblionumber -%]" class="title">[% PROCESS 'show-biblio-title' %]</a>
[%- ELSIF (deleted) -%]
    <span class="deleted-biblio">(Deleted bibliographic record) [%- PROCESS 'show-biblio-title' -%]</span>
[%- ELSE -%]
    [%- PROCESS 'show-biblio-title' -%]
[%- END -%]
[%- BLOCK 'show-biblio-title' -%]
    [%- IF !biblio -%]
        <span class="biblio-no-record">No bibliographic record</span>
    [%- ELSIF !biblio.title -%]
        <span class="biblio-no-title">No title</span>
    [%- ELSE -%]
        <span class="biblio-title">[% biblio.title | html %]</span>
    [%- END -%]
    [%- IF ( biblio.medium ) -%]
        <span class="biblio-medium">[%- biblio.medium | html -%]</span>
    [%- END -%]
    [%- SET subtitles = biblio.subtitle.split(' \\| ') -%]
    [%- FOREACH subtitle IN subtitles -%]
        [%- IF Koha.Preference('marcflavour')=='UNIMARC' -%],[%- END -%]
        <span class="subtitle">[%- subtitle | html -%]</span>
    [%- END -%]
    [%- part_numbers = biblio.part_number.split(' \\| ') -%]
    [%- part_names = biblio.part_name.split(' \\| ') -%]
    [%- i = 0 -%]
    [%- WHILE ( part_numbers.$i.defined || part_names.$i.defined ) -%]
        [%- IF ( part_numbers.$i.defined ) -%]
            <span class="part-number">[%- part_numbers.$i | html -%]</span>
        [%- END -%]
        [%- IF ( part_names.$i.defined ) -%]
            <span class="part-name">[%- part_names.$i | html -%]</span>
        [%- END -%]
        [%- i = i + 1 -%]
    [%- END -%]
[%- END -%]
