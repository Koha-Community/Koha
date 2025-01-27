[%- USE To -%]
[%- IF link && ! biblio %][% link = 0 %][% END %]
[%- IF ( link ) -%]
    <a href="[%- PROCESS biblio_a_href biblionumber => biblio.biblionumber -%]" class="title">[% PROCESS 'show-biblio-title' %]</a>
[%- ELSE -%]
    [%- PROCESS 'show-biblio-title' -%]
[%- END -%]
[%- BLOCK 'show-biblio-title' -%]
    [%- IF !biblio -%]
        <span class="biblio-no-record">No bibliographic record</span>
    [%- ELSIF !biblio.title -%]
        <span class="biblio-no-title">No title</span>
    [%- ELSE -%]
        <span class="biblio-title">[% biblio.title | html | $To %]</span>
    [%- END -%]
    [%- IF ( biblio.medium ) -%]
        <span class="biblio-medium">[%- biblio.medium | html | $To -%]</span>
    [%- END -%]
    [%- SET subtitles = biblio.subtitle.split(' \\| ') -%]
    [%- FOREACH subtitle IN subtitles -%]
        [%- IF Koha.Preference('marcflavour')=='UNIMARC' -%],[%- END -%]
        <span class="subtitle">[%- subtitle | html | $To -%]</span>
    [%- END -%]
    [%- part_numbers = biblio.part_number.split(' \\| ') -%]
    [%- part_names = biblio.part_name.split(' \\| ') -%]
    [%- i = 0 -%]
    [%- WHILE ( part_numbers.$i.defined || part_names.$i.defined ) -%]
        [%- IF ( part_numbers.$i.defined ) -%]
            <span class="part-number">[%- part_numbers.$i | html | $To -%]</span>
        [%- END -%]
        [%- IF ( part_names.$i.defined ) -%]
            <span class="part-name">[%- part_names.$i | html | $To -%]</span>
        [%- END -%]
        [%- i = i + 1 -%]
    [%- END -%]
[%- END -%]
