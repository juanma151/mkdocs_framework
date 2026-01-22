# vim: filetype=zsh: tabstop=3: shiftwidth=3: noexpandtab:

typeset -g __MKDOCSPRJS_INIT

## exit if loaded
if (( ${__MKDOCSPRJS_INIT:-0} == 1 )); then
	return 0
fi


# OPTIONS
emulate zsh \
	+o bare_glob_qual  +o glob_assign \
	+o case_glob       +o glob_dots \
	+o err_exit        -o glob_star_short \
	-o err_return      +o glob_subst \
	-o extended_glob   -o null_glob \
	-o glob            -o numeric_glob_sort


function () {
	typeset -g __MKDOCSPRJS_PRJ_PATH

	local    bindir datadir  basedir nixprdir
	local    fxdir  fxdigest envrc
	local    prjpth
	local -i hasprj

	# folders up
	sdir=${(%):-'%x'}
	sdir=${sdir:a:h}
	
	datadir=${sdir:h}

	# realpath of folders up
	sdir=${sdir:A}
	datadir=${datadir:A}

	# rest of paths
	bindir=${datadir}/bin
	bindir=${bindir:A}

	nixprdir=${datadir}/nixprofile
	nixprdir=${nixprdir:A}/shell.nxp

	fxdir=${datadir}/functions
	fxdir=${fxdir:A}

	fdigest=${datadir}/functions.zwc
	fdigest=${fdigest:A}

	basedir=${datadir}/paths/base
	basedir=${basedir:A}

	envrc=${basedir}/.envrc

	## PROJECT
	if (( ${+__MKDOCSPRJS_PRJ_PATH} == 1 )); then
		prjpth=${__MKDOCSPRJS_PRJ_PATH}
		hasprj=1
	else
		prjpth=''
		hasprj=0
	fi


	typeset -gx -A __MKDOCSPRJS_DIRS=(
		      [base]=${basedir}
		       [bin]=${bindir}
		 [functions]=${fxdir}
		     [nixpr]=${nixprdir}
		   [scripts]=${sdir}
		   [fdigest]=${fdigest}
		     [envrc]=${envrc}
		[hasproject]=${hasprj}
		   [project]=${prjpth}
	)
}


function () {
	typeset -gx -a fpath
	typeset -g  -A __MKDOCSPRJS_DIRS

	local -a fpths  fnames  oldfpath
	local    aname  fpth    fdigest
	local -r ptn='.zwc'

	# get the functions and the function names (sorted by mod_date, yourgest first)
	fpth=${__MKDOCSPRJS_DIRS[functions]}

	fpths=( ${fpth}/*(#q-.om:a) )
	fpths=( ${(u)${fpths%${~ptn}}} )

	if (( ${+fpths} > 0 )); then
		fnames=( ${fpths:t} )
		oldfpath=( ${fpath} )

		# get the digest
		fdigest=${__MKDOCSPRJS_DIRS[fdigest]}

		if [[ ! -f "${fdigest}" || "${fpths[1]}" -nt "${fdigest}" ]]; then
			(
				fpath=( ${fpth} ${fpath} )
				autoload -R -U -k "${(@)fnames}"
				zcompile -a -M "${fdigest}" "${(@)fnames}"
			)
		fi

		# add the digest to the fpath
		fpath=( ${fdigest} ${fpath})
		autoload -R -U -k +X "${(@)fnames}"

		# revert the fpath
		fpath=( ${oldfpath} )
	fi

	# compile scripts
	zsh "${__MKDOCSPRJS_DIRS[scripts]}/compile.zsh"
}


export __MKDOCSPRJS_INIT=1
