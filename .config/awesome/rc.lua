-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")

-- Widget and layout library
wibox = require("wibox")

-- Theme handling library
beautiful = require("beautiful")

-- Notification library
naughty = require("naughty")
menubar = require("menubar")
hotkeys_popup = require("awful.hotkeys_popup").widget

-- widgets
vicious = require("vicious")


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

    errorstring = tostring(err) .. "\n\n" .. debug.traceback()

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
tagnames = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 'a', 'b', 'c', }

-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.getdir("config") .. "/themes/my_default_2.0/theme.lua")

-- Application launches
editor_cmd1 = "nvim-qt"
editor_cmd2 = "kitty -e nvim"
editor_cmd2_root = "kitty -e 'bash -c \"sudo -i nvim\"'"
filemanager_cmd1 = "thunar"
filemanager_cmd1_root = "gksudo thunar"
filemanager_cmd2 = "spacefm"
filemanager_cmd2_root = "spacefm"
terminal_cmd = "kitty"
terminal_cmd_root = "kitty -e bash -c 'su -l root'"
terminal_cmd_stanalone = "kitty"
firefox_cmd_defaultProfile = "firefox -P entertainment --new-instance"
firefox_cmd_ProfileManager = "firefox --ProfileManager --new-instance"

-- Tool launches
inc_display_brightness = "light -A 4"
inc_display_brightness_fine = "light -r -A 1"
inc_display_brightness_max = "light -S 100"
dec_display_brightness = "light -U 4"
dec_display_brightness_fine = "light -r -U 1"
dec_display_brightness_zero = "light -S 0"
maxBrightness_cmd = "light -S 100"
minBrightness_cmd = "light -r -S 1"
stop_focused_process = "bash -c 'kill -STOP $(xdotool getwindowpid $(xdotool getwindowfocus))'"
cont_focused_process = "bash -c 'kill -CONT $(xdotool getwindowpid $(xdotool getwindowfocus))'"
audio_play = "playerctl --all-players play"
audio_pause = "playerctl --all-players pause"
audio_playpause = "playerctl --all-players play-pause"
audio_next = "playerctl --all-players next"
audio_prev = "playerctl --all-players previous"

-- Commands to switch to specific keyboard layout for this session.
-- TODO perhaps these should be more like this: localectl set-x11-keymap us pc104 altgr-intl
kbd_switch2_de_cmd  = "setxkbmap -model pc104 -layout de -option"
kbd_switch2_ru_cmd  = "setxkbmap -model pc104 -layout ru -option"
kbd_switch2_us_cmd  = "setxkbmap -model pc104 -layout us -variant altgr-intl -option"
kbd_switch2_apl_cmd = "setxkbmap -model pc104 -layout us,apl -variant altgr-intl -option grp:rctrl_toggle"
-- kbd_switch2_de_cmd = "localectl set-x11-keymap de pc104"
-- kbd_switch2_ru_cmd = "localectl set-x11-keymap ru pc104"
-- kbd_switch2_us_cmd = "localectl set-x11-keymap us pc104 altgr-intl"

eject_cmd = "eject -T"

killallFlash_cmd = "killall plugin-container"
killallFirefox_cmd = "killall firefox"

lock_screen_cmd = "slock"


bootNextWIN_cmd = "K_setBootnext 0000"
bootNextLINUX_cmd = "K_setBootnext 0002"


suspend_disk_cmd = "suspend_disk"
suspend_ram_cmd = "suspend_ram"
shutdown_cmd = "systemctl poweroff"
reboot_cmd  = "systemctl reboot"
kexec_cmd = "sudo kexec --append=\"$(cat /proc/cmdline)\" /boot/vmlinuz-linux"

etc_shutdown_cmd = "gksudo K_etc_shutdown"
lock_suspend_disk_cmd = "suspend_disk l"
lock_suspend_ram_cmd = "suspend_ram l"

notifySendWmNameAndWmClass_cmd = "notifySendWmNameAndWmClass"

tag_soundtools = "1"
tag_monitoring = "2"
tag_communication = "3"

if os.getenv("USER") == 'md' then
  screen_tools = 2
  more_tools = true
else
  screen_tools = 1
end

