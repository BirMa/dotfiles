-- Based on: https://github.com/stax76/awesome-mpv?tab=readme-ov-file#playback / https://gist.github.com/garoto/e0eb539b210ee077c980e01fb2daef4a

local HISTORY_PATH = os.getenv('HOME')..'/.local/state/mpv/history/history-'..os.date('%Y-%m')..'.log';

mp.register_event('file-loaded', function()
  local logfile;

  logfile = io.open(HISTORY_PATH, 'a+');
  logfile:write(('[%s]\t\0%s\t\0%s\n'):format(os.date('%Y-%m-%d %X'), mp.get_property('path'), mp.get_property('media-title')));
  logfile:close();
end)
