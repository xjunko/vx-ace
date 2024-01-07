# Modified/Based on DLDB's Cheat System
# Author: Unknown DLDB User (DLDB site was long dead when I got this script.)
# Maintainer: xJunko [Github]
# Year: 2023

class Dldb_Setting
  def cheat_check(type)
    case type
    when "move"; @move
    when "dash"; @dash
    when "bgm"; @bgm
    when "bgs"; @bgs
    when "me"; @me
    when "se"; @se
    when "txt"; @txt
    when "exp"; @dldb_exp
    when "encount"; @encount
    when "encount2"; @encount2
    when "cheat"; @cheat
    when "debug"; @debug
    when "type"; @type
    when "battle"; @battle
    when "nobattle"; @nobattle
    end
  end

  def cheat_change(type, text)
    case type
    when "move"; @move = text
    when "dash"; @dash = text
    when "bgm"; @bgm = text
    when "bgs"; @bgs = text
    when "me"; @me = text
    when "se"; @se = text
    when "txt"; @txt = text
    when "exp"; @dldb_exp = text
    when "encount"; @encount = text
    when "encount2"; @encount2 = text
    when "debug"; @debug = text
    when "battle"; @battle = text
    when "nobattle"; @nobattle = text
    when "cheat"; @cheat = text
    end
  end

  def cheat_call(type)
    if cheat_check(type) == nil
      cheat_change(type, false)
      return false
    else
      return cheat_check(type)
    end
  end

  def cheat_save
    save_data($dldb_setting, "dldb.info")
  end
end

class Game_Player < Game_Character
  def cheat_check(type)
    case type
    when "move"; @move
    when "dash"; @dash
    when "bgm"; @bgm
    when "bgs"; @bgs
    when "me"; @me
    when "se"; @se
    when "txt"; @txt
    when "exp"; @dldb_exp
    when "battle"; @battle
    when "nobattle"; @nobattle
    when "encount"; @encount
    when "encount2"; @encount2
    when "cheat"; @cheat
    when "debug"; @debug
    when "type"; @type
    end
  end

  def cheat_change(type, text)
    case type
    when "move"; @move = text
    when "dash"; @dash = text
    when "bgm"; @bgm = text
    when "bgs"; @bgs = text
    when "me"; @me = text
    when "se"; @se = text
    when "txt"; @txt = text
    when "exp"; @dldb_exp = text
    when "battle"; @battle = text
    when "nobattle"; @nobattle = text
    when "encount"; @encount = text
    when "encount2"; @encount2 = text
    when "debug"; @debug = text
    when "cheat"; @cheat = text
    end
  end

  def cheat_call(type)
    if cheat_check(type) == nil
      cheat_change(type, false)
      return $dldb_setting.cheat_call(type)
    else
      return cheat_check(type) if cheat_check(type)
      return $dldb_setting.cheat_call(type)
    end
  end

  def cheat_save
  end
end

class Scene_Map
  #치트 시스템 확인하기
  alias update_scene_dime update_scene if !$dldb_setting

  def update_scene
    update_scene_dime
    update_call_cheat unless scene_changing?
  end

  #치트시스템 불러오기
  def update_call_cheat
    call_cheat if Input.trigger?(:F8) && !$game_player.moving?
    SceneManager.call(Scene_Debug) if Input.press?(:F9) && $game_player.cheat_call("debug") == 1 && !$game_player.moving? && !$TEST
    @cheat_calling = false
  end

  #치트시스템 창 불러오기
  def call_cheat
    Sound.play_ok
    SceneManager.call(Scene_Cheat)
    Window_CheatCommand::init_command_position
  end
end

#치트 초기 메뉴창 설정
class Window_CheatCommand < Window_Command
  def make_command_list
    add_command(DLDB::Name, :DLDB_Open)
  end
end

class Window_DLDBMenu < Window_CheatCommand
  def make_command_list()
    add_command(DLDB::Shop, :shop)
    add_command(DLDB::Tel, :tel) if FileTest.exist?("tel.txt")
    add_command(DLDB::Lv, :lv_edit)
    add_command(DLDB::Setting1, :setting_edit1)
    add_command(DLDB::Setting2, :setting_edit2)
    add_command(DLDB::Fullsize, :screen_full)
    add_command(DLDB::Size, :screen_change)
  end
