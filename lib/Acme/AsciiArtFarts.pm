package Acme::AsciiArtFarts;

use warnings;
use strict;
use LWP;

=head1 NAME

Acme::AsciiArtFarts - Simple Object Interface to AsciiArtFarts

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This package provides a simple object orientated interface to AsciiArtFarts - a
website focussed on Ascii Art humour.

	use Acme::AsciiArtFarts;

	my $aaf = Acme::AsciiArtFarts->new();

	my $current = $aaf->current();
	print $current;

=head1 METHODS

=head2 new

Constructor - creates a new Acme:AsciiArtFarts object.  This method takes no arguments.

=cut

sub new {
	my $class	= shift;
	my $self	= {};
	bless $self, $class;
	$self->{ua}	= LWP::UserAgent->new();
	$self->{uri}	= 'http://www.asciiartfarts.com';
	$self->{req}	= HTTP::Request->new(GET => $self->{uri});
	$self->__get_keywords;
	return $self
}

=head2 current

	print $aaf->current();

Returns the current strip.

=cut

sub current {
	return $_[0]->__request('/today.txt')
}

=head2 random

	print $aaf->random();

Returns a random strip.

=cut

sub random {
	my $self = shift;
	return __parse($self->__request('/random.cgi'));
}

=head2 list_keywords

	print join " ", $aaf->list_keywords();

Returns a list of all keywords by which strips are sorted.

=cut

sub list_keywords {
	my $self = shift;
	return sort keys %{$self->{keywords}}
}

#sub get_by_keyword {
#	my ($self,$keyword)= @_;
	#exists %{$self->{keywords}} or return 0;
	
#}

sub __get_keywords {
	my $self= shift;
	my $itr	= 0;
	my @html= split /\n/, $self->__request('/keyword.html');

	for ($itr=0;$itr<@html;$itr++) {
		$_ = $html[$itr];
		next unless /^<li><a name="keyword/;
		my($key,$page,$count) = /^<li.*?:(.*?)".*ref="(.*)".*a> \((.*)\)/;
		$self->{keywords}{$key}{count}	= $count;
		$self->{keywords}{$key}{page}	= $page;
		
		while ($itr++) {
			$_	= $html[$itr];
			next if /^<ul>/;
			last if /^<\/ul>/;
			last if $itr > 1_000_000;
			#print "DEBUG: _ is $_\n";
			my($num,$page,$name,$date) = /^<li>(.*?):.*ref="(.*?)">(.*?)<.*l>(.*)</;
			$self->{keywords}{$key}{$num}{name}	= $name; #print "DEBUG: Added key $key->$num->name = $name\n";
			$self->{keywords}{$key}{$num}{page}	= $page; #print "DEBUG: Added key $key->$num->page = $page\n";
			$self->{keywords}{$key}{$num}{date}	= $date; #print "DEBUG: Added key $key->$num->date = $date\n";
		}
	}
}

sub __request {
	my($self,$rl)	= @_;
	$rl 		|= '';
	my $res		= $self->{ua}->get($self->{uri}.$rl);
	$res->is_success and return $res->content;
	$self->{error}	= 'Unable to retrieve content: ' . $res->status_line;
	return 0
}

sub __parse {
	my @html	= split /\n/, $_[0];
	my $found	= 0;
	my $res;

	foreach (@html) {
		next unless /^<table cell.*pre>/ or $found;
		$found	= 1;
		next if /^<table cell/;
		return $res if /^<\/pre>/ and $found;
		$res	.= "$_\n";
	}
}

=head1 AUTHOR

Luke Poskitt, C<< <ltp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-acme-asciiartfarts at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Acme-AsciiArtFarts>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Acme::AsciiArtFarts


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Acme-AsciiArtFarts>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Acme-AsciiArtFarts>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Acme-AsciiArtFarts>

=item * Search CPAN

L<http://search.cpan.org/dist/Acme-AsciiArtFarts/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Luke Poskitt.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;
