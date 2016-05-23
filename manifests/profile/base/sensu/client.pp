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
# == Class: tripleo::profile::base::sensu::client
#
# Sensu client for TripleO
#
# === Parameters
#
# [*step*]
#   (Optional) String. The current step of the deployment
#   Defaults to hiera('step')
#
# [*subscription*]
#   (Optional) Array of strings. Topics to which Sensu client
#   should be subscribed.
#   Defaults to ['all']
#
# [*client_config*] Hash. Parameters which will be used for check
#   commands formatting.
#   Defaults to undef
#
# [*rabbitmq_vhost*]
#   (Optional) String. RabbitMQ vhost to be used by Sensu client
#   Defaults to 'sensu'
#
# [*rabbitmq_port*]
#   (Optional) Integer. Port on which RabbitMQ server is listening
#   Default to 5672
#
# [*rabbitmq_host*]
#   (Optional) String. Host running RabbitMQ server for Sensu
#   Defaults to hiera('rabbitmq_vip', '127.0.0.1')
#
# [*rabbitmq_user*]
#   (Optional) String. Username to connect to RabbitMQ server
#   Defaults to hiera('rabbit_username', 'sensu')
#
# [*rabbitmq_password*]
#   (Optional) String. Password to connect to RabbitMQ server
#   Defaults to hiera('rabbit_password', 'sensu')
#
# [*rabbitmq_ssl*]
#   (Optional) Boolean. Use SSL transport to connect to RabbitMQ.
#   Defaults to hiera('rabbit_client_use_ssl', false)
#
# [*redis_host*]
#   (Optional) String. Host running Redis for Sensu
#   Defaults to hiera('redis_vip', '127.0.0.1')
#
# [*redis_port*]
#   (Optional) Integer. Redis port to be used by Sensu client
#   Defaults to 6379
#
# [*redis_password*]
#   (Optional) String. Password to be used to connect to Redis
#   Defaults to hiera('redis_password', undef)
#

class tripleo::profile::base::sensu::client (
  $step                     = hiera('step', undef),
  $subscriptions            = ['all'],
  $client_config            = undef,
  # RabbitMQ parameters
  $rabbitmq_vhost           = 'sensu',
  $rabbitmq_port            = 5672,
  $rabbitmq_host            = hiera('rabbitmq_vip', '127.0.0.1'),
  $rabbitmq_user            = hiera('rabbit_username', 'sensu'),
  $rabbitmq_password        = hiera('rabbit_password', undef),
  $rabbitmq_ssl             = hiera('rabbit_client_use_ssl', false),
  # Redis parameters
  $redis_host               = hiera('redis_vip', '127.0.0.1'),
  $redis_port               = 6379,
  $redis_password           = hiera('redis_password', undef)

) {

  if $step == undef or $step >= 5 {
    class { '::sensu':
      enterprise            => false,
      enterprise_dashboard  => false,
      install_repo          => false,
      client                => true,
      server                => false,
      api                   => false,

      rabbitmq_vhost        => $rabbitmq_vhost,
      rabbitmq_port         => $rabbitmq_port,
      rabbitmq_host         => $rabbitmq_host,
      rabbitmq_user         => $rabbitmq_user,
      rabbitmq_password     => $rabbitmq_password,
      rabbitmq_ssl          => $rabbitmq_ssl,
      redis_host            => $redis_host,
      redis_port            => $redis_port,
      redis_password        => $redis_password,

      subscriptions         => $subscriptions,
      client_custom         => $client_config,

      sensu_plugin_provider => 'yum',
      sensu_plugin_name     => 'rubygem-sensu-plugin',
    }

    # Install OpenStack related check scripts
    package { 'osops-tools-monitoring-oschecks':
      ensure => 'present'
    }
  }
}
