[![Enthusiastic person wielding a broom and a floppy disk.](save-them.jpg)](http://hyperboleandahalf.blogspot.com.au)

# Save All The Things Mode

Minor-mode to automatically save a buffer after you've been inactive
for a while.

Use it manually:

    (save-all-the-things-mode)

Or enable it automatically like so:

    (add-hook 'after-save-hook #'satt-enable-or-disable)
    (add-hook 'find-file-hook #'satt-enable-or-disable)

`satt-enable-or-disable` will enable auto-saving if the buffer has a
matching file and is tracked by Git.
