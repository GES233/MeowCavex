defmodule MeowCaveWeb.PageController do
  use MeowCaveWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def about(conn, _params) do
    render(conn, :about, page_role: "About")
  end
end
