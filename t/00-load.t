#!perl -T

use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
    use_ok( 'XML::LibXML::FileCache' ) || print "Bail out!
";
}

diag( "Testing XML::LibXML::FileCache $XML::LibXML::FileCache::VERSION, Perl $], $^X" );
