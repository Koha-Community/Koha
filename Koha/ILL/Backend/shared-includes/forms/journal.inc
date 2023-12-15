<fieldset id="journal-standard-fieldset" class="rows">
    <legend>Journal details</legend>
    <ol id="journal-standard-fields">
        <li>
            <label for="title">Title:</label>
            <input type="text" name="title" id="title" value="[% whole.value.other.title | html %]" />
        </li>
        <li>
            <label for="volume">Volume:</label>
            <input type="text" name="volume" id="volume" value="[% whole.value.other.volume | html %]" />
        </li>
        <li>
            <label for="issue">Issue number:</label>
            <input type="text" name="issue" id="issue" value="[% whole.value.other.issue | html %]" />
        </li>
        <li>
            <label for="year">Year:</label>
            <input type="text" name="year" id="year" value="[% whole.value.other.year | html %]" />
        </li>
        <li>
            <label for="issn">ISSN:</label>
            <input type="text" name="issn" id="issn" value="[% whole.value.other.issn | html %]" />
        </li>
        <li>
            <label for="doi">DOI:</label>
            <input type="text" name="doi" id="doi" value="[% whole.value.other.doi | html %]" />
        </li>
    </ol>
</fieldset>
