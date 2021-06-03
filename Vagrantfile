#
# Vagrant Scratchpad
#

default_box = "almalinux/8"

name = "docker-ce-builder"

Vagrant.configure("2") do |config|

    if Vagrant.has_plugin?("vagrant-vbguest")
      # Don't allow upgrades; the box has what it has.
      config.vbguest.auto_update = false
    end

    # Basic configuration

    config.vm.provider "virtualbox" do |vbox|
      # The default E1000 has a security vulerability.
      vbox.default_nic_type = "82543GC"
      vbox.cpus = 2
      vbox.memory = 2048
      config.vm.box = default_box
      config.vm.hostname = name
    end

    config.vm.provision "setup", type: "shell", run: "once", inline: <<-SHELL
      yum -y install epel-release
    SHELL

    #
    # User Account, Shared Folders and Local Storage
    #

    acct = Etc.getpwnam(Etc.getlogin)
    home_dir = "/home/#{acct.name}"

    config.vm.provision "account", type: "shell", run: "once", inline: <<-SHELL
      set -e

      mkdir -p '#{home_dir}'

      yum -y install '#{acct.shell}'

      useradd \
                --no-create-home \
                --comment '#{acct.gecos}' \
                --home-dir '#{home_dir}' \
                --shell '#{acct.shell}' \
                --uid '#{acct.uid}' \
                --gid '#{acct.gid}' \
                '#{acct.name}'

        # Local Storage
        install -d -D -o '#{acct.uid}' -g '#{acct.gid}' -m 770 '/local/#{acct.name}'

      # Grant frictionless sudo
      SUDOERS="/etc/sudoers.d/#{acct.name}"
      echo "#{acct.name} ${NEW_USER} ALL= (ALL) NOPASSWD:ALL" > "${SUDOERS}"
      chmod 440 "${SUDOERS}"

    SHELL

    config.vm.synced_folder "#{acct.dir}/", home_dir,
                            automount: false,
                            mount_options: ["uid=#{acct.uid}", "gid=#{acct.gid}"],
                            SharedFoldersEnableSymlinksCreate: true


    config.vm.provision "prep", type: "shell", run: "once", inline: <<-SHELL
      set -e
      /vagrant/system-prep
    SHELL



end


# -*- mode: ruby -*-
# vi: set ft=ruby :
