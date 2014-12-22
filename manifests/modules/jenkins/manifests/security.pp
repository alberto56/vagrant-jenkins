# Copyright 2014 RetailMeNot, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Class jenkins::security
#
# Jenkins security configuration
#
class jenkins::security (
  $security_model = undef,
){
  validate_string($security_model)

  include ::jenkins::cli_helper

  exec { "jenkins-security-${security_model}":
    command => join([
      $::jenkins::cli_helper::helper_cmd,
      'set_security',
      $security_model,
    ], ' '),
    require => Class['::jenkins::cli_helper'],
  }
}
