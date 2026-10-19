-- Home Manager substitutes this path; fonts and appearance live in default.nix.
local theme_directory = "@themeDirectory@"

-- Import on demand through Rex's own importer rather than overwriting its
-- private custom-theme database. Run once on each Mac, or after palette edits.
rex.action({
    name = "import_jb_themes",
    title = "Import JB Light and Dark Themes",
    run = function()
        rex.client.queue("client.theme.import", { path = theme_directory .. "/jb-light" })
        rex.client.queue("client.theme.import", { path = theme_directory .. "/jb-dark" })
    end,
})

local function write_screen_file()
    local screen, err = rex.block.call("com.superlogical.terminal", "format", { format = "text" })
    assert(screen, err)
    local temp, temp_err = rex.exec({ "/usr/bin/mktemp", "-d", "-t", "rex-screen" })
    assert(temp, temp_err)
    assert(temp.ok, temp.stderr)
    local path = temp.stdout:gsub("\n$", "") .. "/screen.txt"
    local file, file_err = io.open(path, "w")
    assert(file, file_err)
    assert(file:write(screen.content))
    assert(file:close())
    return path
end

-- Like Ghostty's write_screen_file:paste/open. These actions run on the server
-- and are intended for the local macOS server, not a remote Linux host.
rex.action({
    name = "paste_screen_file",
    title = "Write Screen to File and Paste Path",
    run = function(ctx)
        local path = write_screen_file()
        local result, err = rex.call("block.event", {
            session_id = ctx.session_id,
            block_id = ctx.block_id,
            event = {
                type = "paste",
                payload = { text = "'" .. path:gsub("'", "'\\''") .. "'" },
            },
        })
        assert(result, err)
    end,
})

rex.action({
    name = "open_screen_file",
    title = "Write Screen to File and Open",
    run = function()
        local result, err = rex.exec({ "/usr/bin/open", write_screen_file() })
        assert(result, err)
        assert(result.ok, result.stderr)
    end,
})

rex.bind("cmd+shift+j", "paste_screen_file")
rex.bind("cmd+alt+shift+j", "open_screen_file")
