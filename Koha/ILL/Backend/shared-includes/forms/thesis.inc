<fieldset id="thesis-standard-fieldset" class="rows">
    <legend>Thesis details</legend>
    <ol id="thesis-standard-fields">
        <li>
            <label for="title">Title:</label>
            <input type="text" name="title" id="title" value="[% whole.value.other.title | html %]" />
        </li>
        <li>
            <label for="author">Author:</label>
            <input type="text" name="author" id="author" value="[% whole.value.other.author | html %]" />
        </li>
        <li>
            <label for="institution">Institution:</label>
            <input type="text" name="institution" id="institution" value="[% whole.value.other.institution | html %]" />
        </li>
        <li>
            <label for="published_date">Publication date:</label>
            <input type="text" name="published_date" id="published_date" value="[% whole.value.other.published_date | html %]" />
        </li>
        <li>
            <label for="doi">DOI:</label>
            <input type="text" name="doi" id="doi" value="[% whole.value.other.doi | html %]" />
        </li>
    </ol>
</fieldset>
