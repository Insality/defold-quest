# Use Cases

This section provides examples of how to use the `quest` module.


## Quest Config

Here is full description of the quest config:
```lua
---@class quest.config
---@field tasks quest.task[] List of tasks to complete
---@field required_quests string[]|string|nil List of required quests or single required quest
---@field category string|nil Used for filtering quests
---@field events_offline boolean|nil If true, the quest events will be stored and processed even quest is not active
---@field autostart boolean|nil If true, the quest will be started automatically after all requirements are met
---@field autofinish boolean|nil If true, the quest will be finished automatically after all tasks are completed
---@field repeatable boolean|nil If true, the quest will be not stored in the completed list
---@field use_max_task_value boolean|nil If true, the maximum value of the task is used instead of the sum of all quest events
```


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

Inside your quest config file you free to add any data
```lua
return {
	["tutorial_menu"] = {
		tasks = { { action = "click", object = "menu" } }
		reward = { gold = 100 }
	}
}
```

```lua
-- Now your data will be available in the quest config
quest.on_quest_event:subscribe(function(event_data)
	if event_data.type == "completed" and event_data.quest_config.reward then
		-- Add rewards to the player
		player:add_reward(event_data.quest_config.reward)
	end
	return true
end)
```

Or you can use the [defold-token](https://github.com/Insality/defold-token) module to add rewards to the player.
```lua
local token = require("token.token")
local quest = require("quest.quest")

quest.on_quest_event:subscribe(function(event_data)
	if event_data.type == "completed" and event_data.quest_config.reward then
		token.container("wallet"):add_many(event_data.quest_config.reward, "quest")
	end
	return true
end)
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
