#!/usr/bin/perl

# Copyright 2019 KohaSuomi oy
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use C4::Languages;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};
    my %args;

    my $vocab = "slm";

    my $language = C4::Languages::getlanguage() || 'fi';
    $language = (split(/-/, $language))[0];

    my $langcode = "fin";
    $langcode = "eng" if ($language eq 'en');
    $langcode = "swe" if ($language eq 'sv');

    my $js  = <<END_OF_JS;
<script type="text/javascript">
//<![CDATA[

	 if (!window.FintoCache) window.FintoCache = [];
	 
	 function gatherdata$function_name(id, sels) {
	     if (!sels.id)
		 return;
	     var fid = \$('#'+id).parent().parent().attr('id');
	     var re = /^(tag_..._)/;
	     var found = fid.match(re);
	     var ind2 = found[1] + 'indicator2_';
	     var sfid0 = found[1] + 'subfield_0_';
	     var sfid2 = found[1] + 'subfield_2_';
	     var sf2val;
	     var sf0val;
	     if (sels.userdef) {
		 sf2val = "local";
		 sf0val = "";
	     } else {
	         if (sels.vocab) {
		     sf2val = sels.vocab + "/$langcode";
		     \$('#'+id).data('vocab', sels.vocab);
		 }
	         if (sels.uri) {
		     sf0val = sels.uri;
		     \$('#'+id).data('uri', sels.uri);
		 }
	     }
	     \$('#'+id).parent().parent().find("input[name^='"+ind2+"']").val("7");
             if (typeof sf2val !== "undefined") \$('#'+id).parent().parent().find("input[id^='"+sfid2+"']").val(sf2val);
             if (typeof sf0val !== "undefined") \$('#'+id).parent().parent().find("input[id^='"+sfid0+"']").val(sf0val);
	 }
	 
	 function Focus$function_name(elementid, force) {
	if (\$("#" + elementid).data("select2-enabled") == 1) { return; };
	\$("#" + elementid).data("select2-enabled", 1).select2({
	  width: 'resolve',
	  data: { id:"", text: "" },
	  initSelection: function(element, callback) {
	      var v = element.val();
              var duri = element.data('uri');
              var dvocab = element.data('vocab');
	      callback({ id:v, text:v, uri: duri, vocab: dvocab });
	  },
	  escapeMarkup: function(m) { return m; },
	  /*allowClear: true,*/
	  /*tags: false,*/
          /*multiple: false,*/
          /*maximumSelectionLength: 1,*/
          /*maximumSelectionSize: 1,*/
          createSearchChoice: function(term, data) { return { id: term, text: term + " <i>(local)</i>", userdef: true }; },
	  minimumInputLength: 2,
	  ajax: {
	      url:'https://api.finto.fi/rest/v1/search',
	      dataType: 'json',
	      delay: 250,
	      quietMillis: 250,
	      cache: true,
	      data: function(params) {
		    var query = {
		      vocab: '$vocab',
		      query: '*' + params + '*',
		      lang: '$language',
		      type: 'skos:Concept',
		      unique: 1,
		    }
		    return query;
	      },
	      processResults: function(data) {
		    var tmp = \$.map(data.results, function(obj){
                            var sl = obj.prefLabel;
                            if (obj.altLabel) { sl += " <i>("+obj.altLabel+")</i>" };
			    if (obj.vocab && / /.test("$vocab")) { sl += " <i>("+obj.vocab+")</i>" }
                            return { id: obj.prefLabel,
                                     text: sl,
                                     uri: obj.uri,
                                     vocab: obj.vocab }
                    });
		    return { results: tmp };
	      },
	      transport: function(params) {
		  if (params.dataType == "json") {
		      var cachekey = params.data.vocab+","+params.data.query+","+params.data.lang;
		      if (window.FintoCache && window.FintoCache[cachekey]) {
			  var res = window.FintoCache[cachekey];
			  params.success(res);
			  return {
			    abort: function() { console.log("FINTO: AJAX call aborted"); }
			  }
		      } else {
			  var \$request = \$.ajax(params);
			  \$request.then(function (data) {
			      window.FintoCache[cachekey] = data;
			      return data;
					 })
			      .then(params.success)
			      \$request.fail(params.failure);
			  return \$request;
		      }
		  } else {
		      var \$request = \$.ajax(params);
		      \$request.then(params.success);
		      \$request.fail(params.failure);
		      return \$request;
		  }
	      },
            }
           })
	   .focus()
           .on('select2-blur', function() { var sels=\$(this).select2('data'); gatherdata$function_name(\$(this).attr('id'), sels); \$(this).data("select2-enabled", 0); \$(this).off('select2-blur');  \$(this).off('select2-close');  \$(this).off('select2-select'); \$(this).off('change'); \$(this).select2('destroy'); })
           .on('select2-select', function(e) { \$(this).trigger({ type: 'select2-blur' }); })
           .on('select2-close', function() { \$(this).trigger({ type: 'select2-select' }); })
           .data('select2').open()

	 }

//]]>
</script>
END_OF_JS
    return $js;
};

return { builder => $builder };
