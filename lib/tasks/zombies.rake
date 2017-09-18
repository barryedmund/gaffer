namespace :zombies do
  task :move_subs_to_first_team => :environment do
    Team.where(deleted_at: nil).each do |team|
      if team.league.current_league_season && !GameWeek.has_current_game_week
        puts "-_-_-_-_-_-_-_-"
        puts team.title
        puts "PLAYERS OUT >>>>"
        if team.is_zombie_team
          team.team_players.joins(:squad_position, :player).where('squad_positions.short_name != ? AND team_players.first_team = ? AND players.news != ?', 'SUB', true, '').each do |unavailable_first_team_player|
            unavailable_first_team_player.update_attributes(first_team: false, squad_position: SquadPosition.find_by(short_name: 'SUB'))
            puts "#{unavailable_first_team_player.full_name} (#{unavailable_first_team_player.player.playing_position})"
          end
        end
        puts "PLAYERS IN <<<<"
        while team.sub_to_move_to_first_team
          # The method return true or false so nothing goes in here
        end
        puts "-_-_-_-_-_-_-_-"
      end
    end
  end
end
