-- TODO - https://stackoverflow.com/a/44594187
-- try to make apps believe they're maximized without them taking up the whole screen
-- maybe also https://stackoverflow.com/questions/29670635/awesome-wm-does-not-maximize-windows-anymore


-- Standard awesome library
Gears = require("gears")
Awful = require("awful")
Awful.rules = require("awful.rules")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- widgets
local vicious = require("vicious")


--- {{{ Early overrides

naughty.config.presets.critical.bg = '#181b1f'
naughty.config.presets.critical.fg = '#e75555'

-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
  title = "Error during startup",
  text = awesome.startup_errors })

  print("\nStartup errors:")
  print(awesome.startup_errors)
  print("\n")
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    local errorstring = tostring(err) .. "\n\n" .. debug.traceback()

    naughty.notify({ preset = naughty.config.presets.critical,
    title = "Error occurred",
    text = tostring(err) .. "\n\n" .. debug.traceback() })

    print("\nStartup errors:")
    print(errorstring)
    print("\n")

    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Tagnames
local tagnames = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 'a', 'b', 'c', }

-- Themes define colours, icons, font and wallpapers.
beautiful.init(Awful.util.getdir("config") .. "/themes/my_default_2.0/theme.lua")

-- Application launches
local editor_cmd1 = "nvim-qt"
local editor_cmd2 = "kitty -e nvim"
local editor_cmd2_root = "kitty -e 'bash -c \"sudo -i nvim\"'"
local filemanager_cmd1 = "thunar"
local filemanager_cmd1_root = "gksudo thunar"
local filemanager_cmd2 = "spacefm"
local filemanager_cmd2_root = "spacefm"
local terminal_cmd = "kitty"
local terminal_cmd_root = "kitty -e bash -c 'su -l root'"
local terminal_cmd_stanalone = "kitty"
local firefox_cmd_defaultProfile = "firefox -P entertainment --new-instance"
local firefox_cmd_ProfileManager = "firefox --ProfileManager --new-instance"

-- Tool launches
local inc_display_brightness = "light -A 4"
local inc_display_brightness_fine = "light -r -A 1"
local inc_display_brightness_max = "light -S 100"
local dec_display_brightness = "light -U 4"
local dec_display_brightness_fine = "light -r -U 1"
local dec_display_brightness_zero = "light -S 0"
local maxBrightness_cmd = "light -S 100"
local minBrightness_cmd = "light -r -S 1"
local stop_focused_process = "bash -c 'kill -STOP $(xdotool getwindowpid $(xdotool getwindowfocus))'"
local cont_focused_process = "bash -c 'kill -CONT $(xdotool getwindowpid $(xdotool getwindowfocus))'"
local audio_play = "playerctl --all-players play"
local audio_pause = "playerctl --all-players pause"
local audio_playpause = "playerctl --all-players play-pause"
local audio_next = "playerctl --all-players next"
local audio_prev = "playerctl --all-players previous"

-- Commands to switch to specific keyboard layout for this session.
-- TODO perhaps these should be more like this: localectl set-x11-keymap us pc104 altgr-intl
local kbd_switch2_de_cmd  = "setxkbmap -model pc104 -layout de -option"
local kbd_switch2_ru_cmd  = "setxkbmap -model pc104 -layout ru -option"
local kbd_switch2_us_cmd  = "setxkbmap -model pc104 -layout us -variant altgr-intl -option"
local kbd_switch2_apl_cmd = "setxkbmap -model pc104 -layout us,apl -variant altgr-intl -option grp:rctrl_toggle"
-- kbd_switch2_de_cmd = "localectl set-x11-keymap de pc104"
-- kbd_switch2_ru_cmd = "localectl set-x11-keymap ru pc104"
-- kbd_switch2_us_cmd = "localectl set-x11-keymap us pc104 altgr-intl"

local eject_cmd = "eject -T"

local lock_screen_cmd = "slock"


local bootNextWIN_cmd = "systemctl reboot --boot-loader-menu=0s --boot-loader-entry=auto-windows"
local bootNextLINUX_cmd = "systemctl reboot --boot-loader-menu=0s --boot-loader-entry=arch.conf"
local bootNextMENU_cmd = "systemctl reboot --boot-loader-menu=60s"
local bootNextBIOS_cmd = "systemctl reboot --boot-loader-menu=0s --boot-loader-entry=auto-reboot-to-firmware-setup"
local bootNextEFISHELL_cmd = "systemctl reboot --boot-loader-menu=0s --boot-loader-entry=auto-efi-shell"


local suspend_disk_cmd = "suspend_disk"
local suspend_ram_cmd = "suspend_ram"
local shutdown_cmd = "systemctl poweroff"
local reboot_cmd  = "systemctl reboot"

local etc_shutdown_cmd = "gksudo K_etc_shutdown"
local lock_suspend_disk_cmd = "suspend_disk l"
local lock_suspend_ram_cmd = "suspend_ram l"

local notifySendWmNameAndWmClass_cmd = "notifySendWmNameAndWmClass"

local tag_soundtools = "1"
local tag_monitoring = "2"
local tag_communication = "3"


local screen_tools = 1
local screen_monitoring = 1
local multi_screens = false
if os.getenv("USER") == 'md' then
  screen_tools = 2
  screen_monitoring = 3
  multi_screens = true
  -- more_tools = true
end

-- Wibar width (right-click menu on taskbar)
local wibar_width = 550


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"
local altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
Awful.layout.layouts = {
  Awful.layout.suit.max,
  Awful.layout.suit.floating,
  --Awful.layout.suit.magnifier,
  --Awful.layout.suit.spiral.dwindle,
  --Awful.layout.suit.spiral,
  --Awful.layout.suit.fair.horizontal,
  --Awful.layout.suit.fair,
  Awful.layout.suit.tile.bottom,
  --Awful.layout.suit.tile.top,
  --Awful.layout.suit.tile.left,
  Awful.layout.suit.tile,
  --Awful.layout.suit.grid,
}
-- }}}