-- Wibar width (right-click menu on taskbar)
local wibar_width = 550


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.max,
  awful.layout.suit.floating,
  --awful.layout.suit.magnifier,
  --awful.layout.suit.spiral.dwindle,
  --awful.layout.suit.spiral,
  --awful.layout.suit.fair.horizontal,
  --awful.layout.suit.fair,
  awful.layout.suit.tile.bottom,
  --awful.layout.suit.tile.top,
  --awful.layout.suit.tile.left,
  awful.layout.suit.tile,
  --awful.layout.suit.grid,
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
      instance = awful.menu.clients({ theme = { width = wibar_width } })
    end
  end
end


local function client_rel_send(rel_idx)
  local client = client.focus
  local focused = awful.screen.focused()
  if client then 
    local scr = client.screen or focused.index
    local sel_idx = focused.selected_tag.index
    local tags = awful.tag.gettags(scr)
    local target = awful.util.cycle(#tags, sel_idx + rel_idx)
    awful.client.movetotag(tags[target], client)
    awful.tag.viewonly(tags[target])
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

awful.menu.menu_keys = {
  up    = { "k", "Up" },
  down  = { "j", "Down" },
  exec  = { "l", "Return", "Right" },
  enter = { "l", "Right" },
  back  = { "h", "Left" },
  close = { "q", "Escape" },
}

-- Create a launcher widget and a main menu
myawesomemenu = {
  { "manual", terminal_cmd .. " -e man awesome" },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end },
}

mytoolsmenu = {
  { "edit config", editor_cmd2 .. " " .. awesome.conffile },
  { "wm info", notifySendWmNameAndWmClass_cmd },
  { "max brightness", maxBrightness_cmd },
  { "min brightness", minBrightness_cmd },
}

myplusmenu = {
  { "bootNext|WIN", bootNextWIN_cmd },
  { "bootNext|LINUX", bootNextLINUX_cmd },
  { "etc,shutdown", etc_shutdown_cmd },
  { "lock,hibernate", lock_suspend_disk_cmd },
  { "lock,suspend", lock_suspend_ram_cmd },
}

mymainmenu = awful.menu ({
  items = {
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "tools", mytoolsmenu },
    { "+", myplusmenu },
    { "hibernate", suspend_disk_cmd },
    { "suspend", suspend_ram_cmd },
    { "shutdown", shutdown_cmd },
    { "reboot", reboot_cmd },
    -- { "kexec", kexec_cmd },
  }
})

-- TODO: figuire out what this is, remove it
mylauncher = awful.widget.launcher(
{
  image = beautiful.awesome_icon,
  menu = mymainmenu,
}
)

-- Menubar configuration
menubar.utils.terminal = terminal_cmd_stanalone -- Set the terminal for applications that require it
-- }}}

-- {{{ Keyboard map indicator

-- Keyboard map indicator and switcher TODO: This sounds interessting
-- mykeyboardlayout = awful.widget.keyboardlayout()
mykeyboardlayout = awful.widget.keyboardlayout:new()

-- }}}

-- {{{ Wibar

-- volume change
volume = {}
-- volume.PAsinkName = "alsa_output.pci-0000_00_1b.0.analog-stereo" -- Would be awesome if we could dynamically figure out the default sink...
-- volume.PAsinkName = "alsa_output.pci-0000_00_1b.0.output_analog-stereo" -- New pipewire name, find it with pactl list | grep Output
-- TODO: Would be really cool to find a pure piewire way that is not
-- `pw-cli s <node-id> Props { mute: false, channelVolumes: [ 0.3, 0.3 ] }`
-- where <node-id> is literally a number i have to figure out with pw-cli ls (prop names are ok, list them with `pw-cli e <node-id>`)
volume.PAsinkName = "@DEFAULT_SINK@" -- Looks like I found it

volume.up = function ()
  fd = io.popen("pactl " .. " set-sink-volume " .. volume.PAsinkName .. " +1%")
  fd:close()
end

volume.down = function ()
  fd = io.popen("pactl " .. " set-sink-volume " .. volume.PAsinkName .. " -1%")
  fd:close()
end

volume.toggleMute = function ()
  fd = io.popen("pactl " .. " set-sink-mute " .. volume.PAsinkName .. " toggle")
  fd:close()
end

-- cpu usage graph
mycpuwidget = wibox.widget.graph()
mycpuwidget:set_width(75)
mycpuwidget:set_background_color("#222222")
mycpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 100, 0 }, stops = { {0, "#688ec6"}, {0.5, "#435b80"}, {1, "#29384e" }}})
vicious.cache(vicious.widgets.cpu)
vicious.register(mycpuwidget, vicious.widgets.cpu, "$1", 1.37)

