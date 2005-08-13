
package Text::Editor::Vip::CommandBlock;

use strict;
use warnings ;

use Text::Editor::Vip::Buffer::DoUndoRedo ;

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

sub new
{
my ($class, $buffer, $do, $do_prefix, $undo, $undo_prefix) = @_;

$do ||= '' ;
$do_prefix ||= '' ;
$undo ||= '' ;
$undo_prefix ||= '' ;

PushUndoStep($buffer, $do, $undo) ;
IncrementUndoStackLevel($buffer, $do_prefix, $undo_prefix) ;

my $this = bless 
		(
		{ BUFFER => $buffer, DO_PREFIX => $do_prefix, UNDO_PREFIX => $undo_prefix}
		, ref ($class) || $class
		);

return ($this);
}

#-------------------------------------------------------------------------------

sub DESTROY
{
my $this = shift ;

DecrementUndoStackLevel($this->{BUFFER}, $this->{DO_PREFIX}, $this->{UNDO_PREFIX}) ;
}

#-------------------------------------------------------------------------------

1 ;

=head1 NAME

Text::Editor::Vip::CommandBlock - 

=head1 SYNOPSIS

  use Text::Editor::Vip::CommandBlock

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


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