-- {{{ Helper functions
local function echo (title, arg)
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = title,
    text=tostring(arg)
  })
end

local function client_menu_toggle_fn()
  local instance = nil

  return function ()
    if instance and instance.wibox.visible then
      instance:hide()
      instance = nil
    else
      instance = Awful.menu.clients({ theme = { width = wibar_width } })
    end
  end
end


local function client_rel_send(rel_idx)
  local client = client.focus
  local focused = Awful.screen.focused()
  if client then 
    local scr = client.screen or focused.index
    local sel_idx = focused.selected_tag.index
    local tags = Awful.tag.gettags(scr)
    local target = Awful.util.cycle(#tags, sel_idx + rel_idx)
    Awful.client.movetotag(tags[target], client)
    Awful.tag.viewonly(tags[target])
  else
    echo("client_rel_send", "no client found!")
  end
end

local client_tag_moveRight  = function ()
  client_rel_send(1)
end

local client_tag_moveLeft = function ()
  client_rel_send(-1)
end
-- }}}


-- {{{ Menu

Awful.menu.menu_keys = {
  up    = { "k", "Up" },
  down  = { "j", "Down" },
  exec  = { "l", "Return", "Right" },
  enter = { "l", "Right" },
  back  = { "h", "Left" },
  close = { "q", "Escape" },
}

-- Create a launcher widget and a main menu
Myawesomemenu = {
  { "manual", terminal_cmd .. " -e man awesome" },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end },
}

Mytoolsmenu = {
  { "edit config", editor_cmd2 .. " " .. awesome.conffile },
  { "wm info", notifySendWmNameAndWmClass_cmd },
  { "max brightness", maxBrightness_cmd },
  { "min brightness", minBrightness_cmd },
}

Myplusmenu = {
  { "bootNext|WIN", bootNextWIN_cmd },
  { "bootNext|LINUX", bootNextLINUX_cmd },
  { "bootNext|MENU", bootNextMENU_cmd },
  { "bootNext|BIOS", bootNextBIOS_cmd },
  { "bootNext|EFI", bootNextEFISHELL_cmd },
  { "etc,shutdown", etc_shutdown_cmd },
  { "lock,hibernate", lock_suspend_disk_cmd },
  { "lock,suspend", lock_suspend_ram_cmd },
}

Mymainmenu = Awful.menu ({
  items = {
    { "awesome", Myawesomemenu, beautiful.awesome_icon },
    { "tools", Mytoolsmenu },
    { "+", Myplusmenu },
    { "hibernate", suspend_disk_cmd },
    { "suspend", suspend_ram_cmd },
    { "shutdown", shutdown_cmd },
    { "reboot", reboot_cmd },
  }
})

-- TODO: figuire out what this is, remove it
Mylauncher = Awful.widget.launcher(
{
  image = beautiful.awesome_icon,
  menu = Mymainmenu,
}
)

-- Menubar configuration
menubar.utils.terminal = terminal_cmd_stanalone -- Set the terminal for applications that require it
-- }}}

-- {{{ Keyboard map indicator

-- Keyboard map indicator and switcher TODO: This sounds interessting
-- Mykeyboardlayout = Awful.widget.keyboardlayout()
Mykeyboardlayout = Awful.widget.keyboardlayout:new()

-- }}}

-- {{{ Wibar

-- volume change
Volume = {}
-- Volume.PAsinkName = "alsa_output.pci-0000_00_1b.0.analog-stereo" -- Would be awesome if we could dynamically figure out the default sink...
-- Volume.PAsinkName = "alsa_output.pci-0000_00_1b.0.output_analog-stereo" -- New pipewire name, find it with pactl list | grep Output
-- TODO: Would be really cool to find a pure piewire way that is not
-- `pw-cli s <node-id> Props { mute: false, channelVolumes: [ 0.3, 0.3 ] }`
-- where <node-id> is literally a number i have to figure out with pw-cli ls (prop names are ok, list them with `pw-cli e <node-id>`)
Volume.PAsinkName = "@DEFAULT_SINK@"

Volume.up = function ()
  local fd = assert(io.popen("pactl " .. " set-sink-volume " .. Volume.PAsinkName .. " +1%"))
  fd:close()
end

Volume.down = function ()
  local fd = assert(io.popen("pactl " .. " set-sink-volume " .. Volume.PAsinkName .. " -1%"))
  fd:close()
end

Volume.toggleMute = function ()
  local fd = assert(io.popen("pactl " .. " set-sink-mute " .. Volume.PAsinkName .. " toggle"))
  fd:close()
end

VolumePAsourceName = "@DEFAULT_SOURCE@"
MicrophoneToggleMute = function ()
  local fd = assert(io.popen("pactl " .. " set-source-mute " .. VolumePAsourceName .. " toggle"))
  fd:close()

  local fds = assert(io.popen("pactl " .. " get-source-mute " .. VolumePAsourceName))
  local muteStatus = fds:read("l")
  fds:close()
  naughty.notify({ preset = naughty.config.presets.notify, title = "Microphone " .. muteStatus, text = "" })
end

-- cpu usage graph
Mycpuwidget = wibox.widget.graph()
Mycpuwidget:set_width(75)
Mycpuwidget:set_background_color("#222222")
Mycpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 100, 0 }, stops = { {0, "#688ec6"}, {0.5, "#435b80"}, {1, "#29384e" }}})
vicious.cache(vicious.widgets.cpu)
vicious.register(Mycpuwidget, vicious.widgets.cpu, "$1", 1.37)

