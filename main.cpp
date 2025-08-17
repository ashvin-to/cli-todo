#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <algorithm>
#include <sstream>
#include <cctype>
#include <limits>
#include <stdexcept>
#include <thread>
#include <unistd.h>
#include <pwd.h>

// The path to the file where tasks are stored.
// It will be saved in the user's home directory.
#ifdef _WIN32
#include <windows.h>
#define TODO_FILE_PATH std::string(getenv("USERPROFILE")) + "\\todo.txt"
#else
std::string getHomeDir() {
    const char *homedir;
    if ((homedir = getenv("HOME")) == NULL) {
        homedir = getpwuid(getuid())->pw_dir;
    }
    return std::string(homedir);
}
#define TODO_FILE_PATH getHomeDir() + "/todo.txt"
#endif

using namespace std;

// Forward declaration of the main task vector to be used by all functions.
vector<class todo> tasks;
const char DELIMITER = '|';

// A simple utility function to trim whitespace from a string.
string trim(const string& str) {
    size_t first = str.find_first_not_of(" \t\n\r");
    if (string::npos == first) {
        return str;
    }
    size_t last = str.find_last_not_of(" \t\n\r");
    return str.substr(first, (last - first + 1));
}

// The main class representing a single to-do item.
class todo {
private:
    int task_id;
    string task_name;
    string task_description;
    bool task_completed;

public:
    // Updated constructor to remove the priority field.
    todo(int id, const string& name, const string& desc, bool completed) {
        this->task_id = id;
        this->task_name = name;
        this->task_description = desc;
        this->task_completed = completed;
    }

    // Getters for class members.
    int getId() const { return task_id; }
    string getName() const { return task_name; }
    string getDescription() const { return task_description; }
    bool isCompleted() const { return task_completed; }

    // Method to display a single task.
    void display_task() const {
        cout << "[" << task_id << "] " << (task_completed ? "[DONE] " : "[PENDING] ") << task_name << endl;
        if (!task_description.empty()) {
            cout << "    Description: " << task_description << endl;
        }
    }

    // Method to toggle the completion status of a task.
    void mark_completed(bool status) {
        this->task_completed = status;
    }

    // Method to serialize the task into a string for saving to a file.
    string toString() const {
        ostringstream oss;
        oss << task_id << DELIMITER
            << task_name << DELIMITER
            << task_description << DELIMITER
            << task_completed;
        return oss.str();
    }
};

// --- Function Prototypes for main logic ---
void saveTasks();
void loadTasks();
void listTasks();
void addTask(const string& name, const string& description);
void completeTask(int id);
void removeTask(int id);
void showHelp();

// --- Main application functions ---

/**
 * @brief Saves the current list of tasks to the todo file.
 */
void saveTasks() {
    ofstream file(TODO_FILE_PATH);
    if (!file.is_open()) {
        cerr << "Error: Could not open file to save tasks." << endl;
        return;
    }
    for (const auto& task : tasks) {
        file << task.toString() << endl;
    }
    file.close();
}

/**
 * @brief Loads tasks from the todo file into the global tasks vector.
 */
void loadTasks() {
    tasks.clear(); // Clear existing tasks
    ifstream file(TODO_FILE_PATH);
    if (!file.is_open()) {
        return; // File doesn't exist yet, which is fine.
    }

    string line;
    while (getline(file, line)) {
        if (trim(line).empty()) continue;

        stringstream ss(line);
        string id_str, name, desc, completed_str;

        // Updated parsing logic to remove the priority field.
        if (getline(ss, id_str, DELIMITER) &&
            getline(ss, name, DELIMITER) &&
            getline(ss, desc, DELIMITER) &&
            getline(ss, completed_str)) {
            
            try {
                int id = stoi(id_str);
                bool completed = (completed_str == "1");
                tasks.push_back(todo(id, name, desc, completed));
            } catch (const invalid_argument& e) {
                cerr << "Warning: Skipping invalid task format." << endl;
            }
        }
    }
    file.close();
}

