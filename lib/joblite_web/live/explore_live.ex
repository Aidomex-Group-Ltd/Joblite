defmodule JobliteWeb.ExploreLive do
  @moduledoc """
  The global job board directory.

  Every board Joblite knows is listed with the permission decision that decides
  how it may be used: a feed candidate whose listings may be imported, a
  directory only board that stays an outbound link, or a board whose written
  permission is still pending. A board is always an outbound link here, and an
  imported listing is never presented as a Joblite posting.

  The screen also holds the discovery preferences of the account. They rank the
  boards the feed promotes, so the reader chooses them once instead of on every
  visit.
  """
  use Phoenix.LiveView, layout: {JobliteWeb.Layouts, :app}

  alias Joblite.JobBoards
  alias JobliteWeb.ExploreLive.DirectoryFilters

  import JobliteWeb.ExploreLive.Components.BoardCard

  embed_templates("explore_live/render.html")

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]

    socket =
      socket
      |> assign(:page_title, "Explore boards")
      |> assign(:filters, DirectoryFilters.new())
      |> assign(:options, JobBoards.directory_options())
      |> assign(:saved_ids, saved_ids(user))
      |> assign(:notice, nil)

    {:ok, load_directory(socket)}
  end

  @impl true
  def handle_event("boards:filter", params, socket) do
    filters = DirectoryFilters.apply(socket.assigns.filters, params)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> load_directory()}
  end

  def handle_event("boards:save", %{"id" => id}, socket) do
    case socket.assigns[:current_user] do
      nil ->
        {:noreply, assign(socket, :notice, "Log in to save a board.")}

      user ->
        case JobBoards.save_board(user, id) do
          {:ok, _saved} ->
            {:noreply,
             socket
             |> assign(:saved_ids, MapSet.put(socket.assigns.saved_ids, id))
             |> assign(:notice, "Board saved.")}

          {:error, :unknown_source} ->
            {:noreply, assign(socket, :notice, "That board is no longer in the directory.")}
        end
    end
  end

  def handle_event("boards:unsave", %{"id" => id}, socket) do
    case socket.assigns[:current_user] do
      nil ->
        {:noreply, assign(socket, :notice, "Log in to change saved boards.")}

      user ->
        :ok = JobBoards.unsave_board(user, id)

        {:noreply,
         socket
         |> assign(:saved_ids, MapSet.delete(socket.assigns.saved_ids, id))
         |> assign(:notice, "Board removed.")}
    end
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  defp load_directory(socket) do
    filters = socket.assigns.filters

    assign_async(socket, :directory, fn ->
      case JobBoards.directory(DirectoryFilters.to_query(filters)) do
        {:ok, boards} -> {:ok, %{directory: boards}}
        {:error, reason} -> {:error, reason}
      end
    end)
  end

  defp saved_ids(nil), do: MapSet.new()

  defp saved_ids(user) do
    case JobBoards.saved_boards(user) do
      {:ok, boards} -> MapSet.new(boards, & &1.id)
      {:error, _reason} -> MapSet.new()
    end
  end


end
