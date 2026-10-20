defmodule JobliteWeb.HomeLive do
  @moduledoc "The first UI slice calls the backend through an ordinary Elixir function."
  use Phoenix.LiveView, layout: {JobliteWeb.Layouts, :app}
  embed_templates "home_live/*"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, architecture: Joblite.Health.architecture(), show_details: false)}
  end

  @impl true
  def handle_event("toggle-details", _params, socket) do
    {:noreply, assign(socket, :show_details, !socket.assigns.show_details)}
  end
end
