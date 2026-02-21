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

---@class quest.task
---@field action string Action to perform to complete the task. Example: "destroy" or "collect"
---@field object string|nil Object to specify the task, example: "enemy" or "money", Default: nil
---@field required number|nil Required amount of the object to complete the task. Default: 1
---@field initial number|nil Initial amount of the object. Default: 0
```


## Core loop and on_quest_event queue

**Flow:** Call `quest.init(quest_config_or_path)` to load config and register offline quests. When something happens in game (kill enemy, collect item), call `quest.event(action, object, amount)`. The module applies progress to matching tasks, handles autostart and autofinish, and pushes lifecycle events into `quest.on_quest_event` in order: `"register"` (quest registered), `"start"`, `"progress"`, `"task_completed"`, `"completed"`.

**Queue behavior:** `quest.on_quest_event` is a [queue](https://github.com/Insality/defold-event/blob/main/api/queue_api.md). Events are pushed when they occur and stay in the queue until they are processed (delivered to subscribers). Nothing is dropped. So you can start the quest system and subscribe to `on_quest_event` early—for example in the **loader** step—and your UI (or other systems) will receive every event when the queue is processed, without missing any.

**Event types and payload:** Subscribe with `quest.on_quest_event:subscribe(callback)`. The callback receives `event_data` with:

| type              | quest_id | quest_config | delta | total | task_index |
|-------------------|----------|--------------|-------|-------|------------|
| `"register"`      | ✓        | ✓            | —     | —     | —          |
| `"start"`         | ✓        | ✓            | —     | —     | —          |
| `"progress"`      | ✓        | ✓            | ✓     | ✓     | ✓          |
| `"task_completed"`| ✓        | ✓            | —     | —     | ✓          |
| `"completed"`     | ✓        | ✓            | —     | —     | —          |

```lua
-- Subscribe in loader or before quest.init() so you never miss an event
quest.on_quest_event:subscribe(function(event_data)
	if event_data.type == "start" then
		ui_quest_log:add_quest(event_data.quest_id, event_data.quest_config)
	elseif event_data.type == "progress" then
		ui_quest_log:update_progress(event_data.quest_id, event_data.task_index, event_data.total)
	elseif event_data.type == "completed" then
		ui_quest_log:mark_completed(event_data.quest_id)
	end
	return true
end)

quest.init(require("game.quests"))
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
	return load_quest_state_from_save()
end


function init(self)
	local state = load_quest_state()
	quest.set_state(state)
	quest.init()
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

You can add additional conditions to quest by subscribing to the `quest.is_can_event`, `quest.is_can_start` and `quest.is_can_complete` events.

```lua
quest.is_can_event:subscribe(function(quest_id, quest_config)
	return true -- Return true to allow event processing, return false to block event processing
end)

quest.is_can_start:subscribe(function(quest_id, quest_config)
	return true -- Return true to allow quest start, return false to block quest start
end)

quest.is_can_complete:subscribe(function(quest_id, quest_config)
	return true -- Return true to allow quest completion, return false to block quest completion
end)
```


## Starting and completing quests

Use `quest.start_quest(quest_id)` when the player accepts a quest (e.g. from an NPC). It returns `true` if the quest was started. Use `quest.complete_quest(quest_id)` when the player turns in a quest; it only completes if all tasks are done and any `is_can_complete` conditions pass.

For autostart/autofinish quests you typically do not call these manually — the module starts and completes them in `quest.update_quests()`. Use `quest.force_complete_quest(quest_id)` to complete a quest without checking conditions (e.g. debug or scripted story moments).

```lua
if quest.is_can_start_quest("hunt_wolves") then
	if quest.start_quest("hunt_wolves") then
		show_quest_started_message()
	end
end

if quest.is_can_complete_quest("hunt_wolves") then
	quest.complete_quest("hunt_wolves")
	show_reward_screen()
end
```


## Using categories

Set `category` in quest config to group quests (e.g. `"main"`, `"side"`, `"daily"`). Use it with the getters to build filtered UI or logic.

```lua
-- In quest config
["main_quest_1"] = { category = "main", tasks = { ... } }
["side_fetch"] = { category = "side", tasks = { ... } }

-- In game
local main_quests = quest.get_current("main")
local completed_side = quest.get_completed("side")
local available_daily = quest.get_can_be_started("daily")
```


## Finding quests by task

Use `quest.get_current_with_task(action, object)` to get active quest IDs that have a task matching the given action (and optionally object). Useful to adjust gameplay while a quest is active—e.g. boost loot, change dialogue, or spawn different enemies when the player has a matching quest.

```lua
local quests_with_kill_enemy = quest.get_current_with_task("kill", "enemy")
if #quests_with_kill_enemy > 0 then
	-- Player has an active "kill enemy" quest: increase drop rate or show special loot
	loot_multiplier = 1.5
end

local quests_collecting_coins = quest.get_current_with_task("collect", "coin")
for _, quest_id in ipairs(quests_collecting_coins) do
	highlight_coin_pickups(quest_id)
end
```


## Autostart, autofinish and repeatable

- **autostart**: When requirements are met (e.g. `required_quests` done), the quest is started automatically on the next `quest.update_quests()` (called after `quest.init`, `quest.add_quests`, `quest.event`, etc.). No need to call `quest.start_quest()`.
- **autofinish**: When all tasks are complete and `is_can_complete` allows it, the quest is completed automatically. No need to call `quest.complete_quest()`.
- **repeatable**: Completed quest is not added to the completed list, so it can become available again (e.g. when requirements are met for autostart, or you reset it). Use for dailies or repeatable objectives.

```lua
["daily_bounty"] = {
	tasks = { { action = "kill", object = "bandit", required = 5 } },
	autostart = true,
	autofinish = true,
	repeatable = true
}
```


## events_offline

When `events_offline = true`, the quest is registered and receives events even when it is not active. Progress is stored and applied when the quest is later started. Use for quests that should count actions the player did before accepting the quest.

```lua
["retroactive_collect"] = {
	tasks = { { action = "collect", object = "artifact", required = 3 } },
	events_offline = true
}
```


## use_max_task_value

By default, a task’s progress is the sum of all matching events. With `use_max_task_value = true`, the task progress is the maximum single value reported for that task (e.g. from `quest.event("collect", "gem", 5)`). Use when the task is “collect at least N in one go” or “reach value N in one action” rather than “collect N total”.

```lua
["big_catch"] = {
	tasks = { { action = "catch", object = "fish", required = 10 } },
	use_max_task_value = true
}
-- quest.event("catch", "fish", 10) completes the task; quest.event("catch", "fish", 3) three times does not
```
