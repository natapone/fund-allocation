use inc::Module::Install;

name 'fund-allocation';
all_from 'lib/fund/allocation.pm';

build_requires 'Test::Perl::Critic';

requires 'Finance::TA';
requires 'Data::Dumper';
requires 'Chart::Gnuplot';
requires 'DateTime';

test_requires 'Test::More';

auto_install;

WriteAll;