end

#치트 초기 메뉴 실행 설정
class Scene_Cheat < Scene_MenuBase
  def start
    super
    create_command_window
  end

  def create_command_window
    @cheat_window = Window_CheatCommand.new
    @cheat_window.set_handler(:DLDB_Open, method(:DLDB_Open))
    @cheat_window.set_handler(:cancel, method(:return_scene))
  end

  def DLDB_Open()
    if !@DLDB_Open
      @DLDB_Open = Window_DLDBMenu.new()
      @DLDB_Open.set_handler(:shop, method(:dldb_shop))
      @DLDB_Open.set_handler(:tel, method(:dldb_tel))
      @DLDB_Open.set_handler(:lv_edit, method(:dldb_lv))
      @DLDB_Open.set_handler(:setting_edit1, method(:dldb_setting1))
      @DLDB_Open.set_handler(:setting_edit2, method(:dldb_setting2))
      @DLDB_Open.set_handler(:screen_full, method(:screen_full))
      @DLDB_Open.set_handler(:screen_change, method(:screen_change))
      @DLDB_Open.set_handler(:cancel, method(:DLDB_Close))
    end

    show_sub_window(@DLDB_Open)
  end

  def DLDB_Close()
    hide_sub_window(@DLDB_Open)
  end
end

#상점 실행 관련
class Scene_Cheat < Scene_MenuBase
  def dldb_shop
    $game_player.check_item
    u_s = $game_player.dldb_item_count
    use = [u_s - 3, u_s - 1]
    dldb_shop_start(use)
  end
end

class Scene_Cheat < Scene_MenuBase
  def dldb_shop_start(item)
    goods = []

    # Internal Item.
    for i in item[0]...item[1] + 1
      goods.push([0, i, 1, 0]) if $data_items[i].name != ""
    end

    # Game Item
    [$data_items, $data_weapons, $data_armors].each do |data_list|
      data_list.each do |item|
        next if item.nil? || item.name == ""
        goods.push([0, item.id, 1, 0])
      end
    end

    return_scene
    SceneManager.call(Scene_Shop)
    SceneManager.scene.prepare(goods, false)
  end
end

##순간이동 관련 처리
#순간이동 관련 선택창
class Window_CheatTel < Window_CheatCommand
  def make_command_list
    add_command("회상", :teleport, true, [File.read("tel.txt"), 1, 1])
  end
end

#순간이동 실행 관련
class Scene_Cheat < Scene_MenuBase
  def dldb_tel()
    if @dldb_teleport
    else
      @dldb_teleport = Window_CheatTel.new
      @dldb_teleport.set_handler(:teleport, method(:tel))
      @dldb_teleport.set_handler(:cancel, method(:hide_sub_window))
    end
    show_sub_window(@dldb_teleport)
  end

  def tel
    place = @dldb_teleport.current_ext
    $game_player.reserve_transfer(place[0], place[1], place[2])
    SceneManager.goto(Scene_Map)
  end
end

##레벨 관련 처리
#레벨 관련 선택창
class Window_CheatLv < Window_CheatCommand
  def make_command_list
    add_command("Lv  1", :edit_lv, true, 1)
    add_command("Lv 20", :edit_lv, true, 20)
    add_command("Lv 40", :edit_lv, true, 40)
    add_command("Lv 60", :edit_lv, true, 60)
    add_command("Lv 80", :edit_lv, true, 80)
    add_command("Lv 99", :edit_lv, true, 99)
  end
end

