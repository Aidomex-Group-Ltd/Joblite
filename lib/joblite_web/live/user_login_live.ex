defmodule JobliteWeb.UserLoginLive do
  @moduledoc "Login page. The form posts to `SessionController.create/2`; this LiveView only renders state and flash."
  use Phoenix.LiveView, layout: {JobliteWeb.Layouts, :app}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Log in")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main id="main" class="container">
      <h1>Log in</h1>
      <form action="/users/log-in" method="post">
        <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
        <p>
          <label for="user_email">Email</label>
          <input id="user_email" name="user[email]" type="email" autocomplete="email" required />
        </p>
        <p>
          <label for="user_password">Password</label>
          <input
            id="user_password"
            name="user[password]"
            type="password"
            autocomplete="current-password"
            required
          />
        </p>
        <p><button type="submit">Log in</button></p>
      </form>
    </main>
    """
  end
end
