------------------------------
-- My Default awesome theme --
------------------------------

local awful = require("awful")

local THEMEDIR = awful.util.getdir("config") .. "themes/" -- name of this folder
local THEMENAME = "my_default_2.0"                -- must be the name of the theme's folder
local THEMEROOT = THEMEDIR .. THEMENAME .. "/"

local theme = {}

theme.font          = "ubuntu 11"

theme.bg_normal     = "#222222"
theme.bg_focus      = "#535d6c"
theme.bg_urgent     = "#06101b"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap   = 0
theme.border_width  = 0
theme.border_normal = "#000000"
theme.border_focus  = "#535d6c"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#316ac1"

-- Display the taglist squares
theme.taglist_squares_sel   = THEMEROOT .. "taglist/squarefw.png"
theme.taglist_squares_unsel = THEMEROOT .. "taglist/squarew.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = THEMEROOT .. "submenu.png"
theme.menu_height = 20
theme.menu_width  = 120

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = THEMEROOT .. "titlebar/close_normal.png"
theme.titlebar_close_button_focus  = THEMEROOT .. "titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = THEMEROOT .. "titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = THEMEROOT .. "titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = THEMEROOT .. "titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = THEMEROOT .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = THEMEROOT .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = THEMEROOT .. "titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = THEMEROOT .. "titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = THEMEROOT .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = THEMEROOT .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = THEMEROOT .. "titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = THEMEROOT .. "titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = THEMEROOT .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = THEMEROOT .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = THEMEROOT .. "titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = THEMEROOT .. "titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = THEMEROOT .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = THEMEROOT .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = THEMEROOT .. "titlebar/maximized_focus_active.png"

-- theme.wallpaper = THEMEROOT .. "background.png"
theme.wallpaper = THEMEROOT .. "background_with_kb_ru.png"

-- You can use your own layout icons like this:
theme.layout_fairh = THEMEROOT .. "layouts/fairhw.png"
theme.layout_fairv = THEMEROOT .. "layouts/fairvw.png"
theme.layout_floating  = THEMEROOT .. "layouts/floatingw.png"
theme.layout_magnifier = THEMEROOT .. "layouts/magnifierw.png"
theme.layout_max = THEMEROOT .. "layouts/maxw.png"
theme.layout_fullscreen = THEMEROOT .. "layouts/fullscreenw.png"
theme.layout_tilebottom = THEMEROOT .. "layouts/tilebottomw.png"
theme.layout_tileleft   = THEMEROOT .. "layouts/tileleftw.png"
theme.layout_tile = THEMEROOT .. "layouts/tilew.png"
theme.layout_tiletop = THEMEROOT .. "layouts/tiletopw.png"
theme.layout_spiral  = THEMEROOT .. "layouts/spiralw.png"
theme.layout_dwindle = THEMEROOT .. "layouts/dwindlew.png"
theme.layout_cornernw = THEMEROOT .. "layouts/cornernww.png"
theme.layout_cornerne = THEMEROOT .. "layouts/cornernew.png"
theme.layout_cornersw = THEMEROOT .. "layouts/cornersww.png"
theme.layout_cornerse = THEMEROOT .. "layouts/cornersew.png"

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = gnome

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
