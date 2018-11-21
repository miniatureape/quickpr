# QuickPr

Open comments from a Github Pull Request in a Vim Quickfix list.

## Installation

Use Vundle or whatever to install.

Create a file at `~/.quickpr` with contents like `<your_githubuser>:<an_api_token>`

The token needs `repo` permissions.

## Usage

While in the root of your local repo use:

`:call QuickPr`

And paste in the url of a Pull Request when prompted.

type `:copen` to see the full list. For more information, try `:help quickfix`