-- memory usage graph
Mymemwidget = wibox.widget.graph()
Mymemwidget:set_width(75)
Mymemwidget:set_background_color("#262626")
Mymemwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 100, 0 }, stops = { {0, "#6ec768"}, {0.5, "#478043"}, {1, "#2c4f29" }}})
vicious.cache(vicious.widgets.mem)
vicious.register(Mymemwidget, vicious.widgets.mem, "$1", 1.7)

-- -- network download graph
-- mynetwidget_down = wibox.widget.graph()
-- mynetwidget_down:set_width(50)
-- mynetwidget_down:set_background_color("#222222")
-- mynetwidget_down:set_color({ type = "linear", from = { 0, 0 }, to = { 1000000000000000, 0 }, stops = { {0, "#6ec768"}, {0.5, "#478043"}, {1, "#2c4f29" }}})
-- vicious.cache(vicious.widgets.net)
-- vicious.register(mynetwidget_down, vicious.widgets.net, "${enp0s20u1 down_kb}", 1.2)
-- 
-- -- network upload graph
-- mynetwidget_up = wibox.widget.graph()
-- mynetwidget_up:set_width(50)
-- mynetwidget_up:set_background_color("#262626")
-- mynetwidget_up:set_color({ type = "linear", from = { 0, 0 }, to = { 50000000, 0 }, stops = { {0, "#c7b968"}, {0.5, "#807743"}, {1, "#4f4a29" }}})
-- vicious.cache(vicious.widgets.net)
-- vicious.register(mynetwidget_up, vicious.widgets.net, "${enp0s20u1 up_b}", 1.2)
-- 
-- dnetwidget = wibox.widget.textbox()
-- vicious.register(dnetwidget, vicious.widgets.net, '${enp0s20u1 down_b}', 1)
-- netwidget = wibox.widget.textbox()
-- vicious.register(netwidget, vicious.widgets.net, '${enp0s20u1 up_b}', 1)

-- Create a textclock widget
Mytextclock = wibox.widget.textclock("[%a] %Y-%m-%d %H:%M", 31)

-- Create a wibox for each screen and add it
local taglist_buttons = Awful.util.table.join(
  Awful.button({        }, 1, function(t) t:view_only() end),
  Awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  Awful.button({        }, 3, Awful.tag.viewtoggle),
  Awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  Awful.button({        }, 4, function(t) Awful.tag.viewnext(t.screen) end), -- scroll up
  Awful.button({        }, 5, function(t) Awful.tag.viewprev(t.screen) end), -- scroll down
  Awful.button({        }, 6, function(t) Awful.tag.viewprev(t.screen) end), -- scroll left
  Awful.button({        }, 7, function(t) Awful.tag.viewnext(t.screen) end)  -- scroll right
)

local tasklist_buttons = Awful.util.table.join(
  Awful.button({        }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
      end
      -- This will also un-minimize
      -- the client, if needed
      client.focus = c
      c:raise()
    end
  end),
  Awful.button({        }, 3, client_menu_toggle_fn()),
  Awful.button({        }, 4, function () Awful.client.focus.byidx(1) end),
  Awful.button({        }, 5, function () Awful.client.focus.byidx(-1) end)
)

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    Gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

Awful.screen.connect_for_each_screen(
  function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    Awful.tag(tagnames, s, Awful.layout.layouts[1])

    -- Set non-default tag layouts
    if s.index == screen_tools then
      Awful.tag.find_by_name(s, tag_soundtools).layout = Awful.layout.suit.tile

      local t_mon = Awful.tag.find_by_name(s, tag_monitoring)
      t_mon.layout = Awful.layout.suit.tile.bottom
      t_mon.master_width_factor = 0.76
    end
    if multi_screens and s.index == screen_monitoring then
      local t_mon = Awful.tag.find_by_name(s, tag_monitoring)
      t_mon.layout = Awful.layout.suit.tile
      t_mon.master_width_factor = 0.55
    end

    -- Create a promptbox for each screen
    s.mypromptbox = Awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = Awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(
      Awful.util.table.join(
        Awful.button({        }, 1, function () Awful.layout.inc( 1) end),
        Awful.button({        }, 3, function () Awful.layout.inc(-1) end)
        -- never use mousewheel to change layout and it just happens accidentally since it's right next to taglist of other screen
        -- Awful.button({        }, 4, function () Awful.layout.inc( 1) end),
        -- Awful.button({        }, 5, function () Awful.layout.inc(-1) end)
      )
    )
    -- Create a taglist widget
    s.mytaglist = Awful.widget.taglist(s, Awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = Awful.widget.tasklist(s, Awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = Awful.wibar({ height = 20, position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        s.mytaglist,
        s.mypromptbox,
        -- mynetwidget_down,
        -- mynetwidget_up,
        -- dnetwidget,
        -- netwidget,
        Mymemwidget,
        Mycpuwidget,
      },
      s.mytasklist, -- Middle widget
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray(),
        Mykeyboardlayout,
        Mytextclock,
        s.mylayoutbox,
      },
    }
  end
)
-- }}}

-- {{{ Mouse bindings
root.buttons(
  Awful.util.table.join(
    Awful.button({        }, 3, function () Mymainmenu:toggle() end)
  )
)
-- }}}

