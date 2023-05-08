define group
printf "::group::Module %s ${TFMAKE_CONTEXT}\n" \${1}
endef

define endgroup
printf "::endgroup::\n"
endef
