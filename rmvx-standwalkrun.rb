#===============================================================================
# Stand/Walk/Run Script --- RMVX Version
#===============================================================================
# Written by Synthesize
# Version 2.50
# January 26, 2008 (v1)
#     Revised: March 1, 2008 (v2)
#     Revised: September 4, 2010 (v2.5)
#===============================================================================
# Customization
#-------------------------------------------------------------------------------
module StandWalkRun
  Use_run = true   # Use Run Points?
  Use_run_sprite = true    # Use a Running sprite?
  Run_sprite_suffix = '_run'   # Running Sprite Suffix
  Run_points = 100   # The maximum amount of Run Points
  Run_points_restore = 60   # 1 Run Point is restored in X Frames
  Restore_run_while_walking = true   # Restore points while walking?
  Use_idle_sprite = true   # Use Idle Sprite?
  Idle_sprite_suffix = '_idle'   # idle Sprite Suffix
  Use_anime = true   # Animate your Idle Sprite?
  Idle_time = 240    # Time before sprite is animated
end
#-------------------------------------------------------------------------------
# Scene_Map:: The main functions of the script are here
#-------------------------------------------------------------------------------
class Scene_Map < Scene_Base
  # Aliases
  alias syn_map_update update
  alias syn_map_start start
  #-----------------------------------------------------------------------------
  # Initiate variables
  #-----------------------------------------------------------------------------
  def start
    if $game_player.old_character_name == nil
     $game_player.old_character_name = $game_player.character_name
    end
    @wait_time = 0
    @wait_time2 = 0
    syn_map_start
  end
  #-----------------------------------------------------------------------------
  # Update:: Update the scene
  #-----------------------------------------------------------------------------
  def update
    syn_map_update
    if Input.dir4 == 0
      wait(1, false) if StandWalkRun::Use_idle_sprite
      call_idle($game_player.character_name + StandWalkRun::Idle_sprite_suffix, StandWalkRun::Use_anime) if @wait_time == StandWalkRun::Idle_time
      $game_temp.syn_state = "idle"
      restore_run if StandWalkRun::Use_run
    else
      $game_temp.syn_state = ""
      restore_run if StandWalkRun::Restore_run_while_walking
      call_idle($game_player.old_character_name, false) if $game_player.character_name != $game_player.old_character_name
      @wait_time = 0
    end
    if $game_temp.sprite_changed == true
      $game_player.old_character_name = $game_player.character_name
      $game_temp.sprite_changed = false
    end
  end
  #-----------------------------------------------------------------------------
  # Call_Idle:: Sets and animates the idle Sprite
  #-----------------------------------------------------------------------------
  def call_idle(sprite, anime)
    $game_player.set_step_anime(anime)
    $game_player.set_graphic(sprite, $game_player.character_index)
  end
  #-----------------------------------------------------------------------------
  # Restore_Run: Restore Run Points
  #-----------------------------------------------------------------------------
  def restore_run
    if $game_player.run_points < StandWalkRun::Run_points
      wait(1, true)
      $game_player.run_points += 1 if @wait_time2 == StandWalkRun::Run_points_restore
      @wait_time2 = 0 if @wait_time2 == StandWalkRun::Run_points_restore
    end
  end
  #-----------------------------------------------------------------------------
  # Wait:: Allows Wait Times
  #-----------------------------------------------------------------------------
  def wait(duration, value)
    for i in 0...duration
      @wait_time += 1 if value == false
      @wait_time2 += 1 if value
      break if i >= duration / 2
    end
  end
end  
#-------------------------------------------------------------------------------
# Game_Temp:: Create current state
#-------------------------------------------------------------------------------
class Game_Temp
  attr_accessor :syn_state
  attr_accessor :sprite_changed
  alias syn_temp_init initialize
  def initialize
    @syn_state = ""
    @sprite_changed = false
    syn_temp_init
  end
end
#-------------------------------------------------------------------------------
# Game_Character:: Create the Change_Sprite method
#-------------------------------------------------------------------------------
class Game_Character
  # Attr(s)
  attr_accessor :old_character_name
  attr_accessor :run_points
  alias syn_ch_init initialize
  #-----------------------------------------------------------------------------
  # Initialize Variables
  #-----------------------------------------------------------------------------
  def initialize
    @run_points = StandWalkRun::Run_points
    syn_ch_init
  end
  #-----------------------------------------------------------------------------
  # Set Setp Animation
  #-----------------------------------------------------------------------------
  def set_step_anime(value)
    @step_anime = value
    return @step_anime
  end
end
#-------------------------------------------------------------------------------
# Game_Player:: This handles the dash process
#-------------------------------------------------------------------------------
class Game_Player < Game_Character
  alias syn_player_update update
  alias syn_player_dash dash?
  def dash?
    return false if @run_points == 0 and StandWalkRun::Use_run
    syn_player_dash
  end
  #-----------------------------------------------------------------------------
  # Update:: Update the scene
  #----------------------------------------------------------------------------
  def update
    if dash?
      if Input.dir4 == 0
        $game_player.set_graphic($game_player.old_character_name, $game_player.character_index)
      end
      unless $game_temp.syn_state == "idle"
        set_graphic(@character_name + StandWalkRun::Run_sprite_suffix, 0) if StandWalkRun::Use_run_sprite
        @run_points -= 1
        syn_player_update
      end
    else
      syn_player_update
    end
  end
end
#-------------------------------------------------------------------------------
#            * This script is not compatible with RPG Maker XP *
#-------------------------------------------------------------------------------
# Written by Synthesize
# Version 2.00
# Requested by Cerulean Sky
#===============================================================================
# Stand/Walk/Run   - RMVX Version
#===============================================================================