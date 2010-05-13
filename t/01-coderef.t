#!perl

use strict;
use warnings;
use FFmpeg::Command;
use Test::More tests => 2;

BEGIN {
	use_ok( 'FFmpeg::Command' );
}

my $ff = FFmpeg::Command->new();
$ff->options( [ '-version' ] );
my $stderr;
$ff->stderr(sub { $stderr .= $_[0] });
$ff->exec();
like $stderr, qr/^FFmpeg version/i;
