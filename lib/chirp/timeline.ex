defmodule Chirp.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Chirp.Repo

  alias Chirp.Timeline.Posts

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Posts{}, ...]

  """
  def list_posts do
    Repo.all(
      from p in Posts,
        order_by: [desc: p.id],
        preload: [:user]
    )
  end

  @doc """
  Gets a single posts.

  Raises `Ecto.NoResultsError` if the Posts does not exist.

  ## Examples

      iex> get_posts!(123)
      %Posts{}

      iex> get_posts!(456)
      ** (Ecto.NoResultsError)

  """
  def get_posts!(id) do
    Repo.get!(Posts, id) |> Repo.preload([:user])
  end

  @doc """
  Creates a posts.

  ## Examples

      iex> create_posts(%{field: value})
      {:ok, %Posts{}}

      iex> create_posts(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_posts(attrs \\ %{}) do
    %Posts{}
    |> Posts.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:post_created)
  end

  @doc """
  Updates a posts.

  ## Examples

      iex> update_posts(posts, %{field: new_value})
      {:ok, %Posts{}}

      iex> update_posts(posts, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_posts(%Posts{} = posts, attrs) do
    posts
    |> Posts.changeset(attrs)
    |> Repo.update()
    |> broadcast(:post_updated)
  end

  @doc """
  Deletes a posts.

  ## Examples

      iex> delete_posts(posts)
      {:ok, %Posts{}}

      iex> delete_posts(posts)
      {:error, %Ecto.Changeset{}}

  """
  def delete_posts(%Posts{} = posts) do
    Repo.delete(posts)
    |> broadcast(:post_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking posts changes.

  ## Examples

      iex> change_posts(posts)
      %Ecto.Changeset{data: %Posts{}}

  """
  def change_posts(%Posts{} = posts, attrs \\ %{}) do
    Posts.changeset(posts, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Chirp.PubSub, "posts")
  end

  def broadcast({:error, _reason} = error, _event), do: error

  def broadcast({:ok, post}, event) do
    # Preload user association before broadcasting
    post_with_user = Repo.preload(post, [:user])
    Phoenix.PubSub.broadcast(Chirp.PubSub, "posts", {event, post_with_user})
    {:ok, post}
  end

  def increment_likes_count(%Posts{} = posts) do
    posts
    |> update_posts(%{likes_count: posts.likes_count + 1})
  end

  def increment_resposts_count(%Posts{} = posts) do
    posts
    |> update_posts(%{resposts_count: posts.resposts_count + 1})
  end

  @doc """
  Checks if a user owns a specific post.

  ## Examples

      iex> user_owns_post?(user, post)
      true

      iex> user_owns_post?(other_user, post)
      false

  """
  def user_owns_post?(%Chirp.Accounts.User{id: user_id}, %Posts{user_id: post_user_id}) do
    user_id == post_user_id
  end

  @doc """
  Gets a post if the user owns it, otherwise returns an error.

  ## Examples

      iex> get_user_post!(user, post_id)
      %Posts{}

      iex> get_user_post!(other_user, post_id)
      ** (Ecto.NoResultsError)

  """
  def get_user_post!(%Chirp.Accounts.User{} = user, id) do
    post = get_posts!(id)

    if user_owns_post?(user, post) do
      post
    else
      raise Ecto.NoResultsError, queryable: Posts
    end
  end

  @doc """
  Updates a post if the user owns it.

  ## Examples

      iex> update_user_post(user, post, %{body: "new content"})
      {:ok, %Posts{}}

      iex> update_user_post(other_user, post, %{body: "new content"})
      {:error, :unauthorized}

  """
  def update_user_post(%Chirp.Accounts.User{} = user, %Posts{} = post, attrs) do
    if user_owns_post?(user, post) do
      update_posts(post, attrs)
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a post if the user owns it.

  ## Examples

      iex> delete_user_post(user, post)
      {:ok, %Posts{}}

      iex> delete_user_post(other_user, post)
      {:error, :unauthorized}

  """
  def delete_user_post(%Chirp.Accounts.User{} = user, %Posts{} = post) do
    if user_owns_post?(user, post) do
      delete_posts(post)
    else
      {:error, :unauthorized}
    end
  end
end
