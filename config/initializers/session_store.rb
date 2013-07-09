# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_npostarguard_session',
  :secret      => '798c3dcf63dd728242a3c917131f67cfe7ad3798d915c6a3675dd7f0f939a12a43160c44361705a9b945169a6e4b6a3322cdd63d0f42e56e7cbedd24c34947cc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
