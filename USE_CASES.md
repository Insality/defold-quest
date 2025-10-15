# Use Cases

This section provides examples of how to use the `quest` module.


## Save Quest State

You need to save the quest state and load it before the `quest.init` function.

For this you can use [Defold Saver](https://github.com/Insality/defold-saver) module.

```lua
local saver = require("saver.saver")
local quest = require("quest.quest")

function init(self)
	saver.init()
	saver.bind_save_part("quest", quest.get_state())

	quest.init()
end
```

Or you can use other save system

```lua
local quest = require("quest.quest")

local function save_quest_state()
	-- Save a quest.state table as you wish
	save_quest_state(quest.get_state())
end


local function load_quest_state()
	-- Load a quest.state table as you wish
	local saved_state = load_quest_state_from_save()
	quest.set_state(saved_state)
end


function init(self)
	quest.state = load_quest_state()
	quest.init(quest_state)
end
```

## Extend Quest Config

You can extend quest config by using the `quest.config` class to fullfill the annotations.

```lua
---@class quest.config
---@field reward table<string, amount> Reward table
```

Inside your quest config file you free to use any data
```lua
return {
	["tutorial_menu"] = {
		tasks = { { action = "click", object = "menu" } }
		reward = { gold = 100 }
	}
}
```


## Add additional conditions to quest

You can add additional conditions to quest by using the `quest.is_can_event` event.

```lua
quest.is_can_event:subscribe(function(quest_id, quest_config)
	-- Any custom checks of quest event processing
	return true
end)

quest.is_can_start:subscribe(function(quest_id, quest_config)
	-- Any custom checks of quest can be started
	return true
end)

quest.is_can_complete:subscribe(function(quest_id, quest_config)
	-- Any custom checks of quest can be completed
	return true
end)
```
