package XML::LibXML::FileCache;
# ABSTRACT: A simple file cache for LibXML (CHI-based)
use strict;
use warnings;
use Moose;
use CHI;
use XML::LibXML;
use Digest::MD5 qw(md5_hex);


=head1 DESCRIPTION

A simple file cache for LibXML documents based on CHI for small web documents. 
Cache is populated when document is first accessed (get) or everytime when 
document is accessed (getFallback).

=func my $cache=new My::FileCache(cacheDir=>'path/to/dir');

Options
cacheDir (required): directory in which cached files are stored
 	cacheDir is not created automatically. Make sure that dir exists!

expire (optional): TODO
	not yet implemented
	expire can be empty, integer (seconds) and 'never'.

=cut


has cacheDir => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
);

has expire => (
	is  => 'ro',
	isa => 'Str',
);

sub BUILD {
	my $self = shift;

	if ( !-d $self->{cacheDir} ) {
		die "Error: CacheDir not a dir ($self->{cacheDir})";
	}

	$self->{cache} = CHI->new(
		driver   => 'File',
		root_dir => $self->{cacheDir},
	);
}

=func my $dom=get ('http://URL.com');

Try cache first. If it fails, try live (web). If all fails, return undef. 

=cut

sub get {
	my $self = shift;
	my $url  = shift or die "Need url!";
	my $key  = $self->_mkKey($url);
	my $dom;

	#first check if in cache
	my $item = $self->_getFromCache($key);

	if ($item) {

		#print "key found\n";
		$dom = XML::LibXML->load_xml( string => $item );
	}
	else {

		#print "key NOT found\n";
		$dom = $self->_fetch($url);
		$self->_saveInCache( $key, $dom->toString );
	}

	return $dom;
}

=func my $file=getFromCache ($url);

Get a file from the cache or return nothing.

=cut

sub getFromCache {
	my $self = shift;
	my $url  = shift or die "Need url!";
	my $key  = $self->_mkKey($url);
	my $dom;

	#first check if in cache
	my $item = $self->_getFromCache($key);

	if ($item) {

		#print "key found\n";
		$dom = XML::LibXML->load_xml( string => $item );
	}
	return $dom;

}

=func  $cache->remove ([$url]);
	
	TODO: should remove complete cache if no argument given.
	Return value 1 for successful removal 0 for no removal.

=cut

sub remove {
	my $self = shift;
	my $url  = shift;

	if ($url) {
		my $key = $self->_mkKey($url);
		$self->{cache}->remove($key);
	}
	else {
		$self->_removeAll;
	}


}

=func my $dom=$cache->getFallback ('http://URL.com');

Check live for url first on the web. If document not live, take it from cache. Return undef if all
fails.

UNTESTED.

=cut

sub getFallback {
	my $self = shift;
	my $url  = shift or die "Need url!";
	my $key  = $self->_mkKey($url);

	#first check if live
	my $dom = $self->_fetch($url);
	$self->_saveInCache( $key, $dom->toString );

	#if not live, get from cache
	if ( !$dom ) {
		print "......................\n";
		my $file = $self->_getFromCache($key) or return;
		print "......................file:$file\n";

		$dom = XML::LibXML->load_xml( string => $file );
	}

	return $dom;
}

#
# internal
#

sub _fetch {
	my $self = shift;
	my $url = shift or die "Need url!";

	#use libXML to fetch document
	my $dom = XML::LibXML->load_xml( location => $url );
	if ( !$dom ) { print "Error: Coulnd't load $url"; }
	return $dom;
}

sub _getFromCache {

	#returns undef on failure
	my $self = shift;
	my $key = shift or die "Need key!";
	return $self->{cache}->get($key);
}

sub _mkKey {
	my $self=shift;
	my $in = shift or die "Need something to work with";
	return md5_hex($in);
}

sub _saveInCache {
	my $self = shift;
	my $key  = shift or die "Error: No key!";
	my $str  = shift or die "Error: No string!";
	$self->{cache}->set( $key, $str, 'never' ) or die "Can't save in Cache!";
}

=head1 DEVELOPMENT
L<https://github.com/mokko/XML-LibXML-FileCache>

=head1 BACKGROUND

Sometimes on my development system, I don't have access to the internet, so I 
can't validate against xsd files on the web. Annoying! So I invented this 
little cache. 

=head1 SEE ALSO

L<XML::LibXML::Cache>
L<CHI>

=head1 TODO

=for :list
* write more tests
* check if $url is in fact a valid URI

=cut

__PACKAGE__->meta->make_immutable;

1;