
package Text::Editor::Vip::Buffer::Plugins::FindReplace ;

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

use constant CASE_SENSITIVE => 0 ;
use constant IGNORE_CASE    => 1 ;

#-------------------------------------------------------------------------------

sub FindOccurence
{

=head2 FindOccurence

#* Find doesn't set selection anymore, add example somewhere
	#~ $buffer->SetModificationPosition($match_line, $match_position + length($match_word)) ;
	#~ $buffer->{SELECTION}->Set($match_line, $match_position,$match_line, $match_position + length($match_word)) ;
=cut

my $buffer       = shift ;
my $search_regex = shift ;

my $line_index   = shift ;
$line_index = $buffer->GetModificationLine() unless defined $line_index ;

# weird return to make comparison function on the calling side happy
return(undef, undef, undef) if($line_index > ($buffer->GetNumberOfLines() - 1)) ;

my $character_index = shift ;
$character_index = $buffer->GetModificationCharacter() unless defined $character_index ;

my $line_length = $buffer->GetLineLength($line_index) ;
$character_index = $character_index > $line_length ? $line_length : $character_index ;

my ($match_line, $match_position, $match_word) ;

my $start_line_index = $line_index ;

if(defined $search_regex && '' ne $search_regex)
	{
	$buffer->{'Text::Editor::Vip::Buffer::Plugins::FindReplace::SEARCH_REGEX'} = $search_regex ;

	my $text = substr($buffer->GetLineText($line_index), $character_index) ;
	if($text =~ /($search_regex)/)
		{
		$match_line     = $line_index ;
		$match_position = index($text, $1) + $character_index ;
		$match_word     = $1 ;
		}
	else
		{
		my $number_of_lines_in_document = $buffer->GetNumberOfLines() ;
		
		for(my $current_line_index = $line_index + 1 ; $current_line_index < $number_of_lines_in_document; $current_line_index++)
			{
			$text = $buffer->GetLineText($current_line_index) ;
			
			if($text =~ /($search_regex)/)
				{
				$match_line     = $current_line_index ;
				$match_position = index($text, $1) ;
				$match_word     = $1 ;
				last ;
				}
			}
		}
	}
	
return($match_line, $match_position, $match_word) ;
}

#-------------------------------------------------------------------------------

sub FindNextOccurence
{

=head2

=cut

my $buffer = shift ;
my $line_index = $buffer->GetModificationLine();

# weird return to make comparison function on the calling side happy
return(undef, undef, undef) if($line_index > ($buffer->GetNumberOfLines() - 1)) ;

my $character_index = $buffer->GetModificationCharacter() ;

$buffer->FindOccurence
	(
	  $buffer->{'Text::Editor::Vip::Buffer::Plugins::FindReplace::SEARCH_REGEX'}
	, $line_index
	, $character_index + 1
	) ;
}

#-------------------------------------------------------------------------------

sub FindNextOccurenceForCurrentWord
{

=head2

=cut

my $buffer = shift ;
$buffer->ExpandedWithOrLoad('GetCurrentWord', 'Text::Editor::Vip::Buffer::Plugins::GetWord') ;

$buffer->{'Text::Editor::Vip::Buffer::Plugins::FindReplace::SEARCH_REGEX'} = $buffer->GetCurrentWord() ;

$buffer->FindNextOccurence() ;
}

#-------------------------------------------------------------------------------

sub FindOccurenceBackwards
{

=head2

=cut

my $buffer       = shift ;
my $search_regex = shift ;

my $line_index   = shift ;
$line_index = $buffer->GetModificationLine() unless defined $line_index ;

# allow search backwards from after the buffer
if($line_index > ($buffer->GetNumberOfLines() - 1))
	{
	$line_index = $buffer->GetNumberOfLines() - 1 ;
	}

my $character_index = shift ;
$character_index = $buffer->GetModificationCharacter() unless defined $character_index ;

my $line_length = $buffer->GetLineLength($line_index) ;
$character_index = $character_index > $line_length ? $line_length : $character_index ;

my($match_line, $match_position, $match_word) ;
my $start_line_index = $line_index ;

if(defined $search_regex && '' ne $search_regex)
	{
	$buffer->{'Text::Editor::Vip::Buffer::Plugins::FindReplace::SEARCH_REGEX'} = $search_regex ;
	
	my ($extended_pattern) = $search_regex =~ /^(\(\?[^)]*\))/ ;
	$extended_pattern ||= '' ;
	
	$search_regex =~ s/^(\(\?[^)]*\))// ;
	
	$search_regex = $extended_pattern . reverse $search_regex ;
	
	my $text = reverse substr($buffer->GetLineText($line_index), 0, $character_index) ;
	
	if($text =~ /($search_regex)/)
		{
		$match_line     = $line_index ;
		$match_position = $character_index - (length($1) +index($text, $1)) ;
		$match_word     = reverse($1) ;
		}
	else
		{
		for(my $current_line_index = $line_index - 1 ; $current_line_index >= 0; $current_line_index--)
			{
			$text = reverse $buffer->GetLineText($current_line_index) ;
			
			if($text =~ /($search_regex)/)
				{
				$match_line     = $current_line_index ;
				$match_position = length($text) - (length($1) + index($text, $1)) ;
				$match_word     = reverse($1) ;
				last ;
				}
			}
		}
	}

