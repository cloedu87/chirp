defmodule Chirp.Repo.Migrations.AddUsernameToUsers do
  use Ecto.Migration

  def change do
    # First add the column as nullable
    alter table(:users) do
      add :username, :string, null: true
    end

    # Update existing users with default usernames
    execute """
    UPDATE users
    SET username = 'user_' || id
    WHERE username IS NULL
    """

    # Now make the column non-nullable
    alter table(:users) do
      modify :username, :string, null: false
    end

    create unique_index(:users, [:username])

    # Add a constraint to ensure username is not empty and contains only valid characters
    execute """
    ALTER TABLE users ADD CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9_]{3,30}$')
    """
  end
end
