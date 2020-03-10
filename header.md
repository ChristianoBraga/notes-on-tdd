---
documentclass: llncs
classoption: a4wide
title: Notes on type-driven development with Idris
author: Christiano Braga 
date: \today
abstract: | 
  In these notes I explore the type-driven software development approach
  using examples from "Type-driven Development", by Edwin Brady, and
  my own. Essentially, it relies on the concept of dependent types to
  enforce safe behavior. Idris is our programming language of 
  choice.
colorlinks: blue
header-includes:
    - "\\usepackage{fourier}"
    - "\\usepackage{cite}"
    - "\\usepackage[utf8]{inputenc}"
    - "\\usepackage{amsmath}"
    - "\\usepackage{bbm}"
    - "\\usepackage{draftwatermark}"
	- "\\SetWatermarkLightness{0.95}"
    - "\\pagestyle{plain}"
	- "\\institute{Instituto de Computação, Universidade Federal Fluminense \\and FADoSS Research Group, Universidad Complutense de Madrid \\and COIN Academic Partner, Tata Consultanncy Services Brazil}"
---
