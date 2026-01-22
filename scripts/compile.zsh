# vim: filetype=zsh: tabstop=3: shiftwidth=3: noexpandtab:


# OPTIONS
emulate zsh \
	+o bare_glob_qual  +o glob_assign \
	+o case_glob       +o glob_dots \
	+o err_exit        -o glob_star_short \
	-o err_return      +o glob_subst \
	-o extended_glob   -o null_glob \
	-o glob            -o numeric_glob_sort


local    basedir tspth
local    pth
local -a allpths
local -r ptn='.zwc'


## DIRS
basedir=${(%):-'%x'}
basedir=${basedir:a:h:h}
basedir=${basedir:A}

tspth=${basedir}/compile.timestamp


## ALLPTHS
allpths=( ${basedir}/(bin|scripts)/*(#q-.om:a) )
allpths=( ${allpths%${~ptn}} )
allpths=( ${(u)allpths} )


## COMPILE
if (( ${#allpths} > 0 )); then
	if [[ ! -f "${tspth}" || "${allpths[1]}" -nt "${tspth}" ]]; then
		for pth in "${(@)allpths}"; do
			zcompile -R "${pth}"
		done

		touch "${tspth}"
	fi
fi
