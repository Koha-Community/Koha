  $(document).ready(function() {
      var path = location.pathname.substring(1);
      if (path.indexOf("labels") >= 0 && path.indexOf("spine") < 0 ) {
        $('#navmenulist a[href$="/cgi-bin/koha/labels/label-home.pl"]').css('font-weight','bold');
      } else if (path.indexOf("patroncards") >= 0 ) {
        $('#navmenulist a[href$="/cgi-bin/koha/patroncards/home.pl"]').css('font-weight','bold');
      } else if (path.indexOf("clubs") >= 0 ) {
          $('#navmenulist a[href$="/cgi-bin/koha/clubs/clubs.pl"]').css('font-weight','bold');
      } else if (path.indexOf("patron_lists") >= 0 ) {
        $('#navmenulist a[href$="/cgi-bin/koha/patron_lists/lists.pl"]').css('font-weight','bold');
      } else if (path.indexOf("rotating_collections") >= 0 ){
        $('#navmenulist a[href$="/cgi-bin/koha/rotating_collections/rotatingCollections.pl"]').css('font-weight','bold');
      } else if ((path+location.search).indexOf("batchMod.pl?del=1") >= 0 ) {
        $('#navmenulist a[href$="/cgi-bin/koha/tools/batchMod.pl?del=1"]').css('font-weight','bold');
      } else if (path.indexOf("quotes-upload.pl") >= 0 ){
        $('#navmenulist a[href$="/cgi-bin/koha/tools/quotes.pl"]').css('font-weight','bold');
      } else if (path.indexOf("plugins") >= 0 ) {
          $('#navmenulist a[href$="/cgi-bin/koha/plugins/plugins-home.pl?method=tool"]').css('font-weight','bold');
      } else {
        $('#navmenulist a[href$="/' + path + '"]').css('font-weight','bold');
      }
  });
