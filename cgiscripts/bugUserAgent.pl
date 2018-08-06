#!/usr/bin/perl -wT

use strict;
use CGI qw/escapeHTML unescapeHTML/;
use DBI;

require '/usr/local/sakaiconfig/vula_bugs_auth.pl';

my $service = "Vula";
my $service_prefix = "https://vula.uct.ac.za";
my $css = "$service_prefix/library/content/uct/css/bugs.css";

# select USER_AGENT_ID, COUNT(*)  from SAKAI_BUGS where year(BUG_DATE)="2018" GROUP BY USER_AGENT_ID ORDER BY COUNT(*) DESC LIMIT 0,10;
#my $YEAR = "2018";
my $q = new CGI; 
my $YEAR = $q->param('year');
if ($YEAR eq "" ) {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                localtime();
    $year = $year+1900;
    $YEAR = $year;
}
my $NYEAR = $YEAR - 1;
my $PYEAR = $YEAR + 1;

(my $dbname, my $dbhost, my $username, my $password) = getBugsDbConfig();
my $dbh = DBI->connect("DBI:mysql:database=$dbname;host=$dbhost;port=3306", $username, $password)
        || die "Could not connect to database: $DBI::errstr";
        
my $OS_SQL = "Select  SAKAI_OS.OS as os, COUNT(*) as count
from SAKAI_BUGS
JOIN SAKAI_USER_AGENT ON SAKAI_BUGS.USER_AGENT_ID=SAKAI_USER_AGENT.USER_AGENT_ID
JOIN SAKAI_OS ON SAKAI_USER_AGENT.OS=SAKAI_OS.OS_ID
where year(BUG_DATE)=\"$YEAR\"
GROUP BY SAKAI_OS.OS ORDER BY COUNT(*) DESC";
my $sth = $dbh->prepare($OS_SQL);
$sth->execute();

my $OS_HTML = "";
while (my @row_ary = $sth->fetchrow_array) {
    my $OSString = $row_ary[0];
    my $OSCount = $row_ary[1];
    $OS_HTML = $OS_HTML."<tr><td>$OSString</td><td>$OSCount</td></tr>\n";
    
}
#print $OS_HTML;
my $DV_SQL ="Select  SAKAI_DEVISES.DEVISES, COUNT(*)
from SAKAI_BUGS
JOIN SAKAI_USER_AGENT ON SAKAI_BUGS.USER_AGENT_ID=SAKAI_USER_AGENT.USER_AGENT_ID
JOIN SAKAI_DEVISES ON SAKAI_USER_AGENT.DEVISE= SAKAI_DEVISES.DEVISES_ID
where year(BUG_DATE)=\"$YEAR\"
GROUP BY SAKAI_USER_AGENT.DEVISE ORDER BY COUNT(*) DESC";
$sth = $dbh->prepare($DV_SQL);
$sth->execute();

my $DEVISES_HTML = "";
while (my @row_ary = $sth->fetchrow_array) {
    my $DEVISESString = $row_ary[0];
    my $DEVISESCount = $row_ary[1];
    $DEVISES_HTML = $DEVISES_HTML."<tr><td>$DEVISESString</td><td>$DEVISESCount</td></tr>\n";
    
}

my $BR_SQL = "Select SAKAI_BROWSER.BROWSER, COUNT(*)
from SAKAI_BUGS
JOIN SAKAI_USER_AGENT ON SAKAI_BUGS.USER_AGENT_ID=SAKAI_USER_AGENT.USER_AGENT_ID
JOIN SAKAI_BROWSER ON SAKAI_USER_AGENT.Browser=SAKAI_BROWSER.BROWSER_ID
where year(BUG_DATE)=\"$YEAR\"
GROUP BY SAKAI_BROWSER.BROWSER ORDER BY COUNT(*) DESC";
$sth = $dbh->prepare($BR_SQL);
$sth->execute();

my $BROWSER_HTML = "";
while (my @row_ary = $sth->fetchrow_array) {
    my $BROWSERString = $row_ary[0];
    my $BROWSERCount = $row_ary[1];
    $BROWSER_HTML = $BROWSER_HTML."<tr><td>$BROWSERString</td><td>$BROWSERCount</td></tr>\n";
    
}


$dbh->disconnect;
                       # create new CGI object

print $q->header();

print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "https://www.w3.org/TR/html4/loose.dtd">
<html>
<HEAD>
<TITLE>$service Bug Details: User Agent $YEAR</TITLE>
<link rel="stylesheet" type="text/css" href="$css" />
</HEAD>
<body style="padding:0.3em;">
<h2>User Agent $YEAR</h2>
<table border="0" cellpadding="5" cellspacing="1" >
<tbody valign="top">
<tr><td><a href="bugUserAgent.pl?year=$NYEAR">$NYEAR</a></td><td><a href="bugUserAgent.pl?year=$PYEAR">$PYEAR</a></td></tr>
<tr><td>
<table>
<tr><th>OS</th><th>Count</th></tr>
$OS_HTML
</table>
</td><td>

<table border="0" cellpadding="0" cellspacing="1">
<tbody>
<tr><th>Devises</th><th>Count</th></tr>
$DEVISES_HTML
</tbody>
</table>
</td></tr>
<tr><td>

<table>
<tr><th>BROWSER</th><th>Count</th></tr>
$BROWSER_HTML
</table>
</td></tr>
</tbody>
</table>
</body>
</html>
HTML
