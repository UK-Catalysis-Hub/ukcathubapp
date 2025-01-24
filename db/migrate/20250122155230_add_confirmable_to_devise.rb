class AddConfirmableToDevise < ActiveRecord::Migration[7.1]
  def change
    ## Confirmable
    add_column :users, :confirmation_token, :string 
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string # Only if using reconfirmable
    ## Add username too
    add_column :users, :username, :string
  end
end
