# Junko's QOL dumbass script
# Free for non commercial and commercial use
# Licence : WTFPL
# Contact: xJunko [Github]
# For DLDB's Compatible Loader

# Tag(s)
module JunkoModuleTags
  NAME = "[Junko's Script] Open"
  HP = "Maximum HP"
  MP = "Maximum MP"
  STATS = "Maximum Stats"
  ALL_PLAYER = "Maximum HP, MP and STATS" # This is stupid can I just skip HP and MP and make it this only?
  TP = "Teleport"
  LV = "Level Change"
  ITEM_ALL = "Get All Items"
  ITEM_SHOP = "Shop for All Items"
  GOD_MODE = "God Mode"
end

# Class(es)

# Add to Menu
class Window_CheatCommand < Window_Command
  alias JK_make_command_list_override make_command_list

  def make_command_list()
    JK_make_command_list_override()

    add_command(JunkoModuleTags::NAME, :JK_Open)
  end
end

# Sub-menu declaration
class Window_JKMenu < Window_CheatCommand
  def make_command_list()
    add_command(JunkoModuleTags::HP, :JK_MaxHP)
    add_command(JunkoModuleTags::MP, :JK_MaxMP)
    add_command(JunkoModuleTags::LV, :JK_Level)
    add_command(JunkoModuleTags::ITEM_ALL, :JK_GainAll)
    add_command(JunkoModuleTags::ITEM_SHOP, :JK_ShopAll)
    add_command(JunkoModuleTags::GOD_MODE, :JK_God)
  end
end

# Sub-menu handling
class Scene_Cheat < Scene_MenuBase
  alias JK_create_command_window_override create_command_window

  def create_command_window()
    JK_create_command_window_override()

    @cheat_window.set_handler(:JK_Open, method(:JK_Open))
  end

  def JK_Open()
    if !@JK_Open
      @JK_Open = Window_JKMenu.new
      @JK_Open.set_handler(:JK_MaxHP, method(:JK_MaxHP))
      @JK_Open.set_handler(:JK_MaxMP, method(:JK_MaxMP))
      @JK_Open.set_handler(:JK_Level, method(:edit_lv))
      @JK_Open.set_handler(:JK_GainAll, method(:JK_GainAll))
      @JK_Open.set_handler(:JK_ShopAll, method(:dldb_shop))
      @JK_Open.set_handler(:JK_God, method(:JK_God))
      @JK_Open.set_handler(:cancel, method(:JK_Close))
    end

    show_sub_window(@JK_Open)
  end

  def JK_Close()
    hide_sub_window(@JK_Open)
  end
end

# Internal
class Edit_Interpreter < Game_Interpreter
  def JK_Gain(item_list)
    item_list.each do | item |
      if item.nil? or item.name == ""
        next
      end
      $game_party.gain_item(item, 999)
    end
  end
end

# Functions
class Scene_Cheat < Scene_MenuBase
  def JK_MaxHP()
    @JK_MaxHP = Edit_Interpreter.new()

    @JK_MaxHP.iterate_actor_var(0, 0) do |actor|
      actor.hp = actor.mhp
    end

    return_scene
  end

  def JK_MaxMP()
    @JK_MaxHP = Edit_Interpreter.new()

    @JK_MaxHP.iterate_actor_var(0, 0) do |actor|
      actor.mp = actor.mmp
    end

    return_scene
  end

  def JK_God()
    @JK_MaxHP = Edit_Interpreter.new()

    @JK_MaxHP.iterate_actor_var(0, 0) do |actor|
      actor.add_param(2, 9999 - actor.atk)
      actor.add_param(3, 9999 - actor.def)
      actor.add_param(4, 9999 - actor.mat)
      actor.add_param(5, 9999 - actor.mdf)
      actor.add_param(6, 9999 - actor.agi)
      actor.add_param(7, 9999 - actor.luk)
    end

    @JK_MaxHP.text("[Debug] All characters with the highest stats, completed.")

    return_scene
  end

  def JK_GainAll()
    @JK_MaxHP = Edit_Interpreter.new()
    @JK_MaxHP.JK_Gain($data_items)
    @JK_MaxHP.JK_Gain($data_weapons)
    @JK_MaxHP.JK_Gain($data_armors)
    @JK_MaxHP.text("[Debug] All items received!")
  end
end
