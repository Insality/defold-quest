# API Reference

## Table of Contents

- [Quest](#quest)
- [Functions](#functions)
  - [quest.init()](#questinit)
  - [quest.quest_event()](#questquest_event)
  - [quest.get_current()](#questget_current)
  - [quest.get_progress()](#questget_progress)
  - [quest.get_completed()](#questget_completed)
  - [quest.is_active()](#questis_active)
  - [quest.is_completed()](#questis_completed)
  - [quest.is_current_with_task()](#questis_current_with_task)
  - [quest.is_can_start_quest()](#questis_can_start_quest)
  - [quest.start_quest()](#queststart_quest)
  - [quest.is_can_complete_quest()](#questis_can_complete_quest)
  - [quest.complete_quest()](#questcomplete_quest)
  - [quest.force_complete_quest()](#questforce_complete_quest)
  - [quest.reset_progress()](#questreset_progress)
  - [quest.get_quest_config()](#questget_quest_config)
  - [quest.update_quests()](#questupdate_quests)
  - [quest.reset_state()](#questreset_state)
  - [quest.set_logger()](#questset_logger)
- [Events](#events)
  - [quest.on_quest_register](#queston_quest_register)
  - [quest.on_quest_start](#queston_quest_start)
  - [quest.on_quest_completed](#queston_quest_completed)
  - [quest.on_quest_progress](#queston_quest_progress)
  - [quest.on_quest_task_completed](#queston_quest_task_completed)
  - [quest.is_can_start](#questis_can_start)
  - [quest.is_can_complete](#questis_can_complete)
  - [quest.is_can_event](#questis_can_event)


## Quest

To start using the Quest module in your project, you first need to import it. This can be done with the following line of code:

```lua
local quest = require("quest.quest")
```

## Functions

**quest.init()**
---
```lua
quest.init()
```

This function initializes the Quest module. It should be called at the beginning of the game.

- **Usage Example:**

```lua
quest.init()
```

**quest.quest_event()**
---
```lua
quest.quest_event(action, object, amount)
```

This function triggers a quest event. Use this event to make progress on a quest when a specific action is performed.

- **Parameters:**
  - `action`: The action to trigger the event for. Example: `"object_destroy"`.
  - `object`: The object to trigger the event for. Example: `"tree"`.
  - `amount`: The amount to trigger the event for. Example: `1`

- **Usage Example:**

```lua
quest.quest_event("object_destroy", "tree", 1)
```

**quest.get_current()**
---
```lua
quest.get_current(category)
```

This function returns the current quests for a category.

- **Parameters:**
  - `category`: The category to get the current quests for.

- **Return Value:**
  - The current quests for the category.

- **Usage Example:**

```lua
local current_quests = quest.get_current("quest")
print(current_quests) -- { "002_open_door" }
```

**quest.get_progress()**
---
```lua
quest.get_progress(quest_id)
```

This function returns the progress of a quest.

- **Parameters:**
  - `quest_id`: The id of the quest to get the progress of.

- **Return Value:**
  - The progress of the quest.

- **Usage Example:**

```lua
local progress = quest.get_progress("002_open_door")
print(progress) -- 0
```

**quest.get_completed()**
---
```lua
quest.get_completed(category)
```

This function returns the completed quests for a category.

- **Parameters:**
  - `category`: The category to get the completed quests for.

- **Return Value:**
  - The completed quests for the category.

- **Usage Example:**

```lua
local completed_quests = quest.get_completed("quest")
print(completed_quests) -- { "001_hidden" }
```

**quest.is_active()**
---
```lua
quest.is_active(quest_id)
```

This function checks if a quest is active.

- **Parameters:**
  - `quest_id`: The id of the quest to check.

- **Return Value:**
  - `true` if the quest is active, `false` otherwise.

- **Usage Example:**


**quest.is_completed()**
---
```lua
quest.is_completed(quest_id)
```

This function checks if a quest is completed.

- **Parameters:**
  - `quest_id`: The id of the quest to check.

- **Return Value:**
  - `true` if the quest is completed, `false` otherwise.

- **Usage Example:**

```lua
local is_completed = quest.is_completed("001_hidden")
print(is_completed) -- true
```

**quest.is_current_with_task()**
---
```lua
quest.is_current_with_task(action, object)
```

This function checks if the current quests contain a task with the specified action and object.

- **Parameters:**
  - `action`: The action to check for.
  - `object`: The object to check for.

- **Return Value:**
  - `true` if the current quests contain a task with the specified action and object, `false` otherwise.

- **Usage Example:**

```lua
local is_current = quest.is_current_with_task("complete_cell", "141")
print(is_current) -- true
```

```lua
local is_active = quest.is_active("002_open_door")
print(is_active) -- true
```

**quest.is_can_start_quest()**
---
```lua
quest.is_can_start_quest(quest_id)
```

This function checks if a quest can be started.

- **Parameters:**
  - `quest_id`: The id of the quest to check.

- **Return Value:**
  - `true` if the quest can be started, `false` otherwise.

- **Usage Example:**

```lua
local can_start = quest.is_can_start_quest("002_open_door")
print(can_start) -- true
```

**quest.start_quest()**
---
```lua
quest.start_quest(quest_id)
```

This function starts a quest.

- **Parameters:**
  - `quest_id`: The id of the quest to start.

- **Usage Example:**

```lua
quest.start_quest("002_open_door")
```

**quest.is_can_complete_quest()**
---
```lua
quest.is_can_complete_quest(quest_id)
```

This function checks if a quest can be completed.

- **Parameters:**
  - `quest_id`: The id of the quest to check.

- **Return Value:**
  - `true` if the quest can be completed, `false` otherwise.

- **Usage Example:**

```lua
local can_complete = quest.is_can_complete_quest("002_open_door")
print(can_complete) -- true
```

**quest.complete_quest()**
---
```lua
quest.complete_quest(quest_id)
```

This function completes a quest.

- **Parameters:**
  - `quest_id`: The id of the quest to complete.

- **Usage Example:**

```lua
quest.complete_quest("002_open_door")
```

**quest.force_complete_quest()**
---
```lua
quest.force_complete_quest(quest_id)
```

This function forces a quest to be completed.

- **Parameters:**
  - `quest_id`: The id of the quest to force complete.

- **Usage Example:**

```lua
quest.force_complete_quest("002_open_door")
```

**quest.reset_progress()**
---
```lua
quest.reset_progress(quest_id)
```

This function resets the progress of a quest.

- **Parameters:**
  - `quest_id`: The id of the quest to reset the progress of.

- **Usage Example:**

```lua
quest.reset_progress("002_open_door")
```

**quest.get_quest_config()**
---
```lua
quest.get_quest_config(quest_id)
```

This function returns the configuration for a quest.

- **Parameters:**
  - `quest_id`: The id of the quest to get the configuration for.

- **Return Value:**
  - The configuration for the quest.

- **Usage Example:**

```lua
local config = quest.get_quest_config("002_open_door")
print(config) -- { "category": "quest", "autostart": true, "autofinish": true, "required_quests": [ "001_hidden" ], "tasks": [ { "action": "complete_cell", "object": "152" } ] }
```

**quest.update_quests()**
---
```lua
quest.update_quests()
```

This function updates the quests.

- **Usage Example:**

```lua
quest.update_quests()
```


**quest.reset_state()**
---
```lua
quest.reset_state()
```

This function resets the state of the Quest module. It should be called when the game is restarted.

- **Usage Example:**

```lua
quest.reset_state()
```

**quest.set_logger()**
---
```lua
quest.set_logger(logger_instance)
```

This function sets the logger instance for the Quest module.

- **Parameters:**
  - `logger_instance`: The logger instance to set.

- **Usage Example:**

```lua
quest.set_logger(logger)
```


```lua
---@class quest.event.quest_register: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest), _)
M.on_quest_register = event.create()

---@class quest.event.quest_start: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest), _)
M.on_quest_start = event.create()

---@class quest.event.quest_end: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest), _)
M.on_quest_completed = event.create()

---@class quest.event.quest_progress: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest, delta: number, total: number, task_index: number)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest, delta: number, total: number, task_index: number), _)
M.on_quest_progress = event.create()

---@class quest.event.quest_task_complete: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest, task_index: number)
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest, task_index: number), _)
M.on_quest_task_completed = event.create()

---@class quest.event.is_can_start: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest): boolean
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest): boolean, _)
M.is_can_start = event.create()

---@class quest.event.is_can_complete: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest): boolean
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest): boolean, _)
M.is_can_complete = event.create()

---@class quest.event.is_can_event: event
---@field trigger fun(_, quest_id: string, quest_config: quest.quest): boolean
---@field subscribe fun(_, callback: fun(quest_id: string, quest_config: quest.quest): boolean, _)
M.is_can_event = event.create()

```



## Events

**quest.on_quest_register**
---
```lua
quest.on_quest_register:subscribe(function(quest_id, quest_config)
	-- Your code here
end)
```

This event is triggered when a quest is registered. It provides the quest ID and configuration.

- **Usage Example:**

```lua
quest.on_quest_register:subscribe(function(quest_id, quest_config)
	print("Quest registered:", quest_id, quest_config)
end)
```

**quest.on_quest_start**
---
```lua
quest.on_quest_start:subscribe(function(quest_id, quest_config)
	-- Your code here
end)
```

This event is triggered when a quest is started. It provides the quest ID and configuration.

- **Usage Example:**

```lua
quest.on_quest_start:subscribe(function(quest_id, quest_config)
	print("Quest started:", quest_id, quest_config)
end)
```

**quest.on_quest_completed**
---
```lua
quest.on_quest_completed:subscribe(function(quest_id, quest_config)
	-- Your code here
end)
```

This event is triggered when a quest is completed. It provides the quest ID and configuration.

- **Usage Example:**

```lua
quest.on_quest_completed:subscribe(function(quest_id, quest_config)
	print("Quest completed:", quest_id, quest_config)
end)
```

**quest.on_quest_progress**
---
```lua
quest.on_quest_progress:subscribe(function(quest_id, quest_config, delta, total, task_index)
	-- Your code here
end)
```

This event is triggered when a quest makes progress. It provides the quest ID, configuration, delta, total, and task index.

- **Usage Example:**

```lua
quest.on_quest_progress:subscribe(function(quest_id, quest_config, delta, total, task_index)
	print("Quest progress:", quest_id, quest_config, delta, total, task_index)
end)
```

**quest.on_quest_task_completed**
---
```lua
quest.on_quest_task_completed:subscribe(function(quest_id, quest_config, task_index)
	-- Your code here
end)
```

This event is triggered when a quest task is completed. It provides the quest ID, configuration, and task index.

- **Usage Example:**

```lua
quest.on_quest_task_completed:subscribe(function(quest_id, quest_config, task_index)
	print("Quest task completed:", quest_id, quest_config, task_index)
end)
```

**quest.is_can_start**
---
```lua
quest.is_can_start:subscribe(function(quest_id, quest_config)
	-- Your code here
end)
```

This event is triggered when a quest can be started. It provides the quest ID and configuration.

- **Usage Example:**

```lua
quest.is_can_start:subscribe(function(quest_id, quest_config)
	-- Your code here, return true or false. Only last subscriber return value will be used
	return true
end)
```

**quest.is_can_complete**
---
```lua
quest.is_can_complete:subscribe(function(quest_id, quest_config)
	-- Your code here
end)
```

This event is triggered when a quest can be completed. It provides the quest ID and configuration.

- **Usage Example:**

```lua
quest.is_can_complete:subscribe(function(quest_id, quest_config)
	-- Your code here, return true or false. Only last subscriber return value will be used
	return true
end)
```

**quest.is_can_event**
---
```lua
quest.is_can_event:subscribe(function(quest_id, quest_config)
	-- Your code here
end)
```

This event is triggered when a quest event can be triggered. It provides the quest ID and configuration.

- **Usage Example:**

```lua
quest.is_can_event:subscribe(function(quest_id, quest_config)
	-- Your code here, return true or false. Only last subscriber return value will be used
	return true
end)
```
