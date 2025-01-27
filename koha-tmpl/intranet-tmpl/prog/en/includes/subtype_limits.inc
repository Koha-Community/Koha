[%- BLOCK subtype_dropdowns -%]
    <select name="limit" class="subtype">
        [% IF ( limits.aud.size ) %]
            <option value="" class="menuheader">Any audience</option>
        [% ELSE %]
            <option value="" selected="selected" class="menuheader">Any audience</option>
        [% END %]
        [% IF (limits.aud.0 == 'a' ) %]
            <option selected="selected" value="aud:a">Preschool</option>
        [% ELSE %]
            <option value="aud:a">Preschool</option>
        [% END %]
        [% IF (limits.aud.0 == 'b' ) %]
            <option value="aud:b" selected="selected">Primary</option>
        [% ELSE %]
            <option value="aud:b">Primary</option>
        [% END %]
        [% IF (limits.aud.0 == 'c' ) %]
            <option value="aud:c" selected="selected">Pre-adolescent</option>
        [% ELSE %]
            <option value="aud:c">Pre-adolescent</option>
        [% END %]
        [% IF (limits.aud.0 == 'd' ) %]
            <option value="aud:d" selected="selected">Adolescent</option>
        [% ELSE %]
            <option value="aud:d">Adolescent</option>
        [% END %]
        [% IF (limits.aud.0 == 'e' ) %]
            <option value="aud:e" selected="selected">Adult</option>
        [% ELSE %]
            <option value="aud:e">Adult</option>
        [% END %]
        [% IF (limits.aud.0 == 'f' ) %]
            <option value="aud:f" selected="selected">Specialized</option>
        [% ELSE %]
            <option value="aud:f">Specialized</option>
        [% END %]
        [% IF (limits.aud.0 == 'g' ) %]
            <option value="aud:g" selected="selected">General</option>
        [% ELSE %]
            <option value="aud:g">General</option>
        [% END %]
        [% IF (limits.aud.0 == 'j' ) %]
            <option value="aud:j" selected="selected">Juvenile</option>
        [% ELSE %]
            <option value="aud:j">Juvenile</option>
        [% END %]
        [% limits.delete( 'aud' ) %]
    </select>

    <select name="limit" class="subtype">
        [% IF ( limits.fic.size OR limits.bio.size OR limits.mus.size ) %]
            <option value="" class="menuheader">Any content</option>
        [% ELSE %]
            <option value="" selected="selected" class="menuheader">Any content</option>
        [% END %]
        [% IF (limits.fic.0 == '1' ) %]
            <option value="fic:1" selected="selected">Fiction</option>
        [% ELSE %]
            <option value="fic:1">Fiction</option>
        [% END %]
        [% IF (limits.fic.0 == '0' ) %]
            <option value="fic:0" selected="selected">Non-fiction</option>
        [% ELSE %]
            <option value="fic:0">Non-fiction</option>
        [% END %]
        [% IF (limits.bio.0 == 'b' ) %]
            <option value="bio:b" selected="selected">Biography</option>
        [% ELSE %]
            <option value="bio:b">Biography</option>
        [% END %]
        [% IF (limits.mus.0 == 'j' ) %]
            <option value="mus:j" selected="selected">Musical recording</option>
        [% ELSE %]
            <option value="mus:j">Musical recording</option>
        [% END %]
        [% IF (limits.mus.0 == 'i' ) %]
            <option value="mus:i" selected="selected">Non-musical recording</option>
        [% ELSE %]
            <option value="mus:i">Non-musical recording</option>
        [% END %]
        [% limits.delete( 'fic' ) %]
        [% limits.delete( 'bio' ) %]
        [% limits.delete( 'mus' ) %]
    </select>

    [% SET lformat = 'l-format' %]
    <select name="limit" class="subtype">
        [% IF ( limits.$lformat.size ) %]
            <option value="" class="menuheader">Any format</option>
        [% ELSE %]
            <option value="" selected="selected" class="menuheader">Any format</option>
        [% END %]
        [% IF (limits.$lformat.0 == 'ta' ) %]
            <option value="l-format:ta" selected="selected">Regular print</option>
        [% ELSE %]
            <option value="l-format:ta">Regular print</option>
        [% END %]
        [% IF (limits.$lformat.0 == 'tb' ) %]
            <option value="l-format:tb" selected="selected">Large print</option>
        [% ELSE %]
            <option value="l-format:tb">Large print</option>
        [% END %]
        [% IF (limits.$lformat.0 == 'tc or fb' ) %]
            <option value="l-format:tc or fb" selected="selected">Braille</option>
        [% ELSE %]
            <option value="l-format:tc or fb">Braille</option>
        [% END %]
        <option value="">-----------</option>
        [% IF (limits.$lformat.0 == 'sd' ) %]
            <option value="l-format:sd" selected="selected">CD audio</option>
        [% ELSE %]
            <option value="l-format:sd">CD audio</option>
        [% END %]
        [% IF (limits.$lformat.0 == 'ss' ) %]
            <option value="l-format:ss" selected="selected">Cassette recording</option>
        [% ELSE %]
            <option value="l-format:ss">Cassette recording</option>
        [% END %]
        [% IF (limits.$lformat.0 == 'vf' ) %]
            <option value="l-format:vf" selected="selected">VHS tape / Videocassette</option>
        [% ELSE %]
            <option value="l-format:vf">VHS tape / Videocassette</option>
        [% END %]
        [% IF (limits.$lformat.0 == 'vd' ) %]
            <option value="l-format:vd" selected="selected">DVD video / Videodisc</option>
        [% ELSE %]
            <option value="l-format:vd">DVD video / Videodisc</option>
        [% END %]
        [% IF (limits.$lformat.0 == 'co' ) %]
            <option value="l-format:co" selected="selected">CD software</option>
        [% ELSE %]
            <option value="l-format:co">CD software</option>
        [% END %]
        [% IF (limits.$lformat.0 == 'cr' ) %]
            <option value="l-format:cr" selected="selected">Website</option>
        [% ELSE %]
            <option value="l-format:cr">Website</option>
        [% END %]
        [% limits.delete( 'l-format' ) %]
    </select>

    <select name="limit" class="subtype">
        [% IF ( limits.ctype.size ) %]
            <option value="">Additional content types</option>
        [% ELSE %]
            <option value="" selected="selected">Additional content types</option>
        [% END %]
        [% IF (limits.ctype.0 == 'a' ) %]
            <option value="ctype:a" selected="selected">Abstracts / Summaries</option>
        [% ELSE %]
            <option value="ctype:a">Abstracts / Summaries</option>
        [% END %]
        [% IF (limits.ctype.0 == 'b' ) %]
            <option value="ctype:b" selected="selected">Bibliographies</option>
        [% ELSE %]
            <option value="ctype:b">Bibliographies</option>
        [% END %]
        [% IF (limits.ctype.0 == 'c' ) %]
            <option value="ctype:c" selected="selected">Catalogs</option>
        [% ELSE %]
            <option value="ctype:c">Catalogs</option>
        [% END %]
        [% IF (limits.ctype.0 == 'e' ) %]
            <option value="ctype:e" selected="selected">Encyclopedias </option>
        [% ELSE %]
            <option value="ctype:e">Encyclopedias </option>
        [% END %]
        [% IF (limits.ctype.0 == 'f' ) %]
            <option value="ctype:f" selected="selected">Handbooks</option>
        [% ELSE %]
            <option value="ctype:f">Handbooks</option>
        [% END %]
        [% IF (limits.ctype.0 == 'g' ) %]
            <option value="ctype:g" selected="selected">Legal articles</option>
        [% ELSE %]
            <option value="ctype:g">Legal articles</option>
        [% END %]
        [% IF (limits.ctype.0 == 'i' ) %]
            <option value="ctype:i" selected="selected">Indexes</option>
        [% ELSE %]
            <option value="ctype:i">Indexes</option>
        [% END %]
        [% IF (limits.ctype.0 == 'j' ) %]
            <option value="ctype:j" selected="selected">Patent document</option>
        [% ELSE %]
            <option value="ctype:j">Patent document</option>
        [% END %]
        [% IF (limits.ctype.0 == 'k' ) %]
            <option value="ctype:k" selected="selected">Discographies</option>
        [% ELSE %]
            <option value="ctype:k">Discographies</option>
        [% END %]
        [% IF (limits.ctype.0 == 'l' ) %]
            <option value="ctype:l" selected="selected">Legislation</option>
        [% ELSE %]
            <option value="ctype:l">Legislation</option>
        [% END %]
        [% IF (limits.ctype.0 == 'm' ) %]
            <option value="ctype:m" selected="selected">Theses</option>
        [% ELSE %]
            <option value="ctype:m">Theses</option>
        [% END %]
        [% IF (limits.ctype.0 == 'n' ) %]
            <option value="ctype:n" selected="selected">Surveys</option>
        [% ELSE %]
            <option value="ctype:n">Surveys</option>
        [% END %]
        [% IF (limits.ctype.0 == 'o' ) %]
            <option value="ctype:o" selected="selected">Reviews</option>
        [% ELSE %]
            <option value="ctype:o">Reviews</option>
        [% END %]
        [% IF (limits.ctype.0 == 'p' ) %]
            <option value="ctype:p" selected="selected">Programmed texts</option>
        [% ELSE %]
            <option value="ctype:p">Programmed texts</option>
        [% END %]
        [% IF (limits.ctype.0 == 'q' ) %]
            <option value="ctype:q" selected="selected">Filmographies</option>
        [% ELSE %]
            <option value="ctype:q">Filmographies</option>
        [% END %]
        [% IF (limits.ctype.0 == 'r' ) %]
            <option value="ctype:r" selected="selected">Directories</option>
        [% ELSE %]
            <option value="ctype:r">Directories</option>
        [% END %]
        [% IF (limits.ctype.0 == 's' ) %]
            <option value="ctype:s" selected="selected">Statistics</option>
        [% ELSE %]
            <option value="ctype:s">Statistics</option>
        [% END %]
        [% IF (limits.ctype.0 == 't' ) %]
            <option value="ctype:t" selected="selected">Technical reports</option>
        [% ELSE %]
            <option value="ctype:t">Technical reports</option>
        [% END %]
        [% IF (limits.ctype.0 == 'v' ) %]
            <option value="ctype:v" selected="selected">Legal cases and case notes</option>
        [% ELSE %]
            <option value="ctype:v">Legal cases and case notes</option>
        [% END %]
        [% IF (limits.ctype.0 == 'w' ) %]
            <option value="ctype:w" selected="selected">Law reports and digests</option>
        [% ELSE %]
            <option value="ctype:w">Law reports and digests</option>
        [% END %]
        [% IF (limits.ctype.0 == 'z' ) %]
            <option value="ctype:z" selected="selected">Treaties </option>
        [% ELSE %]
            <option value="ctype:z">Treaties </option>
        [% END %]
        [% limits.delete( 'ctype' ) %]
    </select>
[%- END -%]
