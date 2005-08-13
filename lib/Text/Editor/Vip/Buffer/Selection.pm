
package Text::Editor::Vip::Buffer::Selection;

use strict;
use warnings ;
use Carp qw(cluck) ;

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

sub GetSelection
{

=head2 GetSelection

Returns the selection object used by the buffer.

=cut

my $this = shift ;
return($this->{SELECTION}) ;
}

#-------------------------------------------------------------------------------

sub SetSelection
{

=head2 SetSelection

Sets the selection object passed as argument to use by the buffer

=cut

my $this = shift ;
my $new_selection = shift or die ;

$this->{SELECTION} = $new_selection ;
}

#-------------------------------------------------------------------------------

sub DeleteSelection
{

=head2 DeleteSelection

Removes the text within the selection, if any,  from the buffer. Sets the modification position to the start of the selection

=cut

my $this = shift ;

my $undo_block = new Text::Editor::Vip::CommandBlock($this, 'DeleteSelection($buffer) ;', '   #', '# undo for DeleteSeletion()', '   ') ;

unless($this->{SELECTION}->IsEmpty())
	{
	my ($start_line, $start_character) = $this->{SELECTION}->GetBoundaries() ;
	
	$this->RunSubOnSelection
				(
				  sub { return(undef) ; }
				, sub { $this->PrintError("Mark selection please\n") ; }
				) ;
				
	$this->SetModificationLine($start_line) ;
	$this->SetModificationCharacter($start_character) ;
	
	$this->{SELECTION}->Clear() ;
	}
}

#-------------------------------------------------------------------------------

sub RunSubOnSelection
{

=head2 RunSubOnSelection

Runs a user supplied sub on the selection. The sub is called for each line in the selection.
It can return a string or undef if the section is to be removed.

=cut

my $this = shift ;
my ($function, $error_sub_ref) = @_ ;

unless($this->{SELECTION}->IsEmpty())
	{
	my 
		(
		  $selection_start_line, $selection_start_character
		, $selection_end_line, $selection_end_character
		) = $this->{SELECTION}->GetBoundaries() ;
		
	my $original_selection = $this->{SELECTION}->Clone() ;
	
	$this->{SELECTION}->Clear() ; # we use buffer functionw that might call this sub otherwise

	my $current_line     = $this->GetModificationLine() ;
	my $current_position = $this->GetModificationCharacter() ;
	
	my $removing_end_of_first_line = 0 ;
	my $number_of_lines_in_selection = $selection_end_line - $selection_start_line ;

	my @lines_to_delete ;
	my $wrap_first_line = -1 ; # we need two confimations to wrap the first line

	for
		(
		my $selection_line_index = $selection_start_line 
		; $selection_line_index <= $selection_end_line 
		; $selection_line_index++
		)
		{
		# we remove the text and replace it with the text returned by the user sub
		my $text = $this->GetLineText($selection_line_index) ;
		my $modification_character ;
		my $whole_line_selected = 0 ;
		
		if($selection_line_index == $selection_start_line && $selection_start_line == $selection_end_line)        
			{
			$text = substr($text, $selection_start_character, $selection_end_character - $selection_start_character) ;
			$modification_character = $selection_start_character ;
			
			$whole_line_selected++ if length($text) == $this->GetLineLength($selection_line_index) ;
			}
		elsif($selection_line_index == $selection_start_line)
			{
			$text = substr($text, $selection_start_character) ;
			$modification_character = $selection_start_character ;
			$wrap_first_line++ ;
			}
		elsif($selection_line_index == $selection_end_line)
			{
			$text = substr($text, 0, $selection_end_character)  ;
			$modification_character = 0 ;
			}
		else
			{
			$modification_character = 0 ;
			$whole_line_selected++ ;
			}
			
		# the sub has access to the line before we modify it
		my $new_text = $function->($text, $selection_line_index, $modification_character, $original_selection, $this) ;
		
		$this->SetModificationPosition($selection_line_index, $modification_character) ;
		$this->Delete(length($text)) ;
		
		if(defined $new_text)
			{
			$this->Insert($new_text) ;
			}
		else
			{
			# deleted lines are not taken away before all lines are processed
			push @lines_to_delete, $selection_line_index if($whole_line_selected) ;
			
			if($selection_line_index == $selection_start_line)
				{
				$wrap_first_line++ ;
				}
			}
		}
		
	$this->DeleteLine($_) for (reverse @lines_to_delete) ;
	
	if($wrap_first_line)
		{
		$this->SetModificationPosition($selection_start_line, $selection_start_character) ;
		$this->Delete(1) ;
		}
	}
else
	{
	$error_sub_ref->("No Selection!") ;
	}
}

#-------------------------------------------------------------------------------

1;

=head1 NAME

Text::Editor::Vip::Buffer::Selection - Selection handling for buffer

=head1 SYNOPSIS

  use Text::Editor::Vip::Buffer::Selection
  

=head1 DESCRIPTION

Plugin for Vip::Buffer. It handles Selection.

=head1 USAGE

=head1 BUGS

=head1 SUPPORT

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
