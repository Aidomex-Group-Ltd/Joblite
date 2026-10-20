defmodule JobliteWeb.HomeLiveTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint JobliteWeb.Endpoint

  test "a connected LiveView renders core data and handles an event" do
    {:ok, view, html} = live(build_conn(), "/")
    assert html =~ "PostgreSQL"
    refute has_element?(view, "#boundary-explanation")
    view |> element("#architecture-details") |> render_click()
    assert has_element?(view, "#boundary-explanation")
  end
end
