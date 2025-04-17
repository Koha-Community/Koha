<fieldset id="journal-standard-fieldset" class="rows">
    <legend>Journal details</legend>
    <ol id="journal-standard-fields">
        [% PROCESS journal_text_input_fields %]
        [% PROCESS ill_text_input_field id = 'doi' label = t('DOI') value = whole.value.other.doi %]
    </ol>
</fieldset>
