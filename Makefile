.PHONY: release test build

# PLEASE CHANGE THE COMPONENT NAME
COMPONENT="wspartners-sandbox-lambda-test"

clean:
	rm -rf package.zip

# Note: we remove the boto3 and botocore folders because they're provided by
# default by the AWS lambda environment
build: clean
	mock-run --os 7 \
	--install python-pip python-virtualenv \
	--copyin src src \
	--shell "virtualenv venv && \
		venv/bin/pip install --upgrade pip && \
		venv/bin/pip install --upgrade setuptools && \
		venv/bin/pip install --requirement src/requirements.txt && \
		cp -R venv/lib/python2.7/site-packages/* src/ && \
		pushd src/ && \
		(rm -r boto3 botocore || :) && \
		zip -9 -r ../package.zip * && \
		popd" \
	--copyout package.zip package.zip

release: clean build
	cosmos-release lambda --lambda-version=`cosmos-release generate-version $(wspartners-sandbox-lambda-test)` "./package.zip" $(wspartners-sandbox-lambda-test)

venv/%: %/requirements.txt
	type virtualenv >/dev/null
	(virtualenv $@ && $@/bin/pip install -r $<) || rm -rf $@

test: venv/test
	venv/test/bin/nosetests -v test/
