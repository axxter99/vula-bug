#! /usr/bin/perl

=begin text
CREATE TABLE `SAKAI_USER_AGENT` (
  `USER_AGENT_ID` bigint(20) NOT NULL auto_increment,
  `USER_AGENT` varchar(255) default NULL,
  `Browser` bigint(20) NOT NULL,
  `Browser_Version` bigint(20) NOT NULL,
  `OS` bigint(20) NOT NULL,
  `DEVISE` bigint(20) NOT NULL,
   PRIMARY KEY  (`USER_AGENT_ID`),
   KEY (`USER_AGENT`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `SAKAI_BROWSER` (
     `BROWSER_ID` bigint(20) NOT NULL auto_increment,
     `BROWSER` varchar(255) default NULL,
     PRIMARY KEY  (`BROWSER_ID`),
     KEY (`BROWSER`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `SAKAI_BROWSER_VERSION` (
    `BROWSER_VERSION_ID` bigint(20) NOT NULL auto_increment,
    `BROWSER_VERSION` varchar(255) default NULL,
    PRIMARY KEY  (`BROWSER_VERSION_ID`),
    KEY (`BROWSER_VERSION_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `SAKAI_OS` (
     `OS_ID` bigint(20) NOT NULL auto_increment,
     `OS` varchar(255) default NULL,
     PRIMARY KEY  (`OS_ID`),
     KEY (`OS`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO SAKAI_BROWSER (BROWSER ) VALUES ('UNAVAILABLE');
INSERT INTO SAKAI_BROWSER_VERSION (BROWSER_VERSION) VALUES ('UNAVAILABLE'); 
INSERT INTO SAKAI_OS (OS) VALUES ('UNAVAILABLE');

CREATE TABLE `SAKAI_DEVISES` (
    `DEVISES_ID` bigint(20) NOT NULL auto_increment,
    `DEVISES` varchar(255) default NULL,
     PRIMARY KEY  (`DEVISES_ID`),
     KEY (`DEVISES`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO SAKAI_DEVISES (DEVISES) VALUES ('computer');
INSERT INTO SAKAI_DEVISES (DEVISES) VALUES ('mobile');
INSERT INTO SAKAI_DEVISES (DEVISES) VALUES ('Pad');
INSERT INTO SAKAI_DEVISES (DEVISES) VALUES ('robot');

=cut

use DBI;
use strict;
use HTTP::BrowserDetect;
# 
   require "/usr/local/sakaiconfig/dbbugs.pl";
   
   (my $host, my $dbname, my $user, my $password)= getBugDbAuth ();
   
  
#getuUserAgent("Mozilla/5.0 (Linux; Android 5.0.1; GT-I9500 Build/LRX22C) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.91 Mobile Safari/537.36");
#getuUserAgent("Opera/9.80 (Series 60; Opera Mini/7.0.31380/28.3692; U; en) Presto/2.8.119 Version/11.10");
sub getuUserAgent ()
    {
    my ($user_agent_string) = @_;
    
    
    my $ua = HTTP::BrowserDetect->new($user_agent_string);
 
    
    
    my $dbh = DBI->connect("DBI:mysql:database=$dbname;host=$host;port=3306", $user, $password)
        || die "Could not connect to bug database $dbname: $DBI::errstr";
    
    
    my $us = "SELECT USER_AGENT_ID from SAKAI_USER_AGENT where USER_AGENT = '$user_agent_string'";
    my @usag = $dbh->selectrow_array($us);
    my $uadb = $usag[0];

    #Print general information
    
    #print "UA!";
    if ($uadb == '') {
        #print "UA NULL! \n\n";
        
        #print "Version: ", $ua->browser_version,$ua->browser_beta, "\n";
        print "OS: ".$ua->os_string."\n";
        my $OS_ID = getOperatingSystem($ua->os_string);
        my $BROWSER = getBrowser($ua->browser_string);
        
        my $BROWSER_VERSION = getBrowserVersion($ua->browser_version);
        
        my $DEVISE = 1;
       
        if ($ua->mobile) {
             $DEVISE =  2;
        }
        
        #print "Tablet \n" if $ua->tablet;
        if ($ua->tablet) {
          $DEVISE = 3;
        }
        
        
        if ($ua->robot) {
            $DEVISE = 4;
         } 
         
         
                
                
                
                
                
        my $uainsertsql = "INSERT INTO SAKAI_USER_AGENT (USER_AGENT, OS, BROWSER, BROWSER_VERSION, DEVISE ) VALUES (?, ?, ?, ?, ?)";
        my $sth = $dbh->prepare($uainsertsql) or die "Couldn't prepare statement: " . $dbh->errstr;
        $sth->execute($user_agent_string, $OS_ID, $BROWSER, $BROWSER_VERSION, $DEVISE);
        #print $uainsertsql."\n $user_agent_string, $OS_ID, $BROWSER, $BROWSER_VERSION, $DEVISE \n\n";
        $sth->finish;
        @usag = $dbh->selectrow_array($us);
        $uadb = $usag[0];
        
    }
    
    
    $dbh->disconnect;
    return $uadb;
}

sub getOperatingSystem () 
 {
    
    my ($OSB) = @_;
    print "getOperatingSystem ($OSB)\n";
    my $u = "UNAVAILABLE";
 
    if ($OSB eq '') {
        print "OS: null!"; 
        $OSB = $u
    }
 

 
  my $dbh = DBI->connect("DBI:mysql:database=$dbname;host=$host;port=3306", $user, $password)
        || die "Could not connect to bug database $dbname: $DBI::errstr";
  my $p = "SELECT * from SAKAI_OS where OS='$OSB'";
  my @row_ary = $dbh->selectrow_array($p);
 
  my $os_id = @row_ary[0];
  
 
  if ($os_id eq '') {
    #print "OS database $OSB \n\n";
    my $insertsql = "INSERT INTO SAKAI_OS (OS) VALUES (?)";
    my $sth = $dbh->prepare($insertsql) or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth->execute($OSB);

	$sth->finish;
    @row_ary = $dbh->selectrow_array($p);
	
  }

    
	
    $dbh->disconnect;
     return $os_id;
}

sub getBrowser () 
 {
    #print "getBROWSER ()\n";
    my ($BB) = @_;
    #print "BROWSER string: $BB \n";
 
 
 if ($BB eq '') {
    #print "BROWSER: null!"; 
    $BB =  "UNAVAILABLE";
 }
 

 
  my $dbh = DBI->connect("DBI:mysql:database=$dbname;host=$host;port=3306", $user, $password)
        || die "Could not connect to bug database $dbname: $DBI::errstr";
  my $pp = "SELECT * from SAKAI_BROWSER where BROWSER='$BB'";
  my @row_ary = $dbh->selectrow_array($pp);
  #print "BROWSER: $pp0 \n";
  my $os_id = @row_ary[0];
  #print  "BROWSER id: $os_id \n";
 
  if ($os_id eq '') {
    #print "BROWSER database $BB \n\n";
    my $insertsql = "INSERT INTO SAKAI_BROWSER (BROWSER) VALUES (?)";
    my $sth = $dbh->prepare($insertsql) or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth->execute($BB);

	$sth->finish;
    my @row_ary = $dbh->selectrow_array($pp);
	$os_id = @row_ary[0];
  }

    
	
    $dbh->disconnect;
    return $os_id;
}

sub getBrowserVersion () 
 {
 #print "getBROWSERVERSION ()\n";
 my ($BB) = @_;
 #print "BROWSER_VERSION string: $BB \n";
 
 
 if ($BB eq '') {
    #print "BROWSER_VERSION: null!"; 
    $BB =  "UNAVAILABLE";
 }
 

 
  my $dbh = DBI->connect("DBI:mysql:database=$dbname;host=$host;port=3306", $user, $password)
        || die "Could not connect to bug database $dbname: $DBI::errstr";
  my $pp = "SELECT * from SAKAI_BROWSER_VERSION where BROWSER_VERSION='$BB'";
  my @row_ary = $dbh->selectrow_array($pp);
  #print "BROWSER_VERSION: $pp0 \n";
  my $os_id = @row_ary[0];
  #print  "BROWSER_VERSION id: $os_id \n";
 
  if ($os_id eq '') {
    #print "BROWSER_VERSION database $BB \n\n";
    my $insertsql = "INSERT INTO SAKAI_BROWSER_VERSION (BROWSER_VERSION) VALUES (?)";
    my $sth = $dbh->prepare($insertsql) or die "Couldn't prepare statement: " . $dbh->errstr;
	$sth->execute($insertsql);

	$sth->finish;
    @row_ary = $dbh->selectrow_array($pp);
	$os_id = @row_ary[0];
  }

    
	
    $dbh->disconnect;
    return $os_id;
}










