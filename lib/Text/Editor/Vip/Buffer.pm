
package Text::Editor::Vip::Buffer;

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

use Carp qw(carp confess cluck);
use List::Util qw(min) ;

use Text::Editor::Vip::Buffer::List ;
use Text::Editor::Vip::Buffer::Constants ;
use Text::Editor::Vip::Selection ;
use Text::Editor::Vip::CommandBlock ;

#-------------------------------------------------------------------------------

=head1 MEMBER FUNCTIONS
 

=cut

sub new
{

=head2 new

Create a Text::Editor::Vip::Buffer .  

  my $buffer = new Text::Editor::Vip::Buffer() ;

=cut

my $invocant = shift ;

my $class = ref($invocant) || $invocant ;
my $this = {} ;

my ($package, $file_name, $line) = caller() ;
$file_name =~ s/[^0-9a-zA-Z_]/_/g ;

# push this object in a 'unique' class
$class .= "::${file_name}_$line" ;
my $this_package = __PACKAGE__ ;
eval "push \@${class}::ISA, '$this_package' ;" ;

my $buffer= bless $this, $class ;

$buffer->Setup(@_) ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::DoUndoRedo') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Selection') ;

return($buffer) ;
}

#-------------------------------------------------------------------------------

sub Setup
{
my $this = shift ;

%$this = 
	(
	  NODES                        => new Text::Editor::Vip::Buffer::List()
	, MARKED_AS_EDITED             => 0
	
	, DO_PREFIX                    => ''
	, DO_STACK                     => []
	, UNDO_PREFIX                  => ''
	, UNDO_STACK                   => []
	
	, MODIFICATION_LINE            => 0
	, MODIFICATION_CHARACTER       => 0
	, SELECTION                    => new Text::Editor::Vip::Selection()
	, @_
	) ;


$this->{NODES}->Push({TEXT => ''}) ;
}

#-------------------------------------------------------------------------------

=head2 Reset

Empties the buffer from it's contents as if it was newly created. L<Plugins> are still plugged into the buffer.

  $buffer->Reset() ;

=cut

*Reset = \&Setup ;

#-------------------------------------------------------------------------------

sub LoadAndExpandWith
{

=head2 LoadAndExpandWith

Loads a perl module (plugin) and adds all it functionality to the buffer

  $buffer->LoadAndExpandWith('Text::Editor::Vip::Plugins::File') ;
  
  # we can now read files
  $buffer->InsertFile(__FILE__) ;

=cut

# look at Export::Cluster, Export::Dispatch

my $this =  shift ;
my $module = shift ;

eval "use $module ;" ;
die __PACKAGE__ . " couldn't load '$module':\n$@" if $@ ;

my $this_package = ref($this) ;
eval "push \@${this_package}::ISA, '$module' ;" ;

# expands the current's package ISA not the objects isa
#~ push @ISA, $module ;

#~ my $class = ref($this) ;

#~ my $symbole_tabel = "main::${module}::" ;

#~ no strict ;
#~ if($symbole_tabel->{EXTEND_VIP_BUFFER})
	#~ {
	#~ for(sort  @{*{$symbole_tabel->{EXTEND_VIP_BUFFER}}{ARRAY}})
		#~ {
		#~ if(*{$symbole_tabel->{$_}}{CODE})
			#~ {
			#~ print "code => $_\n" ;
			#~ $this->ExpandWith($_, *{$symbole_tabel->{$_}}{CODE})
			#~ }
		#~ }
	#~ }
}

#-------------------------------------------------------------------------------

sub ExpandWith
{

=head2 ExpandWith

Adds a member function to the buffer. 

  $buffer->ExpandWith
		(
		  'GotoBufferStart' # member function name
		, \&some_sub    # implementaton for GotoBufferStart
		) ;
  
  # we can now go  to the buffers start
  $buffer->GotoBufferStart() ;

The second argument is optional, if it is not given, Text::Editor::Vip::Buffer will take the sub from the caller namespace

  sub GotoBufferStart
  {
  my $buffer = shift ; # remember we are a plugin to an object oriented module
  $buffer->SetModificationPosition,(0, 0) ;
  }
  
  $buffer->ExpandWith( 'GotoBufferStart') ;
  $buffer->GotoBufferStart() ;

=cut

my $this =  shift ;
my $sub_name = shift ;
my $sub = shift ;

my $class = ref($this) ;

my $warning = '' ;
local $SIG{'__WARN__'} = sub {$warning = $_[0] ;} ;

if($sub)
	{
	eval "*${class}::${sub_name} = \$sub;" ;
	}
else
	{
	# load the named sub from the caller package
	
	my ($package, $file_name, $line) = caller() ;
	$package ||= '' ;
	
	eval "*${class}::${sub_name} = \\\&$package\::${sub_name};" ;
	}
}

