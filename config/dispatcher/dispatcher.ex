defmodule Dispatcher do
  use Matcher

  define_accept_types [
    json: [ "application/json", "application/vnd.api+json" ],
    html: [ "text/html", "application/xhtml+html" ],
    sparql: [ "application/sparql-results+json" ],
    any: [ "*/*" ]
  ]

  define_layers [ :static, :sparql, :api_services, :frontend_fallback, :resources, :not_found ]

  options "/*path", _ do
    conn
    |> Plug.Conn.put_resp_header( "access-control-allow-headers", "content-type,accept" )
    |> Plug.Conn.put_resp_header( "access-control-allow-methods", "*" )
    |> send_resp( 200, "{ \"message\": \"ok\" }" )
  end

  ###############
  # STATIC
  ###############

  # self-service
  match "/index.html", %{ layer: :static } do
    forward conn, [], "http://frontend/index.html"
  end

  get "/assets/*path",  %{ layer: :static } do
    forward conn, path, "http://frontend/assets/"
  end

  get "/@appuniversum/*path", %{ layer: :static } do
    forward conn, path, "http://frontend/@appuniversum/"
  end

  ###############
  # SPARQL
  ###############
  match "/sparql", %{ layer: :sparql, accept: %{ sparql: true } } do
    forward conn, [], "http://database:8890/sparql"
  end


  #################
  # FRONTEND PAGES
  #################

  # self-service
  match "/*path", %{ layer: :frontend_fallback, accept: %{ html: true } } do
    # we don't forward the path, because the app should take care of this in the browser.
    forward conn, [], "http://frontend/index.html"
  end

  # match "/favicon.ico", @any do
  #   send_resp( conn, 404, "" )
  # end

  ###############
  # RESOURCES
  ###############

  match "/remote-data-objects/*path", %{ layer: :resources, accept: %{ json: true } } do
    Proxy.forward conn, path, "http://cache/remote-data-objects/"
  end

  match "/harvesting-collections/*path", %{ layer: :resources, accept: %{ json: true } } do
    Proxy.forward conn, path, "http://cache/harvesting-collections/"
  end

  match "/jobs/*path", %{ layer: :resources, accept: %{ json: true } } do
    Proxy.forward conn, path, "http://cache/jobs/"
  end

  match "/tasks/*path", %{ layer: :resources, accept: %{ json: true } } do
    Proxy.forward conn, path, "http://cache/tasks/"
  end

  match "/data-containers/*path", %{ layer: :resources, accept: %{ json: true } } do
    Proxy.forward conn, path, "http://cache/data-containers/"
  end

  match "/job-errors/*path", %{ layer: :resources, accept: %{ json: true } } do
    Proxy.forward conn, path, "http://cache/job-errors/"
  end

  get "/files/:id/download" do
    Proxy.forward conn, [], "http://file/files/" <> id <> "/download"
  end

  match "/files/*path" do
    Proxy.forward conn, path, "http://cache/files/"
  end

  #################################################################
  # lblod-harvester besluiten sync
  #################################################################
  get "/sync/besluiten/files/*path" do
    Proxy.forward conn, path, "http://delta-producer-json-diff-file-publisher-besluiten/files/"
  end

  #################
  # NOT FOUND
  #################
  match "/*_path", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end

end
