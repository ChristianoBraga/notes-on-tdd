FILES = intro/intro.md \
	the-need-for-types/tnft.lidr \
	type-define-refine/tdr.lidr \
	the-need-for-dependent-types/tnfdt.lidr \
	insertion-sort/is.lidr \
	programming-with-first-class-types/pwfct.lidr \
	streams/streams.lidr \
	protocols/protocols.lidr \
	protocols/simple-app.lidr
#	domain-specific-commands/dsc.lidr 

PANDOC-PAPER-CMD = pandoc -N --toc -f markdown -t latex -s

PANDOC-SLIDES-CMD = pandoc -t beamer --slide-level=2 \
		        -V theme:metropolis \
			-V institute:"Universidade Federal Fluminense" 

PANDOC-MARKDOWN-CMD = pandoc -f markdown -t markdown -s

all: check slides paper

paper: 
	${PANDOC-PAPER-CMD} \
	header.md ${FILES} -s -o notes-on-tdd.pdf

md:
	${PANDOC-MARKDOWN-CMD} \
	header-slides.md ${FILES} -o notes-on-tdd.md

slides:
	${PANDOC-SLIDES-CMD} \
	header-slides.md ${FILES} \
        -o notes-on-tdd-slides.pdf

test:
	#Checking for required tools in macOS Mojave and Linux Ububtu.
	@test -x /usr/local/bin/idris || test -x ${HOME}/.cabal/bin/idris
	@test -x /usr/local/texlive/*/bin/x86_64-*/pdflatex
	#OK

check: test
	#Checking for code files.
	- idris --check the-need-for-types/tnft.lidr
	@echo ==============================================
	@echo Checking for tnft.lidr should give an error...
	@echo ==============================================
	- idris --check the-need-for-types/delta-fix.lidr
	@echo ==============================================
	@echo Checking for delta-fix.lidr should give an error...
	@echo ==============================================
	- idris --check the-need-for-types/delta-fix2.lidr
	- idris --check the-need-for-types/bhask-fun.lidr
	@echo ==============================================
	@echo Checking for bhask-fun.lidr should give an error...
	@echo ==============================================
	- idris --check the-need-for-types/bhask-fun-fix.lidr
	- idris --check type-define-refine/tdr.lidr
	- idris --check the-need-for-dependent-types/tnfdt.lidr
	- idris --check insertion-sort/is.lidr
	- idris --check programming-with-first-class-types/pwfct.lidr
	- idris --check streams/streams.lidr
	- idris --check protocols/protocols.lidr
	- idris --check -p contrib protocols/simple-app.lidr
#	- idris --check domain-specific-commands/dsc.lidr
#	- idris --check domain-specific-commands/ArithCmd.idr
