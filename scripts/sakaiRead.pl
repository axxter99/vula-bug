#! /usr/bin/perlm

##ALTER TABLE SAKAI_BUGS add USER_AGENT_ID long;

use DBI;

require "/usr/local/sakaiconfig/dbbugs.pl";
do "./sakaibrowser.pl";
   
   (my $host, my $dbname, my $user, my $password)= getBugDbAuth ();
   #where USER_AGENT <> NULL
   my $USER_AGENT = "select USER_AGENT from SAKAI_BUGS  GROUP BY USER_AGENT;";
   
   my $dbh = DBI->connect("DBI:mysql:database=$dbname;host=$host;port=3306", $user, $password)
        || die "Could not connect to bug database $dbname: $DBI::errstr";


        #@data = $dbh->selectrow_array($USER_AGENT);
        
        $sth = $dbh->prepare($USER_AGENT) || die "Cannot prepare: " . $dbh->errstr();
        #
        $sth->execute() or die "Cannot execute: " . $sth->errstr();
        

        
        
        # for ($i = 0; $sth->fetch; $i++) {
        $ocurrences = 0;
        print "\n @data \n\n";
        
        while(my @row = $sth->fetchrow_array()){
           #printf("%s\t%s\n",$row[0],$row[1],$row[3]);
            print $row[0];
            print "\n";
            $id = getuUserAgent($row[0]);
            print("\n row: $id \n");
            
            #UPDATE  SAKAI_BUGS set USER_AGENT_ID =1436 WHERE USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:49.0) Gecko/20100101 Firefox/49.0";
            my $insertsql = "UPDATE  SAKAI_BUGS set USER_AGENT_ID = ? WHERE USER_AGENT=?";
            my $sth = $dbh->prepare($insertsql) or die "Couldn't prepare statement: " . $dbh->errstr;
            $sth->execute($id, $row[0]);
        }  
        #for ($i = 0; @data; $i++) {
        


        
        $sth->finish();
        $dbh->disconnect;
