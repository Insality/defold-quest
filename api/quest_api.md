# quest API

> at quest/quest.lua

The Defold Quest module.
Use this module to track tasks in your game.
You can add, start, complete and track quests progress.

# Quest Status Lifecycle

Quests go through different states during their lifecycle:

## Quest States:
* **not_started**: Quest exists in config but hasn't been registered yet
* **registered**: Quest is registered and can receive events (if events_offline = true)
* **active**: Quest is started and actively earning progress from events
* **completed**: Quest has finished all tasks and is marked as completed

## Quest Types:
* **autostart**: Quest automatically starts when requirements are met
* **autofinish**: Quest automatically completes when all tasks are done
* **repeatable**: Quest can be started again after completion (not stored in completed list)
* **events_offline**: Quest can receive events even when not active

## Quest Status Meanings:
* **can_be_started**: Quest meets all requirements and is ready to start
* **active**: Quest is currently running and earning progress
* **completed**: Quest has finished and cannot be restarted (unless repeatable)

# Usage Example:
```lua
quest.init(require("game.quests"))
quest.event("kill", "enemy") -- Apply kill enemy event
local active = quest.get_current() -- Get all active quests
```


## Functions

- [init](#init)
- [reset_state](#reset_state)
- [set_logger](#set_logger)
- [add_quests](#add_quests)
- [get_quests_count](#get_quests_count)
- [get_progress](#get_progress)
- [get_task_progress](#get_task_progress)
- [get_current](#get_current)
- [get_completed](#get_completed)
- [get_can_be_started](#get_can_be_started)
- [get_quest_config](#get_quest_config)
- [get_quests_data](#get_quests_data)
- [is_active](#is_active)
- [is_completed](#is_completed)
- [is_can_start_quest](#is_can_start_quest)
- [is_can_complete_quest](#is_can_complete_quest)
- [get_current_with_task](#get_current_with_task)
- [start_quest](#start_quest)
- [complete_quest](#complete_quest)
- [force_complete_quest](#force_complete_quest)
- [reset_progress](#reset_progress)
- [reset_quest](#reset_quest)
- [clear_all_progress](#clear_all_progress)
- [event](#event)
- [add_task_progress](#add_task_progress)
- [update_quests](#update_quests)
- [get_state](#get_state)
- [set_state](#set_state)

## Fields

- [on_quest_event](#on_quest_event)
- [is_can_start](#is_can_start)
- [is_can_complete](#is_can_complete)
- [is_can_event](#is_can_event)



### init

---
```lua
quest.init([quest_config_or_path])
```

Initialize quest system with config and start processing quests

- **Parameters:**
	- `[quest_config_or_path]` *(string|table<string, quest.config>|nil)*: Path to quest config or config table. Can be nil to init without quests.

- **Example Usage:**

```lua
quest.init()
quest.init(require("game.quests"))
quest.init("/resources/quests.json")
```
### reset_state

---
```lua
quest.reset_state()
```

Reset Module quest state, probably you want to use it only in case of soft game reload

### set_logger

---
```lua
quest.set_logger([logger_instance])
```

Customize the logging mechanism used by Quest Module. You can use **Defold Log** library or provide a custom logger.

- **Parameters:**
	- `[logger_instance]` *(table|quest.logger|nil)*:

### add_quests

---
```lua
quest.add_quests(quest_config_or_path)
```

Add quests to the system from config file or table

- **Parameters:**
	- `quest_config_or_path` *(string|table<string, quest.config>)*: Lua table or path to quest config. Example: "/resources/quests.json"

- **Example Usage:**

```lua
quest.add_quests(require("game.quests"))
quest.add_quests("/resources/quests.json")
```
### get_quests_count

---
```lua
quest.get_quests_count()
```

Get total quests count in quests config

- **Returns:**
	- `Total` *(number)*: quests count

### get_progress

---
```lua
quest.get_progress(quest_id)
```

Get current progress on quest tasks.
Returns an array-like table with task progress values.

- **Parameters:**
	- `quest_id` *(string)*: Quest identifier

- **Returns:**
	- `progress` *(table<number, number>)*: List of task progress, ex {0, 2, 0}

- **Example Usage:**

```lua
local progress = quest.get_progress("kill_enemies")
print(progress[1]) -- Progress on first task
print(progress[2]) -- Progress on second task
--
local progress = quest.get_progress("nonexistent_quest")
print(#progress) -- Will be 0 for non-existent quests
```
### get_task_progress

---
```lua
quest.get_task_progress(quest_id, task_index)
```

Get task progress by task index

- **Parameters:**
	- `quest_id` *(string)*:
	- `task_index` *(number)*:

- **Returns:**
	- `` *(number)*:

### get_current

---
```lua
quest.get_current([category])
```

Get current active quests

- **Parameters:**
	- `[category]` *(string|nil)*:

- **Returns:**
	- `` *(table<string, quest.progress>)*:

### get_completed

---
```lua
quest.get_completed([category])
```

Get completed quests map

- **Parameters:**
	- `[category]` *(string|nil)*: Optional category filter

- **Returns:**
	- `Map` *(table<string, boolean>)*: of completed quests

### get_can_be_started

---
```lua
quest.get_can_be_started([category])
```

Get quests that can be started

- **Parameters:**
	- `[category]` *(string|nil)*: Optional category filter

- **Returns:**
	- `` *(table<string, boolean>)*:

### get_quest_config

---
```lua
quest.get_quest_config(quest_id)
```

Get quest config by id

- **Parameters:**
	- `quest_id` *(string)*: Quest id

- **Returns:**
	- `` *(quest.config)*:

### get_quests_data

---
```lua
quest.get_quests_data()
```

Get quests data

- **Returns:**
	- `` *(table<string, quest.config>)*:

### is_active

---
```lua
quest.is_active([quest_id])
```

Check quest is active

- **Parameters:**
	- `[quest_id]` *(any)*:

- **Returns:**
	- `Quest` *(boolean)*: active state

### is_completed

---
```lua
quest.is_completed(quest_id)
```

Check quest is completed

- **Parameters:**
	- `quest_id` *(string)*:

- **Returns:**
	- `is_completed` *(boolean)*: Quest completed state

### is_can_start_quest

---
```lua
quest.is_can_start_quest(quest_id)
```

Check quest is can be started now

- **Parameters:**
	- `quest_id` *(string)*:

- **Returns:**
	- `Quest` *(boolean)*: can start state

### is_can_complete_quest

---
```lua
quest.is_can_complete_quest(quest_id)
```

Check quest is can be completed now

- **Parameters:**
	- `quest_id` *(string)*:

- **Returns:**
	- `Quest` *(boolean)*: can complete state

### get_current_with_task

---
```lua
quest.get_current_with_task(action, [object])
```

Get current quests that have tasks matching the specified action and object.
Returns an array of quest IDs that contain matching tasks.

- **Parameters:**
	- `action` *(string)*: Action to check (e.g., "kill", "collect")
	- `[object]` *(string|nil)*: Object to check (e.g., "enemy", "coin"). Can be nil for any object

- **Returns:**
	- `List` *(string[])*: of quest IDs that have matching tasks

- **Example Usage:**

```lua
local quests = quest.is_current_with_task("kill", "enemy")
if #quests > 0 then
	print("Found " .. #quests .. " quests with kill enemy task")
end
--
local quests = quest.is_current_with_task("collect")
for i, quest_id in ipairs(quests) do
	print("Quest " .. quest_id .. " has collect task")
end
```
### start_quest

---
```lua
quest.start_quest(quest_id)
```

Start quest, if it can be started

- **Parameters:**
	- `quest_id` *(string)*:

- **Returns:**
	- `Quest` *(boolean)*: started state

### complete_quest

---
```lua
quest.complete_quest(quest_id)
```

Complete quest, if it can be completed

- **Parameters:**
	- `quest_id` *(string)*: Quest id

### force_complete_quest

---
```lua
quest.force_complete_quest(quest_id)
```

Force complete quest, without checking conditions

- **Parameters:**
	- `quest_id` *(string)*: Quest id

### reset_progress

---
```lua
quest.reset_progress(quest_id)
```

Reset quest progress

- **Parameters:**
	- `quest_id` *(string)*: Quest id

### reset_quest

---
```lua
quest.reset_quest(quest_id)
```

Reset quest, remove from current and completed lists, and update can be started list

- **Parameters:**
	- `quest_id` *(string)*: Quest id

### clear_all_progress

---
```lua
quest.clear_all_progress()
```

Clear all quest progress

### event

---
```lua
quest.event(action, [object], [amount])
```

Main function to apply event to all current quests. Call it when specific quest action is performed.

- **Parameters:**
	- `action` *(string)*: Event action
	- `[object]` *(string|nil)*: Event object
	- `[amount]` *(number|nil)*: Event amount default 1

- **Example Usage:**

```lua
quest.event("game_started")
quest.event("kill", "enemy")
quest.event("kill", "enemy", 2)
quest.event("collect", "coin", 3)
```
### add_task_progress

---
```lua
quest.add_task_progress(quest_id, task_index, amount)
```

Add progress to task

- **Parameters:**
	- `quest_id` *(string)*: Quest id
	- `task_index` *(number)*: Task index
	- `amount` *(number)*: Amount to add

### update_quests

---
```lua
quest.update_quests()
```

Update quests lifecycle by processing autostart and autofinish quests.
This function recursively processes quest state changes until no more changes occur.
It handles quest completion and starting based on quest configuration and validation.
Process:
1. Complete autofinish quests that meet completion criteria
2. Start autostart quests that meet start criteria
3. Recursively call itself if any changes occurred

### get_state

---
```lua
quest.get_state()
```

Get state (for saving/loading)

- **Returns:**
	- `` *(quest.state)*:

### set_state

---
```lua
quest.set_state(external_state)
```

Set state (for saving/loading)

- **Parameters:**
	- `external_state` *(quest.state)*: Persist data between game sessions


## Fields
<a name="on_quest_event"></a>
- **on_quest_event** (_quest.queue.quest_event_):  Quest event queue for UI notifications

<a name="is_can_start"></a>
- **is_can_start** (_event_): Triggered when a quest can be started.

<a name="is_can_complete"></a>
- **is_can_complete** (_event_): Triggered when a quest can be completed.

<a name="is_can_event"></a>
- **is_can_event** (_event_): Triggered when a quest can be processed.