#-------------------------------------------------------------------------------

sub Do
{

=head2 Do

Let you run any perl code on the buffer. The variable $buffer is made available in your perl code.

  ($result, $message) = $buffer->Do("# comment\n\$buffer->Insert('bar') ;") ;
  is($buffer->GetText(), "bar", 'buffer contains \'bar\'' ) ;

Returns (1) on success and (0, "error message") on failure.

=cut

my $this = shift ;
my $perl_script = shift || '' ;

our $buffer = $this ;
eval $perl_script ;

if($@)
	{
	$this->PrintError("\n* Failed evaluating buffer command *\n$perl_script\n$@\n") ;
	return(0, $@) ;
	}
else
	{
	return(1) ;
	}
}

#-------------------------------------------------------------------------------

sub PrintError
{
my $this = shift ;
my $message = shift ;

die "\n\n !! Using default PrintError wich simply dies !!\n\n"  . $message ;
}

#-------------------------------------------------------------------------------

sub GetText
{

=head2 GetText

Returns the buffer contents joined with "\n".

See L<GetTextAsArrayRef>.

=cut

my $this = shift ;

my $text = '' ;

for(0 .. ($this->GetNumberOfLines() - 2))
	{
	$text .= $this->GetLine($_)->{TEXT} . "\n" ;
	}

$text .= $this->GetLine(($this->GetNumberOfLines() - 1))->{TEXT} ;

return($text) ;
}

#-------------------------------------------------------------------------------

sub GetTextAsArrayRef
{

=head2 GetTextAsArrayRef

Returns a copy of the buffers content as an array reference.

See L<GetText>.

=cut

my $this = shift ;

my @text ;

for(0 .. ($this->GetNumberOfLines() - 1))
	{
	push @text, $this->GetLine($_)->{TEXT} ;
	}

return(\@text) ;
}

#-------------------------------------------------------------------------------

=head2 MarkedBufferAsEdited

Used to mak the buffer as edited after a modification. You should not need to use this function 
if you access the buffer through it's interface. Which you should always do.

=head2 MarkedBufferAsUndited

Used to mak the buffer as unedited You should not need to use this function.

=head2 IsBufferMarkedAsEdited

Used to query the buffer about its state. Returns (1) if the buffer was edit. (0) otherwise.

=cut

sub IsBufferMarkedAsEdited {return($_[0]->{MARKED_AS_EDITED}) ;}
sub MarkBufferAsEdited { $_[0]->{MARKED_AS_EDITED} = 1 ;}
sub MarkBufferAsUnedited {$_[0]->{MARKED_AS_EDITED} = 0 ;}

#-------------------------------------------------------------------------------

sub GetNumberOfLines
{

=head2 GetNumberOfLines

Returns the number of lines in the buffer.

=cut

return($_[0]->{NODES}->GetNumberOfNodes()) ;
}

#------------------------------------------------------------------------------

sub GetModificationPosition
{

=head2 GetModificationPosition

Returns the position, line and character, where the next modification will occure.

=cut

return($_[0]->{MODIFICATION_LINE}, $_[0]->{MODIFICATION_CHARACTER}) ;
}

#-------------------------------------------------------------------------------

sub SetModificationPosition
{

=head2 SetModificationPosition

Sets the position, line and character, where the next modification will occure.

   $buffer->SetModificationPosition(0, 15) ;

=cut

my ($this, $line, $character) = @_ ;

my $undo_block = new Text::Editor::Vip::CommandBlock($this, "\$buffer->SetModificationPosition($line, $character) ;", '   #', "# undo for \$buffer->SetModificationPosition($line, $character) ;", '   ') ;

$this->SetModificationLine($line) ;
$this->SetModificationCharacter($character) ;
}

#-------------------------------------------------------------------------------

sub GetModificationLine
{

=head2 GetModificationLine

Returns the line where the next modification will occure.

=cut
return($_[0]->{MODIFICATION_LINE}) ;
}

