#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'CiviCRM::Client' );
}

diag( "Testing CiviCRM $CiviCRM::Client::REST::VERSION, Perl $], $^X" );
