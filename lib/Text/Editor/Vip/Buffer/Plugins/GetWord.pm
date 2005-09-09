
package Text::Editor::Vip::Buffer::Plugins::GetWord ;

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

#-------------------------------------------------------------------------------

sub GetAlphanumericFilter
{
my $buffer = shift ;

return
	(
	   $buffer->{'Text::Editor::Vip::Buffer::Plugins::GetWord::ALPHANUMERIC_FILTER'}
	|| qr![a-zA-Z_0-9]+!
	) ;
}

#-------------------------------------------------------------------------------

sub SetAlphanumericFilter
{
my $buffer = shift ;
$buffer->{'Text::Editor::Vip::Buffer::Plugins::GetWord::ALPHANUMERIC_FILTER'} = shift ;
}

#-------------------------------------------------------------------------------

sub GetFirstWord
{
my $buffer = shift ;
my $line_index = shift ;

$line_index = $buffer->GetModificationLine() unless defined $line_index ;

my $current_line_text = $buffer->GetLineText($line_index) ;
my $character_regex   = $buffer->GetAlphanumericFilter() ;
my ($first_word) = $current_line_text =~ /\W*($character_regex)/ ;

return($first_word) ;
}

#-------------------------------------------------------------------------------

sub GetPreviousWord
{
my $buffer = shift ;

my $text = $buffer->GetLineText($buffer->GetModificationLine()) ; 

#what if current character is outside the text length?
#~ my $corrected_selection_start_character = $selection_start_character < $line_length ? $selection_start_character : $line_length ;

my $current_character_index = $buffer->GetModificationCharacter() ;
my $character_regex         = $buffer->GetAlphanumericFilter() ;

my $left_side  = reverse substr($text, 0, $current_character_index) ;

my ($previous_word) = $left_side =~ /\W*($character_regex)/ ;
$previous_word = reverse $previous_word if $previous_word ;

return($previous_word) ;
}

#-------------------------------------------------------------------------------

sub GetCurrentWord
{
my $buffer = shift ;

my $modification_character = $buffer->GetModificationCharacter() ;

my $current_line_text = $buffer->GetLineText($buffer->GetModificationLine()) ;
my $current_line_length = length($current_line_text) ;

return if $modification_character > $current_line_length ;

my $character_regex = $buffer->GetAlphanumericFilter() ;
my $current_character = substr($current_line_text, $modification_character, 1) ;

my $current_word ;
my $cursor_is_at_the_end_of_the_word = 1 ;

if($current_character =~ /$character_regex/)
	{
	$current_word = $current_character ;
	
	for(my $character_index = $modification_character - 1 ; $character_index >= 0 ; $character_index--)
		{
		$current_character = substr($current_line_text, $character_index, 1) ;
		
		if($current_character =~ /$character_regex/)
			{
			$current_word = $current_character . $current_word ;
			}
		else
			{
			# not character
			last ;
			}
		}
		
	for(my $character_index = $modification_character + 1 ; $character_index < $current_line_length ; $character_index++)
		{
		$current_character = substr($current_line_text, $character_index, 1) ;
		
		if($current_character =~ /$character_regex/)
			{
			$current_word .= $current_character ;
			$cursor_is_at_the_end_of_the_word = 0 ;
			}
		else
			{
			# not character
			last ;
			}
		}
	}
#else
	# not on a character
	
return($current_word) ;
}

#-------------------------------------------------------------------------------

sub GetPreviousAlphanumeric
{
my $buffer = shift ;

# Get all string contents from 0  to the cursor position and flip it round
my $line = reverse substr
			(
			$buffer->GetLineText($buffer->GetModificationLine())
			, 0
			, $buffer->GetModificationCharacter()
			) ;
			
my $alphanumeric_filter = $buffer->GetAlphanumericFilter() ;
my ($prefix) = $line =~ /($alphanumeric_filter)/ ;

# !! reverse of undef is defined.
if(defined $prefix)
	{
	return(reverse $prefix) ;
	}
else
	{
	return(undef) ;
	}
}

#-------------------------------------------------------------------------------

sub GetNextAlphanumeric
{
my $buffer = shift ;

my $modification_character = $buffer->GetModificationCharacter() ;

my $current_line_text = $buffer->GetLineText($buffer->GetModificationLine()) ;
my $current_line_length = length($current_line_text) ;

return if $modification_character > $current_line_length ;

my $line = substr
		(
		$buffer->GetLineText($buffer->GetModificationLine())
		, $buffer->GetModificationCharacter()
		) ;
		
my $alphanumeric_filter = $buffer->GetAlphanumericFilter() ;
my ($postfix) = $line =~ /($alphanumeric_filter)/ ;

return($postfix) ;
}

#-------------------------------------------------------------------------------

1 ;

=head1 NAME

Text::Editor::Vip::Buffer::Plugins::GetWord- Vip::Buffer pluggin

=head1 SYNOPSIS
 
  
=head1 DESCRIPTION

plugin for Vip::Buffer

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
