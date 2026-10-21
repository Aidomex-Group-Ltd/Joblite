defmodule JobliteWeb.ExploreLive.Components.BoardCard do
  @moduledoc """
  One board in the global job board directory.
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
        </div>
      </header>

      <p :if={@board.region_labels && @board.region_labels != []} class="jf-board-regions">
        <span :for={label <- @board.region_labels} class="jf-board-pill">{label}</span>
      </p>

      <div class="jf-board-actions">
        <a
          class="jf-board-open"
          href={@board.url}
          target="_blank"
          rel="noopener noreferrer"
          aria-label={"Open #{@board.name} in a new tab"}
        >
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
