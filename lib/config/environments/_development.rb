  # Configure environment to use letter_opener as the mailer
  config.action_mailer.delivery_method = :letter_opener

  # Configure Bullet
  unless RUBY_PLATFORM.match(/mingw/)
    if defined?(Bullet)
      config.after_initialize do
        Bullet.enable = true
        Bullet.alert = false
        Bullet.bullet_logger = true
        Bullet.console = true
        # Bullet.growl = true
        # Bullet.xmpp = { :account => 'bullets_account@jabber.org',
        #                 :password => 'bullets_password_for_jabber',
        #                 :receiver => 'your_account@jabber.org',
        #                 :show_online_status => true }
        Bullet.rails_logger = true
        Bullet.disable_browser_cache = true
      end
    end
  end
