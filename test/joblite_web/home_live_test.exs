defmodule JobliteWeb.HomeLiveTest do
  use JobliteWeb.ConnCase, async: true

  test "initial feed renders thumbnails without video players", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert html =~ "Good work starts with good people"
    assert has_element?(view, "#post-nova")
    assert has_element?(view, "#post-amina")
    assert has_element?(view, "#post-jordan")
    assert has_element?(view, "#media-nova-0 img[src$='nova-poster.jpg']")
    refute has_element?(view, "#feed-posts video")
  end

  test "following and hiring tabs select the intended preview posts", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    view |> element("#tab-following") |> render_click()
    assert has_element?(view, "#post-amina")
    refute has_element?(view, "#post-nova")
    view |> element("#tab-hiring") |> render_click()
    assert has_element?(view, "#post-nova")
    refute has_element?(view, "#post-amina")
  end

  test "saved posts are reversible and do not cross visits", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    view |> element("#save-nova") |> render_click()
    view |> element("#nav-saved") |> render_click()
    assert has_element?(view, "#post-nova")
    refute has_element?(view, "#post-amina")
    view |> element("#save-nova") |> render_click()
    assert has_element?(view, "#feed-empty")
    {:ok, fresh, _html} = live(conn, "/")
    fresh |> element("#nav-saved") |> render_click()
    assert has_element?(fresh, "#feed-empty")
  end

  test "like events accept only known post ids and navigation values", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    view |> element("#like-nova") |> render_click()
    assert has_element?(view, "#like-nova[aria-pressed='true']")
    render_click(view, "feed:save", %{"id" => "unknown"})
    assert has_element?(view, "#feed-notice", "no longer available")
    render_click(view, "feed:page", %{"page" => "admin"})
    assert has_element?(view, "#feed-notice", "navigation")
    assert has_element?(view, "#post-nova")
  end

  test "preview text is escaped and visible in My posts", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    render_hook(view, "feed:preview-post", %{
      "body" => "A new project <script>alert(1)</script>",
      "media" => []
    })

    assert has_element?(view, "#feed-notice", "No public post")
    view |> element("#nav-mine") |> render_click()
    assert has_element?(view, ".jf-post-text", "A new project <script>alert(1)</script>")
    refute has_element?(view, "#feed-posts script")
    refute has_element?(view, "#post-nova")
  end

  test "valid local media references render placeholders without echoing submitted URLs",
       %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    media = %{
      "id" => "local-example-123",
      "kind" => "image",
      "type" => "image/jpeg",
      "name" => "work.jpg",
      "source" => "https://untrusted.invalid/picture"
    }

    html = render_hook(view, "feed:preview-post", %{"body" => "", "media" => [media]})
    assert has_element?(view, "img[data-local-thumbnail='local-example-123']")
    refute html =~ "untrusted.invalid"
  end

  test "empty and malformed preview posts do not add rows", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    render_hook(view, "feed:preview-post", %{"body" => " ", "media" => []})
    render_hook(view, "feed:preview-post", %{"body" => %{}, "media" => []})
    view |> element("#nav-mine") |> render_click()
    assert has_element?(view, "#feed-empty")
  end

  test "core boundary disclosure still works", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    view |> element("#architecture-details") |> render_click()
    assert has_element?(view, "#boundary-explanation", "PostgreSQL")
  end

  test "health endpoints: liveness always answers, readiness reflects the database", %{conn: conn} do
    assert %{"status" => "up"} == conn |> get("/health/live") |> json_response(200)
    assert %{"status" => "ready"} == conn |> get("/health/ready") |> json_response(200)
  end
end
