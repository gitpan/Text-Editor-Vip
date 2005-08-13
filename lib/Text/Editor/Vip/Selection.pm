
package Text::Editor::Vip::Selection;
use strict;
use warnings ;

BEGIN 
{
use Exporter ();
use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = 0.01_1;
@ISA         = qw (Exporter);
@EXPORT      = qw ();
@EXPORT_OK   = qw ();
%EXPORT_TAGS = ();
}

#-------------------------------------------------------------------------------

sub new
{
my $invocant = shift ;
my $class = ref($invocant) || $invocant ;

my $object_reference = bless {}, $class ;
$object_reference->Setup(@_) ;

return($object_reference) ;
}

#-------------------------------------------------------------------------------

sub Setup
{
my $this = shift ;

%$this = 
	(
	START_LINE       => -1
	, START_CHARATER => -1
	, END_LINE       => -1
	, END_CHARATER   => -1
	, IS_COLUMN_TYPE => 0
	, @_
	) ;
}

#-------------------------------------------------------------------------------

use Clone ;

sub Clone
{
my $this = shift ;

return(Clone::clone($this)) ;
}

#-------------------------------------------------------------------------------

sub IsEmpty
{
my $this = shift ;
if
	(
	$this->{START_LINE} == $this->{END_LINE}
	&& $this->{START_CHARATER} == $this->{END_CHARATER}
	)
	{
	return(1) ;
	}
else
	{
	return(0) ;
	}
}

#-------------------------------------------------------------------------------

sub Clear
{
my $this = shift ;
$this->Setup() ;
}

#-------------------------------------------------------------------------------

sub SetAnchor($$) # Expects line and character
{
my $this = shift ;
$this->Setup() ;

$this->{START_LINE}     = shift ;
$this->{START_CHARATER} = shift ;
}

#-------------------------------------------------------------------------------

sub SetLine($$) # Expects line and character
{
my $this      = shift ;

$this->{END_LINE}     = shift ;
$this->{END_CHARATER} = shift ;
}

#-------------------------------------------------------------------------------

sub IsOfColumnType()
{
my $this = shift ;
return($this->{IS_COLUMN_TYPE}) ;
}

#-------------------------------------------------------------------------------

sub SetTypeToColumn
{
my $this = shift ;
$this->{IS_COLUMN_TYPE} = shift ;
}

#-------------------------------------------------------------------------------

sub GetBoundaries
{
my $this = shift ;
if($this->{START_LINE} < $this->{END_LINE})
	{
	return
		(
		$this->{START_LINE}, $this->{START_CHARATER}
		, $this->{END_LINE}, $this->{END_CHARATER}
		) ;
	}
else
	{
	if($this->{START_LINE} == $this->{END_LINE})
		{
		if($this->{START_CHARATER} < $this->{END_CHARATER})
			{
			return
				(
				$this->{START_LINE}, $this->{START_CHARATER}
				, $this->{END_LINE}, $this->{END_CHARATER}
				) ;
			}
		else
			{
			return
				(
				$this->{START_LINE}, $this->{END_CHARATER}
				, $this->{END_LINE}, $this->{START_CHARATER}
				) ;
			}
		}
	else
		{
		return
			(
			$this->{END_LINE}, $this->{END_CHARATER}
			, $this->{START_LINE}, $this->{START_CHARATER}
			) ;
		}
	}
}

#-------------------------------------------------------------------------------

sub GetLineBoundaries
{
my $this = shift ;
my $a_line_index = shift ;

my ($start_line, $start_character, $end_line, $end_character) = $this->GetSelectionBoundaries() ;
my ($line_selection_start, $line_selection_end) ;

if($start_line <= $a_line_index && $a_line_index <= $end_line)
	{
	if($this->{IS_COLUMN_TYPE})
		{
		$line_selection_start = $start_character ;
		$line_selection_end   = $end_character ;
		}
	else
		{
		$line_selection_start = 0 ;
		
		$line_selection_start = $start_character if $a_line_index == $start_line ;
		$line_selection_end   = $end_character if $a_line_index == $end_line ;
		}
	}
   
#else
	# boundaries set to undef
	   
return($line_selection_start, $line_selection_end) ;
}

#-------------------------------------------------------------------------------

sub GetStartLine
{
my $this = shift ;
return(($this->GetSelectionBoundaries())[0]) ;
}

#-------------------------------------------------------------------------------

sub GetStartCharacter
{
my $this = shift ;
return(($this->GetSelectionBoundaries())[1]) ;
}

#-------------------------------------------------------------------------------

sub GetEndLine
{
my $this = shift ;
return(($this->GetSelectionBoundaries())[2]) ;
}

#-------------------------------------------------------------------------------

sub GetEndCharacter
{
my $this = shift ;
return(($this->GetSelectionBoundaries())[3]) ;
}

#-------------------------------------------------------------------------------

sub IsCharacterSelected($$) # Expects a line and a character index
{
my $this              = shift ;
my $a_line_index      = shift ;
my $a_character_index = shift ;

my ($start_line, $start_character, $end_line, $end_character) = $this->GetSelectionBoundaries() ;
return
	(
	$start_line <= $a_line_index && $a_line_index <= $end_line
	&& $start_character <= $a_character_index && $a_character_index <= $end_character
	) ;
}

#-------------------------------------------------------------------------------

sub IsLineSelected($)
{
my $this         = shift ;
my $a_line_index = shift ;

my ($start_line, undef, $end_line) = $this->GetSelectionBoundaries() ;
return($start_line <= $a_line_index && $a_line_index <= $end_line) ;
}

#-------------------------------------------------------------------------------

1 ;


=head1 NAME

Text::Editor::Vip::Selection - Selection Range

=head1 SYNOPSIS

  use Text::Editor::Vip::Selection

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

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
