[% BLOCK sourcetab %]
    <div id="tabrecord[% recordnumber %]">
    [% IF ( records ) %]

        <div class="record">
        <ul id="ulrecord[% recordnumber %]">
        [% FOREACH record IN records %]
            [% FOREACH fiel IN record.field %]
            <li id="k[% fiel.key %]">
                [% IF (defaultrecord) %]
                    <input type="checkbox" checked="checked" class="fieldpick" id="rec_[% recordnumber %]_[% fiel.key %]" />
                [% ELSE %]
                    <input type="checkbox" class="fieldpick" id="rec_[% recordnumber %]_[% fiel.key %]" />
                [% END %]
                <span class="field">[% fiel.tag %]</span>

                <input type="hidden" name="tag_[% fiel.tag %]_indicator1_[% fiel.key %]" value="[% fiel.indicator1 %]" />
                <input type="hidden" name="tag_[% fiel.tag %]_indicator2_[% fiel.key %]" value="[% fiel.indicator2 %]" />
                [% IF ( fiel.value ) %] / [% fiel.value %]
                <input type="hidden" name="tag_[% fiel.tag %]_code_00_[% fiel.key %]" value="00" />
                <input type="hidden" name="tag_[% fiel.tag %]_subfield_00_[% fiel.key %]" value="[% fiel.value %]" />
                [% END %]

                [% IF ( fiel.subfield ) %]
                <ul>
                    [% FOREACH subfiel IN fiel.subfield %]
                    <li id="k[% subfiel.subkey %]">
                        [% IF (defaultrecord) %]
                            <input type="checkbox" checked="checked" class="subfieldpick" id="rec_[% recordnumber %]_[% subfiel.subkey %]" />
                        [% ELSE %]
                            <input type="checkbox" class="subfieldpick" id="rec_[% recordnumber %]_[% subfiel.subkey %]" />
                        [% END %]
                        <span class="subfield">[% subfiel.subtag %]</span> / [% subfiel.value %]
                    <input type="hidden" name="tag_[% subfiel.tag %]_code_[% subfiel.subtag %]_[% subfiel.key %]_[% subfiel.subkey %]" value="[% subfiel.subtag %]" />
                    <input type="hidden" name="tag_[% subfiel.tag %]_subfield_[% subfiel.subtag %]_[% subfiel.key %]_[% subfiel.subkey %]" value="[% subfiel.value |html%]" />
                    </li>
                    [% END %]
                </ul>
                [% END %]
            [% END %]
            </li>
        [% END %]
        </ul>
        </div><!-- /div.record -->
    [% END %]
    </div><!-- /div#tabrecord[% recordnumber %] -->
[% END %]
[% BLOCK mergesource %]
<div id="tabs" class="toptabs">
<h2>Source records</h2>
    <ul>
    <li><a href="#tabrecord1">[% recordid1 %]</a></li>
    <li><a href="#tabrecord2">[% recordid2 %]</a></li>
    </ul>
    [% PROCESS sourcetab records=record1 recordnumber=1 defaultrecord=1 %]
    [% PROCESS sourcetab records=record2 recordnumber=2 defaultrecord=0 %]
</div> <!-- // #tabs -->
[% END %]
[% BLOCK mergetarget %]
<div id="result">
    <h2>Destination record</h2>
    <div style="border:1px solid #E8E8E8;padding:1em;margin-top:2em;">
        <ul id="resultul">
        [% FOREACH record IN record1 %]
            [% FOREACH fiel IN record.field %]<li id="k[% fiel.key %]">
                <span class="field">[% fiel.tag %]</span>
                <input type="hidden" name="tag_[% fiel.tag %]_indicator1_[% fiel.key %]" value="[% fiel.indicator1 %]" />
                <input type="hidden" name="tag_[% fiel.tag %]_indicator2_[% fiel.key %]" value="[% fiel.indicator2 %]" />
                [% IF ( fiel.value ) %] /
                    [% fiel.value %]
                    <input type="hidden" name="tag_[% fiel.tag %]_code_00_[% fiel.key %]" value="00" />
                    <input type="hidden" name="tag_[% fiel.tag %]_subfield_00_[% fiel.key %]" value="[% fiel.value |html%]" />
                [% END %]

                [% IF ( fiel.subfield ) %]
                    <ul>
                        [% FOREACH subfiel IN fiel.subfield %]
                            <li id="k[% subfiel.subkey %]">
                                <span class="subfield">[% subfiel.subtag %]</span> / [% subfiel.value %]
                                <input type="hidden" name="tag_[% subfiel.tag %]_code_[% subfiel.subtag %]_[% subfiel.key %]_[% subfiel.subkey %]" value="[% subfiel.subtag %]" />
                                <input type="hidden" name="tag_[% subfiel.tag %]_subfield_[% subfiel.subtag %]_[% subfiel.key %]_[% subfiel.subkey %]" value="[% subfiel.value |html%]" />
                            </li>
                        [% END %]
                    </ul>
                [% END %]
            </li>[% END %]
        [% END %]
        </ul>
    </div>
</div> <!-- // #result -->
[% END %]
