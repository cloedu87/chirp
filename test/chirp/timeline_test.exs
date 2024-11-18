defmodule Chirp.TimelineTest do
  use Chirp.DataCase

  alias Chirp.Timeline

  describe "posts" do
    alias Chirp.Timeline.Posts

    import Chirp.TimelineFixtures

    @invalid_attrs %{body: nil, username: nil, likes_count: nil, resposts_count: nil}

    test "list_posts/0 returns all posts" do
      posts = posts_fixture()
      assert Timeline.list_posts() == [posts]
    end

    test "get_posts!/1 returns the posts with given id" do
      posts = posts_fixture()
      assert Timeline.get_posts!(posts.id) == posts
    end

    test "create_posts/1 with valid data creates a posts" do
      valid_attrs = %{body: "some body", username: "some username", likes_count: 42, resposts_count: 42}

      assert {:ok, %Posts{} = posts} = Timeline.create_posts(valid_attrs)
      assert posts.body == "some body"
      assert posts.username == "some username"
      assert posts.likes_count == 42
      assert posts.resposts_count == 42
    end

    test "create_posts/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_posts(@invalid_attrs)
    end

    test "update_posts/2 with valid data updates the posts" do
      posts = posts_fixture()
      update_attrs = %{body: "some updated body", username: "some updated username", likes_count: 43, resposts_count: 43}

      assert {:ok, %Posts{} = posts} = Timeline.update_posts(posts, update_attrs)
      assert posts.body == "some updated body"
      assert posts.username == "some updated username"
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
  end
end
