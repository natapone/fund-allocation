use inc::Module::Install;

name 'fund-allocation';
all_from 'lib/fund/allocation.pm';

build_requires 'Test::Perl::Critic';

requires 'Data::Dumper';

test_requires 'Test::More';

auto_install;

WriteAll;
