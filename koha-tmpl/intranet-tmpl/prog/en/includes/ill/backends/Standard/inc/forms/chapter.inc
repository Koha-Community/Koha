<fieldset id="book-standard-fieldset" class="rows">
    <legend>Book details</legend>
    <ol id="publication-standard-fields">
        [% PROCESS book_text_input_fields %]
    </ol>
</fieldset>
<fieldset id="chapter-standard-fieldset" class="rows">
    <legend>Chapter details</legend>
    <ol id="chapter-standard-fields">
        [% PROCESS ill_text_input_field id = 'chapter_author' label = t('Author') value = whole.value.other.chapter_author %]
        [% PROCESS ill_text_input_field id = 'chapter' label = t('Chapter') value = whole.value.other.chapter %]
        [% PROCESS ill_text_input_field id = 'pages' label = t('Pages') value = whole.value.other.pages %]
    </ol>
</fieldset>
