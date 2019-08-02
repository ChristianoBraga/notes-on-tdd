pdf:
	cat header.md the-need-for-types/tnft.lidr the-need-for-dependent-types/tnfdt.lidr programming-with-first-class-types/pwfct.lidr | pandoc -N --toc -f markdown -t latex -o notes-on-tdd.pdf