#레벨 관련 실행
class Scene_Cheat < Scene_MenuBase
  def dldb_lv()
    if @dldb_lv
    else
      @dldb_lv = Window_CheatLv.new
      @dldb_lv.set_handler(:edit_lv, method(:edit_lv))
      @dldb_lv.set_handler(:cancel, method(:hide_lv))
    end
    show_sub_window(@dldb_lv)
  end

  def hide_lv
    hide_sub_window(@dldb_lv)
  end

  def edit_lv
    lv = @dldb_lv.current_ext
    if @edit_lv
    else
      @edit_lv = Edit_Interpreter.new()
    end
    @edit_lv.lv_change(lv)
    @edit_lv.text("Level changed to " + lv.to_s + "!")
    return_scene
  end
end

#레벨변경 출력 관련
class Edit_Interpreter < Game_Interpreter
  def lv_change(i)
    iterate_actor_var(0, 0) do |actor|
      actor.change_level(i, false)
    end
  end

  def text(i)
    $game_message.add(i)
  end
end

class Window_CheatCommand < Window_Command
  def self.init_command_position
    @@last_command_symbol = nil
  end

  def initialize
    super(0, 0)
  end

  def visible_line_number
    item_max
  end

  def menu_name
    return @select_cheat
  end

  def process_ok
    @@last_command_symbol = current_symbol
    super
  end
end

##세팅 관련 처리
#세팅 관련 선택창
class Window_CheatSetting < Window_CheatCommand
  def make_command_list
    add_command(DLDB::Move, :edit_move, true, "move")
    add_command(DLDB::Dash, :edit_dash, true, "dash")
    add_command(DLDB::Exp, :edit_exp, true, "exp")
    add_command(DLDB::Encount, :edit_encount, true, "encount")
    add_command(DLDB::Encount2, :edit_encount2, true, "encount2")
    add_command(DLDB::Text, :edit_text, true, "txt")
    add_command(DLDB::Battle, :edit_battle, true, "battle")
    add_command(DLDB::NoBattle, :edit_nobattle, true, "nobattle")
    add_command(DLDB::Debug, :edit_debug, true, "debug")
    add_command(DLDB::Bgm, :edit_bgm, true, "bgm")
    add_command(DLDB::Bgs, :edit_bgs, true, "bgs")
    add_command(DLDB::Me, :edit_me, true, "me")
    add_command(DLDB::Se, :edit_se, true, "se")
  end
end

#세팅 실행 관련
class Scene_Cheat < Scene_MenuBase
  def dldb_setting1
    @now_setting = $dldb_setting
    dldb_setting
  end

  def dldb_setting2
    @now_setting = $game_player
    dldb_setting
  end

  def close
    @now_setting = false
  end

  def dldb_setting
    @dldb_setting = Window_CheatSetting.new
    @dldb_setting.set_handler(:edit_move, method(:dldb_speed))
    @dldb_setting.set_handler(:edit_dash, method(:dldb_speed))
    @dldb_setting.set_handler(:edit_exp, method(:dldb_exp))
    @dldb_setting.set_handler(:edit_text, method(:dldb_text))
    @dldb_setting.set_handler(:edit_debug, method(:dldb_debug))
    @dldb_setting.set_handler(:edit_encount, method(:dldb_encount))
    @dldb_setting.set_handler(:edit_encount2, method(:dldb_encount2))
    @dldb_setting.set_handler(:edit_battle, method(:dldb_battle))
    @dldb_setting.set_handler(:edit_nobattle, method(:dldb_battle))
    @dldb_setting.set_handler(:edit_bgm, method(:dldb_sound))
    @dldb_setting.set_handler(:edit_bgs, method(:dldb_sound))
    @dldb_setting.set_handler(:edit_me, method(:dldb_sound))
    @dldb_setting.set_handler(:edit_se, method(:dldb_sound))
    @dldb_setting.set_handler(:cancel, method(:setting_cancel))
    show_sub_window(@dldb_setting)
  end
end

#세팅 세부적인 부분
class Window_CheatCommand_Setting < Window_CheatCommand
  alias dldb_initialize initialize if !$dldb_setting

  def initialize(type, text)
    @now_setting = type
    @select_cheat = text
    dldb_initialize
  end

  def close
    @now_setting = false
    @select_cheat = false
  end
end

