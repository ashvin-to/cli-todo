# 🚀 CLI Todo Application

A lightweight and fast command-line task manager built with C++. Perfect for developers who love the terminal!

## ✨ Features

- ⚡ **Blazing Fast**: Built with C++ for maximum performance
- 📝 **Simple Interface**: Clean, intuitive commands
- 💾 **Persistent Storage**: Automatically saves your tasks
- 📱 **Cross-Platform**: Works on any system with a C++ compiler
- 🔄 **Easy Installation**: One-command setup

## 🛠️ Prerequisites

- C++17 or later
- CMake (for building from source)
- Git (for cloning the repository)

## 🚀 Installation

### Linux/macOS

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/cli-todo.git
cd cli-todo

# Make the setup script executable and run it
chmod +x setup.sh
sudo ./setup.sh
```

### Windows

```powershell
# Clone the repository
git clone https://github.com/YOUR_USERNAME/cli-todo.git
cd cli-todo

# Build using CMake
mkdir build
cd build
cmake ..
cmake --build . --config Release
```

## 📝 Usage

### View all tasks
```bash
todo list
```

### Add a new task
```bash
todo add "Complete the C++ project"
todo add "Review pull requests"
```

### Complete a task
```bash
# First, list tasks to find the ID
todo list

# Then complete a task by ID
todo complete 1
```

### Remove a task
```bash
todo rm 2
```

### Get help
```bash
todo help
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

Contributions are welcome! If you have suggestions for improvements or find a bug, please open an issue or submit a pull request.