#-------------------------------------------------------------------------------

sub SetModificationLine
{

=head2 SetModificationLine

Set the line where the next modification will occure.

=cut
my $this = shift ;
my $a_new_modification_line = shift ;

my $current_line = $this->GetModificationLine() ;

if
	(
	$a_new_modification_line < $this->GetNumberOfLines()
	&& 0 <= $a_new_modification_line
	)
	{
	if($a_new_modification_line != $current_line)
		{
		PushUndoStep
			(
			$this
			, "\$buffer->SetModificationLine($a_new_modification_line) ;"
			, "\$buffer->SetModificationLine($current_line) ;"
			) ;
			
		$this->{MODIFICATION_LINE} = $a_new_modification_line ;
		}
	}
else
	{
	$this->PrintError("Invalid line index: $a_new_modification_line. Number of lines: " . $this->GetNumberOfLines(). "\n") ;
	}
}

#-------------------------------------------------------------------------------

sub GetModificationCharacter
{

=head2 GetModificationLine

Returns the character where the next modification will occure.

=cut

my $this = shift ;
return($this->{MODIFICATION_CHARACTER}) ;
}

#-------------------------------------------------------------------------------

sub SetModificationCharacter
{

=head2 GetModificationLine

Sets the character where the next modification will occure.

=cut

my $this = shift ;
my $a_new_modification_character = shift ;

my $current_character = $this->GetModificationCharacter() ;

if(0 <= $a_new_modification_character)
	{
	if($a_new_modification_character != $current_character)
		{
		PushUndoStep
			(
			$this
			, "\$buffer->SetModificationCharacter($a_new_modification_character) ;"
			, "\$buffer->SetModificationCharacter($current_character) ;"
			) ;
			
		$this->{MODIFICATION_CHARACTER} = $a_new_modification_character ;
		}
	}
else
	{
	$this->PrintError("Invalid character index: $a_new_modification_character\n") ;
	}
}

#-------------------------------------------------------------------------------

sub GetLine
{
my $this         = shift ;
my $a_line_index = shift ;

return($this->{NODES}->GetNodeData($a_line_index)) ;
}

#-------------------------------------------------------------------------------

sub GetLineText
{

=head2 GetLineText

Returns the text of the line passes as argument or the current modification line if no argument is passed.

  my $line_12_text = $buffer->GetLineText(12) ;
  my $current_line_text = $buffer->GetLineText() ;

=cut

my $this = shift ;
my $a_line_index = shift ;

$a_line_index = $this->GetModificationLine() unless defined $a_line_index ;

if(0 <= $a_line_index && $a_line_index < $this->GetNumberOfLines())
	{
	return($this->GetLine($a_line_index)->{TEXT}) ;
	}
else
	{
	$this->PrintError("GetLineText: Invalid line index: $a_line_index. Number of lines: " . $this->GetNumberOfLines(). "\n") ;
	return('') ;
	}
}

#-------------------------------------------------------------------------------

sub GetLineLength
{

=head2 GetLineLength

Returns the length of the text of the line passes as argument or the current modification line if no argument is passed.

  my $line_12_text = $buffer->GetLineText(12) ;
  my $current_line_text = $buffer->GetLineText() ;

=cut

my $this = shift ;
my $a_line_index = shift ;

$a_line_index = $this->GetModificationLine() unless defined $a_line_index ;

return(length($this->GetLineText($a_line_index))) ;
}

#-------------------------------------------------------------------------------

sub Backspace
{

=head2 Backspace

Deletes characters backwards. The number of characters to delete is passed as an argument.
Doing a Backspace while at the begining of a line warps to the previous line.

=cut

my $this = shift ;
my $number_of_character_to_delete = shift || 0 ;

return if 0 >= $number_of_character_to_delete  ;

my $undo_block = new Text::Editor::Vip::CommandBlock($this, "\$buffer->Backspace($number_of_character_to_delete) ;", '   #', "# undo for \$buffer->Backspace($number_of_character_to_delete)", '   ') ;

if($this->{SELECTION}->IsEmpty())
	{
	for (1 .. $number_of_character_to_delete)
		{
		
		my $current_line     = $this->GetModificationLine() ;
		my $current_position = $this->GetModificationCharacter() ;

		if($current_position != 0)
			{
			$this->SetModificationCharacter($current_position - 1) ;
		
			if($current_position <= $this->GetLineLength($current_line))
				{
				$this->Delete(1) ;
				}
			#else
				#after end of line, already modified position
			}
		else
			{
			if($current_line != 0)
				{
				$this->SetModificationLine($current_line -1) ;
				
				#Move to end of line
				$this->SetModificationCharacter
					(
					$this->GetLineLength
						(
						$this->GetModificationLine()
						)
					) ;
					
				$this->Delete(1) ;
				}
			#else
				# at first line
			}
		}
	}
else
	{
	$this->DeleteSelection() ;
	$this->Backspace($number_of_character_to_delete - 1) ;
	}
}

