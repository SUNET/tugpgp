_default:
  @just --list --unsorted

# To build the source tarball for pypi
tar:
	mv src/tugpgp/tugpgp.pyproject* ./
	flit --debug build  --no-use-vcs
	mv ./tugpgp.pyproject src/tugpgp/
	mv ./tugpgp.pyproject.user src/tugpgp/

