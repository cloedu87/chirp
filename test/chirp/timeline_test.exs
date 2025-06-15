defmodule Chirp.TimelineTest do
  use Chirp.DataCase

  alias Chirp.Timeline

  describe "posts" do
    alias Chirp.Timeline.Posts

    import Chirp.TimelineFixtures
    import Chirp.AccountsFixtures

    @invalid_attrs %{body: nil, user_id: nil, likes_count: nil, resposts_count: nil}

    test "list_posts/0 returns all posts" do
      posts = posts_fixture()
      assert Timeline.list_posts() == [posts]
    end

    test "get_posts!/1 returns the posts with given id" do
      posts = posts_fixture()
      assert Timeline.get_posts!(posts.id) == posts
    end

    test "create_posts/1 with valid data creates a posts" do
      user = user_fixture()
      valid_attrs = %{body: "some body", user_id: user.id, likes_count: 42, resposts_count: 42}

      assert {:ok, %Posts{} = posts} = Timeline.create_posts(valid_attrs)
      assert posts.body == "some body"
      assert posts.user_id == user.id
      assert posts.likes_count == 42
      assert posts.resposts_count == 42
    end

    test "create_posts/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_posts(@invalid_attrs)
    end

    test "update_posts/2 with valid data updates the posts" do
      posts = posts_fixture()
      user = user_fixture()

      update_attrs = %{
        body: "some updated body",
        user_id: user.id,
        likes_count: 43,
        resposts_count: 43
      }

      assert {:ok, %Posts{} = posts} = Timeline.update_posts(posts, update_attrs)
      assert posts.body == "some updated body"
      assert posts.user_id == user.id
      assert posts.likes_count == 43
      assert posts.resposts_count == 43
    end

    test "update_posts/2 with invalid data returns error changeset" do
      posts = posts_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_posts(posts, @invalid_attrs)
      assert posts == Timeline.get_posts!(posts.id)
    end

    test "delete_posts/1 deletes the posts" do
      posts = posts_fixture()
      assert {:ok, %Posts{}} = Timeline.delete_posts(posts)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_posts!(posts.id) end
    end

    test "change_posts/1 returns a posts changeset" do
      posts = posts_fixture()
      assert %Ecto.Changeset{} = Timeline.change_posts(posts)
    end

    test "user_owns_post?/2 returns true when user owns the post" do
      posts = posts_fixture()
      assert Timeline.user_owns_post?(posts.user, posts) == true
    end

    test "user_owns_post?/2 returns false when user doesn't own the post" do
      posts = posts_fixture()
      other_user = user_fixture(email: "other@example.com")
      assert Timeline.user_owns_post?(other_user, posts) == false
    end

    test "get_user_post!/2 returns the post when user owns it" do
      posts = posts_fixture()
      assert Timeline.get_user_post!(posts.user, posts.id) == posts
    end

    test "get_user_post!/2 raises error when user doesn't own the post" do
      posts = posts_fixture()
      other_user = user_fixture(email: "other@example.com")

      assert_raise Ecto.NoResultsError, fn ->
        Timeline.get_user_post!(other_user, posts.id)
      end
    end

    test "update_user_post/3 updates the post when user owns it" do
      posts = posts_fixture()
      update_attrs = %{body: "updated by owner"}

      assert {:ok, %Posts{} = updated_posts} =
               Timeline.update_user_post(posts.user, posts, update_attrs)

      assert updated_posts.body == "updated by owner"
    end

    test "update_user_post/3 returns unauthorized error when user doesn't own the post" do
      posts = posts_fixture()
      other_user = user_fixture(email: "other@example.com")
      update_attrs = %{body: "attempted update"}

      assert Timeline.update_user_post(other_user, posts, update_attrs) == {:error, :unauthorized}
    end

    test "delete_user_post/2 deletes the post when user owns it" do
      posts = posts_fixture()

      assert {:ok, %Posts{}} = Timeline.delete_user_post(posts.user, posts)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_posts!(posts.id) end
    end

    test "delete_user_post/2 returns unauthorized error when user doesn't own the post" do
      posts = posts_fixture()
      other_user = user_fixture(email: "other@example.com")

      assert Timeline.delete_user_post(other_user, posts) == {:error, :unauthorized}
      # Post should still exist
      assert Timeline.get_posts!(posts.id) == posts
    end
  end
end
