# This is used to create configuration file for collectd-gnocchi plugin
define tripleo::profile::base::metrics::collectd::gnocchi (
  $ensure                       = 'present',
  $order                        = '00',
  $auth_mode                    = 'simple',
  $server                       = undef,
  $port                         = undef,
  $user                         = undef,
  $keystone_auth_url            = undef,
  $keystone_user_name           = undef,
  $keystone_user_id             = undef,
  $keystone_password            = undef,
  $keystone_project_id          = undef,
  $keystone_project_name        = undef,
  $keystone_user_domain_id      = undef,
  $keystone_user_domain_name    = undef,
  $keystone_project_domain_id   = undef,
  $keystone_project_domain_name = undef,
  $keystone_region_name         = undef,
  $keystone_interface           = undef,
  $keystone_endpoint            = undef,
  $resource_type                = 'collectd',
  $batch_size                   = 10,
) {
  include ::collectd

  package { 'python-collectd-gnocchi':
    ensure => $ensure,
  }

  collectd::plugin { 'gnocchi':
    ensure   => $ensure,
    order    => $order,
    content  => template('tripleo/collectd/collectd-gnocchi.conf.erb'),
    require  => Package['python-collectd-gnocchi']
  }
}
