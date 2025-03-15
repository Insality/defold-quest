local WALLET_ID = "wallet"

---@type table<string, quest.config>
local QUEST_DATA = {
	["quest_collect_1"] = {
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "get", object = "money", required = 10 },
			{ action = "get", object = "exp", required = 100 }
		},
		reward = {
			apple = 1
		}
	},
	["quest_collect_2"] = {
		required_quests = { "quest_collect_1" },
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "get", object = "money", required = 30 },
			{ action = "get", object = "exp", required = 200 }
		},
	},
	["quest_collect_3"] = {
		required_quests = { "quest_collect_2" },
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "get", object = "money", required = 50 },
			{ action = "get", object = "exp", required = 300 }
		},
	},
	["quest_destroy_1"] = {
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "destroy", object = "stone", required = 100 }
		},
	},
	["quest_destroy_2"] = {
		required_quests = { "quest_destroy_1" },
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "destroy", object = "stone", required = 200 },
		},
	}
}


return function()
	describe("Defold Quest + Token", function()
		local quest = {}
		local token = {}

		before(function()
			quest = require("quest.quest")
			token = require("token.token")

			token.init()
			token.create_container(WALLET_ID)

			quest.reset_state()
		end)

		after(function()
		end)

		it("Should correct start quests", function()
			quest.init(QUEST_DATA)
			assert(quest.get_current()["quest_collect_1"])
			assert(quest.get_current()["quest_destroy_1"])
		end)

		it("Should throw start_quest event", function()
			local register_quests = {}
			local start_quests = {}

			quest.on_quest_register:subscribe(function(quest_id, quest_config)
				register_quests[quest_id] = quest_config
			end)

			quest.on_quest_start:subscribe(function(quest_id, quest_config)
				start_quests[quest_id] = quest_config
			end)

			quest.init(QUEST_DATA)
			assert(register_quests["quest_collect_1"])
			assert(register_quests["quest_destroy_1"])
			assert(start_quests["quest_collect_1"])
			assert(start_quests["quest_destroy_1"])
		end)

		it("Should throw progress,task completed, end events", function()
			local progress_quest = {}
			local task_complete_quest = {}
			local completed_quest = {}

			quest.on_quest_progress:subscribe(function(quest_id, quest_config, delta, total, task_index)
				progress_quest[quest_id] = { task_index = task_index, delta = delta, total = total }
			end)

			quest.on_quest_task_completed:subscribe(function(quest_id, quest_config, task_index)
				task_complete_quest[quest_id] = task_index
			end)

			quest.on_quest_completed:subscribe(function(quest_id, quest_config)
				completed_quest[quest_id] = true
			end)

			quest.init(QUEST_DATA)
			quest.quest_event("get", "money", 5)
			assert(progress_quest["quest_collect_1"])
			assert(progress_quest["quest_collect_1"].task_index == 1)
			assert(progress_quest["quest_collect_1"].delta == 5)
			assert(progress_quest["quest_collect_1"].total == 5)
			assert(not task_complete_quest["quest_collect_1"])

			quest.quest_event("get", "exp", 100)
			assert(progress_quest["quest_collect_1"])
			assert(progress_quest["quest_collect_1"].task_index == 2)
			assert(progress_quest["quest_collect_1"].delta == 100)
			assert(progress_quest["quest_collect_1"].total == 100)
			assert(task_complete_quest["quest_collect_1"] == 2)

			quest.quest_event("get", "money", 4)
			assert(progress_quest["quest_collect_1"])
			assert(progress_quest["quest_collect_1"].task_index == 1)
			assert(progress_quest["quest_collect_1"].delta == 4)
			assert(progress_quest["quest_collect_1"].total == 9)

			quest.quest_event("get", "money", 10)
			assert(task_complete_quest["quest_collect_1"] == 1)
			assert(completed_quest["quest_collect_1"])
		end)

		it("Should give rewards", function()
			quest.on_quest_completed:subscribe(function(quest_id, quest_config)
				if quest_config.reward then
					token.add_many(WALLET_ID, quest_config.reward, "quest")
				end
			end)

			quest.init(QUEST_DATA)

			assert(token.get(WALLET_ID, "apple") == 0)

			quest.quest_event("get", "money", 10)
			quest.quest_event("get", "exp", 100)
			assert_equal(token.get(WALLET_ID, "apple"), 1)
		end)

		--it("Should start new quests after complete other", function()
		--	quest.init()
		--	eva.wallet.add("level", 1, "test")
		--	quest.quest_event("get", "money", 2000)
		--	assert(events[END].calls == 1)
		--	assert(events[END].params[1].quest_id == "quest_1")

		--	assert(events[REGISTER].calls == 6)
		--	assert(events[START].calls == 2)
		--	assert(events[START].params[1].quest_id == "quest_2")
		--	local current = quest.get_current()
		--	assert(contains(current, "quest_2"))
		--end)

		--it("Should check start quests after changing tokens", function()
		--	quest.init()
		--	quest.quest_event("get", "money", 2000)
		--	assert(events[END].calls == 1)
		--	assert(events[START].calls == 1)
		--	assert(events[REGISTER].calls == 5)

		--	eva.wallet.add("level", 1, "test")
		--	assert(events[START].calls == 2)
		--	assert(events[START].params[1].quest_id == "quest_2")
		--end)

		--it("Should not complete, before become available (offline quests)", function()
		--	quest.init()
		--	quest.quest_event("get", "exp", 90)
		--	assert(events[PROGRESS].calls == 1)
		--	assert(events[END].calls == 0)

		--	quest.quest_event("get", "exp", 20)
		--	assert(events[PROGRESS].calls == 2)
		--	assert(events[PROGRESS].params[1].delta == 10)
		--	assert(events[END].calls == 0)

		--	eva.wallet.add("level", 2, "test")
		--	assert(events[END].calls == 1)
		--end)

		--it("Should can be required by multiply quests", function()
		--	quest.init()
		--	assert(not quest.is_active("quest_5"))
		--	assert(quest.is_active("quest_1"))
		--	assert(not quest.is_active("quest_4"))

		--	quest.quest_event("get", "exp", 100)
		--	assert(not quest.is_completed("quest_4"))
		--	eva.wallet.add("level", 3, "test")
		--	assert(quest.is_completed("quest_4"))

		--	assert(not quest.is_active("quest_5"))

		--	quest.quest_event("get", "money", 100)
		--	assert(quest.is_completed("quest_1"))
		--	assert(quest.is_active("quest_5"))
		--end)

		--it("Should correct save quest progress", function()
		--	quest.init()
		--	eva.wallet.add("level", 3, "test")
		--	quest.quest_event("get", "exp", 100)
		--	quest.quest_event("get", "money", 10)
		--	quest.quest_event("get", "money", 150)
		--	local completed = quest.get_completed()
		--	assert(contains(completed, "quest_1"))
		--	assert(contains(completed, "quest_4"))
		--	assert(#completed == 2)
		--	local current = quest.get_current()
		--	assert(contains(current, "quest_2"))
		--	assert(contains(current, "quest_5"))
		--	assert(#current == 2)

		--	local q2_progress = quest.get_progress("quest_2")
		--	local q5_progress = quest.get_progress("quest_5")
		--	assert(q2_progress[1] == 150)
		--	assert(q5_progress[1] == 0)

		--	eva.saver.save()
		--	eva.init("/resources/tests/eva_tests.json")
		--	quest.init()

		--	q2_progress = quest.get_progress("quest_2")
		--	q5_progress = quest.get_progress("quest_5")
		--	assert(q2_progress[1] == 150)
		--	assert(q5_progress[1] == 0)
		--end)

		--it("Should have custom logic to start, send events, and to end quests", function()
		--	local is_can_start = false
		--	local is_can_end = false
		--	local is_can_event = false

		--	local settings = {
		--		is_can_start = function(quest_id)
		--			return is_can_start
		--		end,
		--		is_can_complete = function(quest_id)
		--			return is_can_end
		--		end,
		--		is_can_event = function(quest_id)
		--			return is_can_event
		--		end,
		--	}
		--	quest.set_settings(settings)
		--	quest.init()

		--	assert(events[START].calls == 0)
		--	assert(events[REGISTER].calls == 4)
		--	is_can_start = true
		--	quest.update_quests()
		--	quest.update_quests()
		--	assert(events[START].calls == 1)
		--	assert(events[REGISTER].calls == 5)

		--	quest.quest_event("get", "money", 10)
		--	assert(events[PROGRESS].calls == 0)

		--	is_can_event = true
		--	quest.quest_event("get", "money", 10)
		--	assert(events[PROGRESS].calls == 1)
		--	assert(events[END].calls == 0)

		--	is_can_end = true
		--	quest.update_quests()
		--	assert(events[END].calls == 1)
		--end)

		--it("Should have custom callbacks on main quest events", function()
		--	local settings = {
		--		on_quest_start = function() end,
		--		on_quest_progress = function() end,
		--		on_quest_task_completed = function() end,
		--		on_quest_completed = function() end,
		--	}
		--	mock.mock(settings)
		--	quest.set_settings(settings)
		--	quest.init()
		--	assert(settings.on_quest_start.calls == 1)

		--	quest.quest_event("get", "exp", 90)
		--	assert(settings.on_quest_progress.calls == 1)

		--	quest.quest_event("get", "exp", 20)
		--	assert(settings.on_quest_progress.calls == 2)
		--	assert(settings.on_quest_task_completed.calls == 1)

		--	eva.wallet.add("level", 2, "test")
		--	assert(settings.on_quest_start.calls == 2)
		--	assert(settings.on_quest_completed.calls == 1)
		--end)

		--it("Should register offline quests", function()
		--	quest.init()
		--	assert(events[REGISTER].calls == 5)
		--	eva.wallet.add("level", 1) -- up to 2 level
		--	assert(events[REGISTER].calls == 5)
		--	assert(events[END].calls == 0)
		--end)

		--it("Should autostart quests, what have been registered", function()
		--	quest.init()
		--	assert(events[START].calls == 1)
		--	eva.wallet.add("level", 2) -- up to 3 level
		--	assert(events[START].calls == 2)
		--	assert(events[START].params[1].quest_id == "quest_4")
		--end)

		--it("Should manual start quests without offline mode", function()
		--	quest.init()
		--	assert(events[START].calls == 1)
		--	quest.start_quest("quest_8")
		--	assert(events[START].calls == 2)

		--	assert(not quest.is_can_start_quest("quest_6"))
		--	quest.start_quest("quest_6") -- cant start, need level 2
		--	assert(not quest.is_can_start_quest("quest_9"))
		--	quest.start_quest("quest_9") -- cant start, need quest_8
		--	assert(events[START].calls == 2)
		--	assert(events[REGISTER].calls == 6)
		--	assert(events[REGISTER].params[1].quest_id == "quest_8")

		--	assert(events[END].calls == 0)
		--	quest.quest_event("get", "item", 1)
		--	assert(events[END].calls == 1)
		--	assert(events[START].calls == 2)

		--	assert(quest.is_can_start_quest("quest_9"))
		--	quest.start_quest("quest_9")
		--	assert(events[START].calls == 3)

		--	assert(not quest.is_can_start_quest("quest_9"))
		--	quest.start_quest("quest_9") -- We should not start quest twice
		--	assert(events[START].calls == 3)

		--	eva.wallet.add("level", 1)
		--	assert(events[START].calls == 3)
		--	assert(events[END].calls == 1)
		--end)

		--it("Should manual start quests with offline mode", function()
		--	quest.init()
		--	assert(events[START].calls == 1)
		--	quest.quest_event("get", "item", 1)

		--	assert(events[END].calls == 0)
		--	assert(events[START].calls == 1)

		--	assert(not quest.is_can_start_quest("quest_6"))
		--	quest.start_quest("quest_6")
		--	assert(events[END].calls == 0)
		--	assert(events[START].calls == 1)

		--	eva.wallet.add("level", 1)
		--	assert(quest.is_can_start_quest("quest_6"))
		--	quest.start_quest("quest_6")
		--	assert(events[END].calls == 1)
		--	assert(events[START].calls == 2)
		--end)

		--it("Should not autofinish quest without autofinish", function()
		--	quest.init()
		--	assert(events[START].calls == 1)
		--	assert(events[REGISTER].calls == 5)
		--	quest.start_quest("quest_10")
		--	assert(events[REGISTER].calls == 6)
		--	assert(events[START].calls == 2)
		--	assert(events[END].calls == 0)
		--	assert(not quest.is_can_complete_quest("quest_10"))
		--	quest.complete_quest("quest_10")
		--	assert(events[END].calls == 0)

		--	quest.quest_event("get", "gold", 1)
		--	assert(events[END].calls == 0)
		--	assert(quest.is_can_complete_quest("quest_10"))

		--	quest.complete_quest("quest_10")
		--	assert(events[END].calls == 1)
		--	assert(not quest.is_can_complete_quest("quest_10"))

		--	assert(quest.is_can_start_quest("quest_11"))
		--	quest.start_quest("quest_11")
		--	assert(events[START].calls == 3)

		--	quest.quest_event("get", "gold", 1)
		--	quest.complete_quest("quest_11")
		--	assert(events[START].calls == 4)
		--	assert(quest.is_active("quest_12"))
		--	assert(quest.is_can_complete_quest("quest_12"))
		--end)

		--it("Should correct work quest without autostart and autofinish", function()
		--	quest.init()
		--	assert(events[START].calls == 1)
		--	eva.wallet.add("gold", 100)
		--	assert(events[START].calls == 2)
		--	assert(events[END].calls == 0)
		--	quest.quest_event("get", "gold", 1)
		--	assert(events[END].calls == 0)
		--	assert(quest.is_can_complete_quest("quest_14"))
		--	quest.complete_quest("quest_14")
		--	assert(events[END].calls == 1)
		--end)

		--it("Should correct work with repeatable quests (daily example)", function()
		--	quest.init()
		--	assert(events[START].calls == 1)

		--	assert(not quest.is_active("quest_daily_1"))
		--	quest.start_quest("quest_daily_1")
		--	assert(events[START].calls == 2)
		--	assert(quest.is_active("quest_daily_1"))
		--	assert(not quest.is_can_complete_quest("quest_daily_1"))

		--	quest.quest_event("win", "game", 1)
		--	assert(not quest.is_can_complete_quest("quest_daily_1"))
		--	quest.quest_event("play", "hero", 1)
		--	assert(quest.is_can_complete_quest("quest_daily_1"))
		--	quest.complete_quest("quest_daily_1")
		--	assert(not quest.is_active("quest_daily_1"))
		--	assert(quest.is_can_start_quest("quest_daily_1"))
		--	quest.start_quest("quest_daily_1")

		--	assert(events[END].calls == 1)
		--	assert(events[START].calls == 3)
		--end)

		--it("Should work with single progress tasks", function()
		--	quest.init()
		--	quest.start_quest("earn_max_score")
		--	assert(quest.is_active("earn_max_score"))
		--	assert(not quest.is_can_complete_quest("earn_max_score"))

		--	quest.quest_event("get", "score", 4000)
		--	assert(not quest.is_can_complete_quest("earn_max_score"))

		--	quest.quest_event("get", "score", 4000)
		--	assert(not quest.is_can_complete_quest("earn_max_score"))

		--	quest.quest_event("get", "score", 5000)
		--	assert(quest.is_can_complete_quest("earn_max_score"))
		--end)
	end)
end
