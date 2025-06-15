defmodule Chirp.Repo.Migrations.RemoveOauthFieldsFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :provider
      remove :provider_id
      remove :avatar_url
      remove :name
    end

    # Remove the unique index for provider + provider_id
    drop_if_exists index(:users, [:provider, :provider_id])

    # Make hashed_password required again
    alter table(:users) do
      modify :hashed_password, :string, null: false
    end
  end
end
