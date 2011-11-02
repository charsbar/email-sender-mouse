#!perl
use strict;
use warnings;
use Test::More tests => 5;

use Email::Sender::Mouse::Failure;
use Email::Sender::Mouse::Failure::Permanent;
use Email::Sender::Mouse::Failure::Temporary;
use Email::Sender::Mouse::Failure::Multi;

my $fail = Email::Sender::Mouse::Failure->new("generic");
my $perm = Email::Sender::Mouse::Failure::Permanent->new("permanent");
my $temp = Email::Sender::Mouse::Failure::Temporary->new("temporary");

my $multi_fail = Email::Sender::Mouse::Failure::Multi->new({
  message  => 'multifail',
  failures => [ $fail ],
});

isa_ok($multi_fail, 'Email::Sender::Mouse::Failure', 'multi(Failure)');
ok(! $multi_fail->isa('Nothing::Is::This'), 'isa is not catholic');

my $multi_perm = Email::Sender::Mouse::Failure::Multi->new({
  message  => 'multifail',
  failures => [ $perm ],
});

isa_ok($multi_perm, 'Email::Sender::Mouse::Failure::Permanent', 'multi(Failure::P)');

my $multi_temp = Email::Sender::Mouse::Failure::Multi->new({
  message  => 'multifail',
  failures => [ $temp ],
});

isa_ok($multi_temp, 'Email::Sender::Mouse::Failure::Temporary', 'multi(Failure::T)');

my $multi_mixed = Email::Sender::Mouse::Failure::Multi->new({
  message  => 'multifail',
  failures => [ $fail, $perm, $temp ],
});

ok(! $multi_mixed->isa('Email::Sender::Mouse::Failure::Temporary'), 'mixed <> temp');
