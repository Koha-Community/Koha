<fieldset id="book-standard-fieldset" class="rows">
    <legend>Book details</legend>
    <ol id="publication-standard-fields">
        <li>
            <label for="title">Title:</label>
            <input type="text" name="title" id="title" value="[% whole.value.other.title | html %]" />
        </li>
        <li>
            <label for="author">Author:</label>
            <input type="text" name="author" id="author" value="[% whole.value.other.author | html %]" />
        </li>
        <li>
            <label for="editor">Editor:</label>
            <input type="text" name="editor" id="editor" value="[% whole.value.other.editor | html %]" />
        </li>
        <li>
            <label for="publisher">Publisher:</label>
            <input type="text" name="publisher" id="publisher" value="[% whole.value.other.publisher | html %]" />
        </li>
        <li>
            <label for="published_place">Place of publication:</label>
            <input type="text" name="published_place" id="published_place" value="[% whole.value.other.published_place | html %]" />
        </li>
        <li>
            <label for="year">Year:</label>
            <input type="text" name="year" id="year" value="[% whole.value.other.year | html %]" />
        </li>
        <li>
            <label for="part_edition">Part / Edition:</label>
            <input type="text" name="part_edition" id="part_edition" value="[% whole.value.other.part_edition | html %]" />
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
            <label for="doi">DOI:</label>
            <input type="text" name="doi" id="doi" value="[% whole.value.other.doi | html %]" />
        </li>
    </ol>
</fieldset>