#-------------------------------------------------------------------------------

sub ClearLine
{

=head2 ClearLine

Removes all text from  the passed line index or the current modification line if no argument is given.
The line itself is not deleted and the modification position is not modified.

  $buffer->ClearLine(0) ;

=cut

my $this = shift ;
my $line_index = shift ;

$line_index = $this->GetModificationLine() unless defined $line_index ;

my $modification_line = $this->GetModificationLine() ;
my $modification_character = $this->GetModificationCharacter() ;

if(0 <= $line_index && $line_index < $this->GetNumberOfLines())
	{
	my $line = $this->GetLine($line_index) ;
	my $text = $line->{TEXT} ;
	$line->{TEXT} = '' ;
	
	$this->MarkBufferAsEdited() ;
	
	PushUndoStep
		(
		$this
		, "\$buffer->ClearLine($line_index) ;"
		, [
		    "\$buffer->SetModificationPosition($line_index, 0) ;" 
		  , '$buffer->Insert("' . Stringify($text) .'") ;' 
		  , "\$buffer->SetModificationPosition($modification_line, $modification_character) ;" 
		  ]
		
		) ;
	}
else
	{
	$this->PrintError("GetLineText: Invalid line index: $line_index. Number of lines: " . $this->GetNumberOfLines(). "\n") ;
	}
}

#-------------------------------------------------------------------------------

sub Delete
{

=head2 Delete

Deleted, from the modification position, the number of characters passed as argument.

=cut

my $this = shift ;
my $a_number_of_character_to_delete = shift ;

return if 0 >= $a_number_of_character_to_delete ;

my $undo_block = new Text::Editor::Vip::CommandBlock($this, "\$buffer->Delete($a_number_of_character_to_delete) ;", '   #', "# undo for \$buffer->Delete($a_number_of_character_to_delete)", '   ') ;

unless($this->{SELECTION}->IsEmpty())
	{
	$this->DeleteSelection() ;
	$a_number_of_character_to_delete-- ;
	}

my ($modification_line, $modification_character) = $this->GetModificationPosition() ;
my $line_length = $this->GetLineLength() ;

if($modification_character < $line_length)
	{
	my $line_ref = \($this->GetLine($modification_line)->{TEXT}) ;
	
	my $character_to_delete_on_this_line = min
						(
						  $line_length - $modification_character
						, $a_number_of_character_to_delete
						) ;
	my $deleted_text = substr
		(
		  $$line_ref
		, $modification_character
		, $character_to_delete_on_this_line
		, ''
		) ;
		
	PushUndoStep
		(
		  $this
		, "# deleting in current line"
		, [
		    '$buffer->Insert("' . Stringify($deleted_text) . '") ;'
		  , "\$buffer->SetModificationPosition($modification_line, $modification_character) ;"
		  ]
		) ;
		
	$a_number_of_character_to_delete -= $character_to_delete_on_this_line ;
	}
else
	{
	# at end of line, copy next line to this line
	
	return if $modification_line == ($this->GetNumberOfLines() - 1) ;
	
	$this->Insert($this->GetLine($modification_line + 1)->{TEXT}) ;
	$this->DeleteLine($modification_line + 1) ;
	$this->SetModificationPosition($modification_line, $modification_character) ;
	
	$a_number_of_character_to_delete-- ; # delete '\n'
	}
	
if($a_number_of_character_to_delete)
	{
	$this->Delete($a_number_of_character_to_delete) ;
	}

$this->MarkBufferAsEdited() ;
}

#-------------------------------------------------------------------------------

