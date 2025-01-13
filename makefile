
.PHONY: test
test:
	helm unittest -f unittests/**/*_test.yaml charts/deep
	helm unittest -f unittests/**/*_test.yaml charts/deep-distributed
