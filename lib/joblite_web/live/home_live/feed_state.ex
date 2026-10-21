defmodule JobliteWeb.HomeLive.FeedState do
  @moduledoc "Bounded presentation state; this module is not a durable Feed context."
  alias JobliteWeb.HomeLive.FeedCatalog

  defstruct posts: [],
            page: "feed",
            tab: "foryou",
            liked: MapSet.new(),
            saved: MapSet.new(),
            notice: nil,
            show_about: false

  @spec new() :: %__MODULE__{}
  def new, do: %__MODULE__{posts: FeedCatalog.posts()}

  @spec visible_posts(%__MODULE__{}) :: [map()]
  def visible_posts(state) do
    Enum.filter(state.posts, fn post ->
      case {state.page, state.tab} do
        {"saved", _} -> MapSet.member?(state.saved, post.id)
        {"mine", _} -> post.mine
        {_, "following"} -> post.following
        {_, "hiring"} -> not is_nil(post.role)
        _ -> true
      end
    end)
  end

  @doc """
  The feed stream: the visible posts with the discovery card placed among them.

  The card takes the place after the last employer post, so it arrives among
  the candidate posts instead of opening or closing the feed.
  """
  @spec stream(%__MODULE__{}, map() | nil) :: [tuple()]
  def stream(state, discovery) do
    items = Enum.map(visible_posts(state), &{:post, &1})

    case discovery do
      nil -> items
      card -> List.insert_at(items, discovery_index(items), {:discovery, card})
    end
  end

  @doc "The place the discovery card takes in a list of stream items."
  @spec discovery_index([tuple()]) :: non_neg_integer()
  def discovery_index(items) do
    case items |> Enum.reverse() |> Enum.find_index(&employer_post?/1) do
      nil -> 0
      from_end -> length(items) - from_end
    end
  end

  defp employer_post?({:post, %{role: role}}), do: not is_nil(role)
  defp employer_post?(_item), do: false

  @spec select_page(%__MODULE__{}, term()) :: {:ok, %__MODULE__{}} | {:error, String.t()}
  def select_page(state, page) when page in ~w(feed saved mine),
    do: {:ok, %{state | page: page, notice: nil}}

  def select_page(_state, _page), do: {:error, "Choose a page from the navigation."}

  @spec select_tab(%__MODULE__{}, term()) :: {:ok, %__MODULE__{}} | {:error, String.t()}
  def select_tab(state, tab) when tab in ~w(foryou following hiring),
    do: {:ok, %{state | page: "feed", tab: tab, notice: nil}}

  def select_tab(_state, _tab), do: {:error, "Choose a feed tab."}

  @spec toggle(%__MODULE__{}, :liked | :saved, term()) ::
          {:ok, %__MODULE__{}} | {:error, String.t()}
  def toggle(state, field, id) when field in [:liked, :saved] do
    if Enum.any?(state.posts, &(&1.id == id)) do
      selected = Map.fetch!(state, field)

      selected =
        if MapSet.member?(selected, id),
          do: MapSet.delete(selected, id),
          else: MapSet.put(selected, id)

      {:ok, Map.put(state, field, selected)}
    else
      {:error, "This post is no longer available."}
    end
  end

  @doc "Adds a preview post. Limits this LiveView to twenty temporary posts."
  @spec prepend(%__MODULE__{}, map()) :: {:ok, %__MODULE__{}} | {:error, String.t()}
  def prepend(state, attrs) do
    if Enum.count(state.posts, & &1.mine) >= 20 do
      {:error, "This preview is limited to 20 posts. Refresh to start a new session."}
    else
      post = %{
        id: "preview-#{System.unique_integer([:positive])}",
        author: "You",
        handle: "@you",
        initial: "Y",
        tone: "you",
        time: "Now",
        mine: true,
        following: true,
        role: nil,
        body: attrs.body,
        media: attrs.media
      }

      {:ok,
       %{
         state
         | posts: [post | state.posts],
           page: "feed",
           tab: "foryou",
           notice: "Added to this preview session. No public post or media upload was created."
       }}
    end
  end
end
