. "envy.sh"

envf envs <<-'EOT'
	if [ $# -eq 1 ] && [ -d "${1}" ]; then
		eval "$(
			envw "${1}" <<-'EOT_'
				envs "${ENVN}"
				EOT_
		)"
	else
		envs_ "$@"
	fi
	EOT

envf envy <<-'EOT'
	if [ $# -lt 1 ]; then
		set -- "$@" "."
	fi
	envy_ "$@"
	EOT

envf envp <<-'EOT'
	PS1='$(logname)@$(uname -n) $(pwd) \$ '
	EOT

envf envp <<-'EOT'
	envp_ "$@"
	PS1=". ${ENV}\n${PS1}"
	while [ $# -gt 0 ]; do
		PS1=". $(
			if [ -d "${1}" ]; then
				envd "${1}"
				realpath -- "${ENVN}"
			else
				realpath -- "${1}"
			fi
		)\n${PS1}"
		shift
	done
	PS1="\n${PS1}"
	EOT

if [ $# -eq 0 ]; then
	eval "$(
		envl IFS <<-'EOT'
			IFS=":"
			set -- ${ENVS}
			EOT
	)"
	envs "$@"
	envp "$@"
	shift $#
fi
