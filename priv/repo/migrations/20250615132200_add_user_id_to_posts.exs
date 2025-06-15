defmodule Chirp.Repo.Migrations.AddUserIdToPosts do
  use Ecto.Migration

  def change do
    # First add the user_id column as nullable
    alter table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all), null: true
    end

    # Assign existing posts to the first user
    execute """
    UPDATE posts
    SET user_id = (SELECT id FROM users ORDER BY id LIMIT 1)
    WHERE user_id IS NULL;
    """

    # Now make user_id not nullable
    alter table(:posts) do
      modify :user_id, :integer, null: false
    end

    create index(:posts, [:user_id])

    # Remove the username field since we'll get it from the user association
    alter table(:posts) do
      remove :username
    end
  end
end
