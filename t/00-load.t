#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'FFmpeg::Command' );
}

diag( "Testing FFmpeg::Command $FFmpeg::Command::VERSION, Perl $], $^X" );
