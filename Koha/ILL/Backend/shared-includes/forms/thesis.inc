<fieldset id="thesis-standard-fieldset" class="rows">
    <legend>Thesis details</legend>
    <ol id="thesis-standard-fields">
        [% PROCESS ill_text_input_field id = 'title' label = t('Title') value = whole.value.other.title %]
        [% PROCESS ill_text_input_field id = 'author' label = t('Author') value = whole.value.other.author %]
        [% PROCESS ill_text_input_field id = 'institution' label = t('Institution') value = whole.value.other.institution %]
        [% PROCESS ill_text_input_field id = 'published_date' label = t('Publication date') value = whole.value.other.published_date %]
        [% PROCESS ill_text_input_field id = 'doi' label = t('DOI') value = whole.value.other.doi %]
    </ol>
</fieldset>
