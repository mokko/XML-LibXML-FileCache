use strict;
use warnings;
use Test::More tests => 2;
use XML::LibXML;
use XML::LibXML::FileCache;
use FindBin;

my $testURL = 'http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd';

my $testDir = "$FindBin::Bin/testCache";
my $cache = new XML::LibXML::FileCache( cacheDir => $testDir );

#populate cache if not yet populated. May fail if not access to inet.
$cache->get($testURL);
{
	my $dom = $cache->getFromCache($testURL);
	ok( $dom, "getFromCache returns stuff" );
}

{
	$cache->remove ($testURL);
	my $dom = $cache->getFromCache($testURL);
	ok( !$dom, "remove did remove stuff from cache" );
}


#$cache->remove('test')
