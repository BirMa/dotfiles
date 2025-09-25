-- Based on: https://github.com/stax76/awesome-mpv?tab=readme-ov-file#playback / https://gist.github.com/garoto/e0eb539b210ee077c980e01fb2daef4a

-- Remark: Will cause the history file of month A to potentially contain logs for month B if the mpv instance is open and month B starts.
local HISTORY_PATH = os.getenv('HOME')..'/.local/state/mpv/history/history-'..os.date('%Y-%m')..'.log';

mp.register_event('file-loaded', function()
  local logfile;

  logfile = io.open(HISTORY_PATH, 'a+');
  logfile:write(
    ('[%s]\0%s\0%s\n'):format(
      os.date('%Y-%m-%d %X'),
      mp.get_property('media-title'),
      mp.get_property('path'):gsub("\n", "")
    )
  );
  logfile:close();
end)
