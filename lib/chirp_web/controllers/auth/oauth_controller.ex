defmodule ChirpWeb.Auth.OAuthController do
  use ChirpWeb, :controller
  plug Ueberauth

  alias Chirp.Accounts
  alias ChirpWeb.UserAuth

  def request(conn, _params) do
    # This function is automatically called by Ueberauth when initiating OAuth
    # It redirects to the OAuth provider
    conn
  end

  def callback(conn, _params) do
    # In test environment, both ueberauth_auth and ueberauth_failure can be present
    # We prioritize auth if it exists to allow proper testing
    cond do
      Map.has_key?(conn.assigns, :ueberauth_auth) && conn.assigns.ueberauth_auth ->
        auth = conn.assigns.ueberauth_auth
        user_params = extract_user_info(auth)

        case Accounts.find_or_create_oauth_user(user_params) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "Successfully authenticated.")
            |> UserAuth.log_in_user(user)

          {:error, _reason} ->
            conn
            |> put_flash(:error, "Something went wrong during authentication.")
            |> redirect(to: ~p"/users/log_in")
        end

      Map.has_key?(conn.assigns, :ueberauth_failure) ->
        conn
        |> put_flash(:error, "Failed to authenticate.")
        |> redirect(to: ~p"/users/log_in")

      true ->
        conn
        |> put_flash(:error, "Failed to authenticate.")
        |> redirect(to: ~p"/users/log_in")
    end
  end

  defp extract_user_info(%Ueberauth.Auth{} = auth) do
    %{
      email: auth.info.email,
      name: auth.info.name || auth.info.nickname,
      avatar_url: auth.info.image,
      provider: to_string(auth.provider),
      provider_id: to_string(auth.uid)
    }
  end
end
