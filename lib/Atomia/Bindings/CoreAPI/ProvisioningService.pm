#!/usr/bin/perl

package Atomia::Bindings::CoreAPI::ProvisioningService;

use Moose;

has 'element_name' => (is => 'rw', isa => 'Str', default => 'service');
has 'fetched' => (is => 'rw');

sub serialize {
	my $self = shift;

	my $class_name = blessed($self->fetched);

	my @properties;
	if (defined($self->fetched->{"properties"}) && ref($self->fetched->{"properties"}) eq "HASH" && defined($self->fetched->{"properties"}->{"ProvisioningServiceProperty"})) {
		@properties = map {
			if (defined($_) && ref($_) eq "HASH") {
				SOAP::Data->name("a:ProvisioningServiceProperty")->value(\SOAP::Data->value(
					SOAP::Data->name("a:ID")->value($_->{"ID"})->type('string'),
					SOAP::Data->name("a:IsKey")->value($_->{"IsKey"})->type('boolean'),
					SOAP::Data->name("a:Name")->value($_->{"Name"})->type('string'),
					SOAP::Data->name("a:propStringValue")->value($_->{"propStringValue"})->type('string')))
			} else {
				SOAP::Data->name("a:ProvisioningServiceProperty")->value(undef)
			}
		} @{$self->fetched->{"properties"}->{"ProvisioningServiceProperty"}};
	}

	my $serialized = SOAP::Data->name($self->element_name)->attr({ 'i:type' => "a:$class_name", 'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns:a' => 'http://schemas.datacontract.org/2004/07/Atomia.Provisioning.Base' })->value(\SOAP::Data->value(
		SOAP::Data->name("a:AccountOwnerId")->value($self->fetched->{"AccountOwnerId"})->type('string'),
		SOAP::Data->name("a:CurrentRequestId")->value($self->fetched->{"CurrentRequestId"})->type('string'),
		defined($self->fetched->{"Parent"})
			? Atomia::Bindings::CoreAPI::ProvisioningService->new(element_name => 'Parent', fetched => $self->fetched->{"Parent"})->serialize()
			: SOAP::Data->name("a:Parent")->value(undef),
		SOAP::Data->name("a:Status")->value($self->fetched->{"Status"})->type(''),
		SOAP::Data->name("a:disabled")->value($self->fetched->{"disabled"})->type('boolean'),
		SOAP::Data->name("a:friendlyName")->value($self->fetched->{"friendlyName"})->type('string'),
		SOAP::Data->name("a:logicalId")->value($self->fetched->{"logicalId"})->type('string'),
		SOAP::Data->name("a:name")->value($self->fetched->{"name"})->type('string'),
		SOAP::Data->name("a:physicalId")->value($self->fetched->{"physicalId"})->type('string'),
		(scalar(@properties) > 0 ? SOAP::Data->name("a:properties")->value(\SOAP::Data->value(@properties)) : SOAP::Data->type("xml" => "<a:properties/>")),
		SOAP::Data->name("a:provisioningDescription")->value($self->fetched->{"provisioningDescription"})->type('string'),
	));
	return $serialized;
}

sub setprop {
	my $self = shift;
	my $name = shift;
	my $value = shift;

	if (defined($self->fetched->{"properties"}) && ref($self->fetched->{"properties"}) eq "HASH" && defined($self->fetched->{"properties"}->{"ProvisioningServiceProperty"})) {
		foreach my $prophash (@{$self->fetched->{"properties"}->{"ProvisioningServiceProperty"}}) {
			if (defined($prophash) && ref($prophash) eq "HASH" && defined($prophash->{"Name"}) && $prophash->{"Name"} eq $name) {
				$prophash->{"propStringValue"} = $value;
				return;
			}
		}

		die Atomia::Bindings::CoreAPI::Exception->new(message => "property with name $name didn't exist in ProvisioningService object");
	} else {
		die Atomia::Bindings::CoreAPI::Exception->new(message => "error setting property of ProvisioningService, no properties exist in object used to construct service object");
	}
}

sub getprop {
	my $self = shift;
	my $name = shift;

	if (defined($self->fetched->{"properties"}) && ref($self->fetched->{"properties"}) eq "HASH" && defined($self->fetched->{"properties"}->{"ProvisioningServiceProperty"})) {
		foreach my $prophash (@{$self->fetched->{"properties"}->{"ProvisioningServiceProperty"}}) {
			if (defined($prophash) && ref($prophash) eq "HASH" && defined($prophash->{"Name"}) && $prophash->{"Name"} eq $name) {
				return $prophash->{"propStringValue"};
			}
		}

		die Atomia::Bindings::CoreAPI::Exception->new(message => "property with name $name didn't exist in ProvisioningService object");
	} else {
		die Atomia::Bindings::CoreAPI::Exception->new(message => "error getting property of ProvisioningService, no properties exist in object used to construct service object");
	}
}

1;