#설정 메뉴창 - 속도
class Window_CheatMove < Window_CheatCommand_Setting
  def make_command_list
    imsi = @now_setting.cheat_check(menu_name)
    for i in 4...10
      if i == imsi
        add_command(i.to_s + DLDB::Now, :change_type, true, i)
      else
        add_command(i.to_s, :change_type, true, i)
      end
    end
    if imsi == false || imsi == nil
      add_command(DLDB::Base + DLDB::Now, :change_type, true, false)
    else
      add_command(DLDB::Base, :change_type, true, false)
    end
  end
end

#설정 메뉴창 - 활성 속도
class Window_CheatBattle < Window_CheatCommand_Setting
  def make_command_list
    imsi = @now_setting.cheat_check(menu_name)
    for i in 1...11
      if i == imsi
        add_command(i.to_s + "x" + DLDB::Now, :change_type, true, i)
      else
        add_command(i.to_s + "x", :change_type, true, i)
      end
    end
    if imsi == false || imsi == nil
      add_command(DLDB::Base + DLDB::Now, :change_type, true, false)
    else
      add_command(DLDB::Base, :change_type, true, false)
    end
  end
end

#설정 - 경험치
class Window_Exp < Window_CheatCommand_Setting
  def make_command_list
    imsi = @now_setting.cheat_check(menu_name)
    for i in 0...11
      if imsi == i
        add_command(i.to_s + "x" + DLDB::Now, :change_type, true, i)
      else
        add_command(i.to_s + "x", :change_type, true, i)
      end
    end
    if imsi == false || imsi == nil
      add_command(DLDB::Base + DLDB::Now, :change_type, true, false)
    else
      add_command(DLDB::Base, :change_type, true, false)
    end
  end
end

#설정 - 인카운트
class Window_Encount < Window_CheatCommand_Setting
  def make_command_list
    imsi = @now_setting.cheat_check(menu_name)
    if imsi == 1
      add_command(DLDB::On + DLDB::Now, :change_type, true, 1)
      add_command(DLDB::Off, :change_type, true, 2)
      add_command(DLDB::Base, :change_type, true, false)
    elsif imsi == 2
      add_command(DLDB::On, :change_type, true, 1)
      add_command(DLDB::Off + DLDB::Now, :change_type, true, 2)
      add_command(DLDB::Base, :change_type, true, false)
    else imsi == false || imsi == nil
      add_command(DLDB::On, :change_type, true, 1)
      add_command(DLDB::Off, :change_type, true, 2)
      add_command(DLDB::Base + DLDB::Now, :change_type, true, false)     end
  end
end

#설정 - 인카운트2
class Window_Encount2 < Window_CheatCommand_Setting
  def make_command_list
    imsi = @now_setting.cheat_check(menu_name)

    add_command(DLDB::Win + DLDB::Now, :change_type, true, 1) if imsi == 1
    add_command(DLDB::Win, :change_type, true, 1) if imsi != 1
    add_command(DLDB::Lose + DLDB::Now, :change_type, true, 2) if imsi == 2
    add_command(DLDB::Lose, :change_type, true, 2) if imsi != 2
    add_command(DLDB::Escape + DLDB::Now, :change_type, true, 3) if imsi == 3
    add_command(DLDB::Escape, :change_type, true, 3) if imsi != 3
    add_command(DLDB::Not + DLDB::Now, :change_type, true, 4) if imsi == 4
    add_command(DLDB::Not, :change_type, true, 4) if imsi != 4
    add_command(DLDB::Base + DLDB::Now, :change_type, true, false) if !imsi
    add_command(DLDB::Base, :change_type, true, false) if imsi
  end
end

#설정 - 텍스트
class Window_TextView < Window_CheatCommand_Setting
  def make_command_list
    imsi = @now_setting.cheat_check(menu_name)
    if imsi == 1
      add_command(DLDB::On + DLDB::Now, :change_type, true, 1)
      add_command(DLDB::Off, :change_type, true, 2)
      add_command(DLDB::Base, :change_type, true, false)
    elsif imsi == 2
      add_command(DLDB::On, :change_type, true, 1)
      add_command(DLDB::Off + DLDB::Now, :change_type, true, 2)
      add_command(DLDB::Base, :change_type, true, false)
    else imsi == false || imsi == nil
      add_command(DLDB::On, :change_type, true, 1)
      add_command(DLDB::Off, :change_type, true, 2)
      add_command(DLDB::Base + DLDB::Now, :change_type, true, false)     end
  end
