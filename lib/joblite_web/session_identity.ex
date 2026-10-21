defmodule JobliteWeb.SessionIdentity do
  @moduledoc """
  Resolves the signed-in account and re-resolves it for sensitive events.

  The LiveView mount receives the browser session. The session token itself
  stays on the server: it is kept in the private part of the socket and is
  never assigned, so it never reaches the client. A sensitive event
  re-resolves the token through `Joblite.Accounts`, so a revoked or expired
  session cannot act on the account it used to own.
  """
  alias Joblite.Accounts
  alias Joblite.Accounts.User
  alias Phoenix.Component
  alias Phoenix.LiveView.Socket

  @token_key :joblite_session_token

  @doc """
  Keeps the session token on the socket and assigns the account it belongs to.

  The account is assigned only when it is not assigned yet, so the
  authentication hook of the live session stays the single source of truth.
  """
  @spec attach(Socket.t(), map()) :: Socket.t()
  def attach(%Socket{} = socket, session) do
    token = session["user_token"]

    socket
    |> put_token(token)
    |> Component.assign_new(:current_user, fn -> resolve(token) end)
  end

  @doc "The account that owns the current session, or nil when there is none."
  @spec current_user(Socket.t()) :: User.t() | nil
  def current_user(%Socket{} = socket), do: resolve(token(socket))

  defp resolve(nil), do: nil
  defp resolve(token) when is_binary(token), do: Accounts.get_user_by_session_token(token)
  defp resolve(_token), do: nil

  defp put_token(socket, token) do
    %{socket | private: Map.put(socket.private, @token_key, token)}
  end

  defp token(%Socket{private: private}), do: Map.get(private, @token_key)
end
