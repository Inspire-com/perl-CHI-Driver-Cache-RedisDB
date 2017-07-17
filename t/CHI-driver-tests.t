use strict;
use warnings;
use version;

use Test::Most tests => 2;
use CHI::Driver::Cache::RedisDB::t::CHIDriverTests;
use Test::RedisDB;

my $server = Test::RedisDB->new;
plan(skip_all => 'Could not start test redis-server') unless $server;

my $min_version = version->parse("2.6.12"); # Need to be able to use EX with SET
my $server_version = version->parse($server->redisdb_client->version);

plan(   skip_all => 'redis-server version too low ('
      . $server_version
      . '), need: '
      . $min_version)
  unless $server_version >= $min_version;

my $prev_env = $ENV{REDIS_CACHE_SERVER};

$ENV{REDIS_CACHE_SERVER} = $server->url;

subtest 'CHI provided tests' => sub {
    CHI::Driver::Cache::RedisDB::t::CHIDriverTests->runtests;
};

subtest 'flush_all' => sub {
    ok(CHI->new(driver => 'Cache::RedisDB')->flush_all, 'Flushed all');
};

$ENV{REDIS_CACHE_SERVER} = $prev_env;

done_testing;
