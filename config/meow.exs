import Config

## Configure Ports.
config :meowcave_app, :default_ports,
  user_repo: MeowCave.Member,
  password_hash: MeowCave.Member.User.PassHash

## TODO: set enable to use email.

## TODO: set strategies to kick guests out.
