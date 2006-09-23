#!perl

use strict;
use warnings;
use FFmpeg::Command;
use Test::More tests => 1;

my $ff = FFmpeg::Command->new();
$ff->options( [ '-version' ] );
$ff->exec();
like $ff->errstr, qr/^FFmpeg version/i;
