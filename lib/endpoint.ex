defmodule Endpoint do
  require Record
  require Jason
  require Logger
  require IO

  Record.defrecord(:httpd, Record.extract(:mod, from_lib: "inets/include/httpd.hrl"))

  def unquote(:do)(data) do
    log_request_details(data)
    response = route_request(data)
    {:proceed, [response: response]}
  end

  defp log_request_details(data) do
    method = httpd(data, :method)
    request_uri = httpd(data, :request_uri)
    request_body = httpd(data, :entity_body)

    IO.puts("#{method} #{request_uri}")
    IO.puts("#{request_body}")
  end

  defp route_request(data) do
    case httpd(data, :request_uri) do
      '/' -> handle_valid_request(data)
      '/error' -> handle_error_request(data)
      _ -> {404, 'Not found\n'}
    end
  end

  defp handle_valid_request(_data) do
    response_data = %{
      status: "success",
      message: "hi it's me, IER"
    }

    response_body =
      response_data
      |> Jason.encode!()
      |> to_charlist()

    {200, response_body ++ '\n'}
  end

  defp handle_error_request(_data) do
    {500, 'Internal server error\n'}
  end
end
