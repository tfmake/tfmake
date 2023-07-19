define group
printf "Module %s ${TFMAKE_CONTEXT}\n" \${1}
endef

define endgroup
printf "\n"
endef
