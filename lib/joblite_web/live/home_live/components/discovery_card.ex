defmodule JobliteWeb.HomeLive.Components.DiscoveryCard do
  @moduledoc """
  Joblite Discovery card in the feed.
  """
  use Phoenix.Component
  import JobliteWeb.HomeLive.Components.Icons

  attr(:card, :map, required: true)
  attr(:signed_in, :boolean, default: false)

  def discovery_card(assigns) do
    ~H"""
    <aside id="discovery-card" class="jf-discovery" data-board={@card.slug} aria-labelledby="discovery-card-title">
      <p class="jf-discovery-label"><.icon name="compass" /> Joblite Discovery</p>
      <h2 id="discovery-card-title" class="jf-discovery-title">{@card.name}</h2>
      <p class="jf-discovery-text">Explore job boards from around the world. Open a board to search for jobs directly on its website.</p>

      <div class="jf-discovery-actions">
        <a
          class="jf-discovery-open"
          href={@card.url}
          target="_blank"
          rel="noopener noreferrer"
          aria-label={"Open #{@card.name} in a new tab"}
        >
          Open board<span class="jf-sr-only"> (opens in a new tab)</span>
        </a>
        <button
          :if={@signed_in}
          type="button"
          phx-click="boards:save"
          phx-value-id={@card.id}
        >Save</button>
        <a :if={!@signed_in} class="jf-discovery-login" href="/users/log-in">Log in to save</a>
        <button type="button" phx-click="boards:dismiss" phx-value-id={@card.id}>Dismiss</button>
      </div>
    </aside>
    """
  end
end
