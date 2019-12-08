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
# == Class: tripleo::profile::base::mistral::executor
#
# Mistral Executor profile for tripleo
#
# === Parameters
#
# [*bootstrap_node*]
#   (Optional) The hostname of the node responsible for bootstrapping tasks
#   Defaults to hiera('mistral_executor_short_bootstrap_node_name')
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
# [*docker_group*]
#   (Optional) Add the mistral user to the docker group to allow actions to
#   perform docker operations
#   Defaults to false
#
class tripleo::profile::base::mistral::executor (
  $bootstrap_node = hiera('mistral_executor_short_bootstrap_node_name', undef),
  $step           = Integer(hiera('step')),
  $docker_group   = false,
) {
  if $::hostname == downcase($bootstrap_node) {
    $sync_db = true
  } else {
    $sync_db = false
  }

  include tripleo::profile::base::mistral

  if $step >= 4 or ($step >= 3 and $sync_db)  {
    include mistral::executor
    if $docker_group {
      ensure_resource('group', 'docker', {
        'ensure' => 'present',
        'tag'    => 'group',
        'gid'    => $::docker_group_gid,
      })
      ensure_resource('user', 'mistral', {
        'name'   => 'mistral',
        'tag'    => 'user',
        'groups' => 'docker',
      })
    }
  }
}
