defmodule ChirpWeb.PostsLive.Index do
  use ChirpWeb, :live_view

  alias Chirp.Timeline
  alias Chirp.Timeline.Posts

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
    socket
    |> assign(:page_title, "Edit Posts")
    |> assign(:posts, Timeline.get_posts!(id))
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
    {:ok, _} = Timeline.delete_posts(posts)
    {:noreply, stream_delete(socket, :posts_collection, posts)}
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
