
package Text::Editor::Vip::Buffer::Plugins::Display;
use strict;
use warnings ;

BEGIN 
{
use Exporter ();

use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = 0.01;
@ISA         = qw (Exporter);
@EXPORT      = qw ();
@EXPORT_OK   = qw ();
%EXPORT_TAGS = ();
}

#------------------------------------------------------------------------------

sub SetTabSize { $_[0]->{'Text::Editor::Vip::Buffer::Display::TAB_SIZE'} = $_[1] ;}
sub GetTabSize { return ($_[0]->{'Text::Editor::Vip::Buffer::Display::TAB_SIZE'}) ;}

#-------------------------------------------------------------------------------

sub GetCharacterPositionInText
{
# given a display position, returns the the position in text

my ($this, $line_index, $position, $line_text) = @_ ;

$line_text ||= $this->GetLineText($line_index) ;

my ($character_position, $display_position) = (0, 0) ;

for (split //, $line_text)
	{
	if($_ eq "\t")
		{
		$display_position += $this->{'Text::Editor::Vip::Buffer::Display::TAB_SIZE'} ;
		}
	else
		{
		$display_position++ ;
		}
		
	last if $display_position > $position ;
	$character_position++ ;
	}

if($display_position < $position)
	{
	return(length($line_text) + ($position - $display_position)) ;
	}
else
	{
	return($character_position) ;
	}
}

#-------------------------------------------------------------------------------

sub GetCharacterDisplayPosition
{
my ($this, $line_index, $position, $line_text) = @_ ;

$line_text = $this->GetLineText($line_index) ;
substr($line_text, $position) = '' if $position < length($line_text) ;

return(($line_text =~ tr/\t/\t/ * ($this->{'Text::Editor::Vip::Buffer::Display::TAB_SIZE'} - 1)) + $position) ;
}

#-------------------------------------------------------------------------------

1 ;

=head1 NAME

Text::Editor::Vip::Buffer::Plugins::Display - Text position to display position utilities

=head1 SYNOPSIS

  use Text::Editor::Vip::Buffer::Dispaly
  
=head1 DESCRIPTION

This module let's you define a tab size and compute text to displa positions.

=head1 USAGE

=head1 BUGS

=head1 AUTHOR

	Khemir Nadim ibn Hamouda
	CPAN ID: NKH
	mailto:nadim@khemir.net
	http:// no web site

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
