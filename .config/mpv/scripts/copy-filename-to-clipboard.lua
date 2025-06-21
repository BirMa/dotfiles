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
    print(string.format('Copied to clipboard: %s', result))
  end
)
