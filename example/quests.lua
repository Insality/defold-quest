---@type table<string, quest.config>
return {
	["intro"] = {
		autostart = true,
		autofinish = true,
		tasks = {{ action = "load_scene", object = "menu" }},
		category = "game",
	},
	["tutorial_quest"] = {
		required_quests = "intro",
		autostart = true,
		tasks = {{ action = "click", object = "play" }},
		category = "game",
	}
}
