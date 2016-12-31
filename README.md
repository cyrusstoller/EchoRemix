# EchoRemix

Thank you for participating in this experiment.
EchoRemix is a project that facilitates anonymous one-on-one
text-conversations about controversial political topics.

I'm sharing this code so that you can have confidence that
the messages being sent are not being stored on the server.

## Contributing

### Bugs / Issues

If you find a bug or something that could improve the user experience, please file an issue on this github project, so
contributors/maintainers can get started fixing them. :-)

### Submitting Pull Requests

- Fork this project
- Make a feature branch git checkout -b feature
- Make your changes and commit them to your feature branch
- Submit a pull request

## Getting started with development

Be sure to have Ruby 2.3.1, Postgresql, and Redis installed on a Mac or Linux machine.

```bash
$ cp .env.example .env
$ bundle install
$ rake db:create
$ rake db:migrate
$ rails s
```

## Deploying EchoRemix

The server has been setup using the Puppet manifests found at https://github.com/cyrusstoller/gardenbed

Then if you're going to leave SSL enabled, be sure to install an SSL certificate using
[LetsEncrypt](https://letsencrypt.org/). You can find instructions [here](https://certbot.eff.org/).

Once the server has been provisioned, be sure to change the `server`
and `ssl_cert_domain` in `config/deploy/production.rb`.

Create `lib/capistrano/templates/env.production` with the appropriate environment variables,
then run the following commands.

```bash
$ cap production setup
$ cap production deploy
```
