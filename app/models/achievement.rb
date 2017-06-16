class Achievement < ActiveRecord::Base
  has_many :team_achievements, dependent: :destroy
  enum award_type: [
    :most_valuable_goalkeeper,
    :best_defensive_contribution_goalkeeper,
    :highest_paid_goalkeeper,
    :worst_signing_goalkeeper,
    :best_signing_goalkeeper,

    :most_valuable_defender,
    :best_defensive_contribution_defender,
    :best_attacking_contribution_defender,
    :highest_paid_defender,
    :worst_signing_defender,
    :best_signing_defender,

    :most_valuable_midfielder,
    :best_defensive_contribution_midfielder,
    :best_attacking_contribution_midfielder,
    :highest_paid_midfielder,
    :worst_signing_midfielder,
    :best_signing_midfielder,

    :most_valuable_forward,
    :best_attacking_contribution_forward,
    :highest_paid_forward,
    :worst_signing_forward,
    :best_signing_forward,

    :most_valuable_overall,
    :best_defensive_contribution_overall,
    :best_attacking_contribution_overall,
    :highest_paid_overall,
    :worst_signing_overall,
    :best_signing_overall,

    :richest_team,
    :poorest_team,
    :highest_total_weekly_salary_team,
    :lowest_total_weekly_salary_team,
    :highest_average_weekly_salary_team,
    :lowest_average_weekly_salary_team,

    :most_valuable_team,
    :least_valuable_team,
    :highest_average_value_of_players_team,
    :lowest_average_value_of_players_team,
    :biggest_squad,
    :smallest_squad,
    
    :galacticos
    ]
end
