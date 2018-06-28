#!/usr/bin/env bash
curl --user ${CIRCLE_TOKEN}: \
  --request POST \
  --form revision=fa279c82728d4e0d764f09f3db0f63269575fba4 \
  --form config=@config.yml \
  --form notify=false \
  https://circleci.com/api/v1.1/project/github/patricklindsay/wice_grid/tree/master
