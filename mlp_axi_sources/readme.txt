version of mlp core with axi lite and axi stream interfaces
putanje do fajlova sa parametrima i slikama koje treba izmeniti su na linijama:
 35 - 36 za test images i labele
 109 - 112 za weights i biases

possible changes:
load pixel/wait pixel - could it be just 1 state instead of 2?
BRAM with reset? it it synthesizable?