end

#설정 - 디버그
class Window_Debug_Dldb < Window_CheatCommand_Setting
  def make_command_list
    imsi = @now_setting.cheat_check(menu_name)
    if imsi == 1
      add_command(DLDB::On + DLDB::Now, :change_type, true, 1)
      add_command(DLDB::Off, :change_type, true, 2)
      add_command(DLDB::Base, :change_type, true, false)
    elsif imsi == 2
      add_command(DLDB::On, :change_type, true, 1)
      add_command(DLDB::Off + DLDB::Now, :change_type, true, 2)
      add_command(DLDB::Base, :change_type, true, false)
    else imsi == false || imsi == nil
      add_command(DLDB::On, :change_type, true, 1)
      add_command(DLDB::Off, :change_type, true, 2)
      add_command(DLDB::Base + DLDB::Now, :change_type, true, false)     end
  end
end

#설정 메뉴창 - 소리
class Window_Volume < Window_CheatCommand_Setting
  def make_command_list
    imsi = @now_setting.cheat_check(menu_name)
    for i in 0...11
      i2 = i * 10
      if imsi == i2
        add_command(i2.to_s + "%" + DLDB::Now, :change_type, true, i2)
      else
        add_command(i2.to_s + "%", :change_type, true, i2)
      end
    end
    if imsi == false || imsi == nil
      add_command(DLDB::Base + DLDB::Now, :change_type, true, false)
    else
      add_command(DLDB::Base, :change_type, true, false)
    end
  end
end

class Scene_Cheat < Scene_MenuBase
  #설정 실행 - 배틀속도
  def dldb_battle
    @dldb_battle = Window_CheatBattle.new(@now_setting, @dldb_setting.current_ext)
    @dldb_battle.set_handler(:change_type, method(:change_type))
    @dldb_battle.set_handler(:cancel, method(:hide_setting_window))
    @now_menu = "battle"
    show_setting_window
  end

  #설정 실행 - 속도
  def dldb_speed
    @dldb_speed = Window_CheatMove.new(@now_setting, @dldb_setting.current_ext)
    @dldb_speed.set_handler(:change_type, method(:change_type))
    @dldb_speed.set_handler(:cancel, method(:hide_setting_window))
    @now_menu = "speed"
    show_setting_window
  end

  #설정 - 경험치
  def dldb_exp
    @dldb_exp = Window_Exp.new(@now_setting, @dldb_setting.current_ext)
    @dldb_exp.set_handler(:change_type, method(:change_type))
    @dldb_exp.set_handler(:cancel, method(:hide_setting_window))
    @now_menu = "exp"
    show_setting_window
  end

  #설정 - 인카운트
  def dldb_encount
    @dldb_encount = Window_Encount.new(@now_setting, @dldb_setting.current_ext)
    @dldb_encount.set_handler(:change_type, method(:change_type))
    @dldb_encount.set_handler(:cancel, method(:hide_setting_window))
    @now_menu = "encount"
    show_setting_window
  end

  #설정 - 인카운트2
  def dldb_encount2
    @dldb_encount2 = Window_Encount2.new(@now_setting, @dldb_setting.current_ext)
    @dldb_encount2.set_handler(:change_type, method(:change_type))
    @dldb_encount2.set_handler(:cancel, method(:hide_setting_window))
    @now_menu = "encount2"
    show_setting_window
  end

  #설정 - 텍스트
  def dldb_text
    @dldb_text = Window_TextView.new(@now_setting, @dldb_setting.current_ext)
    @dldb_text.set_handler(:change_type, method(:change_type))
    @dldb_text.set_handler(:cancel, method(:hide_setting_window))
    @now_menu = "txt"
    show_setting_window
  end

  #설정 - 디버그
  def dldb_debug
    @dldb_debug = Window_Debug_Dldb.new(@now_setting, @dldb_setting.current_ext)
    @dldb_debug.set_handler(:change_type, method(:change_type))
    @dldb_debug.set_handler(:cancel, method(:hide_setting_window))
    @now_menu = "debug"
    show_setting_window
  end

  #설정 실행 - 소리
  def dldb_sound
    @dldb_sound = Window_Volume.new(@now_setting, @dldb_setting.current_ext)
    @dldb_sound.set_handler(:change_type, method(:change_type))
    @dldb_sound.set_handler(:cancel, method(:hide_setting_window))
    @now_menu = "sound"
    show_setting_window
  end