-- {{{ Key bindings
Globalkeys = Awful.util.table.join(
  -- awesome
  Awful.key({ modkey, "Shift"         }, "/", hotkeys_popup.show_help, {description="show help", group="awesome"}),
  Awful.key({ modkey                  }, "p", function() menubar.show() end, {description = "show the menubar", group = "launcher"}),
  Awful.key({ modkey, "Control"       }, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
  Awful.key({ modkey, "Control"       }, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),

  -- tag navigation
  Awful.key({ modkey,                 }, "Left",   Awful.tag.viewprev, {description = "view previous", group = "tag"}),
  Awful.key({ modkey,                 }, "h",      Awful.tag.viewprev, {description = "view previous", group = "tag"}),
  Awful.key({ modkey,                 }, "Right",  Awful.tag.viewnext, {description = "view next", group = "tag"}),
  Awful.key({ modkey,                 }, "l",      Awful.tag.viewnext, {description = "view next", group = "tag"}),
  Awful.key({ modkey,                 }, "Escape", Awful.tag.history.restore, {description = "go back", group = "tag"}),

  -- focus / moving windows
  Awful.key({ modkey,                 }, "n", function () Awful.screen.focus_relative( 1) end, {description = "focus the next screen", group = "screen"}),
  Awful.key({ modkey, "Control"       }, "n", function () Awful.screen.focus_relative(-1) end, {description = "focus the previous screen", group = "screen"}),

  Awful.key({ modkey,                 }, "j", function () Awful.client.focus.byidx( 1) end, {description = "focus next by index", group = "client"}),
  -- Awful.key({ modkey,                 }, "j",
  --   function ()
  --     Awful.client.focus.byidx( 1)
  --     if client.focus then client.focus:raise() end
  --   end
  -- ),
  Awful.key({ modkey, "Shift"         }, "j", function () Awful.client.swap.byidx(  1) end, {description = "swap with next client by index", group = "client"}),

  Awful.key({ modkey,                 }, "k", function () Awful.client.focus.byidx(-1) end, {description = "focus previous by index", group = "client"}),
  -- Awful.key({ modkey,                 }, "k",
  --   function ()
  --     Awful.client.focus.byidx(-1)
  --     if client.focus then client.focus:raise() end
  --   end
  -- ),
  Awful.key({ modkey, "Shift"         }, "k", function () Awful.client.swap.byidx( -1) end, {description = "swap with previous client by index", group = "client"}),

  -- Layout manipulation
  --TODO find key: Awful.key({ modkey, "Shift"         }, "u", Awful.client.urgent.jumpto, {description = "jump to urgent client", group = "client"}),
  Awful.key({ modkey,                 }, "Tab",
    function ()
      Awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    {description = "go back", group = "client"}
  ),
  Awful.key({ modkey,                 }, "u",     function () Awful.tag.incmwfact( 0.05)          end, {description = "increase master width factor", group = "layout"}),
  Awful.key({ modkey,                 }, "i",     function () Awful.tag.incmwfact(-0.05)          end, {description = "decrease master width factor", group = "layout"}),
  Awful.key({ modkey, "Shift"         }, "u",     function () Awful.tag.incnmaster(-1, nil, true) end, {description = "increase the number of master clients", group = "layout"}),
  Awful.key({ modkey, "Shift"         }, "i",     function () Awful.tag.incnmaster( 1, nil, true) end, {description = "decrease the number of master clients", group = "layout"}),
  Awful.key({ modkey, "Control"       }, "u",     function () Awful.tag.incncol(-1, nil, true)    end, {description = "increase the number of columns", group = "layout"}),
  Awful.key({ modkey, "Control"       }, "u",     function () Awful.tag.incncol( 1, nil, true)    end, {description = "decrease the number of columns", group = "layout"}),
  Awful.key({ modkey,                 }, "space", function () Awful.layout.inc( 1)                end, {description = "select next", group = "layout"}),
  Awful.key({ modkey, "Shift"         }, "space", function () Awful.layout.inc(-1)                end, {description = "select previous", group = "layout"}),

  -- Prompts
  -- Awful.key({ modkey,                 }, "w",     function () Mymainmenu:show({keygrabber=true}) end),
  Awful.key({ modkey,                 }, "w",     function () Mymainmenu:show() end, {description = "show main menu", group = "awesome"}),

  Awful.key({ altkey,                 }, "F2",    function () Awful.screen.focused().mypromptbox:run() end, {description = "run prompt", group = "launcher"}),
  Awful.key({ altkey,                 }, "F1",
    function ()
      Awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = Awful.screen.focused().mypromptbox.widget,
        exe_callback = Awful.util.eval,
        history_path = Awful.util.get_cache_dir() .. "/history_eval",
      }
    end,
    {description = "lua execute prompt", group = "awesome"}
  ),

  -- Sound control
  Awful.key({                            }, "XF86AudioRaiseVolume", function () Volume.up() end),
  Awful.key({                            }, "XF86AudioLowerVolume", function () Volume.down() end),
  Awful.key({                            }, "XF86AudioMute", function () Volume.toggleMute() end),
  Awful.key({ "Shift"                    }, "XF86AudioMute", function () MicrophoneToggleMute() end),

  -- Media player controls
  Awful.key({                            }, "XF86AudioPlay",  function () Awful.spawn(audio_play) end),
  Awful.key({ modkey, "Control"          }, "KP_Delete",      function () Awful.spawn(audio_play) end),
  Awful.key({ modkey, "Control"          }, "KP_Decimal",     function () Awful.spawn(audio_play) end),
  Awful.key({                            }, "XF86AudioPause", function () Awful.spawn(audio_pause) end),
  Awful.key({ modkey, "Control"          }, "KP_Insert",      function () Awful.spawn(audio_pause) end),
  Awful.key({ modkey, "Control"          }, "KP_0",           function () Awful.spawn(audio_pause) end),
  Awful.key({ modkey, "Control"          }, "KP_Begin",       function () Awful.spawn(audio_playpause) end),
  Awful.key({ modkey, "Control"          }, "KP_5",           function () Awful.spawn(audio_playpause) end),
  Awful.key({                            }, "XF86AudioNext",  function () Awful.spawn(audio_next) end),
  Awful.key({ modkey, "Control"          }, "KP_Right",       function () Awful.spawn(audio_next) end),
  Awful.key({ modkey, "Control"          }, "KP_6",           function () Awful.spawn(audio_next) end),
  Awful.key({                            }, "XF86AudioPrev",  function () Awful.spawn(audio_prev) end),
  Awful.key({ modkey, "Control"          }, "KP_Left",        function () Awful.spawn(audio_prev) end),
  Awful.key({ modkey, "Control"          }, "KP_4",           function () Awful.spawn(audio_prev) end),

  -- Display brightness control
  Awful.key({                            }, "XF86MonBrightnessUp", function () Awful.spawn(inc_display_brightness) end),
  Awful.key({ "Shift"                    }, "XF86MonBrightnessUp", function () Awful.spawn(inc_display_brightness_fine) end),
  Awful.key({ "Control"                  }, "XF86MonBrightnessUp", function () Awful.spawn(inc_display_brightness_max) end),
  Awful.key({                            }, "XF86MonBrightnessDown", function () Awful.spawn(dec_display_brightness) end),
  Awful.key({ "Shift"                    }, "XF86MonBrightnessDown", function () Awful.spawn(dec_display_brightness_fine) end),
  Awful.key({ "Control"                  }, "XF86MonBrightnessDown", function () Awful.spawn(dec_display_brightness_zero); Awful.spawn(inc_display_brightness_fine);  end),

  -- Stop/Cont currently focused x11 window
  Awful.key({ modkey,                    }, "Pause", function () Awful.spawn(stop_focused_process) end),
  Awful.key({ modkey, "Shift"            }, "Pause", function () Awful.spawn(cont_focused_process) end),

  -- Removable Volume management (devmon)

  -- unmount/remove all removable devices
  Awful.key({ modkey, "Shift"            }, ",",        function () Awful.spawn('devmon --unmount-all --sync --exec-on-drive "notify-send \\"mount %l\\" \\"<b>%f</b> => <b>%d</b>\\"" --exec-on-unmount "notify-send \\"unmount %l\\" \\"<b>%f</b> => <b>%d</b>\\"" --exec-on-remove "notify-send \\"remove <b>%f</b>\\""') end),

  -- mount all removable devices
  Awful.key({ modkey, "Shift"            }, ".",        function () Awful.spawn('devmon --mount-all --sync --exec-on-drive "notify-send \\"mount %l\\" \\"<b>%f</b> => <b>%d</b>\\"" --exec-on-unmount "notify-send \\"unmount %l\\" \\"<b>%f</b> => <b>%d</b>\\"" --exec-on-remove "notify-send \\"remove <b>%f</b>\\""') end),


  -- Spawn programs

  -- Take Screenshot
  Awful.key({ modkey, "Shift"            }, "s",        function () Awful.spawn('gnome-screenshot --interactive --area') end),

  -- launch terminal
  Awful.key({ modkey,                    }, "Return",   function () Awful.spawn(terminal_cmd) end, {description = "open terminal", group = "launcher"}),
  Awful.key({ modkey,                    }, "KP_Enter", function () Awful.spawn(terminal_cmd) end, {description = "open terminal", group = "launcher"}),

  -- launch root terminal
  Awful.key({ modkey, "Shift"            }, "Return",   function () Awful.spawn(terminal_cmd_root) end),

  -- launch filemanager (primary)
  Awful.key({ modkey,                    }, "e",        function () Awful.spawn(filemanager_cmd1) end),

  -- launch filemanager (primary, root)
  Awful.key({ modkey, "Shift"            }, "e",        function () Awful.spawn(filemanager_cmd1_root) end),

  -- launch filemanager (alternative)
  Awful.key({ modkey,                    }, "d",        function () Awful.spawn(filemanager_cmd2) end),

  -- launch filemanager (alternative, root)
  Awful.key({ modkey, "Shift"            }, "d",        function () Awful.spawn(filemanager_cmd2_root) end),

  -- launch editor 2
  Awful.key({ modkey,                    }, "g",        function () Awful.spawn(editor_cmd2) end),

  -- launch root editor 2
  Awful.key({ modkey, "Shift"            }, "g",        function () Awful.spawn(editor_cmd2_root) end),

  -- -- -- launch editor 1
  Awful.key({ modkey, altkey             }, "g",        function () Awful.spawn(editor_cmd1) end),

  -- -- launch root editor 1
  Awful.key({ modkey, altkey, "Shift"    }, "g",        function () Awful.spawn(editor_cmd2_root) end),

  -- switch to german keyboard layout
  -- Awful.key({ modkey,                    }, "F11",      function () Awful.spawn(kbd_switch2_de_cmd) end),

  -- switch to russian keyboard layout
  -- Awful.key({ modkey, "Shift"            }, "F12",      function () Awful.spawn(kbd_switch2_ru_cmd) end),

  -- switch to us international keyboard layout
  Awful.key({ modkey,                    }, "F12",      function () Awful.spawn(kbd_switch2_us_cmd) end),

  -- switch to us,apl keyboard layout
  Awful.key({ modkey, "Shift"            }, "F11",      function () Awful.spawn(kbd_switch2_apl_cmd) end),

  -- launch eject
  Awful.key({ modkey,                    }, "y",        function () Awful.spawn(eject_cmd) end),

  -- kill firefox
  --Awful.key({ modkey, "Shift"            }, "f",        function () Awful.spawn(killallFirefox_cmd) end),

  -- launch htop
  --Awful.key({ "Control", "Shift"         }, "Escape",   function () Awful.spawn(terminal_cmd_stanalone .. " -e htop") end),
  --Awful.key({ "Control", "Shift", altkey }, "Escape",   function () Awful.spawn("gksudo '" .. terminal_cmd_stanalone .. " -e htop'") end),
  Awful.key({ "Control", "Shift"         }, "Escape",   function () Awful.spawn(terminal_cmd .. " --title 'htop' -e htop") end),
  Awful.key({ "Control", "Shift", altkey }, "Escape",   function () Awful.spawn(terminal_cmd .. " --title 'htop (root)' -e 'su -l root sh -c htop'") end),

  -- lock the screen
  Awful.key({ modkey,                    }, "z",        function () Awful.spawn(lock_screen_cmd) end),

  -- launch terminal calculator (python3)
  Awful.key({ modkey, "Shift"            }, "c",        function () Awful.spawn(terminal_cmd_stanalone .. " -e bpython -i etc/bpythonCalcPreload.py") end),

  -- launch speedcrunch
  Awful.key({ modkey,                    }, "c",        function () Awful.spawn("speedcrunch") end),

  -- launch sound related tools
  Awful.key({ modkey, "Shift"            }, "F"..tag_soundtools,    function ()
    Awful.spawn("sonobus")
    --os.execute("sleep .2") -- sleep to make window positions deterministic
    --if more_tools == true then Awful.spawn("easyeffects") end
    --os.execute("sleep .2")
    --if more_tools == true then Awful.spawn("pavucontrol") end
  end),

  -- launch pavucontrol
  Awful.key({ modkey,                    }, "F"..tag_soundtools,    function () Awful.spawn("pavucontrol") end),

  -- launch monitoring
  Awful.key({ modkey, "Shift"            }, "F"..tag_monitoring,    function ()
    Awful.spawn(terminal_cmd.." --title monitoring_nethogs nethogs_suid")
    os.execute("sleep .2") -- sleep to make window positions deterministic
    Awful.spawn(terminal_cmd.." --title monitoring_nvtop nvtop")
    os.execute("sleep .2")
    Awful.spawn(terminal_cmd.." --title monitoring_htop htop")
    os.execute("sleep .2")
    Awful.spawn("psensor")
  end),

  -- launch thunderbird
  Awful.key({ modkey,                    }, "F"..tag_communication, function () Awful.spawn("thunderbird") end),

  -- launch communication tools
  Awful.key({ modkey, "Shift"            }, "F"..tag_communication, function ()
    -- if more_tools == true then Awful.spawn("vencord") end
    Awful.spawn("telegram-desktop");
  end),

  -- launch firefox
  Awful.key({ modkey,                    }, "F4",       function () Awful.spawn(firefox_cmd_defaultProfile) end),

  -- launch firefox profile manager
  Awful.key({ modkey, "Shift"            }, "F4",       function () Awful.spawn(firefox_cmd_ProfileManager) end),

  -- launch chromium
  -- Awful.key({ modkey,                    }, "F4",       function () Awful.spawn("chromium --user-data-dir=\"" .. os.getenv("XDG_CONFIG_HOME") .. "/chromiumProfiles/default\"") end),

  -- launch chromium
  -- Awful.key({ modkey, "Shift"            }, "F4",       function () Awful.spawn("chromium --user-data-dir=\"" .. os.getenv("XDG_CONFIG_HOME") .. "/chromiumProfiles/work\"") end),

  -- launch audacious
  Awful.key({ modkey,                    }, "a",        function () Awful.spawn("audacious") end)
)

Clientkeys = Awful.util.table.join(
  -- move / resize floating windows; resizing of tiled windows can be found in the globalkeys table

  -- dec size Y
  Awful.key({ modkey,          altkey    }, "j",    function () Awful.client.moveresize(  0,   0,   0,  20) end),
  Awful.key({ modkey, "Shift", altkey    }, "j",    function () Awful.client.moveresize(  0,   0,   0,  60) end),

  -- inc size Y
  Awful.key({ modkey,          altkey    }, "k",    function () Awful.client.moveresize(  0,   0,   0, -20) end),
  Awful.key({ modkey, "Shift", altkey    }, "k",    function () Awful.client.moveresize(  0,   0,   0, -60) end),

  -- dec size X
  Awful.key({ modkey,          altkey    }, "l",    function () Awful.client.moveresize(  0,   0,  20,   0) end),
  Awful.key({ modkey, "Shift", altkey    }, "l",    function () Awful.client.moveresize(  0,   0,  60,   0) end),

  -- inc size X
  Awful.key({ modkey,          altkey    }, "h",    function () Awful.client.moveresize(  0,   0, -20,   0) end),
  Awful.key({ modkey, "Shift", altkey    }, "h",    function () Awful.client.moveresize(  0,   0, -60,   0) end),

  -- move left
  Awful.key({ modkey,          "Control" }, "h",    function () Awful.client.moveresize(-20,   0,   0,   0) end),
  Awful.key({ modkey, "Shift", "Control" }, "h",    function () Awful.client.moveresize(-60,   0,   0,   0) end),

  -- move right
  Awful.key({ modkey,          "Control" }, "l",    function () Awful.client.moveresize( 20,   0,   0,   0) end),
  Awful.key({ modkey, "Shift", "Control" }, "l",    function () Awful.client.moveresize( 60,   0,   0,   0) end),

  -- move down
  Awful.key({ modkey,          "Control" }, "j",    function () Awful.client.moveresize(  0,  20,   0,   0) end),
  Awful.key({ modkey, "Shift", "Control" }, "j",    function () Awful.client.moveresize(  0,  60,   0,   0) end),

  -- move up
  Awful.key({ modkey,          "Control" }, "k",    function () Awful.client.moveresize(  0, -20,   0,   0) end),
  Awful.key({ modkey, "Shift", "Control" }, "k",    function () Awful.client.moveresize(  0, -60,   0,   0) end),


  -- toggle titlebar TODO: needs further investigation
  --Awful.key({ modkey                     }, "Up",       function (c) end),


  -- Move client to screen
  Awful.key({ modkey, "Shift",        }, "n",        function (c) c:move_to_screen()               end, {description = "move to (next) screen", group = "client"}),


  -- layout things

  -- minimize client
  Awful.key({ modkey, altkey          }, "m",        function (c) c.minimized = true               end, {description = "minimize", group = "client"}),

  -- maximize client
  Awful.key({ modkey,                 }, "m",        function (c) c.maximized = true c:raise()     end, {description = "maximize", group = "client"}),

  -- get rid of any maximization (vertical, horizontal maximization or whichever)
  Awful.key({ modkey, "Shift"         }, "m",        function (c) c.maximized = false c:raise()    end, {description = "unmaximize", group = "client"}),

  -- toggle client fullscreen (causes confusion on some clients that are fullscreen aware themselfes)
  Awful.key({ modkey,                 }, "f",        function (c) c.fullscreen = not c.fullscreen c:raise() end, {description = "toggle fullscreen", group = "client"}),

  -- toggle sticky
  Awful.key({ modkey,                 }, "s",        function (c) c.sticky = not c.sticky          end),

  -- like the "x" in windows
  Awful.key({ modkey,                 }, "q",        function (c) c:kill()                         end, {description = "close", group = "client"}),

  -- toggle floating
  Awful.key({ modkey, "Control"       }, "space",    Awful.client.floating.toggle                     , {description = "toggle floating", group = "client"}),

  -- move the client with the focus to the "prime" position in the layout
  Awful.key({ modkey, "Control"       }, "Return",   function (c) c:swap(Awful.client.getmaster()) end, {description = "move to master", group = "client"}),

  -- force this client to redraw (doesn't exist anymore)
  --Awful.key({ modkey, "Shift"         }, "r",        function (c) c:redraw()                       end),

  -- toggle "keep this client on top all the time"
  Awful.key({ modkey,                 }, "t",        function (c) c.ontop = not c.ontop            end, {description = "toggle keep on top", group = "client"}),

  -- move window to the left/right workspace
  Awful.key({ modkey, "Shift"         }, "Left" ,    function () client_tag_moveLeft()  end ),
  Awful.key({ modkey, "Shift"         }, "h"    ,    function () client_tag_moveLeft()  end ),
  Awful.key({ modkey, "Shift"         }, "Right",    function () client_tag_moveRight() end ),
  Awful.key({ modkey, "Shift"         }, "l"    ,    function () client_tag_moveRight() end )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.

-- Some setup so it works for all top-row keys of my keyboard {{{
-- 9 + # of tag = keycodeForTag
KEYCODEOFFS = 9

-- Limit nr. of accessible tags via keys
MAXTAGKEY = 13 -- here: 1,...,9,0,-,=,<BS>

-- Compute the maximum number of digits we need
Keynumber = 0
for s = 1, screen.count() do
  Keynumber = math.min(MAXTAGKEY, math.max(#tagnames, Keynumber))
end
-- }}}

-- Bind all key numbers to tags.
for i = 1, Keynumber do
  Globalkeys = Awful.util.table.join(
    Globalkeys,

    -- View tag only.
    Awful.key({ modkey }, "#" .. i + KEYCODEOFFS,
      function ()
        local screen = Awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      {description = "view tag #"..i, group = "tag"}
    ),

    -- Toggle tag display.
    Awful.key({ modkey, "Control" }, "#" .. i + KEYCODEOFFS,
      function ()
        local screen = Awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          Awful.tag.viewtoggle(tag)
        end
      end,
      {description = "toggle tag #" .. i, group = "tag"}
    ),

    -- Move client to tag.
    Awful.key({ modkey, "Shift" }, "#" .. i + KEYCODEOFFS,
      function ()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      {description = "move focused client to tag #"..i, group = "tag"}
    ),

    -- Toggle tag on focused client.
    Awful.key({ modkey, "Control", "Shift" }, "#" .. i + KEYCODEOFFS,
      function ()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      {description = "toggle focused client on tag #" .. i, group = "tag"}
    )
  )
end

-- Mouse buttons
Clientbuttons = Awful.util.table.join(
  Awful.button({        }, 1, function (c) client.focus = c; c:raise() end),
  Awful.button({ modkey }, 1, Awful.mouse.client.move),
  Awful.button({ modkey }, 3, Awful.mouse.client.resize)
)

-- Set keys
root.keys(Globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
Awful.rules.rules = {
  {
    rule = { }, -- All clients will match this rule.
    properties = {
      size_hints_honor     = false,
      --maximized_vertical   = false, --breaks floating
      --maximized_horizontal = false,

      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus        = Awful.client.focus.filter,
      keys         = Clientkeys,
      buttons      = Clientbuttons,

      screen = Awful.screen.preferred,
      --placement = Awful.placement.no_overlap+Awful.placement.no_offscreen -- Never needed this.
    },
  }, {
    rule       = { name = "about", name = "About" },
    properties = { floating = true },
  }, {
    rule       = { class = "Audacious" },
    properties = { size_hints_honor = false },
  }, {
    rule       = { class = "feh" },
    properties = { floating = true },
  }, {
    rule       = { class = "Thunar", name = "File Operation Progress" },
    properties = { floating = true },
  }, {
    rule       = { class = "Pidgin" },
    properties = { floating = true },
  }, {
    rule       = { class = "libreoffice" },
    properties = { floating = false },
  }, {
    rule       = { class = "Xfdesktop" },
    properties = { floating = false, screen = 1, tag = "1" },
  }, {
    rule       = { class = "Xmessage" },
    properties = { floating = true },
  }, {
    rule       = { class = "pavucontrol"},
    properties = { screen = screen_tools, tag = tag_soundtools },
  }, {
    rule       = { class = "SonoBus"},
    properties = { screen = screen_tools, tag = tag_soundtools },
  }, {
    rule       = { class = "easyeffects"},
    properties = { screen = screen_tools, tag = tag_soundtools },
  }, {
    rule       = { class = "Audacious"},
    properties = { screen = screen_tools, tag = tag_soundtools },
  }, {
    rule       = { class = "Thunderbird"},
    properties = { screen = screen_tools, tag = tag_communication },
  }, {
    rule       = { class = "TeamSpeak 3"},
    properties = { screen = screen_tools, tag = tag_communication },
  }, {
    rule       = { name = "Telegram"},
    properties = { screen = screen_tools, tag = tag_communication },
  }, {
    rule       = { class = "vencorddesktop"},
    properties = { screen = screen_tools, tag = tag_communication },
  }, {
  }, {
    rule       = { class = "discord"},
    properties = { screen = screen_tools, tag = tag_communication },
  }, {
    -- Use for testing in awesome-client:
    -- for c in Awful.client.iterate(function (cl) return Awful.rules.match(cl, {class = "steam", name = "Friends List.*"}) end) do print(c) end
    -- The casing of both class and name is relevant for the match rule
    rule       = { class = "steam", name = "Friends List.*" },
    properties = { screen = screen_tools, tag = "4" },
  }, {
    rule       = { class = "kitty", name  = "monitoring_nvtop" },
    properties = { screen = screen_monitoring, tag = tag_monitoring },
  }, {
    rule       = { class = "Psensor" },
    properties = { screen = screen_monitoring, tag = tag_monitoring },
  }, {
    rule       = { class = "kitty", name  = "monitoring_htop" },
    properties = { screen = screen_monitoring, tag = tag_monitoring },
  }, {
    rule       = { class = "kitty", name  = "monitoring_nethogs" },
    properties = { screen = screen_monitoring, tag = tag_monitoring },
  }
  -- Preset rules TODO: maybe merge some of these
  -- { -- All clients will match this rule.
  --   rule = { },
  --   properties = {
  --     border_width = beautiful.border_width,
  --     border_color = beautiful.border_normal,
  --     focus = Awful.client.focus.filter,
  --     raise = true,
  --     keys = Clientkeys,
  --     buttons = Clientbuttons,
  --     screen = Awful.screen.preferred,
  --     placement = Awful.placement.no_overlap+Awful.placement.no_offscreen
  --   }
  -- },

  -- { -- Floating clients.
  --   rule_any = {
  --     instance = {
  --       "DTA",  -- Firefox addon DownThemAll.
  --       "copyq",  -- Includes session name in class.
  --     },
  --     class = {
  --       "Arandr",
  --       "Gpick",
  --       "Kruler",
  --       "MessageWin",  -- kalarm.
  --       "Sxiv",
  --       "Wpa_gui",
  --       "pinentry",
  --       "veromix",
  --       "xtightvncviewer"},

  --       name = {
  --         "Event Tester",  -- xev.
  --       },
  --       role = {
  --         "AlarmWindow",  -- Thunderbird's calendar.
  --         "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
  --       }
  --   },
  --   properties = {
  --     floating = true
  --   }
  -- },

  -- { -- Add titlebars to normal clients and dialogs
  --   rule_any = {
  --     type = {
  --       "normal",
  --       "dialog"
  --     }
  --   },
  --   properties = {
  --     titlebars_enabled = true
  --   }
  -- },


  -- { -- Set Firefox to always map on the tag named "2" on screen 1.
  --   rule = { class = "Firefox" },
  --   properties = { screen = 1, tag = "2" }
  -- },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
  "manage",
  function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then Awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      Awful.placement.no_offscreen(c)
    end
  end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
  "request::titlebars",
  function(c)
    -- buttons for the titlebar
    local buttons = Awful.util.table.join(
      Awful.button({ }, 1, function() client.focus = c c:raise() Awful.mouse.client.move(c) end),
      Awful.button({ }, 3, function() client.focus = c c:raise() Awful.mouse.client.resize(c) end)
    )

    Awful.titlebar(c) : setup {
      { -- Left
        Awful.titlebar.widget.iconwidget(c),
        buttons = buttons,
        layout  = wibox.layout.fixed.horizontal
      },
      { -- Middle
        { -- Title
          align  = "center",
          widget = Awful.titlebar.widget.titlewidget(c)
        },
        buttons = buttons,
        layout  = wibox.layout.flex.horizontal
      },
      { -- Right
        Awful.titlebar.widget.floatingbutton (c),
        Awful.titlebar.widget.maximizedbutton(c),
        Awful.titlebar.widget.minimizedbutton(c),
        Awful.titlebar.widget.stickybutton   (c),
        Awful.titlebar.widget.ontopbutton    (c),
        Awful.titlebar.widget.closebutton    (c),
        layout = wibox.layout.fixed.horizontal()
      },
      layout = wibox.layout.align.horizontal
    }
  end
)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal(
  "mouse::enter",
  function(c)
    if Awful.layout.get(c.screen) ~= Awful.layout.suit.magnifier and Awful.client.focus.filter(c) then
      client.focus = c
    end
  end
)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Hooks
-- timer_low = timer({ timeout = 10 })
-- timer_low:connect_signal("timeout", function() Awful.spawn("") end)
-- timer_low:start()
-- Hooks }}}

-- {{{ Autorun programs
Autorun = true
AutorunApps =
{
  "awesome_autostart",
  "xset -dpms",
  "xset s off",
}
if Autorun then
  for n = 1, #AutorunApps do
    Awful.spawn(AutorunApps[n])
  end
end
-- Autorun }}}
