defmodule Chirp.Timeline.Posts do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :username, :string, default: "anonymous"
    field :likes_count, :integer, default: 0
    field :resposts_count, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(posts, attrs) do
    posts
    |> cast(attrs, [:username, :body, :likes_count, :resposts_count])
    |> validate_required([:username, :body])
    |> validate_length(:body, min: 1, max: 250)
  end
end
