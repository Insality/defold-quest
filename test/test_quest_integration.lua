local WALLET_ID = "wallet"

---@class quest.config
---@field reward table<string, number>? Reward tokens

---@type table<string, quest.config>
local QUEST_DATA = {
	["quest_reward_1"] = {
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "get", object = "money", required = 10 }
		},
		reward = {
			apple = 1,
			gold = 50
		}
	},
	["quest_reward_2"] = {
		required_quests = { "quest_reward_1" },
		autostart = true,
		autofinish = true,
		tasks = {
			{ action = "collect", object = "star", required = 5 }
		},
		reward = {
			diamond = 1
		}
	}
}


return function()
	describe("Defold Quest - Integration with Token", function()
		local quest ---@type quest
		local token ---@type token

		before(function()
			quest = require("quest.quest")
			token = require("token.token")

			token.init()
			token.container(WALLET_ID)
		end)

		after(function()
			token.reset_state()
			quest.reset_state()
		end)

		it("Should give rewards on quest completion", function()
			quest.init(QUEST_DATA)
			local wallet = token.container(WALLET_ID)
			quest.on_quest_event:subscribe(function(event_data)
				if event_data.type == "completed" and event_data.quest_config.reward then
					wallet:add_many(event_data.quest_config.reward, "quest")
				end
				return true  -- Mark event as handled
			end)

			assert(wallet:get("apple") == 0)
			assert(wallet:get("gold") == 0)

			quest.event("get", "money", 10)

			assert(wallet:get("apple") == 1)
			assert(wallet:get("gold") == 50)
		end)

		it("Should handle quest chain with rewards", function()
			quest.init(QUEST_DATA)
			local wallet = token.container(WALLET_ID)
			quest.on_quest_event:subscribe(function(event_data)
				if event_data.type == "completed" and event_data.quest_config.reward then
					wallet:add_many(event_data.quest_config.reward, "quest")
					return true  -- Mark event as handled
				end
			end)

			-- Complete first quest
			quest.event("get", "money", 10)
			assert(wallet:get("apple") == 1)
			assert(wallet:get("diamond") == 0)

			-- Complete second quest
			quest.event("collect", "star", 5)
			assert(wallet:get("diamond") == 1)
		end)

		it("Should track progress with direct event calls", function()
			local wallet = token.container(WALLET_ID)
			local quest_data = {
				["token_quest"] = {
					autostart = true,
					tasks = {
						{ action = "collect", object = "coin", required = 100 }
					}
				}
			}
			quest.init(quest_data)


			-- Simulate token changes driving quest progress
			wallet:add("coin", 50, "gameplay")
			quest.event("collect", "coin", 50)
			assert(quest.get_task_progress("token_quest", 1) == 50)

			wallet:add("coin", 30, "gameplay")
			quest.event("collect", "coin", 30)
			assert(quest.get_task_progress("token_quest", 1) == 80)
		end)

		it("Should handle multiple quest completions with rewards", function()
			local quest_data = {
				["repeatable_reward"] = {
					autostart = false,
					autofinish = true,
					repeatable = true,
					tasks = {
						{ action = "win", object = "battle", required = 1 }
					},
					reward = {
						exp = 10
					}
				}
			}

			local wallet = token.container(WALLET_ID)

			quest.on_quest_event:subscribe(function(event_data)
				if event_data.type == "completed" and event_data.quest_config.reward then
					wallet:add_many(event_data.quest_config.reward, "quest")
				end
				return true  -- Mark event as handled
			end)

			quest.init(quest_data)

			-- Complete multiple times
			quest.start_quest("repeatable_reward")
			quest.event("win", "battle", 1)
			assert(wallet:get("exp") == 10)

			quest.start_quest("repeatable_reward")
			quest.event("win", "battle", 1)
			assert(wallet:get("exp") == 20)

			quest.start_quest("repeatable_reward")
			quest.event("win", "battle", 1)
			assert(wallet:get("exp") == 30)
		end)
	end)
end
