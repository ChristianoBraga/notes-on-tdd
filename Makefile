pdf:
	pandoc -N --toc -f markdown -t latex header.md the-need-for-types/tnft.lidr type-define-refine/tdr.lidr the-need-for-dependent-types/tnfdt.lidr programming-with-first-class-types/pwfct.lidr -s -o notes-on-tdd.pdf
