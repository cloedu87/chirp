defmodule ChirpWeb.PostsLive.PostComponent do
  use ChirpWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="bg-white p-4 rounded-lg shadow hover:bg-gray-50 transition">
      <div class="flex items-start space-x-3">
        <!-- Avatar placeholder -->
        <div class="w-10 h-10 rounded-full bg-gray-200 flex-shrink-0"></div>

        <div class="flex-1">
          <!-- Header -->
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-2">
              <span class="font-bold text-gray-900"><%= @post.username %></span>
              <span class="text-gray-500">@<%= @post.username %></span>
            </div>
            <!-- Actions dropdown or buttons -->
            <div class="flex items-center space-x-2 text-gray-500">
              <.link patch={~p"/posts/#{@post}/edit"} class="hover:text-blue-500">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                  />
                </svg>
              </.link>
              <.link
                phx-click={JS.push("delete", value: %{id: @post.id}) |> hide("##{@id}")}
                data-confirm="Are you sure?"
                class="hover:text-red-500"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                  />
                </svg>
              </.link>
            </div>
          </div>
          <!-- Post body -->
          <p class="mt-2 text-gray-900"><%= @post.body %></p>
          <!-- Post metrics -->
          <div class="mt-3 flex items-center space-x-6 text-gray-500">
            <div class="flex items-center space-x-2">
              <a href="#" phx-click={JS.push("like", value: %{id: @post.id})}>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
                  />
                </svg>
              </a>
              <span><%= @post.likes_count %></span>
            </div>
            <div class="flex items-center space-x-2">
              <a href="#" phx-click={JS.push("respost", value: %{id: @post.id})}>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                  />
                </svg>
              </a>
              <span><%= @post.resposts_count %></span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
