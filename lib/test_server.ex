defmodule TestServer do
  require Logger

  import Supervisor.Spec

  defp port(), do: 3116

  def start(_type, _args) do
    options = [
      server_name: 'TestServer',
      server_root: '/tmp',
      document_root: '/tmp',
      port: port(),
      modules: [Endpoint],
      socket_type: {
        :ssl, [
          cacertfile: './cert/ca.crt',
          certfile: './cert/customer.crt',
          keyfile: './cert/customer.key',
          versions: [:"tlsv1.2"]
        ]
      }
    ]

    args = [:httpd, options]

    web_worker = worker(:inets, args, function: :start)

    children = [
      web_worker
    ]

    Logger.info("Starting server on port #{port()}")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
