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
# == Class: tripleo::profile::pacemaker::loadbalancer
#
# Loadbalancer Pacemaker HA profile for tripleo
#
# === Parameters
#
# [*bootstrap_node*]
#   (Optional) The hostname of the node responsible for bootstrapping tasks
#   Defaults to hiera('bootstrap_nodeid')
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
# [*enable_load_balancer*]
#   (Optional) Whether load balancing is enabled for this cluster
#   Defaults to hiera('enable_load_balancer', true)
#
class tripleo::profile::pacemaker::loadbalancer (
  $bootstrap_node       = hiera('bootstrap_nodeid'),
  $step                 = hiera('step'),
  $enable_load_balancer = hiera('enable_load_balancer', true)
) {

  include ::tripleo::profile::base::loadbalancer

  if $::hostname == downcase($bootstrap_node) {
    $pacemaker_master = true
  } else {
    $pacemaker_master = false
  }

  if $step >= 2 and $pacemaker_master and $enable_load_balancer {
      # FIXME: we should not have to access tripleo::loadbalancer class
      # parameters here to configure pacemaker VIPs. The configuration
      # of pacemaker VIPs could move into puppet-tripleo or we should
      # make use of less specific hiera parameters here for the settings.
      pacemaker::resource::service { 'haproxy':
        clone_params => true,
      }

      $control_vip = hiera('tripleo::loadbalancer::controller_virtual_ip')
      tripleo::pacemaker::haproxy_with_vip { 'haproxy_and_control_vip':
        vip_name   => 'control',
        ip_address => $control_vip,
      }

      $public_vip = hiera('tripleo::loadbalancer::public_virtual_ip')
      tripleo::pacemaker::haproxy_with_vip { 'haproxy_and_public_vip':
        ensure     => $public_vip and $public_vip != $control_vip,
        vip_name   => 'public',
        ip_address => $public_vip,
      }

      $redis_vip = hiera('redis_vip')
      tripleo::pacemaker::haproxy_with_vip { 'haproxy_and_redis_vip':
        ensure     => $redis_vip and $redis_vip != $control_vip,
        vip_name   => 'redis',
        ip_address => $redis_vip,
      }

      $internal_api_vip = hiera('tripleo::loadbalancer::internal_api_virtual_ip')
      tripleo::pacemaker::haproxy_with_vip { 'haproxy_and_internal_api_vip':
        ensure     => $internal_api_vip and $internal_api_vip != $control_vip,
        vip_name   => 'internal_api',
        ip_address => $internal_api_vip,
      }

      $storage_vip = hiera('tripleo::loadbalancer::storage_virtual_ip')
      tripleo::pacemaker::haproxy_with_vip { 'haproxy_and_storage_vip':
        ensure     => $storage_vip and $storage_vip != $control_vip,
        vip_name   => 'storage',
        ip_address => $storage_vip,
      }

      $storage_mgmt_vip = hiera('tripleo::loadbalancer::storage_mgmt_virtual_ip')
      tripleo::pacemaker::haproxy_with_vip { 'haproxy_and_storage_mgmt_vip':
        ensure     => $storage_mgmt_vip and $storage_mgmt_vip != $control_vip,
        vip_name   => 'storage_mgmt',
        ip_address => $storage_mgmt_vip,
      }
  }

}
