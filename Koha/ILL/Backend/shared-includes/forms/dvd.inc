<fieldset id="dvd-standard-fieldset" class="rows">
    <legend>DVD details</legend>
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
            <label for="studio">Studio:</label>
            <input type="text" name="studio" id="studio" value="[% whole.value.other.studio | html %]" />
        </li>
        <li>
            <label for="genre">Genre:</label>
            <input type="text" name="genre" id="genre" value="[% whole.value.other.genre | html %]" />
        </li>
        <li>
            <label for="year">Year:</label>
            <input type="text" name="year" id="year" value="[% whole.value.other.year | html %]" />
        </li>
        <li>
            <label for="format">Format:</label>
            <input type="text" name="format" id="format" value="[% whole.value.other.format | html %]" />
        </li>
        <li>
            <label for="language">Language:</label>
            <input type="text" name="language" id="language" value="[% whole.value.other.language | html %]" />
        </li>
    </ol>
</fieldset>
