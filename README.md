# Overview
This is a sample python lambda setup containing Cloudformation stacks for creating the lambda function and Makefile with targets for building and releasing the package to Cosmos.

# How to build the infrastructure
The Cloudformation templates are defined in python using troposphere in `infrastructure/src/*.py`. You can modify them whichever way you like and then recompile them running:
```
$ cd infrastructure
$ make all
```
Then use the templates under `infrastructure/templates/*.json` and build the stacks in your corresponding accounts.

# How to build the lambda package
In order to build the lambda package simply run:
```
$ make build
```

This will create a clean centos 7 environment, install a virtualenv with latest version of `pip`, install all dependencies and zip the result and put it in `./package.zip` according the AWS docs: http://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html#deployment-pkg-for-virtualenv

# How to release the package
In order to build and release the lambda package simply run:
```
$ make release
```

This will build the package running the target above and then use the `cosmos-release` tool to generate a version, upload the package in the lambda-repository and post the release metadata to cosmos.

# What's that Makefile doing?
The `make build` command creates a mock environment which looks like CentOS 7 and builds the package in there using a Python virtualenv.

It isn't perfect; it blindly copies a lot of packages into the mock src directory and zips them up, along with the code you added to the src directory.

The zipping part is good; this is how AWS Lambda gets its dependencies. Unfortunately some of the packages that get dragged in are superfluous for deployments - including pip itself. In a production environment it would be wise to prune some of these extra packages to get a minimal provision.

If you have a better way of doing this (and there certainly are better ways) please send a PR with details!

## Why does it delete boto3 and botocore?! I need those!
AWS Lambda provides them by default, so you don't need to include them as dependencies. By removing them, the size of a resulting "hello world" ZIP file is roughly halved.
