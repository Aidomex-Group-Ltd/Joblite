defmodule JobliteWeb.HomeLiveTest do
  use JobliteWeb.ConnCase, async: true

  test "a connected LiveView renders core data and handles an event", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert html =~ "PostgreSQL"
    refute has_element?(view, "#boundary-explanation")
    view |> element("#architecture-details") |> render_click()
    assert has_element?(view, "#boundary-explanation")
  end

  test "health endpoints: liveness always answers, readiness reflects the database", %{conn: conn} do
    assert %{"status" => "up"} == conn |> get("/health/live") |> json_response(200)
    assert %{"status" => "ready"} == conn |> get("/health/ready") |> json_response(200)
  end
end
