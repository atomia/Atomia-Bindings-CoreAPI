#!/usr/bin/perl

package Atomia::Bindings::CoreAPI::StringWithName;

use Moose;

has 'name' => (is => 'rw', isa => 'Str');
has 'value' => (is => 'rw', isa => 'Str');

sub serialize {
	my $self = shift;
	return SOAP::Data->name($self->name, $self->value)->type('string');
}

1;
