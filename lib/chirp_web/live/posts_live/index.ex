defmodule ChirpWeb.PostsLive.Index do
  use ChirpWeb, :live_view

  alias Chirp.Timeline
  alias Chirp.Timeline.Posts

  # Add authentication requirement
  on_mount {ChirpWeb.UserAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    {:ok, stream(socket, :posts_collection, Timeline.list_posts() |> Enum.reverse(), limit: 10)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    posts = Timeline.get_user_post!(socket.assigns.current_user, id)

    socket
    |> assign(:page_title, "Edit Posts")
    |> assign(:posts, posts)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Posts")
    |> assign(:posts, %Posts{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Timeline")
    |> assign(:posts, nil)
  end

  @impl true
  def handle_info({ChirpWeb.PostsLive.FormComponent, {:saved, posts}}, socket) do
    {:noreply, stream_insert(socket, :posts_collection, posts)}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, stream_insert(socket, :posts_collection, post, at: 0)}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, stream_insert(socket, :posts_collection, post, at: -1)}
  end

  @impl true
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, stream_delete(socket, :posts_collection, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    posts = Timeline.get_posts!(id)

    case Timeline.delete_user_post(socket.assigns.current_user, posts) do
      {:ok, _} ->
        {:noreply, stream_delete(socket, :posts_collection, posts)}

      {:error, :unauthorized} ->
        {:noreply, put_flash(socket, :error, "You can only delete your own posts.")}
    end
  end

  @impl true
  def handle_event("like", %{"id" => id}, socket) do
    posts = Timeline.get_posts!(id)
    {:ok, _} = Timeline.increment_likes_count(posts)
    {:noreply, socket}
  end

  @impl true
  def handle_event("respost", %{"id" => id}, socket) do
    posts = Timeline.get_posts!(id)
    {:ok, _} = Timeline.increment_resposts_count(posts)
    {:noreply, socket}
  end
end
