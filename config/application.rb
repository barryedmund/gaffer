require File.expand_path('../boot', __FILE__)

require 'csv'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gaffer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib)
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    
    # Euros per attendance at a home game
    config.revenue_per_ticket = 50
    # Player value is based on performance, but if they have no history, or are terrible, this is their value
    config.minimum_player_value = 50000
    # Weeks per year of contract that a team pays when releasing a player
    config.contract_weeks_to_pay_out_on_release = 20
    # How much is each position in the table worth at the end of the season?
    config.reward_per_position_at_end_of_season = 2000000
    # Min & max length of contract
    config.min_length_of_contract_days = 90
    config.max_length_of_contract_days = 1095
    config.min_weekly_salary_of_contract = 25000
    config.min_remaining_for_zombie_after_transfer_bid = 1000000
  end
end
