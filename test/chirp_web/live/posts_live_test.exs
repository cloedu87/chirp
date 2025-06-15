defmodule ChirpWeb.PostsLiveTest do
  use ChirpWeb.ConnCase

  import Phoenix.LiveViewTest
  import Chirp.TimelineFixtures

  @create_attrs %{body: "some body"}
  @update_attrs %{body: "some updated body"}
  @invalid_attrs %{body: nil}

  defp create_posts(%{user: user}) do
    posts = posts_fixture(%{user_id: user.id})
    %{posts: posts}
  end

  defp create_posts(_) do
    posts = posts_fixture()
    %{posts: posts}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_posts]

    test "lists all posts", %{conn: conn, posts: posts} do
      {:ok, _index_live, html} = live(conn, ~p"/posts")

      assert html =~ "Timeline"
      assert html =~ posts.body
    end

    test "saves new posts", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      assert index_live |> element("a", "New Posts") |> render_click() =~
               "New Posts"

      assert_patch(index_live, ~p"/posts/new")

      assert index_live
             |> form("#posts-form", posts: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#posts-form", posts: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/posts")

      html = render(index_live)
      assert html =~ "Posts created successfully"
      assert html =~ "some body"
    end

    test "updates posts in listing", %{conn: conn, posts: posts} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      # Click the edit icon (SVG) in the post component
      assert index_live
             |> element("#posts_collection-#{posts.id} a[href*='edit']")
             |> render_click() =~
               "Edit Posts"

      assert_patch(index_live, ~p"/posts/#{posts}/edit")

      assert index_live
             |> form("#posts-form", posts: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#posts-form", posts: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/posts")

      html = render(index_live)
      assert html =~ "Posts updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes posts in listing", %{conn: conn, posts: posts} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      # Click the delete link directly (no nested anchor)
      assert index_live |> element("#delete-#{posts.id}") |> render_click()

      # The post should be removed from the DOM
      refute has_element?(index_live, "#posts_collection-#{posts.id}")
    end

    test "cannot edit another user's post", %{conn: conn} do
      # Create a post by another user
      other_user = Chirp.AccountsFixtures.user_fixture(email: "other@example.com")
      other_posts = posts_fixture(%{user_id: other_user.id})

      {:ok, index_live, _html} = live(conn, ~p"/posts")

      # Should not see edit button for other user's post
      refute has_element?(index_live, "#posts_collection-#{other_posts.id} a[href*='edit']")
    end

    test "cannot delete another user's post", %{conn: conn} do
      # Create a post by another user
      other_user = Chirp.AccountsFixtures.user_fixture(email: "other@example.com")
      other_posts = posts_fixture(%{user_id: other_user.id})

      {:ok, index_live, _html} = live(conn, ~p"/posts")

      # Should not see delete button for other user's post
      refute has_element?(index_live, "#delete-#{other_posts.id}")
    end

    test "attempting to delete another user's post via direct event fails", %{conn: conn} do
      # Create a post by another user
      other_user = Chirp.AccountsFixtures.user_fixture(email: "other@example.com")
      other_posts = posts_fixture(%{user_id: other_user.id})

      {:ok, index_live, _html} = live(conn, ~p"/posts")

      # Try to delete another user's post directly by sending the event
      render_hook(index_live, "delete", %{"id" => other_posts.id})

      # The post should still be visible (not deleted)
      assert has_element?(index_live, "#posts_collection-#{other_posts.id}")
    end

    test "likes a post", %{conn: conn, posts: posts} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      # Click the like button
      index_live
      |> element("#posts_collection-#{posts.id} a[phx-click*='like']")
      |> render_click()

      # The post should still be visible
      assert has_element?(index_live, "#posts_collection-#{posts.id}")
    end

    test "reposts a post", %{conn: conn, posts: posts} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      # Click the repost button
      index_live
      |> element("#posts_collection-#{posts.id} a[phx-click*='respost']")
      |> render_click()

      # The post should still be visible
      assert has_element?(index_live, "#posts_collection-#{posts.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_posts]

    test "displays posts", %{conn: conn, posts: posts} do
      {:ok, _show_live, html} = live(conn, ~p"/posts/#{posts}")

      assert html =~ "Posts #{posts.id}"
      assert html =~ posts.body
    end

    test "updates posts within modal", %{conn: conn, posts: posts} do
      {:ok, show_live, _html} = live(conn, ~p"/posts/#{posts}")

      assert show_live |> element("a", "Edit posts") |> render_click() =~
               "Edit Posts"

      assert_patch(show_live, ~p"/posts/#{posts}/show/edit")

      assert show_live
             |> form("#posts-form", posts: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#posts-form", posts: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/posts/#{posts}")

      html = render(show_live)
      assert html =~ "Posts updated successfully"
      assert html =~ "some updated body"
    end

    test "cannot see edit button for another user's post", %{conn: conn} do
      # Create a post by another user
      other_user = Chirp.AccountsFixtures.user_fixture(email: "other@example.com")
      other_posts = posts_fixture(%{user_id: other_user.id})

      {:ok, show_live, _html} = live(conn, ~p"/posts/#{other_posts}")

      # Should not see edit button for other user's post
      refute has_element?(show_live, "a", "Edit posts")
    end

    test "cannot access edit page for another user's post", %{conn: conn} do
      # Create a post by another user
      other_user = Chirp.AccountsFixtures.user_fixture(email: "other@example.com")
      other_posts = posts_fixture(%{user_id: other_user.id})

      # Trying to access edit page should raise an error
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/posts/#{other_posts}/show/edit")
      end
    end
  end
end