sub DeleteLine
{

=head2 DeleteLine

Deleted, the line passed as argument. if no argument is passed, the current line is deleted.
The selection and modification position are not modified.

=cut

my $this                   = shift ;
my $a_line_to_delete_index = shift ;

$a_line_to_delete_index = $this->GetModificationLine() unless defined $a_line_to_delete_index ;

return if $this->GetNumberOfLines() == 1 ; # buffer always has at least one line

my ($modification_line, $modification_character) = $this->GetModificationPosition() ;

my $text = Stringify($this->GetLineText($a_line_to_delete_index)) ;

my $undo_block = new Text::Editor::Vip::CommandBlock($this, "# DeleteLine", '    ', '# undo for DeleteLine', '   ') ;

if($a_line_to_delete_index != ($this->GetNumberOfLines() - 1))
	{
	PushUndoStep
		(
		  $this
		, "\$buffer->DeleteLine($a_line_to_delete_index) ;"
		, [
		    "\$buffer->SetModificationPosition($a_line_to_delete_index, 0) ;"
		  , "\$buffer->Insert(\"$text\\n\") ;"
		  , "\$buffer->SetModificationPosition($modification_line, $modification_character) ;"
		  ]
		) ;
	}
else
	{
	#deleting last line 
	my $previous_line = $a_line_to_delete_index - 1 ;
	my $end_of_previous_line = $this->GetLineLength($previous_line) ;
	
	PushUndoStep
		(
		  $this
		, "\$buffer->DeleteLine($a_line_to_delete_index) ;"
		, [
		    "\$buffer->SetModificationPosition($previous_line, $end_of_previous_line) ;"
		  , "\$buffer->Insert(\"\\n$text\") ;"
		  , "\$buffer->SetModificationPosition($modification_line, $modification_character) ;"
		  ]
		) ;
	}
	
$this->{NODES}->DeleteNode($a_line_to_delete_index) if $this->GetNumberOfLines() > 1 ;
$this->MarkBufferAsEdited() ;
}

#-------------------------------------------------------------------------------

sub InsertNewLine
{

=head2 InsertNewLine

Inserts a new line at the modification position. If the modification position is after the end of the 
current line, spaces are used to pad the current line.

InsertNewLine takes one parameter that can be set to  SMART_INDENTATION or NO_SMART_INDENTATION.
If SMART_INDENTATION is used (default) , B<IndentNewLine> is called. B<IndentNewLine> does nothing by default.
This lets you define your own indentation strategy. See  B<IndentNewLine>.

  $buffer->Insert("hi\nThere\nWhats\nYour\nName\n") ;

=cut

my $this                  = shift ;
my $use_smart_indentation = shift || SMART_INDENTATION ;

my $undo_block = new Text::Editor::Vip::CommandBlock($this, "InsertNewLine(\$buffer, $use_smart_indentation) ;", '   #', '# undo for InsertNewLine($use_smart_indentation)', '   ') ;

my ($modification_line, $modification_character) = $this->GetModificationPosition() ;

my $this_line = $this->GetLine($modification_line) ;
my $this_line_text = $this_line->{TEXT} ;

my $next_line_text = '' ;

if($modification_character < length $this_line_text)
	{
	$next_line_text = substr($this_line_text, $modification_character) ;
	}

$this_line_text = substr($this_line_text, 0, $modification_character) ;
								
$this_line->{TEXT} = $this_line_text ;
$this->{NODES}->InsertAfter($modification_line,  {TEXT => $next_line_text} ) ;

$this->SetModificationPosition($modification_line + 1, 0) ;

PushUndoStep
	(
	$this
	, "\$buffer->InsertNewLine($use_smart_indentation) ;"
	, '$buffer->Backspace(1) ;'	
	) ;

$this->IndentNewLine($modification_line + 1) if $use_smart_indentation ;

$this->MarkBufferAsEdited() ;
}

#-------------------------------------------------------------------------------

sub IndentNewLine
{

=head2 IndentNewLine

If Insert or InsertNewLine is called with a SMART_INDENTATION argument,
B<IndentNewLine> is called. This lets you define your own indentation strategy.

  sub my_indenter
  {
  # modification position is set at the new line 
  
  my $this = shift ; # the buffer
  my $line_index = shift ; # usefull if we indent depending on previous lines
  
  $this->Insert('   ') ;  # silly indentation
  $this->MarkBufferAsEdited() ;
  }

  $buffer->ExpandWith('IndentNewLine', \&my_indenter) ;
  $buffer->Insert("hi\nThere\nWhats\nYour\nName\n") ;
  
  is($buffer->GetLineText(1), "   There", "Same text") ;

=cut

my $this = shift ;
my $line_index = shift ;

my $undo_block = new Text::Editor::Vip::CommandBlock($this, "\$buffer->IndentNewLine($line_index) ;", '   #', '# undo for \$buffer->IndentNewLine() ;', '   ') ;
}

