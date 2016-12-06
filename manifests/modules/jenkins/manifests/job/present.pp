# Define: jenkins::job::present
#
#   Creates or updates a jenkins build job
#
# Parameters:
#
#   config
#     the content of the jenkins job config file (required)
#
#   jobname = $title
#     the name of the jenkins job
#
#   enabled = 1
#     if the job should be enabled
#
define jenkins::job::present(
  $config,
  $jobname  = $title,
  $enabled  = 1,
){
  include jenkins::cli

  if $jenkins::service_ensure == 'stopped' or $jenkins::service_ensure == false {
    fail('Management of Jenkins jobs requires \$jenkins::service_ensure to be set to \'running\'')
  }

  $jenkins_cli        = $jenkins::cli::cmd
  $tmp_config_path    = "/tmp/${jobname}-config.xml"
  $job_dir            = "/var/lib/jenkins/jobs/${jobname}"
  $config_path        = "${job_dir}/config.xml"

  Exec {
    logoutput   => false,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    tries       => 5,
    try_sleep   => 5,
  }

  #
  # When a Jenkins job is imported via the cli, Jenkins will
  # re-format the xml file based on its own internal rules.
  # In order to make job management idempotent, we need to
  # apply that formatting before the import, so we can do a diff
  # on any pre-existing job to determine if an update is needed.
  #
  # Jenkins likes to change single quotes to double quotes
  $a = regsubst($config, 'version=\'1.0\' encoding=\'UTF-8\'',
                'version="1.0" encoding="UTF-8"')
  # Change empty tags into self-closing tags
  $b = regsubst($a, '<([a-z]+)><\/\1>', '<\1/>', 'IG')
  # Change &quot; to " since Jenkins is weird like that
  $c = regsubst($b, '&quot;', '"', 'MG')

  # Temp file to use as stdin for Jenkins CLI executable
  file { $tmp_config_path:
    content => $c,
    require => Exec['jenkins-cli'],
  }

  # Use Jenkins CLI to create the job
  $cat_config = "cat ${tmp_config_path}"
  $create_job = "${jenkins_cli} create-job ${jobname}"
  exec { "jenkins create-job ${jobname}":
    command => "${cat_config} | ${create_job}",
    creates => [$config_path, "${job_dir}/builds"],
    require => File[$tmp_config_path],
  }

  # Use Jenkins CLI to update the job if it already exists
  $update_job = "${jenkins_cli} update-job ${jobname}"
  exec { "jenkins update-job ${jobname}":
    command => "${cat_config} | ${update_job}",
    onlyif  => "test -e ${config_path}",
    unless  => "diff -b -q ${config_path} ${tmp_config_path}",
    require => File[$tmp_config_path],
    notify  => Exec['reload-jenkins'],
  }

  # Enable or disable the job (if necessary)
  if ($enabled == 1) {
    exec { "jenkins enable-job ${jobname}":
      command => "${jenkins_cli} enable-job ${jobname}",
      onlyif  => "cat ${config_path} | grep '<disabled>true'",
      require => [
        Exec["jenkins create-job ${jobname}"],
        Exec["jenkins update-job ${jobname}"],
      ],
    }
  } else {
    exec { "jenkins disable-job ${jobname}":
      command => "${jenkins_cli} disable-job ${jobname}",
      onlyif  => "cat ${config_path} | grep '<disabled>false'",
      require => [
        Exec["jenkins create-job ${jobname}"],
        Exec["jenkins update-job ${jobname}"],
      ],
    }
  }

}
