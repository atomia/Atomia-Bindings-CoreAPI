#!/usr/bin/perl

package Atomia::Bindings::CoreAPI::ServiceSearchCriteriaArray;

use Moose;

has 'element_name' => (is => 'rw', isa => 'Str', default => 'searchCriteriaList');
has 'criterias' => (is => 'ro', isa => 'ArrayRef');

sub serialize {
	my $self = shift;

	my @serialized_criterias = map {
		SOAP::Data->name("a:ServiceSearchCriteria")->attr({ 'xmlns:a' => 'http://schemas.datacontract.org/2004/07/Atomia.Provisioning.Base' })->value(\SOAP::Data->value(
			defined($_->{"parent_service"}) ? $_->{"parent_service"}->serialize("a:ParentService") : SOAP::Data->name("a:ParentService")->value(undef),
			SOAP::Data->name("a:ServiceName")->value($_->{"service_name"})->type('string'),
			SOAP::Data->name("a:ServicePath")->value($_->{"service_path"})->type('string'),
			))
	} @{$self->criterias};

	return SOAP::Data->name($self->element_name)->attr({ 'xsi:type' => ''})->value(\SOAP::Data->value(@serialized_criterias));
}

1;
