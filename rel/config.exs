~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"40cKqMK&a@2Gt?xk?bHO1,OE;.O(PGy5=]ReMSPb!WnF(M_NQT8M}8GX&_@2o|~C"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"}zV>l8Kz_BdCPadQS|`{)H>)yW]lvx9qjxjZ:1Y[j$D@UZ/{u(&4GPg)ZD25MJ_F"
end

environment :docker do
  set include_erts: true
  set include_src: false
  set cookie: :"}zV>l8Kz_BdCPadQS|`{)H>)yW]lvx9qjxjZ:1Y[j$D@UZ/{u(&4GPg)ZD25MJ_F"
end

release :shortler do
  set version: current_version(:shortler)
  set applications: [
    :logger,
    :runtime_tools,
    shortler: :permanent
  ]
  set commands: [
    migrate: "rel/commands/migrate.sh"
  ]
end
