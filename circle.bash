#!/bin/bash
#############################################################################
# A script for splitting the test suite across nodes on CircleCI.
#############################################################################

export PATH=/home/ubuntu/.rvm/gems/ruby-1.9.3-p448/bin:$PATH

unit_tests () {
  status=0

  case $CIRCLE_NODE_INDEX in
    0)  export RVM=1.9.3
        export PUPPET_GEM_VERSION="~> 3.0"
        ;;
    1)  export RVM=2.1.5
        export PUPPET_GEM_VERSION="~> 3.0"
        ;;
    2)  export RVM=2.1.6
        export PUPPET_GEM_VERSION="~> 4.0"
        export STRICT_VARIABLES="yes"
        ;;
    *)	echo "No tests on this node."
        return 0
        ;;
  esac

  rvm use $RVM --install --fuzzy
  export BUNDLE_GEMFILE=$PWD/Gemfile
  rm -f Gemfile.lock
  ruby --version
  rvm --version
  bundle --version
  gem --version
  bundle install --without development
  bundle exec rake lint || status=$?
  bundle exec rake validate || status=$?
  bundle exec rake spec SPEC_OPTS="--format RspecJunitFormatter \
      -o $CIRCLE_TEST_REPORTS/rspec/puppet.xml" || status=$?
  return $status
}

echo "Running on test node $CIRCLE_NODE_INDEX of $CIRCLE_NODE_TOTAL"
$1
exit $?