end

#설정 기본
class Scene_Cheat < Scene_MenuBase
  def find_menu
    case @now_menu
    when "speed"; return @dldb_speed
    when "sound"; return @dldb_sound
    when "exp"; return @dldb_exp
    when "encount"; return @dldb_encount
    when "encount2"; return @dldb_encount2
    when "txt"; return @dldb_text
    when "debug"; return @dldb_debug
    when "battle"; return @dldb_battle
    end
  end

  def setting_cancel
    @now_setting = false
    hide_sub_window(@dldb_setting)
  end

  def change_type
    now_menu = find_menu
    @now_setting.cheat_change(@dldb_setting.current_ext, now_menu.current_ext)
    @now_setting.cheat_save
    now_menu.close
    @dldb_setting.close
    return_scene
  end

  def show_sub_window(window)
    width_remain = Graphics.width - window.width
    window.x = @cheat_window.width
    @viewport.rect.x = 0
    @viewport.rect.width = width_remain
    window.show.activate
  end

  def hide_sub_window(window)
    @viewport.rect.x = @viewport.ox = 0
    @viewport.rect.width = Graphics.width
    window.hide.deactivate
    @cheat_window.refresh
    @cheat_window.activate
  end

  def show_setting_window
    now_menu = find_menu
    width_remain = Graphics.width - now_menu.width
    now_menu.x = @cheat_window.width + @dldb_setting.width
    @viewport.rect.x = 0
    @viewport.rect.width = width_remain
    now_menu.show.activate
  end

  def hide_setting_window
    now_menu = find_menu
    @viewport.rect.x = @viewport.ox = 0
    @viewport.rect.width = Graphics.width
    now_menu.hide.deactivate
    now_menu.close
    @dldb_setting.refresh
    @dldb_setting.activate
  end
end

class Scene_Cheat < Scene_MenuBase
  def screen_full
    Graphics.toggle_fullscreen
    @cheat_window.refresh
    @cheat_window.activate
  end

  def screen_change
    Graphics.toggle_ratio
    @cheat_window.refresh
    @cheat_window.activate
  end
end

class Game_Player < Game_Character
  def check_item
    arr = load_data("Data/Items.rvdata2")
    @dldb_item_count = arr.size.to_i
  end

  def dldb_item_count
    @dldb_item_count
  end

  #인카운트
  alias dldb_update_encounter update_encounter if !$dldb_setting

  def update_encounter
    if cheat_call("encount") == 1
      return
    else
      dldb_update_encounter
    end
  end

  #디버그 모드
  alias dldb_debug_through? debug_through? if !$dldb_setting

  def debug_through?
    if cheat_call("debug") == 1 && Input.press?(:CTRL)
      return true
    end
    if $TEST && Input.press?(:CTRL)
      return true
    end
    return false
  end
end

#인카운트2
class Game_Interpreter
  alias dldb_command_301 command_301 if !$dldb_setting
  alias dldb_command_601 command_601 if !$dldb_setting
  alias dldb_command_602 command_602 if !$dldb_setting
  alias dldb_command_603 command_603 if !$dldb_setting

  def command_301
    return if $game_player.cheat_call("encount2")
    dldb_command_301
  end

  def command_601
    return if $game_player.cheat_call("encount2") == 1
    if $game_player.cheat_call("encount2")
      command_skip
    else
      dldb_command_601
    end
  end

  def command_602
    return if $game_player.cheat_call("encount2") == 3
    if $game_player.cheat_call("encount2")
      command_skip
    else
      dldb_command_602
    end
  end

  def command_603
    return if $game_player.cheat_call("encount2") == 2
    if $game_player.cheat_call("encount2")
      command_skip
    else
      dldb_command_603
    end
  end
