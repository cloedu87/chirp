defmodule ChirpWeb.PostsLive.Show do
  use ChirpWeb, :live_view

  alias Chirp.Timeline

  # Add authentication requirement
  on_mount {ChirpWeb.UserAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    posts =
      case socket.assigns.live_action do
        :edit -> Timeline.get_user_post!(socket.assigns.current_user, id)
        _ -> Timeline.get_posts!(id)
      end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:posts, posts)}
  end

  defp page_title(:show), do: "Show Posts"
  defp page_title(:edit), do: "Edit Posts"
end
