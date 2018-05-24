package Koha::MongoDB::LogJson;

use MongoDB;
use Koha::MongoDB::Config;
use Koha::MongoDB::Users;
use Koha::MongoDB::Logs;
#use Data::Dumper;
use Try::Tiny;
#@ISA = qw(Exporter);
#@EXPORT = qw(logs_borrower);

########################################
# returns log markings about one borrower, json format
sub logs_borrower
{
   my @args=@_;
   my $borrowernumber=$args[1];
   my $config = new Koha::MongoDB::Config;
   my $logs = new Koha::MongoDB::Logs;
   my $jsonstring="";
   my $count=0;

   try
   {
     my $client = $config->mongoClient();
     my $settings=$config->getSettings();
     my $user_logs=$client->ns($settings->{database}.'.user_logs');
     my $resultset=$user_logs->find({"objectborrowernumber" => $borrowernumber});
     $jsonstring="{\n\"log marks\":[";
     while(my $row = $resultset->next)
     {
       if($count > 0)
       {
          $jsonstring.="\n,\n";
       }
       $jsonstring.="{\n";
       $jsonstring.="\"sourceuser\":\"".$row->{sourceuser}."\",\n";
       $jsonstring.="\"cardnumber\":\"".$row->{objectcardnumber}."\",\n";
       $jsonstring.="\"action\":\"".$row->{action}."\",\n";
       $jsonstring.="\"info\":\"".$row->{info}."\",\n";
       $jsonstring.="\"timestamp\":\"".$row->{timestamp}."\"\n";
       $jsonstring.="}";
       $count++; 
     }
     $jsonstring.="\n]\n}";
   }
   catch
   {
     $jsonstring="";
   };
  
   return($jsonstring);
}

1;
