<p>
    <a id="show_coded_fields" class="toggle_element" data-element="#Coded_Fields,#show_coded_fields,#hide_coded_fields" href="#"><i class="fa-solid fa-square-plus"></i> Show coded information filters</a>
    <a id="hide_coded_fields" class="toggle_element" data-element="#Coded_Fields,#show_coded_fields,#hide_coded_fields" href="#" style="display:none;"><i class="fa-solid fa-square-minus"></i> Hide coded information filters</a>
</p>
<div style="display:none;" id="Coded_Fields">
<!-- SUBTYPE LIMITS -->
        <fieldset>
        <legend>Coded fields</legend>
        <p>
        <label for="audience">Audience: </label>
        <select id="audience" name="limit" class="subtype">
            <option value="" selected="selected" >Any</option>
            <option value="ta:a">juvenile, general</option>
            <option value="ta:b">pre-primary (0-5)</option>
            <option value="ta:c">primary (5-8)</option>
            <option value="ta:d">children (9-14)</option>
            <option value="ta:e">young adult</option>
            <option value="ta:k">adult, serious</option>
            <option value="ta:m">adult, General</option>
            <option value="ta:u">unknown</option>
		</select>
        </p>
		<p>
        <label for="physical_presentation">Physical presentation: </label>
        <select id="physical_presentation" name="limit" class="subtype">
            <option value="" selected="selected" >Any</option>
            <option value="ff8-23:r">regular print</option>
            <option value="ff8-23:d">large print</option>
            <option value="ff8-23:e">newspaper format</option>
            <option value="ff8-23:f">Braille or Moon script</option>
            <option value="ff8-23:g">microprint</option>
            <option value="ff8-23:h">hand-written</option>
            <option value="ff8-23:i">multimedia</option>
            <option value="ff8-23:j">mini-print</option>
            <option value="ff8-23:s">electronic resource</option>
            <option value="ff8-23:t">microform</option>
            <option value="ff8-23:z">other form of textual material</option>
		</select>
        </p>
		<p>
            <label for="literary_genre">Literary genre: </label>
            <select id="literary_genre" name="limit" class="subtype">
			<option value="" selected="selected" >Any</option>
            <option value="lf:a">fiction</option>
            <option value="lf:b">drama</option>
            <option value="lf:c">essays</option>
            <option value="lf:d">humour, satire</option>
            <option value="lf:e">letters</option>
            <option value="lf:f">short stories</option>
            <option value="lf:g">poetry</option>
            <option value="lf:h">speeches, oratory</option>
            <option value="lf:i">libretto</option>
            <option value="lf:y">not a literary text</option>
            <option value="lf:z">multiple/other literary forms</option>
    </select>
    </p>
        <p>
            <label for="biography">Biography: </label>
            <select id="biography" name="limit" class="subtype">
            <option value="">Any</option>
                <option value="bio:y">not a biography</option>
                <option value="bio:a">autobiography</option>
                <option value="bio:b">individual biography</option>
                <option value="bio:c">collective biography</option>
                <option value="bio:d">contains biographical data</option>
		</select>
        </p>
        <p>
            <label for="illustration">Illustration: </label>
            <select id="illustration" name="limit" class="subtype">
            <option value="">Any</option>
                <option value="ff8-18-21:a">illustrations</option>
                <option value="ff8-18-21:b">maps</option>
                <option value="ff8-18-21:c">portraits</option>
                <option value="ff8-18-21:d">charts</option>
                <option value="ff8-18-21:e">plans</option>
                <option value="ff8-18-21:f">plates</option>
                <option value="ff8-18-21:g">music</option>
                <option value="ff8-18-21:h">facsimiles</option>
                <option value="ff8-18-21:i">coats of arms</option>
                <option value="ff8-18-21:j">genealogical tables</option>
                <option value="ff8-18-21:k">forms</option>
                <option value="ff8-18-21:l">samples</option>
                <option value="ff8-18-21:m">sound recordings</option>
                <option value="ff8-18-21:n">transparencies</option>
                <option value="ff8-18-21:o">illuminations</option>
                <option value="ff8-18-21:y">no illustrations</option>
        </select>
        </p>
		<p>
            <label for="content">Content: </label>
            <select id="content" name="limit" class="subtype">
			<option value="" >Any</option>
            <option value="ctype:a" >bibliography</option>
            <option value="ctype:b" >catalogue</option>
            <option value="ctype:c" >index</option>
            <option value="ctype:d" >abstract</option>
            <option value="ctype:e" >dictionary</option>
            <option value="ctype:f" >encyclopaedia</option>
            <option value="ctype:g" >directory</option>
            <option value="ctype:h" >project description</option>
            <option value="ctype:i" >statistics</option>
            <option value="ctype:j" >programmed text books</option>
            <option value="ctype:k" >patent</option>
            <option value="ctype:l" >standard</option>
            <option value="ctype:m" >dissertation or thesis</option>
            <option value="ctype:n" >laws and legislation</option>
            <option value="ctype:o" >numeric table</option>
            <option value="ctype:p" >technical report</option>
            <option value="ctype:q" >examination paper</option>
            <option value="ctype:r" >literature surveys/reviews</option>
            <option value="ctype:s" >treaties</option>
            <option value="ctype:t" >cartoons or comic strips</option>
            <option value="ctype:v" >dissertation or thesis (revised)</option>
            <option value="ctype:w" >religious text</option>
            <option value="ctype:z" >other</option>
		</select>
        </p>
        <p>
            <label for="video_types">Video types: </label>
            <select id="video_types" name="limit" class="subtype">
            <option value="">Any</option>
			<option value="Video-mt:a">motion picture</option>
			<option value="Video-mt:b">visual projection</option>
			<option value="Video-mt:c">video recording</option>
		</select>
        </p>
		</fieldset>

		<fieldset>
        <legend>Serials</legend>
		<p>
            <label for="serial_type">Serial type: </label>
            <select id="serial_type" name="limit" class="subtype">
           <option value="">Any type</option>
            <option value="ff8-21:a">Periodical</option>
            <option value="ff8-21:b">Monographic series</option>
            <option value="ff8-21:c">Newspaper</option>
            <option value="ff8-21:e">Updating loose-leaf</option>
            <option value="ff8-21:f">Database</option>
            <option value="ff8-21:g">Updating website</option>
            <option value="ff8-21:z">Other</option>
		</select>
        </p>
        <p>
            <label for="periodicity">Periodicity: </label>
            <select id="periodicity" name="limit" class="subtype">
			<option value="">Any</option>
            <option value="ff8-18:a">Daily</option>
            <option value="ff8-18:b">Semiweekly</option>
            <option value="ff8-18:c">Weekly</option>
            <option value="ff8-18:d">Biweekly</option>
            <option value="ff8-18:e">Semimonthly</option>
            <option value="ff8-18:f">Monthly</option>
            <option value="ff8-18:g">Bimonthly</option>
            <option value="ff8-18:h">Quarterly</option>
            <option value="ff8-18:i">Three times a year</option>
            <option value="ff8-18:j">Semiannual</option>
            <option value="ff8-18:k">Annual</option>
            <option value="ff8-18:l">Biennial</option>
            <option value="ff8-18:m">Triennial</option>
            <option value="ff8-18:n">Three times a week</option>
            <option value="ff8-18:o">Three times a month</option>
            <option value="ff8-18:y">Without periodicity</option>
            <option value="ff8-18:u">Unknown</option>
            <option value="ff8-18:z">Other</option>
		</select>
        </p>
        <p>
            <label for="regularity">Regularity: </label>
            <select id="regularity" name="limit" class="subtype">
            <option value="">Any regularity</option>
            <option value="ff8-19:a">regular</option>
            <option value="ff8-19:b">normalised irregular</option>
            <option value="ff8-19:y">irregular</option>
            <option value="ff8-19:u">unknown</option>
		</select>
        </p>
        </fieldset>

		<fieldset>
        <legend>Picture</legend>
        <p>
		<select name="limit" class="subtype">
				<option value="">Any</option>
				<option value="Graphics-type:a">collage</option>
				<option value="Graphics-type:b">drawing</option>
				<option value="Graphics-type:c">painting</option>
				<option value="Graphics-type:d">photomechanical reproduction</option>
				<option value="Graphics-type:e">photonegative</option>
				<option value="Graphics-type:f">photoprint</option>
				<option value="Graphics-type:h">picture</option>
				<option value="Graphics-type:i">print</option>
				<option value="Graphics-type:k">technical drawing</option>
				<option value="Graphics-type:z">other non-projected graphic type</option>
		</select>
		<select name="limit" class="subtype">
            <option value="">Any</option>
            <option value="Graphics-support:a">canvas</option>
            <option value="Graphics-support:b">bristol board</option>
            <option value="Graphics-support:c">cardboard/illustration board</option>
            <option value="Graphics-support:d">glass</option>
            <option value="Graphics-support:j">plaster</option>
            <option value="Graphics-support:k">hardboard</option>
            <option value="Graphics-support:l">porcelaine</option>
            <option value="Graphics-support:m">stone</option>
            <option value="Graphics-support:n">wood</option>
            <option value="Graphics-support:v">mixed collection</option>
            <option value="Graphics-support:e">synthetics</option>
            <option value="Graphics-support:f">skin</option>
            <option value="Graphics-support:g">textile</option>
            <option value="Graphics-support:h">metal</option>
            <option value="Graphics-support:i">paper</option>
            <option value="Graphics-support:z">others</option>
            <option value="Graphics-support:u">unknown</option>
    </select>
        </p>
</fieldset>
</div>
