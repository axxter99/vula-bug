#! /usr/bin/perl

my $path = "/home2/dhorwitz/git/vula-bug/scripts/bug";
do "/home2/dhorwitz/git/vula-bug/scripts/sakaibrowser.pl";

$file=$path;
open(INFO, $file) or die("Could not open  file.");

$count = 0; 
foreach $line (<INFO>)  {   
    print $line;
    getuUserAgent($line);
    print " ====\n";
    if ($++counter == 2){
      last;
    }
}
close(INFO);
