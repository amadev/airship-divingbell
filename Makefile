# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

HELM := helm
TASK := build

EXCLUDES := helm-toolkit docs tests tools logs
CHARTS := $(filter-out $(EXCLUDES), $(patsubst %/.,%,$(wildcard */.)))
CHART := divingbell

all: $(CHART)

$(CHART):
	@echo
	@echo "===== Processing [$@] chart ====="
	@make $(TASK)-$@

init-%: clean
	DEP_UP_LIST=$* tools/helm_tk.sh $(HELM)

lint-%: init-%
	if [ -d $* ]; then $(HELM) lint $*; fi

dryrun-%: init-%
	$(HELM) template $*

build-%: lint-%
	if [ -d $* ]; then $(HELM) package $*; fi

clean:
	@echo "Removed .b64, _partials.tpl, and _globals.tpl files"
	rm -rf helm-toolkit/secrets/*.b64
	rm -rf */templates/_partials.tpl
	rm -rf */templates/_globals.tpl
	rm -rf doc/build

.PHONY: $(EXCLUDES) $(CHARTS)

.PHONY: charts
charts: clean build-$(CHART)

# TODO This needs to run the equivalent of what is in
#      divingbell/tools/gate/setup.sh + test.sh . At present, this is
#      being investigated on how to bring it up to date.
.PHONY: tests
tests: charts

.PHONY: docs
docs: clean build_docs

.PHONY: build_docs
build_docs:
	tox -e docs
