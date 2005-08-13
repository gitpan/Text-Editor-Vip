
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

#~ our @EXTEND_VIP_BUFFER = 
	#~ qw (
	#~ );
}

#-------------------------------------------------------------------------------

sub IncrementUndoStackLevel
{
my ($this, $do_prefix, $undo_prefix) = @_;

$this->{DO_PREFIX} .= $do_prefix ;
$this->{UNDO_PREFIX} .= $undo_prefix;
}

#-------------------------------------------------------------------------------

sub DecrementUndoStackLevel
{
my ($this, $do_prefix, $undo_prefix) = @_;

substr $this->{DO_PREFIX}, -(length($do_prefix)), length($do_prefix),  '' ;
substr $this->{UNDO_PREFIX}, -(length($undo_prefix)), length($undo_prefix), '';
}

#-------------------------------------------------------------------------------

sub PushUndoStep
{
my $this = shift ;
my $do   = shift ;
my $undo = shift ;

my ($package, $file_name, $line, $sub) = caller(1) ;
my $description = "'$sub' @ $file_name:$line" ;

my $do_text = '' ;
if('ARRAY' eq ref $do)
	{
	$do_text .= join("\n", map{"$this->{DO_PREFIX}$_"} @$do) ;
	}
else
	{
	$do_text = "$this->{DO_PREFIX}$do" ;
	}
	
push @{$this->{DO_STACK}}, $do_text ;

my $undo_text = '' ;
if('ARRAY' eq ref $undo)
	{
	$undo_text .= join("\n", map{"$this->{UNDO_PREFIX}$_"} @$undo) ;
	}
else
	{
	$undo_text = "$this->{UNDO_PREFIX}$undo" ;
	}
	
push @{$this->{UNDO_STACK}}, $undo_text ;
}

#-------------------------------------------------------------------------------

sub Undo
{
die "Unimplemented\n" ;
}

#-------------------------------------------------------------------------------

sub GetDoPosition
{
my $this = shift ;

return(scalar(@{$this->{DO_STACK}})) ;
}

#-------------------------------------------------------------------------------

sub GetUndoBuffer
{
my $this = shift ;

my $start =  shift || 0 ;
my $end = shift || $#{$this->{UNDO_STACK}} ;

my @undo_buffer = @{$this->{UNDO_STACK}}[$start .. $end] ;
@undo_buffer  = reverse @undo_buffer ;

my($modification_line, $modification_character) = $this->GetModificationPosition() ;

return("#\n# Current position: $modification_line, $modification_character\n#\n" . join("\n", @undo_buffer) . "\n") ;
}

#-------------------------------------------------------------------------------

sub GetDoBuffer
{
my $this = shift ;

my $start =  shift || 0 ;
my $end =  shift || $#{$this->{DO_STACK}} ;

return(join("\n",@{$this->{DO_STACK}}[$start .. $end]) . "\n") ;
}

#-------------------------------------------------------------------------------

sub Redo
{
my $this = shift ;
}

#-------------------------------------------------------------------------------

1 ;

=head1 NAME

Text::Editor::Vip::Buffer::DoUndoRedo - 

=head1 SYNOPSIS

  use Text::Editor::Vip::DoUndoRedo

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

