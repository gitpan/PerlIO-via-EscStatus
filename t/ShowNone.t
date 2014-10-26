#!/usr/bin/perl

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

use 5.006;  # 3-arg open
use strict;
use warnings;
use PerlIO::via::EscStatus::ShowNone;
use Test::More tests => 7;

SKIP: { eval 'use Test::NoWarnings; 1'
          or skip 'Test::NoWarnings not available', 1; }


my $want_version = 7;
is ($PerlIO::via::EscStatus::ShowNone::VERSION, $want_version,
    'VERSION variable');
is (PerlIO::via::EscStatus::ShowNone->VERSION,  $want_version,
    'VERSION class method');
ok (eval { PerlIO::via::EscStatus::ShowNone->VERSION($want_version); 1 },
    "VERSION class check $want_version");
{ my $check_version = $want_version + 1000;
  ok (! eval { PerlIO::via::EscStatus::ShowNone->VERSION($check_version); 1 },
      "VERSION class check $check_version");
}


sub slurp {
  my ($filename) = @_;
  open (my $fh, '<', $filename) or die "Cannot open $filename for read: $!";
  my $content = do { local $/ = undef; <$fh> };
  close ($fh) or die "Error closing read $filename";
  return $content;
}

{ diag "on a binary file";
  require File::Temp;
  my $tmp = File::Temp->new (TEMPLATE => 'PerlIO-via-EscStatus-ShowNone-test-XXXXXX',
                             TMPDIR => 1);
  my $filename = $tmp->filename;
  diag "temp file $filename";
  open (my $fh, '>', $filename) or die "Cannot open $filename for write: $!";

  binmode ($fh, ':via(EscStatus::ShowNone)')
    or die "Cannot push EscStatus::ShowNone layer";

  print $fh "start\n";
  require PerlIO::via::EscStatus;
  print $fh PerlIO::via::EscStatus::make_status('foo');
  print $fh "end\n";
  close ($fh) or die "Error closing write $filename";

  my $str = slurp ($filename);
  is ($str, "start\nend\n");
}

{ diag "on a utf8 file";
  require File::Temp;
  my $tmp = File::Temp->new (TEMPLATE => 'PerlIO-via-EscStatus-ShowNone-test-XXXXXX',
                             TMPDIR => 1);
  my $filename = $tmp->filename;
  diag "temp file $filename";
  open (my $fh, '>', $filename) or die "Cannot open $filename for write: $!";

  binmode ($fh, ':utf8')
    or die "Cannot set utf8 mode";
  binmode ($fh, ':via(EscStatus::ShowNone)')
    or die "Cannot push EscStatus::ShowNone layer";

  print $fh "start\n";
  require PerlIO::via::EscStatus;
  print $fh PerlIO::via::EscStatus::make_status('foo');
  print $fh "end\n";
  close ($fh) or die "Error closing write $filename";

  my $str = slurp ($filename);
  is ($str, "start\nend\n");
}

exit 0;
