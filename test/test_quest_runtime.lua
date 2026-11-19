return function()
	describe("Defold Quest - Runtime add and remove", function()
		local quest = {}

		local PERMANENT_QUESTS = {
			["streaks"] = {
				autostart = true,
				autofinish = true,
				tasks = { { action = "streak_points", required = 100 } },
			},
		}

		local WEEKLY_QUESTS = {
			["week_42:streaks"] = {
				autostart = true,
				autofinish = true,
				tasks = { { action = "streak_points", required = 5 } },
			},
			["week_42:coins"] = {
				autostart = true,
				autofinish = true,
				tasks = { { action = "coins", required = 1 } },
			},
		}

		local function copy_table(source)
			local result = {}
			for key, value in pairs(source) do
				if type(value) == "table" then
					result[key] = copy_table(value)
				else
					result[key] = value
				end
			end
			return result
		end

		local function save_and_load()
			local saved_state = copy_table(quest.get_state())
			quest.reset_state()
			quest.set_state(saved_state)
		end

		before(function()
			quest = require("quest.quest")
			quest.reset_state()
		end)

		it("Should add quests without replacing current config", function()
			quest.init(PERMANENT_QUESTS)
			quest.event("streak_points", nil, 7)
			assert(quest.get_task_progress("streaks", 1) == 7)

			quest.add_quests(WEEKLY_QUESTS)
			assert(quest.get_quests_count() == 3)
			assert(quest.is_active("streaks"))
			assert(quest.is_active("week_42:streaks"))

			quest.event("streak_points", nil, 1)
			assert(quest.get_task_progress("streaks", 1) == 8)
			assert(quest.get_task_progress("week_42:streaks", 1) == 1)
		end)

		it("Should keep progress after load and add again", function()
			quest.init(PERMANENT_QUESTS)
			quest.event("streak_points", nil, 7)
			quest.add_quests(WEEKLY_QUESTS)
			quest.event("streak_points", nil, 1)
			quest.event("coins", nil, 1)
			assert(quest.is_completed("week_42:coins"))

			save_and_load()
			quest.init(PERMANENT_QUESTS)
			quest.add_quests(WEEKLY_QUESTS)

			assert(quest.get_task_progress("streaks", 1) == 8)
			assert(quest.get_task_progress("week_42:streaks", 1) == 1)
			assert(quest.is_active("week_42:streaks"))
			assert(quest.is_completed("week_42:coins"))
			assert(not quest.is_active("week_42:coins"))
		end)

		it("Should remove quests with progress and completed marks", function()
			quest.init(PERMANENT_QUESTS)
			quest.add_quests(WEEKLY_QUESTS)
			quest.event("coins", nil, 1)
			quest.event("streak_points", nil, 2)
			assert(quest.is_completed("week_42:coins"))
			assert(quest.get_task_progress("week_42:streaks", 1) == 2)

			quest.remove_quests({ "week_42:streaks", "week_42:coins" })

			assert(quest.get_quests_count() == 1)
			assert(not quest.is_active("week_42:streaks"))
			assert(not quest.is_completed("week_42:coins"))
			assert(quest.get_state().current["week_42:streaks"] == nil)
			assert(not quest.get_can_be_started()["week_42:streaks"])
			assert(#quest.get_state().completed == 0)

			save_and_load()
			quest.init(PERMANENT_QUESTS)

			assert(not quest.get_current()["week_42:streaks"])
			assert(not quest.get_completed()["week_42:coins"])
			assert(quest.get_state().current["week_42:streaks"] == nil)

			quest.event("streak_points", nil, 1)
			assert(quest.get_task_progress("streaks", 1) == 3)
			assert(quest.get_state().current["week_42:streaks"] == nil)
		end)

		it("Should clear quests config on reset state", function()
			quest.init(PERMANENT_QUESTS)
			quest.add_quests(WEEKLY_QUESTS)
			assert(quest.get_quests_count() == 3)

			quest.reset_state()
			assert(quest.get_quests_count() == 0)
			assert(PERMANENT_QUESTS["week_42:streaks"] == nil)
		end)

		it("Should clear saved state of quests without config", function()
			quest.init(PERMANENT_QUESTS)
			quest.add_quests(WEEKLY_QUESTS)
			quest.event("streak_points", nil, 2)

			save_and_load()
			quest.init(PERMANENT_QUESTS)
			assert(quest.get_state().current["week_42:streaks"] ~= nil)

			quest.remove_quests({ "week_42:streaks" })
			assert(quest.get_state().current["week_42:streaks"] == nil)
		end)
	end)
end
