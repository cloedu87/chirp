defmodule Chirp.Repo.Migrations.AddOauthFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :provider, :string
      add :provider_id, :string
      add :avatar_url, :string
      add :name, :string
    end

    # Make hashed_password optional for OAuth users
    alter table(:users) do
      modify :hashed_password, :string, null: true
    end

    # Add unique index for provider + provider_id combination
    create unique_index(:users, [:provider, :provider_id])
  end
end
