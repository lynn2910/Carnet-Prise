# Contributing to Carnet de Prise

First off, thank you for considering contributing to this project! Your help is greatly appreciated. Any contribution, whether it's bug reports, feature requests, or code improvements, is welcome.

## Table of Contents
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting a Bug](#reporting-a-bug)
  - [Suggesting an Enhancement](#suggesting-an-enhancement)
- [Your First Code Contribution](#your-first-code-contribution)
  - [Prerequisites](#prerequisites)
  - [Development Workflow](#development-workflow)
- [Style Guide](#style-guide)

## How Can I Contribute?

### Reporting a Bug

If you find a bug, please make sure that:
1.  You are using the latest version of the application.
2.  You have searched the [Issues](https://github.com/lynn2910/Carnet-Prise/issues) to see if the bug has already been reported.

If it's a new bug, please open a new issue and provide the following information:
- A clear and descriptive title.
- The exact steps to reproduce the bug.
- What you expected to happen versus what actually happened.
- Screenshots, if applicable.
- The app version, Flutter version, your device model, and its OS version (Android/iOS).

### Suggesting an Enhancement

If you have an idea for a new feature or an improvement:
1.  Search the [Issues](https://github.com/lynn2910/Carnet-Prise/issues) to see if your idea has already been suggested.
2.  If it hasn't, open a new issue describing:
    - The problem your idea aims to solve.
    - A clear and concise description of the feature you are proposing.
    - Any mockups or examples that could help illustrate your idea.

## Your First Code Contribution

Ready to write some code? Here’s how to get started.

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.
- A code editor set up for Flutter (like VS Code, Intellij IDEA or Android Studio).
- [Git](https://git-scm.com/) installed.

### Development Workflow

1.  **Fork the repository**: Click the "Fork" button at the top right of this page to create a copy of this project on your own GitHub account.

2.  **Clone your fork** to your local machine:
    ```bash
    git clone https://github.com/lynn2910/Carnet-Prise.git
    cd Carnet-Prise
    ```

3.  **Create a new branch** for your changes. Choose a descriptive name (e.g., `fix/display-bug` or `feature/add-photo-sharing`).
    ```bash
    git checkout -b feature/your-feature-name
    ```

4.  **Install the project's dependencies**:
    ```bash
    flutter pub get
    ```

5.  **Make your changes** to the code.

6.  **Test your changes** by running the app and ensuring that everything works as expected.
    ```bash
    flutter run
    ```

7.  **Add and commit your changes** with a clear and descriptive commit message:
    ```bash
    git add .
    git commit -m "feat: Add feature X"
    ```
    *(Tip: Using prefixes like `feat:`, `fix:`, `docs:`, `style:` helps keep the commit history clean.)*

8.  **Push your branch** to your fork on GitHub:
    ```bash
    git push origin feature/your-feature-name
    ```

9.  **Open a Pull Request (PR)**:
    - Navigate to the original `lynn2910/Carnet-Prise` repository.
    - A banner should appear, prompting you to create a Pull Request from your new branch.
    - Fill out the PR template with a clear description of your changes and link the relevant issue if one exists (e.g., `Closes #42`).

10. **Wait for a review**: Your PR will be reviewed, and feedback may be provided. Once approved, it will be merged into the main project.

## Style Guide

To maintain code consistency, please:
- Use the built-in Dart code formatter. You can run it with `dart format .`.
- Follow the recommendations from the static analyzer. Check for issues with `flutter analyze`.
- Adhere to the naming conventions and style of the existing codebase.

Thank you again for your contribution!
