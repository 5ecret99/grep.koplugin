# Grep Search Module

This Lua module is a **KOReader plugin** designed for searching text within a large collection of `.epub` books. It provides an intuitive user interface for entering search terms, displaying results, and opening matched books directly in the reader. The module has been tested on **PocketBook Verse** and **Linux** platforms.

## Features

- **Dispatcher Integration**: Registers a custom action (`launch_organiser`) to trigger the search functionality.
- **Main Menu Integration**: Adds a "Grep Search" option to the application's main menu.
- **Search Input Dialog**: Prompts the user to input a search term using a dialog box.
- **Smart Case Sensitivity**: Automatically determines case sensitivity based on the input query (case-insensitive for lowercase queries, case-sensitive otherwise).
- **File Search**: Uses `find`, `grep`, and `unzip` commands to search through `.epub` files in the selected directory.
- **Search Results Display**: Displays search results in a list, showing file names and paths.
- **Document Opening**: Allows users to open selected files directly in the reader UI and highlights the search term.

## Performance

- The module has been tested with **approximately 150 `.epub` books** and performs well for medium-sized collections.
- **Note**: For very large booklists, the search process may be slower due to the use of shell commands (`find`, `grep`, `unzip`) for processing files.

## How It Works

1. **Initialization**:
   - The module registers itself with the dispatcher and main menu during initialization.

2. **Search Workflow**:
   - When triggered, the module displays an input dialog for the user to enter a search term.
   - It executes a shell command to search for the term in `.epub` files within the selected directory.
   - Results are parsed and displayed in a list.

3. **Result Interaction**:
   - Users can select a result to open the corresponding file in the reader UI.
   - The search term is passed to the reader for further interaction.

## Dependencies

- **System Commands**:
  - `find`, `grep`, `unzip`.

## Usage

1. Add the `grep.koplugin` module to your KOReader plugins directory.
2. When you are in KOReader's file explorer, you can trigger it under the **Search** menu as `grep_search`.

## Notes

- Ensure the required system commands (`find`, `grep`, `unzip`) are available on your Linux system.
- The module is optimized for `.epub` files but can be extended for other file types with minor modifications.
- Tested on **PocketBook Verse** and **Linux** with **~150 books**.

