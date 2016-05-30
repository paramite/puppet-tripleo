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
# == Class: tripleo::profile::base::sensu::rabbitmq
#
# RabbitMQ configuration for Sensu stack for TripleO
#
# === Parameters

class tripleo::profile::base::sensu::rabbitmq (
  $rabbitmq_vhost           = 'sensu',
  $rabbitmq_user            = hiera('rabbit_username', 'sensu'),
  $rabbitmq_password        = hiera('rabbit_password', undef),
) {
  rabbitmq_vhost { 'sensu-rabbit-vhost':
    ensure => present,
    name   => $rabbitmq_vhost
  } -> rabbitmq_user { 'sensu-rabbit-user':
    name     => $rabbitmq_user,
    password => $rabbitmq_password,
    tags     => ['monitoring']
  } -> rabbitmq_user_permissions { "{$rabbitmq_user}@${rabbitmq_vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }
}
