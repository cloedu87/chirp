defmodule Chirp.Accounts.UserNotifier do
  # import Swoosh.Email

  # alias Chirp.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    # we don't send mails at the moment
    # email =
    #   new()
    #   |> to(recipient)
    #   |> from({"Chirp", "contact@example.com"})
    #   |> subject(subject)
    #   |> text_body(body)

    # with {:ok, _metadata} <- Mailer.deliver(email) do
    #   {:ok, email}
    # end

    {:ok,
     %{
       subject: subject,
       from: {"Chirp", "contact@example.com"},
       to: recipient,
       cc: [],
       bcc: [],
       text_body: body,
       html_body: "",
       attachments: [],
       reply_to: "contact@example.com",
       headers: %{},
       private: %{},
       assigns: %{},
       provider_options: %{}
     }}
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
