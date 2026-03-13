# Personal Planner
### iOS-Style Task Management & Daily Planner App

> A Flutter mobile app for managing tasks, folders, calendar notes, and productivity statistics — built with a clean Cupertino (iOS-style) design and fully offline local storage using Hive.

---

## Overview

Personal Planner is a personal productivity app designed for students and professionals to organize their tasks, schedule daily activities, and track their completion progress. It features folder-based task organization, a monthly calendar with daily planning, and a statistics dashboard — all stored locally on the device with no internet connection required.

---

## Features

### Tasks
- Add, edit, and delete tasks with title and notes
- Set due dates using a custom date picker
- Mark tasks as complete/incomplete with a tap
- Group tasks by date (Today, Tomorrow, Yesterday, or specific date)
- Swipe left to delete with confirmation dialog
- Long press to edit a task
- Assign tasks to specific folders

### Folders
- Create folders with custom names and emoji icons
- View tasks per folder
- Edit folder name and icon
- Delete folder (also deletes all tasks inside)
- 16 emoji icons to choose from
- Long press to edit, swipe left to delete

### Calendar
- Monthly calendar view with navigation (previous/next month)
- Dot indicators on dates that have notes or tasks
- Tap any date to open the Day Detail screen
- Add Notes or Tasks directly to a specific day
- View tasks due on the selected day
- Edit notes via long press, delete via swipe
- Mark calendar tasks as complete

### Statistics
- Total tasks, folders, completed tasks, and calendar notes count
- Visual completion rate percentage bar
- Recent activity list (last 5 tasks with folder info)

---

## App Navigation Flow

```
App Launch
    │
    ▼
MainNavigationScreen (Bottom Tab Bar)
    │
    ├── [Tab 1] Tasks Screen
    │       ├── View all tasks grouped by date
    │       ├── Tap [+] → Add Task Dialog (title, notes, due date, folder)
    │       ├── Tap circle → Toggle complete/incomplete
    │       ├── Long press → Edit Task Dialog
    │       ├── Swipe left → Delete (with confirmation)
    │       └── Tap [ℹ] → About Dialog (developer info)
    │
    ├── [Tab 2] Folders Screen
    │       ├── View all folders with task count
    │       ├── Tap [+] → Add Folder Dialog (name + icon)
    │       ├── Tap folder → Opens filtered Task Screen for that folder
    │       ├── Long press → Edit Folder Dialog
    │       └── Swipe left → Delete folder + all its tasks (with confirmation)
    │
    ├── [Tab 3] Calendar Screen
    │       ├── Monthly calendar with dot indicators
    │       ├── Tap [<] / [>] → Navigate months
    │       └── Tap date → Day Detail Screen
    │               ├── View tasks due on that day
    │               ├── View daily planner notes
    │               ├── Tap [+] → Choose: Add Note or Add Task
    │               ├── Long press note → Edit Note
    │               └── Swipe left → Delete note (with confirmation)
    │
    └── [Tab 4] Stats Screen
            ├── Overview cards (total tasks, folders, completed, notes)
            ├── Completion rate % with progress bar
            └── Recent activity list (last 5 tasks)
```

---

## Screens

| Screen | Description |
|---|---|
| Tasks | Main task list grouped by due date with stats header |
| Folders | Grid-style list of folders with task counts |
| Calendar | Monthly calendar with dot indicators per day |
| Day Detail | Per-day view showing due tasks + daily planner notes |
| Statistics | Overview cards + completion rate + recent activity |
| Add/Edit Task Dialog | Title, notes, due date picker, folder picker |
| Add/Edit Folder Dialog | Name + emoji icon grid selector |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x (Dart) |
| UI Style | Cupertino (iOS-style) |
| Local Storage | Hive / hive_flutter |
| State Management | StatefulWidget (built-in Flutter) |
| Navigation | CupertinoTabScaffold + CupertinoPageRoute |

---

## Data Models

### Task
| Field | Type | Description |
|---|---|---|
| title | String | Task name |
| notes | String | Optional notes |
| isCompleted | bool | Completion status |
| dueDate | DateTime | When the task is due |
| folderId | String? | Optional folder reference |

### Folder
| Field | Type | Description |
|---|---|---|
| name | String | Folder name |
| icon | String | Emoji icon (default: 📁) |
| createdAt | DateTime | Creation timestamp |

### CalendarNote
| Field | Type | Description |
|---|---|---|
| content | String | Note or task text |
| date | DateTime | The day this note belongs to |
| isTask | bool | Whether it's a task or note |
| isCompleted | bool | Completion status (for tasks) |
| createdAt | DateTime | Creation timestamp |

---

## Project Structure

```
personal-planner/
├── app/
│   ├── lib/
│   │   └── main.dart         # Full app — models, adapters, screens
│   └── pubspec.yaml
├── .gitignore
└── README.md
```

---

## Installation

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio or VS Code with Flutter extensions

### Run the App

```bash
cd app
flutter pub get
flutter run
```

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
  flutter_lints: ^5.0.0
```

---

## Developer

| Name | Role |
|---|---|
| Digman, Christian D. | Developer |

---

## Roadmap

- [ ] Task priority levels (Low, Medium, High)
- [ ] Push notifications for due tasks
- [ ] Search and filter tasks
- [ ] Dark mode support
- [ ] Export tasks as PDF or CSV
- [ ] Recurring tasks
