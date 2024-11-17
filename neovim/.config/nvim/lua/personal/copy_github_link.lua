local M = {}

function M.get_github_link()
	local Job = require("plenary.job") -- Requires `nvim-lua/plenary.nvim` plugin.

	-- Get the current buffer's file path
	local file_path = vim.fn.expand("%:p")
	if file_path == "" then
		print("No file detected.")
		return
	end

	-- Get the line number if a specific line is desired
	-- Determine if in visual mode
	local start_line, end_line
	if vim.fn.visualmode() ~= "" then
		-- Visual mode: Get the range of selected lines
		start_line = math.min(vim.fn.line("v"), vim.fn.line("."))
		end_line = math.max(vim.fn.line("v"), vim.fn.line("."))
	else
		-- Normal mode: Use the current line
		start_line = vim.fn.line(".")
		end_line = start_line
	end

	-- Construct the line range part of the URL
	local line_part
	if start_line == end_line then
		line_part = string.format("#L%d", start_line)
	else
		line_part = string.format("#L%d-L%d", start_line, end_line)
	end

	-- Get the GitHub remote URL
	local remote_url = nil
	Job:new({
		command = "git",
		args = { "remote", "get-url", "origin" },
		on_stdout = function(_, data)
			remote_url = data
		end,
	}):sync()

	if not remote_url then
		print("Failed to retrieve Git remote URL.")
		return
	end

	-- Replace SSH URL with HTTPS if necessary
	remote_url = remote_url:gsub("git@github%-work%.com:", "https://github.com/")
	remote_url = remote_url:gsub("git@github%.com:", "https://github.com/")
	remote_url = remote_url:gsub("%.git$", "")

	-- Get the current branch
	local branch = nil
	Job:new({
		command = "git",
		args = { "rev-parse", "--abbrev-ref", "HEAD" },
		on_stdout = function(_, data)
			branch = data
		end,
	}):sync()

	if not branch then
		print("Failed to retrieve Git branch.")
		return
	end

	-- Get the relative file path in the repository
	local repo_root = nil
	Job:new({
		command = "git",
		args = { "rev-parse", "--show-toplevel" },
		on_stdout = function(_, data)
			repo_root = data
		end,
	}):sync()

	if not repo_root then
		print("Failed to determine repository root.")
		return
	end

	print(repo_root, file_path)
	local relative_path = file_path:sub(#repo_root + 2)

	-- TODO: Add support for branches other than `main`
	branch = "main"
	-- Construct the GitHub link
	local github_link = string.format("%s/blob/%s/%s#L%s", remote_url, branch, relative_path, line_part)
	return github_link
end

function M.copy_github_link()
	local github_link = M.get_github_link()
	if not github_link then
		print("Failed to generate GitHub link.")
		return
	end

	-- Copy the GitHub link to the system clipboard
	vim.fn.setreg("+", github_link)
	print("GitHub link copied to clipboard.")
end

function M.open_github_link()
	local github_link = M.get_github_link()
	if not github_link then
		print("Failed to generate GitHub link.")
		return
	end

	-- Open the GitHub link in the default web browser
	vim.ui.open(github_link)
end

return M
