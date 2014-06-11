#===============================================================================
# Stand/Walk/Run Script --- RMXP Version
#===============================================================================
# Written by Synthesize
# Version 2.01
# February 8, 2008
#===============================================================================
#                * This script will not work with RMVX *
#===============================================================================
# Customization
#-------------------------------------------------------------------------------
module StandWalkRun
  Use_run = true   # Use Run Points?
  Use_run_sprite = true    # Use a Running sprite?
  Run_sprite_suffix = '_run'   # Running Sprite Suffix
  Run_speed = 5   # Player speed while running
  Walk_speed = 4  # Player speed while walking
  Run_points = 100   # The maximum amount of Run Points
  Run_points_restore = 40   # 1 Run Point is restored in X Frames
  Restore_run_while_walking = true   # Restore points while walking?
  Use_idle_sprite = true   # Use Idle Sprite?
  Idle_sprite_suffix = '_idle'   # idle Sprite Suffix
  Use_anime = true   # Animate your Idle Sprite?
  Idle_time = 24    # Time before sprite is animated
end
#-------------------------------------------------------------------------------
# Scene_Map:: The main functions of the script are here
#-------------------------------------------------------------------------------
class Scene_Map
  # Aliases
  alias syn_map_update update
  alias syn_map_battle call_battle
  alias syn_map_debug call_debug
  alias syn_map_menu call_menu
  alias syn_map_name call_name
  alias syn_map_save call_save
  #-----------------------------------------------------------------------------
  # Initiate variables
  #-----------------------------------------------------------------------------
  def initialize
    $game_player.old_character_name = $game_player.character_name
    @wait_time = 0
    @wait_time2 = 0
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
      @wait_time = 0
      restore_run if StandWalkRun::Restore_run_while_walking
      call_idle($game_player.old_character_name, false) if $game_player.character_name != $game_player.old_character_name
      $game_temp.syn_state = ""
    end
  end
  #-----------------------------------------------------------------------------
  # Call_Idle:: Sets and animates the idle Sprite
  #-----------------------------------------------------------------------------
  def call_idle(sprite, anime)
    $game_player.set_step_anime(anime)
    $game_player.set_graphic(sprite)
  end
  #-----------------------------------------------------------------------------
  # Call_Battle:: Reset the Idle/Run sprite if entering battle
  #-----------------------------------------------------------------------------
  def call_battle
    call_idle($game_player.old_character_name, false)
    syn_map_battle
  end
  #-----------------------------------------------------------------------------
  # Call_Shop:: Reset the idle/run sprite if entering shop
  #-----------------------------------------------------------------------------
  def call_shop
    call_idle($game_player.old_character_name, false)
    syn_map_shop
  end
  #-----------------------------------------------------------------------------
  # Call_Name:: Reset the idle/run sprite if entering Enter Hero Name screen
  #-----------------------------------------------------------------------------
  def call_name
    call_idle($game_player.old_character_name, false)
    syn_map_name
  end
  #-----------------------------------------------------------------------------
  # Call_Menu:: Reset the idle/run sprite if entering menu
  #-----------------------------------------------------------------------------
  def call_menu
    call_idle($game_player.old_character_name, false)
    syn_map_menu
  end
  #-----------------------------------------------------------------------------
  # Call_Debug:: Reset the idle/run sprite if entering debug mode
  #-----------------------------------------------------------------------------
  def call_debug
    call_idle($game_player.old_character_name, false)
    syn_map_debug
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
  alias syn_temp_init initialize
  def initialize
    @syn_state = ""
    syn_temp_init
  end
end
#-------------------------------------------------------------------------------
# Game_Character:: Create the Change_Sprite method
#-------------------------------------------------------------------------------
class Game_Character
  # Attr(s)
  attr_accessor :old_character_name
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
  attr_accessor :run_points
  alias syn_player_update update
  #-----------------------------------------------------------------------------
  # Allow Player to Dash
  #-----------------------------------------------------------------------------
  def dash?
    return false if @run_points == 0 && StandWalkRun::Use_run
    return true  if Input.press?(Input::A) && StandWalkRun::Use_run
  end
  #-----------------------------------------------------------------------------
  # Update:: Update the player
  #----------------------------------------------------------------------------
  def update
    if dash?
      unless $game_temp.syn_state == "idle"
        set_graphic(@character_name + StandWalkRun::Run_sprite_suffix) if StandWalkRun::Use_run_sprite
        @run_points -= 1
        @move_speed = StandWalkRun::Run_speed
        syn_player_update
      end
    else
      @move_speed = StandWalkRun::Walk_speed
      $game_temp.syn_state == ""
      syn_player_update
    end
  end
  #-----------------------------------------------------------------------------
  # Change the player graphic
  #-----------------------------------------------------------------------------
  def set_graphic(character_name)
    @tile_id = 0
    @character_name = character_name
  end
end
#-------------------------------------------------------------------------------
#            * This script is not compatible with RPG Maker VX *
#-------------------------------------------------------------------------------
# Written by Synthesize
# Version 2.01
# Requested by Cerulean Sky
#===============================================================================
# Stand/Walk/Run   - RMXP Version
#===============================================================================