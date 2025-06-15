defmodule ChirpWeb.UserRegistrationLiveTest do
  use ChirpWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Chirp.AccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Register"
      assert html =~ "Username"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{"username" => "ab", "email" => "with spaces", "password" => "too short"}
        )

      assert result =~ "Register"
      assert result =~ "should be at least 3 character"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 12 character"
    end

    test "renders errors for invalid username format", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "username" => "invalid-username!",
            "email" => "test@email.com",
            "password" => "valid_password123"
          }
        )

      assert result =~ "can only contain letters, numbers, and underscores"
    end

    test "renders errors for username starting with underscore", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "username" => "_invalid",
            "email" => "test@email.com",
            "password" => "valid_password123"
          }
        )

      assert result =~ "must start with a letter or number"
    end

    test "renders errors for username ending with underscore", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "username" => "invalid_",
            "email" => "test@email.com",
            "password" => "valid_password123"
          }
        )

      assert result =~ "must end with a letter or number"
    end
  end

  describe "register user" do
    test "creates account and logs the user in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      email = unique_user_email()
      username = unique_user_username()

      form =
        form(lv, "#registration_form",
          user: valid_user_attributes(email: email, username: username)
        )

      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ "Settings"
      assert response =~ "Log out"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture(%{email: "test@email.com", username: "testuser"})

      result =
        lv
        |> form("#registration_form",
          user: %{"username" => "newuser", "email" => user.email, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end

    test "renders errors for duplicated username", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture(%{email: "test@email.com", username: "testuser"})

      result =
        lv
        |> form("#registration_form",
          user: %{
            "username" => user.username,
            "email" => "newemail@test.com",
            "password" => "valid_password"
          }
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Log in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "Log in"
    end
  end
end
