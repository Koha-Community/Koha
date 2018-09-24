<div id="makechart" style="display:none;">
    [% supposed_x = header_row.shift.cell %]

    <fieldset>
        <legend>Draw a chart</legend>
        <ol>
            <li>
                <label for="chart-type">Chart type</label>
                <select name="chart-type" id="chart-type">
                    <option value="pie">Pie</option>
                    <option value="bar">Bar</option>
                    <option value="line">Line</option>
                </select>

                <div id="chart-column-horizontal">
                    <label for="horizontal">Horizontal bar:</label>
                    <input id="horizontal" name="column-horizontal" type="checkbox">
                </div>
            </li>

            <li>
                <label for="x_element">x column:</label>
                <select id="x_element" name="x">
                    <option value="[% supposed_x %]" selected>[% supposed_x %]</option>
                    [% FOREACH header IN header_row %]
                        <option value="[% header.cell %]">[% header.cell %]</option>
                    [% END %]
                </select>
            </li>

            <div>
                <label for="include-all">Include all rows (ignore pagination)</label>
                <input id="include-all" name="chart-include-all" type="checkbox">
            </div>


            <label for="exclude-last">Exclude last line (Rollup)</label>
            <input id="exclude-last" name="chart-exclude-last" type="checkbox">

            [% column = 1 %]
            <li>
                [% FOREACH header IN header_row %]
                    <fieldset class="chart-column-conf" id="column_[% column %]" style="display: inline !important;">
                        <legend>
                            Column [% column %]
                            <a class="chart-column-delete" href="#" data-column="[% column %]">
                                <img src="[% interface %]/[% theme %]/img/x.png" alt="Delete" />
                            </a>
                        </legend>
                        <div>
                            <label for="y_[% column %]" >y:</label>
                            <select id="y_[% column %]" name="y">
                                <option value="[% supposed_x %]" selected>[% supposed_x %]</option>
                                [% FOREACH h IN header_row %]
                                    [% IF header.cell == h.cell %]
                                        <option value="[% h.cell %]" selected>[% h.cell %]</option>
                                    [% ELSE %]
                                        <option value="[% h.cell %]">[% h.cell %]</option>
                                    [% END %]
                            [% END %]
                            </select>
                        </div>

                        <div class="chart-column-group">
                            [% i = 1 %]
                            <label for="group_[% column %]">Group:</label>
                            <select id="group_[% column %]" name="group">
                                [% FOREACH h IN header_row %]
                                    [% IF i == column %]
                                        <option value="[% i %]" selected>[% i %]</option>
                                    [% ELSE %]
                                        <option value="[% i %]">[% i %]</option>
                                    [% END %]
                                    [% i = i + 1 %]
                                [% END %]
                            </select>
                        </div>

                        <div class="chart-column-line">
                            <label for="line_[% column %]">line:</label>
                            <input class="column-line" id="column-line" name="[% header.cell %]" type="checkbox">
                        </div>
                    </fieldset>
                    [% column = column + 1 %]
                [% END %]
            </li>

            <li>
                <button id="draw-chart" class="btn btn-default">Draw</button>
            </li>
        </ol>
    </fieldset>
    [% item = { cell = supposed_x } %]
    [% header_row.unshift(item) %]
    <div id="chart"></div>
</div>
