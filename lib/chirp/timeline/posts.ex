defmodule Chirp.Timeline.Posts do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :likes_count, :integer, default: 0
    field :resposts_count, :integer, default: 0

    belongs_to :user, Chirp.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(posts, attrs) do
    posts
    |> cast(attrs, [:body, :likes_count, :resposts_count, :user_id])
    |> validate_required([:body, :user_id])
    |> validate_length(:body, min: 1, max: 250)
    |> foreign_key_constraint(:user_id)
  end
end
