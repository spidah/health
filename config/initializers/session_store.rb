# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_healtheriser_session',
  :secret      => '4628ada2a71d4694c5e0f04a7d15e1d4c83593ec2b09795e9de4ce9b1ffaaca601ffa62b928a872c0b80453ace58542b6e6a2ef6855573c02eea58c7925c82a4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