#-------------------------------------------------------------------------------

sub Stringify
{
# quotes a string or an array of string so it can be used as perl code

my $text_to_stringify = shift ;
$text_to_stringify = '' unless defined $text_to_stringify ;

my $stringified_text = '' ;

my @text_to_stringify = ref($text_to_stringify) eq 'ARRAY' ? @$text_to_stringify: ($text_to_stringify) ;

for(@text_to_stringify)
	{
	s/\\/\\\\/g ;
	
	s/\$/\\\$/g ;
	s/\@/\\\@/g ;
	s/"/\\"/g ;
	
	s/\n/\\n/g ;
	s/\t/\\t/g ;
	s/\r/\\r/g ;

	$stringified_text .= $_ ;
	}
	
return($stringified_text) ;
}

#-------------------------------------------------------------------------------

sub Insert
{

=head2 Insert

Inserts a string or a list of strings, passed as an array reference, into the buffer.

  $buffer->Insert("bar") ;
  
  my @text = ("Someone\n", "wants me\nNow") ;
  $buffer->Insert(\@text);
  
  $buffer->Insert("\t something \n new") ;

Only "\n" is considered special and forces the addition of a new line in the buffer.

B<Insert> takes a second argument . When set to SMART_INDENTATION (the default), 
B<IndentNewLine> is called to indent the newly inserted line. The default B<IndentNewLine>
does nothing but you can override it to implement any indentation you please. If you want to 
insert raw text, pass NO_SMART_INDENTATION as a second argument.

NO_SMART_INDENTATION is defined in Text::Editor::Vip::Buffer::Constants.

=cut

my $this                  = shift ;
my $text_to_insert        = shift ;
my $use_smart_indentation = shift || SMART_INDENTATION ;

my @text_to_insert ;

if(ref($text_to_insert) eq 'ARRAY')
	{
	@text_to_insert = @$text_to_insert ;
	}
else
	{
	@text_to_insert = ($text_to_insert) ;
	}

my $stringified_text_to_insert = Stringify($text_to_insert);

my $undo_block = new Text::Editor::Vip::CommandBlock
			(
			$this
			, "\$buffer->Insert(\"$stringified_text_to_insert\", $use_smart_indentation) ;", '   #'
			, "# undo for \$buffer->Insert(\"$stringified_text_to_insert\", $use_smart_indentation)", '   '
			) ;

$this->DeleteSelection() ;

for(@text_to_insert)
	{
	for(split /(\n)/) # transform a\nb\nccc into 3 lines
		{
		if("\n" eq $_)
			{
			$this->InsertNewLine($use_smart_indentation) ;
			}
		else
			{
			my $line_ref = \($this->GetLine($this->GetModificationLine())->{TEXT}) ;
			my $modification_character = $this->GetModificationCharacter() ;
			my $line_length = length($$line_ref) ;
			
			#padding
			if($modification_character - $line_length)
				{
				$this->SetModificationCharacter($line_length) ;
				$this->Insert(' ' x ($modification_character - $line_length)) ;
				}
				
			# insert characters
			substr($$line_ref, $modification_character, 0, $_) ;
				
			my $text_to_insert_length = length($_) ;
			$stringified_text_to_insert = Stringify($_);
			
			PushUndoStep
				(
				$this
				, "\$buffer->Insert(\"$stringified_text_to_insert\", $use_smart_indentation) ;"
				, "\$buffer->Delete($text_to_insert_length) ;"
				) ;
				
			$this->SetModificationCharacter($modification_character + length()) ;
			}
		}
		
	$this->MarkBufferAsEdited() ;
	}
}

#-------------------------------------------------------------------------------

1 ;

=head1 NAME

Text::Editor::Vip::Buffer - Editing engine

=head1 SYNOPSIS

  use Text::Editor::Vip::Buffer ;
  my $buffer = new Text::Editor::Vip::Buffer() ;
  
=head1 DESCRIPTION

This module implements the core functionality for an editing engine. It knows about 
selection,  undo and plugins.

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
