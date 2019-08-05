FILES = intro/intro.md \
	the-need-for-types/tnft.lidr \
	type-define-refine/tdr.lidr \
	the-need-for-dependent-types/tnfdt.lidr \
	insertion-sort/is.lidr \
	programming-with-first-class-types/pwfct.lidr 

all: check slides paper

paper:
	pandoc -N --toc -f markdown -t latex \
	header.md ${FILES} -s -o notes-on-tdd.pdf

md:
	pandoc -f markdown -t markdown -s \
	header-slides.md ${FILES} -o notes-on-tdd.md

slides: 
	pandoc header-slides.md ${FILES} \
	-t beamer --slide-level=2 \
        -V theme:metropolis \
	-V institute:"Universidade Federal Fluminense" \
        -o notes-on-tdd-slides.pdf

check: check-tnft

check-tnft:
	- idris --check the-need-for-types/tnft.lidr
	- idris --check the-need-for-dependent-types/tnfdt.lidr



