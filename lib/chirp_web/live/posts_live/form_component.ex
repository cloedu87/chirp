defmodule ChirpWeb.PostsLive.FormComponent do
  use ChirpWeb, :live_component

  alias Chirp.Timeline

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to publish your chirp.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="posts-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:body]} type="textarea" label="Body" />
        <:actions>
          <.button phx-disable-with="Saving...">Publish</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{posts: posts} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Timeline.change_posts(posts))
     end)}
  end

  @impl true
  def handle_event("validate", %{"posts" => posts_params}, socket) do
    changeset = Timeline.change_posts(socket.assigns.posts, posts_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"posts" => posts_params}, socket) do
    save_posts(socket, socket.assigns.action, posts_params)
  end

  defp save_posts(socket, :edit, posts_params) do
    case Timeline.update_posts(socket.assigns.posts, posts_params) do
      {:ok, posts} ->
        notify_parent({:saved, posts})

        {:noreply,
         socket
         |> put_flash(:info, "Posts updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_posts(socket, :new, posts_params) do
    case Timeline.create_posts(posts_params) do
      {:ok, posts} ->
        notify_parent({:saved, posts})

        {:noreply,
         socket
         |> put_flash(:info, "Posts created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
