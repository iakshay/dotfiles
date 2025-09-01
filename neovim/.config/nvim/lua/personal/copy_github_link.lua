local M = {}

function M.is_git_commit_buffer()
	-- Check if the buffer's filetype is git
	local ft = vim.bo.filetype
	if ft ~= "git" then
		return nil
	end

	-- Get the buffer's full path
	local path = vim.fn.expand("%:p")

	-- Check if it's a gitsigns commit path
	if not path:match("^gitsigns://.*/.git//[a-f0-9]+$") then
		return nil
	end

	-- Extract the commit hash (last 40 characters of the path)
	local commit_id = path:match("/([a-f0-9]+)$")

	return commit_id
end

function M.get_github_repo_url()
	local Job = require("plenary.job")

	-- Get the GitHub remote URL using result from sync()
	local job = Job:new({
		command = "git",
		args = { "remote", "get-url", "origin" },
	})

	local result = job:sync()
	
	if not result or #result == 0 then
		vim.notify("Failed to retrieve Git remote URL", vim.log.levels.ERROR)
		return nil
	end

	local remote_url = result[1] -- Get first line of output

	if not remote_url or remote_url == "" then
		vim.notify("Empty remote URL", vim.log.levels.ERROR)
		return nil
	end

	-- Replace SSH URL with HTTPS if necessary
	remote_url = remote_url:gsub("git@github%-work%.com:", "https://github.com/")
	remote_url = remote_url:gsub("git@github%.com:", "https://github.com/")
	remote_url = remote_url:gsub("%.git$", "")
	return remote_url
end

function M.get_github_pr_url(pr_number)
	local remote_url = M.get_github_repo_url()
	local github_link = string.format("%s/pull/%s", remote_url, pr_number)
	return github_link
end

function M.get_github_author_commits(author)
	local remote_url = M.get_github_repo_url()
	local github_link = string.format("%s/commits?author=%s", remote_url, author)
	return github_link
end
function M.get_github_author_prs(author)
	local remote_url = M.get_github_repo_url()
	local github_link = string.format("%s/pulls?is:pull author:%s", remote_url, author)
	return github_link
end

function M.get_github_commit_url(commit)
	local remote_url = M.get_github_repo_url()
	local github_link = string.format("%s/commit/%s", remote_url, commit)
	return github_link
end

function M.get_github_file_url()
	local Job = require("plenary.job") -- Requires `nvim-lua/plenary.nvim` plugin.

	local commit = M.is_git_commit_buffer()

	if commit ~= nil then
		return M.get_github_commit_url(commit)
	end
	-- Get the current buffer's file path
	local file_path = vim.fn.expand("%:p")
	if file_path == "" then
		vim.notify("No file detected", vim.log.levels.WARN)
		return nil
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
	local remote_url = M.get_github_repo_url()

	-- Get the default branch from remote
	local branch
	
	-- Try to get default branch from remote HEAD
	local default_branch_job = Job:new({
		command = "bash",
		args = { "-c", "git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'" },
	})
	
	local default_result = default_branch_job:sync()
	
	if default_result and #default_result > 0 and default_result[1] ~= "" then
		branch = vim.trim(default_result[1])
	else
		-- Fallback: get default branch from remote show
		local remote_show_job = Job:new({
			command = "bash",
			args = { "-c", "git remote show origin 2>/dev/null | grep 'HEAD branch' | cut -d' ' -f5" },
		})
		
		local remote_result = remote_show_job:sync()
		
		if remote_result and #remote_result > 0 and remote_result[1] ~= "" then
			branch = vim.trim(remote_result[1])
		else
			-- Final fallback: use current branch
			local current_branch_job = Job:new({
				command = "git",
				args = { "rev-parse", "--abbrev-ref", "HEAD" },
			})
			local current_result = current_branch_job:sync()
			if current_result and #current_result > 0 then
				branch = vim.trim(current_result[1])
			else
				branch = "main" -- Ultimate fallback
			end
		end
	end
	

	-- Get the relative file path in the repository
	local repo_job = Job:new({
		command = "git",
		args = { "rev-parse", "--show-toplevel" },
	})

	local repo_result = repo_job:sync()
	
	if not repo_result or #repo_result == 0 then
		vim.notify("Failed to determine repository root", vim.log.levels.ERROR)
		return nil
	end

	local repo_root = repo_result[1]

	if not repo_root or repo_root == "" then
		vim.notify("Empty repository root", vim.log.levels.ERROR)
		return nil
	end

	-- print(repo_root, file_path)
	local relative_path = file_path:sub(#repo_root + 2)
	-- Construct the GitHub link
	local github_link = string.format("%s/blob/%s/%s%s", remote_url, branch, relative_path, line_part)
	return github_link
end

function M.copy_github_link()
	local github_link = M.get_github_file_url()
	if not github_link then
		vim.notify("Failed to generate GitHub link", vim.log.levels.ERROR)
		return
	end

	-- Copy the GitHub link to the system clipboard
	vim.fn.setreg("+", github_link)
	vim.notify("GitHub link copied to clipboard", vim.log.levels.INFO)
end

function M.open_github_link()
	local github_link = M.get_github_file_url()
	if not github_link then
		vim.notify("Failed to generate GitHub link", vim.log.levels.ERROR)
		return
	end

	-- Open the GitHub link in the default web browser
	vim.ui.open(github_link)
end

function M.open_github_commit(commit)
	local github_link = M.get_github_commit_url(commit)
	if not github_link then
		vim.notify("Failed to generate GitHub commit link", vim.log.levels.ERROR)
		return
	end

	-- Open the GitHub link in the default web browser
	vim.ui.open(github_link)
end

function M.open_github_pr(prNumber)
	local github_link = M.get_github_pr_url(prNumber)
	if not github_link then
		vim.notify("Failed to generate GitHub PR link", vim.log.levels.ERROR)
		return
	end

	-- Open the GitHub link in the default web browser
	vim.ui.open(github_link)
end

function M.open_github_author_commits(author)
	local github_link = M.get_github_author_commits(author)
	if not github_link then
		vim.notify("Failed to generate GitHub author commits link", vim.log.levels.ERROR)
		return
	end

	-- Open the GitHub link in the default web browser
	vim.ui.open(github_link)
end

function M.open_github_author_prs(author)
	local github_link = M.get_github_author_prs(author)
	if not github_link then
		vim.notify("Failed to generate GitHub author PRs link", vim.log.levels.ERROR)
		return
	end

	-- Open the GitHub link in the default web browser
	vim.ui.open(github_link)
end

return M