-- memory usage graph
mymemwidget = wibox.widget.graph()
mymemwidget:set_width(75)
mymemwidget:set_background_color("#262626")
mymemwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 100, 0 }, stops = { {0, "#6ec768"}, {0.5, "#478043"}, {1, "#2c4f29" }}})
vicious.cache(vicious.widgets.mem)
vicious.register(mymemwidget, vicious.widgets.mem, "$1", 1.7)

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
mytextclock = wibox.widget.textclock("[%a] %Y-%m-%d %H:%M", 31)

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
  awful.button({        }, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({        }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({        }, 4, function(t) awful.tag.viewnext(t.screen) end), -- scroll up
  awful.button({        }, 5, function(t) awful.tag.viewprev(t.screen) end), -- scroll down
  awful.button({        }, 6, function(t) awful.tag.viewprev(t.screen) end), -- scroll left
  awful.button({        }, 7, function(t) awful.tag.viewnext(t.screen) end)  -- scroll right
)

local tasklist_buttons = awful.util.table.join(
  awful.button({        }, 1, function (c)
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
  awful.button({        }, 3, client_menu_toggle_fn()),
  awful.button({        }, 4, function () awful.client.focus.byidx(1) end),
  awful.button({        }, 5, function () awful.client.focus.byidx(-1) end)
)

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(
  function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag(tagnames, s, awful.layout.layouts[1])

    -- Set non-default tag layouts
    if s.index == screen_tools then
      awful.tag.find_by_name(s, tag_soundtools).layout = awful.layout.suit.tile
      awful.tag.find_by_name(s, tag_monitoring).layout = awful.layout.suit.tile.bottom
    end

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(
      awful.util.table.join(
        awful.button({        }, 1, function () awful.layout.inc( 1) end),
        awful.button({        }, 3, function () awful.layout.inc(-1) end),
        awful.button({        }, 4, function () awful.layout.inc( 1) end),
        awful.button({        }, 5, function () awful.layout.inc(-1) end)
      )
    )
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ height = 20, position = "top", screen = s })

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
        mymemwidget,
        mycpuwidget,
      },
      s.mytasklist, -- Middle widget
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray(),
        mykeyboardlayout,
        mytextclock,
        s.mylayoutbox,
      },
    }
  end
)
-- }}}

