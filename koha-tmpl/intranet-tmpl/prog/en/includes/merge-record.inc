[% BLOCK sourcetab %]
    <div id="tabrecord[% record.recordid %]">
        <div class="record">
            <ul id="ulrecord[% record.recordid %]">
                [% FOREACH field IN record.display %]
                  [% IF field.tag != biblionumbertag %]
                    <li id="k[% field.key %]">
                        [% IF (tabrecord.reference) %]
                            <input type="checkbox" checked="checked" class="fieldpick" id="rec_[% record.recordid %]_[% field.key %]" />
                        [% ELSE %]
                            <input type="checkbox" class="fieldpick" id="rec_[% record.recordid %]_[% field.key %]" />
                        [% END %]
                        <label for="rec_[% record.recordid %]_[% field.key %]"><span class="field">[% field.tag %]</span></label>

                        <input type="hidden" name="tag_[% field.tag %]_indicator1_[% field.key %]" value="[% field.indicator1 %]" />
                        <input type="hidden" name="tag_[% field.tag %]_indicator2_[% field.key %]" value="[% field.indicator2 %]" />
                        [% IF ( field.value ) %]
                            / [% field.value %]
                            <input type="hidden" name="tag_[% field.tag %]_code_00_[% field.key %]" value="00" />
                            <input type="hidden" name="tag_[% field.tag %]_subfield_00_[% field.key %]" value="[% field.value %]" />
                        [% END %]

                        [% IF ( field.subfield.size ) %]
                            <ul>
                                [% FOREACH subfield IN field.subfield %]
                                    <li id="k[% subfield.subkey %]">
                                        [% IF (tabrecord.reference) %]
                                            <input type="checkbox" checked="checked" class="subfieldpick" id="rec_[% record.recordid %]_[% subfield.subkey %]" />
                                        [% ELSE %]
                                            <input type="checkbox" class="subfieldpick" id="rec_[% record.recordid %]_[% subfield.subkey %]" />
                                        [% END %]
                                        <label for="rec_[% record.recordid %]_[% subfield.subkey %]"><span class="subfield">[% subfield.subtag %]</span> / [% subfield.value %]</label>
                                        <input type="hidden" name="tag_[% field.tag %]_code_[% subfield.subtag %]_[% field.key %]_[% subfield.subkey %]" value="[% subfield.subtag %]" />
                                        <input type="hidden" name="tag_[% field.tag %]_subfield_[% subfield.subtag %]_[% subfield.key %]_[% subfield.subkey %]" value="[% subfield.value |html%]" />
                                    </li>
                                [% END %]
                            </ul>
                        [% END %]
                    </li>
                  [% END %]
                [% END %]
            </ul>
        </div><!-- /div.record -->
    </div><!-- /div#tabrecordXXX -->
[% END %]

[% BLOCK mergesource %]
<div id="tabs" class="toptabs">
<h2>Source records</h2>
    <ul>
        [% FOREACH record IN sourcerecords %]
            <li>
                <a href="#tabrecord[% record.recordid %]">
                    [% record.recordid %]
                    [% IF record.reference %](ref)[% END %]
                </a>
            </li>
        [% END %]
    </ul>
    [% IF ( sourcerecords.size ) %]
        [% FOREACH record IN sourcerecords %]
            [% PROCESS sourcetab tabrecord=record %]
        [% END %]
    [% END %]
</div> <!-- // #tabs -->
[% END %]

[% BLOCK mergetarget %]
<div id="result">
    <h2>Destination record</h2>
    <div style="border:1px solid #E8E8E8;padding:1em;margin-top:2em;">
        <ul id="resultul"></ul>
    </div>
</div> <!-- // #result -->
[% END %]
