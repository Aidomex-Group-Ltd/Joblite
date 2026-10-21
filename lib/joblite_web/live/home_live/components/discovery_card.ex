defmodule JobliteWeb.HomeLive.Components.DiscoveryCard do
  @moduledoc """
  One job board discovery card in the feed.

  The card is labelled directory content: it names a board Joblite knows and
  states the status of its integration. It never looks like a post and never
  presents an imported listing as a Joblite posting. A listing that was
  imported from a board whose terms allow it links to the original listing, so
  the reader always reaches the source.
  """
  use Phoenix.Component
  import JobliteWeb.HomeLive.Components.Icons

  attr(:card, :map, required: true)
  attr(:signed_in, :boolean, default: false)

  def discovery_card(assigns) do
    ~H"""
    <aside id="discovery-card" class="jf-discovery" data-board={@card.slug}>
      <p class="jf-discovery-label"><.icon name="compass" /> Job board directory</p>
      <div class="jf-discovery-head">
        <h2>{@card.name}</h2>
        <span class={["jf-board-mode", @card.status_tone]}>{@card.mode_label}</span>
      </div>
      <p class="jf-discovery-text">{@card.mode_note}</p>

      <dl class="jf-discovery-facts">
        <div>
          <dt>Remote</dt>
          <dd>{@card.remote_label}</dd>
        </div>
        <div>
          <dt>Coverage</dt>
          <dd>{@card.coverage_label}</dd>
        </div>
      </dl>

      <p :if={@card.listing} class="jf-discovery-listing">
        Latest listing:
        <a href={@card.listing.canonical_url} target="_blank" rel="noopener noreferrer">
          {@card.listing.title}<span class="jf-sr-only"> (opens in a new tab)</span>
        </a>
        · {@card.listing.attribution}
      </p>

      <div class="jf-discovery-actions">
        <a class="jf-board-open" href={@card.url} target="_blank" rel="noopener noreferrer">
          Open board<span class="jf-sr-only"> (opens in a new tab)</span>
        </a>
        <button
          :if={@signed_in}
          type="button"
          phx-click="boards:save"
          phx-value-id={@card.id}
        >Save</button>
        <a :if={!@signed_in} class="jf-discovery-login" href="/users/log-in">Log in to save</a>
        <button type="button" phx-click="boards:dismiss" phx-value-id={@card.id}>Not interested</button>
      </div>
    </aside>
    """
  end
end
