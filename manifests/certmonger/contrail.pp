# Copyright (C) 2018 Juniper Networks
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
# == Class: tripleo::certmonger::contrail
#
# Request a certificate for the contrail service and do the necessary setup.
#
# === Parameters
#
# [*hostname*]
#   The hostname of the node. this will be set in the CN of the certificate.
#
# [*service_certificate*]
#   The path to the certificate that will be used for TLS in this service.
#
# [*service_key*]
#   The path to the key that will be used for TLS in this service.
#
# [*certmonger_ca*]
#   (Optional) The CA that certmonger will use to generate the certificates.
#   Defaults to hiera('contrail_certmonger_ca', 'IPA').
#
# [*postsave_cmd*]
#   (Optional) Specifies the command to execute after requesting a certificate.
#   Defaults to undef
#
# [*principal*]
#   (Optional) The service principal that is set for contrail in kerberos.
#   Defaults to undef
#
class tripleo::certmonger::contrail (
  $hostname,
  $service_certificate,
  $service_key,
  $certmonger_ca    = hiera('contrail_certmonger_ca', 'IPA'),
  $dnsnames         = $hostname,
  $container_cli    = hiera('container_cli', docker),
  $presave_cmd      = "/usr/bin/certmonger-contrail-presave.sh",
  $postsave_cmd     = "/usr/bin/certmonger-contrail-postsave.sh",
  $principal        = undef,
  $contrail_user    = 'root',
  $contrail_group   = 1999,
) {
  include ::certmonger
  certmonger_certificate { 'contrail' :
    ensure       => 'present',
    certfile     => $service_certificate,
    keyfile      => $service_key,
    hostname     => $hostname,
    dnsname      => $dnsnames,
    principal    => $principal,
    presave_cmd  => $presave_cmd,
    postsave_cmd => $postsave_cmd,
    ca           => $certmonger_ca,
    wait         => true,
    tag          => 'contrail-cert',
    require      => Class['::certmonger'],
  } ->
  file { $service_certificate :
    require => Certmonger_certificate['contrail'],
    owner   => $contrail_user,
    group   => $contrail_group,
    seltype => 'cert_t',
    mode    => '0644',
  } ->
  file { $service_key :
    require => Certmonger_certificate['contrail'],
    owner   => $contrail_user,
    group   => $contrail_group,
    seltype => 'cert_t',
    mode    => '0640',
  }
}
