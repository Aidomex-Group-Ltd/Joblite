defmodule JobliteWeb.HomeLive do
  @moduledoc "A modular candidate feed with explicit session-only preview state."
  use Phoenix.LiveView, layout: {JobliteWeb.Layouts, :app}

  alias JobliteWeb.HomeLive.{FeedState, PostForm}
  import JobliteWeb.HomeLive.Components.FeedShell
  import JobliteWeb.HomeLive.Components.FeedPost
  import JobliteWeb.HomeLive.Components.Composer
  import JobliteWeb.HomeLive.Components.MediaViewer

  embed_templates("home_live/render.html")

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, feed: FeedState.new(), architecture: Joblite.Health.architecture())}
  end

  @impl true
  def handle_event("feed:page", %{"page" => page}, socket) do
    change_feed(socket, FeedState.select_page(socket.assigns.feed, page))
  end

  def handle_event("feed:tab", %{"tab" => tab}, socket) do
    change_feed(socket, FeedState.select_tab(socket.assigns.feed, tab))
  end

  def handle_event("feed:like", %{"id" => id}, socket) do
    change_feed(socket, FeedState.toggle(socket.assigns.feed, :liked, id))
  end

  def handle_event("feed:save", %{"id" => id}, socket) do
    change_feed(socket, FeedState.toggle(socket.assigns.feed, :saved, id))
  end

  def handle_event("feed:preview-post", params, socket) do
    with {:ok, attrs} <- PostForm.parse(params),
         {:ok, feed} <- FeedState.prepend(socket.assigns.feed, attrs) do
      {:reply, %{ok: true}, assign(socket, :feed, feed)}
    else
      {:error, reason} -> {:reply, %{ok: false, error: reason}, socket}
    end
  end

  def handle_event("feed:about", _params, socket) do
    feed = %{socket.assigns.feed | show_about: not socket.assigns.feed.show_about}
    {:noreply, assign(socket, :feed, feed)}
  end

  def handle_event(_event, _params, socket) do
    {:noreply,
     assign(socket, :feed, %{socket.assigns.feed | notice: "That action is unavailable."})}
  end

  defp change_feed(socket, {:ok, feed}), do: {:noreply, assign(socket, :feed, feed)}

  defp change_feed(socket, {:error, message}) do
    {:noreply, assign(socket, :feed, %{socket.assigns.feed | notice: message})}
  end
end
