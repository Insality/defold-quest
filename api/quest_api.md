# quest API

> at /quest/quest.lua

The Defold Quest module.
Use this module to track tasks in your game.
You can create quests, start them, complete them, and track their progress.

## Functions

- [reset_state](#reset_state)
- [set_logger](#set_logger)
- [get_quests_count](#get_quests_count)
- [get_progress](#get_progress)
- [get_current](#get_current)
- [get_completed](#get_completed)
- [is_current_with_task](#is_current_with_task)
- [is_active](#is_active)
- [is_completed](#is_completed)
- [is_can_start_quest](#is_can_start_quest)
- [start_quest](#start_quest)
- [is_can_complete_quest](#is_can_complete_quest)
- [complete_quest](#complete_quest)
- [force_complete_quest](#force_complete_quest)
- [reset_progress](#reset_progress)
- [get_quest_config](#get_quest_config)
- [quest_event](#quest_event)
- [init](#init)
- [update_quests](#update_quests)

## Fields

- [on_quest_register](#on_quest_register)
- [on_quest_start](#on_quest_start)
- [on_quest_completed](#on_quest_completed)
- [on_quest_progress](#on_quest_progress)
- [on_quest_task_completed](#on_quest_task_completed)
- [is_can_start](#is_can_start)
- [is_can_complete](#is_can_complete)
- [is_can_event](#is_can_event)
- [state](#state)



### reset_state

---
```lua
quest.reset_state()
```

Reset quest state, probably you want to use it in case of game reload

### set_logger

---
```lua
quest.set_logger([logger_instance])
```

Customize the logging mechanism used by Quest Module. You can use **Defold Log** library or provide a custom logger.

- **Parameters:**
	- `[logger_instance]` *(table|quest.logger|nil)*:

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

Get current progress on quest

- **Parameters:**
	- `quest_id` *(string)*:

- **Returns:**
	- `` *(table<string, number>)*:

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

### is_current_with_task

---
```lua
quest.is_current_with_task(action, [object])
```

Check if there is quests in current with
pointer action and object

- **Parameters:**
	- `action` *(string)*: Action to check
	- `[object]` *(string|nil)*: Object to check

- **Returns:**
	- `` *(boolean)*:

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

### quest_event

---
```lua
quest.quest_event(action, [object], [amount])
```

Apply event to all current quests

- **Parameters:**
	- `action` *(string)*: Event action
	- `[object]` *(string|nil)*: Event object
	- `[amount]` *(number|nil)*: Event amount

### init

---
```lua
quest.init(quest_config_or_path)
```

Init quest system
After init the quest system can trigger events, so you should subscribe to events before init

- **Parameters:**
	- `quest_config_or_path` *(string|table<string, quest.config>)*: Path to quest config. Example: "/resources/quests.json"

### update_quests

---
```lua
quest.update_quests()
```

Update quests list
 It will start and end quests, by checking quests condition


## Fields
<a name="on_quest_register"></a>
- **on_quest_register** (_unknown_): Triggered when a quest is registered and now able to receive events.

<a name="on_quest_start"></a>
- **on_quest_start** (_unknown_): Triggered when a quest is started.

<a name="on_quest_completed"></a>
- **on_quest_completed** (_unknown_): Triggered when a quest is completed.

<a name="on_quest_progress"></a>
- **on_quest_progress** (_unknown_): Triggered when a quest progress is updated.

<a name="on_quest_task_completed"></a>
- **on_quest_task_completed** (_unknown_): Triggered when a quest task is completed.

<a name="is_can_start"></a>
- **is_can_start** (_unknown_): Triggered when a quest can be started.

<a name="is_can_complete"></a>
- **is_can_complete** (_unknown_): Triggered when a quest can be completed.

<a name="is_can_event"></a>
- **is_can_event** (_unknown_): Triggered when a quest can be processed.

<a name="state"></a>
- **state** (_nil_): Persist data between game sessions