/**
 * @brief Lists all tasks. Sorting is no longer needed without priority.
 */
void listTasks() {
    if (tasks.empty()) {
        cout << "Your to-do list is empty! 🎉" << endl;
        return;
    }

    cout << "Your To-Do List:" << endl;
    for (const auto& task : tasks) {
        task.display_task();
    }
}

/**
 * @brief Adds a new task from the command line.
 * @param name The name of the new task.
 * @param description The description of the new task.
 */
void addTask(const string& name, const string& description = "") {
    int new_id = tasks.empty() ? 1 : tasks.back().getId() + 1;
    tasks.push_back(todo(new_id, name, description, false));
    saveTasks();
    cout << "Added task: \"" << name << "\"" << endl;
}

/**
 * @brief Marks a task as completed and removes it from the list.
 * @param id The ID of the task to complete.
 */
void completeTask(int id) {
    auto it = find_if(tasks.begin(), tasks.end(), [id](const todo& t) {
        return t.getId() == id;
    });

    if (it != tasks.end()) {
        it->mark_completed(true);
        cout << "Marked task " << id << " as completed and removed." << endl;
        // The core change: call removeTask to delete it immediately.
        removeTask(id); 
    } else {
        cerr << "Error: Task with ID " << id << " not found." << endl;
    }
}

/**
 * @brief Removes a task from the list.
 * @param id The ID of the task to remove.
 */
void removeTask(int id) {
    auto it = find_if(tasks.begin(), tasks.end(), [id](const todo& t) {
        return t.getId() == id;
    });

    if (it != tasks.end()) {
        tasks.erase(it);
        saveTasks();
    } else {
        cerr << "Error: Task with ID " << id << " not found." << endl;
    }
}

/**
 * @brief Displays the help message for the application.
 */
void showHelp() {
    cout << "Simple CLI To-Do List (C++)" << endl;
    cout << "Usage: todo [command] [arguments]" << endl;
    cout << "\nCommands:" << endl;
    cout << "  list                - Display all tasks." << endl;
    cout << "  add \"task name\"   - Add a new task with a name." << endl;
    cout << "  complete <id>       - Marks a task as completed and removes it." << endl;
    cout << "  rm <id>             - Remove a task by its ID." << endl;
    cout << "  help                - Show this help message." << endl;
    cout << "\nExamples:" << endl;
    cout << "  $ ./todo list" << endl;
    cout << "  $ ./todo add \"Finish the Arch setup\"" << endl;
    cout << "  $ ./todo complete 1" << endl;
}


int main(int argc, char* argv[]) {
    loadTasks(); // Load tasks at the beginning of the program.

    if (argc < 2) {
        listTasks();
        return 0;
    }

    string command = argv[1];

    if (command == "list") {
        listTasks();
    } else if (command == "add") {
        if (argc < 3) {
            cerr << "Error: 'add' requires a task name in quotes." << endl;
            return 1;
        }
        string name;
        stringstream ss;
        for (int i = 2; i < argc; ++i) {
            ss << argv[i] << " ";
        }
        name = trim(ss.str());
        addTask(name, ""); // The description is optional and can be left blank.
    } else if (command == "complete") {
        if (argc < 3) {
            cerr << "Error: 'complete' requires a task ID." << endl;
            return 1;
        }
        try {
            completeTask(stoi(argv[2]));
        } catch (const invalid_argument& e) {
            cerr << "Error: Invalid task ID. Please enter a number." << endl;
        }
    } else if (command == "rm") {
        if (argc < 3) {
            cerr << "Error: 'rm' requires a task ID." << endl;
            return 1;
        }
        try {
            removeTask(stoi(argv[2]));
        } catch (const invalid_argument& e) {
            cerr << "Error: Invalid task ID. Please enter a number." << endl;
        }
    } else if (command == "help" || command == "--help" || command == "-h") {
        showHelp();
    } else {
        cerr << "Error: Unknown command '" << command << "'. Use 'help' to see available commands." << endl;
        showHelp();
        return 1;
    }

    return 0;
}