end

#이속
class Game_CharacterBase
  alias dldb_real_move_speed real_move_speed if !$dldb_setting

  def real_move_speed
    if dash?
      return dldb_dash
    else
      return dldb_move
    end
  end

  def dldb_dash
    if $game_player.cheat_call("dash")
      return $game_player.cheat_call("dash")
    else
      return dldb_move + 1
    end
  end

  def dldb_move
    if $game_player.cheat_call("move")
      return $game_player.cheat_call("move")
    else
      return @move_speed
    end
  end
end

#메세지 빠르게
class Window_Message < Window_Base
  alias dldb_clear_flags clear_flags if !$dldb_setting

  def clear_flags
    dldb_clear_flags
    if $game_player.cheat_call("txt") == 1 && $game_message.choices.size == 0
      @show_fast = true
    end
  end
end # Window_Message

#경험치
class Game_Troop < Game_Unit
  alias dldb_exp_total exp_total if !$dldb_setting

  def exp_total
    if $game_player.cheat_call("exp") == false
      dldb_exp_total
    else
      dldb_exp_total * $game_player.cheat_call("exp")
    end
  end
end

#음량 설정
class RPG::BGM < RPG::AudioFile
  alias dldb_play play if !$dldb_setting

  def play(pos = 0)
    if $game_player.cheat_call("bgm")
      @volume = $game_player.cheat_call("bgm")
    end
    dldb_play(pos)
  end
end

class RPG::BGS < RPG::AudioFile
  alias dldb_play play if !$dldb_setting

  def play(pos = 0)
    if $game_player.cheat_call("bgs")
      @volume = $game_player.cheat_call("bgs")
    end
    dldb_play(pos)
  end
end

class RPG::ME < RPG::AudioFile
  alias dldb_play play if !$dldb_setting

  def play
    if $game_player.cheat_call("me")
      @volume = $game_player.cheat_call("me")
    end
    dldb_play
  end
end

class RPG::SE < RPG::AudioFile
  alias dldb_play play if !$dldb_setting

  def play
    if $game_player.cheat_call("se")
      @volume = $game_player.cheat_call("se")
    end
    dldb_play
  end
end

class << Graphics
  def dldb_get_speed
    if SceneManager.scene_is?(Scene_Battle)
      if $game_player.cheat_call("battle")
        return $game_player.cheat_call("battle")
      end
    else
      if $game_player.cheat_call("nobattle")
        return $game_player.cheat_call("nobattle")
      end
    end
    return 1
  end

  def spd_frame_count
    @spd_frame_count = Graphics.frame_count if @spd_frame_count == nil
    return @spd_frame_count
  end

  def spd_frame_count=(count)
    @spd_frame_count = count
  end

  alias :dldb_update_spd :update if !$dldb_setting

  def update
    if Graphics.frame_count % dldb_get_speed.to_i > 0
      Graphics.frame_count += 1
    else
      Graphics.spd_frame_count += 1
      dldb_update_spd
    end
  end

  alias :dldb_wait_spd :wait if !$dldb_setting

  def wait(duration)
    duration /= dldb_get_speed
    dldb_wait_spd(duration)
  end

  alias :dldb_fadein_spd :fadein if !$dldb_setting

  def fadein(duration)
    duration /= dldb_get_speed
    dldb_fadein_spd(duration)
  end

  alias :dldb_fadeout_spd :fadeout if !$dldb_setting

  def fadeout(duration)
    duration /= dldb_get_speed
    dldb_fadeout_spd(duration)
  end

  alias :dldb_transition_spd :transition if !$dldb_setting

  def transition(duration = 10, filename = "", vague = 40)
    duration /= dldb_get_speed
    dldb_transition_spd(duration, filename, vague)
  end
end
