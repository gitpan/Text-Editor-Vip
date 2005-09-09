
package Text::Editor::Vip::Buffer::DoUndoRedo;
use strict;
use warnings ;

BEGIN 
{
use Exporter ();
use vars qw ($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = 0.01_1;
@ISA         = qw (Exporter);
@EXPORT      = 
		qw (
		DecrementUndoStackLevel
		GetDoBuffer
		GetDoPosition
		GetUndoBuffer
		IncrementUndoStackLevel
		PushUndoStep
		Redo
		Undo
		);
		
@EXPORT_OK   = qw ();
%EXPORT_TAGS = ();
}

=head1 NAME

Text::Editor::Vip::Buffer::DoUndoRedo - non optional plugin for a Text::Editor::Vip::Buffer

=head1 DESCRIPTION

The do, undo, redo functionality of Text::Editor::Vip::Buffer is implemented by this package.
This package automatically extends a Text::Editor::Vip::Buffer when a Text::Editor::Vip::Buffer
instance is created.

This package manipulated the data structures used to implement a do, undo and redo functionality.
Text::Editor::Vip uses perl as it building block to implement such functionality. Perl "scripts" are the base 
for implementing this functionality.

=head1 MEMBER FUNCTIONS

=cut

#-------------------------------------------------------------------------------

sub IncrementUndoStackLevel
{

=head2 IncrementUndoStackLevel

Increments the do and undo prefix for the perl "scripts' used to implement do and undo.

=cut

my ($buffer, $do_prefix, $undo_prefix) = @_;

$buffer->{DO_PREFIX} .= $do_prefix ;
$buffer->{UNDO_PREFIX} .= $undo_prefix;
}

#-------------------------------------------------------------------------------

sub DecrementUndoStackLevel
{

=head2 DecrementUndoStackLevel

Decrements the do and undo prefix for the perl "scripts' used to implement do and undo.

=cut

my ($buffer, $do_prefix, $undo_prefix) = @_;

substr $buffer->{DO_PREFIX}, -(length($do_prefix)), length($do_prefix),  '' ;
substr $buffer->{UNDO_PREFIX}, -(length($undo_prefix)), length($undo_prefix), '';
}

#-------------------------------------------------------------------------------

sub PushUndoStep
{

=head2 PushUndoStep

Adds a do "script"  to the do  command list and an undo "script" to the undo command list.
The scripts are prepended with the prefixes defined by L<IncrementUndoStackLevel> and L<DecrementUndoStackLevel>

=cut

my $buffer = shift ;
my $do   = shift ;
my $undo = shift ;

my ($package, $file_name, $line, $sub) = caller(1) ;
my $description = "'$sub' @ $file_name:$line" ;

my $do_text = '' ;
if('ARRAY' eq ref $do)
	{
	$do_text .= join("\n", map{"$buffer->{DO_PREFIX}$_"} @$do) ;
	}
else
	{
	$do_text = "$buffer->{DO_PREFIX}$do" ;
	}
	
#~ $do_text = "#$description\n$do_text" ;
push @{$buffer->{DO_STACK}}, $do_text ;

my $undo_text = '' ;
if('ARRAY' eq ref $undo)
	{
	$undo_text .= join("\n", map{"$buffer->{UNDO_PREFIX}$_"} @$undo) ;
	}
else
	{
	$undo_text = "$buffer->{UNDO_PREFIX}$undo" ;
	}

#~ $undo_text = "#$description\n$undo_text" ;
push @{$buffer->{UNDO_STACK}}, $undo_text ;
}

#-------------------------------------------------------------------------------

sub Undo
{

=head2 Undo

Undoes the commands the commands that have been executed on a buffer.

=cut

my $buffer = shift ;
my $number_of_steps = shift ;

die "Unimplemented\n" ;
}

#-------------------------------------------------------------------------------

sub GetDoPosition
{

=head2 GetDoPosition

Gets the current index of the do command list. This index can be later passes to L<GetUndoBuffer> to
get a selected amount of undo commands.

This index can also be used to get a selected amound of do commands to implement a macro facility.


  my $start_position = $buffer->GetDoPosition() ;

  $buffer->DoLotsOfStuff() ;
  $buffer->DoEvenMoreStuff() ;
  
  # get scripts that would undo everything since we got the do position
  $undo = $buffer->GetUndoBuffer($start_position) ;
  
  # get scripts that correspond sto what has been done since we got the do position
  $do = $buffer->GetDoBuffer($start_position) ;

=cut

my $buffer = shift ;

return(scalar(@{$buffer->{DO_STACK}})) ;
}

#-------------------------------------------------------------------------------

sub GetUndoBuffer
{

=head2 GetUndoBuffer

This sub is given a start and and end index. those indexes are used to retrieve undo commands.

If not arguments are passed, the start index will be set to zero (first undo command) and the last available
undo command. Thus returning a list of all the commands in the undo stack.


See L<GetDoPosition>

=cut

my $buffer = shift ;

my $start =  shift || 0 ;
my $end = shift || $#{$buffer->{UNDO_STACK}} ;

my @undo_buffer = @{$buffer->{UNDO_STACK}}[$start .. $end] ;
@undo_buffer  = reverse @undo_buffer ;

my($modification_line, $modification_character) = $buffer->GetModificationPosition() ;

return("#\n# Current position: $modification_line, $modification_character\n#\n" . join("\n", @undo_buffer) . "\n") ;
}

#-------------------------------------------------------------------------------

sub GetDoBuffer
{

=head2 GetDoBuffer

This sub is given a start and and end index. those indexes are used to retrieve do commands.

If not arguments are passed, the start index will be set to zero (first do command) and the last available
do command. Thus returning a list of all the commands in the do stack.

See L<GetDoPosition>

=cut

my $buffer = shift ;

my $start =  shift || 0 ;
my $end =  shift || $#{$buffer->{DO_STACK}} ;

return(join("\n",@{$buffer->{DO_STACK}}[$start .. $end]) . "\n") ;
}

#-------------------------------------------------------------------------------

sub Redo
{

=head2 Redo

Redoes the commands the commands that have been executed on a buffer.

=cut

my $buffer = shift ;
}

#-------------------------------------------------------------------------------

1 ;

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

