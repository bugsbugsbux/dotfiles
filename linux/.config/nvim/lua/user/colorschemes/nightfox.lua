local nightfox_group = {
  selected = { light = 'dayfox', dark = 'carbonfox' },
  variants = {
    light = { 'dayfox', 'dawnfox' },
    dark = { 'nightfox', 'duskfox', 'nordfox', 'terafox', 'carbonfox' },
  },
}

-- register
local themes = require('user.colorschemes')
themes['dayfox'] = nightfox_group
themes['dawnfox'] = nightfox_group
themes['nightfox'] = nightfox_group
themes['duskfox'] = nightfox_group
themes['nordfox'] = nightfox_group
themes['terafox'] = nightfox_group
themes['carbonfox'] = nightfox_group
