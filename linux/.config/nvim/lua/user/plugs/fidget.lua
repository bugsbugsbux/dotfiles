require('fidget').setup({
    progress = {
        display = {
            skip_history = false,
            -- done_icon = '✔',
            progress_icon = { pattern = 'dots_pulse', period = 0.5 }, -- in seconds
        },
    },
})
