defmodule Chirp.Accounts.UserTest do
  use Chirp.DataCase

  alias Chirp.Accounts.User

  describe "registration_changeset/3" do
    test "validates required fields" do
      changeset = User.registration_changeset(%User{}, %{})

      assert %{
               email: ["can't be blank"],
               username: ["can't be blank"],
               password: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates username length" do
      changeset =
        User.registration_changeset(%User{}, %{
          email: "test@example.com",
          username: "ab",
          password: "valid_password123"
        })

      assert "should be at least 3 character(s)" in errors_on(changeset).username

      # Test max length
      long_username = String.duplicate("a", 31)

      changeset =
        User.registration_changeset(%User{}, %{
          email: "test@example.com",
          username: long_username,
          password: "valid_password123"
        })

      assert "should be at most 30 character(s)" in errors_on(changeset).username
    end

    test "validates username format - only letters, numbers, underscores" do
      invalid_usernames = ["user-name", "user.name", "user name", "user@name", "user#name"]

      for username <- invalid_usernames do
        changeset =
          User.registration_changeset(%User{}, %{
            email: "test@example.com",
            username: username,
            password: "valid_password123"
          })

        assert "can only contain letters, numbers, and underscores" in errors_on(changeset).username
      end
    end

    test "validates username must start with letter or number" do
      changeset =
        User.registration_changeset(%User{}, %{
          email: "test@example.com",
          username: "_username",
          password: "valid_password123"
        })

      assert "must start with a letter or number" in errors_on(changeset).username
    end

    test "validates username must end with letter or number" do
      changeset =
        User.registration_changeset(%User{}, %{
          email: "test@example.com",
          username: "username_",
          password: "valid_password123"
        })

      assert "must end with a letter or number" in errors_on(changeset).username
    end

    test "accepts valid usernames" do
      valid_usernames = ["user123", "test_user", "User_123", "a1b2c3", "user_name_123"]

      for username <- valid_usernames do
        changeset =
          User.registration_changeset(
            %User{},
            %{
              email: "test@example.com",
              username: username,
              password: "valid_password123"
            },
            hash_password: false,
            validate_email: false,
            validate_username: false
          )

        refute errors_on(changeset)[:username], "Username #{username} should be valid"
      end
    end

    test "validates username uniqueness when enabled" do
      {:ok, _existing_user} =
        %User{}
        |> User.registration_changeset(%{
          email: "existing@example.com",
          username: "existing_user",
          password: "valid_password123"
        })
        |> Repo.insert()

      changeset =
        User.registration_changeset(%User{}, %{
          email: "new@example.com",
          username: "existing_user",
          password: "valid_password123"
        })

      {:error, changeset} = Repo.insert(changeset)
      assert "has already been taken" in errors_on(changeset).username
    end
  end
end
