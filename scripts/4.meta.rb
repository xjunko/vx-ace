alias load_data_base load_data

def load_data(file)
  base_file = file
  cheat_file = file.sub("Data/") { "Data_Cheat/" }
  jpn_file = file.sub("Data/") { "Data_Jpn/" }
  if FileTest.exist?(cheat_file) == true
    arr = load_data_base(cheat_file)
    return arr
  end
  if FileTest.exist?(jpn_file) == true
    arr = load_data_base(jpn_file)
    return arr
  end
  return load_data_base(file)
end

class Game_Player < Game_Character
  def check_item
    arr = load_data("Data/Items.rvdata2")
    @dldb_item_count = arr.size.to_i
  end
end

$dldb_setting = Dldb_Setting.new
if FileTest.exist?("dldb.info") == false
  $dldb_setting.cheat_save
else
  $dldb_setting = load_data("dldb.info")
end

module DLDB
  Shop = "Cheat Shop"
  Tel = "Teleport"
  Lv = "Lv Change"
  Setting1 = "Setting - ALL -"
  Setting2 = "Setting - This -"
  Sound = "Sound"
  Move = "Move Speed"
  Dash = "Dash Speed"
  Exp = "Exp"
  Encount = "Ecount (Random)"
  Encount2 = "Ecount (Event)"
  Text = "Text Speed"
  Fullsize = "Full Screen"
  Size = "Screen Change"
  Debug = "Debug Mode"
  Bgm = "BGM"
  Bgs = "BGS"
  Me = "ME"
  Se = "SE"
  Base = "Base"
  Battle = "Battle Speed"
  NoBattle = "Game Speed"
  On = "On"
  Off = "Off"
  Now = " (Now)"
  Replay_Load = "Replay"
  Save = "Save"
  Win = "Win"
  Lose = "Lose"
  Escape = "Escape"
  Not = "None"
end

Graphics.load_fullscreen_settings
