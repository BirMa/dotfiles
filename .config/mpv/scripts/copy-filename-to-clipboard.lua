mp.add_key_binding(
  'y',
  'copy-filename',
  function()
    result = mp.get_property('path');
    mp.commandv(
      'run',
      '/usr/bin/env',
      'sh',
      '-c',
      string.format("echo -n '%s' | xclip -selection clipboard", result:gsub("'", "'\\''"))
    );
    msg = string.format('Copied to clipboard: %s', result);
    mp.msg.info(msg);
    mp.osd_message(msg , 1);
  end
)
