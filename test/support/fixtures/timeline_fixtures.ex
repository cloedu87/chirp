defmodule Chirp.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chirp.Timeline` context.
  """

  @doc """
  Generate a posts.
  """
  def posts_fixture(attrs \\ %{}) do
    {:ok, posts} =
      attrs
      |> Enum.into(%{
        body: "some body",
        likes_count: 42,
        resposts_count: 42,
        username: "some username"
      })
      |> Chirp.Timeline.create_posts()

    posts
  end
end
