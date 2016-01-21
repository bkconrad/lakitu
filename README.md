# Lakitu
![CircleCI build status](https://circleci.com/gh/bkconrad/lakitu.png?circle-token=a622a5a71cc7a5ad0662d05e164a67f8ddbdaff1)

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

## Other Options
You could also check out the folowing if this is too much hubbub for you:
  - https://rubygems.org/gems/knife-ec2-ssh-config
  - https://rubygems.org/gems/ec2-ssh
  - https://rubygems.org/gems/aws_ssh
  - https://rubygems.org/gems/aws-ssh
  - [An SSH tip for modern AWS patrons](http://codeinthehole.com/writing/an-ssh-tip-for-modern-aws-patrons/)