return($match_line, $match_position, $match_word) ;
}

#-------------------------------------------------------------------------------

sub FindPreviousOccurence
{

=head2

=cut

my $buffer = shift ;

my $line_index = $buffer->GetModificationLine();
my $character_index = $buffer->GetModificationCharacter() ;

$buffer->FindOccurenceBackwards
	(
	  $buffer->{'Text::Editor::Vip::Buffer::Plugins::FindReplace::SEARCH_REGEX'}
	, $line_index
	, $character_index - 1
	) ;
}

#-------------------------------------------------------------------------------

sub FindPreviousOccurenceForCurrentWord
{

=head2

=cut

my $buffer = shift ;

$buffer->ExpandedWithOrLoad('GetCurrentWord', 'Text::Editor::Vip::Buffer::Plugins::GetWord') ;

$buffer->{'Text::Editor::Vip::Buffer::Plugins::FindReplace::SEARCH_REGEX'} = $buffer->GetCurrentWord() ;
$buffer->FindOccurenceBackwards($buffer->{'Text::Editor::Vip::Buffer::Plugins::FindReplace::SEARCH_REGEX'}) ;
}

#-------------------------------------------------------------------------------

sub ReplaceOccurence
{

=head2

=cut

my $buffer            = shift ;
my $search_regex      = shift ;
my $replacement_regex = shift ;

my ($match_line, $match_position, $match_word) ;
my $replaced_by ;

if(defined $search_regex && '' ne $search_regex && defined $replacement_regex)
	{
	$buffer->{'Text::Editor::Vip::Buffer::Plugins::FindReplace::SEARCH_REPLACE_REGEX'} = $search_regex ;
	$buffer->{REPLACEMENT_REGEX} = $replacement_regex ;
	
	($match_line, $match_position, $match_word) = $buffer->FindOccurence($search_regex) ;
	
	if(defined $match_line)
		{
		$buffer->SetModificationPosition($match_line, $match_position + length($match_word)) ;
		$buffer->SetSelectionBoundaries($match_line, $match_position, $match_line, $match_position + length($match_word)) ;
		$buffer->Delete() ;
		
		$replaced_by = $match_word ;
		eval "#line " . __LINE__ . "'" . __FILE__ . "'\n\$replaced_by =~ s/$search_regex/$replacement_regex/ ;" ;
		
		$buffer->Insert($replaced_by) ;
		}
	}

return($match_line, $match_position, $match_word, $replaced_by) ;
}

#-------------------------------------------------------------------------------

1 ;

=head1 NAME

Text::Editor::Vip::Buffer::Plugins::FindReplace- Find and replace functionality plugin for Vip::Buffer

=head1 SYNOPSIS

  is_deeply([$buffer->FindOccurence('1', 0, 0)], [0, 5, '1'], 'Found occurence 1') ;
  is($buffer->GetText(), $text, 'Text still the same') ;
  is($buffer->GetSelectionText(), '', 'GetSelectionText empty') ;
  
  #FindNextOccurence
  $buffer->SetModificationPosition(0, 0) ;
  is_deeply([$buffer->FindNextOccurence()], [0, 5, '1'], 'FindNextOccurence') ;
  
  $buffer->SetModificationPosition(0, 5) ;
  is_deeply([$buffer->FindNextOccurence()], [0, 9, '1'], 'FindNextOccurence') ;
  
  # FindNextOccurenceForCurrentWord
  $buffer->SetModificationPosition(0, 0) ;
  is_deeply([$buffer->FindNextOccurenceForCurrentWord()], [1, 0, 'line'], 'FindNextOccurenceForCurrentWord') ;
  
  $buffer->SetModificationPosition(1, 0) ;
  is_deeply([$buffer->FindNextOccurenceForCurrentWord()], [2, 0, 'line'], 'FindNextOccurenceForCurrentWord') ;
  
  $buffer->SetModificationPosition(4, 0) ;
  
  is_deeply([$buffer->FindNextOccurenceForCurrentWord()], [undef, undef, undef], 'FindNextOccurenceForCurrentWord') ;
  
  # Regex search
  is_deeply([$buffer->FindOccurence(qr/..n[a-z]/, 0, 0)], [0, 0, 'line'], 'Found occurence with regex') ;

=head1 DESCRIPTION

Find and replace functionality plugin for Vip::Buffer

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
