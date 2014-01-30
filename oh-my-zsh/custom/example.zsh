# functions to switch hosts files, to avoid distractions
function isolate(){
	ISOLATION_MODE=true
	cp /etc/hosts.blocked /etc/hosts
}

function unisolate(){
	ISOLATION_MODE=false
	cp /etc/hosts.unblocked /etc/hosts
}

function isolate_prompt_info(){
	if [[ "$ISOLATION_MODE" == "true" ]]
	then
		echo "\e[38;5;196m◕︵◕"
	else
		echo -e "\e[38;5;190m◕◡◕"
	fi
}

#reload zshrc
alias reload='source ~/.zshrc'

# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}"
	open "http://localhost:${port}/"
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# Create a new directory and enter it
function md() {
	mkdir -p "$@" && cd "$@"
}

#Todo - Show time since last commit in prompt
function git_time_since_commit(){
  #echo $(git log -1 --pretty=format:"%ad" --date="relative")
}

function imgur {
  curl -s -F "image=@$1" -F "key=486690f872c678126a2c09a9e196ce1b" https://imgur.com/api/upload.xml | grep -E -o "<original_image>(.)*</original_image>" | grep -E -o "http://i.imgur.com/[^<]*"
}
export isolate_prompt_info