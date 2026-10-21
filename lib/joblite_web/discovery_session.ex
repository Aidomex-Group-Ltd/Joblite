defmodule JobliteWeb.DiscoverySession do
  @moduledoc """
  Counts the feed visits of one browser session.

  The count is the rotation offset of the feed discovery card, so a session
  that opens the feed again meets another board instead of the same one. The
  counter lives in the browser session and is never sent to the client as an
  assign.
  """
  import Plug.Conn

  @key "job_board_discovery_visit"

  @spec init(keyword()) :: keyword()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    put_session(conn, @key, visit(conn) + 1)
  end

  defp visit(conn) do
    case get_session(conn, @key) do
      count when is_integer(count) and count > 0 -> count
      _other -> 0
    end
  end
end
