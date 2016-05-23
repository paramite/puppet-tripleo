# Copyright 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::monitoring::sensu
#
# Sensu configuration for TripleO
#
# === Parameters
#
# [*step*]
#   (Optional) String. The current step of the deployment
#   Defaults to hiera('step')
#
# [*enable_monitoring*]
#   (Optional) Set to true if overcloud monitoring should be installed
#   on overcloud nodes
#   Defaults to hiera('enable_monitoring', true)
#
class tripleo::profile::base::monitoring::sensu (
  $step              = hiera('step', undef),
  $enable_monitoring = hiera('enable_monitoring', true),
) {

  if $enable_monitoring and ($step == undef or $step >= 3) {
    include ::sensu

    # TODO(mmagr): To successfully connect to redis without password, we must
    #              not use empty string in config. This should be removed once
    #              it is fixed in sensu-puppet module:
    #              [https://github.com/sensu/sensu-puppet/issues/503]
    if hiera('::redis::requirepass', undef) == undef {
      augeas { 'redis-password-hack':
        incl    => '/etc/sensu/conf.d/redis.json',
        lens    => 'Json.lns',
        changes => [
          'rm dict/entry[.= "redis"]/dict/entry[.="password"]'
        ],
        require => Class['::sensu']
      }

      if hiera('::redis::server', true) {
        $cmd_server = 'sensu-server'
      } else {
        $cmd_server = ''
      }
      if hiera('::redis::api', true) {
        $cmd_api = 'sensu-api'
      } else {
        $cmd_api = ''
      }
      if hiera('::redis::client', true) {
        $cmd_client = 'sensu-client'
      } else {
        $cmd_client = ''
      }

      exec { 'restart-sensu-services':
        path    => ['/usr/bin', '/usr/sbin', '/bin', 'sbin'],
        command => "systemctl restart ${cmd_server} ${cmd_api} ${cmd_client}",
        require => Augeas['redis-password-hack']
      }
    }
  }
}
