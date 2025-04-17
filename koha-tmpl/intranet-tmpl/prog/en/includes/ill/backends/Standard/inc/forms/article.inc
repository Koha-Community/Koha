<fieldset id="journal-standard-fieldset" class="rows">
    <legend>Journal details</legend>
    <ol id="journal-standard-fields">
        [% PROCESS journal_text_input_fields %]
    </ol>
</fieldset>
<fieldset id="article-standard-fieldset" class="rows">
    <legend>Article details</legend>
    <ol id="article-standard-fields">
        [% PROCESS ill_text_input_field id = 'article_title' label = t('Article title') value = whole.value.other.article_title %]
        [% PROCESS ill_text_input_field id = 'article_author' label = t('Article author') value = whole.value.other.article_author %]
        [% PROCESS ill_text_input_field id = 'published_date' label = t('Publication date') value = whole.value.other.published_date %]
        [% PROCESS ill_text_input_field id = 'pages' label = t('Pages') value = whole.value.other.pages %]
        [% PROCESS ill_text_input_field id = 'doi' label = t('DOI') value = whole.value.other.doi %]
    </ol>
</fieldset>
