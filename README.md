# Hyperflask Getting Started App

This is the repository for the [Hyperflask Getting Started guide](https://hyperflask.dev/getting-started/)

## Development environment

Using Visual Studio Code:

1. Open your project folder in vscode
2. Use the Dev Containers: Reopen in Container command from the Command Palette
3. Launch your app using F5

Using other editors:

1. [Install devcontainers-cli](https://github.com/devcontainers/cli#npm-install)
2. Start dev container: `devcontainer up --workspace-folder .`
3. Launch your app: `devcontainer exec uv run hyperflask dev`
3. Go to http://localhost:5000

## Deployment

From inside the development container, run:

    uv run hyperflask deploy