-- {{{ Mouse bindings
root.buttons(
  awful.util.table.join(
    awful.button({        }, 3, function () mymainmenu:toggle() end)
  )
)
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
  -- awesome
  awful.key({ modkey, "Shift"         }, "/", hotkeys_popup.show_help, {description="show help", group="awesome"}),
  awful.key({ modkey                  }, "p", function() menubar.show() end, {description = "show the menubar", group = "launcher"}),
  awful.key({ modkey, "Control"       }, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
  awful.key({ modkey, "Control"       }, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),

  -- tag navigation
  awful.key({ modkey,                 }, "Left",   awful.tag.viewprev, {description = "view previous", group = "tag"}),
  awful.key({ modkey,                 }, "h",      awful.tag.viewprev, {description = "view previous", group = "tag"}),
  awful.key({ modkey,                 }, "Right",  awful.tag.viewnext, {description = "view next", group = "tag"}),
  awful.key({ modkey,                 }, "l",      awful.tag.viewnext, {description = "view next", group = "tag"}),
  awful.key({ modkey,                 }, "Escape", awful.tag.history.restore, {description = "go back", group = "tag"}),

  -- focus / moving windows
  awful.key({ modkey,                 }, "n", function () awful.screen.focus_relative( 1) end, {description = "focus the next screen", group = "screen"}),
  awful.key({ modkey, "Control"       }, "n", function () awful.screen.focus_relative(-1) end, {description = "focus the previous screen", group = "screen"}),

  awful.key({ modkey,                 }, "j", function () awful.client.focus.byidx( 1) end, {description = "focus next by index", group = "client"}),
  -- awful.key({ modkey,                 }, "j",
  --   function ()
  --     awful.client.focus.byidx( 1)
  --     if client.focus then client.focus:raise() end
  --   end
  -- ),
  awful.key({ modkey, "Shift"         }, "j", function () awful.client.swap.byidx(  1) end, {description = "swap with next client by index", group = "client"}),

  awful.key({ modkey,                 }, "k", function () awful.client.focus.byidx(-1) end, {description = "focus previous by index", group = "client"}),
  -- awful.key({ modkey,                 }, "k",
  --   function ()
  --     awful.client.focus.byidx(-1)
  --     if client.focus then client.focus:raise() end
  --   end
  -- ),
  awful.key({ modkey, "Shift"         }, "k", function () awful.client.swap.byidx( -1) end, {description = "swap with previous client by index", group = "client"}),

  -- Layout manipulation
  --TODO find key: awful.key({ modkey, "Shift"         }, "u", awful.client.urgent.jumpto, {description = "jump to urgent client", group = "client"}),
  awful.key({ modkey,                 }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    {description = "go back", group = "client"}
  ),
  awful.key({ modkey,                 }, "u",     function () awful.tag.incmwfact( 0.05)          end, {description = "increase master width factor", group = "layout"}),
  awful.key({ modkey,                 }, "i",     function () awful.tag.incmwfact(-0.05)          end, {description = "decrease master width factor", group = "layout"}),          
  awful.key({ modkey, "Shift"         }, "u",     function () awful.tag.incnmaster(-1, nil, true) end, {description = "increase the number of master clients", group = "layout"}), 
  awful.key({ modkey, "Shift"         }, "i",     function () awful.tag.incnmaster( 1, nil, true) end, {description = "decrease the number of master clients", group = "layout"}), 
  awful.key({ modkey, "Control"       }, "u",     function () awful.tag.incncol(-1, nil, true)    end, {description = "increase the number of columns", group = "layout"}),        
  awful.key({ modkey, "Control"       }, "u",     function () awful.tag.incncol( 1, nil, true)    end, {description = "decrease the number of columns", group = "layout"}),        
  awful.key({ modkey,                 }, "space", function () awful.layout.inc( 1)                end, {description = "select next", group = "layout"}),                           
  awful.key({ modkey, "Shift"         }, "space", function () awful.layout.inc(-1)                end, {description = "select previous", group = "layout"}),                       

  -- Prompts
  -- awful.key({ modkey,                 }, "w",     function () mymainmenu:show({keygrabber=true}) end),
  awful.key({ modkey,                 }, "w",     function () mymainmenu:show() end, {description = "show main menu", group = "awesome"}),

  awful.key({ altkey,                 }, "F2",    function () awful.screen.focused().mypromptbox:run() end, {description = "run prompt", group = "launcher"}),
  awful.key({ altkey,                 }, "F1",
    function ()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval",
      }
    end,
    {description = "lua execute prompt", group = "awesome"}
  ),

  -- Sound control
  awful.key({                            }, "XF86AudioRaiseVolume", function () volume.up() end),
  awful.key({                            }, "XF86AudioLowerVolume", function () volume.down() end),
  awful.key({                            }, "XF86AudioMute", function () volume.toggleMute() end),

  -- Media player controls
  awful.key({                            }, "XF86AudioPlay",  function () awful.spawn(audio_play) end),
  awful.key({ modkey, "Control"          }, "KP_Delete",      function () awful.spawn(audio_play) end),
  awful.key({ modkey, "Control"          }, "KP_Decimal",     function () awful.spawn(audio_play) end),
  awful.key({                            }, "XF86AudioPause", function () awful.spawn(audio_pause) end),
  awful.key({ modkey, "Control"          }, "KP_Insert",      function () awful.spawn(audio_pause) end),
  awful.key({ modkey, "Control"          }, "KP_0",           function () awful.spawn(audio_pause) end),
  awful.key({ modkey, "Control"          }, "KP_Begin",       function () awful.spawn(audio_playpause) end),
  awful.key({ modkey, "Control"          }, "KP_5",           function () awful.spawn(audio_playpause) end),
  awful.key({                            }, "XF86AudioNext",  function () awful.spawn(audio_next) end),
  awful.key({ modkey, "Control"          }, "KP_Right",       function () awful.spawn(audio_next) end),
  awful.key({ modkey, "Control"          }, "KP_6",           function () awful.spawn(audio_next) end),
  awful.key({                            }, "XF86AudioPrev",  function () awful.spawn(audio_prev) end),
  awful.key({ modkey, "Control"          }, "KP_Left",        function () awful.spawn(audio_prev) end),
  awful.key({ modkey, "Control"          }, "KP_4",           function () awful.spawn(audio_prev) end),

  -- Display brightness control
  awful.key({                            }, "XF86MonBrightnessUp", function () awful.spawn(inc_display_brightness) end),
  awful.key({ "Shift"                    }, "XF86MonBrightnessUp", function () awful.spawn(inc_display_brightness_fine) end),
  awful.key({ "Control"                  }, "XF86MonBrightnessUp", function () awful.spawn(inc_display_brightness_max) end),
  awful.key({                            }, "XF86MonBrightnessDown", function () awful.spawn(dec_display_brightness) end),
  awful.key({ "Shift"                    }, "XF86MonBrightnessDown", function () awful.spawn(dec_display_brightness_fine) end),
  awful.key({ "Control"                  }, "XF86MonBrightnessDown", function () awful.spawn(dec_display_brightness_zero); awful.spawn(inc_display_brightness_fine);  end),

  -- Stop/Cont currently focused x11 window
  awful.key({ modkey,                    }, "Pause", function () awful.spawn(stop_focused_process) end),
  awful.key({ modkey, "Shift"            }, "Pause", function () awful.spawn(cont_focused_process) end),

  -- Removable Volume management (devmon)

  -- unmount/remove all removable devices
  awful.key({ modkey, "Shift"            }, ",",        function () awful.spawn('devmon --unmount-all --sync --exec-on-drive "notify-send \\"mount %l\\" \\"<b>%f</b> => <b>%d</b>\\"" --exec-on-unmount "notify-send \\"unmount %l\\" \\"<b>%f</b> => <b>%d</b>\\"" --exec-on-remove "notify-send \\"remove <b>%f</b>\\""') end),

  -- mount all removable devices
  awful.key({ modkey, "Shift"            }, ".",        function () awful.spawn('devmon --mount-all --sync --exec-on-drive "notify-send \\"mount %l\\" \\"<b>%f</b> => <b>%d</b>\\"" --exec-on-unmount "notify-send \\"unmount %l\\" \\"<b>%f</b> => <b>%d</b>\\"" --exec-on-remove "notify-send \\"remove <b>%f</b>\\""') end),


  -- Spawn programs

  -- Take Screenshot
  awful.key({ modkey, "Shift"            }, "s",        function () awful.spawn('gnome-screenshot --interactive --area') end),

  -- launch terminal
  awful.key({ modkey,                    }, "Return",   function () awful.spawn(terminal_cmd) end, {description = "open terminal", group = "launcher"}),
  awful.key({ modkey,                    }, "KP_Enter", function () awful.spawn(terminal_cmd) end, {description = "open terminal", group = "launcher"}),

  -- launch root terminal
  awful.key({ modkey, "Shift"            }, "Return",   function () awful.spawn(terminal_cmd_root) end),

  -- launch filemanager (primary)
  awful.key({ modkey,                    }, "e",        function () awful.spawn(filemanager_cmd1) end),

  -- launch filemanager (primary, root)
  awful.key({ modkey, "Shift"            }, "e",        function () awful.spawn(filemanager_cmd1_root) end),

  -- launch filemanager (alternative)
  awful.key({ modkey,                    }, "d",        function () awful.spawn(filemanager_cmd2) end),

  -- launch filemanager (alternative, root)
  awful.key({ modkey, "Shift"            }, "d",        function () awful.spawn(filemanager_cmd2_root) end),

  -- launch editor 2
  awful.key({ modkey,                    }, "g",        function () awful.spawn(editor_cmd2) end),

  -- launch root editor 2
  awful.key({ modkey, "Shift"            }, "g",        function () awful.spawn(editor_cmd2_root) end),

  -- -- -- launch editor 1
  awful.key({ modkey, altkey             }, "g",        function () awful.spawn(editor_cmd1) end),

  -- -- launch root editor 1
  awful.key({ modkey, altkey, "Shift"    }, "g",        function () awful.spawn(editor_cmd2_root) end),

  -- switch to german keyboard layout
  awful.key({ modkey,                    }, "F11",      function () awful.spawn(kbd_switch2_de_cmd) end),

  -- switch to russian keyboard layout
  awful.key({ modkey, "Shift"            }, "F12",      function () awful.spawn(kbd_switch2_ru_cmd) end),

  -- switch to us international keyboard layout
  awful.key({ modkey,                    }, "F12",      function () awful.spawn(kbd_switch2_us_cmd) end),

  -- switch to us,apl keyboard layout
  awful.key({ modkey, "Shift"            }, "F11",      function () awful.spawn(kbd_switch2_apl_cmd) end),

  -- launch eject
  awful.key({ modkey,                    }, "y",        function () awful.spawn(eject_cmd) end),

  -- kill firefox
  --awful.key({ modkey, "Shift"            }, "f",        function () awful.spawn(killallFirefox_cmd) end),

  -- kill firefox flashplugins
  -- awful.key({ modkey, "Shift"            }, "v",        function () awful.spawn(killallFlash_cmd) end),

  -- launch htop
  --awful.key({ "Control", "Shift"         }, "Escape",   function () awful.spawn(terminal_cmd_stanalone .. " -e htop") end),
  --awful.key({ "Control", "Shift", altkey }, "Escape",   function () awful.spawn("gksudo '" .. terminal_cmd_stanalone .. " -e htop'") end),
  awful.key({ "Control", "Shift"         }, "Escape",   function () awful.spawn(terminal_cmd .. " --title 'htop' -e htop") end),
  awful.key({ "Control", "Shift", altkey }, "Escape",   function () awful.spawn(terminal_cmd .. " --title 'htop (root)' -e 'su -l root sh -c htop'") end),

  -- lock the screen
  awful.key({ modkey,                    }, "z",        function () awful.spawn(lock_screen_cmd) end),

  -- launch terminal calculator (python3)
  awful.key({ modkey, "Shift"            }, "c",        function () awful.spawn(terminal_cmd_stanalone .. " -e bpython -i etc/bpythonCalcPreload.py") end),

  -- launch speedcrunch
  awful.key({ modkey,                    }, "c",        function () awful.spawn("speedcrunch") end),

  -- launch sound related tools
  awful.key({ modkey, "Shift"            }, "F"..tag_soundtools,    function ()
    awful.spawn("sonobus")
    --os.execute("sleep .2") -- sleep to make window positions deterministic
    --if more_tools == true then awful.spawn("easyeffects") end
    --os.execute("sleep .2")
    --if more_tools == true then awful.spawn("pavucontrol") end
  end),

  -- launch pavucontrol
  awful.key({ modkey,                    }, "F"..tag_soundtools,    function () awful.spawn("pavucontrol") end),

  -- launch monitoring
  awful.key({ modkey, "Shift"            }, "F"..tag_monitoring,    function ()
    awful.spawn(terminal_cmd.." --title monitoring_nethogs nethogs_suid")
    os.execute("sleep .2") -- sleep to make window positions deterministic
    awful.spawn(terminal_cmd.." --title monitoring_nvtop nvtop")
    os.execute("sleep .2")
    awful.spawn(terminal_cmd.." --title monitoring_htop htop")
  end),

  -- launch thunderbird
  awful.key({ modkey,                    }, "F"..tag_communication, function () awful.spawn("thunderbird") end),

  -- launch communication tools
  awful.key({ modkey, "Shift"            }, "F"..tag_communication, function ()
    if more_tools == true then awful.spawn("vencord") end
    awful.spawn("telegram-desktop");
  end),

  -- launch firefox
  awful.key({ modkey,                    }, "F4",       function () awful.spawn(firefox_cmd_defaultProfile) end),

  -- launch firefox profile manager
  awful.key({ modkey, "Shift"            }, "F4",       function () awful.spawn(firefox_cmd_ProfileManager) end),

  -- launch chromium
  -- awful.key({ modkey,                    }, "F4",       function () awful.spawn("chromium --user-data-dir=\"" .. os.getenv("XDG_CONFIG_HOME") .. "/chromiumProfiles/default\"") end),

  -- launch chromium
  -- awful.key({ modkey, "Shift"            }, "F4",       function () awful.spawn("chromium --user-data-dir=\"" .. os.getenv("XDG_CONFIG_HOME") .. "/chromiumProfiles/work\"") end),

  -- launch audacious
  awful.key({ modkey,                    }, "a",        function () awful.spawn("audacious") end)
)

clientkeys = awful.util.table.join(
  -- move / resize floating windows; resizing of tiled windows can be found in the globalkeys table

  -- dec size Y
  awful.key({ modkey,          altkey    }, "j",    function () awful.client.moveresize(  0,   0,   0,  20) end),
  awful.key({ modkey, "Shift", altkey    }, "j",    function () awful.client.moveresize(  0,   0,   0,  60) end),

  -- inc size Y
  awful.key({ modkey,          altkey    }, "k",    function () awful.client.moveresize(  0,   0,   0, -20) end),
  awful.key({ modkey, "Shift", altkey    }, "k",    function () awful.client.moveresize(  0,   0,   0, -60) end),

  -- dec size X
  awful.key({ modkey,          altkey    }, "l",    function () awful.client.moveresize(  0,   0,  20,   0) end),
  awful.key({ modkey, "Shift", altkey    }, "l",    function () awful.client.moveresize(  0,   0,  60,   0) end),

  -- inc size X
  awful.key({ modkey,          altkey    }, "h",    function () awful.client.moveresize(  0,   0, -20,   0) end),
  awful.key({ modkey, "Shift", altkey    }, "h",    function () awful.client.moveresize(  0,   0, -60,   0) end),

  -- move left
  awful.key({ modkey,          "Control" }, "h",    function () awful.client.moveresize(-20,   0,   0,   0) end),
  awful.key({ modkey, "Shift", "Control" }, "h",    function () awful.client.moveresize(-60,   0,   0,   0) end),

  -- move right
  awful.key({ modkey,          "Control" }, "l",    function () awful.client.moveresize( 20,   0,   0,   0) end),
  awful.key({ modkey, "Shift", "Control" }, "l",    function () awful.client.moveresize( 60,   0,   0,   0) end),

  -- move down
  awful.key({ modkey,          "Control" }, "j",    function () awful.client.moveresize(  0,  20,   0,   0) end),
  awful.key({ modkey, "Shift", "Control" }, "j",    function () awful.client.moveresize(  0,  60,   0,   0) end),

  -- move up
  awful.key({ modkey,          "Control" }, "k",    function () awful.client.moveresize(  0, -20,   0,   0) end),
  awful.key({ modkey, "Shift", "Control" }, "k",    function () awful.client.moveresize(  0, -60,   0,   0) end),


  -- toggle titlebar TODO: needs further investigation
  --awful.key({ modkey                     }, "Up",       function (c) end),


  -- Move client to screen
  awful.key({ modkey, "Shift",        }, "n",        function (c) c:move_to_screen()               end, {description = "move to (next) screen", group = "client"}),


  -- layout things
  
  -- minimize client
  awful.key({ modkey, altkey          }, "m",        function (c) c.minimized = true               end, {description = "minimize", group = "client"}),

  -- maximize client
  awful.key({ modkey,                 }, "m",        function (c) c.maximized = true c:raise()     end, {description = "maximize", group = "client"}),

  -- get rid of any maximization (vertical, horizontal maximization or whichever)
  awful.key({ modkey, "Shift"         }, "m",        function (c) c.maximized = false c:raise()    end, {description = "unmaximize", group = "client"}),

  -- toggle client fullscreen (causes confusion on some clients that are fullscreen aware themselfes)
  awful.key({ modkey,                 }, "f",        function (c) c.fullscreen = not c.fullscreen c:raise() end, {description = "toggle fullscreen", group = "client"}),

  -- toggle sticky
  awful.key({ modkey,                 }, "s",        function (c) c.sticky = not c.sticky          end),

  -- like the "x" in windows
  awful.key({ modkey,                 }, "q",        function (c) c:kill()                         end, {description = "close", group = "client"}),

  -- toggle floating
  awful.key({ modkey, "Control"       }, "space",    awful.client.floating.toggle                     , {description = "toggle floating", group = "client"}),

  -- move the client with the focus to the "prime" position in the layout
  awful.key({ modkey, "Control"       }, "Return",   function (c) c:swap(awful.client.getmaster()) end, {description = "move to master", group = "client"}),

  -- force this client to redraw (doesn't exist anymore)
  --awful.key({ modkey, "Shift"         }, "r",        function (c) c:redraw()                       end),

  -- toggle "keep this client on top all the time"
  awful.key({ modkey,                 }, "t",        function (c) c.ontop = not c.ontop            end, {description = "toggle keep on top", group = "client"}),

  -- move window to the left/right workspace
  awful.key({ modkey, "Shift"         }, "Left" ,    function () client_tag_moveLeft()  end ),
  awful.key({ modkey, "Shift"         }, "h"    ,    function () client_tag_moveLeft()  end ),
  awful.key({ modkey, "Shift"         }, "Right",    function () client_tag_moveRight() end ),
  awful.key({ modkey, "Shift"         }, "l"    ,    function () client_tag_moveRight() end )
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
keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(MAXTAGKEY, math.max(#tagnames, keynumber))
end
-- }}}

-- Bind all key numbers to tags.
for i = 1, keynumber do
  globalkeys = awful.util.table.join(
    globalkeys,

    -- View tag only.
    awful.key({ modkey }, "#" .. i + KEYCODEOFFS,
      function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      {description = "view tag #"..i, group = "tag"}
    ),

    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + KEYCODEOFFS,
      function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      {description = "toggle tag #" .. i, group = "tag"}
    ),

    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + KEYCODEOFFS,
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
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + KEYCODEOFFS,
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
clientbuttons = awful.util.table.join(
  awful.button({        }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  {
    rule = { }, -- All clients will match this rule.
    properties = {
      size_hints_honor     = false,
      --maximized_vertical   = false, --breaks floating
      --maximized_horizontal = false,

      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus        = awful.client.focus.filter,
      keys         = clientkeys,
      buttons      = clientbuttons,

      screen = awful.screen.preferred,
      --placement = awful.placement.no_overlap+awful.placement.no_offscreen -- Never needed this.
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
    rule       = { class = "Pavucontrol"},
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
    rule       = { class = "discord"},
    properties = { screen = screen_tools, tag = tag_communication },
  }, {
    -- Use for testing in awesome-client:
    -- for c in awful.client.iterate(function (cl) return awful.rules.match(cl, {class = "steam", name = "Friends List.*"}) end) do print(c) end
    -- The casing of both class and name is relevant for the match rule
    rule       = { class = "steam", name = "Friends List.*" },
    properties = { screen = screen_tools, tag = "4" },
  }, {
    rule       = { class = "kitty", name  = "monitoring_nvtop" },
    properties = { screen = screen_tools, tag = tag_monitoring },
  }, {
    rule       = { class = "kitty", name  = "monitoring_htop" },
    properties = { screen = screen_tools, tag = tag_monitoring },
  }, {
    rule       = { class = "kitty", name  = "monitoring_nethogs" },
    properties = { screen = screen_tools, tag = tag_monitoring },
  }
  -- Preset rules TODO: maybe merge some of these
  -- { -- All clients will match this rule.
  --   rule = { },
  --   properties = {
  --     border_width = beautiful.border_width,
  --     border_color = beautiful.border_normal,
  --     focus = awful.client.focus.filter,
  --     raise = true,
  --     keys = clientkeys,
  --     buttons = clientbuttons,
  --     screen = awful.screen.preferred,
  --     placement = awful.placement.no_overlap+awful.placement.no_offscreen
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
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
    end
  end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
  "request::titlebars",
  function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
      awful.button({ }, 1, function() client.focus = c c:raise() awful.mouse.client.move(c) end),
      awful.button({ }, 3, function() client.focus = c c:raise() awful.mouse.client.resize(c) end)
    )

    awful.titlebar(c) : setup {
      { -- Left
        awful.titlebar.widget.iconwidget(c),
        buttons = buttons,
        layout  = wibox.layout.fixed.horizontal
      },
      { -- Middle
        { -- Title
          align  = "center",
          widget = awful.titlebar.widget.titlewidget(c)
        },
        buttons = buttons,
        layout  = wibox.layout.flex.horizontal
      },
      { -- Right
        awful.titlebar.widget.floatingbutton (c),
        awful.titlebar.widget.maximizedbutton(c),
        awful.titlebar.widget.minimizedbutton(c),
        awful.titlebar.widget.stickybutton   (c),
        awful.titlebar.widget.ontopbutton    (c),
        awful.titlebar.widget.closebutton    (c),
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
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
      client.focus = c
    end
  end
)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Hooks
-- timer_low = timer({ timeout = 10 })
-- timer_low:connect_signal("timeout", function() awful.spawn("") end)
-- timer_low:start()
-- Hooks }}}

-- {{{ Autorun programs
autorun = true
autorunApps =
{
  "awesome_autostart",
  "xset -dpms",
  "xset s off",
}
if autorun then
  for n = 1, #autorunApps do
    awful.spawn(autorunApps[n])
  end
end
-- Autorun }}}
