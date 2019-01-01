# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant multi machine configuration

require 'yaml'
config_yml = YAML.load_file(File.open(__dir__ + '/vagrant-config.yml'))

NON_ROOT_USER = 'vagrant'.freeze
SWAPSIZE = 1000

Vagrant.configure(2) do |config|
  # set auto update to false if you do NOT want to check the correct additions version when booting this machine
  # config.vbguest.auto_update = true

  config_yml[:vms].each do |name, settings|
    # use the config key as the vm identifier
    config.vm.define name.to_s, autostart: true, primary: true do |vm_config|
      config.ssh.insert_key = false
      vm_config.vm.usable_port_range = (2200..2250)

      # This will be applied to all vms

      # set auto_update to false, if you do NOT want to check the correct
      # additions version when booting this machine
      vm_config.vbguest.auto_update = false

      # Ubuntu
      vm_config.vm.box = settings[:box]

      # Vagrant can share the source directory using rsync, NFS, or SSHFS (with the vagrant-sshfs
      # plugin). Consult the Vagrant documentation if you do not want to use SSHFS.
      # Get's honored normally
      # vm_config.vm.synced_folder '.', '/vagrant', disabled: true
      # # But not the centos box
      # vm_config.vm.synced_folder '.', '/home/vagrant/sync', disabled: true

      # TODO: Should we try this???
      # Change the permission of files and directories
      # so that nosetests runs without extra arguments.
      # config.vm.synced_folder '.', '/vagrant', mount_options: ['dmode=775,fmode=664']
      # vm_config.vm.synced_folder '.', '/shared', type: 'nfs'

      # assign an ip address in the hosts network
      vm_config.vm.network 'private_network', ip: settings[:ip]

      vm_config.vm.hostname = settings[:hostname]

      config.vm.provider 'virtualbox' do |v|
        # make sure that the name makes sense when seen in the vbox GUI
        v.name = settings[:hostname]

        v.gui = false

        # Be nice to our users.
        # v.customize ['modifyvm', :id, '--cpuexecutioncap', '50']
        v.customize ['modifyvm', :id, '--memory', settings[:ram], '--cpus', settings[:cpu]]
        v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        v.customize ['modifyvm', :id, '--chipset', 'ich9']

        v.customize ['modifyvm', :id, '--ioapic', 'on'] # Bug 51473
        v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
        # Prevent clock drift, see http://stackoverflow.com/a/19492466/323407
        v.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 10_000]

        v.customize ['modifyvm', :id, '--audio', 'none']

        # v.customize ["modifyvm", :id, "--natdnshostresolver2", "on"]
      end

      hostname_with_hyenalab_tld = "#{settings[:hostname]}.hyenalab.home"

      aliases = [hostname_with_hyenalab_tld, settings[:hostname]]

      if Vagrant.has_plugin?('vagrant-hostsupdater')
        vm_config.hostsupdater.aliases = aliases
      elsif Vagrant.has_plugin?('vagrant-hostmanager')
        vm_config.hostmanager.enabled = true
        vm_config.hostmanager.manage_host = true
        vm_config.hostmanager.manage_guests = true
        vm_config.hostmanager.ignore_private_ip = false
        vm_config.hostmanager.include_offline = true
        vm_config.hostmanager.aliases = aliases
      end

      # TODO: Get rid of /etc/hosts bash script command
      vm_config.vm.provision 'shell' do |s|
        s.inline = <<-SHELL
              if [ -f /vagrant_bootstrap ]; then
                echo "vagrant_bootstrap EXISTS ALREADY"
                exit 0
              fi
              sudo apt-get -y update
              sudo apt-get -y install python-minimal python-apt
              HOSTNAME=`hostname`; sudo sed -ri \"/127\.0\.0\.1.*$HOSTNAME.*/d\" /etc/hosts
              cat /etc/hosts
              DEBIAN_FRONTEND=noninteractive apt-get update; apt-get install -y \
              sudo \
              bash-completion \
              curl \
              git \
              vim \
            ; \
                  apt-get update \
            ; \
              DEBIAN_FRONTEND=noninteractive apt-get install -y python-six python-pip \
            ; \
            touch /vagrant_bootstrap && \
            chown #{NON_ROOT_USER}:#{NON_ROOT_USER} /vagrant_bootstrap
            SHELL
        s.privileged = true
      end # end - vm_config.vm.provision 'shell' do |s|

      # vm_config.vm.provision :ansible do |ansible|
      #   ansible.host_key_checking	= 'false'
      #   # Disable default limit to connect to all the machines
      #   ansible.limit = 'all'
      #   ansible.playbook = 'vagrant_playbook.yml'
      #   ansible.groups = config_yml[:groups]
      #   ansible.verbose = 'vvv'
      #   ansible.extra_vars = {
      #     deploy_env: 'vagrant'
      #   }
      #   # ansible.skip_tags = %w[bootstrap]
      #   ansible.raw_arguments = ['--forks=10']
      # end
    end
  end
end
