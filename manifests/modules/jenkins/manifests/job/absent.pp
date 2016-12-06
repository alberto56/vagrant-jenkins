# Define: jenkins::job::absent
#
#   Removes a jenkins build job
#
# Parameters:
#
#   config
#     the content of the jenkins job config file (required)
#
#   jobname = $title
#     the name of the jenkins job
#
define jenkins::job::absent(
  $jobname  = $title,
){
  include jenkins::cli

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins jobs requires \$jenkins::service_ensure to be set to \'running\'')
  }

  $tmp_config_path  = "/tmp/${jobname}-config.xml"
  $job_dir          = "/var/lib/jenkins/jobs/${jobname}"
  $config_path      = "${job_dir}/config.xml"

  # Temp file to use as stdin for Jenkins CLI executable
  file { $tmp_config_path:
    ensure  => absent,
  }

  # Delete the job
  exec { "jenkins delete-job ${jobname}":
    command   => "${jenkins::cli::cmd} delete-job ${jobname}",
    logoutput => false,
    onlyif    => "test -f ${config_path}",
    require   => Exec['jenkins-cli'],
  }

}
