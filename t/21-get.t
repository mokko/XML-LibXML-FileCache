use strict;
use warnings;
use Test::More tests => 4;
use XML::LibXML;
use XML::LibXML::FileCache;
use FindBin;

my $testDir = "$FindBin::Bin/testCache";
my $testURL = 'http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd';
my $cache   = new XML::LibXML::FileCache( cacheDir => $testDir );

{
	eval { $cache->get(); };
	ok( $@, 'get fails with no argument' );
}

{
	eval { $cache->get('sds'); };
	ok( $@, 'get fails with stupid argument' );
}

#need internet to dl this file

{
	eval { $cache->get($testURL); };
	ok( !$@, 'get succeeds with good argument! ' . $@ );
}

my $dom = $cache->get($testURL);
ok( $dom, 'xml seems to exist' );

#print $dom->toString;

