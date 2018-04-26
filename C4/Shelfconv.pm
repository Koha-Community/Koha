package C4::Shelfconv;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(finnajson);


#################################################
# pick shelves data from array-reference and make json string (finna format)
sub  finnajson {
  my @args=@_;
  my $biblios_ref=$args[0];
  my $shelfname=$args[1];
  my $json_string="{\n \"lists\":[{\n\"description\": null,\n\"public\": 0,\n\"records\":[\n";
  my $i=0;
  my $count=scalar @$biblios_ref;
     while($i < $count)
     {
       if($i >0)
       {
         $json_string.=",";
       }
       
       $json_string.="{\n\"id\":\"outi.".$biblios_ref->[$i]."\",\n";
       $json_string.="\"notes\":null,\n\"order\":null,\n\"source\":\"Solr\",\n\"tags\":[]\n}";
       $i++;
     }
     $json_string.="\n],\n\"title\":\"".$shelfname."\"\n\}\n],\"searches\":[]\n}";
     return($json_string);
} 
1;
