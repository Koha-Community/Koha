[%- BLOCK subtype_limits_description -%]
    [%- SWITCH subtype_limit -%]
        [%- CASE  'aud:a' -%]<span>Preschool</span>
        [%- CASE  'aud:b' -%]<span>Primary</span>
        [%- CASE  'aud:c' -%]<span>Pre-adolescent</span>
        [%- CASE  'aud:d' -%]<span>Adolescent</span>
        [%- CASE  'aud:e' -%]<span>Adult</span>
        [%- CASE  'aud:f' -%]<span>Specialized</span>
        [%- CASE  'aud:g' -%]<span>General</span>
        [%- CASE  'aud:j' -%]<span>Juvenile</span>
        [%- CASE  'fic:1' -%]<span>Fiction</span>
        [%- CASE  'fic:0' -%]<span>Non-fiction</span>
        [%- CASE  'bio:b' -%]<span>Biography</span>
        [%- CASE  'mus:j' -%]<span>Musical recording</span>
        [%- CASE  'mus:i' -%]<span>Non-musical recording</span>
        [%- CASE  'l-format:ta' -%]<span>Regular print</span>
        [%- CASE  'l-format:tb' -%]<span>Large print</span>
        [%- CASE  'l-format:tc or l-format:fb' -%]<span>Braille</span>
        [%- CASE  '' -%]<span>-----------</span>
        [%- CASE  'l-format:sd' -%]<span>CD audio</span>
        [%- CASE  'l-format:ss' -%]<span>Cassette recording</span>
        [%- CASE  'l-format:vf' -%]<span>VHS tape / Videocassette</span>
        [%- CASE  'l-format:vd' -%]<span>DVD video / Videodisc</span>
        [%- CASE  'l-format:co' -%]<span>CD software</span>
        [%- CASE  'l-format:cr' -%]<span>Website</span>
        [%- CASE  'ctype:a' -%]<span>Abstracts / Summaries</span>
        [%- CASE  'ctype:b' -%]<span>Bibliographies</span>
        [%- CASE  'ctype:c' -%]<span>Catalogs</span>
        [%- CASE  'ctype:d' -%]<span>Dictionaries</span>
        [%- CASE  'ctype:e' -%]<span>Encyclopedias </span>
        [%- CASE  'ctype:f' -%]<span>Handbooks</span>
        [%- CASE  'ctype:g' -%]<span>Legal articles</span>
        [%- CASE  'ctype:i' -%]<span>Indexes</span>
        [%- CASE  'ctype:j' -%]<span>Patent document</span>
        [%- CASE  'ctype:k' -%]<span>Discographies</span>
        [%- CASE  'ctype:l' -%]<span>Legislation</span>
        [%- CASE  'ctype:m' -%]<span>Theses</span>
        [%- CASE  'ctype:n' -%]<span>Surveys</span>
        [%- CASE  'ctype:o' -%]<span>Reviews</span>
        [%- CASE  'ctype:p' -%]<span>Programmed texts</span>
        [%- CASE  'ctype:q' -%]<span>Filmographies</span>
        [%- CASE  'ctype:r' -%]<span>Directories</span>
        [%- CASE  'ctype:s' -%]<span>Statistics</span>
        [%- CASE  'ctype:t' -%]<span>Technical reports</span>
        [%- CASE  'ctype:v' -%]<span>Legal cases and case notes</span>
        [%- CASE  'ctype:w' -%]<span>Law reports and digests</span>
        [%- CASE  'ctype:z' -%]<span>Treaties </span>
    [%- END -%]
[%- END -%]
