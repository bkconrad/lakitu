# Lakitu
![CircleCI build status](https://circleci.com/gh/bkconrad/lakitu.png?style=shield&circle-token=a622a5a71cc7a5ad0662d05e164a67f8ddbdaff1)

Generate an SSH config from AWS (or potentially other cloud provider) APIs.

## Prework
To use Lakitu effectively, you will need the following:

  1. A modern Ruby (2.0+). You may need RVM for this.
  2. A modern `bash-completion` package installed via `brew`, `apt-get`, or `yum`.
  3. AWS profiles configured according to the [official documentation](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles) (or via `aws configure`).

If you don't have 1-3 above, you will not get the most out of this project (and you are missing out on some other really cool stuff).

## Usage
```
$ gem install lakitu
$ lakitu generate
$ lakitu configure
$ lakitu edit
```

## How It Works
Lakitu parses your AWS credentials file, and for each configured profile will pull a list of Public IP addresses. It will also try look for files in `~/.ssh/` matching the keypair listed for each instance, and if it exists will add the key to the generated config output. For example, if your instance has a keypair listed on the console as `acme-production`, and you have a local file at `~/.ssh/acme-production.pem`, Lakitu will configure that key to be used when connecting to the specified instance.

It's not possible for Lakitu to determine usernames or proxy commands to use when connecting to instances. To allow configuration of this and other SSH related things, lakitu looks for a `~/.ssh/local.sshconfig` file and prepends it to the generated ssh config. When first run, Lakitu will back up your old SSH config to this location. You can also edit this file via `lakitu edit`, which will then regenerate your primary config after editing.

A common `local.sshconfig` might include things like the following:
```
Host acme-*
  User ubuntu

Host enron-*
  ForwardAgent yes
  ProxyCommand nohup ssh ubuntu@gateway.enron.com nc %h %p
```

Which would then be prepended to the generated global SSH config.

## Periodic Refresh
Simply add the following line to your `.bashrc`
```
lakitu generate &>~/.lakitu.log &
```

If you installed lakitu via RVM, you should add the following to your shell profile instead:
```
rvm default do lakitu generate &>~/.lakitu.log &
```

`lakitu generate` waits for a refresh interval to pass before re-generating the SSH config. This means you can safely add it to your `.bashrc` or equivalent, and your ssh config will refresh in the background only when that interval has passed.

## Another One?
There are several projects that will generate an SSH config from AWS instance data. This one aims to provide the following advantages:

  - **Ease of use**: With a properly configured environment, it will detect your configured profiles for supported providers.
  - **Configurability**: Easily edit a simple config file to control host alias formatting, profiles to skip, etc.
  - **Automation**: Periodically refreshes the ssh config (via bashrc), and takes no action unless the config appears to be stale.
  - **Extensibility**: A simple Provider API allows easy support for new providers.
  - **Reliability**: A robust test suite ensures that Lakitu probably won't cause your machine to combust unexpectedly.

## Why do you have to clobber my SSH config?
One major goal of this project is to support `bash-completion` "out of the box". Unfortunately, most versions of SSH in use right now don't support the `Include` directive, and `bash-completion` will only look at the main ssh config. Changes have been prepared for when `Include` becomes more commonly supported which will simply add an Include directive and will put lakitu output into its own isolated file. However, this branch remains unmerged due to overwhelming lack of support for this directive.

It's important to note that lakitu has several checks to prevent clobbering or destroying an unmanaged ssh config. However, once lakitu is managing the config (`# Managed by lakitu` is found in the file) it will overwrite the file ruthlessly. For this reason, you should always make custom changes via the `laktiu edit` command, or by editing `local.sshconfig`.

## Other Options
You could also check out the folowing if this is too much hubbub for you:
  - https://rubygems.org/gems/knife-ec2-ssh-config
  - https://rubygems.org/gems/ec2-ssh
  - https://rubygems.org/gems/aws_ssh
  - https://rubygems.org/gems/aws-ssh
  - [An SSH tip for modern AWS patrons](http://codeinthehole.com/writing/an-ssh-tip-for-modern-aws-patrons/)