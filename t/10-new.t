use strict;
use warnings;
use Test::More tests => 4;
use XML::LibXML;
use FindBin;
use XML::LibXML::FileCache;

my $testDir="$FindBin::Bin/testCache";

{
	eval { new XML::LibXML::FileCache(); };
	ok( $@, 'fails without cacheDir' );
}

{
	eval { new XML::LibXML::FileCache( cacheDir => 'not/a/dir' ); };
	ok( $@, 'fails with non-existant cacheDir' );
}

#make cacheDir for testing purposes if it doesn't exist
if (! -d $testDir) {
	mkdir $testDir or die "Cant make testDir";
}

{
	eval { new XML::LibXML::FileCache( cacheDir => $testDir ); };
	ok( !$@, 'succeeds with existing cacheDir' );
}

my $cache = new XML::LibXML::FileCache( cacheDir => $testDir );
ok( ref $cache eq 'XML::LibXML::FileCache', 'package name as expected' );



