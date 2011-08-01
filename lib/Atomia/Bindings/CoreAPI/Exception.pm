#!/usr/bin/perl

package Atomia::Bindings::CoreAPI::Exception;

use Moose;

has 'message' => (is => 'ro', isa => 'Str');

1;
