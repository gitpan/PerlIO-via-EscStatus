# Copyright 2008, 2009, 2010 Kevin Ryde

# This file is part of PerlIO-via-EscStatus.
#
# PerlIO-via-EscStatus is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# PerlIO-via-EscStatus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with PerlIO-via-EscStatus.  If not, see <http://www.gnu.org/licenses/>.

package PerlIO::via::EscStatus::Parser;
use 5.006;  # for $-[0]
use strict;
use warnings;

our $VERSION = 7;

# This regexp generated by devel/partial-end.pl.  It matches either a whole
# ESCSTATUS_STR anywhere, or a leading portion of it at the end of the
# string, like say /\e_$/.  Frequently there won't be any Esc's left in the
# string and the first \e will quickly fail to match.
#
use constant ESCSTATUS_STR_PARTIAL_REGEXP
  => qr/\e(?:$|_(?:$|E(?:$|s(?:$|c(?:$|S(?:$|t(?:$|a(?:$|t(?:$|u(?:$|s(?:$|\e(?:$|\\))))))))))))/;

sub new {
  my ($class) = @_;
  return bless { partial => '' }, $class;
}

sub parse {
  my ($self, $buf) = @_;
  my $status = undef;
  $buf = $self->{'partial'} . $buf;

  # whole statuses
  if ($buf =~ s/\e_EscStatus\e\\([^\n]*)\n//g) {
    $status = $1;
  }
  my $pos = ($buf =~ ESCSTATUS_STR_PARTIAL_REGEXP
             ? $-[0] # start of match
             : length ($buf));
  $self->{'partial'} = substr ($buf, $pos); # match onwards
  $buf = substr ($buf, 0, $pos);            # prematch
  return ($status, $buf);
}

1;
__END__

=head1 NAME

PerlIO::via::EscStatus::Parser - parse out status escape lines

=for test_synopsis my ($input)

=head1 SYNOPSIS

 use PerlIO::via::EscStatus::Parser;
 my $ep = PerlIO::via::EscStatus::Parser->new;
 my ($text, $status) = $ep->parse ($input);

=head1 DESCRIPTION

An C<EscStatus::Parser> object parses out EscStatus format status strings
from text.  This is used by the EscStatus layers and is offered for parsing
a stream the same way the layers do.

=head1 FUNCTIONS

=over 4

=item C<< $ep = PerlIO::via::EscStatus::Parser->new >>

Create and return a new parser object.

=item C<< ($text, $status) = $ep->parse ($input) >>

Parse an input string C<$input> and return the plain C<$text> part of that
input, and the last complete C<$status> line.  If there's no complete status
line yet then C<$status> is C<undef>.  If there's no plain text, ie. if the
input is entirely status, then C<$text> is an empty string C<"">.

C<$input> doesn't have to be complete lines.  Any partial status at the end
of it is held in C<$ep> and will be returned on a later C<parse> call when
the full line has been received.

=back

=head1 SEE ALSO

L<PerlIO::via::EscStatus>

=head1 HOME PAGE

http://user42.tuxfamily.org/perlio-via-escstatus/index.html

=head1 LICENSE

Copyright 2008, 2009, 2010 Kevin Ryde

PerlIO-via-EscStatus is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

PerlIO-via-EscStatus is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
PerlIO-via-EscStatus.  If not, see http://www.gnu.org/licenses/

=cut
