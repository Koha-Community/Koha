<fieldset id="conference-standard-fieldset" class="rows">
    <legend>Conference details</legend>
    <ol id="conference-standard-fields">
        <li>
            <label for="title">Conference title:</label>
            <input type="text" name="title" id="title" value="[% whole.value.other.title | html %]" />
        </li>
        <li>
            <label for="publication">Publication:</label>
            <input type="text" name="publication" id="publication" value="[% whole.value.other.publication | html %]" />
        </li>
        <li>
            <label for="conference_date">Conference date:</label>
            <input type="text" name="conference_date" id="conference_date" value="[% whole.value.other.conference_date | html %]" />
        </li>
        <li>
            <label for="venue">Venue:</label>
            <input type="text" name="venue" id="venue" value="[% whole.value.other.venue | html %]" />
        </li>
        <li>
            <label for="sponsor">Sponsor:</label>
            <input type="text" name="sponsor" id="sponsor" value="[% whole.value.other.sponsor | html %]" />
        </li>
        <li>
            <label for="volume">Volume:</label>
            <input type="text" name="volume" id="volume" value="[% whole.value.other.volume | html %]" />
        </li>
        <li>
            <label for="isbn">ISBN:</label>
            <input type="text" name="isbn" id="isbn" value="[% whole.value.other.isbn | html %]" />
        </li>
        <li>
            <label for="issn">ISSN:</label>
            <input type="text" name="issn" id="issn" value="[% whole.value.other.issn | html %]" />
        </li>
        <li>
            <label for="part_edition">Part:</label>
            <input type="text" name="part_edition" id="part_edition" value="[% whole.value.other.part_edition | html %]" />
        </li>
        <li>
            <label for="paper_title">Paper title:</label>
            <input type="text" name="paper_title" id="paper_title" value="[% whole.value.other.paper_title | html %]" />
        </li>
        <li>
            <label for="paper_author">Paper author:</label>
            <input type="text" name="paper_author" id="paper_author" value="[% whole.value.other.paper_author | html %]" />
        </li>
    </ol>
</fieldset>
