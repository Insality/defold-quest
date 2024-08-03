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
	saver.bind_save_part("quest", quest.state)

	quest.init()
end
```

Or you can use other save system

```lua
local quest = require("quest.quest")

local function save_quest_state()
	-- Save a quest.state table as you wish
	save_quest_state(quest.state)
end


local function load_quest_state()
	-- Load a quest.state table as you wish
	return load_quest_state_from_save()
end


function init(self)
	quest.state = load_quest_state()
	quest.init(quest_state)
end
```


## Custom Configuration
- How to configure the module to fit your additional requirements

## Use Defold-Quest with Defold-Token module
- How to add requirements to quest start
- How to add rewards from quests

## Add your fields to quest data
- How category can be used

## Use quest as repetitive tasks
- Examples and how to use quest as daily tasks

## Use quest as game progression
- How to use quest as game progression