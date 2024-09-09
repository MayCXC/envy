# envy
stackable and composable `sh` profiles

`envy` is a script that enables a [POSIX User Portability Utilities Shell](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/sh.html) to source multiple profiles, and share definitions between them.
these constructs are useful for automation and resource sharing in both interactive and non-interactive environments.

## Synopsis

```sh
envy [path/to/profile/env.sh] [...]
```

## Examples

```sh
$ cat path/to/profile/a.sh
$ cat path/to/profile/b.sh
$ envy path/to/profile/a.sh path/to/profile/b.sh
```

## Environment Variables

the following environment variables are modified and exported from envy:

* `$ENVY` is the absolute path of the `envy` executable. it is used to resolve the default value of `$ENVYSH`, or otherwise can be used to extend it, [(ex.)](#advanced).

* `$ENVYSH` is the absolute path of `envy.sh`. it can be sourced from a profile to allow use of its shell functions, [(ex.)](https://github.com/MayCXC/envy/blob/master/env.sh).
this entrypoint can also be extended with its own utility functions, in the same manner as other profiles.

* `$ENVSH` is the absolute path of the default `env.sh`. it can be sourced from a profile to extend its behavior. the default `env.sh` sources `$ENVYSH`, sources each profile in `$ENVS` with `envs`, and sets new values for `$HOME` and `$PS1`.

* `$ENVS` is an `$IFS` delimited list of profile paths to source. it defaults to `.` if `${ENV}` is not null.

* `$ENV` is the same environment variable received by a [POSIX User Portability Utilities Shell](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/sh.html). its default value is `$ENVSH`.

the following environment variables are set by, but not exported from, envy:

* `ENVSTAIL`
* `ENVSARGS`
* `ENVSSPIN`

finally, the default profile appends `$ENVD` to profile paths that resolve to a directory. its default value is `env.sh`.

## POSIX Shell Functions

the `envf` function is used to define and extend shell functions:

```sh
envf fname -<<'EOT'
  echo parent
  if [ $# -gt 0 ]; then
    echo $@
    shift
    fname "$@"
  fi
  EOT

envf fname -<<'EOT'
  echo child
  if [ $# -gt 3 ]; then
    echo $1
    shift
    fname $@
  else
    $fname_prev "$@"
  fi
  EOT

fname 1 2 3 4 5
```

these definitions are then evaluated as follows:

```
fname_ = 0

fname_0 () {
  echo parent
  if [ $# -gt 0 ]; then
    echo $@
    shift
    fname "$@"
  fi
}

fname () {
  fname_0 "$@"
}

fname_1 () {
  fname_prev = "fname_0"
  echo child
  if [ $# -gt 3 ]l then
    echo $1
    shift
    fname $@
  else
    $fname_prev "$@"
  fi
  unset fname_prev
}

fname () {
  fname_1 "$@"
}
```

in the example above, `$fname_prev` calls the extended implementation `fname_0` from the extention implementation `fname_1`.

the `envd` function applies sane default options to `cd`.

the `envs` function is used to source profiles from their own directories:

```sh
$ cat enva.sh
$ cat dirb/envb.sh
$ cat dirb/dirc/envc.sh
$ . enva.sh

```

the default profile extends `envs` to handle profile directories with `$ENVD`, and then uses it to source the profiles in `$ENVS`, [(ex.)](https://github.com/MayCXC/envy/blob/master/env.sh).
if `envs` receives an error exit code when it sources a profile, it exits with that code.
any paths sourced from `envs` that do not start with `/` are prepended with `./`, to avoid sources from `$PATH`.

the `envc` function is used to document and configure completions for functions defined with `envf` (todo, unsure how possible this is to do with posix sh):

## Advanced Usage

the following example is a replacement `envy.sh` that extends `envs` to interactively review each profile the first time it is sourced, and then sign it with with `ssh-keygen` (todo):

```sh
. "${ENVY}.sh"

envf envs-<<'EOT'
  for p in "$@"; do
    echo todo
    read y/N
    if [ review = "y" ]; then
      "${EDITOR} ${p}"
      read y/N
      ssh-keygen ...
    fi
  done
  EOT
```

## Similar Projects

- https://github.com/direnv/direnv
- https://github.com/direnv/direnv?tab=readme-ov-file#related-projects
- https://github.com/casey/just
- https://github.com/casey/just?tab=readme-ov-file#alternatives-and-prior-art
