defmodule JobliteWeb.ExploreLive.Components.BoardCard do
  @moduledoc """
  One board of the job board directory.

  The card states what Joblite knows about the board: where it covers, how it
  may be used and when that was last checked. A board is always an outbound
  link; the card never presents imported listings as Joblite's own postings.
  Coverage that the board never confirmed is shown as pending review instead of
  being filled in.
  """
  use Phoenix.Component

  attr(:board, :map, required: true)
  attr(:saved, :boolean, default: false)
  attr(:dismissed, :boolean, default: false)
  attr(:id_prefix, :string, default: "board")

  def board_card(assigns) do
    ~H"""
    <article class="jf-board" id={"#{@id_prefix}-#{@board.slug}"} data-board={@board.slug}>
      <header class="jf-board-head">
        <div class="jf-board-title">
          <h2>{@board.name}</h2>
          <p class="jf-board-host">{@board.url}</p>
        </div>
        <span class={["jf-board-mode", @board.status_tone]}>{@board.mode_label}</span>
      </header>

      <p class="jf-board-note">{@board.mode_note}</p>

      <dl class="jf-board-facts">
        <div>
          <dt>Coverage</dt>
          <dd>{@board.coverage_label}</dd>
        </div>
        <div>
          <dt>Remote</dt>
          <dd>{@board.remote_label}</dd>
        </div>
        <div>
          <dt>Access</dt>
          <dd>{@board.access_label}</dd>
        </div>
        <div>
          <dt>Freshness</dt>
          <dd>{@board.freshness_label}</dd>
        </div>
        <div>
          <dt>Synchronization</dt>
          <dd>{@board.sync_label}</dd>
        </div>
        <div>
          <dt>Checked</dt>
          <dd>{@board.last_verified_label}</dd>
        </div>
      </dl>

      <div class="jf-board-coverage">
        <div :if={@board.region_labels != []} class="jf-board-tags">
          <span class="jf-board-tag jf-board-tag-key">Regions</span>
          <span :for={label <- @board.region_labels} class="jf-board-tag">{label}</span>
        </div>
        <p class="jf-board-line" id={"#{@id_prefix}-#{@board.slug}-countries"}>
          <span class="jf-board-key">Countries</span> {@board.countries_summary}
        </p>
        <p class="jf-board-line" id={"#{@id_prefix}-#{@board.slug}-categories"}>
          <span class="jf-board-key">Categories</span> {@board.categories_summary}
        </p>
      </div>

      <p :if={@board.attribution_text} class="jf-board-terms">Terms: {@board.attribution_text}</p>
      <p :if={@board.status_note} class="jf-board-status">{@board.status_note}</p>
      <p :if={@board.last_error} class="jf-board-error">Last import error: {@board.last_error}</p>

      <div class="jf-board-actions">
        <a class="jf-board-open" href={@board.url} target="_blank" rel="noopener noreferrer">
          Open board<span class="jf-sr-only"> (opens in a new tab)</span>
        </a>
        <button
          :if={@dismissed}
          type="button"
          phx-click="boards:revisit"
          phx-value-id={@board.id}
        >Bring back</button>
        <button
          :if={@saved and not @dismissed}
          type="button"
          phx-click="boards:unsave"
          phx-value-id={@board.id}
        >Saved · remove</button>
        <button
          :if={!@saved and not @dismissed}
          type="button"
          phx-click="boards:save"
          phx-value-id={@board.id}
        >Save board</button>
      </div>
    </article>
    """
  end
end
