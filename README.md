![](media/logo.png)

[![GitHub release (latest by date)](https://img.shields.io/github/v/tag/insality/defold-quest?style=for-the-badge&label=Release)](https://github.com/Insality/defold-quest/tags)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/insality/defold-quest/ci-workflow.yml?branch=master&style=for-the-badge)](https://github.com/Insality/defold-quest/actions)
[![codecov](https://img.shields.io/codecov/c/github/Insality/defold-quest?style=for-the-badge)](https://codecov.io/gh/Insality/defold-quest)

[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/insality) [![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/insality) [![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/insality)


# Disclaimer

The library in development stage. May be not fully tested and README may be not full. If you have any questions, please, create an issue. This library is an adoptation of [Quest](https://github.com/Insality/defold-eva/blob/master/eva/modules/quest.lua) module from my [Defold-Eva](https://github.com/Insality/defold-eva) library.


# Quest

**Quest** - module is a comprehensive system for managing quests in a game. It allows for the registration, tracking, and completion of quests, with various events and callbacks to handle quest-related activities.


## Features

- **Quest Management** - Create, start, and complete quests with ease.
- **Quest Progress** - Track the progress of quests and their tasks.
- **Quest Events** - Listen for quest-related events and adjust it for your needs.


## Setup

### [Dependency](https://www.defold.com/manuals/libraries/)

Open your `game.project` file and add the following line to the dependencies field under the project section:

**[Defold Event](https://github.com/Insality/defold-event)**

```
https://github.com/Insality/defold-event/archive/refs/tags/11.zip
```

**[Defold Quest](https://github.com/Insality/defold-quest/archive/refs/tags/1.zip)**

```
https://github.com/Insality/defold-quest/archive/refs/tags/1.zip
```

After that, select `Project ▸ Fetch Libraries` to update [library dependencies]((https://defold.com/manuals/libraries/#setting-up-library-dependencies)). This happens automatically whenever you open a project so you will only need to do this if the dependencies change without re-opening the project.

### Library Size

> **Note:** The library size is calculated based on the build report per platform

| Platform         | Library Size |
| ---------------- | ------------ |
| HTML5            | **3.91 KB**  |
| Desktop / Mobile | **7.57 KB**  |


## API Reference

### Quick API Reference

```lua
quest.init(quest_config_path)
quest.reset_state()

-- Events
quest.on_quest_register -- event (quest_id, quest_config)
quest.on_quest_start -- event (quest_id, quest_config)
quest.on_quest_completed -- event (quest_id, quest_config)
quest.on_quest_progress -- event (quest_id, quest_config, delta, total, task_index)
quest.on_quest_task_completed -- event (quest_id, quest_config, task_index)
quest.is_can_start -- event (quest_id, quest_config): boolean
quest.is_can_complete -- event (quest_id, quest_config): boolean
quest.is_can_event -- event (quest_id, quest_config): boolean

quest.quest_event(action, object, amount)
quest.get_current(category)
quest.get_progress(quest_id)
quest.get_completed(category)
quest.is_active(quest_id)
quest.is_completed(quest_id)
quest.is_current_with_task(action, object)
quest.is_can_start_quest(quest_id)
quest.start_quest(quest_id)
quest.is_can_complete_quest(quest_id)
quest.complete_quest(quest_id)
quest.force_complete_quest(quest_id)
quest.reset_progress(quest_id)
quest.get_quest_config(quest_id)
quest.update_quests()
quest.set_logger(logger_instance)
```

### API Reference

Read the [API Reference](API_REFERENCE.md) file to see the full API documentation for the module.

## Use Cases

Read the [Use Cases](USE_CASES.md) file to see several examples of how to use the this module in your Defold game development projects.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Issues and Suggestions

For any issues, questions, or suggestions, please [create an issue](https://github.com/Insality/defold-quest/issues).

## 👏 Contributors

<a href="https://github.com/Insality/defold-quest/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=insality/defold-quest"/>
</a>

## ❤️ Support project ❤️

Your donation helps me stay engaged in creating valuable projects for **Defold**. If you appreciate what I'm doing, please consider supporting me!

[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/insality) [![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/insality) [![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/insality)
