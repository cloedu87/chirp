defmodule ChirpWeb.Auth.OAuthControllerTest do
  use ChirpWeb.ConnCase, async: true

  import Chirp.AccountsFixtures

  describe "GET /auth/:provider" do
    test "redirects to provider", %{conn: conn} do
      conn = get(conn, ~p"/auth/google")
      assert redirected_to(conn) =~ "accounts.google.com"
    end
  end

  describe "GET /auth/:provider/callback - success" do
    test "creates a new user and logs them in", %{conn: conn} do
      auth = %Ueberauth.Auth{
        provider: :google,
        uid: "123456",
        info: %Ueberauth.Auth.Info{
          email: "test@example.com",
          name: "Test User",
          image: "https://example.com/avatar.jpg"
        }
      }

      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get(~p"/auth/google/callback")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Successfully authenticated."

      # Verify user was created
      user = Chirp.Accounts.get_user_by_provider("google", "123456")
      assert user.email == "test@example.com"
      assert user.name == "Test User"
      assert user.avatar_url == "https://example.com/avatar.jpg"
    end

    test "logs in existing OAuth user", %{conn: conn} do
      existing_user = oauth_user_fixture()

      auth = %Ueberauth.Auth{
        provider: String.to_atom(existing_user.provider),
        uid: existing_user.provider_id,
        info: %Ueberauth.Auth.Info{
          email: existing_user.email,
          name: existing_user.name,
          image: existing_user.avatar_url
        }
      }

      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get(~p"/auth/#{existing_user.provider}/callback")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Successfully authenticated."
    end

    test "links OAuth account to existing user with same email", %{conn: conn} do
      existing_user = user_fixture()

      auth = %Ueberauth.Auth{
        provider: :github,
        uid: "789012",
        info: %Ueberauth.Auth.Info{
          email: existing_user.email,
          name: "Test User",
          image: "https://example.com/avatar.jpg"
        }
      }

      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get(~p"/auth/github/callback")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Successfully authenticated."

      # Verify the existing user was updated with OAuth info
      updated_user = Chirp.Accounts.get_user!(existing_user.id)
      assert updated_user.provider == "github"
      assert updated_user.provider_id == "789012"
    end
  end

  describe "GET /auth/:provider/callback - failure" do
    test "redirects to login with error on authentication failure", %{conn: conn} do
      conn =
        conn
        |> assign(:ueberauth_failure, %Ueberauth.Failure{})
        |> get(~p"/auth/google/callback")

      assert redirected_to(conn) == ~p"/users/log_in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Failed to authenticate."
    end

    test "redirects to login with error when user creation fails", %{conn: conn} do
      # Create auth with invalid email format to cause validation to fail
      auth = %Ueberauth.Auth{
        provider: :google,
        uid: "123456",
        info: %Ueberauth.Auth.Info{
          email: "invalid-email-format", # This will cause email validation to fail
          name: "Test User",
          image: nil
        }
      }

      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get(~p"/auth/google/callback")

      assert redirected_to(conn) == ~p"/users/log_in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Something went wrong during authentication."
    end
  end
end
