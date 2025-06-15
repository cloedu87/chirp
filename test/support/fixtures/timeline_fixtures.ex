defmodule Chirp.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chirp.Timeline` context.
  """

  import Chirp.AccountsFixtures

  @doc """
  Generate a posts.
  """
  def posts_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, posts} =
      attrs
      |> Enum.into(%{
        body: "some body",
        likes_count: 42,
        resposts_count: 42,
        user_id: user.id
      })
      |> Chirp.Timeline.create_posts()

    # Preload the user association to match how Timeline.list_posts/0 works
    Chirp.Repo.preload(posts, [:user])
  end
end
