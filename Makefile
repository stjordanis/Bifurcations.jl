JULIA_BIN = julia
JULIA = time $(JULIA_BIN) --color=yes

# See [[./.travis.yml::GKS_WSTYPE]]
GKS_WSTYPE ?= png
export GKS_WSTYPE

.PHONY: help test

help:
	@cat misc/make-help.md

test:
	$(JULIA) --check-bounds=yes test/runtests.jl

include misc/docs.mk