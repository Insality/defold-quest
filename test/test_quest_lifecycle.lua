return function()
	describe("Defold Quest - Lifecycle", function()
		local quest = {}

		before(function()
			quest = require("quest.quest")
			quest.reset_state()
			-- Clear queue from previous tests
			quest.on_quest_event:clear()
			-- Clear validation events
			quest.is_can_start:clear()
			quest.is_can_complete:clear()
			quest.is_can_event:clear()
		end)

		after(function()
		end)

		it("Should handle quest dependencies", function()
			local quest_data = {
				["quest_1"] = {
					autostart = true,
					autofinish = true,
					tasks = {
						{ action = "get", object = "money", required = 10 }
					}
				},
				["quest_2"] = {
					required_quests = { "quest_1" },
					autostart = true,
					autofinish = true,
					tasks = {
						{ action = "get", object = "exp", required = 100 }
					}
				}
			}

			quest.init(quest_data)

			-- quest_1 should be active, quest_2 should not
			assert(quest.is_active("quest_1"))
			assert(not quest.is_active("quest_2"))

			-- Complete quest_1
			quest.event("get", "money", 10)
			assert(quest.is_completed("quest_1"))

			-- quest_2 should now be active
			assert(quest.is_active("quest_2"))
		end)

		it("Should handle manual quest start", function()
			local quest_data = {
				["manual_quest"] = {
					autostart = false,
					autofinish = true,
					tasks = {
						{ action = "collect", object = "item", required = 1 }
					}
				}
			}

			quest.init(quest_data)

			-- Quest should not be active initially
			assert(not quest.is_active("manual_quest"))

			-- Start manually
			quest.start_quest("manual_quest")
			assert(quest.is_active("manual_quest"))
		end)

		it("Should handle manual quest completion", function()
			local quest_data = {
				["manual_complete"] = {
					autostart = true,
					autofinish = false,
					tasks = {
						{ action = "collect", object = "item", required = 1 }
					}
				}
			}

			quest.init(quest_data)

			quest.event("collect", "item", 1)

			-- Quest should still be active (no autofinish)
			assert(quest.is_active("manual_complete"))

			-- Complete manually
			quest.complete_quest("manual_complete")
			assert(quest.is_completed("manual_complete"))
		end)

		it("Should handle repeatable quests", function()
			local quest_data = {
				["daily_quest"] = {
					autostart = false,
					autofinish = true,
					repeatable = true,
					tasks = {
						{ action = "win", object = "game", required = 1 }
					}
				}
			}

			quest.init(quest_data)

			-- Start and complete
			quest.start_quest("daily_quest")
			quest.event("win", "game", 1)

			-- Should not be in completed list (repeatable)
			local completed = quest.get_completed()
			assert(not completed["daily_quest"])

			-- Should be able to start again
			assert(quest.is_can_start_quest("daily_quest"))
			quest.start_quest("daily_quest")
			assert(quest.is_active("daily_quest"))
		end)

		it("Should reset quest", function()
			local quest_data = {
				["reset_quest"] = {
					autostart = true,
					autofinish = true,
					tasks = {
						{ action = "get", object = "coins", required = 10 }
					}
				}
			}

			quest.init(quest_data)

			quest.event("get", "coins", 10)
			assert(quest.is_completed("reset_quest"))

			quest.reset_quest("reset_quest")
			assert(not quest.is_completed("reset_quest"))
		end)

		it("Should force complete quest", function()
			local quest_data = {
				["force_quest"] = {
					autostart = true,
					autofinish = false,
					tasks = {
						{ action = "get", object = "item", required = 100 }
					}
				}
			}

			quest.init(quest_data)

			-- Force complete without progress
			quest.force_complete_quest("force_quest")
			assert(quest.is_completed("force_quest"))
		end)

		it("Should check if quest can be started", function()
			local quest_data = {
				["quest_1"] = {
					autostart = true,
					autofinish = true,
					tasks = {
						{ action = "get", object = "a", required = 1 }
					}
				},
				["quest_2"] = {
					required_quests = { "quest_1" },
					autostart = false,
					tasks = {
						{ action = "get", object = "b", required = 1 }
					}
				}
			}

			quest.init(quest_data)

			-- quest_2 cannot be started yet
			assert(not quest.is_can_start_quest("quest_2"))

			-- Complete quest_1
			quest.event("get", "a", 1)

			-- Now quest_2 can be started
			assert(quest.is_can_start_quest("quest_2"))
		end)

		it("Should check if quest can be completed", function()
			local quest_data = {
				["check_quest"] = {
					autostart = true,
					autofinish = false,
					tasks = {
						{ action = "collect", object = "star", required = 5 }
					}
				}
			}

			quest.init(quest_data)

			assert(not quest.is_can_complete_quest("check_quest"))

			quest.event("collect", "star", 3)
			assert(not quest.is_can_complete_quest("check_quest"))

			quest.event("collect", "star", 2)
			assert(quest.is_can_complete_quest("check_quest"))
		end)

		it("Should add quests dynamically", function()
			quest.init({})

			quest.add_quests({
				["new_quest"] = {
					autostart = true,
					autofinish = true,
					tasks = {
						{ action = "test", object = "dynamic", required = 1 }
					}
				}
			})

			assert(quest.get_quests_count() == 1)
			assert(quest.is_active("new_quest"))
		end)

		it("Should clear all progress", function()
			local quest_data = {
				["quest_1"] = {
					autostart = true,
					autofinish = true,
					tasks = {
						{ action = "get", object = "item", required = 5 }
					}
				}
			}

			quest.init(quest_data)
			quest.event("get", "item", 5)

			assert(quest.is_completed("quest_1"))

			quest.clear_all_progress()
			assert(not quest.is_completed("quest_1"))
		end)

		it("Should use custom is_can_start validation", function()
			local allow_start = false

			-- Subscribe BEFORE init
			quest.is_can_start:subscribe(function(quest_id, quest_config)
				return allow_start
			end)

			local quest_data = {
				["custom_quest"] = {
					autostart = true,
					tasks = {
						{ action = "get", object = "item", required = 1 }
					}
				}
			}

			quest.init(quest_data)

			-- Should not start due to custom validation
			assert(not quest.is_active("custom_quest"))

			-- Allow start
			allow_start = true
			quest.update_quests()

			assert(quest.is_active("custom_quest"))
		end)

		it("Should use custom is_can_complete validation", function()
			local allow_complete = false

			-- Subscribe BEFORE init
			quest.is_can_complete:subscribe(function(quest_id, quest_config)
				return allow_complete
			end)

			local quest_data = {
				["custom_complete"] = {
					autostart = true,
					autofinish = true,
					tasks = {
						{ action = "get", object = "item", required = 1 }
					}
				}
			}

			quest.init(quest_data)
			quest.event("get", "item", 1)

			-- Should not complete due to custom validation
			assert(quest.is_active("custom_complete"))

			-- Allow complete
			allow_complete = true
			quest.update_quests()

			assert(quest.is_completed("custom_complete"))
		end)
	end)
end

