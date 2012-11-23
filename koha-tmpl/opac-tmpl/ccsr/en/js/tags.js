if (typeof KOHA == "undefined" || !KOHA) {
    var KOHA = {};
}

/**
* A namespace for Tags related functions.
* readCookie is expected to already be declared.  That's why the assignment below is unscoped.
* readCookie should be from basket.js or undefined.

$.ajaxSetup({
       url: "/cgi-bin/koha/opac-tags.pl",
     type: "POST",
  dataType: "script"
});
*/
if (typeof(readCookie) == "undefined") {
     readCookie = function (name) { // from http://www.quirksmode.org/js/cookies.html
               var nameEQ = name + "=";
               var ca = document.cookie.split(';');
           for (var i=0;i < ca.length;i++) {
                      var c = ca[i];
                 while (c.charAt(0)==' '){ c = c.substring(1,c.length); }
                       if (c.indexOf(nameEQ) == 0){ return c.substring(nameEQ.length,c.length); }
             }
              return null;
   }
}
KOHA.Tags = {
      add_tag_button: function(bibnum, tag){
          var mynewtag = "newtag" + bibnum;
            var mytagid = "#" + mynewtag;
          var mydata = {CGISESSID: readCookie('CGISESSID')};	// Someday this should be OPACSESSID
                mydata[mynewtag] = tag;	// need [bracket] for variable property id
                var response;	// AJAX from server will assign value to response.
               $.post(
                        "/cgi-bin/koha/opac-tags.pl",
                  mydata,
                        function(data){
                                // alert("AJAX Response: " + data);
                            eval(data);
                            // alert("counts: " + response["added"] + response["deleted"] + response["errors"]);
                           KOHA.Tags.set_tag_status(
                                      mytagid + "_status",
                                   KOHA.Tags.common_status(response["added"], response["deleted"], response["errors"])
                            );
                             if (response.alerts) {
                                 alert(response.alerts.join("\n\n"));
                           }
                      },
                     'script'
               );
             return false;
  },
     common_status : function(addcount, delcount, errcount) {
           var cstat = "";
        if (addcount && addcount > 0) {cstat += MSG_TAGS_ADDED + addcount + ".  " ;}
           if (delcount && delcount > 0) {cstat += MSG_TAGS_DELETED + delcount + ".  " ;}
         if (errcount && errcount > 0) {cstat += MSG_TAGS_ERRORS + errcount + ". " ;}
           return cstat;
      },
     set_tag_status : function(tagid, newstatus) {
          $(tagid).html(newstatus);
              $(tagid).show();
      },
     append_tag_status : function(tagid, newstatus) {
               $(tagid).append(newstatus);
            $(tagid).show();
      },
     clear_all_tag_status : function() {
          $(".tagstatus").empty().hide();
      },

    tag_message: {
 tagsdisabled : function(arg) {return (MSG_TAGS_DISABLED);},
    scrubbed_all_bad : function(arg) {return (MSG_TAG_ALL_BAD);},
  badparam : function(arg) {return (MSG_ILLEGAL_PARAMETER+" "+arg);},
    scrubbed : function(arg) {return (MSG_TAG_SCRUBBED+" "+arg);},
    failed_add_tag : function(arg) {return (MSG_ADD_TAG_FAILED+ " '"+arg+"'. \n"+MSG_ADD_TAG_FAILED_NOTE);},
    failed_delete  : function(arg) {return (MSG_DELETE_TAG_FAILED+ " '"+arg+"'. \n"+MSG_DELETE_TAG_FAILED_NOTE);},
   login : function(arg) {return (MSG_LOGIN_REQUIRED);}
   },

    // Used to tag multiple items at once.  The main difference
    // is that status is displayed on a per item basis.
    add_multitags_button : function(bibarray, tag){
                var mydata = {CGISESSID: readCookie('CGISESSID')};	// Someday this should be OPACSESSID
        for (var i = 0; i < bibarray.length; i++) {
            var mynewtag = "newtag" + bibarray[i];
            mydata[mynewtag] = tag;
        }
           var response;	// AJAX from server will assign value to response.
               $.post(
                        "/cgi-bin/koha/opac-tags.pl",
                  mydata,
                        function(data){
                                eval(data);
                KOHA.Tags.clear_all_tag_status();
                var bibErrors = false;

                // Display the status for each tagged bib
                for (var i = 0; i < bibarray.length; i++) {
                    var bib = bibarray[i];
                    var mytagid = "#newtag" + bib;
                    var status = "";

                    // Number of tags added.
                    if (response[bib]) {
                        var added = response[bib]["added"];
                        if (added > 0) {
                            status = MSG_TAGS_ADDED + added + ".  ";
				        KOHA.Tags.set_tag_status(mytagid + "_status", status);
                        }

                        // Show a link that opens an error dialog, if necessary.
                        var errors = response[bib]["errors"];
                        if (errors.length > 0) {
                            bibErrors = true;
                            var errid = "tagerr_" + bib;
                            var errstat = "<a id=\"" + errid + "\" class=\"tagerror\" href=\"#\">";
                            errstat += MSG_TAGS_ERRORS + errors.length + ". ";
                            errstat += "</a>";
					    KOHA.Tags.append_tag_status(mytagid + "_status", errstat);
                            var errmsg = "";
                            for (var e = 0; e < errors.length; e++){
                                if (e) {
                                    errmsg += "\n\n";
                                }
                                errmsg += errors[e];
                            }
                            $("#" + errid).click(function(){
                                alert(errmsg);
                            });
                        }
                    }
                }

                if (bibErrors || response["global_errors"]) {
                    var msg = "";
                    if (bibErrors) {
                        msg = MSG_MULTI_ADD_TAG_FAILED;
                    }

                    // Show global errors in a dialog.
                    if (response["global_errors"]) {
                        var global_errors = response["global_errors"];
                        var msg;
                        for (var e = 0; e < global_errors.length; e++) {
                            msg += "\n\n";
                            msg += response.alerts[global_errors[e]];
                        }
                    }
                    alert(msg);
                }
                     },
                     'script'
               );
             return false;
    }
};
