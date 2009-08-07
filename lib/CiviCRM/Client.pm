package CiviCRM::Client;

=head1 NAME

CiviCRM::Client - Client library for the CiviCRM API

This Perl module provides a wrapper around the REST web services
exposed by CiviCRM. It makes interacting with CiviCRM from Perl
scripts much simpler.

=head1 SYNOPSIS

See the docs for CiviCRM::Client::REST for the details on how to use this
module in your code.

=cut

# For now we just use the REST client implementation since it's the only one
use CiviCRM::Client::REST;

1;