This architecture is a powerhouse for personal knowledge management. By using **Obsidian-MCP**, you are moving away from fragile APIs and moving toward a robust, filesystem-level integration that treats your vault like a professional code repository.

Here is the complete setup in English, following **First Principles**: data integrity, modularity, and automated validation.

---

### 1. The Dockerfile (Base: Bookworm-Slim)

This Dockerfile builds the **ObsidianPilot** server and ensures that `git` and `sqlite3` are present for indexing and version control.


---

### 2. The docker-compose.yml

This orchestrates the "Brain" (OpenClaw) and the "Memory Bridge" (ObsidianPilot).


---

### 3. Implementing the "Audit Guard": The Git Hook

To satisfy your requirement of "checking for done" and "archiving correctly," we must place a gatekeeper at the Git level.

#### Step A: Place the Pre-commit Hook [ Dockerfile does it ]

Inside your Obsidian Vault, go to the hidden `.git/hooks/` folder and paste the file named `pre-commit`.

#### Step B: Conventional Commits (CC Hooks) [ Dockerfile does it ]

To enforce the `archive(lesson): title` format, paste the file named `commit-msg` in the same `.git/hooks/` folder.


---

### 4. How the "First Principles" Logic Works

1. **Extraction:** You send a prompt. OpenClaw uses "First Principles" to distill the info.
2. **Writing:** OpenClaw uses the **ObsidianPilot MCP** to save the note into `/vault/Archive/lesson_name.md`.
3. **The Validation:** OpenClaw executes a shell command: `git add . && git commit -m "archive(logic): first principles of X"`.
4. **The "Done" Check:** * The **Pre-commit Hook** scans the file.
* If it finds an empty checkbox (`[ ]`), it kills the commit.
* OpenClaw receives the error, realizes its mistake, checks the box in the file, and tries again.


5. **Persistence:** Your vault is now a verified timeline of "concluded" knowledge.

### Why this is the "Gold Standard":

* **Zero Noise:** The SQLite index in ObsidianPilot ensures the AI only sees relevant data.
* **Immutable Proof:** Using `git` means you can prove *when* a lesson was mastered.
* **Autonomous Quality:** The IA is "forced" to be disciplined by your Speckit (the Hook).


6. The "Recovery" System Prompt (Essential) 📝 ⚙️ 🛠️ 🔧


Since you are using Speckit + Hooks, the OpenClaw agent needs to know how to react when the "Pre-commit Audit" fails.


Add this to your OpenClaw System Instructions:

Memory & Archiving Protocol:

You must save all distilled lessons to the /vault/Archive/ directory.

After writing a file, you must commit it using: git add . && git commit -m "archive(logic): [title]"

Audit Failure Handling: I have a pre-commit hook that blocks commits if a file in Archive/ contains uncompleted tasks ([ ]).

If your commit command returns an error code (Exit 1) and mentions "Audit Failure," you must:

Re-read the file you just wrote.

Ensure all - [ ] are changed to - [x].

Attempt the commit again.

Never leave a lesson in the Archive folder without successfully committing it.